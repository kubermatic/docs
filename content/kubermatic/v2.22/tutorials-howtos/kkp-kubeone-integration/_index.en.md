+++
title = "KKP KubeOne Integration"
date = 2023-02-21T14:07:15+02:00
weight = 7

+++

This section describes how to import and manage KubeOne clusters in KKP.
We can import/connect an existing KubeOne cluster. Imported Cluster can be viewed and edited.

  Currently Supported Providers:
   - [AWS]({{< ref "./aws" >}})
   - [Google Cloud Provider]({{< ref "./gcp" >}})
   - [Azure]({{< ref "./azure" >}})

## Prerequisites

The following requirements must be met to import a KubeOne cluster:
 - The KubeOne cluster must already exist before we begin the import/connect process.
 - Manifest: KubeOne can define our KubeOne clusters declaratively, in a form of a YAML manifest.
   Run `kubeone config dump -m kubeone.yaml -t tf.json` in our KubeOne terraform directory to get a manifest.
 - Private SSH Key used to create the KubeOne cluster:  KubeOne connects to instances over SSH to perform any management   operation.
 - Provider Specific Credentials used to create the cluster.

 > For more information on the kubeone configurations for different environment, checkout the [Creating the kubernetes Cluster using Kubeone]({{< relref "../../../../kubeone/main/tutorials/creating-clusters/" >}}) documentation.

## Import KubeOne Cluster

KKP allows connecting any existing KubeOne cluster of supported provider to view and edit the cluster's current state.

- To import a KubeOne cluster go to `KubeOne Clusters` page and Click the `Import KubeOne Cluster` button.

![Import KubeOne Cluster](/img/kubermatic/v2.22/tutorials/kubeone_clusters/cluster_list_empty.png "Import KubeOne Cluster")

- Select the KubeOne cloud provider.

![Select Provider](/img/kubermatic/v2.22/tutorials/kubeone_clusters/import_kubeone_cluster.png "Select Provider")


We can then see the details of the cluster.

![Cluster Details](/img/kubermatic/v2.22/tutorials/kubeone_clusters/cluster_details.png "Imported AWS Cluster")

![KubeOne Cluster List](/img/kubermatic/v2.22/tutorials/kubeone_clusters/cluster_list.png "KubeOne Cluster List")

## Cluster Details Page

After the cluster is imported, the KKP controller retrieves the cluster kubeconfig to display all necessary information.
A healthy cluster has `Running` state. Move the mouse cursor over the state indicator to get more details.

## Update Cluster

> KKP supports latest KubeOne code hence supported kubernetes version '>= 1.24'.
We need to use an older KubeOne version to upgrade ou cluster to a supported version using KubeOne cli.
Please refer to the [KubeOne Compatibility section]({{< relref "../../../../kubeone/main/architecture/compatibility/supported-versions/" >}}) docs for more details.

### Upgrade Cluster Version

When an upgrade for the cluster is available, a little dropdown arrow will be shown beside the `Control Plane Version` on the cluster’s page.
To start the upgrade, choose the desired version from the list of available upgrade versions and click on `Change Version`.

![Upgrade Cluster](/img/kubermatic/v2.22/tutorials/kubeone_clusters/upgrade_cluster.png "Upgrade Cluster")

If the version upgrade is valid, the cluster state will change to `Reconciling`.

## Update the Machine Deployment Version

- Navigate to the cluster overview, scroll down to machine deployments.

- Click on the edit icon next to the machine deployment we want to edit.

![Update Machine Deployment Version](/img/kubermatic/v2.22/tutorials/kubeone_clusters/update_md_list.png "Update Machine Deployment Version")

- Upgrade Kubelet Version. Select the Kubelet Version from the dropdown to upgrade the machine deployment.

![Select Version](/img/kubermatic/v2.22/tutorials/kubeone_clusters/update_md_dialog.png "Select Version")

## Disconnect Cluster

{{% notice info %}}
Disconnect operation does not delete the cluster from the cloud provider.
{{% /notice %}}

We can `Disconnect` a KubeOne cluster by clicking on the disconnect icon next to the cluster we want to disconnect or from the cluster details page.

![Disconnect KubeOne Cluster](/img/kubermatic/v2.22/tutorials/kubeone_clusters/disconnect_cluster_list.png "Disconnect KubeOne Cluster")

![Disconnect KubeOne Cluster on Details Page](/img/kubermatic/v2.22/tutorials/kubeone_clusters/disconnect_cluster_details.png "Disconnect KubeOne Cluster on Details Page")

![Disconnect Dialog](/img/kubermatic/v2.22/tutorials/kubeone_clusters/disconnect_cluster_dialog.png "Disconnect Dialog")

## Troubleshoot
To Troubleshoot a failing imported cluster we can `Pause` cluster by editing the external cluster CR.

```bash
# set externalcluster.spec.pause=true
kubectl edit externalcluster xxxxxxxxxx
```

Once we are done, we can reset the `pause` flag on the externalcluster:

```bash
# set externalcluster.spec.pause=false
kubectl edit externalcluster xxxxxxxxxx
```