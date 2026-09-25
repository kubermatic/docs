+++
title = "Ingress to Gateway API Migration"
linkTitle = "Ingress to Gateway API"
date = 2026-01-30T00:00:00+01:00
description = "Why and how to migrate from Kubernetes Ingress to Gateway API, with tooling and assessment guidance."
weight = 25
+++

This guide covers migrating from Kubernetes Ingress to Gateway API: what is changing, why, and what you need to do.

## Why Migrate?

### Ingress is Frozen

The Kubernetes Ingress API has been stable since v1.19 (2020) and is feature-frozen. With [Gateway API v1.0 graduating to GA in October 2023](https://kubernetes.io/blog/2023/10/31/gateway-api-ga/), the Kubernetes community designated it as the successor to Ingress. New features are no longer added to Ingress; development effort goes into Gateway API, which addresses Ingress limitations while remaining implementation-agnostic.

### ingress-nginx Retirement

ingress-nginx is the most widely deployed Ingress controller. The Kubernetes SIG Network and Security Response Committee [announced](https://groups.google.com/a/kubernetes.io/g/dev/c/rxtrKvT_Q8E) that [ingress-nginx](https://github.com/kubernetes/ingress-nginx) will enter retirement mode with best-effort maintenance until **March 2026**. After that date:

- No new releases
- No security patches
- No bug fixes

This applies to the community ingress-nginx controller, not the Ingress API itself. Because ingress-nginx is so widely deployed, this timeline makes migration planning urgent.

{{% notice note %}}
Other ingress controllers (Traefik, HAProxy, etc.) may continue support, but the ecosystem is converging on Gateway API.

See also: [Ingress NGINX: Statement from the Kubernetes Steering and Security Response Committees](https://kubernetes.io/blog/2026/01/29/ingress-nginx-statement/)
{{% /notice %}}

### Gateway API Advantages

| Feature | Ingress | Gateway API |
|---------|---------|-------------|
| **Role separation** | Single resource | GatewayClass → Gateway → Routes (platform provider, operator, developer) |
| **Protocol support** | HTTP/HTTPS only | HTTP, HTTPS, gRPC, TCP, UDP, TLS |
| **Header manipulation** | Annotation-dependent | Native support |
| **Traffic splitting** | Limited | Built-in weighted routing |
| **Cross-namespace routing** | Complex | First-class ReferenceGrant support |
| **Portability** | Vendor annotations | Standardized API |

## Core Concepts Mapping

### Resource Hierarchy

```text
Ingress World                    Gateway API World
─────────────                    ─────────────────
IngressClass          →          GatewayClass
     ↓                                ↓
  Ingress             →            Gateway
(rules + backend)                     ↓
                                 HTTPRoute / GRPCRoute / TCPRoute / etc.
                                      ↓
                                   Service
```

## Migration Strategy

Migrating from Ingress to Gateway API is not a one-shot process. The effort depends on how complex your current Ingress setup is, and you may hit roadblocks. Evaluate your setup and plan the migration accordingly.

### Before You Start

Assess these areas:

#### Load Balancer IP Changes

Your Ingress controller runs its own LoadBalancer Service. Gateway API creates a separate LoadBalancer Service with a different IP. Plan for DNS cutover accordingly.

```text
Ingress Controller LB (10.0.0.1)  →  Gateway LB (10.0.0.2)
         ↑                                    ↑
    Current DNS                          New DNS target
```

#### DNS Cutover Strategy

**Option A - Blue-Green:**

- Deploy Gateway alongside existing Ingress
- Test thoroughly with direct IP access
- Switch DNS to Gateway IP
- Keep Ingress running for rollback

**Option B - Gradual Migration:**

- Lower DNS TTL (e.g., 60s) before migration
- Switch one hostname at a time
- Monitor traffic and errors
- Increase TTL after stabilization

external-dns can manage records for both Ingress and Gateway simultaneously during migration.

#### Overlapping Hostnames

When the same hostname exists on both Ingress and Gateway:

- external-dns deduplicates based on hostname
- Only one DNS record target exists at a time
- Traffic goes to whichever IP the DNS record points to
- After migration: remove Ingress source from external-dns to prevent record conflicts

#### Certificate Continuity

Existing TLS certificates do not carry over to Gateway resources; cert-manager must issue new ones. To avoid downtime during validation, use DNS01 challenges. If your Gateway is in the same namespace as your Ingress, both can share the same Secret.

#### Traffic During Migration

You cannot gradually shift traffic percentages between Ingress and Gateway, and there is no canary support between them. DNS is the switch, and it is all or nothing per hostname. Test thoroughly before flipping.

## Migration Options

### Option 1: KubeLB (Beta)

KubeLB includes a migration tool that converts Ingress resources to Gateway API. It is free to use and open source.

Do not use this tool directly in production. Run it first in testing/staging environments, verify the results, identify resources that could not be migrated, and migrate those manually.

The tool covers the assessment points above, including DNS cutover strategy, overlapping hostnames, and certificate continuity. It can add a suffix to all new Gateway resources to avoid conflicts with existing Ingress resources. Verify the new Gateway resources work as expected, then flip DNS to the new Gateway IP.

Supported Ingress controllers:

- ingress-nginx

Supported Gateway API implementations:

- Envoy Gateway

See the [KubeLB Ingress to Gateway API Converter](kubelb-automation) page for detailed documentation.

For an interactive workflow, the KubeLB CLI and its local web dashboard can list, preview, and convert Ingresses step by step; see the [CLI & Dashboard guide]({{< relref "../cli/ingress-to-gateway-api" >}}).

### Option 2: Manual Migration

The community tool [ingress2gateway](https://github.com/kubernetes-sigs/ingress2gateway) migrates Ingress resources to Gateway API. While KubeLB handles annotations for ingress-nginx only, ingress2gateway supports additional Ingress controllers.

Supported providers:

- apisix
- cilium
- ingress-nginx
- istio
- gce
- kong
- nginx
- openapi

See the [ingress2gateway](https://github.com/kubernetes-sigs/ingress2gateway) repository.

## Ingress to HTTPRoute Conversion

### Basic Example

**Ingress:**

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: example
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
    - host: example.com
      http:
        paths:
          - path: /api
            pathType: Prefix
            backend:
              service:
                name: api-service
                port:
                  number: 80
  tls:
    - hosts:
        - example.com
      secretName: example-tls
```

**Equivalent Gateway API:**

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: example
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
  name: api-route
spec:
  parentRefs:
    - name: example
  hostnames:
    - example.com
  rules:
    - matches:
        - path:
            type: PathPrefix
            value: /api
      filters:
        - type: URLRewrite
          urlRewrite:
            path:
              type: ReplacePrefixMatch
              replacePrefixMatch: /
      backendRefs:
        - name: api-service
          port: 80
```

## Tooling Migration

Supporting tools also need updates when migrating to Gateway API. The following pages cover how to adapt cert-manager and external-dns configurations:

- [cert-manager Migration](cert-manager)
- [external-dns Migration](external-dns)

## ingress-nginx Support in KubeLB

KubeLB is not dropping Ingress support, and ingress-nginx remains supported. We encourage users to migrate to Gateway API as soon as possible.

KubeLB will patch and upgrade the ingress-nginx controller while updates are available upstream. Once upstream support ends, KubeLB will ship the last available ingress-nginx release.

## Table of Contents

{{% children depth=1 %}}
{{% /children %}}
