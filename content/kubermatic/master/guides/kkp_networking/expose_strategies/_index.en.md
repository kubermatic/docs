+++
title = "Expose Strategy"
date = 2020-02-14T12:07:15+02:00
weight = 70

+++

This chapter describes how to configure the expose strategy when setting up a Kubermatic Kubernetes Platform (KKP).
The expose strategy defines how the control plane components are exposed
outside the seed cluster.

The expose strategies rely on a component called `nodeport-proxy`. It is
basically a L4 service proxy (TCP only is supported at the moment), capable of
routing the traffic based on:

* Destination port: this requires a unique port for each service.
* SNI: TLS traffic can be routed based on SNI without termination.
* HTTP/2 tunnel: Terminate HTTP/2 CONNECT request and multiplex the TCP
  streams.
  

## Configure the Expose Strategy

The expose strategy can be configured globally with the `KubermaticConfiguration` as follow:

```yaml
apiVersion: operator.kubermatic.io/v1alpha1
kind: KubermaticConfiguration
metadata:
  name: kubermatic
  namespace: kubermatic
spec:
  exposeStrategy: NodePort
  featureGates:
    TunnelingExposeStrategy: {}
``` 

The valid values for `exposeStrategy` are:

* `NodePort`: With this strategy a service of type nodeport is created for each
  exposed component (e.g. Kubernetes API Server). If services of type
  `LoadBalancer` are available all the services will be made available through
  a single load balancer, passing from the `nodeport-proxy`. 
* `LoadBalancer`: A service of type `LoadBalancer` will be created for each user cluster.
  This strategy requires services of type `LoadBalancer` to be available on the seed
  clusters.
* `Tunneling`: (alpha) With this strategy the traffic is routed to the based on
  a combination of SNI and HTTP/2 tunnels by the `nodeport-proxy`.

Alternatively, the expose strategy can be overridden at `Seed` level, meaning
that it is possible to have different expose strategies on the same KKP
cluster. e.g.

```yaml
apiVersion: kubermatic.k8s.io/v1
kind: Seed
metadata:
  name: kubermatic
  namespace: kubermatic
spec:
  # these two fields are only informational
  country: FR
  location: Paris

  # List of datacenters where this seed cluster is allowed to create clusters in
  # In this example, user cluster will be deployed in eu-central-1 on AWS.
  datacenters:
    aws-eu-central-1:
      country: DE
      location: EU (Frankfurt)
      spec:
        aws:
          images: null
          region: eu-central-1
        enforceAuditLogging: false
        enforcePodSecurityPolicy: false

  # Override the default expose strategy with 'LoadBalancer'
  expose_strategy: LoadBalancer
  # reference to the kubeconfig to use when connecting to this seed cluster
  kubeconfig:
    name: kubeconfig-cluster-example
    namespace: kubermatic
```

### Configuring Tunneling Expose Strategy (alpha)

This strategy is available starting from KKP 2.16 as a tech preview.

In order to enable this strategy the `TunnelingExposeStrategy` feature gate
should be enabled.

```yaml
apiVersion: operator.kubermatic.io/v1alpha1
kind: KubermaticConfiguration
metadata:
  name: kubermatic
  namespace: kubermatic
spec:
  exposeStrategy: Tunneling
  featureGates:
    TunnelingExposeStrategy: {}
```

The current limitations of this strategy are:

* Not supported yet in set-ups where the worker nodes should pass from a
  corporate proxy (HTTPS proxy) to reach the control plane.
* An agent is deployed on each worker node to provide access to control plane
  components. It binds to the IP advertised by the Kubernetes API Server, which
  is currently hardcoded to `192.168.30.10`.
