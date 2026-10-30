+++
title = "Observability"
date = 2026-10-29T00:00:00+00:00
weight = 5
+++

This guide sends the platform's metrics, traces and logs to an OTLP backend, such as Grafana Cloud,
a self-hosted Grafana Alloy or OpenTelemetry Collector, Datadog, Elastic or Honeycomb, and covers
how to check that data arrives.

You configure it in the `observability` block of the cluster configuration file. Once
`observability.export.otlp.endpoint` is set, `kubermatic-virtualization apply` installs:

* the OpenTelemetry Collector `kubev-otel-collector`, which scrapes the platform and pushes
  everything to your endpoint;
* a node agent, the DaemonSet `kubev-otel-agent-agent` with one pod per node, when node metrics or
  logs are turned on.

Both run in the `kubev-observability` namespace. Nothing is stored in the cluster, and nothing
outside the cluster can send telemetry in. KubeV installs no Prometheus and adds no charts to the
dashboard: the data lands in your backend.

## Before You Start

* An OTLP endpoint the cluster's nodes can reach, over gRPC or HTTP, and the credentials it needs.
  Grafana Cloud takes the instance ID and an access policy token with the `metrics:write`,
  `traces:write` and `logs:write` scopes.
* For api-server metrics and traces, `dashboard.enabled` must be `true`.

## What Is Exported

