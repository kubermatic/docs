+++
title = "Tenants"
linkTitle = "Tenants"
date = 2023-10-27T10:07:15+02:00
weight = 1
+++

Tenants are the consumers of the load balancer services in the management cluster: individual users, teams, or applications whose workloads, access control, and quotas are isolated per tenant. Each tenant is represented by the `Tenant` CRD and has a dedicated namespace `tenant-<tenant-name>` in the management cluster. Each Kubernetes cluster running the KubeLB CCM is a unique tenant; see [Architecture]({{< relref "../../architecture/" >}}) for details.

{{% notice note %}}
Tenant configuration has a higher precedence than the global configuration and overrides the global configuration values for the tenant if the fields are available in both the tenant and global configuration.
{{% /notice %}}

## Kubermatic Kubernetes Platform (Enterprise Edition Only)

For details, go through [KKP integration details]({{< relref "../../installation/kkp">}})

## Usage

For usage outside of KKP, follow this guide. It assumes that the KubeLB management cluster has been configured by following the [installation guide](../../installation/).

### KubeLB Tenant

Since KubeLB v1.1, register a new tenant by creating a `Tenant` CRD.

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: Tenant
metadata:
  name: shroud
spec:
  propagatedAnnotations: null
  # Propagate all annotations to the resources.
  propagateAllAnnotations: true
  # Exclude these annotation key patterns regardless of propagateAllAnnotations / propagatedAnnotations.
  # Patterns support shell-style globs.
  deniedAnnotations:
    - "internal.company.io/*"
  loadBalancer:
    class: "metallb.universe.tf/metallb"
    # Enterprise Edition Only
    limit: 10
  ingress:
    class: "nginx"
  gatewayAPI:
    class: "eg"
  # All of the below configurations are Enterprise Edition Only
  dns:
    allowedDomains:
      - "*.example.com"
  certificates:
    defaultClusterIssuer: "letsencrypt-prod"
    allowedDomains:
      - "*.example.com"
  allowedDomains:
    # All subdomains of example.com are allowed but at a single lower level. For example, kube.example.com, test.example.com, etc.
    - "*.example.com"
    # All subdomains of kube.com are allowed but at any lower level. For example, example.kube.com, test.tenant1.prod.kube.com etc.
    - "**.kube.com"
```

This creates a tenant named `shroud` with the following configuration:

* **propagateAllAnnotations: true** - Propagate all annotations to the resources.
* **deniedAnnotations** - Annotation key patterns to exclude from propagation. Deny rules always take precedence over `propagateAllAnnotations` and `propagatedAnnotations`. See [Annotation Settings]({{< relref "../../installation/configuration#annotation-settings" >}}) for details.
* **loadBalancer.class: metallb.universe.tf/metallb** - The class to use for LoadBalancer resources for tenants in the management cluster.
* **loadBalancer.limit: 10** - The limit of LoadBalancer resources that can be created by the tenant.
* **ingress.class: nginx** - The class to use for Ingress resources for tenants in the management cluster.
* **gatewayAPI.class: eg** - The class to use for Gateway API resources for tenants in the management cluster. To use more than one gateway class per tenant, see [Gateway Class Mappings]({{< relref "../gatewayapi#gateway-class-mappings-enterprise-edition-only" >}}) (Enterprise Edition only).
* For DNS, the allowed domain is `*.example.com`.
* For certificates, the default cluster issuer is `letsencrypt-prod` and the allowed domain is `*.example.com`.
* For Ingress and Gateway API, the allowed domains are `*.example.com` and `**.kube.com`.

{{% notice info %}}
The tenant name provided to the consumers is the name of the namespace that is created in the management cluster against the tenant CRD. So the tenant **shroud** will be represented by the namespace **tenant-shroud** in the management cluster. For the CCM, tenantName of **tenant-shroud** needs to be used.
{{% /notice %}}

{{% notice tip %}}
When a resource requests a hostname outside `allowedDomains`, the corresponding `Route` in the management cluster is rejected: its `Accepted` condition is set to `False` with reason `DomainNotAllowed`, and a Warning event is emitted. If a hostname does not come up, check the Route's conditions and events with `kubectl describe`.
{{% /notice %}}

### Load Balancer Policy

{{% notice note %}}
Enterprise Edition only. Available from KubeLB v1.4.
{{% /notice %}}

Set `spec.loadBalancerPolicy` on the Tenant to override the global [Load Balancer Policy]({{< relref "../../installation/configuration#configure-load-balancer-policy" >}}) for this tenant's Envoy clusters.

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: Tenant
metadata:
  name: shroud
spec:
  loadBalancerPolicy: Random
```

Valid values are `RoundRobin`, `LeastRequest`, and `Random`. For a per-service override, use the [`kubelb.k8c.io/lb-policy` annotation]({{< relref "../loadbalancer#per-service-load-balancer-policy" >}}).

See [CRD References]({{< relref "../../references">}}) for all options.

## Per-Tenant Envoy Proxy Sizing

The global `Config.spec.envoyProxy` block sets defaults for every tenant's data plane. A tenant can independently size its Envoy Proxy by setting `replicas` and `resources` under `spec.envoyProxy` on its `Tenant` CR.

{{% notice note %}}
Fields set under `Tenant.spec.envoyProxy` take precedence over the matching fields in `Config.spec.envoyProxy`. `replicas` is ignored when `Config.spec.envoyProxy.useDaemonset` is `true`.
{{% /notice %}}

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: Tenant
metadata:
  name: shroud
spec:
  envoyProxy:
    replicas: 3
    resources:
      requests:
        cpu: 200m
        memory: 256Mi
      limits:
        cpu: 500m
        memory: 512Mi
```

See [Configure Envoy Proxy]({{< relref "../../installation/configuration#configure-envoy-proxy" >}}) for the global defaults that these overrides replace.
