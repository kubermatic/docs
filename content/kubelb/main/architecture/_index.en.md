+++
title = "Architecture"
date = 2023-10-27T10:07:15+02:00
weight = 5
+++

KubeLB is an elastically scalable load balancer with a distributed data plane that can span, serve, and scale with apps across various on-premise and cloud locations. The distributed data plane empowers customers to obtain application affinity at the application microservice levels, thus significantly enhancing the overall application performance. In addition, the clean separation of planes also enables the creation of a unified, centralized control plane that significantly alleviates the operational complexity associated with integrating, operating, and managing each ADC appliance across locations individually.

## Terminology

In this chapter, you will find the following KubeLB specific terms:

1. **Management Cluster/Load balancing Cluster** -- A Kubernetes cluster which is responsible for management of all the tenants and their data plane components. Requests for Layer 4 and Layer 7 load balancing are handled by the management cluster.
2. **Tenant Cluster** -- A Kubernetes cluster which acts as a consumer of the load balancer services. Workloads that need Layer 4 or Layer 7 load balancing are created in the tenant cluster. The tenant cluster hosts the KubeLB Cloud Controller Manager (CCM) component which is responsible for propagating the load balancer configurations to the management cluster. Each Kubernetes cluster where the KubeLB CCM is running is considered a unique tenant. This demarcation is based on the fact that the endpoints, simply the Node IPs and node ports, are unique for each Kubernetes cluster.

## Design and Architecture

KubeLB follows the **hub and spoke** model in which the "Management Cluster" acts as the hub and the "Tenant Clusters" act as the spokes. The information flow is from the tenant clusters to the management cluster. The agent running in the tenant cluster watches for nodes, services, ingresses, and Gateway API etc. resources and then propagates the configuration to the management cluster. The management cluster then deploys the load balancer and configures it according to the desired specification. Management cluster then uses Envoy Proxy to route traffic to the appropriate endpoints i.e. the node ports open on the nodes of the tenant cluster.

For security and isolation, the tenants have no access to any native kubernetes resources in the management cluster. The tenants can only interact with the management cluster via the KubeLB CRDs. This ensures that they are not exceeding their access level and only perform controlled operations in the management cluster.

<!-- TODO: Needs to be updated -->
![KubeLB Architecture](/img/kubelb/common/architecture.png "KubeLB Architecture")

## Components

KubeLB comprises of two components:

### Cloud Controller Manager

The **KubeLB CCM** is deployed in the tenant clusters and acts as an `agent` that watches for changes in layer 4 and layer 7 load balancing components in the tenant cluster. Such as nodes, secrets, services, ingresses, Gateway API etc. Based on it's configuration and what's allowed, it processes and propagates the required resources to the `manager` cluster.

For layer 4 load balancing `LoadBalancer` and for Layer 7 load balancing `Route` CRDs are used.

### Manager

The **KubeLB manager** is responsible for managing the data plane of it's tenants. The manager **registers** the tenant clusters as tenants, and then it receives the load balancer configurations from the CCM(s) in the form of `LoadBalancer` or `Route` CRDs. It then deploys the necessary workloads according to the desired specification.

At its core, the KubeLB manager relies on [envoy proxy][1] to load balance the traffic. The manager is responsible for deploying the envoy proxy and configuring it to for each load balancer service per tenant, based on the envoy proxy deployment topology.

### Envoy Proxy Deployment Topology

KubeLB manager supports two different deployment topologies for envoy proxy:

1. **Shared (default)**: In this topology, a single envoy proxy is deployed per tenant cluster. All load balancer services in a particular tenant cluster are configured to use this envoy proxy. This is the default topology.
2. **Global**: In this topology, a single envoy proxy is deployed per KubeLB manager. All load balancer services in all tenant clusters are configured to use this envoy proxy. Pitfalls: Due to a single envoy proxy deployment, service-level network access is required from the tenant namespace to the controller namespace.

The consumers are not aware or affected by the topology. This is only an internal detail for the management cluster.

## Personas

KubeLB targets the following personas:

1. Platform Provider: The Platform Provider is responsible for the overall environment that the cluster runs in, i.e. the cloud provider. The Platform Provider will interact with GatewayClass resources.
2. Platform Operator: The Platform Operator is responsible for overall cluster administration. They manage policies, network access, application permissions and will interact with Gateway resources.
3. Service Operator: The Service Operator is responsible for defining application configuration and service composition. They will interact with HTTPRoute and TLSRoute resources and other typical Kubernetes resources.

Inspired from [Gateway API Personas](https://gateway-api.sigs.k8s.io/#personas).

Service Operator and Platform Operator are the more or less the same persona in KubeLB and they are resposinble for defining the load balancer configurations in tenant cluster. Platform Provider is the "KubeLB provider" and manages the management cluster.

## User experience

One of the most vital consideration while designing KubeLB was the user experience. There should be least possible friction and divergance of how the workflows to manage Layer 4 and Layer 7 workloads used to work like before KubeLB.

All the end users need is to configure the CCM with there desired configuration and the CCM will take care of the rest. With default configuration, all you need is to use the Class **kubelb** for your resources instead of a provider specific class that the users used to have before.

### Kubernetes Class

Class is a concept in Kubernetes that is used to mark the ownership of a resource. For example an Ingress with `class: nginx` will be owned by a controller that implements the IngressClass named `nginx`. We have the similar concept in services, ingresses, gateway API resources, etc. KubeLB leverages on this concept to provide a seamless experience to the users by simply filtering out and processing the resoruces that are owned by KubeLB, by default. This behavior can also be changed by overriding the CCM configuration.

## Installation

See the [installation documentation]({{< relref "../installation/">}}) for more details on how to setup and install KubeLB.

[1]: https://github.com/envoyproxy/envoy

## Table of Content

{{% children depth=5 %}}
{{% /children %}}
