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
helm pull oci://quay.io/kubermatic/helm-charts/kubelb-manager-ee --version=v1.4.3 --untardir "." --untar
## Apply CRDs
kubectl apply -f kubelb-manager-ee/crds/
## Create and update values.yaml with the required values.
helm upgrade --install kubelb-manager kubelb-manager-ee --namespace kubelb -f kubelb-manager-ee/values.yaml --create-namespace
```

### Review KubeLB Manager EE values

<!-- helm-values-kubelb-manager-ee start -->
The chart publishes the complete, version-matched configuration reference. Inspect it directly instead of relying on a copied values table:

```sh
helm show values oci://quay.io/kubermatic/helm-charts/kubelb-manager-ee --version=v1.4.3
helm show readme oci://quay.io/kubermatic/helm-charts/kubelb-manager-ee --version=v1.4.3
```
<!-- helm-values-kubelb-manager-ee end -->

{{% /tab %}}
{{% tab name="Community Edition" %}}

### Install the Helm chart

```sh
helm pull oci://quay.io/kubermatic/helm-charts/kubelb-manager --version=v1.4.3 --untardir "." --untar
## Apply CRDs
kubectl apply -f kubelb-manager/crds/
## Create and update values.yaml with the required values.
helm upgrade --install kubelb-manager kubelb-manager --namespace kubelb -f kubelb-manager/values.yaml --create-namespace
```

### Review KubeLB Manager CE values

<!-- helm-values-kubelb-manager start -->
The chart publishes the complete, version-matched configuration reference. Inspect it directly instead of relying on a copied values table:

```sh
helm show values oci://quay.io/kubermatic/helm-charts/kubelb-manager --version=v1.4.3
helm show readme oci://quay.io/kubermatic/helm-charts/kubelb-manager --version=v1.4.3
```

You can also browse the [v1.4.3 Community Edition chart reference](https://github.com/kubermatic/kubelb/blob/v1.4.3/charts/kubelb-manager/README.md#values).
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
