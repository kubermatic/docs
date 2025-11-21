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

{{% notice warning %}} In case if Gateway API needs to be enabled for the cluster. Please set `kubelb.enableGatewayAPI` to `true` in the `values.yaml`. This is required otherwise due to missing CRDs, kubelb will not be able to start. {{% /notice %}}

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
helm pull oci://quay.io/kubermatic/helm-charts/kubelb-manager-ee --version=v1.1.6 --untardir "." --untar
## Create and update values.yaml with the required values.
helm upgrade --install kubelb-manager kubelb-manager-ee --namespace kubelb -f kubelb-manager-ee/values.yaml --create-namespace
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
| cert-manager.enabled | bool | `false` | Enable cert-manager. |
| external-dns.enabled | bool | `false` | Enable External-DNS. |
| fullnameOverride | string | `""` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"quay.io/kubermatic/kubelb-manager-ee"` |  |
| image.tag | string | `"v1.1.6"` |  |
| imagePullSecrets[0].name | string | `"kubermatic-quay.io"` |  |
| kubelb.debug | bool | `true` |  |
| kubelb.enableGatewayAPI | bool | `false` | enableGatewayAPI specifies whether to enable the Gateway API and Gateway Controllers. By default Gateway API is disabled since without Gateway APIs installed the controller cannot start. |
| kubelb.enableLeaderElection | bool | `true` |  |
| kubelb.enableTenantMigration | bool | `true` |  |
| kubelb.envoyProxy.affinity | object | `{}` |  |
| kubelb.envoyProxy.nodeSelector | object | `{}` |  |
| kubelb.envoyProxy.replicas | int | `3` | The number of replicas for the Envoy Proxy deployment. |
| kubelb.envoyProxy.resources | object | `{}` |  |
| kubelb.envoyProxy.singlePodPerNode | bool | `true` | Deploy single pod per node. |
| kubelb.envoyProxy.tolerations | list | `[]` |  |
| kubelb.envoyProxy.topology | string | `"shared"` | Topology defines the deployment topology for Envoy Proxy. Valid values are: shared and global. |
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
| resources.limits.cpu | string | `"500m"` |  |
| resources.limits.memory | string | `"512Mi"` |  |
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
helm pull oci://quay.io/kubermatic/helm-charts/kubelb-manager --version=v1.1.6 --untardir "." --untar
## Create and update values.yaml with the required values.
helm upgrade --install kubelb-manager kubelb-manager --namespace kubelb -f kubelb-manager/values.yaml --create-namespace
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
| image.tag | string | `"v1.1.6"` |  |
| imagePullSecrets | list | `[]` |  |
| kubelb.debug | bool | `true` |  |
| kubelb.enableGatewayAPI | bool | `false` | enableGatewayAPI specifies whether to enable the Gateway API and Gateway Controllers. By default Gateway API is disabled since without Gateway APIs installed the controller cannot start. |
| kubelb.enableLeaderElection | bool | `true` |  |
| kubelb.enableTenantMigration | bool | `true` |  |
| kubelb.envoyProxy.affinity | object | `{}` |  |
| kubelb.envoyProxy.nodeSelector | object | `{}` |  |
| kubelb.envoyProxy.replicas | int | `3` | The number of replicas for the Envoy Proxy deployment. |
| kubelb.envoyProxy.resources | object | `{}` |  |
| kubelb.envoyProxy.singlePodPerNode | bool | `true` | Deploy single pod per node. |
| kubelb.envoyProxy.tolerations | list | `[]` |  |
| kubelb.envoyProxy.topology | string | `"shared"` | Topology defines the deployment topology for Envoy Proxy. Valid values are: shared and global. |
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
| resources.limits.cpu | string | `"500m"` |  |
| resources.limits.memory | string | `"512Mi"` |  |
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

Refer to [Layer 4 Load Balancing Setup]({{< relref "../../tutorials/loadbalancer#setup" >}}) for more details.

### Layer 7 Load Balancing

For Layer 7 load balancing, kubeLB supports both Ingress and Gateway API resources.

Our default recommendation is to use Gateway API and use [Envoy Gateway](https://gateway.envoyproxy.io/) as the Gateway API implementation. The features specific to Gateway API that will be built and consumed in KubeLB will be based on Envoy Gateway. While KubeLB supports integration with any Ingress or Gateway API implementation, the only limitation is that we only support native Kubernetes APIs i.e. Ingress and Gateway APIs. Provider specific APIs are not supported by KubeLB and will be completely ignored. Also, we are only testing KubeLB with Envoy Gateway and Nginx Ingress, we can't guarantee the compatibility with other Gateway API or Ingress implementations.

#### Ingress

Refer to [Ingress Setup]({{< relref "../../tutorials/ingress#setup" >}}) for more details.

#### Gateway API

Refer to [Gateway API Setup]({{< relref "../../tutorials/gatewayapi#setup" >}}) for more details.

### Certificate Management(Enterprise Edition)

Refer to [Certificate Management Setup]({{< relref "../../tutorials/security/cert-management#setup" >}}) for more details.

### DNS Management(Enterprise Edition)

Refer to [DNS Management Setup]({{< relref "../../tutorials/security/dns#setup" >}}) for more details.
