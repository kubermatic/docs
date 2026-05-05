+++
title = "Timeouts"
linkTitle = "Timeouts"
date = 2026-05-05T10:00:00+02:00
weight = 5
enterprise = true
+++

KubeLB exposes Envoy's HTTP and TCP timeouts as configurable fields on the `Config`, `Tenant`, `Route`, and `LoadBalancer` resources, plus tenant-side annotations on `Ingress`, `HTTPRoute`, and `TCPRoute`. Operators can extend or shorten timeouts per-cluster, per-tenant, or per-route without patching code or restarting the proxy.

## Why Configurable Timeouts?

Default Envoy timeouts target short-lived REST traffic. They cut off useful long-lived flows:

- Streaming downloads (object storage, model artifacts, video) drop at the request timeout.
- WebSocket / SSE / gRPC server-streaming sessions die at the HTTP idle-connection timeout.
- Slow-warming upstreams (LLM inference, JVM cold-start) hit the connect timeout before they are ready.

KubeLB defaults are tuned for these workloads, and every field is overridable per resource.

## Configuration Levels

Timeouts can be set at four levels. Resolution per-field, with later levels overriding earlier ones:

1. **Built-in defaults** — applied when no override is set anywhere.
2. **`Config` CRD** (`spec.timeouts`) — cluster-wide default for all tenants.
3. **`Tenant` CRD** (`spec.timeouts`) — overrides Config for a single tenant.
4. **`Route` / `LoadBalancer` CRD** (`spec.timeouts`) — overrides Tenant and Config for one resource.

Each field is merged independently. Setting `Tenant.spec.timeouts.tcpIdle` does not clear `Config.spec.timeouts.connect` — the `connect` value still applies.

A value of `0s` is **not** "inherit". It is "disable that timeout" — Envoy semantics. Leave the field unset to inherit from the next tier.

## Configuration Fields

| Field | Type | Built-in Default | Envoy Setting | Applies To |
|-------|------|------------------|---------------|------------|
| `request` | duration | `0s` (disabled) | `route.timeout` | Ingress, HTTPRoute, GRPCRoute |
| `streamIdle` | duration | `1h` | `http_connection_manager.stream_idle_timeout` | Ingress, HTTPRoute, GRPCRoute |
| `requestHeaders` | duration | `0s` (disabled) | `http_connection_manager.request_headers_timeout` | Ingress, HTTPRoute, GRPCRoute |
| `idleConnection` | duration | `1h` | `common_http_protocol_options.idle_timeout` | Ingress, HTTPRoute, GRPCRoute |
| `tcpIdle` | duration | `1h` | `tcp_proxy.idle_timeout` | TCPRoute, TLSRoute, L4 LoadBalancer |
| `connect` | duration | `5s` | `cluster.connect_timeout` | All routes and L4 LoadBalancer |

Durations follow Go's `time.ParseDuration` format: `30s`, `5m`, `1h`, `2h30m`.

## Tenant-Side Annotations

Tenant-cluster users do not need access to the management cluster to tune timeouts. The CCM translates these annotations on `Ingress`, `HTTPRoute`, `GRPCRoute`, `TCPRoute`, and `TLSRoute` into the corresponding `Route.spec.timeouts` field:

| Annotation | Maps To |
|------------|---------|
| `kubelb.k8c.io/timeout-request` | `request` |
| `kubelb.k8c.io/timeout-stream-idle` | `streamIdle` |
| `kubelb.k8c.io/timeout-request-headers` | `requestHeaders` |
| `kubelb.k8c.io/timeout-idle-connection` | `idleConnection` |
| `kubelb.k8c.io/timeout-tcp-idle` | `tcpIdle` |
| `kubelb.k8c.io/timeout-connect` | `connect` |

Invalid or negative durations are silently ignored. The remaining valid annotations still apply.

## Global Configuration

Apply cluster-wide timeout defaults via the `Config` CRD in the management cluster:

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: Config
metadata:
  name: default
  namespace: kubelb
spec:
  timeouts:
    streamIdle: 30m
    idleConnection: 30m
    connect: 10s
```

When installing via the Helm chart, set these under `kubelb.timeouts`:

```yaml
kubelb:
  timeouts:
    streamIdle: 30m
    idleConnection: 30m
    connect: 10s
```

## Tenant Configuration

Override Config defaults for a single tenant:

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: Tenant
metadata:
  name: streaming-tenant
  namespace: kubelb
spec:
  timeouts:
    streamIdle: 4h
    idleConnection: 4h
    tcpIdle: 4h
```

Fields not set on the Tenant fall back to the Config (or built-in default if the Config also leaves them unset).

