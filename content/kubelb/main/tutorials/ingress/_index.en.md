+++
title = "Ingress"
linkTitle = "Ingress"
date = 2023-10-27T10:07:15+02:00
description = "Set up Layer 7 load balancing with Kubernetes Ingress and plan migration to Gateway API."
weight = 4
+++

Set up Layer 7 load balancing with Ingress.

{{% notice warning %}}
**ingress-nginx has been deprecated by the Kubernetes community and will not have any new releases after March 2026. We strongly encourage you to migrate to Gateway API as soon as possible.**

See the [Ingress to Gateway API Migration]({{< relref "../../ingress-to-gateway-api/" >}}) page for details.
{{% /notice %}}

Kubermatic's default recommendation is to use Gateway API with [Envoy Gateway](https://gateway.envoyproxy.io/) as the Gateway API implementation, and Gateway API features built into KubeLB are based on Envoy Gateway. This is not a strict binding; any Ingress or Gateway API implementation can be used. KubeLB supports only the native Kubernetes APIs, Ingress and Gateway API. Provider-specific APIs are not supported and are ignored.

Although KubeLB supports Ingress, use Gateway API instead where possible: Ingress is [feature frozen](https://kubernetes.io/docs/concepts/services-networking/ingress/#:~:text=Note%3A-,Ingress%20is%20frozen,-.%20New%20features%20are) in Kubernetes and new development happens in Gateway API. Gateway API is more flexible, has extensible APIs, and supports multi-tenancy by default; Ingress does not.

## Setup

There are two modes in which Ingress can be set up in the management cluster:

### Per tenant (Recommended)

Install your controller in the following way and scope it down to a specific namespace. This is the recommended approach as it allows you to have a single controller per tenant and the IP for ingress controller is not shared across tenants.

Install the **Ingress Controller** in the tenant namespace. Replace **TENANT_NAME** with the name of the tenant. This has to be unique to ensure that any cluster level resource that is installed, doesn't create a conflict with existing resources. Following example is for a tenant named `shroud`:

```sh
TENANT_NAME=shroud
TENANT_NAMESPACE=tenant-$TENANT_NAME

helm upgrade --install ingress-nginx-${TENANT_NAME} ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ${TENANT_NAMESPACE} \
  --create-namespace \
  --set controller.scope.enabled=true \
  --set controller.scope.namespace=${TENANT_NAMESPACE} \
  --set controller.ingressClassResource.name=nginx-${TENANT_NAME}
```

For details: <https://kubernetes.github.io/ingress-nginx/#how-to-easily-install-multiple-instances-of-the-ingress-nginx-controller-in-the-same-cluster>

The next step would be to configure the tenant to use the new ingress controller:

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: Tenant
metadata:
  name: ${TENANT_NAME}
spec:
  ingress:
    class: "nginx-${TENANT_NAME}"
```

### Shared

Update `values.yaml` for the KubeLB Manager chart to enable the ingress-nginx addon.

```yaml
kubelb-addons:
  enabled: true
  ingress-nginx:
    enabled: true
    controller:
      service:
        externalTrafficPolicy: Local
```

For details: <https://kubernetes.github.io/ingress-nginx/deploy>

## Usage with KubeLB

In the tenant cluster, create the following resources:

```yaml

apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: backend
spec:
  ingressClassName: kubelb
  rules:
      # Replace with your domain
    - host: "demo.example.com"
      http:
        paths:
          - path: /backend
            pathType: Exact
            backend:
              service:
                name: backend
                port:
                  number: 3000
---
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
  type: ClusterIP
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
```

This creates an Ingress resource, a service, and a deployment. KubeLB CCM creates a service of type `NodePort` against the service so the management cluster can reach it. The ingress class is `kubelb`; this is required for KubeLB to manage the Ingress resources and can be changed via the [configuration](#configurations) below.

## Configurations

Configure the CCM through the KubeLB CCM helm chart. Common options:

```yaml
kubelb:
  # Set to false to watch all resources irrespective of the Ingress class.
  useIngressClass: true
```
