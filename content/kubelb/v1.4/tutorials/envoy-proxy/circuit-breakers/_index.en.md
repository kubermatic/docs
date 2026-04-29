+++
title = "Circuit Breakers"
linkTitle = "Circuit Breakers"
date = 2025-01-16T10:00:00+02:00
weight = 3
enterprise = true
+++

Circuit breakers prevent cascading failures by short-circuiting requests when upstream services are overwhelmed. When connection or request thresholds are exceeded, Envoy immediately returns errors instead of queuing more requests.

## Why Circuit Breakers?

Envoy's default circuit breaker limits (1024 connections, 1024 pending requests) may be too low for high-traffic environments. Without proper tuning:

- Legitimate requests get rejected during traffic spikes
- Slow upstream services cause request queues to build up
- A single failing upstream can exhaust connection pools

Circuit breakers allow you to set appropriate limits based on your traffic patterns and upstream capacity.

## Configuration Levels

Circuit breakers can be configured at two levels:

1. **Global** (`Config` CRD): Applies to all tenants as the default
2. **Tenant** (`Tenant` CRD): Overrides global config for specific tenants

Tenant-level configuration takes precedence over global configuration.

## Configuration Fields

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `maxConnections` | int64 | `1024` | Maximum connections to all upstream endpoints |
| `maxPendingRequests` | int64 | `1024` | Maximum requests queued waiting for a connection |
| `maxParallelRequests` | int64 | `1024` | Maximum parallel requests (HTTP/2, gRPC multiplexing) |
| `maxParallelRetries` | int64 | `3` | Maximum parallel retry attempts |
| `maxRequestsPerConnection` | int64 | - | Maximum requests per connection before closing |
| `perEndpoint.maxConnections` | int64 | - | Maximum connections per individual endpoint |

## Global Configuration

Configure circuit breakers globally in the `Config` CRD under `spec.circuitBreaker`:

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: Config
metadata:
  name: default
  namespace: kubelb
spec:
  circuitBreaker:
    maxConnections: 10000
    maxPendingRequests: 5000
    maxParallelRequests: 10000
    maxParallelRetries: 10
    maxRequestsPerConnection: 1000
    perEndpoint:
      maxConnections: 500
```

## Tenant Configuration

Override global settings for specific tenants in the `Tenant` CRD:

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: Tenant
metadata:
  name: high-traffic-tenant
  namespace: kubelb
spec:
  circuitBreaker:
    maxConnections: 50000
    maxPendingRequests: 25000
    maxParallelRequests: 50000
    maxParallelRetries: 20
```

## Circuit Breaker Behavior

When thresholds are exceeded:

1. Envoy adds `x-envoy-overloaded` header to responses
2. New requests receive HTTP 503 (Service Unavailable)
3. Existing in-flight requests continue to completion
4. Circuit opens immediately—no gradual degradation

Monitor for `x-envoy-overloaded` headers to detect when circuit breakers are triggering.

## Example: High-Traffic Global Defaults

For platforms expecting heavy traffic across all tenants:

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: Config
metadata:
  name: default
  namespace: kubelb
spec:
  circuitBreaker:
    maxConnections: 100000
    maxPendingRequests: 50000
    maxParallelRequests: 100000
    maxParallelRetries: 50
    perEndpoint:
      maxConnections: 2000
```

## Example: Resource-Constrained Tenant

For tenants with limited upstream capacity:

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: Tenant
metadata:
  name: small-tenant
  namespace: kubelb
spec:
  circuitBreaker:
    maxConnections: 500
    maxPendingRequests: 250
    maxParallelRequests: 500
    maxParallelRetries: 3
    maxRequestsPerConnection: 100
```

## Example: gRPC/HTTP2 Optimization

For tenants using primarily gRPC or HTTP/2 with multiplexed connections:

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: Tenant
metadata:
  name: grpc-tenant
  namespace: kubelb
spec:
  circuitBreaker:
    maxConnections: 1000
    maxPendingRequests: 10000
    # Higher parallel requests due to multiplexing
    maxParallelRequests: 50000
    maxParallelRetries: 10
```

## Monitoring

Track circuit breaker metrics to tune your configuration:

- `envoy_cluster_upstream_cx_overflow`: Connections rejected due to `maxConnections`
- `envoy_cluster_upstream_rq_pending_overflow`: Requests rejected due to `maxPendingRequests`
- `envoy_cluster_upstream_rq_retry_overflow`: Retries rejected due to `maxParallelRetries`

## Further Reading

- [Envoy Circuit Breaking Documentation](https://www.envoyproxy.io/docs/envoy/latest/intro/arch_overview/upstream/circuit_breaking)
