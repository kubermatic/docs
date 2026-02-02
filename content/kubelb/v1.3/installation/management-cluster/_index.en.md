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
helm pull oci://quay.io/kubermatic/helm-charts/kubelb-manager-ee --version=v1.3.0 --untardir "." --untar
## Apply CRDs
kubectl apply -f kubelb-manager-ee/crds/
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
| grafana.dashboards.annotations | object | `{}` | Additional annotations for dashboard ConfigMaps |
| grafana.dashboards.enabled | bool | `false` | Requires grafana to be deployed with `sidecar.dashboards.enabled=true`. For more info: <https://github.com/grafana/helm-charts/tree/grafana-10.5.13/charts/grafana#:~:text=%5B%5D-,sidecar.dashboards.enabled,-Enables%20the%20cluster> |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"quay.io/kubermatic/kubelb-manager-ee"` |  |
| image.tag | string | `"v1.3.0"` |  |
| imagePullSecrets[0].name | string | `"kubermatic-quay.io"` |  |
| kkpintegration.rbac | bool | `false` | Create RBAC for KKP integration. |
| kubeRbacProxy.image.pullPolicy | string | `"IfNotPresent"` |  |
| kubeRbacProxy.image.repository | string | `"quay.io/brancz/kube-rbac-proxy"` |  |
| kubeRbacProxy.image.tag | string | `"v0.20.1"` |  |
| kubelb.debug | bool | `true` |  |
| kubelb.disableEnvoyGatewayFeatures | bool | `false` | disableEnvoyGatewayFeatures disables Envoy Gateway support for BackendTrafficPolicy and ClientTrafficPolicy. Use this if you're using a Gateway API implementation other than Envoy Gateway. |
| kubelb.enableGatewayAPI | bool | `false` | enableGatewayAPI specifies whether to enable the Gateway API and Gateway Controllers. By default Gateway API is disabled since without Gateway APIs installed the controller cannot start. |
| kubelb.enableLeaderElection | bool | `true` |  |
| kubelb.enableWAF | bool | `false` | [Alpha Feature] enableWAF enables the WAF controller for Web Application Firewall policy validation. WAF is an alpha feature and is disabled by default. |
| kubelb.envoyProxy.affinity | object | `{}` |  |
| kubelb.envoyProxy.gracefulShutdown.disabled | bool | `false` | Disable graceful shutdown (default: false) |
| kubelb.envoyProxy.nodeSelector | object | `{}` |  |
| kubelb.envoyProxy.replicas | int | `2` | The number of replicas for the Envoy Proxy deployment. |
| kubelb.envoyProxy.resources | object | `{}` |  |
| kubelb.envoyProxy.singlePodPerNode | bool | `true` | Deploy single pod per node. |
| kubelb.envoyProxy.tolerations | list | `[]` |  |
| kubelb.envoyProxy.topology | string | `"shared"` | Topology defines the deployment topology for Envoy Proxy. Valid values are: shared and global. |
| kubelb.envoyProxy.useDaemonset | bool | `false` | Use DaemonSet for Envoy Proxy deployment instead of Deployment. |
| kubelb.logLevel | string | `"info"` | To configure the verbosity of logging. Can be one of 'debug', 'info', 'error', 'panic' or any integer value > 0 which corresponds to custom debug levels of increasing verbosity. |
| kubelb.propagateAllAnnotations | bool | `false` | Propagate all annotations from the LB resource to the LB service. |
| kubelb.propagatedAnnotations | object | `{}` | Allowed annotations that will be propagated from the LB resource to the LB service. |
| kubelb.skipConfigGeneration | bool | `false` | Set to true to skip the generation of the Config CR. Useful when the config CR needs to be managed manually. |
| kubelb.tunnel.connectionManager.affinity | object | `{}` |  |
| kubelb.tunnel.connectionManager.healthCheck.enabled | bool | `true` |  |
| kubelb.tunnel.connectionManager.healthCheck.livenessInitialDelay | int | `30` |  |
| kubelb.tunnel.connectionManager.healthCheck.readinessInitialDelay | int | `10` |  |
| kubelb.tunnel.connectionManager.httpAddr | string | `":8080"` | Server addresses |
| kubelb.tunnel.connectionManager.httpRoute.annotations | object | `{"cert-manager.io/cluster-issuer":"letsencrypt-prod","external-dns.alpha.kubernetes.io/hostname":"connection-manager.${DOMAIN}"}` | Annotations for HTTPRoute |
| kubelb.tunnel.connectionManager.httpRoute.domain | string | `"connection-manager.${DOMAIN}"` | Domain for the HTTPRoute NOTE: Replace ${DOMAIN} with your domain name. |
| kubelb.tunnel.connectionManager.httpRoute.enabled | bool | `false` |  |
| kubelb.tunnel.connectionManager.httpRoute.gatewayName | string | `"gateway"` | Gateway name to attach to |
| kubelb.tunnel.connectionManager.httpRoute.gatewayNamespace | string | `""` | Gateway namespace |
| kubelb.tunnel.connectionManager.image | object | `{"pullPolicy":"IfNotPresent","repository":"quay.io/kubermatic/kubelb-connection-manager-ee","tag":""}` | Connection manager image configuration |
| kubelb.tunnel.connectionManager.ingress | object | `{"annotations":{"cert-manager.io/cluster-issuer":"letsencrypt-prod","external-dns.alpha.kubernetes.io/hostname":"connection-manager.${DOMAIN}","nginx.ingress.kubernetes.io/backend-protocol":"HTTP","nginx.ingress.kubernetes.io/proxy-read-timeout":"3600","nginx.ingress.kubernetes.io/proxy-send-timeout":"3600"},"className":"nginx","enabled":false,"hosts":[{"host":"connection-manager.${DOMAIN}","paths":[{"path":"/tunnel","pathType":"Prefix"},{"path":"/health","pathType":"Prefix"}]}],"tls":[{"hosts":["connection-manager.${DOMAIN}"],"secretName":"connection-manager-tls"}]}` | Ingress configuration for external HTTP/2 access |
| kubelb.tunnel.connectionManager.nodeSelector | object | `{}` |  |
| kubelb.tunnel.connectionManager.podAnnotations | object | `{}` | Pod configuration |
| kubelb.tunnel.connectionManager.podLabels | object | `{}` |  |
| kubelb.tunnel.connectionManager.podSecurityContext.fsGroup | int | `65534` |  |
| kubelb.tunnel.connectionManager.podSecurityContext.runAsNonRoot | bool | `true` |  |
| kubelb.tunnel.connectionManager.podSecurityContext.runAsUser | int | `65534` |  |
| kubelb.tunnel.connectionManager.replicaCount | int | `1` | Number of connection manager replicas |
| kubelb.tunnel.connectionManager.requestTimeout | string | `"30s"` |  |
| kubelb.tunnel.connectionManager.resources | object | `{"limits":{"cpu":"500m","memory":"256Mi"},"requests":{"cpu":"250m","memory":"128Mi"}}` | Resource limits |
| kubelb.tunnel.connectionManager.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"readOnlyRootFilesystem":true,"runAsNonRoot":true,"runAsUser":65534}` | Security context |
| kubelb.tunnel.connectionManager.service | object | `{"httpPort":8080,"type":"ClusterIP"}` | Service configuration |
| kubelb.tunnel.connectionManager.tolerations | list | `[]` |  |
| kubelb.tunnel.enabled | bool | `false` | Enable tunnel functionality |
| metrics.port | int | `9443` | Port where the manager exposes metrics (includes both manager and envoycp metrics) |
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
helm pull oci://quay.io/kubermatic/helm-charts/kubelb-manager --version=v1.3.0 --untardir "." --untar
## Apply CRDs
kubectl apply -f kubelb-manager/crds/
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
| grafana.dashboards.annotations | object | `{}` | Additional annotations for dashboard ConfigMaps |
| grafana.dashboards.enabled | bool | `false` | Requires grafana to be deployed with `sidecar.dashboards.enabled=true`. For more info: <https://github.com/grafana/helm-charts/tree/grafana-10.5.13/charts/grafana#:~:text=%5B%5D-,sidecar.dashboards.enabled,-Enables%20the%20cluster> |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"quay.io/kubermatic/kubelb-manager"` |  |
| image.tag | string | `"v1.3.0"` |  |
| imagePullSecrets | list | `[]` |  |
| kkpintegration.rbac | bool | `false` | Create RBAC for KKP integration. |
| kubeRbacProxy.image.pullPolicy | string | `"IfNotPresent"` |  |
| kubeRbacProxy.image.repository | string | `"quay.io/brancz/kube-rbac-proxy"` |  |
| kubeRbacProxy.image.tag | string | `"v0.20.1"` |  |
| kubelb.debug | bool | `true` |  |
| kubelb.enableGatewayAPI | bool | `false` | enableGatewayAPI specifies whether to enable the Gateway API and Gateway Controllers. By default Gateway API is disabled since without Gateway APIs installed the controller cannot start. |
| kubelb.enableLeaderElection | bool | `true` |  |
| kubelb.envoyProxy.affinity | object | `{}` |  |
| kubelb.envoyProxy.gracefulShutdown.disabled | bool | `false` | Disable graceful shutdown (default: false) |
| kubelb.envoyProxy.nodeSelector | object | `{}` |  |
| kubelb.envoyProxy.replicas | int | `2` | The number of replicas for the Envoy Proxy deployment. |
| kubelb.envoyProxy.resources | object | `{}` |  |
| kubelb.envoyProxy.singlePodPerNode | bool | `true` | Deploy single pod per node. |
| kubelb.envoyProxy.tolerations | list | `[]` |  |
| kubelb.envoyProxy.topology | string | `"shared"` | Topology defines the deployment topology for Envoy Proxy. Valid values are: shared and global. |
| kubelb.envoyProxy.useDaemonset | bool | `false` | Use DaemonSet for Envoy Proxy deployment instead of Deployment. |
| kubelb.logLevel | string | `"info"` | To configure the verbosity of logging. Can be one of 'debug', 'info', 'error', 'panic' or any integer value > 0 which corresponds to custom debug levels of increasing verbosity. |
| kubelb.propagateAllAnnotations | bool | `false` | Propagate all annotations from the LB resource to the LB service. |
| kubelb.propagatedAnnotations | object | `{}` | Allowed annotations that will be propagated from the LB resource to the LB service. |
| kubelb.skipConfigGeneration | bool | `false` | Set to true to skip the generation of the Config CR. Useful when the config CR needs to be managed manually. |
| metrics.port | int | `9443` | Port where the manager exposes metrics (includes both manager and envoycp metrics) |
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

