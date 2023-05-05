+++
title = "Networking"
date = 2022-04-20T12:15:02+02:00
weight = 20

+++

## KKP Networking 

In the Kubermatic Kubernetes Platform (KKP), some parts of the Kubernetes control plane are deployed in the dedicated Seed cluster instead of the user cluster. 
This design requires two endpoints to be exposed at the Seed via the nodeport-proxy service in order to be accessible from user clusters. 
These endpoints expose the Kubernetes apiserver as well as a proxy to connect to the user cluster network for each user cluster on a Seed. 
The [expose strategy]({{< ref "../../../../tutorials-howtos/networking/expose-strategies" >}}) enables configuration of how the services are exposed on a Seed.

This section explains how the connection between user clusters and the control plane is established, as well as the general networking concept in KKP.

KKP Operator --> Master cluster Kubernetes API
KKP Operator --> Seed cluster Kubernetes API

Kubernetes API --> Seed Cluster Kubernetes API
Kubernetes API --> Seed cluster nodeport-proxy 

Seed controller manager --> Seed cluster Kubernetes API
Seed controller manager --> Cloud Provider API

![KKP Network](/img/kubermatic/main/concepts/architecture/expose-np.png?classes=shadow,border "This diagram illustrated the necessary connections for KKP.")

The following diagrams illustrate all available [expose strategy]({{< ref "../../../../tutorials-howtos/networking/expose-strategies" >}}) available in KKP.

![KKP NodePort](/img/kubermatic/main/concepts/architecture/expose-np.png?classes=shadow,border "NodePort")

![KKP Tunneling](/img/kubermatic/main/concepts/architecture/expose-tunnel.png?classes=shadow,border "Tunneling")

![KKP LoadBalancer](/img/kubermatic/main/concepts/architecture/expose-lb.png?classes=shadow,border "LoadBalancer")

They define how user cluster connect to their control plane and how users connect to the cluster apiserver.

#### Worker Nodes

Worker nodes in user clusters must have full connectivity to each other to ensure the functionality of various components, including different Container Network Interfaces (CNIs) and Container Storage Interfaces (CSIs) supported by KKP.

#### API Server

For each user cluster, an API server is deployed in the Seed and exposed depending on the chosen expose strategy. 
Its purpose is not only to make the apiserver accessible to users, but also to ensure the proper functioning of the cluster. 
Nodes run kubelet as the primary node agent, which registers the node with the apiserver and therefore requires access to it. 
In addition, the apiserver is used for [in-cluster API](https://kubernetes.io/docs/tasks/run-application/access-api-from-pod) access.

In Tunneling mode, to forward traffic to the correct apiserver, an envoy proxy is deployed on each node, serving as an endpoint for the Kubernetes cluster service to proxy traffic to the apiserver.

#### Kubernetes Konnectivity proxy

To enable Kubernetes to work properly, parts of the control plane need to be connected to the internal Kubernetes cluster network. 
This is done via the [konnectivity proxy](https://kubernetes.io/docs/tasks/extend-kubernetes/setup-konnectivity/), which is deployed for each cluster. 
It consists of a client and server model, where the server is deployed in the Seed and the client is deployed as part of the kube-system in the user cluster. 
This allows the apiserver to communicate with kubelet, which is required, for example, to receive logs of a container.

