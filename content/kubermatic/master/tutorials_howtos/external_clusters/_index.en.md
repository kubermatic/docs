+++
title = "Adding an External Kubernetes Cluster"
date = 2022-01-10T14:07:15+02:00
weight = 7

+++

This section describes how to add and manage existing GKE, AKS, and EKS clusters. Once an external cluster is added and
registered within the KKP platform, you may then upgrade the control plane version or scale the nodes.
You can also connect any other clusters in the KKP via kubeconfig. Connected clusters can only be viewed, not edited. 

The KKP platform uses existing kubeconfig or generate the new one from the cloud provider API. The KKP backend take advantage of
this kubeconfig to retrieve the cluster information like: cluster and node details, metrics, events.
Every cluster update is performed only by the cloud provider client. There is no need to install any agent on the cloud provider side.   

## Requirements

The following requirements must be met in order to add an external Kubernetes cluster:
 - The external Kubernetes cluster must already exist before you begin the add/connect process. Please refer to your cloud
 provider documentation for instructions.
 - The external Kubernetes cluster must be accessible using kubectl to get the information needed to import that cluster.
 - Make sure the cluster kubeconfig or provider credentials have sufficient rights to manage the cluster (get, list, upgrade,
 get kubeconfig)

## Add External Cluster

To add a new external cluster go to Clusters -> External Clusters and press `Add External Cluster` button.

![Add External Cluster](/img/kubermatic/master/tutorials/external_clusters/add_external_cluster.png "Add External Cluster")

Select the Kubernetes clod provider. You can add the following external clusters:

  - [GKE]({{< ref "./gke" >}})
  - [AKS]({{< ref "./aks" >}})
  - [EKS]({{< ref "./eks" >}})
  
## Connect existing cluster
