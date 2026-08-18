+++
title = "Architecture"
date = 2023-10-27T10:07:15+02:00
description = "How KubeLB separates the control plane from the data plane across a management cluster and tenant clusters."
weight = 5
+++

KubeLB separates the control plane from the data plane: a central management cluster holds the load balancing configuration and runs the data plane (Envoy Proxy) for many tenant clusters, while a lightweight agent in each tenant cluster reports what needs to be load balanced. This page explains the components involved and how they interact.

## Terminology

This chapter uses the following KubeLB-specific terms:

1. **Management Cluster** (also called the load balancing cluster): A Kubernetes cluster responsible for managing all tenants and their data plane components. Requests for Layer 4 and Layer 7 load balancing are handled by the management cluster.
2. **Tenant Cluster**: A Kubernetes cluster that consumes the load balancer services. Workloads that need Layer 4 or Layer 7 load balancing are created in the tenant cluster. The tenant cluster hosts the KubeLB Cloud Controller Manager (CCM), which propagates the load balancer configurations to the management cluster. Each Kubernetes cluster where the KubeLB CCM runs is a unique tenant, because its endpoints (the node IPs and node ports) are unique to that cluster.

## Design and architecture

KubeLB follows a **hub-and-spoke** model: the management cluster is the hub and tenant clusters are the spokes.

1. The KubeLB CCM in each tenant cluster watches nodes, Services, Ingresses, Secrets, and Gateway API resources.
2. The CCM validates relevant resources and synchronizes the desired state to the tenant's namespace in the management cluster.
3. The KubeLB manager reconciles that state into load balancer infrastructure and Envoy configuration.
4. Envoy routes external traffic to NodePort endpoints in the tenant cluster.

For security and isolation, tenants have no access to native Kubernetes resources in the management cluster. Each tenant gets its own namespace there, reached with a namespaced credential that grants KubeLB CRDs and nothing else. See [Tenant Isolation]({{< relref "./tenant-isolation/" >}}) for what that credential can and cannot do, how hostname claims are bounded, and the network policies available in Enterprise Edition.

![A management cluster runs KubeLB Manager and Envoy for multiple tenant clusters, while a KubeLB CCM in each tenant cluster synchronizes desired state and status.](/img/kubelb/v1.1/kubelb-high-level-architecture.png?classes=shadow,border "KubeLB management and tenant cluster architecture")

## Components

KubeLB has two control-plane components:

### Cloud Controller Manager

The **KubeLB CCM** is deployed in the tenant clusters and acts as an agent that watches for changes in Layer 4 and Layer 7 load balancing components in the tenant cluster, such as nodes, secrets, services, ingresses, and Gateway API resources. Based on its configuration and what is allowed, it processes and propagates the required resources to the management cluster.

Layer 4 load balancing uses the `LoadBalancer` CRD; Layer 7 load balancing uses the `Route` CRD.

### Manager

The **KubeLB manager** is responsible for managing the data plane of its tenants. The manager **registers** the tenant clusters as tenants, and then it receives the load balancer configurations from the CCM(s) in the form of `LoadBalancer` or `Route` CRDs. It then deploys the necessary workloads according to the desired specification.

At its core, the KubeLB manager relies on [Envoy Proxy][1] to load balance the traffic. The manager is responsible for deploying Envoy Proxy and configuring it for each load balancer service per tenant, based on the Envoy Proxy deployment topology.

## Personas and responsibilities

KubeLB uses the following personas, based on the [Gateway API persona model](https://gateway-api.sigs.k8s.io/concepts/roles-and-personas/):

| Persona | Scope | Primary responsibilities | Typical resources |
| --- | --- | --- | --- |
| Platform Provider | Management cluster and underlying infrastructure | Operates KubeLB, provides load balancing infrastructure, and defines available implementations | `GatewayClass`, KubeLB `Config`, `Tenant` |
| Platform Operator | Tenant-cluster platform | Manages shared networking, policies, permissions, and application entry points | `Gateway`, policy resources, namespaces |
| Service Operator | Application workloads | Defines how application traffic is matched, secured, and routed to Services | `HTTPRoute`, `GRPCRoute`, `TCPRoute`, `TLSRoute`, `Service` |

One team may perform both the Platform Operator and Service Operator roles, but the responsibilities and permissions remain distinct. The Platform Provider operates the management cluster; the other roles work primarily in tenant clusters.

## Concepts

### Envoy Proxy deployment topology

KubeLB manager deploys Envoy Proxy using the **shared** topology: a single Envoy Proxy is deployed per tenant cluster, and all load balancer services in that tenant cluster are routed through it.

{{% notice warning %}}
The `global` Envoy Proxy topology available in KubeLB v1.3 and earlier has been removed in v1.4. Existing installations using `global` must migrate to `shared` before upgrading; update `Config.spec.envoyProxy.topology` (or the corresponding tenant-level override) to `shared`.
{{% /notice %}}

### User experience

Existing workflows for managing Layer 4 and Layer 7 workloads should keep working with as little change as possible. Once the CCM is configured, the only difference for end users is to use the class **kubelb** for their resources instead of a provider-specific class.

### Kubernetes classes

A Kubernetes class identifies the controller responsible for a resource. For example, an Ingress that references the `nginx` IngressClass is handled by the controller that implements that class. Equivalent class-selection mechanisms exist for Services and Gateway API resources. By default, KubeLB processes only resources that select its class; CCM configuration can change this behavior.

## Related architecture pages

{{% children depth=5 %}}
{{% /children %}}

## Installation

See the [installation documentation]({{< relref "../installation/">}}) for how to set up and install KubeLB.

[1]: https://github.com/envoyproxy/envoy
