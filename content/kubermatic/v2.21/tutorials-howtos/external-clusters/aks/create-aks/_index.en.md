+++
title = "Create an External AKS Cluster"
date = 2022-01-10T14:07:15+02:00
description = "Detailed tutorial to help you create a Kubernetes cluster in AKS and then manage it using KKP"
weight = 7

+++

## Create AKS Cluster:
Create a cluster following these steps:

- Click on `Create External Cluster` button:

![Create External Cluster](/img/kubermatic/v2.21/tutorials/external_clusters/create_external_cluster.png "Create External Cluster")

- Choose "Azure Kubernetes Service" from the supported providers:

![Select AKS Provider](/img/kubermatic/v2.21/tutorials/external_clusters/aks_selection.png "Select AKS Provider")

- Provide the credentials

![Select Preset](/img/kubermatic/v2.21/tutorials/external_clusters/select_preset.png "Select Preset")

- Configure the cluster:

![Configure Cluster](/img/kubermatic/v2.21/tutorials/external_clusters/aks_cluster_settings.png "Configure Cluster")

- Click on `Create External Cluster` button

## Configure the cluster:

### Basic Settings:

- Name: Assign a unique name for this node pool.
- Kubernetes Version: Select the Kubernetes version that should be used for this cluster. You will be able to upgrade this version after creating the cluster.
- Location: Enter The Azure region into which the cluster should be deployed.
- Resource Group: A resource group is a collection of resources that share the same lifecycle, permissions, and policies.
[Authorize Resource Group](https://docs.microsoft.com/en-us/azure/aks/concepts-identity#azure-rbac-to-authorize-access-to-the-aks-resource "Authorize Resource Group")

{{% notice info %}}
Resource Group should have sufficient permissions to manage AKS cluster and to pull the Admin kubeconfig.
{{% /notice %}}

### Primary Node Pool Setting:

{{% notice info %}}
At least one systempool is required in an AKS cluster.
Hence a systempool will be created along with the cluster.
{{% /notice %}}

[Learn more about node pools in Azure Kubernetes Service
Node size](https://docs.microsoft.com/en-gb/azure/aks/use-multiple-node-pools "Learn more about node pools in Azure Kubernetes Service
Node size
")

- Node Pool Name: Assign a unique name for this node pool.
- VM Size: The size of the virtual machines that will form the nodes in the cluster. This cannot be changed after creating the cluster.
- Mode: System Mode will be preselected. `System` node pools are preferred for system pods (used to keep AKS running) and have size and other restrictions to ensure they have enough capacity to run those pods.
- AutoScaling: Autoscaling is recommended for standard configuration.
    Set the minimum and maximum node counts for this node pool. You cannot set a lower minimum than the current node count in the node pool.

## Create Node Pool:

![Add Node Pool](/img/kubermatic/v2.21/tutorials/external_clusters/add_md.png "Add Node Pool")

- Name: The name for this node pool. Node pool must contain only lowercase letters and numbers. For Linux node pools the name cannot be longer than 12 characters, and for Windows node pools the name cannot be longer than 6 characters.
- VM Size: The size of the virtual machines that will form the nodes in this node pool.
- Kubernetes Version: Select the version from the dropdown.
- Count: Number of replicas for the nodepool.
- Mode: Choose between 'system' and 'user' mode for this node pool. System node pools are preferred for system pods (used to keep AKS running) and have size and other restrictions to ensure they have enough capacity to run those pods. User node pools are preferred for your application pods although application pods may be scheduled on system node pools.
- AutoScaling: Autoscaling is recommended for standard configuration.
    Set the minimum and maximum node counts for this node pool. You cannot set a lower minimum than the current node count in the node pool.

![Create Node Pool](/img/kubermatic/v2.21/tutorials/external_clusters/aks_md.png "Create Node Pool")


