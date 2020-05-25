+++
title = "Create a Cluster"
date = 2018-04-28T12:07:15+02:00
weight = 20

+++

## Create a Cluster

{{% notice note %}}
You can try setting up a cluster by yourself using our demo at [cloud.kubermatic.io](https://cloud.kubermatic.io)!
{{% /notice %}}

### Step 1 – Select Your Project

Before you can manage clusters or SSH keys, select your current project by using the project list after you logged in or use the dropdown in the top left corner of the page. After choosing the project, the relevant menu items will become active.

![Wizard cluster specification step](/img/2.13/getting_started/manage_projects/projects-list.png)

Go to clusters view by clicking on "Clusters" menu entry and then click on the "Add Cluster" button in the top right corner to go to the cluster wizard.

### Step 2 – Specify the Cluster Name and Kubernetes Version

The cluster name is how you will identify your Kubernetes cluster instance. Choose a name that is easy for you to remember. You must also select your desired Kubernetes version.

![Wizard cluster specification step](/img/2.13/getting_started/create_cluster/wizard-spec.png)

### Step 3 – Choose a Cloud Provider for Your Kubernetes Nodes

Choose a cloud provider for your Kubernetes nodes to be deployed by Kubermatic. Your nodes can be placed in any cloud you like.

![Wizard provider step](/img/2.13/getting_started/create_cluster/wizard-provider.png)

### Step 4 – Select the Datacenter of Your Cloud Provider

This is the datacenter of your cloud provider. Your worker nodes will get deployed there.

![Wizard datacenter step](/img/2.13/getting_started/create_cluster/wizard-dc.png)

### Step 5 – Enter Your Provider Credentials and Configure Your Worker Nodes

Enter your provider specific credentials so that Kubermatic can configure your worker machines and integrate them into your cluster.

{{% notice tip %}}
This step varies depending on the selected provider! You will be asked for different provider credentials when choosing AWS or Google for example.
{{% /notice %}}

![Wizard settings step](/img/2.13/getting_started/create_cluster/wizard-settings.png)

### Step 6 – Review Your Configuration Settings and Confirm Cluster Creation

Check whether all your configuration settings are correct and create your cluster!

![Wizard summary step](/img/2.13/getting_started/create_cluster/wizard-summary.png)

Please note that depending on the capacities in the seed cluster and the chosen cloud provider, cluster creation can take up to a few minutes until your nodes are ready.
