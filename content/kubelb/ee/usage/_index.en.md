+++
title = "Working with KubeLB"
date = 2023-10-27T10:07:15+02:00
weight = 6
+++

## Working with KubeLB

### Kubermatic Kubernetes Platform

Starting with KKP v2.24, KubeLB is integrated into the Kubermatic Kubernetes Platform (KKP). This means that you can use KubeLB to provision load balancers for your KKP clusters. KKP will take care of configurations and deployments for you in the user cluster. Admins mainly need to create the KubeLB manager cluster and configure KKP to use it.

For usage outside of KKP please follow the guide along.

### Usage

This guide assumes that the KubeLB manager cluster has been configured by following the [installation guide](/kubelb/ee/installation/).

### KubeLB Manager configuration

Each cluster that wants load balancer services is treated as a unique **tenant** by KubeLB. This means that the KubeLB manager needs to be aware of the tenant clusters. This is done by registering the tenant clusters in the KubeLB manager cluster. This is done by creating a namespace with the unique name of tenant and labelling it with `kubelb.k8c.io/managed-by: kubelb`.

We then create a restricted service account in the tenant cluster that will be used by the KubeLB CCM to communicate with the KubeLB manager cluster. Eventually, we need a `kubeconfig` that can be configured in the KubeLB CCM to communicate with the KubeLB manager cluster.

This script can be used for creating the required RBAC and generating the kubeconfig:

```sh
{{< readfile "kubelb/ee/data/create-kubelb-sa.sh" >}}
```

#### Manager Config

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

### KubeLB CCM configuration

For CCM, during installation we need to provide the `kubeconfig` that we generated in the previous step. Also, the `tenantName` field in the values.yaml should be set to the name of the tenant cluster.

### Propagate annotations from services to LoadBalancer

KubeLB can propagate annotations from services in the consumer cluster to the LoadBalancers in the management cluster. This is useful for setting annotations that are required by the cloud provider to configure the LoadBalancers. For example, the `service.beta.kubernetes.io/aws-load-balancer-internal` annotation is used to create an internal LoadBalancer in AWS.

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
