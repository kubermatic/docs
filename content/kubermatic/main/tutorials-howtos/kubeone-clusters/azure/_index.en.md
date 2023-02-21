+++
title = "Azure"
date = 2023-02-21T14:07:15+02:00
description = "Detailed tutorial to help you manage Azure KubeOne cluster using KKP"
weight = 7

+++

## Import Azure Cluster

You can add an existing Azure KubeOne cluster and then manage it using KKP.

- Navigate to `KubeOne Clusters` page.

- Click `Import KubeOne Cluster` button.

![Import KubeOne Cluster](/img/kubermatic/main/tutorials/kubeone_clusters/cluster_list_empty.png "Import KubeOne Cluster")

- Pick `Azure` provider.

![Select Provider](/img/kubermatic/main/tutorials/kubeone_clusters/import_kubeone_cluster.png "Select Provider")

- Provide cluster Manifest config and enter private key to access the KubeOne cluster.

![Cluster Settings](/img/kubermatic/main/tutorials/kubeone_clusters/cluster_settings_step.png "Cluster Settings")

- Provide Credentials in either of the below mentioned ways:
    - Select a pre-created preset which stores the provider specific credentials.

    - Manually enter the credentials `Client ID`, `Client Secret`, `Subscription ID`, `Tenant ID`.

![Azure credentials](/img/kubermatic/main/tutorials/kubeone_clusters/azure_credentials_step.png "Azure credentials")

- Review provided settings and click `Import KubeOne Cluster`.

## Cluster Details Page

After the cluster is import, the KKP controller retrieves the cluster kubeconfig to display all necessary information.
A healthy cluster has `Running` state. Otherwise, the cluster can be in the `Error` state. Move the mouse cursor over the state indicator to get more details.

![Azure cluster](/img/kubermatic/main/tutorials/kubeone_clusters/cluster_details.png "Azure cluster")

## Update Cluster

### Upgrade Cluster Version

When an upgrade for the cluster is available, a little dropdown arrow will be shown beside the `Control Plane Version` on the cluster’s page.
To start the upgrade, choose the desired version from the list of available upgrade versions and click on `Change Version`.

![Upgrade Cluster](/img/kubermatic/main/tutorials/kubeone_clusters/upgrade_cluster.png "Upgrade Cluster")

If the version upgrade is valid, the cluster state will change to `Reconciling`.

## Update the Machine Deployment Version

- Navigate to the cluster overview, scroll down to machine deployments.

- Click on the edit icon next to the machine deployment you want to edit.

![Update Machine Deployment Version](/img/kubermatic/main/tutorials/kubeone_clusters/update_md_list.png "Update Machine Deployment Version")

- Upgrade Kubelet Version. Select the Kubelet Version from the dropdown to upgrade the machine deployment.

![Select Version](/img/kubermatic/main/tutorials/kubeone_clusters/update_md_dialog.png "Select Version")