Management cluster acts as the dataplane and central control plane for all your load balancing configurations. It is the place where all the components required for Layer 4 and Layer 7 load balancing, AI Gateways, MCP Gateways, Agent2Agent Gateways, and API Gateways etc. are deployed. The management cluster is multi-tenant by design which makes it a perfect for managing a fleet of clusters in a scalable, robust, and secure way.

KubeLB has introduced an addons chart to simplify the installation of the required components for the management cluster. The chart is already part of the KubeLB manager chart and can be installed by setting the `kubelb-addons.enabled` to `true` in the values.yaml.

```yaml
kubelb:
  enableGatewayAPI: true
  debug: true

## Addon configuration
kubelb-addons:
  enabled: true

  gatewayClass:
    create: true

  # Ingress Nginx
  ingress-nginx:
    enabled: false
    controller:
      service:
        externalTrafficPolicy: Local

  # Envoy Gateway
  envoy-gateway:
    enabled: true

  # Cert Manager
  cert-manager:
    enabled: true
    crds:
      enabled: true
    config:
      apiVersion: controller.config.cert-manager.io/v1alpha1
      kind: ControllerConfiguration
      enableGatewayAPI: true

  # External DNS
  external-dns:
    domainFilters:
      - example.com
    extraVolumes:
      - name: credentials
        secret:
          secretName: route53-credentials
    extraVolumeMounts:
      - name: credentials
        mountPath: /.aws
        readOnly: true
    env:
      - name: AWS_SHARED_CREDENTIALS_FILE
        value: /.aws/credentials
    txtOwnerId: kubelb-example-aws
    registry: txt
    provider: aws
    policy: sync
    sources:
      - service
      - ingress
      - gateway-httproute
      - gateway-grpcroute
      - gateway-tlsroute
      - gateway-tcproute
      - gateway-udproute

  ## AI and Agent2Agent Gateways Integration
  # KGateway CRDs
  kgateway-crds:
    enabled: true

  # KGateway
  kgateway:
    enabled: true
    gateway:
      aiExtension:
        enabled: true
    agentgateway:
      enabled: true

```

