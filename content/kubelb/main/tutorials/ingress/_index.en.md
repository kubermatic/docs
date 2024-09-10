+++
title = "Ingress"
linkTitle = "Ingress"
date = 2023-10-27T10:07:15+02:00
weight = 4
+++

This tutorial will guide you through the process of setting up Layer 7 load balancing with Ingress.

Kubermatic's default recommendation is to use Gateway API and use [Envoy Gateway](https://gateway.envoyproxy.io/) as the Gateway API implementation. The features specific to Gateway API that will be built and consumed in KubeLB will be based on Envoy Gateway. Although this is not a strict binding and our consumers are free to use any Ingress or Gateway API implementation. The only limitation is that we only support native Kubernetes APIs i.e. Ingress and Gateway APIs. Provider specific APIs are not supported by KubeLB and will be completely ignored.

Although KubeLB supports Ingress, we strongly encourage you to use Gateway API instead as Ingress has been [feature frozen](https://kubernetes.io/docs/concepts/services-networking/ingress/#:~:text=Note%3A-,Ingress%20is%20frozen,-.%20New%20features%20are) in Kubernetes and all new development is happening in the Gateway API space. The biggest advantage of Gateway API is that it is a more flexible, has extensible APIs and is **multi-tenant compliant** by default. Ingress doesn't support multi-tenancy.

### Setup

There are two modes in which Ingress can be setup in the management cluster:

#### Per tenant(Recommended)

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

#### Shared

Install your controller with default configuration.

```sh
helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx --create-namespace
```

For details: <https://kubernetes.github.io/ingress-nginx/deploy>

### Usage with KubeLB

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

This will create an Ingress resource, a service and a deployment. KubeLB CCM will create a service of type `NodePort` against your service to ensure connectivity from the management cluster. Note that the class for ingress is `kubelb`, this is required for KubeLB to manage the Ingress resources. This behavior can be changed however by following the [Ingress configuration](#configurations).

### Configurations

KubeLB CCM helm chart can be used to further configure the CCM. Some essential options are:

```yaml
kubelb:
  # Set to false to watch all resources irrespective of the Ingress class.
  useIngressClass: true
```
