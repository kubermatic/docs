+++
title = "Health Checks"
linkTitle = "Health Checks"
date = 2026-07-22T10:00:00+02:00
weight = 6
enterprise = true
+++

KubeLB configures Envoy active health checking on the upstream clusters that back your services. By default every TCP cluster gets a connect-only TCP check. This page shows how to replace that with tuned TCP, HTTP, or gRPC checks on the `Config`, `Tenant`, `LoadBalancer`, and `Route` resources, or through tenant-side annotations.

## Why Configurable Health Checks?

The built-in connect-only TCP check confirms that a backend accepts TCP connections. It does not confirm that the application behind it is serving traffic. A pod that has crashed at the application layer but still holds an open socket keeps receiving requests.

Application-aware checks fix this:

- HTTP checks poll a health endpoint and require a success status, so a backend returning `500` is ejected from the pool.
- gRPC checks use the standard `grpc.health.v1.Health` service to probe gRPC servers.
- Tuned TCP checks let you change probe interval, timeout, and the healthy/unhealthy thresholds for connect-only checks.

## Configuration Levels

Health checks can be set at four levels. Resolution is **whole-struct**, not per-field. The first level that sets `healthCheck` wins, and its block is used in full:

1. **`Route` / `LoadBalancer` CRD** (`spec.healthCheck`): overrides Tenant and Config for one resource.
2. **`Tenant` CRD** (`spec.healthCheck`): overrides Config for a single tenant.
3. **`Config` CRD** (`spec.healthCheck`): cluster-wide default for all tenants.
4. **Built-in default**: connect-only TCP check, applied when no level sets `healthCheck`.

This differs from [Timeouts]({{< relref "../timeouts" >}}), which merge field-by-field across levels. A health check is a single unit: an HTTP check on a `Route` is not merged with a gRPC check on the `Tenant`. Only the winning level's block applies. Fields left unset **within** that block fall back to the built-in field defaults below, not to a lower level's block.

## Configuration Fields

| Field | Type | Built-in Default | Description |
|-------|------|------------------|-------------|
| `type` | enum | `TCP` | Check type: `TCP`, `HTTP`, or `GRPC` |
| `interval` | duration | `5s` | Time between checks |
| `timeout` | duration | `5s` | Time to wait for a single check |
| `healthyThreshold` | int32 | `2` | Consecutive successes before an endpoint is marked healthy |
| `unhealthyThreshold` | int32 | `3` | Consecutive failures before an endpoint is marked unhealthy |
| `http.path` | string | `/` | Request path (used when `type: HTTP`) |
| `http.host` | string | cluster name | Host/authority header (used when `type: HTTP`) |
| `http.expectedStatuses` | []int32 | `[200]` | Status codes considered healthy, each `100`-`599` |
| `grpc.serviceName` | string | empty | gRPC service name; empty checks overall server health (used when `type: GRPC`) |
| `grpc.authority` | string | cluster name | `:authority` header (used when `type: GRPC`) |

Durations follow Go's `time.ParseDuration` format: `2s`, `500ms`, `1m`.

`http` is only honored when `type: HTTP`, and `grpc` only when `type: GRPC`. Setting the mismatched block is rejected by the API.

UDP clusters never receive health checks. Envoy does not support them, so any configuration is ignored for UDP ports.

## Tenant-Side Annotations

Tenant-cluster users do not need management-cluster access to configure health checks. The CCM translates these annotations on `Service` (L4 LoadBalancer), `Ingress`, `HTTPRoute`, `GRPCRoute`, `TCPRoute`, and `TLSRoute` into the generated `LoadBalancer.spec.healthCheck` or `Route.spec.healthCheck`:

| Annotation | Maps To |
|------------|---------|
| `kubelb.k8c.io/health-check-type` | `type` |
| `kubelb.k8c.io/health-check-interval` | `interval` |
| `kubelb.k8c.io/health-check-timeout` | `timeout` |
| `kubelb.k8c.io/health-check-healthy-threshold` | `healthyThreshold` |
| `kubelb.k8c.io/health-check-unhealthy-threshold` | `unhealthyThreshold` |
| `kubelb.k8c.io/health-check-http-path` | `http.path` |
| `kubelb.k8c.io/health-check-http-host` | `http.host` |
| `kubelb.k8c.io/health-check-http-expected-statuses` | `http.expectedStatuses` (comma-separated, e.g. `200,204`) |
| `kubelb.k8c.io/health-check-grpc-service` | `grpc.serviceName` |
| `kubelb.k8c.io/health-check-grpc-authority` | `grpc.authority` |

