+++
title = "Overload Manager"
linkTitle = "Overload Manager"
date = 2025-01-16T10:00:00+02:00
weight = 2
+++

The Overload Manager protects Envoy proxy instances from resource exhaustion by taking protective actions when memory or connection limits are reached, preventing OOMKills and cascading failures.

## Why Overload Manager?

Envoy manages its own heap memory separate from container limits. Without overload protection:

- Envoy's heap can grow beyond container memory limits
- Kubernetes OOMKills the pod abruptly
- All connections are dropped immediately
- Traffic shifts suddenly to remaining pods, potentially triggering more OOMKills

The Overload Manager monitors resource usage and takes graceful protective actions before limits are reached.

## Configuration

Configure the Overload Manager in the `Config` CRD under `spec.envoyProxy.overloadManager`:

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: Config
metadata:
  name: default
  namespace: kubelb
spec:
  envoyProxy:
    overloadManager:
      enabled: true
      maxHeapSizeBytes: 1073741824  # 1GB
      maxActiveDownstreamConnections: 50000
```

### Configuration Fields

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `enabled` | bool | `false` | Must be explicitly enabled |
| `maxHeapSizeBytes` | uint64 | - | Memory threshold in bytes that triggers overload actions |
| `maxActiveDownstreamConnections` | uint64 | - | Maximum number of downstream (client) connections |

## Protective Actions

When thresholds are reached, Envoy takes these protective actions:

| Trigger | Action |
|---------|--------|
| Heap size approaches `maxHeapSizeBytes` | Returns HTTP 503 to new requests |
| Heap size approaches `maxHeapSizeBytes` | Sends GOAWAY frames to drain HTTP/2 connections |
| Connections reach `maxActiveDownstreamConnections` | Rejects new network connections |

## Best Practices

### Set Heap Below Container Limit

Always configure `maxHeapSizeBytes` below your container's memory limit to give Envoy room to drain gracefully:

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: Config
metadata:
  name: default
  namespace: kubelb
spec:
  envoyProxy:
    resources:
      limits:
        memory: 2Gi
    overloadManager:
      enabled: true
      # Set to ~80% of container limit
      maxHeapSizeBytes: 1717986918  # ~1.6GB
```

### Scale Connection Limits with Replicas

Connection limits should account for your expected traffic distributed across replicas:

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: Config
metadata:
  name: default
  namespace: kubelb
spec:
  envoyProxy:
    replicas: 3
    overloadManager:
      enabled: true
      # 50k per pod = 150k total across 3 replicas
      maxActiveDownstreamConnections: 50000
```

## Example: Memory-Constrained Environment

For environments with limited memory:

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: Config
metadata:
  name: default
  namespace: kubelb
spec:
  envoyProxy:
    resources:
      requests:
        memory: 256Mi
      limits:
        memory: 512Mi
    overloadManager:
      enabled: true
      maxHeapSizeBytes: 402653184  # 384MB (~75% of limit)
      maxActiveDownstreamConnections: 10000
```

## Example: High-Traffic Environment

For environments expecting heavy traffic:

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: Config
metadata:
  name: default
  namespace: kubelb
spec:
  envoyProxy:
    replicas: 5
    resources:
      requests:
        memory: 2Gi
      limits:
        memory: 4Gi
    overloadManager:
      enabled: true
      maxHeapSizeBytes: 3221225472  # 3GB
      maxActiveDownstreamConnections: 100000
```

## Further Reading

- [Envoy Overload Manager Documentation](https://www.envoyproxy.io/docs/envoy/latest/configuration/operations/overload_manager/overload_manager)
