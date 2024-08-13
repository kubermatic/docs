+++
title = "Config"
linkTitle = "Config"
date = 2023-10-27T10:07:15+02:00
weight = 1
+++

## KubeLB Manager Config

We have a dedicated CRD `config` that can be used to manage configuration for KubeLB manager. The following is an example of a `config` CRD:

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

Users can skip creation  of `config` CRD via helm by setting `kubelb.skipConfigGeneration` to `true` in the values.yaml. This will de-couple the `config` CRD from the helm chart and users can manage it separately.

**NOTE: The `config` CR named `default` is mandatory for KubeLB manager to work.**

### Propagate annotations from services to LoadBalancer

KubeLB can propagate annotations from services in the tenant cluster to the LoadBalancers in the management cluster. This is useful for setting annotations that are required by the cloud provider to configure the LoadBalancers. For example, the `service.beta.kubernetes.io/aws-load-balancer-internal` annotation is used to create an internal LoadBalancer in AWS.

Annotations are not propagated by default since tenants can make unwanted changes to the LoadBalancer configuration. Since each tenant is treated as a separate entity, the KubeLB manager cluster needs to be configured to allow the propagation of specific annotations.

This can be achieved in the following ways:

#### Propagate all annotations

This can be done by setting the `kubelb.propagateAllAnnotations` field to `true` in the `config` CRD. This will propagate all annotations from the service to the LoadBalancer.

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: Config
metadata:
  name: default
  namespace: kubelb
spec:
  propagateAllAnnotations: true
```

#### Propagate specific annotations

This can be done by setting the `kubelb.propagatedAnnotations` field in the `config` CRD. This field is a map of annotations that are allowed to be propagated. The key is the annotation name and the value is the annotation value. If the value is empty, any value is allowed.

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: Config
metadata:
  name: default
  namespace: kubelb
spec:
  propagatedAnnotations:
    metalb.universe.tf/allow-shared-ip: ""
    metallb.universe.tf/loadBalancerIPs: "8.8.8.8"
```

#### Propagate annotations from tenant namespace

This is done by adding the `kubelb.k8c.io/propagate-annotation` annotation to the tenant namespace in the management cluster. For multiple annotations, the suffix can be incremented like `kubelb.k8c.io/propagate-annotation-1` . The suffix can be any arbitrary string, it's just for uniqueness.

Here is a basic example, where optionally kubelb allows to set a values filter:

```yaml
annotations:
  kubelb.k8c.io/propagate-annotation: "metallb.universe.tf/address-pool"
  kubelb.k8c.io/propagate-annotation-1: "metallb.universe.tf/loadBalancerIPs=192.168.1.100,192.168.1.102"
```

The first configured annotation allows propagating any value for `metallb.universe.tf/address-pool` and the second one restricts the values to be either `192.168.1.100` or `192.168.1.102`.
