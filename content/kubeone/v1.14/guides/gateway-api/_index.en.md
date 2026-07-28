+++
title = "Gateway API"
date = 2026-05-08T12:00:00+02:00
+++

# Enabling Gateway API with Cilium in KubeOne

## Overview

[Gateway API](https://gateway-api.sigs.k8s.io/) is a Kubernetes-native API for managing network traffic routing. It
provides a more expressive, extensible, and role-oriented approach compared to the Ingress API. Cilium integrates
natively with Gateway API, allowing you to leverage eBPF-powered data plane for gateway traffic.

KubeOne supports enabling Gateway API for clusters using the Cilium CNI plugin via the `enableGatewayAPI` field in the
KubeOne configuration manifest.

## Prerequisites

- KubeOne v1.14 or later
- Cilium selected as the CNI plugin
- Cilium must be configured with the kube-proxy replacement
- Gateway API CRDs installed on the cluster (see [Installing Gateway API CRDs](#installing-gateway-api-crds))

## Configuration

To enable Gateway API support in Cilium, set the `enableGatewayAPI` field to `true` under the Cilium CNI configuration in your KubeOne manifest:

```yaml
apiVersion: kubeone.k8c.io/v1beta2
kind: KubeOneCluster
name: example

clusterNetwork:
  cni:
    cilium:
      enableGatewayAPI: true
```

This sets `enable-gateway-api: "true"` in the Cilium ConfigMap, which activates Cilium's built-in Gateway API controller.

### Full Example

A more complete example combining Gateway API with other Cilium features:

```yaml
apiVersion: kubeone.k8c.io/v1beta2
kind: KubeOneCluster
name: example

versions:
  kubernetes: "v1.32.0"

clusterNetwork:
  podSubnet: "10.244.0.0/16"
  serviceSubnet: "10.96.0.0/12"
  cni:
    cilium:
      enableGatewayAPI: true
      enableHubble: true
      kubeProxyReplacement: true
```

## Installing Gateway API CRDs

Gateway API CRDs must be installed on the cluster before or alongside enabling the feature in Cilium. You can install them using a KubeOne addon or manually.

### Using kubectl

Install all standard CRDs at once:

```bash
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.5.1/standard-install.yaml
```

### Using a KubeOne Addon

Create an addon that installs Gateway API CRDs automatically during cluster provisioning. Place the CRD manifests in your addons directory:

```yaml
# kubeone.yaml
apiVersion: kubeone.k8c.io/v1beta2
kind: KubeOneCluster
name: example

clusterNetwork:
  cni:
    cilium:
      enableGatewayAPI: true
      kubeProxyReplacement: true

addons:
  enable: true
  path: "./addons"
```

## Verifying the Configuration

After applying the configuration, verify that Gateway API is enabled in Cilium:

```bash
# Check the Cilium ConfigMap
kubectl -n kube-system get configmap cilium-config -o yaml | grep enable-gateway-api

# Check Cilium status
kubectl -n kube-system exec ds/cilium -- cilium-dbg status | grep GatewayAPI
```

## Creating a Gateway

Once Gateway API is enabled, you can create `GatewayClass` and `Gateway` resources:

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: cilium
spec:
  controllerName: io.cilium/gateway-controller
---
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: my-gateway
  namespace: default
spec:
  gatewayClassName: cilium
  listeners:
    - name: http
      protocol: HTTP
      port: 80
---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: my-route
  namespace: default
spec:
  parentRefs:
    - name: my-gateway
  rules:
    - matches:
        - path:
            type: PathPrefix
            value: /
      backendRefs:
        - name: my-service
          port: 80
```

## API Reference

The `enableGatewayAPI` field is part of the `CiliumSpec` struct:

| Field | Description | Type | Default |
|-------|-------------|------|---------|
| `kubeProxyReplacement` | Enables eBPF-based kube-proxy replacement | `bool` | `false` |
| `enableHubble` | Deploys Hubble relay and UI | `bool` | `false` |
| `enableL2Announcements` | Enables Layer 2 announcement feature | `bool` | `false` |
| `enableGatewayAPI` | Enables Gateway API support in Cilium | `bool` | `false` |

See the full [v1beta2 API reference][v1beta2-apidoc] for details.

## References

- [Cilium Gateway API documentation](https://docs.cilium.io/en/stable/network/servicemesh/gateway-api/gateway-api/)
- [Kubernetes Gateway API specification](https://gateway-api.sigs.k8s.io/)
- [KubeOne issue #4065](https://github.com/kubermatic/kubeone/issues/4065)

[v1beta2-apidoc]: {{< ref "../../references/kubeone-cluster-v1beta2#ciliumspec" >}}
