+++
title = "KubeLB Management Cluster Configuration"
linkTitle = "Management Configuration"
date = 2023-10-27T10:07:15+02:00
description = "Configure KubeLB Manager in the management cluster through the Config CRD."
weight = 40
aliases = ["/kubelb/main/tutorials/config/"]
+++

The `Config` CRD manages KubeLB Manager configuration in the management cluster. Example:

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: Config
metadata:
  name: default
  namespace: kubelb
spec:
  envoyProxy:
    replicas: 3
    topology: shared
```

To skip creation of the **Config** object via helm, apply the following modification to the **values.yaml** file for the helm chart:

```yaml
kubelb:
  skipConfigGeneration: true
```

This decouples the `Config` from the helm chart so it can be managed separately. This is recommended; otherwise the helm chart must be upgraded to update the `Config` CRD.

{{% notice note %}}
As of KubeLB v1.4, the manager starts without a `Config` CR and serves sensible defaults (shared Envoy topology, 3 replicas). Creating a `Config` named `default` is still recommended for most setups: features that depend on specific fields (for example, Ingress/Gateway API class, DNS automation, propagated annotations) remain disabled until the corresponding keys are set.
{{% /notice %}}

## Configuration Options

{{% notice note %}}
Tenant configuration has a higher precedence than the global configuration and overrides the global configuration values for the tenant if the fields are available in both the tenant and global configuration.
{{% /notice %}}

### Essential configurations

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: Config
metadata:
  name: default
  namespace: kubelb
spec:
  ingress:
    class: "nginx"
  gatewayAPI:
    class: "eg"
  # Enterprise Edition only
  certificates:
    defaultClusterIssuer: "letsencrypt-prod"
```

These options are available at both global and tenant level; tenant values override global values. Configure them at one of those levels, since core KubeLB functions depend on them.

1. **Ingress.Class**: The class to use for Ingress resources for tenants in management cluster.
2. **GatewayAPI.Class**: The class to use for Gateway API resources for tenants in management cluster.
3. **Certificates.DefaultClusterIssuer(EE)**: The default cluster issuer to use for certificate management.

### Annotation Settings

KubeLB can propagate annotations from services, ingresses, Gateway API objects etc. in the tenant cluster to the corresponding LoadBalancer or Route resources in the management cluster. This is useful for setting annotations that are required by the cloud provider to configure the LoadBalancers. For example, the `service.beta.kubernetes.io/aws-load-balancer-internal` annotation is used to create an internal LoadBalancer in AWS.

Annotations are not propagated by default since tenants can make unwanted changes to the LoadBalancer configuration. Since each tenant is treated as a separate entity, the KubeLB management cluster needs to be configured to allow the propagation of specific annotations.

The annotation configuration set on the tenant level will override the global annotation configuration for that tenant.

#### 1. Propagate all annotations

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: Config
metadata:
  name: default
  namespace: kubelb
spec:
  propagateAllAnnotations: true
```

Keys listed in `deniedAnnotations` are still excluded; see [Deny annotations](#3-deny-annotations) below.

#### 2. Propagate specific annotations

Keys in `propagatedAnnotations` support shell-style glob patterns (`*`, `?`, `[abc]`), which is useful for allowing a whole family of controller annotations at once.

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: Config
metadata:
  name: default
  namespace: kubelb
spec:
  propagatedAnnotations:
    # If the value is empty, any value is allowed for this key.
    metallb.universe.tf/allow-shared-ip: ""
    # If the value is non-empty, it is treated as a comma-separated list of permitted exact values.
    metallb.universe.tf/loadBalancerIPs: "8.8.8.8"
    # Glob patterns match all keys under a prefix.
    nginx.ingress.kubernetes.io/*: ""
```

#### 3. Deny annotations

`deniedAnnotations` is a list of key patterns that are excluded from propagation. Deny rules **always take precedence** over `propagatedAnnotations` and `propagateAllAnnotations`, so this is the right place to enforce hard exclusions (sensitive keys, controller-internal keys, etc.). Patterns support the same shell-style glob syntax as `propagatedAnnotations`.

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: Config
metadata:
  name: default
  namespace: kubelb
spec:
  propagateAllAnnotations: true
  deniedAnnotations:
    - "kubernetes.io/last-applied-configuration"
    - "internal.company.io/*"
