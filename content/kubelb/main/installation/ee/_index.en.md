+++
title = "Install Kubermatic KubeLB Enterprise Edition"
linkTitle = "Install Enterprise Edition"
date = 2023-10-27T10:07:15+02:00
weight = 20
enterprise = true
+++

{{% notice note %}}
To use KubeLB enterprise offering, you need to have a valid license.
Please [contact sales](mailto:sales@kubermatic.com) for more information.
{{% /notice %}}

## Requirements

### Tenant cluster

* KubeLB manager cluster API access.
* Registered as a tenant in the KubeLB manager cluster.

### Load balancer cluster

* Service type `LoadBalancer` implementation. This can be a cloud solution or a self-managed implementation like [MetalLB](https://metallb.universe.tf).
* Network access to the tenant cluster nodes with node port range (default: 30000-32767). This is required for the envoy proxy to be able to connect to the tenant cluster nodes.

## Installation for KubeLB manager

KubeLB manager is deployed as a Kubernetes application. It can be deployed using the KubeLB manager Helm chart in the following way:

### Prerequisites

* Create a namespace `kubelb` for the CCM to be deployed in.
* Create `imagePullSecrets` for the chart to pull the image from the registry.

At this point a minimal values.yaml should look like this:

```yaml
imagePullSecrets:
  - name: <imagePullSecretName>
```

Now, we can install the helm chart:

```sh
helm registry login quay.io --username ${REGISTRY_USER} --password ${REGISTRY_PASSWORD}
helm pull oci://quay.io/kubermatic/helm-charts/kubelb-manager-ee --version=v1.1.0 --untardir "kubelb-manager" --untar
## Create and update values.yaml with the required values.
helm install kubelb-manager kubelb-manager/kubelb-manager-ee --namespace kubelb -f values.yaml
```

### KubeLB Manager Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| autoscaling.enabled | bool | `false` |  |
| autoscaling.maxReplicas | int | `10` |  |
| autoscaling.minReplicas | int | `1` |  |
| autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| autoscaling.targetMemoryUtilizationPercentage | int | `80` |  |
| cert-manager.enabled | bool | `false` |  |
| external-dns.enabled | bool | `false` |  |
| fullnameOverride | string | `""` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"quay.io/kubermatic/kubelb-manager-ee"` |  |
| image.tag | string | `"v0.7.0"` |  |
| imagePullSecrets | list | `[]` |  |
| kubelb.debug | bool | `false` |  |
| kubelb.enableLeaderElection | bool | `true` |  |
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

#### Subcharts

| Repository | Name | Version |
|------------|------|---------|
| <https://charts.jetstack.io> | cert-manager(cert-manager) | v1.15.1 |
| oci://registry-1.docker.io/bitnamicharts | external-dns(external-dns) | 8.3.3 |

## Installation for KubeLB CCM

### Pre-requisites

* Create a namespace **kubelb** for the CCM to be deployed in.
* The agent expects a **Secret** with a kubeconf file named **kubelb** to access the load balancer cluster.
  * First register the tenant in LB cluster by following [tenant registration]({{< relref "../../tutorials/01-tenants">}}) guidelines.
  * Fetch the generated kubeconfig and create a secret by using the command:

  ```sh
  kubectl --namespace kubelb create secret generic kubelb-cluster --from-file=<path to kubelb kubeconf file>
  ```

* The name of secret can be overridden using `.Values.kubelb.clusterSecretName`
* Update the `tenantName` in the `values.yaml` to a unique identifier for the tenant. This is used to identify the tenant in the manager cluster. This can be any unique string that follows [lower case RFC 1123](https://www.rfc-editor.org/rfc/rfc1123).

At this point a minimal `values.yaml` should look like this:

```yaml
imagePullSecrets:
  - name: <imagePullSecretName>
kubelb:
    clusterSecretName: kubelb-cluster
    tenantName: <unique-identifier-for-tenant>
```

Now, we can install the helm chart:

```sh
helm registry login quay.io --username ${REGISTRY_USER} --password ${REGISTRY_PASSWORD}
helm pull oci://quay.io/kubermatic/helm-charts/kubelb-ccm-ee --version=v1.1.0 --untardir "kubelb-ccm" --untar
## Create and update values.yaml with the required values.
helm install kubelb-ccm kubelb-ccm/kubelb-ccm-ee --namespace kubelb -f values.yaml
```

### KubeLB CCM Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| autoscaling.enabled | bool | `false` |  |
| autoscaling.maxReplicas | int | `10` |  |
| autoscaling.minReplicas | int | `1` |  |
| autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| autoscaling.targetMemoryUtilizationPercentage | int | `80` |  |
| extraVolumeMounts | list | `[]` |  |
| extraVolumes | list | `[]` |  |
| fullnameOverride | string | `""` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"quay.io/kubermatic/kubelb-ccm-ee"` |  |
| image.tag | string | `"v0.7.0"` |  |
| imagePullSecrets | list | `[]` |  |
| kubelb.clusterSecretName | string | `"kubelb-cluster"` | Name of the secret that contains kubeconfig for the loadbalancer cluster |
| kubelb.disableGRPCRouteController | bool | `false` | disableGRPCRouteController specifies whether to disable the GRPCRoute Controller. |
| kubelb.disableGatewayAPI | bool | `false` | disableGatewayAPI specifies whether to disable the Gateway API and Gateway Controllers. |
| kubelb.disableGatewayController | bool | `false` | disableGatewayController specifies whether to disable the Gateway Controller. |
| kubelb.disableHTTPRouteController | bool | `false` | disableHTTPRouteController specifies whether to disable the HTTPRoute Controller. |
| kubelb.disableIngressController | bool | `false` | disableIngressController specifies whether to disable the Ingress Controller. |
| kubelb.disableTCPRouteController | bool | `false` | disableTCPRouteController specifies whether to disable the TCPRoute Controller. |
| kubelb.disableTLSRouteController | bool | `false` | disableTLSRouteController specifies whether to disable the TLSRoute Controller. |
| kubelb.disableUDPRouteController | bool | `false` | disableUDPRouteController specifies whether to disable the UDPRoute Controller. |
| kubelb.enableLeaderElection | bool | `true` | Enable the leader election. |
| kubelb.nodeAddressType | string | `"InternalIP"` |  |
| kubelb.tenantName | string | `nil` | Name of the tenant, must be unique against a load balancer cluster. |
| kubelb.useGatewayClass | bool | `true` | useGatewayClass specifies whether to target resources with `kubelb` gateway class or all resources. |
| kubelb.useIngressClass | bool | `true` | useIngressClass specifies whether to target resources with `kubelb` ingress class or all resources. |
| kubelb.useLoadBalancerClass | bool | `false` | useLoadBalancerClass specifies whether to target services of type LoadBalancer with `kubelb` load balancer class or all services of type LoadBalancer. |
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
| service.port | int | `8443` |  |
| service.protocol | string | `"TCP"` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `""` |  |
| serviceMonitor.enabled | bool | `false` |  |
| tolerations | list | `[]` |  |

## Usage

See the [tutorial documentation]({{< relref "../../tutorials">}}) for usage documentation.