Invalid or malformed values are silently ignored; the remaining valid annotations still apply.

## Global Configuration

Apply a cluster-wide default via the `Config` CRD in the management cluster:

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: Config
metadata:
  name: default
  namespace: kubelb
spec:
  healthCheck:
    type: HTTP
    interval: 10s
    timeout: 3s
    unhealthyThreshold: 3
    healthyThreshold: 2
    http:
      path: /healthz
      expectedStatuses:
        - 200
```

When installing via the Helm chart, set the same block under `kubelb.healthCheck`:

```yaml
kubelb:
  healthCheck:
    type: HTTP
    interval: 10s
    http:
      path: /healthz
```

## Tenant Configuration

Override the Config default for a single tenant:

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: Tenant
metadata:
  name: payments-tenant
  namespace: kubelb
spec:
  healthCheck:
    type: HTTP
    interval: 5s
    http:
      path: /health
      expectedStatuses:
        - 200
        - 204
```

## Route / LoadBalancer Configuration

Set a check on the management-cluster `Route` or `LoadBalancer` for the finest control:

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: Route
metadata:
  name: grpc-api
  namespace: tenant-payments
spec:
  healthCheck:
    type: GRPC
    interval: 5s
    grpc:
      serviceName: payments.v1.Payments
```

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: LoadBalancer
metadata:
  name: redis
  namespace: tenant-cache
spec:
  healthCheck:
    type: TCP
    interval: 2s
    timeout: 1s
    unhealthyThreshold: 2
```

## Tenant-Side Annotation Examples

### HTTP Health Check on a Service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web
  namespace: default
  annotations:
    kubelb.k8c.io/health-check-type: HTTP
    kubelb.k8c.io/health-check-http-path: /healthz
    kubelb.k8c.io/health-check-http-expected-statuses: "200,204"
    kubelb.k8c.io/health-check-interval: 10s
spec:
  type: LoadBalancer
  selector:
    app: web
  ports:
    - port: 80
      targetPort: 8080
```

### gRPC Health Check on an HTTPRoute

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: grpc-api
  namespace: default
  annotations:
    kubelb.k8c.io/health-check-type: GRPC
    kubelb.k8c.io/health-check-grpc-service: payments.v1.Payments
    kubelb.k8c.io/health-check-interval: 5s
spec:
  parentRefs:
    - name: api-gateway
  rules:
    - backendRefs:
        - name: payments
          port: 8080
```

## Interaction with mTLS Backend Transport

When [mTLS backend transport]({{< relref "../../mtls-backend-transport" >}}) is enabled, the built-in default check probes at a slower 60s interval. Every probe pays a full TLS handshake, and the handshake load scales with clusters times nodes, so the default is deliberately conservative. A health check you configure explicitly keeps its own interval: KubeLB assumes the value is intentional and does not slow it down.

## Monitoring

Track endpoint health with these Envoy metrics:

- `envoy_cluster_health_check_attempt`: Total health check attempts per cluster.
- `envoy_cluster_health_check_failure`: Failed health checks (immediate plus network failures).
- `envoy_cluster_health_check_healthy`: Number of healthy endpoints in the cluster.
- `envoy_cluster_membership_healthy`: Endpoints currently receiving traffic.

A rising `envoy_cluster_health_check_failure` with a falling `envoy_cluster_membership_healthy` means endpoints are being ejected. Check the backend health endpoint and confirm `timeout` is not shorter than the endpoint's real response time.

## Precedence Cheat Sheet

```text
Route.spec.healthCheck               (highest precedence)
LoadBalancer.spec.healthCheck
Tenant.spec.healthCheck
Config.spec.healthCheck
built-in default (connect-only TCP)  (fallback)
```

The whole block is taken from the first level that sets it. Levels are not merged.

## Further Reading

- [Envoy Health Checking](https://www.envoyproxy.io/docs/envoy/latest/intro/arch_overview/upstream/health_checking)
- [Envoy Health Check API](https://www.envoyproxy.io/docs/envoy/latest/api-v3/config/core/v3/health_check.proto)
- [gRPC Health Checking Protocol](https://github.com/grpc/grpc/blob/master/doc/health-checking.md)
