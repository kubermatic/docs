+++
title = "Application Load Balancing"
date = 2023-10-27T10:07:15+02:00
weight = 10
+++

This document explains the architecture for Layer 7 or Application Layer Load Balancing support in KubeLB.

## Background

With Kubelb, we want to build a product that can manage the data plane of a fleet of clusters(tenants) from a centralized point. Thus providing Layer 4 and Layer 7 load balancing capabilities as a centralized platform.

KubeLB already had support for L4 load balancing and provisioning/managing load balancers for kubernetes clusters from a central cluster. With v1.1, we want to extend this functionality to managing Application level load balancing including DNS management, TLS management and termination, and other aspects.

### Challenges

Every Kubernetes cluster operates within its isolated network namespace, which offers several advantages. For instance, individual pods can be effortlessly accessed via unique IP addresses. Deploying your load balancing appliance such as nginx-ingress controller or Envoy Gateway would work seamlessly within the cluster because it would run as a pod inside your cluster and by gist, would have access to the same pod-level network as the rest. This enables the load balancing appliance to route and load balance traffic within the cluster.

However, external clusters, management cluster in our case, cannot have direct access to the pod-network of the tenant kubernetes clusters. This introduces a limitation in KubeLB that the management cluster cannot directly route traffic from the load balancing appliance hosted on the management cluster to the tenant clusters. To achieve something like this, the LB cluster would need pod-level network access to ALL the consumer clusters. The options to achieve this are:

- Share the network routes of consumer clusters with the ingress controller server via BGP peering.
- Leverage tools like Submariner, Cilium Cluster Mesh, to create stretched clusters.

These are the options that we want to look into in the future but they do require significant effort and might not be possible to achieve in some cases since KubeLB is simply an "application" that runs in a Kubernetes Cluster. It doesn't, for now, depend or dictate the infrastructural requirements for that Kubernetes cluster.

### Solution

Considering the limitations, we settled for using services of type `NodePort` to route traffic from the management cluster to the tenants. This offers high level of isolation since the only infrastructural requirement for this is to have network access to the tenant cluster nodes with node port range (default: 30000-32767). This is required for the envoy proxy to be able to connect to the tenant cluster nodes.

This is already a requirement for Layer 4 load balancing so we are not adding any new requirements specifically for this use case. This also means that no additional infrastructural level or network level modifications need to be made to your existing management or tenant clusters.

For layer 7 requests, KubeLB will automatically create a `NodePort` service against your `ClusterIP` service hence no manual actions are required from the user's prospective. The user experience remains exactly the same as if they had the load balancing appliance installed within their own cluster.

### Lifecycle of a request

1. Developer creates a deployment, service, and Ingress.
2. KubeLB evaluates if the service is of type ClusterIP and generates a NodePort service against it.
3. After validation, KubeLB CCM will propagate these resources from the tenant to LB cluster using the `Route` CRD.
4. The manager then copies/creates the corresponding resources in the teanat namespace in the management cluster.
5. KubeLB CCM polls for the updated status of the Ingress, updates the status when available.
6. KubeLB manager starts routing the traffic for your resource.

<!-- TODO: Needs to be updated: Flow Diagram -->
![KubeLB Architecture](/img/kubelb/common/architecture.png "KubeLB Architecture")

### High Level Architecture

<!-- TODO: Needs to be updated: Architecture Diagram -->
![KubeLB Architecture](/img/kubelb/common/architecture.png "KubeLB Architecture")
