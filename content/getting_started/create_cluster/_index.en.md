+++
title = "Create a cluster"
date = 2018-04-28T12:07:15+02:00
weight = 5
pre = "<b></b>"
+++

## Create a cluster

{{% notice note %}}
You can try setting up a cluster by yourself using our demo at [cloud.kubermatic.io](https://cloud.kubermatic.io)!
{{% /notice %}}

#### Step 1 – Specify the cluster name and Kubernetes version

The cluster name is how you will identify your Kubernetes cluster instance. Choose a name that is easy for you to remember. You must also select your desired Kubernetes version.

![Screenshoft of Kubermatic's first cluster creation wizard page](/img/getting_started/create_cluster/kubermatic_00.png)

![Screenshoft of Kubermatic's first cluster creation wizard page](/img/getting_started/create_cluster/kubermatic_01.png)

#### Step 2 – Choose a cloud provider for your Kubernetes nodes

Choose a cloud provider for your Kubernetes nodes to be deployed by Kubermatic. Your nodes can be placed in any cloud you like.

![Screenshoft of Kubermatic's second cluster creation wizard page](/img/getting_started/create_cluster/kubermatic_02.png)

#### Step 3 – Select the datacenter of your cloud provider

This is the datacenter of your cloud provider. Your worker nodes will get deployed there.

![Screenshoft of Kubermatic's third cluster creation wizard page](/img/getting_started/create_cluster/kubermatic_03.png)

#### Step 4 – Enter your provider credentials and configure your worker nodes

Enter your provider specific credentials so that Kubermatic can configure your worker machines and integrate them into your cluster.

{{% notice tip %}}
This step varies depending on the selected provider! You will be asked for different provider credentials when choosing AWS or Google for example
{{% /notice %}}

![Screenshoft of Kubermatic's fourth cluster creation wizard page](/img/getting_started/create_cluster/kubermatic_04.png)

#### Step 5 – Review your configuration settings and confirm cluster creation

Check wether all your configuration settings are correct and create your cluster!

![Screenshoft of Kubermatic's final cluster creation wizard page](/img/getting_started/create_cluster/kubermatic_05.png)
