+++
title = "Application Load Balancing"
date = 2023-10-27T10:07:15+02:00
description = "How KubeLB provides centralized Layer 7 routing, DNS, and TLS for tenant-cluster applications."
weight = 10
+++

This document explains the architecture for Layer 7 (application layer) load balancing in KubeLB.

## Background

KubeLB manages the data plane for a fleet of tenant clusters from a central management cluster. Layer 7 capabilities include application routing, DNS management, and TLS certificate management and termination.

### Challenges

Every Kubernetes cluster operates within its own isolated network: individual pods can be reached directly via unique IP addresses. A load balancing appliance such as the ingress-nginx controller or Envoy Gateway works within the cluster because it runs as a pod and shares the pod-level network, so it can route and load balance traffic inside the cluster.

The management cluster has no direct access to the pod network of the tenant clusters, so it cannot route traffic from its load balancing appliance directly to tenant pods. That would require pod-level network access from the management cluster to all tenant clusters, for example by sharing tenant network routes via BGP peering, or by creating stretched clusters with tools like Submariner or Cilium Cluster Mesh. KubeLB does not take this approach: it is an application running in a Kubernetes cluster and does not dictate infrastructure requirements for that cluster.

### Solution

KubeLB routes traffic from the management cluster to the tenants through services of type `NodePort`. This preserves isolation: the only infrastructural requirement is network access from the management cluster to the tenant cluster nodes on the node port range (default: 30000-32767), which Envoy Proxy needs to connect to the tenant cluster nodes.

This is already a requirement for Layer 4 load balancing, so Layer 7 support adds no new requirements and no network-level changes to existing management or tenant clusters.

For Layer 7 requests, KubeLB automatically creates a `NodePort` service against your `ClusterIP` service; no manual action is required. The user experience remains the same as if the load balancing appliance were installed in the tenant cluster.

### Lifecycle of a request

1. A Service Operator creates a workload, a `ClusterIP` Service, and an Ingress or Gateway API route in a tenant cluster.
2. The KubeLB CCM validates the resources and ensures that a NodePort Service exposes the backend to the management cluster.
3. The CCM synchronizes a `Route` resource and its dependencies to the tenant's namespace in the management cluster.
4. The KubeLB manager reconciles the required Envoy, DNS, and certificate configuration.
5. The CCM mirrors the assigned address and readiness status back to the original tenant resource.
6. Envoy accepts external traffic and forwards it to the tenant cluster's NodePort endpoints.

![An Ingress or Gateway API route is synchronized from a tenant cluster to the management cluster, where KubeLB configures Envoy, DNS, and TLS before routing traffic back to tenant NodePorts.](/img/kubelb/v1.1/layer7-architecture.png?classes=shadow,border "KubeLB Layer 7 request lifecycle")
