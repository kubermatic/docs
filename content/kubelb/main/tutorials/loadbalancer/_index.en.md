+++
title = "TCP/UDP Load Balancing"
linkTitle = "TCP/UDP Load Balancing"
date = 2023-10-27T10:07:15+02:00
weight = 3
+++

Set up Layer 4 (TCP/UDP) load balancing with KubeLB.

### Setup

For layer 4 load balancing, either the Kubernetes cluster should be on a cloud, using its CCM, that supports the `LoadBalancer` service type or a self-managed solution like [MetalLB](https://metallb.universe.tf) should be installed. [This guide](https://metallb.universe.tf/installation/#installation-with-helm) can be followed to install and configure MetalLB on the management cluster.

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

This configures an address pool `extern` with an IP range from 10.10.255.200 to 10.10.255.250. This IP range can be used by the tenant clusters to allocate IP addresses for the `LoadBalancer` service type. For more options, see the [MetalLB L2 configuration documentation](https://metallb.universe.tf/configuration/_advanced_l2_configuration/).

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

### Session Persistence

Set `sessionAffinity: ClientIP` on the Service in the tenant cluster to route requests from the same client IP to the same backend endpoint. The CCM translates this to `spec.persistence.type: SourceIP` on the LoadBalancer resource in the management cluster; when creating LoadBalancer resources directly, set the field yourself:

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: LoadBalancer
metadata:
  name: sticky
spec:
  persistence:
    type: SourceIP
```

{{% notice note %}}
Persistence is based on the source IP as observed by the KubeLB Envoy proxy. Behind a NAT gateway or another proxy, multiple clients can share one observed IP and will be pinned to the same endpoint.
{{% /notice %}}

### Hostname Endpoints

Endpoint addresses can reference a DNS hostname instead of an IP. This is useful when the backend has no stable IP. Envoy resolves the hostname continuously (strict DNS), so the endpoint follows DNS changes. If both `ip` and `hostname` are set, `ip` wins.

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: LoadBalancer
metadata:
  name: dns-backend
spec:
  endpoints:
    - addresses:
        - hostname: backend.internal.example.com
      ports:
        - port: 31632
          protocol: TCP
  ports:
    - port: 8080
      protocol: TCP
```

### Load Balancer Hostname Support

KubeLB supports assigning a hostname directly to the LoadBalancer resource. This is helpful for simpler configurations where no special routing rules are required for your Ingress or HTTPRoute resources.

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

### Per-Service Load Balancer Policy

{{% notice note %}}
Enterprise Edition only. Available from KubeLB v1.4.
{{% /notice %}}

Annotate a Service of `type: LoadBalancer` with `kubelb.k8c.io/lb-policy` to select the Envoy load balancing policy for just that service. The same annotation on an Ingress, Gateway, HTTPRoute, or GRPCRoute applies to the corresponding L7 Route.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: echo
  annotations:
    kubelb.k8c.io/lb-policy: LeastRequest
spec:
  type: LoadBalancer
  selector:
    app: echo
  ports:
    - port: 80
      targetPort: 8080
```

Valid values are `RoundRobin`, `LeastRequest`, and `Random`.

Precedence (highest first):

1. Per-resource annotation on the Service/Ingress/Gateway/HTTPRoute/GRPCRoute (`kubelb.k8c.io/lb-policy`)
2. Tenant `spec.loadBalancerPolicy`
3. Config `spec.loadBalancerPolicy`
4. Default: `RoundRobin`

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
