+++
title = "KubeLB Dashboard"
linkTitle = "Dashboard"
date = 2026-04-23T10:00:00+02:00
weight = 28
description = "Web UI for KubeLB — browse tenants, LoadBalancers, and Routes, watch live service traffic, view per-proxy metrics, and manage WAF policies across your fleet."
+++

## Overview

KubeLB Dashboard is the web UI for KubeLB. A single chart and binary cover both
Community and Enterprise editions — the edition is detected internally at
runtime, so there is no separate EE build. Source code and upstream
documentation live at [kubermatic/kubelb-dashboard](https://github.com/kubermatic/kubelb-dashboard).

Beyond browsing tenants, LoadBalancers, Routes, and Gateway API resources, the
dashboard can render a [live traffic graph](#traffic-view-hubble), [per-proxy
metrics](#metrics-prometheus), and [Kubernetes events](#events) on detail pages.
Enterprise Edition adds [WAF policy management](#waf-policies-enterprise-edition)
and a read-only [AI &amp; MCP gateway](#ai--mcp-gateways-enterprise-edition) view.

## Screenshots

{{< tabs name="dashboard-screenshots" >}}
{{% tab name="Overview" %}}
Cluster overview with resource counts and health.

![Dashboard overview](/img/kubelb/common/dashboard/overview.png)
{{% /tab %}}
{{% tab name="Tenants" %}}
Tenant detail showing enabled features, DNS, certificates, and tunnel configuration.

![Tenant detail](/img/kubelb/common/dashboard/tenants.png)
{{% /tab %}}
{{% tab name="Routes" %}}
Route detail with endpoints, source, DNS/certificate state, and route conditions.

![Route detail](/img/kubelb/common/dashboard/routes.png)
{{% /tab %}}
{{% tab name="WAF Policies" %}}
WAF policies list (Enterprise Edition).

![WAF policies](/img/kubelb/common/dashboard/waf.png)
{{% /tab %}}
{{< /tabs >}}

## Install

Install the dashboard from the Kubermatic OCI registry:

```bash
helm upgrade kubelb-dashboard \
  oci://quay.io/kubermatic/helm-charts/kubelb-dashboard \
  --version v1.0.1 \
  --namespace kubelb --create-namespace --install
```

The dashboard is deployed alongside the KubeLB Manager in the `kubelb`
namespace on the management cluster.

## Expose via HTTPRoute

Enable the chart's built-in HTTPRoute (Gateway API v1) with `--set` flags. It
is independent of `ingress.enabled` — both may be on simultaneously.

```bash
helm install kubelb-dashboard oci://quay.io/kubermatic/helm-charts/kubelb-dashboard \
  --set httpRoute.enabled=true \
  --set httpRoute.parentRefs[0].name=kubelb \
  --set httpRoute.parentRefs[0].namespace=kubelb \
  --set httpRoute.hostnames[0]=app.example.com
```

Equivalent `values.yaml`:

```yaml
httpRoute:
  enabled: true
  parentRefs:
    - name: kubelb
      namespace: kubelb
  hostnames:
    - app.example.com
```

`parentRefs` must point at an existing Gateway. Omitting `httpRoute.rules`
routes PathPrefix `/` to the dashboard Service on `service.port`; override
`rules` for custom matches or backends.

## Expose via Ingress

Enable the chart's built-in Ingress with `--set` flags:

```bash
helm install kubelb-dashboard oci://quay.io/kubermatic/helm-charts/kubelb-dashboard \
  --set ingress.enabled=true \
  --set ingress.className=nginx \
  --set ingress.hosts[0].host=app.example.com \
  --set ingress.hosts[0].paths[0].path=/ \
  --set ingress.hosts[0].paths[0].pathType=Prefix
```

Equivalent `values.yaml`:

```yaml
ingress:
  enabled: true
  className: nginx
  hosts:
    - host: app.example.com
      paths:
        - path: /
          pathType: Prefix
```

For TLS termination, pair the Ingress with
[cert-manager](https://cert-manager.io) and populate `ingress.tls` and
`ingress.annotations` accordingly.

## Editions

A single chart and image serve both editions. The edition is detected at runtime
by probing for the `wafpolicies` CRD (present in Enterprise Edition, absent in
Community Edition) — there is nothing to configure. On Community Edition the
Enterprise-only navigation entries and detail-page sections are hidden; on
Enterprise Edition they appear automatically.

| Capability                                    | Community | Enterprise |
| --------------------------------------------- | :-------: | :--------: |
| Tenants, LoadBalancers, Routes, Gateway API   |     ✓     |     ✓      |
| Traffic view, Metrics, Events, Watch          |     ✓     |     ✓      |
| WAF policy management                         |           |     ✓      |
| AI &amp; MCP gateways                         |           |     ✓ *    |
| Tenant tunnel / circuit-breaker / limit fields|           |     ✓      |

<small>* AI &amp; MCP gateways additionally require the agentgateway addon; see below.</small>

## Traffic View (Hubble)

The **Traffic** view renders a live service-to-service graph and an accompanying
flow table sourced from [Cilium Hubble](https://docs.cilium.io/en/stable/observability/hubble/).
Select a time window (`1m`, `5m`, `15m`, or `1h`), filter flows, and open a
per-proxy subgraph to focus on the traffic handled by a single KubeLB Envoy
proxy. A detail panel breaks down the selected edge or flow.

![Live traffic graph](/img/kubelb/common/dashboard/traffic.png?classes=shadow,border "Live service-to-service graph and flow table")

Point the dashboard at the Hubble Relay gRPC endpoint:

```yaml
traffic:
  hubbleRelayAddress: hubble-relay.kube-system.svc:80
```

The Traffic view is **capability-gated**: when no Hubble Relay is reachable, the
view is hidden entirely. When the relay is served over mTLS on port `443`, the
dashboard loads client certificates automatically during
[auto-discovery](#observability-auto-discovery); for a TLS relay on a non-standard
port, set an explicit address and supply the certificate material through the
`HUBBLE_RELAY_TLS_*` [environment variables](#environment-variable-reference).

## Metrics (Prometheus)

The **Metrics** tab on an Envoy Proxy detail page surfaces per-proxy metrics —
request rate, 5xx errors, p99 latency, and active connections — computed from
the Envoy series scraped by Prometheus.

![Per-proxy metrics](/img/kubelb/common/dashboard/metrics.png?classes=shadow,border "Per-proxy metrics on an Envoy Proxy detail page")

Point the dashboard at a Prometheus that scrapes the KubeLB Envoy proxies:

```yaml
metrics:
  prometheusUrl: http://prometheus.monitoring.svc:9090
```

Metrics are **capability-gated**: if Prometheus is unreachable or does not expose
the Envoy series, the metrics panels are hidden. The API templates all PromQL
server-side from a fixed set of named queries — the browser never sends raw
PromQL, so the dashboard cannot be used as an open Prometheus proxy.

## Observability Auto-Discovery

{{% notice note %}}
Auto-discovery is an upcoming feature. It is available on the dashboard `main`
branch and ships in a future release; the `traffic.autoDiscover` and
`metrics.autoDiscover` values are no-ops on older dashboard images.
{{% /notice %}}

When `traffic.hubbleRelayAddress` and `metrics.prometheusUrl` are left empty, the
API discovers the in-cluster observability backends itself, so the Traffic and
Metrics views work with **zero configuration**:

- **Hubble Relay** — the API looks for a Service labelled `k8s-app=hubble-relay`
  in any namespace, falling back to a Service named `hubble-relay` in
  `kube-system` or `cilium`. A relay on port `443` is treated as mTLS and its
  client certificates are loaded from the `hubble-relay-client-certs` Secret.
- **Prometheus** — the API probes well-known Prometheus (and VictoriaMetrics)
  Service locations and selects the first one that actually exposes the Envoy
  series the metrics panels need.

Discovery goes through **Services only** (never Pods), so it needs no RBAC beyond
what the chart already grants (cluster-wide read on `services`, `secrets`, and
`namespaces`). An explicitly configured address always wins over discovery. While
a source stays unavailable, the API re-checks every 5 minutes, so a cluster that
installs Prometheus or Hubble later is picked up without a restart.

Auto-discovery is on by default. Turn it off to pin the dashboard to explicitly
configured endpoints only:

```yaml
traffic:
  autoDiscover: false
metrics:
  autoDiscover: false
```

## Events

Resource detail pages list the Kubernetes **Events** associated with the object,
so you can see the recent reconcile activity for a tenant, LoadBalancer, or Route
without leaving the dashboard.

![Events on a detail page](/img/kubelb/common/dashboard/events.png?classes=shadow,border "Kubernetes events on a resource detail page")

## Watch Streaming

By default the dashboard polls resource lists every 15 seconds. Enable Kubernetes
**watch streaming** to receive updates as they happen:

```yaml
watch:
  enabled: true
```

Watch is disabled by default; enable it per deployment once validated against
your cluster. If a watch stream fails, the dashboard automatically falls back to
polling.

## Read-Only Mode

Run the dashboard in **read-only mode** to disable all mutating operations:

```yaml
readOnly: true
```

In this mode the API rejects mutating requests to the Kubernetes API and the UI
hides every create, edit, and delete control. When `rbac.create` is `true`, the
generated ClusterRole is additionally narrowed to read-only verbs
(`get`, `list`, `watch`) as defense-in-depth.

## AI &amp; MCP Gateways (Enterprise Edition)

On clusters running the agentgateway addon, an **AI Gateway** view lists
`AgentgatewayBackend` resources read-only. It surfaces the configured LLM
providers and models (OpenAI, Anthropic, Gemini, Mistral, Ollama) and any
federated MCP tool servers. Provider and auth credentials are shown by **name
only** — secret values are never displayed.

This view is gated on discovery of the `agentgatewaybackends.agentgateway.dev`
CRD. Because the addon is Enterprise-only, its presence already implies
Enterprise Edition; it is intentionally independent of the WAF-based edition
signal, so an Enterprise cluster can run the agentgateway addon without the WAF
addon.

## WAF Policies (Enterprise Edition)

Enterprise Edition adds a **WAF Policies** page (shown in the
[screenshots](#screenshots) above) with full create, read, update, and delete
support for `WAFPolicy` resources.

## OIDC Authentication

OIDC is off by default. The underlying API reads the following environment variables:

| Variable             | Required | Default                                      | Description                                               |
| -------------------- | -------- | -------------------------------------------- | --------------------------------------------------------- |
| `OIDC_ISSUER`        | Yes      | —                                            | OIDC provider issuer URL (e.g. `https://dex.example.com`) |
| `OIDC_CLIENT_ID`     | Yes      | —                                            | OIDC client ID                                            |
| `OIDC_CLIENT_SECRET` | Yes      | —                                            | OIDC client secret                                        |
| `SESSION_SECRET`     | Yes      | —                                            | 32+ char secret for encrypting session cookies            |
| `OIDC_REDIRECT_URI`  | No       | `http://localhost:{PORT}/auth/callback`      | Callback URL registered with IdP                          |
| `OIDC_SCOPES`        | No       | `openid email profile groups offline_access` | Space-separated scopes                                    |
| `SESSION_MAX_AGE`    | No       | `86400` (24h)                                | Session cookie max age in seconds                         |

{{% notice note %}}
All four required variables must be set together. A partial configuration
exits with an error. If none are set, the dashboard runs without
authentication.
{{% /notice %}}

Enable OIDC via `values.yaml`:

```yaml
auth:
  enabled: true
  oidc:
    issuerUrl: https://dex.example.com
    clientId: kubelb-dashboard
  existingSecret: kubelb-dashboard-auth
```

In production, supply `clientSecret` and `sessionSecret` through
`auth.existingSecret` rather than inline values, so secret material stays out
of the values file.

## Kubernetes API Access

The dashboard proxies requests to the Kubernetes API through the API server, and
by default only an **allowlist** of paths is permitted — the resource groups the
dashboard actually renders (`kubelb.k8c.io`, `apps`, `networking.k8s.io`, the
Gateway API groups, `agentgateway.dev`, and core `namespaces`/`services`/
`secrets`/`events`), plus CRD discovery. Pod `exec`, `attach`, `portforward`,
and `proxy` subresources are always blocked, as are paths containing `..` or
`%`.

The allowlist is on by default and is the recommended posture. It can be
disabled with the `KUBE_PROXY_ALLOWLIST_DISABLED=true`
[environment variable](#environment-variable-reference) — do this only when you
deliberately need broader proxy access, since it removes a defense-in-depth
boundary.

## Configuration Reference

### Helm Values

Feature-related values (see the
[chart README](https://github.com/kubermatic/kubelb-dashboard/blob/main/charts/kubelb-dashboard/README.md)
for the complete list):

| Value                        | Default | Description                                                                       |
| ---------------------------- | ------- | --------------------------------------------------------------------------------- |
| `readOnly`                   | `false` | Disable all mutating operations and narrow the ClusterRole to read-only verbs     |
| `watch.enabled`              | `false` | Stream resource-list updates instead of polling every 15s                         |
| `metrics.prometheusUrl`      | `""`    | Prometheus base URL that scrapes the KubeLB Envoy proxies                          |
| `metrics.autoDiscover`       | `true`  | Auto-discover Prometheus when `prometheusUrl` is empty (explicit URL always wins) |
| `traffic.hubbleRelayAddress` | `""`    | Hubble Relay gRPC address, e.g. `hubble-relay.kube-system.svc:80`                  |
| `traffic.autoDiscover`       | `true`  | Auto-discover Hubble Relay when `hubbleRelayAddress` is empty (explicit wins)      |
| `rbac.create`                | `true`  | Create the ClusterRole and ClusterRoleBinding the API needs                        |
| `auth.enabled`               | `false` | Enable [OIDC authentication](#oidc-authentication)                                 |

### Environment Variable Reference

The API server reads the following variables. Most are set for you by the chart
from the values above; the ones marked **env-only** are not surfaced as chart
values and must be set directly on the API container when needed.

| Variable                        | Default   | Set by            | Description                                                            |
| ------------------------------- | --------- | ----------------- | --------------------------------------------------------------------- |
| `PORT`                          | `3001`    | image             | API server listen port                                                |
| `READ_ONLY`                     | `false`   | `readOnly`        | Reject mutating requests and hide write controls                      |
| `WATCH_ENABLED`                 | `false`   | `watch.enabled`   | Stream list updates instead of polling                                |
| `PROMETHEUS_URL`                | —         | `metrics.prometheusUrl` | Prometheus base URL for per-proxy metrics                       |
| `PROMETHEUS_AUTODISCOVER`       | `true`    | `metrics.autoDiscover`  | Auto-discover Prometheus when `PROMETHEUS_URL` is unset         |
| `HUBBLE_RELAY_ADDRESS`          | —         | `traffic.hubbleRelayAddress` | Hubble Relay gRPC address for the Traffic view            |
| `HUBBLE_AUTODISCOVER`           | `true`    | `traffic.autoDiscover`  | Auto-discover Hubble Relay when `HUBBLE_RELAY_ADDRESS` is unset |
| `HUBBLE_RELAY_TLS_CA`           | —         | **env-only**      | CA certificate (PEM) for an mTLS Hubble Relay                          |
| `HUBBLE_RELAY_TLS_CERT`         | —         | **env-only**      | Client certificate (PEM) for an mTLS Hubble Relay                      |
| `HUBBLE_RELAY_TLS_KEY`          | —         | **env-only**      | Client key (PEM) for an mTLS Hubble Relay                              |
| `HUBBLE_RELAY_TLS_SERVER_NAME`  | —         | **env-only**      | Override the TLS server name when verifying the relay certificate      |
| `KUBE_PROXY_ALLOWLIST_DISABLED` | `false`   | **env-only**      | Disable the [Kubernetes API path allowlist](#kubernetes-api-access)    |
| `KUBECONFIG`                    | —         | `kubeconfig.existingSecret` | Path to a mounted kubeconfig for out-of-cluster access       |

OIDC and session variables are documented under
[OIDC Authentication](#oidc-authentication).

## Kubeconfig (optional)

For out-of-cluster access to the KubeLB management API, mount a kubeconfig
through an existing Secret:

```yaml
kubeconfig:
  existingSecret: kubelb-dashboard-kubeconfig
  key: kubeconfig
```

`kubeconfig.key` is the key inside the Secret that holds the kubeconfig file
(default `kubeconfig`). Leave `kubeconfig.existingSecret` empty to use the
in-cluster service account.

## Further Reading

- [kubermatic/kubelb-dashboard](https://github.com/kubermatic/kubelb-dashboard) — dashboard repository and README
- [kubelb-dashboard Helm chart README](https://github.com/kubermatic/kubelb-dashboard/blob/main/charts/kubelb-dashboard/README.md) — full values reference
- [KubeLB Manager installation]({{< relref "../installation" >}}) — install the management cluster the dashboard connects to
