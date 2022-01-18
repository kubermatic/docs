+++
title = "Adding an External Kubernetes Cluster"
date = 2022-01-10T14:07:15+02:00
weight = 7

+++

This section describes how to add and manage existing Kubernetes clusters known as external clusters in KKP.
You can import or connect a cluster.
- Import: You can import a cluster via credentials. Imported Cluster can be viewed and edited i.e, upgrade the control plane version or scale the nodes. Currently, GKE, AKS, and EKS clusters are supported.
- Connect: You can also connect any other clusters in the KKP via kubeconfig. Connected clusters can only be viewed, not edited.

The KKP platform uses existing kubeconfig or generates the new one from the cloud provider API.
The KKP backend takes advantage of this kubeconfig to retrieve the cluster information, its' nodes, metrics, and events.
Every cluster update is performed only by the cloud provider client. There is no need to install any agent on the cloud provider side.

## Prerequisites

The following requirements must be met to add an external Kubernetes cluster:
 - The external Kubernetes cluster must already exist before you begin the import/connect process. Please refer to your cloud
 provider documentation for instructions.
 - The external Kubernetes cluster must be accessible using kubectl to get the information needed to add that cluster.
 - Make sure the cluster kubeconfig or provider credentials have sufficient rights to manage the cluster (get, list, upgrade,
 get kubeconfig)

## Add External Cluster

To add a new external cluster go to `Clusters` -> `External Clusters` and click the `Add External Cluster` button.

![Add External Cluster](/img/kubermatic/master/tutorials/external_clusters/add_external_cluster.png "Add External Cluster")

Select the Kubernetes cloud provider. You can add the following external clusters:

  - [GKE]({{< ref "./gke" >}})
  - [AKS]({{< ref "./aks" >}})
  - [EKS]({{< ref "./eks" >}})

## Connect Existing Cluster

To connect a cluster from any provider, click on `Any Provider` and provide the cluster name and kubeconfig.

![Connect Cluster](/img/kubermatic/master/tutorials/external_clusters/connect.png "Connect Cluster")

![Provide Kubeconfig](/img/kubermatic/master/tutorials/external_clusters/custom_cluster_credentials.png "Provide Kubeconfig")

You can then see the details of the cluster.

![Custom Cluster](/img/kubermatic/master/tutorials/external_clusters/custom_details.png "Custom Cluster")

## Cluster State

You can view the current state of your cluster by hovering the cursor over the small circle on the left of the cluster name.

Provisioning state depicts that the cluster is getting created:
![External Cluster Provisioning State](/img/kubermatic/master/tutorials/external_clusters/provisioning_status.png "External Cluster Provisioning State")

Reconciling state depicts that the cluster is getting upgraded:
![External Cluster Reconciling State](/img/kubermatic/master/tutorials/external_clusters/aks_reconcile.png "External Cluster Reconciling State")

### Deleted Cluster

If you delete the cluster from the provider, the state in KKP will be shown as `Deleting`.
![External Cluster Delete State](/img/kubermatic/master/tutorials/external_clusters/delete_status.png "External Cluster Delete State")

You can `Disconnect` the deleted cluster by clicking on the disconnect icon next to the cluster you want to disconnect, which will delete KKP cluster object for this cluster.

![Disconnect Deleted External Cluster](/img/kubermatic/master/tutorials/external_clusters/disconnect_deleted_cluster.png "Disconnect Deleted External Cluster")