| Source | Default | What it exports |
|---|---|---|
| `apiServer` | on | KubeV api-server request and Go runtime metrics. Needs `dashboard.enabled`. |
| `controllers` | on | Metrics of the controller manager and the edge router manager. |
| `kubevirt` | on | Metrics of virt-api, virt-controller, virt-handler and virt-operator, including the `kubevirt_vmi_*` series of every virtual machine. |
| `kubernetes` | on | The state of Kubernetes objects such as pods, nodes and deployments. |
| `traces` | on | A span for every api-server request. Needs `dashboard.enabled`. See [Traces](#traces). |
| `nodes` | off | Kubelet and host metrics of every node. See [Node Metrics](#node-metrics). |
| `logs` | off | Logs of the KubeV and KubeVirt pods. See [Logs](#logs). |

Every series carries `k8s.cluster.name` (the cluster's `apiEndpoint.host`) and the scraped pod's
`k8s.namespace.name`, `k8s.pod.name` and `k8s.node.name`. KubeVirt VMI series name the virtual
machine's own namespace in their `namespace` label. With KDP, records from a KDP host namespace also
carry the tenant's organization and project, see [Grouping by Organization and Project](#grouping-by-organization-and-project).

## Enabling Observability

Add `observability` to the configuration file. Grafana Cloud takes OTLP over HTTP with basic
authentication: use the instance ID as the user name and the access policy token as the password,
and base64 encode `instanceID:token`:

```yaml
observability:
  export:
    otlp:
      endpoint: https://otlp-gateway-prod-eu-west-2.grafana.net/otlp
      protocol: http
      headers:
        Authorization: 'Basic <base64 of instanceID:token>'
  scrapeInterval: 60s
```

Then apply the configuration:

```bash
kubermatic-virtualization apply -f cluster.yaml
```

The installer checks the block when it loads the file and lists every invalid field in one run. See
[Observability]({{< ref "../../configuration-guide#observability" >}}) in the Configuration Guide
for the block in context.

| Field | Meaning |
|---|---|
| `export.otlp.endpoint` | Required. `host:port`, or a full `http(s)://` URL when the receiver sits behind a path. |
| `export.otlp.protocol` | `grpc` (default) or `http`. A `host:port` with `http` gets `https://`, or `http://` when `insecure` is set. |
| `export.otlp.insecure` | Sends in plain text, without TLS. Cannot be combined with `tls`. |
| `export.otlp.headers` | Headers sent with every push, for example `Authorization`. |
| `export.otlp.tls.caBundle` | PEM CA certificates of the receiver, in addition to the system roots. |
| `export.otlp.tls.insecureSkipVerify` | Skips certificate verification. For testing only. Cannot be combined with `caBundle`. |
| `scrapeInterval` | How often metrics are scraped, at least `10s`. Defaults to `30s`. |
| `sources` | Per-source toggles, see [Choosing What to Collect](#choosing-what-to-collect). |
| `resources` | Requests and limits of the Collector container. |
| `agentResources` | Requests and limits of each node agent container. |
| `helmValues` | Extra chart values, see [Tuning the Collector](#tuning-the-collector). |

### Headers and TLS

Headers are stored in the Collector's configuration Secret, so use an access token with the
narrowest scope your backend offers rather than a personal credential.

A receiver whose certificate a private CA signs needs that CA in `tls.caBundle`. This example uses a
self-hosted Collector or Alloy over gRPC:

```yaml
observability:
  export:
    otlp:
      endpoint: otel-gateway.example.com:4317
      protocol: grpc
      tls:
        caBundle: |
          -----BEGIN CERTIFICATE-----
          ...
          -----END CERTIFICATE-----
```

Set `insecure: true` only for a receiver that does not speak TLS at all. `insecureSkipVerify` is
meant for short tests.

### Resources

Without `resources`, the Collector requests 100m CPU and 128Mi memory and is limited to 512Mi.
Without `agentResources`, each node agent pod requests 50m CPU and 64Mi memory and is limited to
256Mi. Raise the limits on large clusters if the Collector or an agent restarts for running out of
memory.

## Choosing What to Collect

Set a source to `false` under `sources` and apply the configuration; its scrape job or receiver is
dropped:

```yaml
observability:
  export:
    otlp:
      endpoint: otlp.example.com:4317
  sources:
    kubernetes: false
    kubevirt: false
```

With `nodes` and `logs` off, the node agent is not installed. With every source off, or without the
`observability` block, the Collector is not installed either, and `apply` uninstalls an existing
one. The empty `kubev-observability` namespace stays behind; delete it by hand if you do not plan to
enable observability again.

### Node Metrics

`sources.nodes: true` installs the node agent, with one pod on every node, the control plane nodes
included. Each pod reports its own node:

* node, pod, container and volume CPU, memory, file system and network usage, read from the
  kubelet;
* the host's CPU, memory, disk, file system, load and paging.

Both are collected every `scrapeInterval`. Every series carries `k8s.cluster.name` and
`k8s.node.name`, and pod and container series carry the same `k8s.*` and KDP attributes as the
Collector's metrics.

To report the host, the agent reads the node's root file system read-only. It talks to the kubelet
with its own service account.

### Logs

`sources.logs: true` installs the same node agent and tails the container logs of the pods in the
`kubermatic-virtualization` and `kubevirt` namespaces on its node. No other namespace is read, so
tenant workloads, and the agent and Collector themselves, are never collected. Virtual machines
whose `virt-launcher` pods run in those two namespaces are collected.

Each record carries the pod's namespace, name, UID and container, `k8s.node.name`,
`k8s.cluster.name` and, with KDP, the tenant attributes. The agent starts at the end of each log
file, so lines written while it is down are not sent.

To read the log files, the agent mounts `/var/log/pods` read-only and runs as root, because the
container runtime makes them readable by root only. With logs off, the agent keeps the image's
non-root user. In both cases it drops every Linux capability, cannot escalate privileges and has a
read-only root file system.

### Traces

With `sources.traces` on and the dashboard enabled, the api-server sends a span for every API
request, plus a child span for each call it makes to the Kubernetes API, to the Collector. The
Collector forwards them to your endpoint with the same `k8s.*` and `k8s.cluster.name` attributes as
the metrics. Span names use the route pattern, for example
`GET /api/kdp/clusters/{workspace}/permissions`, never the request path.

The Collector accepts traces from inside the cluster only: a NetworkPolicy admits only pods in the
`kubermatic-virtualization` namespace to its OTLP port. A `traceparent` header sent by a client is
ignored, so every request starts a trace of its own.

## Grouping by Organization and Project

With [KDP]({{< ref "../../kdp-integration" >}}) enabled, one export covers every tenant:

* request spans carry `kubev.workspace`, `kubev.organization` and `kubev.project`;
* metrics from KDP host namespaces carry `kubev.organization`, `kubev.project` and
  `kubev.namespace`.

The api-server also exports `kubev_host_namespace_info{namespace, organization, project,
tenant_namespace}`, with the value 1, for every KDP host namespace. KubeVirt's `kubevirt_vmi_*`
series carry only the host namespace, so join them to this series to group virtual machine usage by
organization or project:

```promql
kubevirt_vmi_memory_used_bytes
  * on (namespace) group_left (organization, project)
  max by (namespace, organization, project) (kubev_host_namespace_info)
```

The `max by` folds the series of several api-server replicas, or of a rollout in progress, into one.

## Tuning the Collector

`helmValues` passes extra values to the `opentelemetry-collector` chart behind both the Collector
and the node agent, merged last. Use it for processors and scheduling, such as `nodeSelector` and
`tolerations`. The values apply to the Collector and the agent alike, and a list you set replaces
the installer's list.

```yaml
observability:
  export:
    otlp:
      endpoint: otlp.example.com:4317
  helmValues:
    nodeSelector:
      node-role.kubernetes.io/infra: ""
```

The installer owns these keys, and `apply` rejects a `helmValues` that sets any of them:

* `mode`, `alternateConfig`, `image`, `command` and `clusterRole`;
* `extraEnvs`, `extraVolumes` and `extraVolumeMounts`;
* `resources`, `fullnameOverride` and `presets`;
* `config.receivers`, `config.service` and any `otlp*` exporter under `config.exporters`.

Size the containers with `resources` and `agentResources` instead.

## Checking Observability

Check that the Collector runs, and that a node agent runs on every node when `nodes` or `logs` is
on:

```bash
kubectl -n kubev-observability get pods -o wide
```

Then read the logs of the Collector and of the node agent:

```bash
kubectl -n kubev-observability logs deploy/kubev-otel-collector
kubectl -n kubev-observability logs ds/kubev-otel-agent-agent
```

`kubectl logs ds/...` shows one pod. To read the agent on a given node, take its pod name from the
`get pods -o wide` output and run `kubectl -n kubev-observability logs <pod>`.

Export errors such as DNS failures, TLS errors or `401` responses appear as
`Exporting failed. Will retry` lines. They are logged at info level while the Collector retries, for
about five minutes, and at error level once it gives up on a batch. The Collector keeps running
either way, so a wrong token or CA shows up in these logs, not as a crash.

## Troubleshooting

| Symptom | What to do |
|---|---|
| Nothing arrives and the log shows `401` or `403` | Check the `Authorization` header and the token's scopes. |
| TLS errors in the log | Add the receiver's CA to `tls.caBundle`, and check that `protocol` matches the endpoint's port. |
| No api-server metrics or traces | Set `dashboard.enabled` to `true`. |
| No node metrics or logs | Set `sources.nodes` or `sources.logs` to `true`, and check that an agent pod runs on the node. |
| `kubevirt_vmi_*` series cannot be grouped by project | Join them with `kubev_host_namespace_info`, see [Grouping by Organization and Project](#grouping-by-organization-and-project). |

## Offline Installations

`kubermatic-virtualization mirror-images` mirrors the `opentelemetry-collector` chart and the
`otel/opentelemetry-collector-k8s` image with the rest of the platform, and the node agent uses the
same chart and image. The OTLP endpoint must still be reachable from the cluster. See
[Offline Installation]({{< ref "../../installation/offline-installation" >}}).

## Limitations

* Node metrics on IPv6-only nodes are not supported yet.
* Logs come from the `kubermatic-virtualization` and `kubevirt` namespaces only.
* KubeV pushes to one OTLP endpoint. To reach several backends, fan out from a Collector or Alloy
  you run.
