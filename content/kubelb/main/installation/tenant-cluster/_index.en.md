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
* The agent expects a **Secret** with a kubeconf file named **kubelb** to access the management/load balancing cluster.
  * First register the tenant in LB cluster by following [tenant registration]({{< relref "../../tutorials/02-tenants">}}) guidelines.
  * Fetch the generated kubeconfig and create a secret by using the command:

  ```sh
  kubectl --namespace kubelb create secret generic kubelb-cluster --from-file=<path to kubelb kubeconf file>
  ```

* The name of secret can be overridden using `.Values.kubelb.clusterSecretName`
* Update the `tenantName` in the `values.yaml` to a unique identifier for the tenant. This is used to identify the tenant in the manager cluster. This can be any unique string that follows [lower case RFC 1123](https://www.rfc-editor.org/rfc/rfc1123).

At this point a minimal `values.yaml` should look like this:

```yaml
kubelb:
    clusterSecretName: kubelb-cluster
    tenantName: <unique-identifier-for-tenant>
```

## Installation for KubeLB CCM

{{% notice warning %}} In case if Gateway API needs to be disabled for the cluster. Please set `kubelb.disableGatewayAPI` to `true` in the `values.yaml`. This is required otherwise due to missing CRDs, kubelb will not be able to start. {{% /notice %}}

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
helm registry login quay.io --username ${REGISTRY_USER} --password ${REGISTRY_PASSWORD}
helm pull oci://quay.io/kubermatic/helm-charts/kubelb-ccm-ee --version=v1.0.0 --untardir "kubelb-ccm" --untar
## Create and update values.yaml with the required values.
helm install kubelb-ccm kubelb-ccm/kubelb-ccm-ee --namespace kubelb -f values.yaml
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
| image.tag | string | `"v1.0.0"` |  |
| imagePullSecrets | list | `[]` |  |
| kubelb.clusterSecretName | string | `"kubelb-cluster"` |  |
| kubelb.enableLeaderElection | bool | `true` |  |
| kubelb.nodeAddressType | string | `"InternalIP"` |  |
| kubelb.tenantName | string | `nil` |  |
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

{{% /tab %}}
{{% tab name="Community Edition" %}}

### Install the helm chart

```sh
helm pull oci://quay.io/kubermatic/helm-charts/kubelb-ccm --version=v1.0.0 --untardir "kubelb-ccm" --untar
## Create and update values.yaml with the required values.
helm install kubelb-ccm kubelb-ccm/kubelb-ccm --namespace kubelb -f values.yaml
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
| image.tag | string | `"v1.0.0"` |  |
| imagePullSecrets | list | `[]` |  |
| kubelb.clusterSecretName | string | `"kubelb-cluster"` |  |
| kubelb.enableLeaderElection | bool | `true` |  |
| kubelb.nodeAddressType | string | `"InternalIP"` |  |
| kubelb.tenantName | string | `nil` |  |
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

{{% /tab %}}
{{< /tabs >}}

## Setup the tenant cluster

### Install Gateway API CRDs

At this point, the KubeLB CCM should be installed and running in the tenant cluster. Next steps are to install the Gateway API CRDs in the cluster. This is required to use the Gateway API resources in the tenant cluster.

{{< tabs name="Gateway APIs" >}}
{{% tab name="Enterprise Edition" %}}

Use the Experimental channel to install the CRDs:

```sh
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.1.0/experimental-install.yaml
```

For more details: [Experimental Install](https://gateway-api.sigs.k8s.io/guides/#install-experimental-channel)
{{% /tab %}}
{{% tab name="Community Edition" %}}

Use the Standard channel to install the CRDs:

```sh
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.1.0/standard-install.yaml
```

For more details: [Standard Install](https://gateway-api.sigs.k8s.io/guides/#install-standard-channel)

{{% /tab %}}
{{< /tabs >}}

{{% notice info %}}
Due to the following reasons this has been left as a manual step and we haven't added these CRDs to the KubeLB Manager chart, for automated installation:

* We can't have optional CRDs in a helm chart.
* Installing it through the helm chart would result in the existing CRDs in the tenant cluster to be overwritten. Which is not the desired behavior.

{{% /notice %}}
