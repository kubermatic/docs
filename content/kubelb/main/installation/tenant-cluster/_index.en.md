+++
title = "Install KubeLB CCM and setup Tenant Cluster"
linkTitle = "Setup Tenant Cluster"
date = 2023-10-27T10:07:15+02:00
weight = 20
+++

## Requirements

* KubeLB management cluster kubernetes API access.
* Registered as a tenant in the KubeLB management cluster.

## Pre-requisites

* Create a namespace **kubelb** for the CCM to be deployed in.
* The agent expects a **Secret** with a kubeconf file named **`kubelb`** to access the management/load balancing cluster.
  * First register the tenant in LB cluster by following [tenant registration]({{< relref "../../tutorials/tenants">}}) guidelines.
  * Fetch the generated kubeconfig and create a secret from the management cluster by using these command:

  ```sh
  # Replace with the tenant cluster kubeconfig path
  TENANT_KUBECONFIG=~/.kube/<tenant-cluster>
  #  Replace with the tenant name
  TENANT_NAME=tenant-shroud
  KUBELB_KUBECONFIG=$(kubectl get secret kubelb-ccm-kubeconfig -n $TENANT_NAME --template={{.data.kubelb}})
  # At this point we have the kubeconfig in base64 encoded format.
  # Switch the context to the Tenant cluster
  export KUBECONFIG=$TENANT_KUBECONFIG
  kubectl --namespace kubelb create secret generic kubelb-cluster --from-literal=kubelb="$(echo $KUBELB_KUBECONFIG | base64 -d)"
  ```

* The name of secret can be overridden using `.Values.kubelb.clusterSecretName`, if required. If not the secret needs to be named `kubelb` and look like:

  ```
  kubectl get secrets -o yaml kubelb-cluster
  ```

  ```
  apiVersion: v1
  data:
    kubelb: xxx-base64-encoded-xxx
  kind: Secret
  metadata:
    name: kubelb-cluster
    namespace: kubelb
  type: Opaque
  ```

* Update the `tenantName` in the `values.yaml` to a unique identifier for the tenant. This is used to identify the tenant in the manager cluster. Tenants are registered in the management cluster by the Platform Provider and the name is prefixed with `tenant-`. So for example, a tenant named `my-tenant` will be registered as `tenant-my-tenant`. **NOTE: We have an automation in place and both tenant name without and with `tenant-` prefix are supported.**

At this point a minimal `values.yaml` should look like this:

```yaml
kubelb:
    clusterSecretName: kubelb-cluster
    tenantName: <unique-identifier-for-tenant>
```

{{% notice info %}}

**Important configurations for private clusters!**
If your cluster only uses internal IPs for nodes (check the following example output) you would need to change the value `kubelb.nodeAddressType` to `InternalIP`:

```bash
kubectl get nodes -o wide
```

```
NAME     STATUS   ROLES           AGE    VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE          KERNEL-VERSION       CONTAINER-RUNTIME
node-x   Ready    control-plane   208d   v1.29.9   10.66.99.222   <none>        Ubuntu            5.15.0-121-generic   containerd://1.6.33
```

Adjust `values.yaml`:

```yaml
kubelb:
  # -- Address type to use for routing traffic to node ports. Values are ExternalIP, InternalIP.
  nodeAddressType: InternalIP
```

{{% /notice %}}

## Installation for KubeLB CCM

{{% notice warning %}} In case if Gateway API needs to be enabled for the cluster. Please set `kubelb.enableGatewayAPI` to `true` in the `values.yaml`. This is required otherwise due to missing CRDs, kubelb will not be able to start. {{% /notice %}}

{{< tabs name="KubeLB CCM" >}}
{{% tab name="Enterprise Edition" %}}

### Prerequisites

* Create a namespace **kubelb** for the CCM to be deployed in.
* Create **imagePullSecrets** for the chart to pull the image from the registry in kubelb namespace.

At this point a minimal values.yaml should look like this:

```yaml
imagePullSecrets:
  - name: <imagePullSecretName>
kubelb:
    clusterSecretName: kubelb-cluster
    tenantName: <unique-identifier-for-tenant>
```

### Install the helm chart

```sh
helm pull oci://quay.io/kubermatic/helm-charts/kubelb-ccm-ee --version=v1.1.5 --untardir "." --untar
## Create and update values.yaml with the required values.
helm upgrade --install kubelb-ccm kubelb-ccm-ee --namespace kubelb -f kubelb-ccm-ee/values.yaml --create-namespace
```

