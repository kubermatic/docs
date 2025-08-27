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
  name: extern
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

This will create a service of type `LoadBalancer` and a deployment. KubeLB CCM will then propagate the request to management cluster, create a LoadBalancer CR there and retrieve the IP address allocated in the management cluster. Eventually the IP address will be assigned to the service in the tenant cluster.

### Load Balancer Hostname Support

KubeLB now supports assigning a hostname directly to the LoadBalancer resource. This is helpful for simpler configurations where no special routing rules are required for your Ingress or HTTPRoute resources.

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: LoadBalancer
metadata:
  name: test-lb-hostname
  namespace: tenant-dkrqjswsgk
  annotations:
    kubelb.k8c.io/request-wildcard-domain: "true"
spec:
  # hostname: test.example.com
  endpoints:
    - addresses:
        - ip: 91.99.112.254
      ports:
        - name: 8080-tcp
          port: 31632
          protocol: TCP
  ports:
    - name: 8080-tcp
      port: 8080
      protocol: TCP
  type: ClusterIP
```

This will create a LoadBalancer resource with the hostname `test.example.com` that can forward traffic to the IP address `91.99.112.254` on port `31632`. The `kubelb.k8c.io/request-wildcard-domain: "true"` annotation is used to request a wildcard domain for the hostname. Otherwise `spec.hostname` can also be used to explicitly set the hostname.

Please take a look at [DNS Automation](../security/dns/#enable-dns-automation) for more details on how to configure DNS for the hostname.

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