## Route / LoadBalancer Configuration

For finer control, set timeouts on the management-cluster `Route` or `LoadBalancer` CR:

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: Route
metadata:
  name: object-storage-route
  namespace: tenant-streaming
spec:
  timeouts:
    request: 0s          # disable per-request timeout for downloads
    streamIdle: 6h
    idleConnection: 6h
```

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: LoadBalancer
metadata:
  name: ssh-bastion
  namespace: tenant-ops
spec:
  timeouts:
    tcpIdle: 24h          # long-lived SSH sessions
    connect: 3s
```

## Tenant-Side Annotation Examples

### Streaming Ingress

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: minio-downloads
  namespace: default
  annotations:
    kubelb.k8c.io/timeout-request: "0s"
    kubelb.k8c.io/timeout-stream-idle: "2h"
    kubelb.k8c.io/timeout-idle-connection: "2h"
spec:
  ingressClassName: kubelb
  rules:
    - host: minio.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: minio
                port:
                  number: 9000
```

### Long-Lived TCP Route

```yaml
apiVersion: gateway.networking.k8s.io/v1alpha2
kind: TCPRoute
metadata:
  name: postgres
  namespace: default
  annotations:
    kubelb.k8c.io/timeout-tcp-idle: "8h"
    kubelb.k8c.io/timeout-connect: "5s"
spec:
  parentRefs:
    - name: postgres-gateway
  rules:
    - backendRefs:
        - name: postgres
          port: 5432
```

### Slow-Warming Upstream

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: llm-inference
  namespace: default
  annotations:
    kubelb.k8c.io/timeout-connect: "30s"
    kubelb.k8c.io/timeout-request: "0s"
    kubelb.k8c.io/timeout-stream-idle: "10m"
spec:
  parentRefs:
    - name: ai-gateway
  rules:
    - backendRefs:
        - name: llm-server
          port: 8080
```

## Behavior Change from Earlier Releases

Two defaults shifted from upstream Envoy values to streaming-friendly ones. **No action is required if the new defaults work for your workloads** — but if a deployment relied on requests being capped at 15 seconds, or on idle HTTP connections being recycled every 60 seconds, you must opt back in:

| Field | Previous Default | Current Default |
|-------|------------------|-----------------|
| `request` (HTTP `route.timeout`) | `15s` (Envoy default) | `0s` (disabled) |
| `idleConnection` (HTTP `common_http.idle_timeout`) | `60s` (KubeLB hardcoded) | `1h` |

Restore the previous behavior cluster-wide:

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: Config
metadata:
  name: default
  namespace: kubelb
spec:
  timeouts:
    request: 15s
    idleConnection: 60s
```

Or per-tenant:

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: Tenant
metadata:
  name: legacy-tenant
spec:
  timeouts:
    request: 15s
    idleConnection: 60s
```

## Monitoring

Watch for timeout-driven disconnects with these Envoy metrics:

- `envoy_http_downstream_rq_idle_timeout`: Connections closed because no request arrived within `streamIdle`.
- `envoy_http_downstream_rq_max_duration_reached`: Connections cut by `request` (per-request timeout).
- `envoy_cluster_upstream_cx_connect_timeout`: Upstream connect attempts that exceeded `connect`.
- `envoy_tcp_idle_timeout`: TCP proxy connections closed by `tcpIdle`.

If `envoy_cluster_upstream_cx_connect_timeout` is rising, consider raising `connect`. If clients report mid-download disconnects on streaming workloads, raise `streamIdle` and `idleConnection`.

## Precedence Cheat Sheet

```text
Route.spec.timeouts.<field>          (highest precedence)
LoadBalancer.spec.timeouts.<field>
Tenant.spec.timeouts.<field>
Config.spec.timeouts.<field>
built-in default                     (fallback)
```

A `nil` value at any level falls through. A `0s` value at any level disables the timeout — it does not fall through.

## Further Reading

- [Envoy HTTP Connection Manager Timeouts](https://www.envoyproxy.io/docs/envoy/latest/configuration/http/http_conn_man/headers#config-http-conn-man-headers-timeouts)
- [Envoy Route Timeout](https://www.envoyproxy.io/docs/envoy/latest/api-v3/config/route/v3/route_components.proto#config-route-v3-routeaction)
- [Envoy TCP Proxy Idle Timeout](https://www.envoyproxy.io/docs/envoy/latest/api-v3/extensions/filters/network/tcp_proxy/v3/tcp_proxy.proto)
- [Envoy Cluster Connect Timeout](https://www.envoyproxy.io/docs/envoy/latest/api-v3/config/cluster/v3/cluster.proto#config-cluster-v3-cluster)
