+++
title = "Ingress to Gateway API Migration"
linkTitle = "Ingress to Gateway API"
date = 2026-01-30T00:00:00+01:00
weight = 33
+++

This guide helps you migrate from Kubernetes Ingress to Gateway API. Whether you're managing a single cluster or operating at scale with KubeLB, through this guide you will be able to understand what's changing, why it's changing and what you need to do to migrate.

## Why Migrate?

### Ingress is Frozen

Kubernetes Ingress API has been stable since v1.19 (2020) and is now feature-frozen. With [Gateway API v1.0 graduating to GA in October 2023](https://kubernetes.io/blog/2023/10/31/gateway-api-ga/), the Kubernetes community has officially designated it as the successor to Ingress. Gateway API is designed to address Ingress limitations while remaining implementation-agnostic.

This means that new features are not being added to Ingress and all the development effort is going into Gateway API.

### Ingress NGINX Retirement

Ingress NGINX is the most popular and widely deployed Ingress controller. Everyone who has worked with Kubernetes at some point has used it or at least heard of it. It's a great controller and has been an essential part of the Kubernetes ecosystem.

However, the Kubernetes SIG Network and Security Response Committee [announced](https://groups.google.com/a/kubernetes.io/g/dev/c/rxtrKvT_Q8E) that [ingress-nginx](https://github.com/kubernetes/ingress-nginx) will enter retirement mode with best-effort maintenance until **March 2026**. After that date:

- No new releases
- No security patches
- No bug fixes

This applies specifically to the community ingress-nginx controller, not the Ingress API itself. However, as the most widely deployed Ingress controller, this timeline creates urgency for migration planning.

{{% notice note %}}
Other ingress controllers (Traefik, HAProxy, etc.) may continue support, but the ecosystem is converging on Gateway API.

This article is also quite important to read: [Ingress NGINX: Statement from the Kubernetes Steering and Security Response Committees](https://kubernetes.io/blog/2026/01/29/ingress-nginx-statement/)
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

Understanding the conceptual shift is essential before migrating resources.

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

The migration from Ingress to Gateway API is unfortunately not a one-shot, straight forward process. There are complications involved based on how complex your current setup with Ingress is and you might end up hitting some roadblocks. Thus, we believe that it shouldn't be taken as a one-time effort, you should evaluate your current setup and plan for the migration accordingly.

### Before You Start

Before starting migration, assess these critical areas:

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

Your existing TLS certs won't carry over to Gateway resources. You'll need cert-manager to issue new ones. If you want to avoid downtime during validation, use DNS01 challenges. One shortcut: if your Gateway is in the same namespace as your Ingress, they can share the same Secret.

#### Traffic During Migration

You can't gradually shift traffic percentages between Ingress and Gateway. There is no support for canary deployments between Ingress and Gateway. DNS is your switch—it's all or nothing per hostname. Test thoroughly before flipping.

## Migration Options

### Option 1: KubeLB [Experimental]

Realising the urgency of the situation, we have decided to build a migration tool that will help you migrate your Ingress resources to Gateway API. This tool will be available as a part of KubeLB and will be free to use. It will be open source and will be available on GitHub.

Due to the limitations discussed above, we *strongly advise* you to not use this tool in your production environments directly. Instead, you should use it first in testing/staging environments and make sure that everything works for you. Identify limitations, and resources that couldn't be successfully migrated using this tool and manually migrate them.

For more details please refer to the [KubeLB Ingress to Gateway API Converter](kubelb-automation) page.

KubeLB deals with the key assessment points discussed above including DNS Cutover Strategy, Overlapping Hostnames, Certificate Continuity etc. It offers a way to add a suffix to all your new Gateway resources to avoid conflicts with your existing Ingress resources. You can then verify the new Gateway resources are working as expected and then flip the DNS to the new Gateway IP.

Supported Ingress controllers:

- ingress-nginx

Supported Gateway API implementations:

- Envoy Gateway

We might expand this to cover other Ingress controllers and Gateway API implementations in the future. But for now, we are focusing only on these two.

Detailed documentation is available on the [KubeLB Ingress to Gateway API Converter](kubelb-automation) page.

### Option 2: Manual Migration

Official community tools like [ingress2gateway](https://github.com/kubernetes-sigs/ingress2gateway) can be used to migrate your Ingress resources to Gateway API. While KubeLB focuses strictly on Ingress conversion and only handles annotations for ingress-nginx, ingress2gateway can be used to migrate other Ingress controllers to Gateway API.

Supported providers:

- apisix
- cilium
- ingress-nginx
- istio
- gce
- kong
- nginx
- openapi

For more details please refer to the [ingress2gateway](https://github.com/kubernetes-sigs/ingress2gateway) repository.

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

When migrating to Gateway API, your supporting tools also need updates. We learnt some lessons ourselves since we built KubeLB that supports both Ingress and Gateway API. And we want to share them with you to help you avoid the same mistakes we made.

The following sections cover how to adapt cert-manager and external-dns configurations.

- [Cert Manager Migration](cert-manager)
- [External DNS Migration](external-dns)

## Ingress-nginx support in KubeLB

KubeLB is not dropping Ingress support and ingress-nginx will still be supported. However, we highly encourage our users to migrate to Gateway API as soon as possible.

We will patch/upgrade the ingress-nginx controller when updates are available for it. But eventually since upstream will stop supporting it, we will be left with no choice but to ship whatever version/release of ingress-nginx is available at the time.
