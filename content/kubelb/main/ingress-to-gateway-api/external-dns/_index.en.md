+++
title = "External DNS Migration"
linkTitle = "External DNS"
date = 2026-01-30T00:00:00+01:00
weight = 3
+++

External DNS automates DNS record management by watching Kubernetes resources and creating corresponding DNS entries. It's widely used alongside Ingress controllers.

When migrating from Ingress to Gateway API, external-dns requires source configuration changes to watch Gateway API resources.

## Installation

The key difference is adding Gateway API sources alongside or instead of Ingress sources.

{{< tabs name="external-dns-install" >}}
{{% tab name="Ingress" %}}

Standard external-dns configuration for Ingress:

```yaml
# values.yaml
sources:
  - service
  - ingress
provider: aws
policy: sync
registry: txt
txtOwnerId: my-cluster
domainFilters:
  - example.com
```

{{% /tab %}}
{{% tab name="Gateway API" %}}

Add Gateway API sources:

```yaml
# values.yaml
sources:
  - service
  - gateway-httproute
  - gateway-grpcroute
  - gateway-tlsroute
  - gateway-tcproute
  - gateway-udproute
provider: aws
policy: sync
registry: txt
txtOwnerId: my-cluster
domainFilters:
  - example.com
```

{{% /tab %}}
{{% tab name="Both (Migration)" %}}

During migration, you can watch both Ingress and Gateway API resources:

```yaml
# values.yaml
sources:
  - service
  - ingress
  - gateway-httproute
  - gateway-grpcroute
  - gateway-tlsroute
  - gateway-tcproute
  - gateway-udproute
provider: aws
policy: sync
registry: txt
txtOwnerId: my-cluster
domainFilters:
  - example.com
```

{{% /tab %}}
{{< /tabs >}}

{{% notice note %}}
Running external-dns with both Ingress and Gateway API sources during migration allows gradual traffic cutover without DNS gaps.
{{% /notice %}}

## Source Types

Gateway API introduces multiple route types, each requiring its own source:

| Source | Resource | Use Case |
|--------|----------|----------|
| `gateway-httproute` | HTTPRoute | HTTP/HTTPS traffic |
| `gateway-grpcroute` | GRPCRoute | gRPC traffic |
| `gateway-tlsroute` | TLSRoute | TLS passthrough |
| `gateway-tcproute` | TCPRoute | Raw TCP traffic |
| `gateway-udproute` | UDPRoute | UDP traffic |

Add only the sources you need based on your route types.

## Annotation Handling

External-dns annotations work similarly on both Ingress and Gateway API resources.

| Ingress Annotation | Gateway/Route Annotation | Notes |
|--------------------|--------------------------|-------|
| `external-dns.alpha.kubernetes.io/hostname` | `external-dns.alpha.kubernetes.io/hostname` | Same annotation |
| `external-dns.alpha.kubernetes.io/ttl` | `external-dns.alpha.kubernetes.io/ttl` | Same annotation |
| `external-dns.alpha.kubernetes.io/target` | `external-dns.alpha.kubernetes.io/target` | Same annotation |
| `external-dns.alpha.kubernetes.io/alias` | `external-dns.alpha.kubernetes.io/alias` | Same annotation |

### Example Migration

{{< tabs name="annotation-example" >}}
{{% tab name="Ingress" %}}

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: example
  annotations:
    external-dns.alpha.kubernetes.io/hostname: app.example.com
    external-dns.alpha.kubernetes.io/ttl: "300"
spec:
  ingressClassName: nginx
  rules:
    - host: app.example.com
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
kind: HTTPRoute
metadata:
  name: example
  annotations:
    external-dns.alpha.kubernetes.io/hostname: app.example.com
    external-dns.alpha.kubernetes.io/ttl: "300"
spec:
  parentRefs:
    - name: default
  hostnames:
    - app.example.com
  rules:
    - backendRefs:
        - name: backend
          port: 80
```

{{% /tab %}}
{{< /tabs >}}

### Hostname Source

With Gateway API, external-dns can also derive hostnames from the route's `hostnames` field without requiring annotations:

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: example
  # No annotation needed - hostname derived from spec
spec:
  parentRefs:
    - name: default
  hostnames:
    - app.example.com  # external-dns creates DNS record for this
  rules:
    - backendRefs:
        - name: backend
          port: 80
```

## Limitations

{{% notice warning %}}
Be aware of these limitations when migrating external-dns to Gateway API.
{{% /notice %}}

We didn't find any significant limitations during our migrations and testing. Everything worked as expected and seamlessly. Although, some things to be aware of:

### IP Address Resolution

External-dns needs the Gateway's IP address to create DNS records. Ensure your Gateway has a LoadBalancer service with an assigned external IP before routes can get DNS records.

### Multiple Routes Same Hostname

If multiple HTTPRoutes specify the same hostname, external-dns creates a single DNS record pointing to the Gateway IP. This is expected behavior since all routes share the same Gateway ingress point.

### TXT Record Ownership

External-dns uses TXT records for ownership tracking. When migrating, the `txtOwnerId` should remain the same to avoid orphaned records. If you change the owner ID, old records won't be cleaned up automatically.

### Gateway vs Route Annotations

Annotations can be placed on either the Gateway or the Route:

- **Gateway annotations**: Apply to all routes attached to that Gateway
- **Route annotations**: Apply only to that specific route

During migration, be consistent about where you place annotations.

## Migration Checklist

1. Add Gateway API sources to external-dns configuration
2. Keep Ingress source during migration period
3. Verify Gateway has external IP assigned
4. Move annotations from Ingress to HTTPRoute/Gateway
5. Verify DNS records are created for Gateway API resources
6. Remove Ingress source after full migration

## Further Reading

- [external-dns Gateway API tutorial](https://kubernetes-sigs.github.io/external-dns/latest/tutorials/gateway-api/)
- [external-dns annotations reference](https://kubernetes-sigs.github.io/external-dns/latest/docs/annotations/annotations/)
