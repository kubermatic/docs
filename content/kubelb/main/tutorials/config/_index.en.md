+++
title = "KubeLB Management Cluster Configuration"
linkTitle = "Management Configuration"
date = 2023-10-27T10:07:15+02:00
weight = 1
+++

We have a dedicated CRD `config` that can be used to manage configuration for KubeLB manager in management cluster. The following is an example of a `config` CRD:

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

Users can skip creation  of **Config** object via helm by applying the following modification to the **values.yaml** file for the helm chart:

```yaml
kubelb:
  skipConfigGeneration: true
```

This will de-couple the `config` from the helm chart and users can manage it separately. This is recommended since the coupling of `config` CRD with helm chart makes it dependant on the helm chart and the admin would need to upgrade the helm chart to update the `config` CRD.

**NOTE: The Config CR named `default` is mandatory for KubeLB manager to work.**

## Configuration Options

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

These configurations are available at a global level and also at a tenant level. The tenant level configurations will override the global configurations for that tenant. It's important to configure these options at one of those levels since they perform essential functions for KubeLB.

1. **Ingress.Class**: The class to use for Ingress resources for tenants in mangement cluster.
2. **GatewayAPI.Class**: The class to use for Gateway API resources for tenants in management cluster.
3. **Certificates.DefaultClusterIssuer(EE)**: The default cluster issuer to use for certificate management.

### Propagate annotations

KubeLB can propagate annotations from services, ingresses, gateway API objects etc. in the tenant cluster to the corresponding LoadBalancer or Route resources in the management cluster. This is useful for setting annotations that are required by the cloud provider to configure the LoadBalancers. For example, the `service.beta.kubernetes.io/aws-load-balancer-internal` annotation is used to create an internal LoadBalancer in AWS.

Annotations are not propagated by default since tenants can make unwanted changes to the LoadBalancer configuration. Since each tenant is treated as a separate entity, the KubeLB manager cluster needs to be configured to allow the propagation of specific annotations.

1. Propagate all annotations

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: Config
metadata:
  name: default
  namespace: kubelb
spec:
  propagateAllAnnotations: true
```

2. Propagate specifc annotations

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: Config
metadata:
  name: default
  namespace: kubelb
spec:
  propagatedAnnotations:
    # If the key is empty, any value can be configured for propagation.
    metalb.universe.tf/allow-shared-ip: ""
    # Since the value is explicitly provided, only this value will be allowed for propagation.
    metallb.universe.tf/loadBalancerIPs: "8.8.8.8"
```

### Configure Envoy Proxy

Sample configuration, inflated with values for demonstration purposes only. All of the values are optional and have sane defaults. For more details check [CRD References]({{< relref "../../references">}})

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
    # Can be used to configure requests/limits for envoy proxy
    resources:
      requests:
        cpu: 100m
        memory: 128Mi
      limits:
        cpu: 200m
        memory: 256Mi
    # Configure affinity for envoy proxy
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
    # Enterprise Edition Only
    limit: 5
```

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
    # The class to use for Ingress resources in the management cluster
    class: "nginx"
    disable: false
    # Enterprise Edition Only
    gateway:
      limits: 10
    disableHTTPRoute: false
    disableGRPCRoute: false
    # Enterprise Edition Only
    disableTCPRoute: false
    # Enterprise Edition Only
    disableUDPRoute: false
    # Enterprise Edition Only
    disableTLSRoute: false
```

**For more details and options, please go through [CRD References]({{< relref "../../references">}})**
