+++
title = "Install KubeLB Manager and set up the management cluster"
linkTitle = "Set Up Management Cluster"
date = 2023-10-27T10:07:15+02:00
weight = 10
+++

## Prerequisites

* Service type `LoadBalancer` implementation. This can be a cloud solution or a self-managed implementation like [MetalLB](https://metallb.universe.tf).
* Network access to the tenant cluster nodes with node port range (default: 30000-32767). This is required for the envoy proxy to be able to connect to the tenant cluster nodes. With the mTLS backend transport mode (Enterprise Edition), the proxies instead connect to the tenant proxy on its NodePort, or on the fixed port 15443 when it is exposed through a LoadBalancer service.

See [Requirements]({{< relref "../requirements" >}}) for the full port and resource sizing reference.

## Install KubeLB Manager

{{% notice warning %}} If you enable Gateway API support, install its CRDs first and set `kubelb.enableGatewayAPI` to `true` in `values.yaml`. Without the CRDs, KubeLB Manager cannot start. {{% /notice %}}

{{< tabs name="KubeLB Manager" >}}
{{% tab name="Enterprise Edition" %}}

### Prerequisites

* Create a `kubelb` namespace for KubeLB Manager.
* Create the required `imagePullSecrets` in that namespace so the chart can pull Enterprise Edition images.

A minimal `values.yaml` looks like this:

```yaml
imagePullSecrets:
  - name: <imagePullSecretName>
```

### Install the Helm chart

```sh
helm pull oci://quay.io/kubermatic/helm-charts/kubelb-manager-ee --version=v1.5.0 --untardir "." --untar
## Apply CRDs
kubectl apply -f kubelb-manager-ee/crds/
## Create and update values.yaml with the required values.
helm upgrade --install kubelb-manager kubelb-manager-ee --namespace kubelb -f kubelb-manager-ee/values.yaml --create-namespace
```

{{% notice warning %}}
Helm applies a chart's `crds/` directory only on `helm install` and silently skips it on `helm upgrade`. This applies to the addon subcharts too, so the Gateway API, Envoy Gateway and External DNS CRDs are never updated by Helm. Re-apply the CRDs on every upgrade — see [Upgrading KubeLB]({{< relref "../upgrade" >}}).
{{% /notice %}}

### KubeLB Manager EE Values

<!-- helm-values-kubelb-manager-ee start -->

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
| global.imagePullSecrets | list | `[]` | Global image pull secrets propagated to all pod specs. Used for private mirror registries. |
| global.imageRegistry | string | `""` | Override the registry for all images (prefix replacement). Example: "registry.customer.internal" rewrites quay.io/foo/bar to registry.customer.internal/foo/bar |
| grafana.dashboards.annotations | object | `{}` | Additional annotations for dashboard ConfigMaps |
| grafana.dashboards.enabled | bool | `false` | Requires grafana to be deployed with `sidecar.dashboards.enabled=true`. For more info: https://github.com/grafana/helm-charts/tree/grafana-10.5.13/charts/grafana#:~:text=%5B%5D-,sidecar.dashboards.enabled,-Enables%20the%20cluster |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"quay.io/kubermatic/kubelb-manager-ee"` |  |
| image.tag | string | `"v1.5.0"` |  |
| imagePullSecrets[0].name | string | `"kubermatic-quay.io"` |  |
| kkpintegration.rbac | bool | `false` | Create RBAC for KKP integration. |
| kubeRbacProxy.image.pullPolicy | string | `"IfNotPresent"` |  |
| kubeRbacProxy.image.repository | string | `"quay.io/brancz/kube-rbac-proxy"` |  |
| kubeRbacProxy.image.tag | string | `"v0.20.1"` |  |
| kubelb.backendTransport.mode | string | `"Direct"` | Backend transport mode for management-to-tenant backend traffic. Direct preserves current behavior. MTLS enables KubeLB-managed tenant Envoy mTLS topology for L7 and L4 TCP. [Beta / Technical Preview Feature] |
| kubelb.backendTransport.tenantProxy.replicas | int | `2` | Number of tenant proxy pods when workload is Deployment. Ignored for DaemonSet. |
| kubelb.backendTransport.tenantProxy.serviceType | string | `"NodePort"` | Service type used to expose the tenant proxy in MTLS mode. NodePort (default) publishes node addresses plus the allocated NodePort; LoadBalancer publishes the Service's LB ingress addresses on the fixed proxy port 15443. |
| kubelb.backendTransport.tenantProxy.workload | string | `"DaemonSet"` | Workload kind for the tenant proxy in MTLS mode. DaemonSet (default) runs one proxy per node; Deployment runs a fixed replica count and only proxy-bearing node addresses are published. |
| kubelb.backendTransport.udp.mode | string | `"Tunnel"` | UDP transport in MTLS mode. Tunnel (default) wraps UDP sessions in CONNECT-UDP over the encrypted tenant proxy port; Direct keeps UDP on plain per-service NodePorts (unencrypted escape hatch). |
| kubelb.debug | bool | `true` |  |
| kubelb.deniedAnnotations | list | `[]` | Annotation key patterns to exclude from propagation. Patterns support shell-style globbing. Deny rules always take precedence over PropagatedAnnotations and PropagateAllAnnotations. |
| kubelb.disableEnvoyGatewayFeatures | bool | `false` | disableEnvoyGatewayFeatures disables Envoy Gateway support for BackendTrafficPolicy and ClientTrafficPolicy. Use this if you're using a Gateway API implementation other than Envoy Gateway. |
| kubelb.enableGatewayAPI | bool | `false` | enableGatewayAPI specifies whether to enable the Gateway API and Gateway Controllers. By default Gateway API is disabled since without Gateway APIs installed the controller cannot start. |
| kubelb.enableInsights | bool | `true` | enableInsights enables the KubeLB insights engine, which periodically evaluates the management cluster against the check registry and records findings as Insight resources. Checks whose feature is disabled are skipped, so a default installation evaluates only what applies to it. |
| kubelb.enableLeaderElection | bool | `true` |  |
| kubelb.enableWAF | bool | `false` | [Beta Feature] enableWAF enables the WAF controller for Web Application Firewall policy validation. WAF is a beta feature and is disabled by default. |
| kubelb.envoyProxy.affinity | object | `{}` |  |
| kubelb.envoyProxy.gracefulShutdown.disabled | bool | `false` | Disable graceful shutdown (default: false) |
| kubelb.envoyProxy.gracefulShutdown.shutdownManagerImage | string | `""` | Shutdown manager sidecar image. If empty, defaults to docker.io/envoyproxy/gateway:v1.3.0 |
| kubelb.envoyProxy.image | string | `""` | Envoy Proxy container image. If empty, defaults to envoyproxy/envoy:distroless-v1.36.4 |
| kubelb.envoyProxy.imagePullSecrets | list | `[]` | imagePullSecrets for Envoy Proxy pods. If not set, auto-detected from manager pod. |
| kubelb.envoyProxy.nodeSelector | object | `{}` |  |
| kubelb.envoyProxy.podMonitor.enabled | bool | `false` | Create PodMonitor resources for Envoy Proxy pods to enable Prometheus Operator scraping. |
| kubelb.envoyProxy.replicas | int | `2` | The number of replicas for the Envoy Proxy deployment. |
| kubelb.envoyProxy.resources | object | `{}` | Resource requests/limits for the Envoy Proxy container. If empty, defaults to requests 200m CPU / 256Mi memory and limits 2 CPU / 1Gi memory. |
| kubelb.envoyProxy.singlePodPerNode | bool | `true` | Deploy single pod per node. |
| kubelb.envoyProxy.tolerations | list | `[]` |  |
| kubelb.envoyProxy.topology | string | `"shared"` | Topology defines the deployment topology for Envoy Proxy. Only "shared" is supported. "dedicated" and "global" are deprecated and will default to shared. |
| kubelb.envoyProxy.useDaemonset | bool | `false` | Use DaemonSet for Envoy Proxy deployment instead of Deployment. |
| kubelb.insights.disabledChecks | list | `[]` | disabledChecks lists insight check IDs that must not run, for example ["KLB010"]. Rendered into the generated Config CR. |
| kubelb.insights.perFindingMetrics | bool | `false` | perFindingMetrics emits one kubelb_manager_insight_info time series per finding. Off by default: the affected object's name is an unbounded metric label. |
| kubelb.logLevel | string | `"info"` | To configure the verbosity of logging. Can be one of 'debug', 'info', 'error', 'panic' or any integer value > 0 which corresponds to custom debug levels of increasing verbosity. |
| kubelb.prometheus | object | `{}` | prometheus holds the Config spec.prometheus connection settings (url, bearerTokenSecretRef, caCertSecretRef, insecureSkipVerify) the manager reads metrics from. Rendered verbatim into the generated Config CR. |
| kubelb.propagateAllAnnotations | bool | `false` | Propagate all annotations from the source resource to load balancing resources. DeniedAnnotations still applies. |
| kubelb.propagatedAnnotations | object | `{}` | Allowed annotation key patterns to propagate from the source resource to load balancing resources. Keys support shell-style globbing (e.g. "nginx.ingress.kubernetes.io/*"). Empty value means any value. |
| kubelb.skipConfigGeneration | bool | `true` | Set to false to enable the generation of the Config CR. Set to true to skip the generation of the Config CR. Useful when the config CR needs to be managed manually. |
| kubelb.timeouts | object | `{}` | Default Envoy timeouts. Optional fields: request, streamIdle, requestHeaders, idleConnection, tcpIdle, connect. Tenant and Route/LoadBalancer overrides take precedence per-field. Built-in defaults apply when unset (request 0s/disabled, streamIdle 1h, requestHeaders 0s/disabled, idleConnection 1h, tcpIdle 1h, connect 5s). |
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
| kubelb.waf.wasmInitContainerImage | string | `""` | WASM init container image. If empty, defaults to the detected manager pod image. |
| metrics.port | int | `9443` | Port where the manager exposes metrics (includes both manager and envoycp metrics) |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` |  |
| podAnnotations | object | `{}` |  |
| podLabels | object | `{}` |  |
| podSecurityContext.runAsNonRoot | bool | `true` |  |
| podSecurityContext.seccompProfile.type | string | `"RuntimeDefault"` |  |
| priorityClassName | string | `""` | PriorityClassName for the manager pod (e.g., "system-cluster-critical") |
| prometheusRule.enabled | bool | `false` | Render a monitoring.coreos.com/v1 PrometheusRule with the bundled WAF alerts. |
| prometheusRule.labels | object | `{}` | Extra labels for the PrometheusRule, e.g. a `release` label matching the operator's ruleSelector. |
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
| testImage.repository | string | `"busybox"` |  |
| testImage.tag | string | `"1.35.0"` |  |
| tolerations | list | `[]` |  |
<!-- helm-values-kubelb-manager-ee end -->

{{% /tab %}}
{{% tab name="Community Edition" %}}

### Install the Helm chart

```sh
helm pull oci://quay.io/kubermatic/helm-charts/kubelb-manager --version=v1.5.0 --untardir "." --untar
## Apply CRDs
kubectl apply -f kubelb-manager/crds/
## Create and update values.yaml with the required values.
helm upgrade --install kubelb-manager kubelb-manager --namespace kubelb -f kubelb-manager/values.yaml --create-namespace
```

{{% notice warning %}}
Helm applies a chart's `crds/` directory only on `helm install` and silently skips it on `helm upgrade`. This applies to the addon subcharts too, so the Gateway API, Envoy Gateway and External DNS CRDs are never updated by Helm. Re-apply the CRDs on every upgrade — see [Upgrading KubeLB]({{< relref "../upgrade" >}}).
{{% /notice %}}

### KubeLB Manager CE Values

<!-- helm-values-kubelb-manager start -->

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
| grafana.dashboards.enabled | bool | `false` | Requires grafana to be deployed with `sidecar.dashboards.enabled=true`. For more info: https://github.com/grafana/helm-charts/tree/grafana-10.5.13/charts/grafana#:~:text=%5B%5D-,sidecar.dashboards.enabled,-Enables%20the%20cluster |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"quay.io/kubermatic/kubelb-manager"` |  |
| image.tag | string | `"v1.5.0"` |  |
| imagePullSecrets | list | `[]` |  |
| kkpintegration.rbac | bool | `false` | Create RBAC for KKP integration. |
| kubeRbacProxy.image.pullPolicy | string | `"IfNotPresent"` |  |
| kubeRbacProxy.image.repository | string | `"quay.io/brancz/kube-rbac-proxy"` |  |
| kubeRbacProxy.image.tag | string | `"v0.20.1"` |  |
| kubelb.debug | bool | `true` |  |
| kubelb.deniedAnnotations | list | `[]` | Annotation key patterns to exclude from propagation. Patterns support shell-style globbing. Deny rules always take precedence over PropagatedAnnotations and PropagateAllAnnotations. |
| kubelb.enableGatewayAPI | bool | `false` | enableGatewayAPI specifies whether to enable the Gateway API and Gateway Controllers. By default Gateway API is disabled since without Gateway APIs installed the controller cannot start. |
| kubelb.enableLeaderElection | bool | `true` |  |
| kubelb.envoyProxy.affinity | object | `{}` |  |
| kubelb.envoyProxy.gracefulShutdown.disabled | bool | `false` | Disable graceful shutdown (default: false) |
| kubelb.envoyProxy.nodeSelector | object | `{}` |  |
| kubelb.envoyProxy.podMonitor.enabled | bool | `false` | Create PodMonitor resources for Envoy Proxy pods to enable Prometheus Operator scraping. |
| kubelb.envoyProxy.replicas | int | `2` | The number of replicas for the Envoy Proxy deployment. |
| kubelb.envoyProxy.resources | object | `{}` | Resource requests/limits for the Envoy Proxy container. If empty, defaults to requests 200m CPU / 256Mi memory and limits 2 CPU / 1Gi memory. |
| kubelb.envoyProxy.singlePodPerNode | bool | `true` | Deploy single pod per node. |
| kubelb.envoyProxy.tolerations | list | `[]` |  |
| kubelb.envoyProxy.topology | string | `"shared"` | Topology defines the deployment topology for Envoy Proxy. Only "shared" is supported. "dedicated" and "global" are deprecated and will default to shared. |
| kubelb.envoyProxy.useDaemonset | bool | `false` | Use DaemonSet for Envoy Proxy deployment instead of Deployment. |
| kubelb.logLevel | string | `"info"` | To configure the verbosity of logging. Can be one of 'debug', 'info', 'error', 'panic' or any integer value > 0 which corresponds to custom debug levels of increasing verbosity. |
| kubelb.propagateAllAnnotations | bool | `false` | Propagate all annotations from the source resource to load balancing resources. DeniedAnnotations still applies. |
| kubelb.propagatedAnnotations | object | `{}` | Allowed annotation key patterns to propagate from the source resource to load balancing resources. Keys support shell-style globbing (e.g. "nginx.ingress.kubernetes.io/*"). Empty value means any value. |
| kubelb.skipConfigGeneration | bool | `true` | Set to false to enable the generation of the Config CR. Set to true to skip the generation of the Config CR. Useful when the config CR needs to be managed manually. |
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
<!-- helm-values-kubelb-manager end -->

{{% /tab %}}
{{< /tabs >}}

## Verify the installation

Check that the manager is running:

```bash
kubectl get pods -n kubelb
```

```text
NAME                              READY   STATUS    RESTARTS   AGE
kubelb-manager-6d95d7f45d-xz2lp   2/2     Running   0          1m
```

The `kubelb-manager` pod must be in `Running` state. Envoy proxy pods appear in the tenant namespaces later, once tenants are registered and load balancers are created.

## Set up the management cluster

{{% notice note %}}
The examples and tools shared below are for demonstration purposes, you can use any other tools or configurations as per your requirements.
{{% /notice %}}

The management cluster acts as the data plane and central control plane for all your load balancing configurations. All the components required for Layer 4 and Layer 7 load balancing, AI Gateways, MCP Gateways, Agent2Agent Gateways, API Gateways etc. are deployed here. The management cluster is multi-tenant and can serve a whole fleet of clusters.

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

  ## AI, MCP and Agent2Agent Gateways Integration
  agentgateway-crds:
    enabled: true

  agentgateway:
    enabled: true

```

### Custom Image Registry

The `kubelb-addons` chart honors `global.imageRegistry` and `global.imagePullSecrets` and propagates both to every addon subchart (ingress-nginx, envoy-gateway, cert-manager, external-dns, metallb, agentgateway). Set them on the top-level install to route all addon images through a private mirror and attach a pull secret, without editing each subchart's own values. See the [Air-Gap Installation]({{< relref "../air-gap" >}}) guide for the full end-to-end mirroring workflow; the same flags apply to non-airgap setups pulling from a company registry.

### Client Header Size Limits

Envoy rejects requests whose combined client headers exceed **60 KiB** with a `431 Request Header Fields Too Large` response. Workloads that carry large `Authorization`/JWT tokens, long cookies, or many tracing headers can hit this limit.

An L7 request passes through two Envoy hops: the Envoy Gateway edge proxy, and then KubeLB's own managed Envoy. Both must allow the larger headers, otherwise the request is rejected at whichever hop still enforces the 60 KiB default.

KubeLB's managed Envoy limits are set on the `Config` resource under `spec.envoyProxy.headerLimits`:

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: Config
metadata:
  name: default
  namespace: kubelb
spec:
  envoyProxy:
    headerLimits:
      # Max request header block size in KiB. Range (0, 8192]. Defaults to 8192.
      maxRequestHeadersKb: 8192
      # Max number of request headers. Defaults to 4096.
      maxRequestHeadersCount: 4096
      # Max upstream response header block size in KiB. Range (0, 8192]. Defaults to 8192.
      maxResponseHeadersKb: 8192
```

All three fields default to Envoy's maximum, so out of the box KubeLB's managed Envoy never rejects headers the edge already accepted. Lower them if you want the managed Envoy to enforce a smaller cap.

The Envoy Gateway edge is not managed by KubeLB. Raise its limit yourself on the `EnvoyProxy` resource that your `GatewayClass` references, for example with a bootstrap runtime layer:

```yaml
apiVersion: gateway.envoyproxy.io/v1alpha1
kind: EnvoyProxy
metadata:
  name: kubelb-proxy-config
  namespace: kubelb
spec:
  bootstrap:
    type: Merge
    value: |
      layered_runtime:
        layers:
        - name: header-limits
          static_layer:
            envoy.reloadable_features.max_request_headers_size_kb: 96
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
