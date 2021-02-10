+++
title = "Expose Strategy"
date = 2020-02-10T11:07:15+02:00
weight = 1
+++

# Overview

The expose strategy defines the entry point for the control plane of the user
clusters managed by Kubermatic Kubernetes Platform (KKP).

The kubelets of the worker nodes and the pods running on them will reach the
Kubernetes API Server (KAS) in different ways depending on the chosen expose
strategy.

The components that are exposed for each user cluster are:
* KAS: The Kubernetes API Server needs to be reachable from the kubelets and
  some pods (e.g. operators and controllers deployed on the user clusters).
* OpenVPN Server: It is used to establish secure communication channels from
  control plane network to node networks (e.g. KAS to Kubelet communication).

Currently, the supported expose strategies are:

* Nodeport
* Nodeport with Global LoadBalancer
* One LoadBalancer per User Cluster (KKP 2.11+)
* Tunneling (alpha KKP 2.16+)

## Nodeport

A `NodePort` will be created for every exposed service on the user cluster.
Clients will use the combination of the FQDN and the port to connect.

A wildcard DNS record (A record) should be created and maintained by the KKP
operator for each of the seed clusters, using the following pattern:

`*.<<seed-cluster-name>>.base.domain`

It must point to one or more of the seed cluster node IPs.

**Note** that as clients will target the seed nodes directly, the IPs used in the
DNS entries should be routable from the user cluster worker networks.

**Pros**
* Cost-effective, do not require any load balancer.

**Cons**
* Operational overhead (DNS administration).


## NodePort with Global LoadBalancer

An extension to the previous strategy that simplifies the operations is to use
one LoadBalancer per seed cluster. The routing to the right user cluster and
its exposed services is based on the port. Services of type Nodeport are used
to guarantee the uniqueness of the allocation.

When using this strategy the `NodeportProxy` will be deployed into the seed.
It will create a Kubernetes Service of type `LoadBalancer`. 

The advantage of this solution is that it uses a single point of entry.
The requirement in terms of DNS configuration is to setup a wildcard entry (A
or CNAME record) pointing to the static IPv4 address or FQDN associated to the
load balancer.

The DNS entry should follow this pattern:

`*.<<seed-cluster-name>>.base.domain`

`NodePortProxy` is composed by a set of Envoy proxies and a control plane to
configure them dynamically when clusters are added or removed, and when the
exposed service endpoints change (e.g. KAS pods are created or terminated).

The Envoy proxies are needed, because chaining Kubernetes services is not
allowed.

**Pros**
* Cost-effective, requires one single load balancer per seed cluster.

**Cons**
* Some load balancer implementations do not cope well with port ranges. e.g.
  in AWS Elastic Load Balancer a listener per port is required and the default
  quota is set to [50 listeners per load balancer][aws_elb_qotas], meaning that
  a maximum of 25 clusters can be exposed per seed with this strategy.


## One LoadBalancer per User Cluster (KKP 2.11+)

A third option is to create one load balancer per user cluster.

This will result in one service of type `LoadBalancer` per user cluster being
created. The `NodeportProxy` will be used in this strategy too, to avoid
creating a load balancer per exposed service.

This is simple to setup, but will result in one service of type `LoadBalancer` per cluster
KKP manages. This my result in additional charges by your cloud provider.

**Pros**
* Avoids problems with load balancers not supporting port ranges.
* Simple to configure, no DNS configuration is needed.

**Cons**
* Not very cost effective, one load balancer has to be created per each user
  cluster.


## Tunneling (alpha KKP 2.16+)

This strategy is based on a single load balancer, like the aforementioned
`NodePort with Global LoadBalancer` strategy. The main difference is that it is
not relying on Services of type `NodePort`. The traffic will be routed based on
SNI and based on tunneling techniques (e.g. HTTP/2 CONNECT).

The reasons why we cannot rely solely on SNI routing are two:
* Not all traffic is fully TLS compliant (i.e. OpenVPN protocol).
* Clients communicating with Kubernetes API Server from pods running on worker
  nodes rely by default on the `kubernetes` service in default namespace, using
  the ClusterIP. This means that no SNI information will be present in the
  `Client Hello` during the TLS handshake. 

The traffic that cannot be routed based on SNI will be tunneled trough agents
running on the user cluster worker nodes.

When using this strategy the `NodeportProxy` will be deployed into the seed
cluster. It will also create a Kubernetes Service of type `LoadBalancer`
pointing to it. 

The requirement in terms of DNS configuration is to setup a wildcard entry (A
or CNAME record) pointing to the static IPv4 address or FQDN associated to the
load balancer.

The DNS entry should follow this pattern:

`*.<<seed-cluster-name>>.base.domain`

**Pros**
* Avoids problems with load balancers not supporting port ranges.

**Cons**
* Cost-effective, requires one single load balancer per seed cluster.


[aws_elb_quotas]: https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-limits.html
