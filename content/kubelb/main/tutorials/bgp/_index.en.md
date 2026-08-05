+++
title = "Layer 4 Load Balancing with BGP"
linkTitle = "BGP"
date = 2025-08-27T10:07:15+02:00
description = "Advertise Layer 4 load balancer addresses with BGP by integrating KubeLB with MetalLB."
weight = 5
+++

In the management cluster, KubeLB offloads provisioning of the actual load balancers to the load balancing appliance in use. This can be the CCM in case of a cloud provider or a self-managed solution like [MetalLB](https://metallb.universe.tf), [Cilium Load Balancer](https://cilium.io/use-cases/load-balancer/) or any other solution.

KubeLB therefore works with any load balancing appliance, regardless of the route advertisement protocol it uses (BGP, OSPF, L2, etc.). This tutorial focuses on [BGP](https://networklessons.com/bgp/introduction-to-bgp) and assumes that the underlying infrastructure of your Kubernetes cluster is already configured to support it.

## Setup

We'll use [MetalLB](https://metallb.universe.tf) with BGP for this tutorial. Update `values.yaml` for KubeLB Manager to enable MetalLB:

```yaml
kubelb-addons:
  metallb:
    enabled: true
```

A minimal configuration for MetalLB for demonstration purposes is as follows:

```yaml
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: extern
  namespace: metallb-system
spec:
  addresses:
  - 10.10.255.200-10.10.255.250
  autoAssign: true
  avoidBuggyIPs: true
---
apiVersion: metallb.io/v1beta1
kind: BGPAdvertisement
metadata:
  name: extern
  namespace: metallb-system
spec:
  ipAddressPools:
  - extern
```

This creates an address pool `extern` covering 10.10.255.200 to 10.10.255.250, from which tenant clusters allocate IP addresses for `LoadBalancer` services.

Then follow the [Layer 4 Load balancing](../loadbalancer#usage-with-kubelb) tutorial to create a `LoadBalancer` service in the tenant cluster.

## Further Reading

- [MetalLB BGP Configuration](https://metallb.universe.tf/configuration/_advanced_bgp_configuration/)
- [MetalLB BGP Usage](https://metallb.universe.tf/usage/#bgp)
