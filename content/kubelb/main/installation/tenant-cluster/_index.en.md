+++
title = "Install KubeLB CCM and set up the tenant cluster"
linkTitle = "Set Up Tenant Cluster"
date = 2023-10-27T10:07:15+02:00
weight = 20
+++

## Prerequisites

* Access to the Kubernetes API of the KubeLB management cluster.
* A tenant registered in the KubeLB management cluster.

See [Requirements]({{< relref "../requirements" >}}) for the full port and resource sizing reference.

* Create a `kubelb` namespace for KubeLB CCM.
* KubeLB CCM expects a Secret named `kubelb-cluster` by default. Its `kubelb` data key must contain the kubeconfig for the management cluster.
  * First register the tenant by following the [tenant registration]({{< relref "../../tutorials/tenants">}}) guide.
  * Fetch the generated kubeconfig from the management cluster, switch to the tenant cluster, and create the Secret:

  ```sh
  # Replace with the tenant cluster kubeconfig path
  TENANT_KUBECONFIG=~/.kube/<tenant-cluster>
  # Replace with the tenant name
  TENANT_NAME=tenant-shroud
  KUBELB_KUBECONFIG_B64=$(kubectl get secret kubelb-ccm-kubeconfig --namespace "$TENANT_NAME" --template='{{ .data.kubelb }}')
  # Switch to the tenant cluster.
  export KUBECONFIG="$TENANT_KUBECONFIG"
  kubectl --namespace kubelb create secret generic kubelb-cluster \
    --from-literal=kubelb="$(printf '%s' "$KUBELB_KUBECONFIG_B64" | base64 -d)"
  ```

* Override the Secret name with `.Values.kubelb.clusterSecretName` if required. Otherwise, the Secret is named `kubelb-cluster` and looks like this:

  ```sh
  kubectl get secret kubelb-cluster --namespace kubelb -o yaml
  ```

  ```yaml
  apiVersion: v1
  data:
    kubelb: xxx-base64-encoded-xxx
  kind: Secret
  metadata:
    name: kubelb-cluster
    namespace: kubelb
  type: Opaque
  ```

* Set `tenantName` in `values.yaml` to the tenant's unique identifier. The management cluster stores tenant namespaces with a `tenant-` prefix; for example, `my-tenant` becomes `tenant-my-tenant`. KubeLB accepts the name with or without this prefix.

At this point a minimal `values.yaml` should look like this:

```yaml
kubelb:
  clusterSecretName: kubelb-cluster
  tenantName: <unique-identifier-for-tenant>
```

{{% notice info %}}

**Private clusters:** If the tenant nodes do not have external IP addresses, set `kubelb.nodeAddressType` to `InternalIP`.

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
  # -- Address type to use for routing traffic to node ports. Values are ExternalIP, InternalIP, or Hostname.
  nodeAddressType: InternalIP
```

{{% /notice %}}

## Install KubeLB CCM

{{% notice warning %}} To enable Gateway API support, set both fields below in `values.yaml`. KubeLB CCM cannot start with Gateway API enabled unless the CRDs are installed.

```yaml
kubelb:
  enableGatewayAPI: true
  installGatewayAPICRDs: true
