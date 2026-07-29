+++
title = "Application Load Balancing"
date = 2023-10-27T10:07:15+02:00
weight = 10
+++

This document explains the architecture for Layer 7 (application layer) load balancing in KubeLB.

## Background

KubeLB manages the data plane of a fleet of tenant clusters from a central management cluster, providing Layer 4 and Layer 7 load balancing through a single platform. Layer 7 support, introduced in v1.1, covers application-level load balancing including DNS management and TLS management and termination.

### Challenges

Every Kubernetes cluster operates within its own isolated network: individual pods can be reached directly via unique IP addresses. A load balancing appliance such as the ingress-nginx controller or Envoy Gateway works within the cluster because it runs as a pod and shares the pod-level network, so it can route and load balance traffic inside the cluster.

The management cluster has no direct access to the pod network of the tenant clusters, so it cannot route traffic from its load balancing appliance directly to tenant pods. That would require pod-level network access from the management cluster to all tenant clusters, for example by sharing tenant network routes via BGP peering, or by creating stretched clusters with tools like Submariner or Cilium Cluster Mesh. KubeLB does not take this approach: it is an application running in a Kubernetes cluster and does not dictate infrastructure requirements for that cluster.

### Solution

KubeLB routes traffic from the management cluster to the tenants through services of type `NodePort`. This preserves isolation: the only infrastructural requirement is network access from the management cluster to the tenant cluster nodes on the node port range (default: 30000-32767), which Envoy Proxy needs to connect to the tenant cluster nodes.

This is already a requirement for Layer 4 load balancing, so Layer 7 support adds no new requirements and no network-level changes to existing management or tenant clusters.

For Layer 7 requests, KubeLB automatically creates a `NodePort` service against your `ClusterIP` service; no manual action is required. The user experience remains the same as if the load balancing appliance were installed in the tenant cluster.

### Lifecycle of a request

1. Developer creates a deployment, service, and Ingress.
2. KubeLB evaluates if the service is of type ClusterIP and generates a NodePort service against it.
3. After validation, the KubeLB CCM propagates these resources from the tenant to the management cluster using the `Route` CRD.
4. The KubeLB manager copies/creates the corresponding resources in the tenant namespace in the management cluster.
5. The KubeLB CCM polls for the updated status of the Ingress and updates the status when available.
6. The KubeLB manager starts routing the traffic for your resource.

![KubeLB Architecture](/img/kubelb/v1.1/layer7-architecture.png?classes=shadow,border "KubeLB Architecture")
