+++
title = "Cert Manager Migration"
linkTitle = "Cert Manager"
date = 2026-01-30T00:00:00+01:00
weight = 3
+++

Cert Manager is the de-facto tool for managing certificates in Kubernetes. It's a great tool and has been an essential part of the Kubernetes ecosystem.

When migrating from Ingress to Gateway API, cert-manager requires configuration changes and your existing ClusterIssuers may need updates.

## Installation

The key difference is enabling Gateway API support in cert-manager's controller configuration.

{{< tabs name="cert-manager-install" >}}
{{% tab name="Ingress" %}}

Standard cert-manager installation for Ingress:

```yaml
# values.yaml
crds:
  enabled: true
```

{{% /tab %}}
{{% tab name="Gateway API" %}}

Enable Gateway API support:

```yaml
# values.yaml
crds:
  enabled: true
config:
  apiVersion: controller.config.cert-manager.io/v1alpha1
  kind: ControllerConfiguration
  enableGatewayAPI: true
```

{{% /tab %}}
{{< /tabs >}}

## ClusterIssuer Migration

HTTP01 challenge solvers need updates to reference Gateway resources instead of Ingress.

### HTTP01 Challenge

{{< tabs name="http01-issuer" >}}
{{% tab name="Ingress" %}}

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-production
spec:
  acme:
    email: user@example.com
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: letsencrypt-account-key
    solvers:
      - http01:
          ingress:
            ingressClassName: nginx
```

{{% /tab %}}
{{% tab name="Gateway API" %}}

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-production
spec:
  acme:
    email: user@example.com
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: letsencrypt-account-key
    solvers:
      - http01:
          gatewayHTTPRoute:
            parentRefs:
              - kind: Gateway
                name: default
                namespace: default
                sectionName: http
```

{{% /tab %}}
{{< /tabs >}}

### DNS01 Challenge

DNS01 challenge configuration remains unchanged between Ingress and Gateway API:

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-production-dns
spec:
  acme:
    email: user@example.com
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: letsencrypt-dns-account-key
    solvers:
      - dns01:
          route53:
            region: eu-central-1
            accessKeyIDSecretRef:
              name: route53-credentials
              key: access-key-id
            secretAccessKeySecretRef:
              name: route53-credentials
              key: secret-access-key
```

## Annotation Handling

Cert-manager annotations work similarly on both Ingress and Gateway resources. The only difference is that the annotations are applied to the Gateway resource instead of the Ingress resource.

| Ingress Annotation | Gateway Annotation | Notes |
|--------------------|-------------------|-------|
| `cert-manager.io/cluster-issuer` | `cert-manager.io/cluster-issuer` | Same annotation, apply to Gateway |
| `cert-manager.io/issuer` | `cert-manager.io/issuer` | Same annotation, apply to Gateway |
| `cert-manager.io/common-name` | `cert-manager.io/common-name` | Same annotation |
| `cert-manager.io/duration` | `cert-manager.io/duration` | Same annotation |

### Example Migration

{{< tabs name="annotation-example" >}}
{{% tab name="Ingress" %}}

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: example
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-production
spec:
  ingressClassName: nginx
  tls:
    - hosts:
        - example.com
      secretName: example-tls
  rules:
    - host: example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: backend
                port:
                  number: 80
```

{{% /tab %}}
{{% tab name="Gateway API" %}}

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: example
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-production
spec:
  gatewayClassName: kubelb
  listeners:
    - name: https
      protocol: HTTPS
      port: 443
      hostname: example.com
      tls:
        mode: Terminate
        certificateRefs:
          - name: example-tls
---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: example
spec:
  parentRefs:
    - name: example
  hostnames:
    - example.com
  rules:
    - backendRefs:
        - name: backend
          port: 80
```

{{% /tab %}}
{{< /tabs >}}

## Limitations

{{% notice warning %}}
Be aware of these limitations when migrating cert-manager to Gateway API.
{{% /notice %}}

### Wildcard Certificates with HTTP01

Gateway API does **not** support wildcard certificates with HTTP01 challenge. You must use DNS01 challenge for wildcards:

```yaml
# This will NOT work with Gateway API + HTTP01
listeners:
  - hostname: "*.example.com"  # Wildcard requires DNS01
```

### Gateway Reference Required

HTTP01 solver requires explicit Gateway reference with `parentRefs`. Unlike Ingress where you just specify `ingressClassName`, Gateway API needs:

- Gateway name
- Gateway namespace
- Listener section name (must have an HTTP listener for challenges)

### Certificate Ownership

With Ingress, cert-manager creates and manages the Certificate resource automatically. With Gateway API, the same applies but the Certificate is associated with the Gateway, not individual routes.

### Multiple Gateways

If you have multiple Gateways, you need separate ClusterIssuers or use DNS01 challenge which doesn't require Gateway references.

## Migration Checklist

1. Update HTTP01 ClusterIssuers to use `gatewayHTTPRoute` instead of `ingress`
2. Ensure Gateway has an HTTP listener (port 80) for ACME challenges
3. Move cert-manager annotations from Ingress to Gateway resources
4. Verify certificates are issued before switching DNS

## Further Reading

- [cert-manager Gateway API documentation](https://cert-manager.io/docs/usage/gateway/)
- [ACME HTTP01 with Gateway API](https://cert-manager.io/docs/configuration/acme/http01/#configuring-the-http-01-gateway-api-solver)
