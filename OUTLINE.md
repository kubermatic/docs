# Outline
Create and overview and architecture docu for users:

Let's start with the following topics:

* What is Kubermatic
* Architecture
* Features
* Usage
  * Create/delete cluster
  * Add/remove nodes
* Launch Stages (similar https://cloud.google.com/terms/launch-stages or https://dcos.io/docs/1.8/overview/feature-maturity/)

Examples for similar documentations are:
http://docs.rancher.com/rancher/v1.3/en/
https://dcos.io/docs/1.8/overview/
https://docs.docker.com/datacenter/ucp/2.0/guides/

-------------

# What is Kubermatic
Coverage{

* Kubernetes as a service
* No Setup
* No Updating
* We provide scaling
* On every platform, gcloud, aws,do, own hardware

}

Kubermatic provides Kubernetes for your datacenter - so you don't have to worry about it.
We setup your cluster and configure your infrastructure so that you can focus on developing your product.
Kubermatic can connect to different cloud providers such as Amazon Web Services, DigitalOcean, Google Cloud or you can host nodes on your on machines.

# Architecture
Coverage{

* Rely on Kubernetes to manage Kubernetes
  * High AV
  * Stability
* API is on master cluster
* Master speeks with Seed clusters
  * Seed is in local datacenter
  * Seed is self managed
* Seed deploys customer components
  * Customer components are fully managed by Kubernetes
* Drawing

}

Our infrastructure consists of 3 main components, which provide maximal availability, without compromising on flexibility.
#### Main Cluster
Our own main cluster runs all user facing services, such as the API, or the Dashboard. All components run using Kubernetes which makes them fault tolerant and scaleable to support even high load scenarios.

#### Seed Cluster
The Seed cluster runs in a local datacenter such as an Amazon Web Services Region to provide low latency and a more reliable internet connection.
It's purpose is to deploy the final customer clusters.
The Seed cluster itself is also managed by Kubernetes which allows it to take advantage of all its benefits.
The master cluster communicates with a selected Seed cluster to deploy a customer cluster.

### Customer cluster.
The customer cluster provides all needed components to run a Kubernetes cluster such as etcd and the Kubernetes master.
The services will be proxied to the nodes of the customer which are located in their datacenter.

# Features
Coverage{

* Install Kubernetes (obviously)
* Update Kubernetes
* Manage nodes
  * Manage Network
  * Init cloud provider
* Install Addons, comming soon

}

# With Kubermatic you can:
#### Use Kubernetes
Modernize your cloud deployment workflow by using all the advanced features that Kubernetes has to offer.

#### Update Kubernetes
We provide live updates of your Kubernetes cluster without disrupting your daily buissnes.
Use all the new features of Kubernetes as you grow scale.

#### Scale your cluster
By analyzing your usage we can make sure that the cluster scales to support your current requirements.

#### Install addons
With the click of a button youch can launch any application we provide to enhance your development expirience.
The provided addons are managed and monitored by our services so you can drink a coffee ☕️😇 and focus on your actual work.


# Usage
Coverage{

* Pics ....

}
### Login:
Navigate to the Dashboard on `https://beta.kubermatic.io`.
And login usign your Github or Google profile.
![](usage/login.png "")

Click on the `Create Kubernets Cluster` button.
![](usage/startpage.png "")

Type in a name for the cluster.
In this example we use `my-cluster`.

You also have to select the locality of the Seed Cluster.

When you are ready click `Create Kubernets Cluster`
This will create the Kubernetes master components for you.
![](usage/create_cluster.png "")

This is view of your cluster.
Here you can monitor the running components.
At the moment all of our components aren't started so they are blue.
![](usage/wait_cluster.png "")

Wait up to a few minutes until your cluster is ready.
You see when your cluster is redy after all Components are merked green.
![](usage/cluster_ready.png "")

Now Click `Select a cloud provider`.
Here you can select where the actual nodes should be run.
We will choose a DigitalOcean datacenter in Amsterdam to demonstrate the independence of the Seed cluster and the customers nodes.
![](usage/select_provider_1.png "")

We have to provide a DigitalOcean ocean token with `Read` and `Write` access for Kubermatic to create nodes.
We also selcet SSH keys saved in the DigitalOcean account to access them later over SSH.
![](usage/select_provider_2.png "")

Now we can selct the amout and size of nodes to add to the cluster.
![](usage/create_nodes.png "")

Now we have to wait a few minutes for the nodes to become ready.
This will be indicated by showing the nodes as `Node Ready` in the dashboard.
![](usage/wait_node.png "")

We can now download the kubeconfig by clicking `download kubeconfig`
We now use the downloaded kubeconfig to connect over kubectl to our new deployed Kubernetes server.
![](usage/terminal_nodes_list.png "")

Happy Hacking!
