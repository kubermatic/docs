+++
title = "Backend TLS Re-encryption"
linkTitle = "Backend TLS"
date = 2026-04-23T10:00:00+02:00
weight = 4
enterprise = true
+++

## Overview

By default, KubeLB's Envoy proxy forwards traffic to backend endpoints over plain TCP. When a backend also serves TLS (for example, an `nginx` pod listening on `443` with its own certificate), the plaintext connection from Envoy to the backend fails the TLS handshake. Backend TLS re-encryption instructs Envoy to open a TLS connection on the upstream leg, so traffic stays encrypted end-to-end from client to backend pod.

This feature is scoped to Layer 4 `LoadBalancer` Services. Layer 7 resources (`Ingress`, `HTTPRoute`, `GRPCRoute`) do not use these annotations; for HTTPS backends behind an Ingress, see the TLS passthrough behavior triggered by `nginx.ingress.kubernetes.io/backend-protocol: HTTPS` covered in the [Ingress tutorial]({{< relref "../ingress" >}}).

## Annotations

Set annotations on the tenant-cluster `LoadBalancer` Service.

| Annotation | Values | Description |
| --- | --- | --- |
| `kubelb.k8c.io/backend-tls-policy` | `Insecure`, `Verify` | Enables upstream TLS. `Insecure` skips certificate verification. `Verify` verifies the backend certificate against the CA provided via `backend-tls-ca-secret`. |
| `kubelb.k8c.io/backend-tls-ca-secret` | Secret name | Name of the Secret in the tenant namespace on the **management** cluster that holds the CA bundle under the `ca.crt` key. Only consumed with `policy: Verify`. |

When neither annotation is set, Envoy connects to backends using plain TCP (existing behavior).

{{% notice warning %}}
`Insecure` enables TLS but does not validate the backend certificate (Envoy's `ACCEPT_UNTRUSTED` trust chain mode). Use it only for development, self-signed certificates without a CA on hand, or certificates without SANs. Use `Verify` in production.
{{% /notice %}}

## Insecure mode

Use `Insecure` when the backend serves TLS but you do not have (or do not want to validate) its CA.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-tls-backend
  namespace: default
  annotations:
    kubelb.k8c.io/backend-tls-policy: "Insecure"
spec:
  type: LoadBalancer
  selector:
    app: my-tls-backend
  ports:
    - port: 443
      targetPort: 443
```

## Verify mode

Use `Verify` to make Envoy validate the backend certificate against a CA bundle you provide.

### 1. Place the CA on the management cluster

The CA Secret must exist in the tenant namespace on the **management** cluster (the same namespace where the `LoadBalancer` CR is reconciled). Envoy reads the Secret directly from that namespace; it is not automatically copied from the tenant cluster.

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: my-backend-ca
  namespace: tenant-primary
type: Opaque
data:
  ca.crt: <base64-encoded CA certificate>
```

The Secret **must** contain a key named `ca.crt`. Other keys are ignored.

### 2. Annotate the tenant Service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-tls-backend
  namespace: default
  annotations:
    kubelb.k8c.io/backend-tls-policy: "Verify"
    kubelb.k8c.io/backend-tls-ca-secret: "my-backend-ca"
spec:
  type: LoadBalancer
  selector:
    app: my-tls-backend
  ports:
    - port: 443
      targetPort: 443
```

The KubeLB CCM strips both annotations from the Service before creating the `LoadBalancer` CR, and sets `spec.upstreamTLS` on the CR:

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: LoadBalancer
spec:
  upstreamTLS:
    policy: Verify
    caSecretRef:
      name: my-backend-ca
```

## How it works

Envoy attaches a TLS `TransportSocket` to the upstream cluster.

- **Insecure**: `UpstreamTlsContext` with `CertificateValidationContext.TrustChainVerification: ACCEPT_UNTRUSTED`. No CA is loaded.
- **Verify**: `UpstreamTlsContext` with `CertificateValidationContext.TrustedCa` set to the inline PEM bytes from `ca.crt`.

KubeLB does not set an SNI value on the upstream connection. Backends that require a specific SNI to serve the correct certificate may fail; prefer backends that serve a default certificate or accept any SNI. KubeLB also does not configure per-host SAN matching, so `Verify` only checks that the server certificate chains to the provided CA.

## Troubleshooting

- **`caSecretRef is required for Verify policy`** in the manager log — `backend-tls-policy: Verify` was set but `backend-tls-ca-secret` was not. Envoy falls back to plain TCP for the cluster.
- **`failed to get CA secret`** — the Secret named by the annotation does not exist in the tenant namespace on the management cluster. Create it there directly; the CCM does not copy arbitrary Secrets from the tenant cluster.
- **`secret <name> missing 'ca.crt' key`** — the Secret exists but does not contain a `ca.crt` entry. Rename the key or re-create the Secret with `kubectl create secret generic <name> --from-file=ca.crt=<path>`.
- **Handshake fails with `certificate verify failed`** — the backend certificate is not signed by the CA in the Secret, or the chain is incomplete. Include intermediates in `ca.crt`.
- **Connection resets / TLS alerts with a "plain" backend** — the backend does not speak TLS on the target port. Remove the annotations or switch the backend to TLS.
- **Changes to the CA Secret are not picked up** — the Envoy configuration is regenerated on `LoadBalancer` reconcile. Trigger a reconcile by updating the Service (for example, re-applying the annotation) if rotation does not propagate immediately.

## Further reading

- [Envoy upstream TLS (`UpstreamTlsContext`)](https://www.envoyproxy.io/docs/envoy/latest/api-v3/extensions/transport_sockets/tls/v3/tls.proto#extensions-transport-sockets-tls-v3-upstreamtlscontext)
- [Gateway API `BackendTLSPolicy`](https://gateway-api.sigs.k8s.io/api-types/backendtlspolicy/) — KubeLB does not consume `BackendTLSPolicy`, but readers looking for the upstream Gateway API spec may find it useful.
