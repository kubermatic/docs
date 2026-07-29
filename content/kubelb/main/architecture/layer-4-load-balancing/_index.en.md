+++
title = "Layer 4 Load Balancing"
date = 2023-10-27T10:07:15+02:00
weight = 5
+++

This document explains the architecture for Layer 4 (TCP/UDP) load balancing in KubeLB. This feature provisions load balancers for a fleet of tenant clusters from a centralized platform.

## Background

Kubernetes does not include a load balancer implementation for clusters. Network and application level load balancing is delegated to the IaaS platform (GCP, AWS, Azure, etc.). On a provider that does not offer load balancing capabilities, services of type `LoadBalancer` cannot be provisioned.

Available solutions such as MetalLB focus on a single cluster, which requires each cluster admin to understand the cluster's networking to configure the appliance. Hardware appliances such as F5 have the same problem: managing and delegating them to individual clusters carries a large administrative overhead.

### Solution

KubeLB manages load balancers from a centralized point instead of running appliances on each individual cluster. An agent, the Cloud Controller Manager, runs on the tenant cluster and propagates all load balancing requests to the management cluster. The KubeLB manager running in the management cluster provisions the actual load balancers and routes traffic back to the tenant workloads.

### Lifecycle of a request

1. Developer creates a service of type LoadBalancer.
2. After validation, the KubeLB CCM propagates these resources from the tenant to the management cluster using the `LoadBalancer` CRD.
3. The KubeLB manager copies/creates the corresponding resources in the tenant namespace in the management cluster.
4. The KubeLB CCM polls for the updated status of the service and updates the status when available.
5. The KubeLB manager starts routing the traffic for your resource.

![KubeLB Architecture](/img/kubelb/common/architecture.png "KubeLB Architecture")