```

{{% /notice %}}

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

### Install the Helm chart

```sh
helm pull oci://quay.io/kubermatic/helm-charts/kubelb-ccm-ee --version=v1.4.3 --untardir "." --untar
## Apply CRDs
kubectl apply -f kubelb-ccm-ee/crds/
## Create and update values.yaml with the required values.
helm upgrade --install kubelb-ccm kubelb-ccm-ee --namespace kubelb -f kubelb-ccm-ee/values.yaml --create-namespace
```

### KubeLB CCM EE Values

<!-- helm-values-kubelb-ccm-ee start -->
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
| grafana.dashboards.annotations | object | `{}` | Additional annotations for dashboard ConfigMaps |
| grafana.dashboards.enabled | bool | `false` | Requires grafana to be deployed with `sidecar.dashboards.enabled=true`. For more info: <https://github.com/grafana/helm-charts/tree/grafana-10.5.13/charts/grafana#:~:text=%5B%5D-,sidecar.dashboards.enabled,-Enables%20the%20cluster> |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"quay.io/kubermatic/kubelb-ccm-ee"` |  |
| image.tag | string | `"v1.3.9"` |  |
| imagePullSecrets[0].name | string | `"kubermatic-quay.io"` |  |
| kubeRbacProxy.image.pullPolicy | string | `"IfNotPresent"` |  |
| kubeRbacProxy.image.repository | string | `"quay.io/brancz/kube-rbac-proxy"` |  |
| kubeRbacProxy.image.tag | string | `"v0.20.1"` |  |
| kubelb.clusterSecretName | string | `"kubelb-cluster"` | Name of the secret that contains kubeconfig for the loadbalancer cluster |
| kubelb.disableBackendTrafficPolicyController | bool | `false` | disableBackendTrafficPolicyController specifies whether to disable the BackendTrafficPolicy Controller. |
| kubelb.disableClientTrafficPolicyController | bool | `false` | disableClientTrafficPolicyController specifies whether to disable the ClientTrafficPolicy Controller. |
| kubelb.disableGRPCRouteController | bool | `false` | disableGRPCRouteController specifies whether to disable the GRPCRoute Controller. |
| kubelb.disableGatewayController | bool | `false` | disableGatewayController specifies whether to disable the Gateway Controller. |
| kubelb.disableHTTPRouteController | bool | `false` | disableHTTPRouteController specifies whether to disable the HTTPRoute Controller. |
| kubelb.disableIngressController | bool | `false` | disableIngressController specifies whether to disable the Ingress Controller. |
| kubelb.disableTCPRouteController | bool | `false` | disableTCPRouteController specifies whether to disable the TCPRoute Controller. |
| kubelb.disableTLSRouteController | bool | `false` | disableTLSRouteController specifies whether to disable the TLSRoute Controller. |
| kubelb.disableUDPRouteController | bool | `false` | disableUDPRouteController specifies whether to disable the UDPRoute Controller. |
| kubelb.enableGatewayAPI | bool | `false` | enableGatewayAPI specifies whether to enable the Gateway API and Gateway Controllers. By default Gateway API is disabled since without Gateway APIs installed the controller cannot start. |
| kubelb.enableLeaderElection | bool | `true` | Enable the leader election. |
| kubelb.enableSecretSynchronizer | bool | `false` | Enable to automatically convert Secrets labelled with `kubelb.k8c.io/managed-by: kubelb` to Sync Secrets. This is used to sync secrets from tenants to the LB cluster in a controlled and secure way. |
| kubelb.gatewayAPICRDsChannel | string | `"experimental"` | gatewayAPICRDsChannel specifies the channel for the Gateway API CRDs. Options are `standard` and `experimental`. |
| kubelb.ingressConversion.copyTLSSecrets | bool | `true` | copyTLSSecrets copies TLS secrets from Ingress namespace to Gateway namespace for cross-namespace certificate references |
| kubelb.ingressConversion.disableEnvoyGatewayFeatures | bool | `false` | disableEnvoyGatewayFeatures disables creation of Envoy Gateway policies (SecurityPolicy, BackendTrafficPolicy) |
| kubelb.ingressConversion.domainReplace | string | `""` | domainReplace is the domain suffix to replace in hostnames |
| kubelb.ingressConversion.domainSuffix | string | `""` | domainSuffix is the replacement domain suffix for hostnames |
| kubelb.ingressConversion.enabled | bool | `false` | enabled enables automatic Ingress to HTTPRoute conversion |
| kubelb.ingressConversion.gatewayAnnotations | string | `""` | gatewayAnnotations are annotations to add to created Gateway (comma-separated key=value pairs) Example: "cert-manager.io/cluster-issuer=letsencrypt,external-dns.alpha.kubernetes.io/target=lb.example.com" |
| kubelb.ingressConversion.gatewayClass | string | `"kubelb"` | gatewayClass is the GatewayClass name for created Gateway |
| kubelb.ingressConversion.gatewayName | string | `"kubelb"` | gatewayName is the name of the Gateway for converted HTTPRoutes |
| kubelb.ingressConversion.gatewayNamespace | string | `"kubelb"` | gatewayNamespace is the namespace for the shared Gateway (required) |
| kubelb.ingressConversion.ingressClass | string | `""` | ingressClass filters Ingresses to convert (empty = convert all) |
| kubelb.ingressConversion.propagateExternalDnsAnnotations | bool | `true` | propagateExternalDnsAnnotations propagates external-dns annotations to Gateway/HTTPRoute |
| kubelb.ingressConversion.standaloneMode | bool | `false` | standaloneMode runs as standalone converter, disabling all other controllers |
| kubelb.installGatewayAPICRDs | bool | `false` | installGatewayAPICRDs Installs and manages the Gateway API CRDs using gateway crd controller. |
| kubelb.logLevel | string | `"info"` | To configure the verbosity of logging. Can be one of 'debug', 'info', 'error', 'panic' or any integer value > 0 which corresponds to custom debug levels of increasing verbosity. |
| kubelb.maxNodeAddressCount | int | `0` | Maximum number of node addresses to forward to the LB cluster. When set, addresses are selected with topology-aware round-robin spread across zones (topology.kubernetes.io/zone). 0 means no limit. |
| kubelb.nodeAddressLabelSelector | string | `""` | Only use nodes matching this label selector as endpoint addresses (e.g. kubelb.k8c.io/endpoint=true). |
| kubelb.nodeAddressType | string | `"ExternalIP"` | Address type to use for routing traffic to node ports. Values are ExternalIP, InternalIP. |
| kubelb.tenantName | string | `nil` | Name of the tenant, must be unique against a load balancer cluster. |
| kubelb.useGatewayClass | bool | `true` | useGatewayClass specifies whether to target resources with `kubelb` gateway class or all resources. |
| kubelb.useIngressClass | bool | `true` | useIngressClass specifies whether to target resources with `kubelb` ingress class or all resources. |
| kubelb.useLoadBalancerClass | bool | `false` | useLoadBalancerClass specifies whether to target services of type LoadBalancer with `kubelb` load balancer class or all services of type LoadBalancer. |
| metrics.port | int | `9445` | Port where the CCM exposes metrics |
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
<!-- helm-values-kubelb-ccm-ee end -->

