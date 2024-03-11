+++
title = "External Kubernetes Clusters"
date = 2022-01-10T14:07:15+02:00
weight = 7

+++

This section describes how to add, create and manage Kubernetes clusters known as external clusters in KKP.
You can create a new cluster or import/connect an existing cluster.
- Import: You can import a cluster via credentials. Imported Cluster can be viewed and edited.
  Supported Providers:
  - Azure Kubernetes Service (AKS)
  - Amazon Elastic Kubernetes Service (EKS)
  - Google Kubernetes Engine (GKE)

- Connect: You can also connect any cluster in the KKP via kubeconfig. Connected clusters can only be viewed, not edited.

The KKP platform uses the provided kubeconfig or generates a new one from the cloud provider API.
The KKP backend takes advantage of this kubeconfig to retrieve the cluster's information, nodes, metrics, and events.
Every cluster update is performed only by the cloud provider client. There is no need to install any agent on the cloud provider side.

## Prerequisites

The following requirements must be met to add an external Kubernetes cluster:
 - The external Kubernetes cluster must already exist before you begin the import/connect process. Please refer to the cloud provider documentation for instructions.
 - The external Kubernetes cluster must be accessible using kubectl to get the information needed to add that cluster.
 - Make sure the cluster kubeconfig or provider credentials have sufficient rights to manage the cluster (get, list, upgrade,get kubeconfig)

## Import External Cluster

KKP allows connecting any existing Kubernetes cluster as an external cluster to view the cluster's current state.

- To add a new external cluster go to `External Clusters` page and Click the `Import External Cluster` button.

![Import External Cluster](/img/kubermatic/v2.25/tutorials/external-clusters/add-external-cluster.png "Import External Cluster")

- Select the Kubernetes cloud provider. You can add or create the following external clusters:

  - [AKS]({{< ref "./aks" >}})
  - [EKS]({{< ref "./eks" >}})
  - [GKE]({{< ref "./gke" >}})

- To connect a cluster from any provider, click on `Any Provider` and provide the cluster name and kubeconfig.

{{% notice info %}}
It is important that the kubeconfig used to connect the cluster is using standard authentication mechanisms like certificates or ServiceAccount tokens. OIDC or provider-specific plugins are not supported.
{{% /notice %}}

![Connect Cluster](/img/kubermatic/v2.25/tutorials/external-clusters/connect.png "Connect Cluster")

{{% notice info %}}
If an existing kubeconfig uses custom authentication mechanisms, `kubermatic-installer convert-kubeconfig` can (optionally) be used to create a ServiceAccount on the external cluster and fetch its token into a new kubeconfig.
{{% /notice %}}

![Provide kubeconfig](/img/kubermatic/v2.25/tutorials/external-clusters/custom-cluster-credentials.png "Provide kubeconfig")

You can then see the details of the cluster.

![Custom Cluster](/img/kubermatic/v2.25/tutorials/external-clusters/bringyourown.png "BringYourOwn Cluster")

## Create External Cluster

KKP allows creating a Kubernetes cluster on AKS/GKE/EKS and import it as an External Cluster.

![Create External Cluster](/img/kubermatic/v2.25/tutorials/external-clusters/create-external-cluster.png "Create External Cluster")

![External Cluster List](/img/kubermatic/v2.25/tutorials/external-clusters/externalcluster-list.png "External Cluster List")

## Delete Cluster:

{{% notice info %}}
Delete operation is not allowed for imported clusters.
{{% /notice %}}

Cluster can be  Deleted by clicking on the delete icon next to the cluster you want to delete or from the cluster details page, which will delete and disconnect the cluster from the provider.

![Delete External Cluster](/img/kubermatic/v2.25/tutorials/external-clusters/delete-externalcluster.png "Delete External Cluster")

![Delete External Cluster on Details Page](/img/kubermatic/v2.25/tutorials/external-clusters/delete-disconnect-page.png "Delete External Cluster on Details Page")

## Cluster State

You can view the current state of your cluster by hovering the cursor over the small circle on the left of the cluster name.

Provisioning state depicts that the cluster is getting created:
![External Cluster Provisioning State](/img/kubermatic/v2.25/tutorials/external-clusters/provisioning-status.png "External Cluster Provisioning State")

Reconciling state depicts that the cluster is getting upgraded:
![External Cluster Reconciling State](/img/kubermatic/v2.25/tutorials/external-clusters/reconciling-status.png "External Cluster Reconciling State")

Running state depicts that the cluster is healthy:
![External Cluster Provisioning State](/img/kubermatic/v2.25/tutorials/external-clusters/running-status.png "External Cluster Running State")

Deleting state depicts that the cluster is getting deleted:

![External Cluster Delete State](/img/kubermatic/v2.25/tutorials/external-clusters/aks-deleting.png "External Cluster Delete State")

## Disconnect Cluster

{{% notice info %}}
Disconnect operation does not delete the cluster from the cloud provider.
{{% /notice %}}

You can `Disconnect` an external cluster by clicking on the disconnect icon next to the cluster you want to disconnect or from the cluster details page, which will delete internal cluster object in KKP.

![Disconnect External Cluster](/img/kubermatic/v2.25/tutorials/external-clusters/disconnect-externalcluster.png "Disconnect External Cluster")

![Disconnect External Cluster on Details Page](/img/kubermatic/v2.25/tutorials/external-clusters/disconnect-externalcluster-details-page.png "Disconnect External Cluster on Details Page")

![Disconnect Dialog](/img/kubermatic/v2.25/tutorials/external-clusters/disconnect.png "Disconnect Dialog")


## Delete Cluster

{{% notice info %}}
Delete Cluster displays information in case nodes are attached
{{% /notice %}}


![Delete External Cluster](/img/kubermatic/v2.25/tutorials/external-clusters/delete-external-cluster-dialog.png "Delete External Cluster")
