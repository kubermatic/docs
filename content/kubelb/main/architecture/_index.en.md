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

## Design and Architecture

KubeLB follows the **hub and spoke** model: the management cluster is the hub and the tenant clusters are the spokes. Information flows from the tenant clusters to the management cluster. The agent running in the tenant cluster watches nodes, services, ingresses, and Gateway API resources and propagates the configuration to the management cluster. The management cluster deploys the load balancer, configures it according to the desired specification, and uses Envoy Proxy to route traffic to the appropriate endpoints, the node ports open on the nodes of the tenant cluster.

For security and isolation, tenants have no access to native Kubernetes resources in the management cluster. They interact with it only through the KubeLB CRDs, which limits them to controlled operations within their access level.

![KubeLB Architecture](/img/kubelb/v1.1/kubelb-high-level-architecture.png?classes=shadow,border "KubeLB Architecture")

## Components

KubeLB consists of two components:

### Cloud Controller Manager

The **KubeLB CCM** is deployed in the tenant clusters and acts as an agent that watches for changes in Layer 4 and Layer 7 load balancing components in the tenant cluster, such as nodes, secrets, services, ingresses, and Gateway API resources. Based on its configuration and what is allowed, it processes and propagates the required resources to the management cluster.

Layer 4 load balancing uses the `LoadBalancer` CRD; Layer 7 load balancing uses the `Route` CRD.

### Manager

The **KubeLB manager** is responsible for managing the data plane of its tenants. The manager **registers** the tenant clusters as tenants, and then it receives the load balancer configurations from the CCM(s) in the form of `LoadBalancer` or `Route` CRDs. It then deploys the necessary workloads according to the desired specification.

At its core, the KubeLB manager relies on [Envoy Proxy][1] to load balance the traffic. The manager is responsible for deploying Envoy Proxy and configuring it for each load balancer service per tenant, based on the Envoy Proxy deployment topology.

## Personas

KubeLB targets the following personas:

1. Platform Provider: The Platform Provider is responsible for the overall environment that the cluster runs in, i.e. the cloud provider. The Platform Provider will interact with GatewayClass resources.
2. Platform Operator: The Platform Operator is responsible for overall cluster administration. They manage policies, network access, application permissions and will interact with Gateway resources.
3. Service Operator: The Service Operator is responsible for defining application configuration and service composition. They will interact with HTTPRoute and TLSRoute resources and other typical Kubernetes resources.

Inspired by [Gateway API Personas](https://gateway-api.sigs.k8s.io/#personas).

Service Operator and Platform Operator are more or less the same persona in KubeLB and they are responsible for defining the load balancer configurations in tenant cluster. Platform Provider is the "KubeLB provider" and manages the management cluster.

## Concepts

### Envoy Proxy Deployment Topology

KubeLB manager deploys Envoy Proxy using the **shared** topology: a single Envoy Proxy is deployed per tenant cluster, and all load balancer services in that tenant cluster are routed through it.

{{% notice warning %}}
The `global` Envoy Proxy topology available in KubeLB v1.3 and earlier has been removed in v1.4. Existing installations using `global` must migrate to `shared` before upgrading; update `Config.spec.envoyProxy.topology` (or the corresponding tenant-level override) to `shared`.
{{% /notice %}}

### User experience

Existing workflows for managing Layer 4 and Layer 7 workloads should keep working with as little change as possible. Once the CCM is configured, the only difference for end users is to use the class **kubelb** for their resources instead of a provider-specific class.

### Kubernetes Class

Class is a concept in Kubernetes that is used to mark the ownership of a resource. For example, an Ingress with `class: nginx` will be owned by a controller that implements the IngressClass named `nginx`. The same concept exists for services and Gateway API resources. By default, KubeLB only processes resources that carry its class; this behavior can be changed by overriding the CCM configuration.

## Table of Contents

{{% children depth=5 %}}
{{% /children %}}

## Installation

See the [installation documentation]({{< relref "../installation/">}}) for how to set up and install KubeLB.

[1]: https://github.com/envoyproxy/envoy
