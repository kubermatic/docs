+++
title = "Tenant Isolation"
linkTitle = "Tenant Isolation"
date = 2026-08-10T00:00:00+02:00
description = "How KubeLB keeps tenant clusters apart from each other, and from the management cluster they share."
weight = 15
+++

KubeLB is hub-and-spoke: many tenant clusters, one management cluster holding the Envoy data plane. That shared hub is the thing worth protecting. A tenant should not be able to read another tenant's configuration, claim a hostname that isn't theirs, or reach anything on the management cluster beyond their own corner of it.

This page describes what enforces that.

## Each tenant gets a namespace, and a credential that only works there

When you create a `Tenant`, the manager creates a namespace for it on the management cluster, named `tenant-<name>`. Everything that tenant generates lives there: its `LoadBalancer` and `Route` objects, its Envoy deployment, its addresses.

The manager also creates a ServiceAccount in that namespace, binds it to a **namespaced Role**, and writes the resulting kubeconfig to a secret. That kubeconfig is what the tenant's CCM uses to reach the management cluster. It carries no cluster-scoped permission of any kind, so a tenant cannot list namespaces, cannot read another tenant's objects, and cannot see cluster-scoped resources such as `Tenant` or `Config`.

If you are installing the CCM yourself, that secret is the one to copy:

```bash
kubectl --context <management-cluster> \
  -n tenant-<name> get secret kubelb-ccm-kubeconfig \
  -o jsonpath='{.data.kubelb}' | base64 -d
```

Handing the CCM a cluster-admin kubeconfig instead will work, and will quietly discard every boundary described here. Don't.

## The tenant credential can only touch KubeLB custom resources

The Role grants verbs on `kubelb.k8c.io` custom resources and nothing else. No secrets, no configmaps, no pods, no services, no deployments. A tenant's credential has no route to native Kubernetes objects on the management cluster, in its own namespace or anywhere else.

| | Granted in `tenant-<name>` |
|---|---|
| `loadbalancers`, `routes`, `addresses`, `syncsecrets` (+ `tunnels` in EE) | create, get, list, watch, update, patch, delete |
| the `/status` subresource of each | get, update, patch |
| `tenantstates` | get, list, watch, patch |
| `tenantstates/status` | get, update, patch |
| everything in the core API group | nothing |

This is deliberate, and it constrains how KubeLB itself is built: when the CCM needs to move secret material to the management cluster, it cannot write a `Secret`. It creates a `SyncSecret` custom resource, and the manager, which does hold the necessary permissions, materializes it. The tenant boundary holds even for KubeLB's own internals.

## Tenants can only claim hostnames you allow them

Namespace separation stops a tenant reading another tenant's objects. It does nothing to stop a tenant *claiming another tenant's hostname*, since both are just strings in a spec.

`allowedDomains` closes that. Set it on the `Tenant`, and any Ingress, HTTPRoute or Gateway whose hostname falls outside the list is rejected: no Envoy configuration is generated, and the rejection is reported back to the tenant as an event on the source object.

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: Tenant
metadata:
  name: team-a
spec:
  allowedDomains:
    - "*.team-a.example.com"
```

Two related controls sit alongside it. Conflicting Gateway origins are rejected, so two tenants cannot both claim the same Gateway and the loser finds out rather than being silently dropped. And in Enterprise Edition, `enforceReferenceGrants` requires cross-namespace backend references to carry an explicit `ReferenceGrant` in the target namespace, the way the Gateway API intends. Without it, a route in one namespace can quietly point at a service in another.

## Network policies for the shared data plane (EE)

Everything above is API-level. Network policies address the layer underneath: tenant Envoy pods share a cluster, and by default a pod in one tenant namespace can open a connection to a pod in another.

Enterprise Edition can generate a policy set per tenant namespace:

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: Tenant
metadata:
  name: team-a
spec:
  networkPolicy:
    enable: true
```

The defaults deny ingress, then re-open exactly what the data plane needs:

| Policy | What it allows |
|---|---|
| `kubelb-deny-all-ingress` | nothing, the baseline |
| `kubelb-allow-same-namespace` | pod-to-pod within the tenant namespace |
| `kubelb-allow-manager-ingress` | traffic from the KubeLB manager namespace |
| `kubelb-allow-dns-egress` | DNS via kube-system, port 53 |
| `kubelb-allow-xds-egress` | xDS to the manager, port 8001 |
| `kubelb-allow-metrics-ingress` | Prometheus scraping, port 19001 |
| `kubelb-allow-envoy-ingress` | inbound LoadBalancer traffic to Envoy pods |
| `kubelb-allow-envoy-egress` | Envoy reaching tenant NodePorts |

Drop any default with `disabledPolicies`, and add your own through `additionalPolicies`. Set the same block on `Config` to apply it fleet-wide; the `Tenant` value wins where both are set.

This is off by default today and will become the default in a future release. Enabling it on an existing installation is worth doing in a maintenance window, since a missing egress rule surfaces as a tenant's traffic quietly failing.

## Capping what a tenant can consume

Isolation is also about one tenant not exhausting the hub. Enterprise Edition lets you cap and disable per tenant:

- `spec.loadBalancer.limit` and `spec.gatewayAPI.gateway.limit` bound how many objects a tenant can create. Lowering a limit below what already exists blocks new objects rather than deleting existing ones, since KubeLB cannot know which of a tenant's load balancers are safe to remove.
- `spec.ingress.disable`, `spec.gatewayAPI.disable` and the per-route-kind flags turn off whole resource types
- `spec.envoyProxy.replicas` and `spec.envoyProxy.resources` size a tenant's Envoy explicitly, rather than letting it inherit whatever the fleet default is

## Encrypting the hop to the backend (EE)

By default, traffic from the management cluster's Envoy to a tenant's NodePort crosses the network in the clear. If those clusters share an untrusted network, mTLS backend transport terminates the hop at a proxy inside the tenant cluster, with certificates issued and rotated per tenant.

The proxies then connect to the tenant proxy rather than directly to node ports. See [Management Cluster installation]({{< relref "../../installation/management-cluster/" >}}) for the connectivity this changes.

## What this does not protect against

Three limits are worth stating plainly.

The management cluster is a trust boundary you own. Anyone with cluster-admin there can read every tenant's configuration and certificates, so its RBAC deserves the care you'd give any shared control plane.

Tenants still share Envoy infrastructure. A tenant that sends enough traffic affects its neighbours no matter how the namespaces are carved up, which is what limits, circuit breakers and per-tenant resource sizing exist to bound.

And a tenant admin remains trusted inside their own cluster. KubeLB constrains what a tenant projects onto the shared hub, not what they do at home.
