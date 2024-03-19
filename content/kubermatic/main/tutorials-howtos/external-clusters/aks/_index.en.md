+++
title = "Azure Kubernetes Service"
date = 2022-01-10T14:07:15+02:00
description = "Detailed tutorial to help you manage AKS cluster using KKP"
weight = 7

+++

## Import AKS Cluster

You can add an existing Azure Kubernetes Service cluster and then manage it using KKP.

- Navigate to `External Clusters` page.

- Click `Import External Cluster` button.

![Add External Cluster](@/images/main/tutorials/external-clusters/external-cluster-page.png "Add External Cluster")

- Pick `Azure Kubernetes Cluster` provider.

![Select Provider](@/images/main/tutorials/external-clusters/connect.png "Select Provider")

- Provide Credentials in either of the below mentioned ways:
    - Select a pre-created preset which stores the provider specific credentials.

    - Manually enter the credentials `Tenant ID`, `Subscription ID`, `Client ID` and  `Client Secret`.

{{% notice info %}}
The credentials should provide access rights to read & write Azure Kubernetes Service and list cluster admin credential, in order to fetch kubeconfig using API.
[Learn about Authorize Resource Group](https://docs.microsoft.com/en-us/azure/aks/concepts-identity#azure-rbac-to-authorize-access-to-the-aks-resource "Learn about Authorize Resource Group")
{{% /notice %}}

- After user provides all required credentials, credentials will be validated.

{{% notice info %}}
Validation performed will only check if the credentials have `Read` access.
{{% /notice %}}

![AKS credentials](@/images/main/tutorials/external-clusters/aks-credentials.png "AKS credentials")

- You should see the list of all available clusters. Select the one and click the `Import Cluster` button. Clusters can be imported only once in a single project. The same cluster can be imported in multiple projects.

![Select AKS cluster](@/images/main/tutorials/external-clusters/select-aks-cluster.png "Select AKS cluster")

## Create AKS Preset
Admin can create a preset on a KKP cluster using KKP `Admin Panel`.
This Preset can then be used to Create/Import an AKS cluster.

- Click on `Admin Panel` from the menu.

![Select Admin Panel](@/images/main/tutorials/external-clusters/select-adminpanel.png "Select Admin Panel")

- Navigate to `Provider Presets` Page and Click on `+ Create Preset` button.

![Provider Preset Page](@/images/ui/preset-management.png?height=300px&classes=shadow,border "Provider Preset Page")

- Enter Preset Name.

![Provide Preset Name](@/images/main/tutorials/external-clusters/create-akspreset.png "Provide Preset Name")

- Choose `Azure Kubernetes Service` from the list of providers.

![Choose AKS Preset](@/images/main/tutorials/external-clusters/choose-akspreset.png "Choose AKS Preset")

-  Enter AKS credentials and Click on `Create` button.

!["Enter Credentials](@/images/main/tutorials/external-clusters/enter-aks-credentials-preset.png "Enter Credentials")

- You can now use created AKS Preset to Create or Import AKS Cluster.

![Select AKS Preset](@/images/main/tutorials/external-clusters/existing-aks-preset.png "Select AKS Preset")

## Cluster Details Page

After the cluster is added, the KKP controller retrieves the cluster kubeconfig to display all necessary information.
A healthy cluster has `Running` state. Otherwise, the cluster can be in the `Error` state. Move the mouse cursor over the state indicator to get more details.

![AKS cluster](@/images/main/tutorials/external-clusters/aks-details.png "AKS cluster")

You can also expand `Events` to get information from the controller.

![Cluster Events](@/images/main/tutorials/external-clusters/aks-cluster-events.png "Cluster Events")

You can click on `Machine Deployments` to get the details:

![AKS Machine Deployment](@/images/main/tutorials/external-clusters/aks-machine-deployments.png "AKS Machine Deployment")

## Update Cluster

### Upgrade Cluster Version

When an upgrade for the cluster is available, a little dropdown arrow will be shown beside the `Control Plane Version` on the cluster’s page.
To start the upgrade, choose the desired version from the list of available upgrade versions and click on `Change Version`.

![Upgrade Available](@/images/main/tutorials/external-clusters/aks-upgrade-available.png "Upgrade Available")

![Upgrade AKS](@/images/main/tutorials/external-clusters/upgrade-aks.png "Upgrade AKS")

If the version upgrade is valid, the cluster state will change to `Reconciling`.

## Edit the Machine Deployment

{{% notice info %}}
Only one operation can be performed at one point of time. If the replica count is updated then Kubernetes version upgrade will be disabled and vice versa.
{{% /notice %}}

- Navigate to the cluster overview, scroll down to machine deployments.

- Click on the edit icon next to the machine deployment you want to edit.

![Update AKS Machine Deployment](@/images/main/tutorials/external-clusters/edit-md.png "Update AKS Machine Deployment")

- Upgrade Kubernetes Version. Select the Kubernetes Version from the dropdown to upgrade the machine deployment.

- Scale the replicas: In the popup dialog, you can increase or decrease the number of worker nodes that are managed by this machine deployment.

![Update AKS Machine Deployment](@/images/main/tutorials/external-clusters/scale-aks-md.png "Update AKS Machine Deployment")

## Delete Cluster

{{% notice info %}}
Delete operation is not allowed for imported clusters
{{% /notice %}}

Delete cluster operation allows to delete the cluster from the Provider. Click on the `Delete` button.

![Delete Cluster](@/images/main/tutorials/external-clusters/aks-delete-button.png
 "Delete Cluster")

## Delete the Node Pool

{{% notice info %}}
At least one systempool is required in an AKS cluster.
{{% /notice %}}

Navigate to the cluster overview, scroll down to machine deployments and click on the delete icon next to the machine deployment you want to delete.

![Update AKS Machine Deployment](@/images/main/tutorials/external-clusters/delete-md.png "Delete AKS Machine Deployment")

## Cluster State:

{{% notice info %}}
`Provisioning State` is used to indicate AKS Cluster State
This represents the state of the last operation attempted on this node pool, such as scaling the number of nodes or upgrading the Kubernetes version. The nodes may still be running even if this state is showing as 'Failed'. Check previous operations on the node pool to resolve any failures.
{{% /notice %}}

If the cluster is stopped from the Azure side, you will be able to see the current state of the cluster as stopped.
Cluster details will not be visible as the details are fetched using kubeconfig, and the kubeconfig is not available for the stopped cluster.

![AKS Cluster Stopped](@/images/main/tutorials/external-clusters/aks-stopped.png "AKS Cluster Stopped")