### KubeLB CCM EE Values

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
| image.tag | string | `"v1.1.5"` |  |
| imagePullSecrets[0].name | string | `"kubermatic-quay.io"` |  |
| kubelb.clusterSecretName | string | `"kubelb-cluster"` | Name of the secret that contains kubeconfig for the loadbalancer cluster |
| kubelb.disableGRPCRouteController | bool | `false` | disableGRPCRouteController specifies whether to disable the GRPCRoute Controller. |
| kubelb.enableGatewayAPI | bool | `false` | enableGatewayAPI specifies whether to enable the Gateway API and Gateway Controllers. By default Gateway API is disabled since without Gateway APIs installed the controller cannot start. |
| kubelb.disableGatewayController | bool | `false` | disableGatewayController specifies whether to disable the Gateway Controller. |
| kubelb.disableHTTPRouteController | bool | `false` | disableHTTPRouteController specifies whether to disable the HTTPRoute Controller. |
| kubelb.disableIngressController | bool | `false` | disableIngressController specifies whether to disable the Ingress Controller. |
| kubelb.disableTCPRouteController | bool | `false` | disableTCPRouteController specifies whether to disable the TCPRoute Controller. |
| kubelb.disableTLSRouteController | bool | `false` | disableTLSRouteController specifies whether to disable the TLSRoute Controller. |
| kubelb.disableUDPRouteController | bool | `false` | disableUDPRouteController specifies whether to disable the UDPRoute Controller. |
| kubelb.enableLeaderElection | bool | `true` | Enable the leader election. |
| kubelb.enableSecretSynchronizer | bool | `false` | Enable to automatically convert Secrets labelled with `kubelb.k8c.io/managed-by: kubelb` to Sync Secrets. This is used to sync secrets from tenants to the LB cluster in a controlled and secure way. |
| kubelb.gatewayAPICRDsChannel | string | `"experimental"` | gatewayAPICRDsChannel specifies the channel for the Gateway API CRDs. Options are `standard` and `experimental`. |
| kubelb.installGatewayAPICRDs | bool | `false` | installGatewayAPICRDs Installs and manages the Gateway API CRDs using gateway crd controller. |
| kubelb.nodeAddressType | string | `"ExternalIP"` | Address type to use for routing traffic to node ports. Values are ExternalIP, InternalIP. |
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
| resources.limits.cpu | string | `"500m"` |  |
| resources.limits.memory | string | `"512Mi"` |  |
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

{{% /tab %}}
{{% tab name="Community Edition" %}}

### Install the helm chart

```sh
helm pull oci://quay.io/kubermatic/helm-charts/kubelb-ccm --version=v1.1.5 --untardir "." --untar
## Create and update values.yaml with the required values.
helm upgrade --install kubelb-ccm kubelb-ccm --namespace kubelb -f kubelb-ccm/values.yaml --create-namespace
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
| image.repository | string | `"quay.io/kubermatic/kubelb-ccm"` |  |
| image.tag | string | `"v1.1.5"` |  |
| imagePullSecrets | list | `[]` |  |
| kubelb.clusterSecretName | string | `"kubelb-cluster"` | Name of the secret that contains kubeconfig for the loadbalancer cluster |
| kubelb.disableGRPCRouteController | bool | `false` | disableGRPCRouteController specifies whether to disable the GRPCRoute Controller. |
| kubelb.enableGatewayAPI | bool | `false` | enableGatewayAPI specifies whether to enable the Gateway API and Gateway Controllers. By default Gateway API is disabled since without Gateway APIs installed the controller cannot start. |
| kubelb.disableGatewayController | bool | `false` | disableGatewayController specifies whether to disable the Gateway Controller. |
| kubelb.disableHTTPRouteController | bool | `false` | disableHTTPRouteController specifies whether to disable the HTTPRoute Controller. |
| kubelb.disableIngressController | bool | `false` | disableIngressController specifies whether to disable the Ingress Controller. |
| kubelb.enableLeaderElection | bool | `true` | Enable the leader election. |
| kubelb.enableSecretSynchronizer | bool | `false` | Enable to automatically convert Secrets labelled with `kubelb.k8c.io/managed-by: kubelb` to Sync Secrets. This is used to sync secrets from tenants to the LB cluster in a controlled and secure way. |
| kubelb.gatewayAPICRDsChannel | string | `"standard"` | gatewayAPICRDsChannel specifies the channel for the Gateway API CRDs. Options are `standard` and `experimental`. |
| kubelb.installGatewayAPICRDs | bool | `false` | installGatewayAPICRDs Installs and manages the Gateway API CRDs using gateway crd controller. |
| kubelb.nodeAddressType | string | `"ExternalIP"` | Address type to use for routing traffic to node ports. Values are ExternalIP, InternalIP. |
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
| resources.limits.cpu | string | `"500m"` |  |
| resources.limits.memory | string | `"512Mi"` |  |
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

{{% /tab %}}
{{< /tabs >}}

{{% notice info %}}
The manual step needed to install the Gateway API CRDs has been automated and can be enabled by setting `kubelb.installGatewayAPICRDs` to `true` in the `values.yaml` file. This will install the CRDs automatically when the KubeLB CCM is deployed.
{{% /notice %}}
