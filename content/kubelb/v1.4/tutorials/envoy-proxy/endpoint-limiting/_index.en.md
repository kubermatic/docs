+++
title = "Endpoint Limiting"
linkTitle = "Endpoint Limiting"
date = 2025-01-16T10:00:00+02:00
weight = 4
enterprise = true
+++

Endpoint limiting reduces health-check fan-out by capping the number of upstream endpoints Envoy tracks per cluster. In large clusters, the combination of nodes, Envoy replicas, and LoadBalancers creates excessive health-check traffic — for example, 30 nodes with 3 Envoy replicas and 10 LoadBalancers produces 900 TCP health checks every 5 seconds.

## Approaches

Endpoint limiting can be applied at two levels:

1. **Manager-side**: Caps endpoints in the xDS snapshot via the `Config` CR
2. **CCM-side**: Filters and limits node addresses before they are forwarded to the management cluster

Both approaches compose: if a label selector is configured, nodes are filtered first, then sorted by IP, and finally the count limit is applied.

## Manager-Side: Config CR

Set `maxEndpointsPerCluster` in the `Config` CR under `spec.envoyProxy` to cap the number of endpoints included in the xDS snapshot for each cluster:

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: Config
metadata:
  name: default
  namespace: kubelb
spec:
  envoyProxy:
    replicas: 3
    topology: shared
    maxEndpointsPerCluster: 10
```

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `maxEndpointsPerCluster` | int32 | `0` (no limit) | Maximum endpoints per cluster in xDS snapshot |

This is a global-only setting configured on the `Config` CR. It is not available at the tenant level.

## CCM-Side: Node Address Filtering

The KubeLB CCM supports filtering and limiting which node addresses are forwarded to the management cluster. Configure these via Helm values or CLI flags:

| Flag | Helm Value | Type | Default | Description |
|------|-----------|------|---------|-------------|
| `--max-node-address-count` | `kubelb.maxNodeAddressCount` | int | `0` (no limit) | Maximum node addresses to forward |
| `--node-address-label-selector` | `kubelb.nodeAddressLabelSelector` | string | `""` (all nodes) | Label selector to filter nodes |

### Helm Configuration

```yaml
kubelb:
  maxNodeAddressCount: 10
  nodeAddressLabelSelector: "node-role.kubernetes.io/worker="
```

### Topology-Aware Round Robin

When `--max-node-address-count` is set, the CCM distributes the selected endpoints evenly across failure domains (zones) using round-robin. This ensures that the limited set of endpoints maintains zone diversity for resilience.

## Example: Combined Filtering

Filter to worker nodes and limit to 10 addresses on the CCM side, then further cap to 5 endpoints in the xDS snapshot on the manager side:

**CCM values.yaml:**

```yaml
kubelb:
  maxNodeAddressCount: 10
  nodeAddressLabelSelector: "node-role.kubernetes.io/worker="
```

**Config CR:**

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: Config
metadata:
  name: default
  namespace: kubelb
spec:
  envoyProxy:
    maxEndpointsPerCluster: 5
```
