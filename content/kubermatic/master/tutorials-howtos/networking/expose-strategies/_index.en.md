+++
title = "Control Plane Expose Strategy"
date = 2020-02-14T12:07:15+02:00
weight = 70
enableToc = true
+++

## Expose Strategies
This chapter describes the control plane expose strategies in the Kubermatic Kubernetes Platform (KKP).
The expose strategy defines how the control plane components (e.g. Kubernetes API server) are exposed
outside the seed cluster - to the worker nodes and the actual cluster users.

The expose strategies rely on a component called nodeport-proxy. It is a L4 service proxy based on Envoy,
capable of routing the traffic based on TCP destination port, SNI or HTTP/2 tunnels, depending on which expose strategy is used.

There are 3 different expose strategies in KKP: `NodePort`, `LoadBalancer` and `Tunneling`.
Different user clusters in KKP may be using different expose strategies at the same time.

### NodePort
NodePort is the default expose strategy in KKP. With this strategy a k8s service of type NodePort is created for each
exposed component (e.g. Kubernetes API Server) of each user cluster. Each cluster normally consumes 2 NodePorts,
which limits the number of total clusters per Seed based on the NodePort range configured in the Seed cluster.

By default, the nodeport-proxy is enabled for this expose strategy. If services of type LoadBalancer are
available in the Seed, all the services of all user clusters will be made available through a single LoadBalancer
service in front of the nodeport-proxy. This approach however has a limitation on sme cloud platforms, where the
number of listeners per load balancer is limited, which can limit the total number of user clusters per Seed even more.
[The nodeport-proxy can be disabled](#disabling-nodeport-proxy-for-the-nodeport-expose-strategy)
if your platform doesn't support LoadBalancer services or if the front LoadBalancer service is not required.

### LoadBalancer
In the LoadBalancer expose strategy, a dedicated service of type LoadBalancer will be created for each user cluster.
This strategy requires services of type LoadBalancer to be available on the Seed cluster and usually results into higher cost of cloud resources.
However, this expose strategy supports more user clusters per Seed, and provides better ingress traffic isolation per user cluster.

### Tunneling (Alpha)
The Tunneling expose strategy addresses both the scaling issues of the NodePort strategy and cost issues of the LoadBalancer strategy.
With this strategy, the traffic is routed to the based on a combination of SNI and HTTP/2 tunnels by the nodeport-proxy.
This expose strategy is still in alpha stage and to use it,
it first needs to be enabled [via a feature gate](#enabling-the-tunneling-expose-strategy-alpha).

## Configuring the Expose Strategy
The expose startegy can be configured at 3 levels:

 - globally,
 - on Seed level,
 - on User Cluster level.

Seed level configuration overrides the global one, and user cluster level configuration overrides both.

### Global Configuration
The expose strategy can be configured globally with the `KubermaticConfiguration` as follows:

```yaml
apiVersion: kubermatic.k8c.io/v1
kind: KubermaticConfiguration
metadata:
  name: kubermatic
  namespace: kubermatic
spec:
  exposeStrategy: NodePort
```

The valid values for the `exposeStrategy` are `NodePort` / `LoadBalancer` / `Tunneling`.

**NOTE:** If the `exposeStrategy` is not specified in the `KubermaticConfiguration`, it would default to `NodePort`.

### Seed Level Configuration
The expose strategy can be overridden at Seed level in the `Seed` CR, e.g.:

```yaml
apiVersion: kubermatic.k8c.io/v1
kind: Seed
metadata:
  name: kubermatic
  namespace: kubermatic
spec:
  # Override the global expose strategy with 'LoadBalancer'
  exposeStrategy: LoadBalancer
```

### User Cluster Level Configuration
The expose strategy can be also overridden on the user cluster level. To do that, configure the
desired expose strategy in cluster's `spec.exposeStrategy` in the cluster API, for example:

```yaml
apiVersion: kubermatic.k8c.io/v1
kind: Cluster
metadata:
  name: clustername
spec:
  # Override the expose strategy for this cluster only
  exposeStrategy: Tunneling
```

### Disabling Nodeport-Proxy for the NodePort Expose Strategy

By default, the nodeport-proxy is enabled when using the `NodePort` expose strategy.
If services of type LoadBalancer are available in the Seed, all the services of all user clusters will be made
available through a single LoadBalancer service in front of the nodeport-proxy.
The nodeport-proxy can be disabled if your platform doesn’t support LoadBalancer services or if the front LoadBalancer service is not required.

If nodeport-proxy is disabled, the DNS entries for the Seed cluster need to point directly to the Seed cluster's node IPs.
Note that this approach has limitations in case of Seed cluster node failures and DNS entries need
to be manually re-configured upon Seed cluster node rotation.

The nodeport-proxy can be disabled at the Seed level, as shown on the following example:

```yaml
apiVersion: kubermatic.k8c.io/v1
kind: Seed
metadata:
  name: kubermatic
  namespace: kubermatic
spec:
  # Configure the expose strategy to NodePort and disable the nodeport-proxy
  exposeStrategy: NodePort
  nodeportProxy:
    disable: true
```

### Enabling the Tunneling Expose Strategy (Alpha)

This strategy is available as a tech preview and is still in alpha stage.

In order to enable this strategy the `TunnelingExposeStrategy` feature gate
should be enabled:

```yaml
apiVersion: kubermatic.k8c.io/v1
kind: KubermaticConfiguration
metadata:
  name: kubermatic
  namespace: kubermatic
spec:
  exposeStrategy: Tunneling
  featureGates:
    TunnelingExposeStrategy: true
```

The current limitations of this strategy are:

* Not supported yet in set-ups where the worker nodes should pass from a
  corporate proxy (HTTPS proxy) to reach the control plane.
* An agent is deployed on each worker node to provide access to control plane
  components. It binds to the IP advertised by the Kubernetes API Server, which
  is currently hardcoded to `192.168.30.10`.

## Migrating the Expose Strategy for Existing Clusters
TODO
