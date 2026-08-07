+++
title = "Layer 4 Load Balancing"
date = 2023-10-27T10:07:15+02:00
description = "How KubeLB provisions centralized TCP and UDP load balancing for tenant-cluster Services."
weight = 5
+++

This document explains the architecture for Layer 4 (TCP/UDP) load balancing in KubeLB. This feature provisions load balancers for a fleet of tenant clusters from a centralized platform.

## Background

Kubernetes does not include a load balancer implementation for clusters. Network and application level load balancing is delegated to the IaaS platform (GCP, AWS, Azure, etc.). On a provider that does not offer load balancing capabilities, services of type `LoadBalancer` cannot be provisioned.

Available solutions such as MetalLB focus on a single cluster, which requires each cluster admin to understand the cluster's networking to configure the appliance. Hardware appliances such as F5 have the same problem: managing and delegating them to individual clusters carries a large administrative overhead.

### Solution

KubeLB manages load balancers from a centralized point instead of running appliances on each individual cluster. An agent, the Cloud Controller Manager, runs on the tenant cluster and propagates all load balancing requests to the management cluster. The KubeLB manager running in the management cluster provisions the actual load balancers and routes traffic back to the tenant workloads.

### Lifecycle of a request

1. A Service Operator creates a Service of type `LoadBalancer` in a tenant cluster.
2. The KubeLB CCM validates the Service and synchronizes a `LoadBalancer` resource to the tenant's namespace in the management cluster.
3. The KubeLB manager reconciles the required infrastructure and Envoy configuration.
4. The CCM mirrors the assigned address and readiness status back to the original Service.
5. Traffic enters through the assigned address and is forwarded to NodePort endpoints in the tenant cluster.

![A LoadBalancer Service is synchronized by KubeLB CCM to the management cluster, where KubeLB Manager configures Envoy while the CCM mirrors assigned status to the tenant cluster.](/img/kubelb/common/architecture.png "KubeLB Layer 4 request lifecycle")
