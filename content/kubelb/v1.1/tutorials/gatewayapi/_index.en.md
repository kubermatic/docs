+++
title = "Gateway API"
linkTitle = "Gateway API"
date = 2023-10-27T10:07:15+02:00
weight = 5
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

Ensure that `GatewayClass` exists in the management cluster. A minimal configuration for GatewayClass is as follows:

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: eg
spec:
  controllerName: gateway.envoyproxy.io/gatewayclass-controller
```

### Usage with KubeLB

#### Gateway resource

Once you have created the GatewayClass, the next resource that is required is the Gateway.  In Enterprise edition, users can set the limit of Gateways to 0 to shift the role of "Platform Operator" to the "Platform Provider". In other case, by default, the Platform Operator role is assigned to the tenants. By setting the limit to 0, Gateways are supposed to be created in the management cluster by the Platform Provider. Otherwise this resource below should be created by the tenants.

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

If created in the management cluster directly then the `gatewayClassName` should be set to the gateway class configured in the management cluster. When created in tenant cluster since the decision of the gateway class is made by the management cluster, the `gatewayClassName` should be set to `kubelb`.

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