{{% /tab %}}
{{% tab name="Community Edition" %}}

### Install the Helm chart

```sh
helm pull oci://quay.io/kubermatic/helm-charts/kubelb-ccm --version=v1.4.3 --untardir "." --untar
## Apply CRDs
kubectl apply -f kubelb-ccm/crds/
## Create and update values.yaml with the required values.
helm upgrade --install kubelb-ccm kubelb-ccm --namespace kubelb -f kubelb-ccm/values.yaml --create-namespace
```

### KubeLB CCM CE Values

<!-- helm-values-kubelb-ccm start -->
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
| grafana.dashboards.annotations | object | `{}` | Additional annotations for dashboard ConfigMaps |
| grafana.dashboards.enabled | bool | `false` | Requires grafana to be deployed with `sidecar.dashboards.enabled=true`. For more info: <https://github.com/grafana/helm-charts/tree/grafana-10.5.13/charts/grafana#:~:text=%5B%5D-,sidecar.dashboards.enabled,-Enables%20the%20cluster> |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"quay.io/kubermatic/kubelb-ccm"` |  |
| image.tag | string | `"v1.3.9"` |  |
| imagePullSecrets | list | `[]` |  |
| kubeRbacProxy.image.pullPolicy | string | `"IfNotPresent"` |  |
| kubeRbacProxy.image.repository | string | `"quay.io/brancz/kube-rbac-proxy"` |  |
| kubeRbacProxy.image.tag | string | `"v0.20.1"` |  |
| kubelb.clusterSecretName | string | `"kubelb-cluster"` | Name of the secret that contains kubeconfig for the loadbalancer cluster |
| kubelb.disableGRPCRouteController | bool | `false` | disableGRPCRouteController specifies whether to disable the GRPCRoute Controller. |
| kubelb.disableGatewayController | bool | `false` | disableGatewayController specifies whether to disable the Gateway Controller. |
| kubelb.disableHTTPRouteController | bool | `false` | disableHTTPRouteController specifies whether to disable the HTTPRoute Controller. |
| kubelb.disableIngressController | bool | `false` | disableIngressController specifies whether to disable the Ingress Controller. |
| kubelb.enableGatewayAPI | bool | `false` | enableGatewayAPI specifies whether to enable the Gateway API and Gateway Controllers. By default Gateway API is disabled since without Gateway APIs installed the controller cannot start. |
| kubelb.enableLeaderElection | bool | `true` | Enable the leader election. |
| kubelb.enableSecretSynchronizer | bool | `false` | Enable to automatically convert Secrets labelled with `kubelb.k8c.io/managed-by: kubelb` to Sync Secrets. This is used to sync secrets from tenants to the LB cluster in a controlled and secure way. |
| kubelb.gatewayAPICRDsChannel | string | `"standard"` | gatewayAPICRDsChannel specifies the channel for the Gateway API CRDs. Options are `standard` and `experimental`. |
| kubelb.ingressConversion.copyTLSSecrets | bool | `true` | copyTLSSecrets copies TLS secrets from Ingress namespace to Gateway namespace for cross-namespace certificate references |
| kubelb.ingressConversion.disableEnvoyGatewayFeatures | bool | `false` | disableEnvoyGatewayFeatures disables creation of Envoy Gateway policies (SecurityPolicy, BackendTrafficPolicy) |
| kubelb.ingressConversion.domainReplace | string | `""` | domainReplace is the domain suffix to replace in hostnames |
| kubelb.ingressConversion.domainSuffix | string | `""` | domainSuffix is the replacement domain suffix for hostnames |
| kubelb.ingressConversion.enabled | bool | `false` | enabled enables automatic Ingress to HTTPRoute conversion |
| kubelb.ingressConversion.gatewayAnnotations | string | `""` | gatewayAnnotations are annotations to add to created Gateway (comma-separated key=value pairs) Example: "cert-manager.io/cluster-issuer=letsencrypt,external-dns.alpha.kubernetes.io/target=lb.example.com" |
| kubelb.ingressConversion.gatewayClass | string | `"kubelb"` | gatewayClass is the GatewayClass name for created Gateway |
| kubelb.ingressConversion.gatewayName | string | `"kubelb"` | gatewayName is the name of the Gateway for converted HTTPRoutes |
| kubelb.ingressConversion.gatewayNamespace | string | `"kubelb"` | gatewayNamespace is the namespace for the shared Gateway (required) |
| kubelb.ingressConversion.ingressClass | string | `""` | ingressClass filters Ingresses to convert (empty = convert all) |
| kubelb.ingressConversion.propagateExternalDnsAnnotations | bool | `true` | propagateExternalDnsAnnotations propagates external-dns annotations to Gateway/HTTPRoute |
| kubelb.ingressConversion.standaloneMode | bool | `false` | standaloneMode runs as standalone converter, disabling all other controllers |
| kubelb.installGatewayAPICRDs | bool | `false` | installGatewayAPICRDs Installs and manages the Gateway API CRDs using gateway crd controller. |
| kubelb.logLevel | string | `"info"` | To configure the verbosity of logging. Can be one of 'debug', 'info', 'error', 'panic' or any integer value > 0 which corresponds to custom debug levels of increasing verbosity. |
| kubelb.nodeAddressType | string | `"ExternalIP"` | Address type to use for routing traffic to node ports. Values are ExternalIP, InternalIP. |
| kubelb.tenantName | string | `nil` | Name of the tenant, must be unique against a load balancer cluster. |
| kubelb.useGatewayClass | bool | `true` | useGatewayClass specifies whether to target resources with `kubelb` gateway class or all resources. |
| kubelb.useIngressClass | bool | `true` | useIngressClass specifies whether to target resources with `kubelb` ingress class or all resources. |
| kubelb.useLoadBalancerClass | bool | `false` | useLoadBalancerClass specifies whether to target services of type LoadBalancer with `kubelb` load balancer class or all services of type LoadBalancer. |
| metrics.port | int | `9445` | Port where the CCM exposes metrics |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` |  |
| podAnnotations | object | `{}` |  |
| podLabels | object | `{}` |  |
| podSecurityContext.runAsNonRoot | bool | `true` |  |
| podSecurityContext.seccompProfile.type | string | `"RuntimeDefault"` |  |
| priorityClassName | string | `""` | PriorityClassName for the manager pod (e.g., "system-cluster-critical") |
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
<!-- helm-values-kubelb-ccm end -->

{{% /tab %}}
{{< /tabs >}}

## Verify the installation

Check that the CCM is running:

```bash
kubectl get pods -n kubelb
```

```text
NAME                          READY   STATUS    RESTARTS   AGE
kubelb-ccm-7c9f7d6b8d-4qk2n   2/2     Running   0          1m
```

The `kubelb-ccm` pod must be in `Running` state before load balancer services are reconciled.

## Set up the tenant cluster

### Install Gateway API CRDs

Starting from KubeLB v1.2.0, the Gateway API CRDs can be installed using the `installGatewayAPICRDs` flag.

{{< tabs name="Gateway APIs" >}}
{{% tab name="Enterprise Edition" %}}

```yaml
imagePullSecrets:
  - name: <imagePullSecretName>
kubelb:
    clusterSecretName: kubelb-cluster
    tenantName: <unique-identifier-for-tenant>
    # This will install the experimental channel of the Gateway API CRDs
    installGatewayAPICRDs: true
    enableGatewayAPI: true
```

For more details: [Experimental Install](https://gateway-api.sigs.k8s.io/guides/#install-experimental-channel)
{{% /tab %}}
{{% tab name="Community Edition" %}}

```yaml
kubelb:
    clusterSecretName: kubelb-cluster
    tenantName: <unique-identifier-for-tenant>
    # This will install the standard channel of the Gateway API CRDs
    installGatewayAPICRDs: true
    enableGatewayAPI: true
```

For more details: [Standard Install](https://gateway-api.sigs.k8s.io/guides/#install-standard-channel)

{{% /tab %}}
{{< /tabs >}}
