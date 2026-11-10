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
  everything to your endpoint, when one of the sources it gathers (`apiServer`, `controllers`,
  `kubevirt`, `kubernetes` or `traces`) is on;
* a node agent, the DaemonSet `kubev-otel-agent-agent` with one pod per node, when node metrics or
  logs are turned on.

Both run in the `kubev-observability` namespace. Nothing is stored in the cluster. The Collector's
only listener is the OTLP receiver that takes the api-server's traces, open while traces are
collected and reachable only from the `kubermatic-virtualization` namespace. The node agent opens no
receiver port, Service or host port. KubeV installs no Prometheus and adds no charts to the
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
machine's own namespace in their `namespace` label. With KDP, the Collector and the node agent are
configured to add the tenant's organization and project to pod-level records from a KDP host
namespace (object state, node metrics and logs); the KubeV and KubeVirt components' own series get
none, since those pods belong to no tenant. See
[Grouping by Organization and Project](#grouping-by-organization-and-project).

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
| `export.otlp.endpoint` | Required. `host:port` for gRPC, or an `http(s)://` URL whose scheme agrees with `insecure`. The URL must not carry credentials, a query or a fragment: put tokens in `headers`. |
| `export.otlp.protocol` | `grpc` (default) or `http`. A gRPC endpoint takes no path, not even `/`. A receiver behind a path such as `/otlp` needs `http` and a URL. |
| `export.otlp.insecure` | Sends in plain text, without TLS. Cannot be combined with `tls`. |
| `export.otlp.headers` | Headers sent with every push, for example `Authorization`. |
| `export.otlp.tls.caBundle` | PEM CA certificates of the receiver, in addition to the system roots. |
| `export.otlp.tls.insecureSkipVerify` | Skips certificate verification. For testing only. Cannot be combined with `caBundle`. |
| `scrapeInterval` | How often each source is scraped and Kubernetes object state is collected, in whole seconds, at least `10s`. Defaults to `30s`. |
| `sources` | Per-source toggles, see [Choosing What to Collect](#choosing-what-to-collect). |
| `resources` | Requests and limits of the Collector container. |
| `agentResources` | Requests and limits of each node agent container. |
| `helmValues` | Extra chart values, see [Tuning the Collector](#tuning-the-collector). |

### Headers and TLS

Headers are kept in a dedicated Secret per release that the Collector and the node agent read as
environment variables, never in their ConfigMaps; the Helm release Secret holds them too, as it does every chart value. Use an access
token with the narrowest scope your backend offers rather than a personal credential.

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

With `nodes` and `logs` off, the node agent is not installed; with only `nodes` or `logs` on, the
Collector is not. At least one source must stay on:
`apply` rejects a block that turns every source off, since it would export nothing. `apiServer` and
`traces` count only with `dashboard.enabled`, which deploys the api-server. To uninstall
the Collector, remove the `observability` block; the next `apply` removes the release. The empty
`kubev-observability` namespace stays behind; delete it by hand if you do not plan to enable
observability again.

### Node Metrics

`sources.nodes: true` installs the node agent, with one pod on every node, the control plane nodes
included. Each pod reports its own node:

* node, pod, container and volume CPU, memory, file system and network usage, read from the
  kubelet;
* the host's CPU, memory, disk, file system, load and paging.

Both are collected every `scrapeInterval`. Every series carries `k8s.cluster.name` and
`k8s.node.name`, and pod and container series carry the same `k8s.*` attributes as the Collector's
metrics. With KDP, the agent is configured to add the same tenant attributes.

To report the host, the agent reads the node's root file system read-only. It talks to the kubelet
with its own service account.

### Logs

`sources.logs: true` installs the same node agent and tails the container logs of the pods in the
`kubermatic-virtualization` and `kubevirt` namespaces on its node. No other namespace is read, so
tenant workloads, and the agent and Collector themselves, are never collected. Virtual machines
whose `virt-launcher` pods run in those two namespaces are collected.

Each record carries the pod's namespace, name, UID and container, `k8s.node.name` and
`k8s.cluster.name`. With KDP, the agent is configured to add the tenant attributes too. The agent
starts at the end of each log file, so lines written while it is down are not sent.

To read the log files, the agent mounts `/var/log/pods` read-only and runs as root, because the
container runtime makes them readable by root only. With logs off, the agent keeps the image's
non-root user. In both cases it drops every Linux capability, cannot escalate privileges and has a
read-only root file system.

### Traces

With `sources.traces` on and the dashboard enabled, the api-server sends a span for every API
request, plus a child span for each call it makes to the Kubernetes API, to the Collector. The
Collector forwards them to your endpoint with the same `k8s.*` and `k8s.cluster.name` attributes as
the metrics. Span names use the route pattern, for example
`GET /api/kdp/clusters/{workspace}/permissions`, never the request path. Span attributes still carry
the request: server spans hold `url.path`, `user_agent.original` and `client.address`, and spans for
calls to the host cluster and to kcp hold `url.full`, each capped at 256 bytes.

The Collector accepts traces from inside the cluster only: a NetworkPolicy admits only pods in the
`kubermatic-virtualization` namespace to its OTLP port. The api-server sends spans to the Collector
over plaintext gRPC without authentication, so that NetworkPolicy is the only thing confining the hop
to the KubeV namespace. A `traceparent` header sent by a client is ignored, so every request starts a
trace of its own; calls to the Kubernetes API and to kcp carry it on.

`traces` is on by default, so an existing cluster with an `observability` block starts exporting
traces on its next `apply`: the Collector opens its OTLP port behind a Service and the NetworkPolicy
and pushes spans to the backend. A backend token without permission to write traces then shows up as
export errors in the Collector's log. Set `sources.traces: false` before upgrading to keep exporting
metrics only.

## Grouping by Organization and Project

With [KDP]({{< ref "../../kdp-integration" >}}) enabled, one export covers every tenant:

* a request span carries `kubev.workspace`, `kubev.organization` and `kubev.project` only when the
  request answered with a status below 400 and its workspace is a project path, taken from the
  `{workspace}` route value or verified by the host-read gate on `/api/cluster`; other spans carry
  none of them;
* the Collector and the node agent are configured to add `kubev.organization`, `kubev.project` and
  `kubev.namespace` to the object state, node metrics and logs of pods in KDP host namespaces, read
  from the namespace's labels; the KubeV and KubeVirt components' own metrics get none, since those
  pods belong to no tenant.

### Tenant Labels for KubeVirt Series

The api-server also exports `kubev_host_namespace_info{namespace, organization, project,
tenant_namespace}`, with the value 1, for every KDP host namespace. The series follows the
`apiServer` source and KDP mode, not `traces`: it reaches the backend only through the `apiServer`
scrape, so with `sources.apiServer: false` it is not exported even when traces are on. KubeVirt's
`kubevirt_vmi_*` series carry only the host namespace, so join them to this series to group virtual
machine usage by organization or project:

```promql
kubevirt_vmi_memory_used_bytes
  * on (namespace) group_left (organization, project)
  max by (namespace, organization, project) (kubev_host_namespace_info)
```

The `max by` folds the series of several api-server replicas, or of a rollout in progress, into one.

The api-server's `/metrics` listener has no authentication, and this series lists every tenant's
organization, project and namespaces. Keep the api-server's metrics Service reachable only from the
`kubev-observability` namespace.

## Tuning the Collector

`helmValues` passes extra values to the `opentelemetry-collector` chart behind both the Collector
and the node agent, merged last. Use it for processors and scheduling, such as `nodeSelector` and
`tolerations`. The values apply to the Collector and the agent alike. A list you set replaces the
installer's list, except the lists described below.

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

* `mode`, `replicaCount`, `autoscaling`, `ports`, `service`, `networkPolicy`, `configMap`,
  `alternateConfig`, `image`, `command` and `clusterRole`;
* `resources`, `nameOverride`, `fullnameOverride` and `presets`;
* `config.receivers`, `config.processors.k8s_attributes`, `config.processors.resource`,
  `config.service` and any `otlp*` exporter under `config.exporters`;
* the `checksum/kubev-otlp` pod annotation, which rolls the Collector and the agent when the headers or CA change.

Size the containers with `resources` and `agentResources` instead.

`extraManifests`, `extraEnvs`, `extraEnvsFrom`, `extraVolumes` and `extraVolumeMounts` must stay
lists; `apply` rejects a map, `null` or a single value under them. Their entries are added after the
installer's in both the Collector and the agent, except `extraManifests`: those objects are rendered
once, with the Collector, or with the node agent when no Collector is deployed. The installer's
entries carry the export headers and CA certificates and, in the agent, the node variables and host
mounts. `apply` rejects an `extraEnvs` entry without a string `name`, or named `K8S_NODE_NAME`,
`K8S_NODE_IP` or `KUBEV_OTLP_HEADER_*`, since it would override the installer's variable. Your
entries must not reuse these names either:

* the Secrets `kubev-otel-collector-otlp-headers`, `kubev-otel-collector-otlp-ca`,
  `kubev-otel-agent-otlp-headers` and `kubev-otel-agent-otlp-ca`;
* the volumes `otlp-ca`, `hostfs` and `varlogpods`, and the mount path `/etc/kubev-otlp-ca`.

A sidecar added through `extraContainers` runs with the release's service account, so in the
Collector it can read pods, nodes, services and the other objects the Collector watches across the
cluster.

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
