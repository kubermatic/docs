+++
title = "Layer 4 Load balancing"
linkTitle = "Layer 4 Load balancing"
date = 2023-10-27T10:07:15+02:00
weight = 3
+++

This tutorial will guide you through the process of setting up a Layer 4 LoadBalancer using KubeLB.

### Setup

For layer 4 load balancing, either the kubernetes cluster should be on a cloud, using it's CCM, that supports the `LoadBalancer` service type or a self-managed solution like [MetalLB](https://metallb.universe.tf) should be installed. [This guide](https://metallb.universe.tf/installation/#installation-with-helm) can be followed to install and configure MetalLB on the management cluster.

A minimal configuration for MetalLB for demonstration purposes is as follows:

```yaml
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: extern
  namespace: metallb-system
spec:
  ipAddressPools:
    - extern
---
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: management-pool
  namespace: metallb-system
spec:
  addresses:
    - 10.10.255.200-10.10.255.250
```

This configures an address pool `extern` with an IP range from 10.10.255.200 to 10.10.255.250. This IP range can be used by the tenant clusters to allocate IP addresses for the `LoadBalancer` service type.

Further reading: <https://metallb.universe.tf/configuration/_advanced_l2_configuration/>

### Usage with KubeLB

In the tenant cluster, create a service of type `LoadBalancer` and a deployment:

```yaml
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
  type: LoadBalancer
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

This will create a service of type `LoadBalancer` and a deployment. KubeLB CCM will then propagate the request to mangement cluster, create a LoadBalancer CR there and retrieve the IP address allocated in the management cluster. Eventually the IP address will be assigned to the service in the tenant cluster.

### Configurations

KubeLB CCM helm chart can be used to further configure the CCM. Some essential options are:

```yaml
kubelb:
  # Use ExternalIP or InternalIP in the management cluster to route traffic back to the node ports of the tenant cluster.
  nodeAddressType: ExternalIP
  # This can be enabled to use KubeLB in a cluster where another load balancer provider is already running. When enabled, kubeLB will only manage
  # services of type LoadBalancer that are using the `kubelb` LoadBalancerClass.
  useLoadBalancerClass: false
```
