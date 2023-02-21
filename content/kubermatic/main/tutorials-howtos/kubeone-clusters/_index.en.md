+++
title = "KubeOne Clusters"
date = 2023-02-21T14:07:15+02:00
weight = 7

+++

This section describes how to import and manage KubeOne clusters in KKP.
You can import/connect an existing cluster.
- Import: You can import a cluster via credentials. Imported Cluster can be viewed and edited.
  Supported Providers:
  - AWS
  - Google Cloud Provider
  - Azure

The KKP platform uses the provided manifest config.
The KKP backend takes advantage of this manifest to retrieve the cluster's information, nodes, metrics, and events.

## Prerequisites

The following requirements must be met to import a KubeOne cluster:
 - The KubeOne cluster must already exist before you begin the import/connect process. Please refer to the cloud provider documentation for instructions.
 - Make sure the cluster manifest or provider credentials have sufficient rights to manage the cluster (get, list, upgrade,get kubeconfig)

## Import KubeOne Cluster

KKP allows connecting any existing KubeOne cluster to view the cluster's current state.

- To import a KubeOne cluster go to `KubeOne Clusters` page and Click the `Import KubeOne Cluster` button.

![Import KubeOne Cluster](/img/kubermatic/main/tutorials/kubeone_clusters/import_kubeone_cluster.png "Import KubeOne Cluster")

- Select the KubeOne cloud provider. You can import the following KubeOne clusters:

  - [AWS]({{< ref "./aws" >}})
  - [Google Cloud Provider]({{< ref "./gcp" >}})
  - [Azure]({{< ref "./azure" >}})

You can then see the details of the cluster.

![Cluster Details](/img/kubermatic/main/tutorials/kubeone_clusters/cluster_details.png "AWS Cluster")

![KubeOne Cluster List](/img/kubermatic/main/tutorials/kubeone_clusters/cluster_list.png "KubeOne Cluster List")

## Disconnect Cluster

{{% notice info %}}
Disconnect operation does not delete the cluster from the cloud provider.
{{% /notice %}}

You can `Disconnect` a KubeOne cluster by clicking on the disconnect icon next to the cluster you want to disconnect or from the cluster details page.

![Disconnect KubeOne Cluster](/img/kubermatic/main/tutorials/kubeone_clusters/disconnect_cluster_list.png "Disconnect KubeOne Cluster")

![Disconnect KubeOne Cluster on Details Page](/img/kubermatic/main/tutorials/kubeone_clusters/disconnect_cluster_details.png "Disconnect KubeOne Cluster on Details Page")

![Disconnect Dialog](/img/kubermatic/main/tutorials/kubeone_clusters/disconnect_cluster_dialog.png "Disconnect Dialog")
