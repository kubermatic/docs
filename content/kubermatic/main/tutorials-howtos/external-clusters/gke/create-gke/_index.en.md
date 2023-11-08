+++
title = "Create an External GKE Cluster"
date = 2022-01-10T14:07:15+02:00
description = "Detailed tutorial to help you add an existing Kubernetes cluster in GKE and then manage it using KKP"
weight = 7

+++

## Create GKE Cluster

Create a cluster following these steps:

- Click on `Create External Cluster` button:

![Create External Cluster](/img/kubermatic/main/tutorials/external-clusters/create-external-cluster.png "Create External Cluster")

- Choose "Google Kubernetes Engine" from the supported providers:

![Select Provider](/img/kubermatic/main/tutorials/external-clusters/gke-select-provider.png "Select Provider")

- Provide the credentials:

![Select Preset](/img/kubermatic/main/tutorials/external-clusters/select-gke-preset.png "Select Preset")

- Configure the cluster:

![Configure Cluster](/img/kubermatic/main/tutorials/external-clusters/gke-settings.png "Configure Cluster")

- Click on `Create External Cluster` button

### Configure the Cluster

- Name: Provide a unique name for your cluster.
- Zone: Select the cluster zone from the dropdown list.
- Initial Node Count: Number of nodes for the creation of `defaultpool` along with cluster.
- Kubernetes Version: Choose whether you'd like to upgrade the cluster's control plane version manually or let GKE do it automatically.
 - Static Version: Manually manage the version upgrades. GKE will only upgrade the control plane and nodes if it's necessary to maintain security and compatibility, as described in the release schedule.
 - Release Channel: Let GKE automatically manage the cluster's control plane version.
   Release Channel can be of 3 types: Regular (default), Rapid and Stable.
   - Regular: These versions have passed internal validation and are considered production-quality, but don't have enough historical data to guarantee their stability.

   - Rapid: Rapid channel is offered on an early access basis for customers who want to test new releases before they are qualified for production use or general availability. Versions available in the Rapid Channel may be subject to unresolved issues with no known workaround and are not for use with production workloads or subject to any SLAs.

   - Stable: These versions have met all the requirements of the Regular channel and have been shown to be stable and reliable in production, based on the observed performance of running clusters.

### Create Node Pool

![Add Node Pool](/img/kubermatic/main/tutorials/external-clusters/add-md.png "Add Node Pool")

- Name: Enter a unique name for this machine deployment.
- Kubernetes Version: Control Plane Version of Cluster is prefilled.
- Machine Type: Choose the machine family, type, and series that will best fit the resource needs of your cluster. You won't be able to change the machine type for this cluster once it's created.
- Disk Type, Disk Size
- AutoScaling: Autoscaling is recommended for standard configuration.
    Set the minimum and maximum node counts for this node pool. You cannot set a lower minimum than the current node count in the node pool.

![Create Node Pool](/img/kubermatic/main/tutorials/external-clusters/gke-md.png "Create Node Pool")
