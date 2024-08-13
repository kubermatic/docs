+++
title = "Install KubeLB Manager and setup Management Cluster"
linkTitle = "Setup Management Cluster"
date = 2023-10-27T10:07:15+02:00
weight = 20
+++

## Requirements

* Service type `LoadBalancer` implementation. This can be a cloud solution or a self-managed implementation like [MetalLB](https://metallb.universe.tf).
* Network access to the tenant cluster nodes with node port range (default: 30000-32767). This is required for the envoy proxy to be able to connect to the tenant cluster nodes.

## Installation for KubeLB manager

{{% notice warning %}} In case if Gateway API needs to be disabled for the cluster. Please set `kubelb.disableGatewayAPI` to `true` in the `values.yaml`. This is required otherwise due to missing CRDs, kubelb will not be able to start. {{% /notice %}}

{{< tabs name="KubeLB Manager" >}}
{{% tab name="Enterprise Edition" %}}

### Prerequisites

* Create a namespace **kubelb** for the CCM to be deployed in.
* Create **imagePullSecrets** for the chart to pull the image from the registry in kubelb namespace.

At this point a minimal values.yaml should look like this:

```yaml
imagePullSecrets:
  - name: <imagePullSecretName>
```

### Install the helm chart

```sh
helm registry login quay.io --username ${REGISTRY_USER} --password ${REGISTRY_PASSWORD}
helm pull oci://quay.io/kubermatic/helm-charts/kubelb-manager-ee --version=v1.0.0 --untardir "kubelb-manager" --untar
## Create and update values.yaml with the required values.
helm install kubelb-manager kubelb-manager/kubelb-manager-ee --namespace kubelb -f values.yaml
```

### KubeLB Manager EE Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| autoscaling.enabled | bool | `false` |  |
| autoscaling.maxReplicas | int | `10` |  |
| autoscaling.minReplicas | int | `1` |  |
| autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| autoscaling.targetMemoryUtilizationPercentage | int | `80` |  |
| fullnameOverride | string | `""` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"quay.io/kubermatic/kubelb-manager-ee"` |  |
| image.tag | string | `"v1.0.0"` |  |
| imagePullSecrets | list | `[]` |  |
| kubelb.debug | bool | `false` |  |
| kubelb.enableLeaderElection | bool | `true` |  |
| kubelb.envoyProxy.affinity | object | `{}` |  |
| kubelb.envoyProxy.nodeSelector | object | `{}` |  |
| kubelb.envoyProxy.replicas | int | `3` | The number of replicas for the Envoy Proxy deployment. |
| kubelb.envoyProxy.resources | object | `{}` |  |
| kubelb.envoyProxy.singlePodPerNode | bool | `true` | Deploy single pod per node. |
| kubelb.envoyProxy.tolerations | list | `[]` |  |
| kubelb.envoyProxy.topology | string | `"shared"` | Topology defines the deployment topology for Envoy Proxy. Valid values are: shared, dedicated, and global. |
| kubelb.envoyProxy.useDaemonset | bool | `false` | Use DaemonSet for Envoy Proxy deployment instead of Deployment. |
| kubelb.propagateAllAnnotations | bool | `false` | Propagate all annotations from the LB resource to the LB service. |
| kubelb.propagatedAnnotations | object | `{}` | Allowed annotations that will be propagated from the LB resource to the LB service. |
| kubelb.skipConfigGeneration | bool | `false` | Set to true to skip the generation of the Config CR. Useful when the config CR needs to be managed manually. |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` |  |
| podAnnotations | object | `{}` |  |
| podLabels | object | `{}` |  |
| podSecurityContext.runAsNonRoot | bool | `true` |  |
| podSecurityContext.seccompProfile.type | string | `"RuntimeDefault"` |  |
| rbac.allowLeaderElectionRole | bool | `true` |  |
| rbac.allowMetricsReaderRole | bool | `true` |  |
| rbac.allowProxyRole | bool | `true` |  |
| rbac.enabled | bool | `true` |  |
| replicaCount | int | `1` |  |
| resources.limits.cpu | string | `"100m"` |  |
| resources.limits.memory | string | `"128Mi"` |  |
| resources.requests.cpu | string | `"100m"` |  |
| resources.requests.memory | string | `"128Mi"` |  |
| securityContext.allowPrivilegeEscalation | bool | `false` |  |
| securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| securityContext.runAsUser | int | `65532` |  |
| service.port | int | `8001` |  |
| service.protocol | string | `"TCP"` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `""` |  |
| serviceMonitor.enabled | bool | `false` |  |
| tolerations | list | `[]` |  |

{{% /tab %}}
{{% tab name="Community Edition" %}}

### Install the helm chart

```sh
helm pull oci://quay.io/kubermatic/helm-charts/kubelb-manager --version=v1.0.0 --untardir "kubelb-manager" --untar
## Create and update values.yaml with the required values.
helm install kubelb-manager kubelb-manager/kubelb-manager --namespace kubelb -f values.yaml --create-namespace
```

### KubeLB Manager CE Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| autoscaling.enabled | bool | `false` |  |
| autoscaling.maxReplicas | int | `10` |  |
| autoscaling.minReplicas | int | `1` |  |
| autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| autoscaling.targetMemoryUtilizationPercentage | int | `80` |  |
| fullnameOverride | string | `""` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"quay.io/kubermatic/kubelb-manager"` |  |
| image.tag | string | `"v1.0.0"` |  |
| imagePullSecrets | list | `[]` |  |
| kubelb.debug | bool | `false` |  |
| kubelb.enableLeaderElection | bool | `true` |  |
| kubelb.envoyProxy.affinity | object | `{}` |  |
| kubelb.envoyProxy.nodeSelector | object | `{}` |  |
| kubelb.envoyProxy.replicas | int | `3` | The number of replicas for the Envoy Proxy deployment. |
| kubelb.envoyProxy.resources | object | `{}` |  |
| kubelb.envoyProxy.singlePodPerNode | bool | `true` | Deploy single pod per node. |
| kubelb.envoyProxy.tolerations | list | `[]` |  |
| kubelb.envoyProxy.topology | string | `"shared"` | Topology defines the deployment topology for Envoy Proxy. Valid values are: shared, dedicated, and global. |
| kubelb.envoyProxy.useDaemonset | bool | `false` | Use DaemonSet for Envoy Proxy deployment instead of Deployment. |
| kubelb.propagateAllAnnotations | bool | `false` | Propagate all annotations from the LB resource to the LB service. |
| kubelb.propagatedAnnotations | object | `{}` | Allowed annotations that will be propagated from the LB resource to the LB service. |
| kubelb.skipConfigGeneration | bool | `false` | Set to true to skip the generation of the Config CR. Useful when the config CR needs to be managed manually. |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` |  |
| podAnnotations | object | `{}` |  |
| podLabels | object | `{}` |  |
| podSecurityContext.runAsNonRoot | bool | `true` |  |
| podSecurityContext.seccompProfile.type | string | `"RuntimeDefault"` |  |
| rbac.allowLeaderElectionRole | bool | `true` |  |
| rbac.allowMetricsReaderRole | bool | `true` |  |
| rbac.allowProxyRole | bool | `true` |  |
| rbac.enabled | bool | `true` |  |
| replicaCount | int | `1` |  |
| resources.limits.cpu | string | `"100m"` |  |
| resources.limits.memory | string | `"128Mi"` |  |
| resources.requests.cpu | string | `"100m"` |  |
| resources.requests.memory | string | `"128Mi"` |  |
| securityContext.allowPrivilegeEscalation | bool | `false` |  |
| securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| securityContext.runAsUser | int | `65532` |  |
| service.port | int | `8001` |  |
| service.protocol | string | `"TCP"` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `""` |  |
| serviceMonitor.enabled | bool | `false` |  |
| tolerations | list | `[]` |  |

{{% /tab %}}
{{< /tabs >}}

## Setup the management cluster

{{% notice note %}}
The examples and tools shared below are for demonstration purposes, you can use any other tools or configurations as per your requirements.
{{% /notice %}}

Management cluster is the place where all the components required for Layer 4 and Layer 7 load balancing are installed. The management cluster is responsible for managing the tenant clusters and their load balancing requests/configurations.

### Layer 4 Load Balancing

For layer 4 load balancing, either the kubernetes cluster should be on a cloud, using it's CCM, that supports the `LoadBalancer` service type or a self-managed solution like [MetalLB](https://metallb.universe.tf) should be installed. [This guide](https://metallb.universe.tf/installation/#installation-with-helm) can be followed to install and configure MetalLB on the management cluster.

A minimal configuration for MetalLB for demonstration purposes is as follows:

```yaml
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: extern
  namespace: metallb-system
spec:
  ipAddressPools:
    - extern
---
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: management-pool
  namespace: metallb-system
spec:
  addresses:
    - 10.10.255.200-10.10.255.250
```

This configures an address pool `extern` with an IP range from 10.10.255.200 to 10.10.255.250. This IP range can be used by the tenant clusters to allocate IP addresses for the `LoadBalancer` service type.

Further reading: <https://metallb.universe.tf/configuration/_advanced_l2_configuration/>

### Layer 7 Load Balancing

For Layer 7 load balancing, kubeLB supports both Ingress and Gateway API resources.

Our default recommendation is to use Gateway API and use [Envoy Gateway](https://gateway.envoyproxy.io/) as the Gateway API implementation. The features specific to Gateway API that will be built and consumed in KubeLB will be based on Envoy Gateway. Although this is not a strict binding and our consumers are free to use any Ingress or Gateway API implementation. The only limitation is that we only support native Kubernetes APIs i.e. Ingress and Gateway APIs. Provider specific APIs are not supported by KubeLB and will be completely ignored.

#### Ingress

Although KubeLB supports Ingress, we strongly encourage you to use Gateway API instead as Ingress has been [feature frozen](https://kubernetes.io/docs/concepts/services-networking/ingress/#:~:text=Note%3A-,Ingress%20is%20frozen,-.%20New%20features%20are) in Kubernetes and all new development is happening in the Gateway API space. The biggest advantage of Gateway API is that it is a more flexible, has extensible APIs and is **multi-tenant compliant** by default. Ingress doesn't support multi-tenancy.

There are two modes in which Ingress can be setup in the management cluster:

1. **Per tenant(Recommended)**: Install your controller with default configuration but scope it down to a specific namespace. This is the recommended approach as it allows you to have a single controller per tenant and the IP for ingress controller is not shared across tenants.

```sh
helm install nginx-ingress oci://ghcr.io/nginxinc/charts/nginx-ingress --version 1.3.1 \
      --namespace tenant-shroud
      -–set controller.scope.namespace=tenant-shroud
```

2. **Shared**: Install your controller with default configuration.

```sh
helm install nginx-ingress oci://ghcr.io/nginxinc/charts/nginx-ingress --version 1.3.1
```

For details: <https://docs.nginx.com/nginx-ingress-controller/installation/installing-nic/installation-with-helm/#installing-the-chart>

#### Gateway API

Gateway API targets three personas:

1. Platform Provider: The Platform Provider is responsible for the overall environment that the cluster runs in, i.e. the cloud provider. The Platform Provider will interact with GatewayClass resources.
2. Platform Operator: The Platform Operator is responsible for overall cluster administration. They manage policies, network access, application permissions and will interact with Gateway resources.
3. Service Operator: The Service Operator is responsible for defining application configuration and service composition. They will interact with HTTPRoute and TLSRoute resources and other typical Kubernetes resources.

Further reading: <https://gateway-api.sigs.k8s.io/#personas>

In KubeLB, we treat the admins of management cluster as the Platform provider. Hence, they are responsible for creating the `GatewayClass` resource. Tenants are the Service Operators. For Platform Operator, this role could vary based on your configurations for the management cluster. In Enterprise edition, users can set the limit of Gateways to 0 to shift the role of "Platform Operator" to the "Platform Provider". In other case, by default, the Platform Operator role is assigned to the tenants.

Install Envoy Gateway by following this [guide](https://gateway.envoyproxy.io/docs/install/install-helm/) or any other Gateway API implementation of your choice.

Ensure that `GatewayClass` exists in the management cluster. A minimal configuration for GatewayClass is as follows:

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: eg
spec:
  controllerName: gateway.envoyproxy.io/gatewayclass-controller
```

### Certificate Management(Enterprise Edition)

Install [cert-manager](https://cert-manager.io/docs/installation/helm/) to manage certificates for your tenants. Certificate management can be enabled/disabled at global or tenant level. For automation purposes, you can configure allowed domains and default issuer for the certificates at the tenant level.

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: Tenant
metadata:
  name: shroud
spec:
  # These domains are allowed to be used for Ingress, Gateway API, DNS, and certs.
  allowedDomains:
    - "kube.example.com"
    - "*.kube.example.com"
    - "*.shroud.example.com"
  certificates:
    # can also be configured in the `Config` resource at a global level.
    # Default issuer to use if `kubelb.k8c.io/manage-certificates` annotation is added to the cluster.
    defaultClusterIssuer: "letsencrypt-staging"
    # If not empty, only the domains specified here will have automation for Certificates. Everything else will be ignored.
    allowedDomains:
    - "*.shroud.example.com"
```

Users can then either use [cert-manager annotations](https://cert-manager.io/docs/usage/ingress/) or the annotation `kubelb.k8c.io/manage-certificates: true` on their resources to automate certificate management.

#### Cluster Issuer example

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-staging
spec:
  acme:
    # You must replace this email address with your own.
    # Let's Encrypt will use this to contact you about expiring
    # certificates, and issues related to your account.
    email: user@example.com
    server: https://acme-staging-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      # Secret resource that will be used to store the account's private key.
      name: example-issuer-account-key
    # Add a single challenge solver, HTTP01 using nginx
    solvers:
    - http01:
        ingress:
          ingressClassName: nginx
```

The additional validation at the tenant level allows us to use a single instance of cert-manager for multiple tenants. Multiple cert-manager installations are not recommended and it's better to have a single instance of cert-manager for all tenants but different ClusterIssuers/Issuers for different tenants, if required.

### DNS Management(Enterprise Edition)

Install [External-dns](https://bitnami.com/stack/external-dns/helm) to manage DNS records for the tenant clusters. DNS can be enabled/disabled at global or tenant level. For automation purposes, you can configure allowed domains for DNS per tenant.

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: Tenant
metadata:
  name: shroud
spec:
  # These domains are allowed to be used for Ingress, Gateway API, DNS, and certs.
  allowedDomains:
    - "kube.example.com"
    - "*.kube.example.com"
    - "*.shroud.example.com"
  dns:
    # If not empty, only the domains specified here will have automation for DNS. Everything else will be ignored.
    allowedDomains:
    - "*.shroud.example.com"
```

Users can then either use [external-dns annotations](https://github.com/kubernetes-sigs/external-dns/blob/master/docs/annotations/annotations.md) or the annotation `kubelb.k8c.io/manage-dns: true` on their resources to automate DNS management.

The additional validation at the tenant level allows us to use a single instance of external-dns for multiple tenants. Although, if required, external-dns can be installed per tenant as well.
