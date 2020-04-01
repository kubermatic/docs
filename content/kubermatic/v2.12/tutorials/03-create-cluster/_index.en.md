+++
title = "Create a New Cluster"
date = 2019-10-23T12:07:15+02:00
weight = 30
pre = "<b></b>"
+++

To create a new cluster, open the Kubermatic dashboard, choose a project, select the menu entry `Clusters` and click the button `Add Cluster` on the top right.

![Overview of cluster creation](03-create-cluster-start.png)
 Enter a name for your cluster and click Next. Here you can also activate [Audit Logging](https://kubernetes.io/docs/tasks/debug-application-cluster/audit/) and [Pod Security Policy](https://kubernetes.io/docs/concepts/policy/pod-security-policy/), assign labels to your cluster, and choose a Kubernetes version.

![Overview of cluster creation](03-create-cluster-choose-name.png)

Choose the cloud provider:

![Menu to choose cloud provider](03-create-cluster-choose-provider.png)

and the datacenter region closest to you:

![Menu to choose datacenter](03-create-cluster-choose-region.png)

In the next step of the installer, enter the API token into the `Provider credentials` field. If you chose DigitalOcean, your view will look like this:

![Overview of cluster settings](03-create-cluster-api-tokens.png)

If you entered a valid API token, your node settings will be pre-filled:

![Overview of cluster settings with prefilled node section](03-create-cluster-node-settings.png)

Scroll down to choose or add an SSH key. You can choose one of the keys you already created for the project, or create a new one.

You can assign labels to your nodes. You can also set [node taints](https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/) which is a property that allows your node to repel certain pods.

The chosen SSH key will be used for authentication for the default user (e.g. `ubuntu` for Ubuntu images) on all worker nodes. When you click on `Next`, you will see a summary and the cluster creation will start after you confirm by clicking `Create`. 

![Cluster details in confirmation screen](03-create-cluster-confirm.png)

You will then be forwarded to the cluster creation page where you can view the cluster creation process:

![Cluster details in creation state](03-create-cluster-creation.png)

After all of the master components are ready, your cluster will create the configured number of worker nodes. Fully created nodes will be marked with a green dot, pending ones with a yellow circle. Clicking on the download icon lets you download the kubeconfig to be able to use `kubectl` with your cluster.
