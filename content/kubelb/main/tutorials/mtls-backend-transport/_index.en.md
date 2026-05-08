+++
title = "mTLS Backend Transport"
linkTitle = "mTLS Backend Transport"
date = 2026-05-07T10:00:00+02:00
weight = 15
enterprise = true
+++

## Overview

KubeLB can encrypt backend traffic between the management cluster and tenant clusters with mutual TLS (mTLS). When enabled, KubeLB deploys a tenant-local Envoy proxy and routes management-to-tenant backend traffic through it.

Default `Direct` mode:

```text
Client -> KubeLB Envoy -> tenant node:NodePort -> backend pod
```

`MTLS` mode:

```text
Client -> KubeLB Envoy
       -- TLS 1.3 with mutual authentication -->
       -> kubelb-tenant-envoy -> backend Service -> backend pod
```

Application teams keep using the same Kubernetes resources: `LoadBalancer` Services, `Ingress`, and Gateway API routes. The backend transport change is handled by KubeLB.

Use this feature when the management and tenant clusters communicate across a network path where backend traffic should not be plaintext.

{{% notice warning %}}
UDPRoute uses an alpha CONNECT-UDP tunnel over the same mTLS tenant proxy port; see [UDP behavior](#udp-behavior).
{{% /notice %}}

## Enable mTLS backend transport

Enable the feature on the KubeLB manager chart:

```yaml
kubelb:
  backendTransport:
    mode: MTLS
```

Upgrade the KubeLB manager release:

```bash
helm upgrade kubelb oci://quay.io/kubermatic/helm-charts/kubelb-manager-ee \
  --namespace kubelb \
  --reuse-values \
  --set kubelb.backendTransport.mode=MTLS
```

The chart writes the setting to the management cluster `Config` resource:

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: Config
metadata:
  name: default
  namespace: kubelb
spec:
  backendTransport:
    mode: MTLS
```

Tenants do not need a separate setting. The tenant CCM discovers the effective mode from `TenantState` and reconciles the tenant proxy automatically.

{{% notice note %}}
Switching between `Direct` and `MTLS` changes the backend traffic path. Plan it like a network topology change and validate tenant traffic after rollout.
{{% /notice %}}

## Verify the rollout

Check the tenant state in the management cluster:

```bash
kubectl --context <management> -n <tenant-namespace> \
  get tenantstate -o jsonpath='{.items[*].status.conditions[?(@.type=="TenantProxyReady")].status}{"\n"}'
```

Expected result:

```text
True
```

Check the tenant proxy DaemonSet in the tenant cluster:

```bash
kubectl --context <tenant> -n kubelb \
  get daemonset kubelb-tenant-envoy
```

The DaemonSet should have ready pods on tenant nodes that can receive backend traffic.

## What KubeLB manages

KubeLB manages the certificate lifecycle for this transport:

- A KubeLB-owned root CA.
- A tenant-scoped intermediate CA.
- A management Envoy client certificate.
- A tenant proxy server certificate.

The management Envoy and tenant Envoy validate each other with tenant-specific identities and use TLS 1.3 for TCP connections. Certificate rotation is automatic and does not normally require a tenant proxy pod restart.

If a manually created certificate Secret conflicts with the KubeLB-managed one, KubeLB refuses to overwrite it and reports `BackendCertificateConflict` on the affected `Tenant`.

## Supported traffic

Traffic is encrypted between management Envoy and the tenant proxy for:

- `LoadBalancer` Services with TCP ports.
- `Ingress`.
- `HTTPRoute`.
- `GRPCRoute`.
- `TCPRoute`.
- `TLSRoute`.
- `UDPRoute`.

The tenant proxy forwards traffic to the backend Kubernetes Service inside the tenant cluster.

### UDP behavior

In `MTLS` mode, UDPRoute traffic is tunneled with CONNECT-UDP over the existing mTLS tenant proxy TCP port. The tenant proxy Service does not expose per-backend UDP NodePorts.

CONNECT-UDP and raw UDP-over-HTTP tunneling are alpha Envoy features. Validate workload-specific MTU, burst, stream-count, and idle-timeout behavior before using it for production UDP traffic.

## Network requirements

The management cluster must be able to reach tenant cluster nodes on Kubernetes NodePort ranges.

In `MTLS` mode, the tenant cluster exposes `kubelb-tenant-envoy` as a `NodePort` Service in the tenant `kubelb` namespace. Management Envoy connects to tenant node addresses and the assigned NodePort. TCP backends and UDPRoute tunnels share the same tenant proxy port.

Check the tenant proxy Service:

```bash
kubectl --context <tenant> -n kubelb \
  get service kubelb-tenant-envoy -o wide
```

## Operations

These changes do not normally restart tenant proxy pods:

- Adding or removing backend Services or Routes.
- Backend configuration updates.
- Certificate rotation.

These changes may roll tenant proxy pods:

- Enabling or disabling mTLS backend transport.
- KubeLB upgrades that change tenant proxy bootstrap configuration.
- Pod-template-level settings such as image, node selector, tolerations, or image pull secrets.

KubeLB does not use active TCP health checks from management Envoy to the tenant proxy for mTLS backend clusters. Instead, management Envoy uses passive outlier detection after real request failures. `TenantProxyReady` reports DaemonSet readiness, not application health.

## Metrics to watch

Manager metrics:

| Metric | What to watch |
| --- | --- |
| `kubelb_manager_mtls_certificate_rotation_failures_total` | Any non-zero rate during rotation needs investigation. |
| `kubelb_manager_mtls_tenants` | Number of tenants with mTLS PKI material. |

CCM metrics:

| Metric | What to watch |
| --- | --- |
| `kubelb_ccm_tenant_proxy_daemonset_ready` | `1` means the tenant proxy DaemonSet is ready; `0` means it is not ready. |
| `kubelb_ccm_tenant_proxy_server_cert_verification_failures_total` | The tenant CCM rejected synced server certificate material. |

## Troubleshooting

### Tenant proxy is not ready

Inspect `TenantState` on the management cluster:

```bash
kubectl --context <management> -n <tenant-namespace> \
  get tenantstate -o yaml
```

Look for the `TenantProxyReady` condition and reason.

Then inspect the tenant proxy DaemonSet:

```bash
kubectl --context <tenant> -n kubelb \
  describe daemonset kubelb-tenant-envoy
```

### Certificate verification is failing

Check:

```text
kubelb_ccm_tenant_proxy_server_cert_verification_failures_total
```

Common causes include clock skew, stale certificate material, wrong tenant DNS names, wrong extended key usage, or a foreign `SyncSecret`.

If the affected `Tenant` has `BackendCertificateConflict=True`, remove the conflicting `kubelb-tenant-proxy-server-tls` `SyncSecret` from the tenant namespace on the management cluster and let KubeLB recreate it.

### Traffic fails after the proxy is ready

Verify management-to-tenant NodePort reachability first. The management cluster must be able to reach the NodePorts assigned to `kubelb-tenant-envoy`.

You can inspect the backend clusters loaded by the tenant proxy:

```bash
kubectl --context <tenant> -n kubelb \
  exec ds/kubelb-tenant-envoy -c envoy -- \
  wget -qO- http://localhost:19000/clusters
```

## Disable mTLS backend transport

Switch back to `Direct`:

```bash
helm upgrade kubelb oci://quay.io/kubermatic/helm-charts/kubelb-manager-ee \
  --namespace kubelb \
  --reuse-values \
  --set kubelb.backendTransport.mode=Direct
```

The CCM cleans up tenant proxy resources after the effective mode changes. Plan for a brief traffic path change while traffic moves back to direct tenant NodePort routing.
