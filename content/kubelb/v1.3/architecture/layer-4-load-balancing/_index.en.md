+++
title = "Layer 4 Load Balancing"
date = 2023-10-27T10:07:15+02:00
weight = 5
+++

This document explains the architecture for Layer 4 or TCP/UDP Load Balancing support in KubeLB. This feature is used to provision LoadBalancers for a fleet of clusters(tenants) from a centralized platform.

## Background

Kubernetes does not offer an out of the box implementation of load-balancers for clusters. The Network & Application level load balancing is delegated to the IaaS platform(GCP, AWS, Azure, etc.). If you're using a cloud provider that doesn't offer load balancing capabilities then you can't provision services of type `LoadBalancer`.

Solutions which are available e.g. MetalLB focus on a single cluster. There are significant downsides of this since the individual cluster admin needs to be aware and understand how networking works in your cluster to be able to configure some appliance such as MetalLB.

Another use case that was common was using something like F5 for load balancing. Managing and delegating it to individual clusters had massive administrative overheads.

### Solution

KubeLB focuses on managing the load balancers from a centralized point. So instead of having appliances running on each individual clusters. An agent which is the `Cloud Controller Manager` is running on the tenant cluster that propagates all the load balancing request to the management cluster. KubeLB manager running in the management cluster is then responsible for provisioning the actual load balancers and routing traffic back to the tenant workloads.

### Lifecycle of a request

1. Developer creates a service of type LoadBalancer.
2. After validation, KubeLB CCM will propagate these resources from the tenant to LB cluster using the `LoadBalancer` CRD.
3. KubeLB manager then copies/creates the corresponding resources in the tenant namespace in the management cluster.
4. KubeLB CCM polls for the updated status of the service, updates the status when available.
5. KubeLB manager starts routing the traffic for your resource.

![KubeLB Architecture](/img/kubelb/common/architecture.png "KubeLB Architecture")