### TCP/UDP Load Balancing (Layer 4)

Refer to [Layer 4 Load Balancing Setup]({{< relref "../../tutorials/loadbalancer#setup" >}}) for more details.

### Application Layer Load Balancing (Layer 7)

For Application layer load balancing, **kubeLB supports both Ingress and Gateway API resources**.

Our default recommendation is to use Gateway API and use [Envoy Gateway](https://gateway.envoyproxy.io/) as the Gateway API implementation. Most of the upcoming and current features that KubeLB will focus on will prioritize Gateway API instead of Ingress. With Envoy Gateway being the product that we'll actively support, test, and base our features on.

While KubeLB supports integration with any Ingress or Gateway API implementation, the only limitation is that we only support native Kubernetes APIs i.e. Ingress and Gateway APIs. Provider specific APIs are not supported by KubeLB and will be completely ignored. Also, we are only testing KubeLB with Envoy Gateway and Nginx Ingress, we can't guarantee the compatibility with other Gateway API or Ingress implementations.

#### Ingress

Refer to [Ingress Setup]({{< relref "../../tutorials/ingress#setup" >}}) for more details.

#### Gateway API

Refer to [Gateway API Setup]({{< relref "../../tutorials/gatewayapi#setup" >}}) for more details.

### Certificate Management(Enterprise Edition)

Refer to [Certificate Management Setup]({{< relref "../../tutorials/security/cert-management#setup" >}}) for more details.

### DNS Management(Enterprise Edition)

Refer to [DNS Management Setup]({{< relref "../../tutorials/security/dns#setup" >}}) for more details.
