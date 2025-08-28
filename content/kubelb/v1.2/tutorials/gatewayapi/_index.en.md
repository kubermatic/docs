+++
title = "Gateway API"
linkTitle = "Gateway API"
date = 2023-10-27T10:07:15+02:00
weight = 4
+++

This tutorial will guide you through the process of setting up Layer 7 load balancing with Gateway API.

Gateway API targets three personas:

1. Platform Provider: The Platform Provider is responsible for the overall environment that the cluster runs in, i.e. the cloud provider. The Platform Provider will interact with GatewayClass resources.
2. Platform Operator: The Platform Operator is responsible for overall cluster administration. They manage policies, network access, application permissions and will interact with Gateway resources.
3. Service Operator: The Service Operator is responsible for defining application configuration and service composition. They will interact with HTTPRoute and TLSRoute resources and other typical Kubernetes resources.

Further reading: <https://gateway-api.sigs.k8s.io/#personas>

In KubeLB, we treat the admins of management cluster as the Platform provider. Hence, they are responsible for creating the `GatewayClass` resource. Tenants are the Service Operators. For Platform Operator, this role could vary based on your configurations for the management cluster. In Enterprise edition, users can set the limit of Gateways to 0 to shift the role of "Platform Operator" to the "Platform Provider". In other case, by default, the Platform Operator role is assigned to the tenants.

### Setup

Kubermatic's default recommendation is to use Gateway API and use [Envoy Gateway](https://gateway.envoyproxy.io/) as the Gateway API implementation. Install Envoy Gateway by following this [guide](https://gateway.envoyproxy.io/docs/install/install-helm/) or any other Gateway API implementation of your choice.

Update values.yaml for KubeLB manager chart to enable the Gateway API addon.

```yaml
kubelb:
  enableGatewayAPI: true

## Addon configuration
kubelb-addons:
  enabled: true
  # Create the GatewayClass resource in the management cluster.
  gatewayClass:
    create: true

  envoy-gateway:
    enabled: true
```

#### KubeLB Manager Configuration

Update the KubeLB Manager configuration to use the Gateway Class name as `eg` either at a Global or Tenant level:

#### Global

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: Config
metadata:
  name: default
  namespace: kubelb
spec:
  gatewayAPI:
    # Name of the Gateway Class.
    class: "eg"
```

#### Tenant

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: Tenant
metadata:
  name: shroud
spec:
  gatewayAPI:
    # Name of the Gateway Class.
    class: "eg"
```

**Leave it empty if you named your Gateway Class as `kubelb`**

### Usage with KubeLB

#### Gateway resource

Once you have created the GatewayClass, the next resource that is required is the Gateway. For CE version, the Gateway needs to be created in the tenant cluster. However, in Enterprise edition, the Gateway can exist in the management cluster or the tenant cluster.  In Enterprise edition, users can set the limit of Gateways to 0 to shift the role of "Platform Operator" to the "Platform Provider". Otherwise, by default, the Platform Operator role is assigned to the tenants.

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: kubelb
spec:
  gatewayClassName: kubelb
  listeners:
    - name: http
      protocol: HTTP
      port: 80
```

It is recommended to create the Gateway in tenant cluster directly since the Gateway Object needs to be modified regularly to attach new routes etc. In cases where the Gateway exists in management cluster, set the `use-gateway-class` argument for CCM to false.

{{% notice warning %}}
Community Edition only one gateway is allowed per tenant and that has to be named `kubelb`.
{{% /notice %}}

#### HTTPRoute resource

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: backend
---
apiVersion: v1
kind: Service
metadata:
  name: backend
  labels:
    app: backend
    service: backend
spec:
  ports:
    - name: http
      port: 3000
      targetPort: 3000
  selector:
    app: backend
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: backend
      version: v1
  template:
    metadata:
      labels:
        app: backend
        version: v1
    spec:
      serviceAccountName: backend
      containers:
        - image: gcr.io/k8s-staging-gateway-api/echo-basic:v20231214-v1.0.0-140-gf544a46e
          imagePullPolicy: IfNotPresent
          name: backend
          ports:
            - containerPort: 3000
          env:
            - name: POD_NAME
              valueFrom:
                fieldRef:
                  fieldPath: metadata.name
            - name: NAMESPACE
              valueFrom:
                fieldRef:
                  fieldPath: metadata.namespace
---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: backend
spec:
  parentRefs:
    - name: kubelb
  hostnames:
    - "www.example.com"
  rules:
    - backendRefs:
        - group: ""
          kind: Service
          name: backend
          port: 3000
          weight: 1
      matches:
        - path:
            type: PathPrefix
            value: /
```

### Support

The following resources are supported in CE and EE version:

- Community Edition:
  - HTTPRoute
  - GRPCRoute
- Enterprise Edition:
  - HTTPRoute
  - GRPCRoute
  - TCPRoute
  - UDPRoute
  - TLSRoute

**For more details on how to use them and example, please refer to examples from [Envoy Gateway Documentation](https://gateway.envoyproxy.io/docs/tasks/)**

### Limitations

- ReferenceGrants, BackendTLSPolicy are not supported in KubeLB, yet.
