+++
title = "Adding an External AKS Kubernetes Cluster"
date = 2022-01-10T14:07:15+02:00
weight = 7

+++

## Add AKS Cluster

You can add an existing Azure Kubernetes Service cluster and then manage it using KKP. From the Clusters page, click `External Clusters`.
Click `Add External Cluster` button and Pick `Azure Kubernetes Cluster` provider.

![Add External Cluster](/img/kubermatic/v2.19/tutorials/external_clusters/add_external_cluster.png "Add External Cluster")

Select preset with valid credentials or enter AKS `Tenant ID`, `Subscription ID`, `Client ID` and  `Client Secret`, to connect to the provider.
The credentials should have enough access like read, write Azure Kubernetes Service and list cluster admin credential action, to fetch kubeconfig using API.

![AKS credentials](/img/kubermatic/v2.19/tutorials/external_clusters/aks_credentials.png "AKS credentials")

You should see the list of all available clusters. Select the one and click the `Import Cluster` button. Clusters can be imported only once in a single project. The same cluster can be imported in multiple projects.

![Select AKS cluster](/img/kubermatic/v2.19/tutorials/external_clusters/select_aks_cluster.png "Select AKS cluster")

## Cluster Details Page

After the cluster is added, the KKP controller retrieves the cluster kubeconfig to display all necessary information.
A healthy cluster has `Running` state. Otherwise, the cluster can be in the `Error` state. Move the mouse cursor over the state indicator to get more details.

![AKS cluster](/img/kubermatic/v2.19/tutorials/external_clusters/aks_details.png "AKS cluster")

You can also expand `Events` to get information from the controller.

![Cluster Events](/img/kubermatic/v2.19/tutorials/external_clusters/events.png "Cluster Events")

You can click on `Machine Deployments` to get the details:

![AKS Machine Deployment](/img/kubermatic/v2.19/tutorials/external_clusters/aks_machine_deployments.png "AKS Machine Deployment")

## Update Cluster

### Upgrade Version

When an upgrade for the cluster is available, a little dropdown arrow will be shown beside the `Control Plane Version` on the cluster’s page.
To start the upgrade, choose the desired version from the list of available upgrade versions and click on `Change Version`.

![Upgrade AKS](/img/kubermatic/v2.19/tutorials/external_clusters/upgrade_aks.png "Upgrade AKS")

If the version upgrade is valid, the cluster state will change to `Reconciling`.

### Scale the Machine Deployment

Navigate to the cluster overview, scroll down to machine deployments and click on the edit icon next to the machine deployment you want to edit.

![Update AKS Machine Deployment](/img/kubermatic/v2.19/tutorials/external_clusters/edit_md.png "Update AKS Machine Deployment")

In the popup dialog, you can now increase or decrease the number of worker nodes that are managed by this machine deployment.
Either specify the number of desired nodes or use the `+` or `-` to increase or decrease node count.

![Update AKS Machine Deployment](/img/kubermatic/v2.19/tutorials/external_clusters/update_aks_md.png "Update AKS Machine Deployment")

## Stopped Cluster State

If the cluster is stopped from the Azure side, you will be able to see the current state of the cluster as stopped.
Cluster details will not be visible as the details are fetched using kubeconfig, and the kubeconfig is not available for the stopped cluster.

![AKS Cluster Stopped](/img/kubermatic/v2.19/tutorials/external_clusters/aks_stopped.png "AKS Cluster Stopped")