```

{{% notice note %}}
`defaultAnnotations` are not subject to deny rules: they represent explicit administrator intent and are merged in last without being filtered.
{{% /notice %}}

#### 4. Default annotations

Default annotations for resources that KubeLB generates in the management cluster can also be configured. This is useful for setting annotations that are required by the cloud provider to configure the LoadBalancers. For example, the `service.beta.kubernetes.io/aws-load-balancer-internal` annotation is used to create an internal LoadBalancer in AWS.

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: Config
metadata:
  name: default
  namespace: kubelb
spec:
  defaultAnnotations:
    service:
      service.beta.kubernetes.io/aws-load-balancer-internal: "true"
    ingress:
      kubernetes.io/ingress.class: "nginx"
    # Valid resource keys: all, service, ingress, gateway, httproute, grpcroute, tcproute, udproute, tlsroute
    gateway:
      cert-manager.io/cluster-issuer: "letsencrypt-prod"
    # Will be applied to all resources such as Ingress, Gateway API resources, services, etc.
    all:
      internal: "true"
```

### Configure Envoy Proxy

Sample configuration with demonstration values. All values are optional and have sane defaults. For details, see [CRD References]({{< relref "../../references">}}).

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: Config
metadata:
  name: default
  namespace: kubelb
spec:
  envoyProxy:
    replicas: 3
    # Immutable, cannot be changed after configuration.
    topology: shared
    useDaemonset: false
    singlePodPerNode: false
    nodeSelector:
      kubernetes.io/os: linux
    tolerations:
      - effect: NoSchedule
        operator: Exists
    # Can be used to configure requests/limits for Envoy Proxy
    resources:
      requests:
        cpu: 100m
        memory: 128Mi
      limits:
        cpu: 200m
        memory: 256Mi
    # Configure affinity for Envoy Proxy
    affinity:
      nodeAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
          nodeSelectorTerms:
          - matchExpressions:
            - key: kubernetes.io/os
              operator: In
              values:
              - linux
```

These values act as defaults for every tenant. To override them for a specific tenant, see [Per-Tenant Envoy Proxy Sizing]({{< relref "../../tutorials/tenants#per-tenant-envoy-proxy-sizing" >}}).

### Configure LoadBalancer Options

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: Config
metadata:
  name: default
  namespace: kubelb
spec:
  loadBalancer:
    # The class to use for LB service in the management cluster
    class: "metallb.universe.tf/metallb"
    disable: false
    # Enterprise Edition only
    limit: 5
```

### Configure Load Balancer Policy

{{% notice note %}}
Enterprise Edition only. Available from KubeLB v1.4.
{{% /notice %}}

KubeLB passes this value through to the Envoy cluster `lb_policy` for every LoadBalancer and Route it manages, affecting both L4 (Service `type: LoadBalancer`) and L7 (Ingress, Gateway API) traffic.

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: Config
metadata:
  name: default
  namespace: kubelb
spec:
  # default: RoundRobin
  loadBalancerPolicy: LeastRequest
```

Valid values:

* `RoundRobin` (default when unset)
* `LeastRequest`
* `Random`

This setting can be overridden per tenant (see [Load Balancer Policy]({{< relref "../../tutorials/tenants#load-balancer-policy" >}})) or per service via annotation (see [Per-Service Load Balancer Policy]({{< relref "../../tutorials/loadbalancer#per-service-load-balancer-policy" >}})).

### Configure Ingress Options

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: Config
metadata:
  name: default
  namespace: kubelb
spec:
  ingress:
    # The class to use for Ingress resources in the management cluster
    class: "nginx"
    disable: false
```

### Configure Gateway API Options

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: Config
metadata:
  name: default
  namespace: kubelb
spec:
  gatewayAPI:
    class: "eg"
    disable: false
    defaultGateway:
      name: "default"
      namespace: "envoy-gateway"
    # All options below are available in Enterprise Edition only.
    gateway:
      limit: 10
    disableHTTPRoute: false
    disableGRPCRoute: false
    disableTCPRoute: false
    disableUDPRoute: false
    disableTLSRoute: false
```

### Configure DNS Options

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: Config
metadata:
  name: default
  namespace: kubelb
spec:
  dns:
    # The wildcard domain to use for auto-generated hostnames for Load balancers
    # In EE Edition, this is also use to generated dynamic hostnames for tunnels.
    wildcardDomain: "*.apps.example.com"
    # Allow tenants to specify explicit hostnames for Load balancers and tunnels(in EE Edition)
    allowExplicitHostnames: false
```

See [CRD References]({{< relref "../../references">}}) for all options.
