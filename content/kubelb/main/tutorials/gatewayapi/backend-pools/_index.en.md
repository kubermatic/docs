+++
title = "Backend Pools"
linkTitle = "Backend Pools"
date = 2026-07-10T00:00:00+05:00
weight = 6
enterprise = true
+++

A backend pool lets one `HTTPRoute` send traffic to several KubeLB load balancers. It is useful when applications still run on VMs: one backend can go offline without taking the frontend with it.

| Backend 1 | Backend 2 | Result |
|---|---|---|
| Healthy | Healthy | A cookie keeps the session on one backend |
| Unhealthy | Healthy | The session moves to backend 2 |
| Healthy | Unhealthy | The session moves to backend 1 |
| Unhealthy | Unhealthy | Envoy returns `503`; an optional maintenance page can replace it |

{{% notice note %}}
Backend pools are available in KubeLB Enterprise Edition.
{{% /notice %}}

## Create a Pool

Add the same annotation to each existing `LoadBalancer`. The value is the pool ID:

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: LoadBalancer
metadata:
  name: example-app-01
  annotations:
    kubelb.k8c.io/backend-pool: example-app
spec:
  upstreamTLS:
    policy: Insecure
  # Keep the existing endpoints and ports.
---
apiVersion: kubelb.k8c.io/v1alpha1
kind: LoadBalancer
metadata:
  name: example-app-02
  annotations:
    kubelb.k8c.io/backend-pool: example-app
spec:
  upstreamTLS:
    policy: Insecure
  # Keep the existing endpoints and ports.
```

KubeLB creates `kubelb-pool-example-app` as a headless Service and keeps its EndpointSlices in sync. **Do not create or manage those resources yourself.**

Point the `HTTPRoute` at the generated pool Service:

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: example-app
spec:
  # parentRefs, hostnames, and matches omitted
  rules:
    - sessionPersistence:
        sessionName: SERVERID
        type: Cookie
        absoluteTimeout: 3600s
        cookieConfig:
          lifetimeType: Permanent
      backendRefs:
        - name: kubelb-pool-example-app
          port: 443
```

That is the complete KubeLB-specific configuration: one annotation on every member and one pool reference in the route.

## Add Health Checks

Attach an Envoy Gateway `BackendTrafficPolicy` to the route. Setting `panicThreshold: 0` is important: Envoy must not send traffic to unhealthy members when the pool has no healthy endpoint.

```yaml
apiVersion: gateway.envoyproxy.io/v1alpha1
kind: BackendTrafficPolicy
metadata:
  name: example-app
spec:
  targetRefs:
    - group: gateway.networking.k8s.io
      kind: HTTPRoute
      name: example-app
  loadBalancer:
    type: LeastRequest
  healthCheck:
    panicThreshold: 0
    active:
      type: HTTP
      http:
        path: /
        expectedStatuses:
          - 200
          - 421
      interval: 5s
      timeout: 2s
      unhealthyThreshold: 3
      healthyThreshold: 2
```

Cookie persistence and health checks work together: Envoy honors the cookie while its backend is healthy and selects another healthy member when it is not. To show custom HTML only when all members are unhealthy, add a `503` response override as described in [Backend Traffic Policy]({{< relref "../backend-traffic-policy" >}}).

## Use a Tenant Cluster

When the KubeLB CCM creates the load balancers, put the annotation on each tenant Service instead:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: backend-01
  annotations:
    kubelb.k8c.io/backend-pool: example-app
spec:
  type: LoadBalancer
  # selector and ports omitted
```

The CCM copies the annotation to the generated `LoadBalancer`. The tenant `HTTPRoute` still references `kubelb-pool-example-app`; no pool Service is needed in the tenant cluster.

## Before You Apply

- Pool members must be in the same management-cluster namespace.
- Every member must expose identical port names, numbers, and protocols.
- The pool ID must be a lowercase DNS label, at most 51 characters.
- `spec.upstreamTLS` remains a property of each `LoadBalancer`. KubeLB does not replace it or create a `BackendTLSPolicy` for the pool.
- Removing the annotation removes that member. KubeLB deletes the generated pool resources after the last member leaves.
