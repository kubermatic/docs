+++
title = "Cluster Modifiers"
date = 2026-03-17T10:07:15+02:00
weight = 10
+++

Cluster modifiers define the configuration axes for Kubernetes clusters created during conformance testing. Each modifier belongs to a **group**, and within each group only one modifier is active per cluster. This creates an exclusive selection axis for generating the cluster matrix.

## Modifier Groups

| Group              | Options                                        | Description |
|--------------------|------------------------------------------------|-------------|
| `cni`              | canal, cilium                                  | Container Network Interface plugin |
| `expose-strategy`  | NodePort, LoadBalancer, Tunneling              | How the cluster API is exposed |
| `proxy-mode`       | ipvs, iptables, ebpf                          | Kube-proxy mode |
| `audit`            | enabled, disabled                              | Kubernetes audit logging |
| `ssh`              | enabled, disabled                              | SSH key agent |
| `opa`              | enabled, disabled                              | Open Policy Agent integration |
| `mla-monitoring`   | enabled, disabled                              | MLA monitoring stack |
| `mla-logging`      | enabled, disabled                              | MLA logging stack |
| `node-local-dns`   | enabled, disabled                              | Node-local DNS cache |
| `k8s-dashboard`    | enabled, disabled                              | Kubernetes Dashboard |
| `pod-node-selector`| enabled, disabled                              | PodNodeSelector admission controller |
| `event-rate-limit` | enabled, disabled                              | EventRateLimit admission controller |
| `csi-driver`       | enabled, disabled                              | CSI driver integration |
| `update-window`    | configured, none                               | Maintenance window (excluded from dedup) |
| `oidc`             | disabled                                       | OIDC configuration (excluded from dedup) |
| `external-ccm`     | enabled, disabled                              | External Cloud Controller Manager |
| `ipvs-strict-arp`  | enabled, disabled                              | IPVS strict ARP mode |

## Deduplication

Cluster modifiers are deduplicated using SHA-256 hashing. Two modifier combinations that produce the same effective `ClusterSpec` will share the same cluster, avoiding redundant cluster creation.

Some groups are **excluded from the dedup hash** because they don't change the cluster's functional behavior:

- `update-window` — Maintenance windows don't affect cluster behavior
- `oidc` — OIDC is orthogonal to the provider/version matrix

## Modifier Type

```go
type CloudSpecModifier struct {
    Name   string
    Group  string
    Modify func(spec *kubermaticv1.CloudSpec)
}
```

Each modifier has:
- **Name**: Human-readable description (e.g., "with cni plugin set to canal")
- **Group**: Exclusive selection axis
- **Modify**: Function that mutates the cluster spec
