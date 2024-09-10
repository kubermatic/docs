+++
title = "Create an External EKS Cluster"
date = 2022-01-10T14:07:15+02:00
description = "Detailed tutorial to help you add an existing Kubernetes cluster in EKS"
weight = 7

+++

## Create EKS Cluster

{{% notice info %}}
Creating External cluster does not create node group by default but you can create one by clicking `Add Machine Deployment` once the cluster is created.
{{% /notice %}}

Create a cluster following these steps:

- Click on `Create External Cluster` button:

![Create External Cluster](/img/kubermatic/v2.25/tutorials/external-clusters/create-external-cluster.png "Create External Cluster")

- Choose "Elastic Kubernetes Service" from the supported providers:

![Select AKS Provider](/img/kubermatic/v2.25/tutorials/external-clusters/eks-selection.png "Select EKS Provider")

- Provide the credentials:

![Select Preset](/img/kubermatic/v2.25/tutorials/external-clusters/select-eks-preset.png "Select Preset")

- Configure the cluster:

{{% notice info %}}
Supported kubernetes versions 1.21.0, 1.22.0, 1.23.0, 1.24.0 currently available for new Amazon EKS clusters.
{{% /notice %}}

![Configure Cluster](/img/kubermatic/v2.25/tutorials/external-clusters/eks-settings.png "Configure Cluster")

- Click on `Create External Cluster` button

## Configure the Cluster

### Basic Settings
- Name: Provide a unique name for your cluster
- Kubernetes Version: Select the Kubernetes version for this cluster.
- Cluster Service Role: Select the IAM role to allow the Kubernetes control plane to manage AWS resources on your behalf. This property cannot be changed after the cluster is created.

### Networking
- VPC: Select a VPC to use for your EKS cluster resources

- Subnets: Choose the subnets in your VPC where the control plane may place elastic network interfaces (ENIs) to facilitate communication with your cluster.
{{% notice info %}}
Subnets specified must be in at least two different AZs.
{{% /notice %}}

- Security Groups: Choose the security groups to apply to the EKS-managed Elastic Network Interfaces that are created in your worker node subnets.

Both Subnet and Security Groups list depends on chosen VPC.

## Create EKS NodeGroup

- Click on `Add Machine Deployment`

- Add NodeGroup configurations:

### Basic Settings
- Name: Assign a unique name for this node group.
  The node group name should begin with letter or digit and can have any of the following characters: the set of Unicode letters, digits, hyphens and underscores. Maximum length of 63.
- Kubernetes Version: Cluster Control Plane Version is prefilled.
- Node IAM Role: Select the IAM role that will be used by the node
- Disk Size: Select the size of the attached EBS volume for each node.

### Networking
- VPC: VPC of the cluster is pre-filled.
- Subnet: Specify the subnets in your VPC where your nodes will run.

### Autoscaling
Node group scaling configuration:
- Desired Size: Set the desired number of nodes that the group should launch with initially.
- Max Count: Set the maximum number of nodes that the group can scale out to.
- Min Count: Set the minimum number of nodes that the group can scale in to.

![Add Node Group](/img/kubermatic/v2.25/tutorials/external-clusters/add-md.png "Add Node Group")

![Create Node Group](/img/kubermatic/v2.25/tutorials/external-clusters/create-eks-md.png "Create Node Group")
