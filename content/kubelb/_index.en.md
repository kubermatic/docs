+++
title = "Kubermatic KubeLB"
date = 2023-10-27T10:07:15+02:00
weight = 6
description = "Learn how you can use Kubermatic KubeLB to centrally provision and manage load balancers across multiple cloud and on-premise environments."
+++

![KubeLB logo](/img/kubelb/common/logo.png?classes=height=50)

## What is KubeLB?

KubeLB is a project by Kubermatic, it is a Kubernetes native tool, responsible for centrally managing load balancers for Kubernetes clusters across multi-cloud and on-premise environments.

## Motivation and Background

Kubernetes does not offer any implementation for load balancers and in turn relies on the in-tree or out-of-tree cloud provider implementations to take care of provisioning and managing load balancers. This means that if you are not running on a supported cloud provider, your services of type `LoadBalancer` will never be allotted a load balancer IP address. This is an obstacle for bare-metal Kubernetes environments.

There are solutions available like [MetalLB][2], [Cilium][3], etc. that solve this issue. However, these solutions are focused on a single cluster where you have to deploy the application in the same cluster where you want the load balancers. This is not ideal for multi-cluster environments since you have to configure load balancing for each cluster separately, which makes IP address management not trivial.

KubeLB solves this problem by providing a centralized load balancer management solution for Kubernetes clusters across multi-cloud and on-premise environments.

## Architecture

![KubeLB Architecture](/img/kubelb/common/architecture.png "KubeLB Architecture")

KubeLB comprises of two components:

### CCM

The `KubeLB CCM` is deployed in the consumer clusters that require load balancer services. Its main responsibility is to propagate the load balancer configurations to the `manager`.

It watches for changes in Kubernetes services, and nodes, and then generates the load balancer configuration for the manager. It then sends the configuration to the manager in the form of `LoadBalancer` CRD.

### Manager

The `KubeLB manager` is responsible for deploying and configuring the actual load balancers. The manager **registers** the consumer clusters as tenants, and then it receives the load balancer configurations from the CCM(s) in the form of `LoadBalancer` CRD. It then deploys a load balancer and configures it according to the desired specification.

At its core, the KubeLB manager relies on [envoy proxy][1] to load balance the traffic. The manager is responsible for deploying the envoy proxy and configuring it to for each load balancer service per tenant, based on the envoy proxy deployment topology.

### Envoy Proxy Deployment Topology

KubeLB manager supports three different deployment topologies for envoy proxy:

#### Dedicated

In this topology, the envoy proxy is deployed per load balancer service.

#### Shared (default)

In this topology, a single envoy proxy is deployed per tenant cluster. All load balancer services in a particular tenant cluster are configured to use this envoy proxy. This is the default topology.

#### Global

In this topology, a single envoy proxy is deployed per KubeLB manager. All load balancer services in all tenant clusters are configured to use this envoy proxy.

[1]: https://github.com/envoyproxy/envoy
[2]: https://metallb.universe.tf
[3]: https://cilium.io/use-cases/load-balancer
