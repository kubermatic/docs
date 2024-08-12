+++
title = "Architecture"
date = 2023-10-27T10:07:15+02:00
weight = 5
+++

KubeLB is an elastically scalable load balancer with a distributed data plane that can span, serve, and scale with apps across various on-premise and cloud locations. The distributed data plane empowers customers to obtain application affinity at the application microservice levels, thus significantly enhancing the overall application performance. In addition, the clean separation of planes also enables the creation of a unified, centralized control plane that significantly alleviates the operational complexity associated with integrating, operating, and managing each ADC appliance across locations individually.

## Terminology

In this chapter, you will find the following KubeLB specific terms:

1. **Load Balancer Cluster** -- A Kubernetes cluster which is responsible for management of all the tenants and their data plane components. Requests for Layer 4 and Layer 7 load balancing are handled by the load balancer cluster.
2. **Tenant Cluster** -- A Kubernetes cluster which acts as a consumer of the load balancer services. Workloads that need Layer 4 or Layer 7 load balancing are created in the tenant cluster. The tenant cluster hosts the KubeLB Cloud Controller Manager (CCM) component which is responsible for propagating the load balancer configurations to the load balancer cluster.

## Design and Architecture

KubeLB follows the **hub and spoke** model in which the "Load Balancer Cluster" acts as the hub and the "Tenant Clusters" act as the spokes. The information flow is from the tenant clusters to the load balancer cluster. The agent running in the tenant cluster watches for nodes, services, ingresses, and Gateway API etc. resources and then propagates the configuration to the load balancer cluster. The load balancer cluster then deploys the load balancer and configures it according to the desired specification. Load balancer cluster then uses Envoy Proxy to route traffic to the appropriate endpoints i.e. the node ports open on the nodes of the tenant cluster.

For security and isolation, the tenants have no access to any native kubernetes resources in the load balancer cluster. The tenants can only interact with the load balancer cluster via the KubeLB CRDs. This ensures that they are not exceeding their access level and only perform controlled operations in the load balancer cluster.

<!-- TODO: Update the architecture diagram -->
![KubeLB Architecture](/img/kubelb/common/architecture.png "KubeLB Architecture")

## Components

KubeLB comprises of two components:

### Cloud Controller Manager

The **KubeLB CCM** is deployed in the tenant clusters and acts as an `agent` that watches for changes in layer 4 and layer 7 load balancing components in the tenant cluster. Such as nodes, secrets, services, ingresses, Gateway API etc. Based on it's configuration and what's allowed, it processes and propagates the required resources to the `manager` cluster.

For layer 4 load balancing `LoadBalancer` and for Layer 7 load balancing `Route` CRDs are used.

### Manager

The **KubeLB manager** is responsible for managing the data plane of it's tenants. The manager **registers** the tenant clusters as tenants, and then it receives the load balancer configurations from the CCM(s) in the form of `LoadBalancer` or `Route` CRDs. It then deploys the neccessary workloads according to the desired specification.

At its core, the KubeLB manager relies on [envoy proxy][1] to load balance the traffic. The manager is responsible for deploying the envoy proxy and configuring it to for each load balancer service per tenant, based on the envoy proxy deployment topology.

### Envoy Proxy Deployment Topology

KubeLB manager supports three different deployment topologies for envoy proxy:

1. **Shared (default)**: In this topology, a single envoy proxy is deployed per tenant cluster. All load balancer services in a particular tenant cluster are configured to use this envoy proxy. This is the default topology.
2. **Global**: In this topology, a single envoy proxy is deployed per KubeLB manager. All load balancer services in all tenant clusters are configured to use this envoy proxy.

## Installation

See the [installation documentation]({{< relref "../installation/">}}) for more details on how to setup datacenters.

[1]: https://github.com/envoyproxy/envoy
