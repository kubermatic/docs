+++
title = "Automated Network Policies"
linkTitle = "Network Policies"
date = 2026-04-23T10:00:00+02:00
weight = 3
enterprise = true
+++

## Overview

KubeLB Manager can generate a baseline set of `NetworkPolicy` resources in every tenant namespace to isolate tenants from each other while preserving the traffic the Envoy data plane and the Manager require. When the feature is enabled, the controller reconciles a curated list of default policies, honors a deny-list of policies you want to skip, and appends any custom policies you supply. Settings are defined on the `Config` CR and can be overridden per tenant.

## Prerequisites

A Kubernetes cluster running a CNI that enforces `NetworkPolicy` (for example Cilium, Calico, or Antrea). Policies created on a cluster without a policy-aware CNI will have no effect.

## Enable

Enable network policy automation globally on the `Config` CR:

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: Config
metadata:
  name: default
  namespace: kubelb
spec:
  networkPolicy:
    enable: true
```

Override on a specific tenant. Tenant settings take precedence over `Config`:

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: Tenant
metadata:
  name: tenant-a
spec:
  networkPolicy:
    enable: true
```

## Default Policies

The controller creates the following policies in each tenant namespace. Names are the exact string values accepted by `disabledPolicies`.

| Name | Purpose |
| --- | --- |
| `kubelb-deny-all-ingress` | Default deny all ingress traffic to tenant namespace. |
| `kubelb-allow-same-namespace` | Allow pod-to-pod traffic within the tenant namespace. |
| `kubelb-allow-manager-ingress` | Allow ingress from the KubeLB manager namespace. |
| `kubelb-allow-dns-egress` | Allow DNS resolution via `kube-system` on port 53 (UDP/TCP). |
| `kubelb-allow-xds-egress` | Allow xDS control-plane communication to the manager on port 8001/TCP. |
| `kubelb-allow-metrics-ingress` | Allow Prometheus metrics scraping on port 19001/TCP. |
| `kubelb-allow-envoy-ingress` | Allow all ingress to Envoy proxy pods so LoadBalancer traffic can reach them. |
| `kubelb-allow-envoy-egress` | Allow all egress from Envoy proxy pods so they can reach tenant NodePorts. |

Each generated policy carries the labels `app.kubernetes.io/managed-by=kubelb` and `kubelb.k8c.io/network-policy=true`, and a `kubelb.k8c.io/description` annotation.

## Disable Specific Defaults

List policy names in `disabledPolicies` to skip them. Remaining defaults still reconcile.

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: Config
metadata:
  name: default
  namespace: kubelb
spec:
  networkPolicy:
    enable: true
    disabledPolicies:
      - kubelb-deny-all-ingress
      - kubelb-allow-metrics-ingress
```

Drop `kubelb-deny-all-ingress` when an upstream policy engine already provides the default-deny posture and you do not want two ingress-deny policies stacking. Drop `kubelb-allow-metrics-ingress` when you do not scrape Envoy stats from Prometheus.

## Add Custom Policies

`additionalPolicies` is a list of named `NetworkPolicySpec` templates. The controller wraps each entry in a `NetworkPolicy` object, places it in the tenant namespace, and applies the standard KubeLB labels. A custom policy whose `name` collides with a default wins over the default.

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: Config
metadata:
  name: default
  namespace: kubelb
spec:
  networkPolicy:
    enable: true
    additionalPolicies:
      - name: allow-monitoring-egress
        spec:
          podSelector: {}
          policyTypes:
            - Egress
          egress:
            - to:
                - namespaceSelector:
                    matchLabels:
                      kubernetes.io/metadata.name: monitoring
              ports:
                - protocol: TCP
                  port: 4317
```

Each entry has only `name` and `spec`. Do not include `apiVersion`, `kind`, or `metadata`; the controller sets them.

## Verification

List the generated policies:

```bash
kubectl get networkpolicy -n tenant-<name>
kubectl get networkpolicy -n tenant-<name> -l kubelb.k8c.io/network-policy=true
```

Inspect an individual policy:

```bash
kubectl describe networkpolicy kubelb-allow-manager-ingress -n tenant-<name>
```

The description annotation (`kubelb.k8c.io/description`) summarises the purpose of each default policy.

## Troubleshooting

- **Traffic to an external service is blocked.** `kubelb-allow-dns-egress` only opens port 53 to `kube-system`. Any egress to external endpoints must be added via `additionalPolicies` with a matching `egress` rule (CIDR or namespace selector). The defaults do not include a blanket allow-all egress.
- **A new pod in the tenant namespace cannot reach the manager.** Confirm `kubelb-allow-manager-ingress` and `kubelb-allow-xds-egress` are not listed in `disabledPolicies`. Without `kubelb-allow-xds-egress`, Envoy cannot fetch its configuration from the manager's xDS endpoint on port 8001/TCP.

## Further Reading

- [Kubernetes NetworkPolicy documentation](https://kubernetes.io/docs/concepts/services-networking/network-policies/)
- [Cilium Network Policy reference](https://docs.cilium.io/en/stable/security/policy/)
- [Calico Network Policy reference](https://docs.tigera.io/calico/latest/network-policy/)
