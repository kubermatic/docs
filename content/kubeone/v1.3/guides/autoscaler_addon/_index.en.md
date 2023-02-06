+++
title = "Using Kubernetes Autoscaler with KubeOne Cluster"
date = 2022-10-22T12:18:15+02:00
+++

This document explains how to use the Kubernetes cluster-autoscaler on the KubeOne cluster. 
## What is a Cluster Autoscaler in Kubernetes?
Cluster Autoscaler is a Kubernetes component that automatically adjusts the size of a Kubernetes cluster so that all pods have a place to run and there are no unneeded nodes. This means that the Autoscaler automatically scales up a cluster by adding new nodes when there are not enough resources for workload scheduling and scales down the cluster by removing existing nodes when there are underutilized nodes. The scaling up happens as soon as there are Pods that can’t be scheduled; while scaling down happens if a node is underutilized for an extended period (10 minutes by default).

## The Prerequisites

Using the Kubernetes Cluster Autoscaler in the KubeOne cluster requires some prerequisites to be met, which are:
* KubeOne 1.3.2 or newer is required
* The worker nodes need to be managed by the Kubermatic machine-controller. Therefore, we recommend checking the [concepts][concepts] document to learn more about how Cluster-API and Kubermatic [machine-controller][machine-controller] work
* A Kubernetes cluster running Kubernetes v1.19 or newer is required

## How It Works

We will use the KubeOne [addons mechanism][addons] to deploy the Cluster Autoscaler, which will use the Cluster-API provider. First, the cluster is autoscaled by increasing/decreasing replicas on the chosen Machinedeployment objects. Once the Machinedeployment is scaled, the Kubermatic machine-controller creates a new instance and joins it to the cluster (if the cluster is scaled up) or deletes one of the existing instances (if the cluster is scaled down). The Machinedeployment object for scaling is chosen randomly from a set of Machinedeployments that have autoscaling enabled. **It is important to note that pending pods will cause autoscaler to upscale while lack of workloads (too many free resources on the nodes) will cause it to downscale.**

## Installing Kubernetes Cluster Autoscaler on KubeOne Cluster

You can either install Kubernetes Cluster Autoscaler when provisioning a new cluster or on an existing KubeOne cluster. Either way, the autoscaler is deployed on the cluster as an addon. 

### Step 1: Preparing the KubeOneCluster Manifest

The cluster-autoscaler add-on which deploys the cluster-autoscaler component is enabled via the KubeOneCluster manifest. If you already have a KubeOne cluster, modify your existing KubeOneCluster manifest to add the `addons` section below.
If you don’t have a KubeOne cluster, check out our [Creating a Cluster using the KubeOne tutorial][cluster-creation] to find out how to provision a KubeOne cluster and create the infrastructure using Terraform. You will then add the `addons` section into the kubeone.yaml manifest file at [step 5][step-5] after you have created your tf.json file and before the cluster provisioning.
The manifest should look like the following: 

kubeone.yaml
```yaml
apiVersion: kubeone.io/v1beta1
kind: KubeOneCluster
versions:
  kubernetes: '1.22.2'   ## kubernetes version
cloudProvider:  ## This field is sourced automatically if terraform is used for the cluster
  aws: {}
addons:
  enable: true
    # Path to the addons directory.
   # We will not use this directory in this tutorial, but the directory must exist regardless.
  # In case when the relative path is provided, the path is relative to the KubeOne configuration file.
  path: “./addons"
  addons:
  - name: cluster-autoscaler
```

### (Optional) Step 2: Modifying the cluster-autoscaler addon

If you wish to change some of the properties, such as timeout for scaling up/down, you’ll need to provide the appropriate command-line flags to cluster-autoscaler. For that, you’ll need to override the cluster-autoscaler addon embedded in the KubeOne binary with your addon.

To find out how to override embedded add-ons, please check the [Addons document][embedded-addons]. For more information regarding available configuration parameters and options, please check the [Cluster Autoscaler FAQ][ca-faq].

### Step 3: Deploying Kubernetes Cluster Autoscaler

The cluster-autoscaler addon can be deployed by running `kubeone apply`. If you’re deploying it to an existing cluster, `kubeone apply` will make sure all resources deployed by KubeOne are up to date and then deploy the addon. If this is a new cluster, this command will also provision the cluster for you.

```bash
$ kubeone apply -m kubeone.yaml -t tf.json
INFO[19:21:58 CEST] Determine hostname...                        
INFO[19:22:02 CEST] Determine operating system...                
INFO[19:22:04 CEST] Running host probes…
+ ensure machinedeployment "kb-cluster-eu-west-3a" with 1 replica(s) exists
	+ ensure machinedeployment "kb-cluster-eu-west-3b" with 1 replica(s) exists
	+ ensure machinedeployment "kb-cluster-eu-west-3c" with 1 replica(s) exists
	+ apply addons defined in "./addons/cluster-autoscaler"
Do you want to proceed (yes/no): yes
INFO[19:31:06 CEST] Patching static pods...                      
INFO[19:31:06 CEST] Patching static pods...                      
INFO[19:31:06 CEST] Patching static pods...                      
INFO[19:31:07 CEST] Downloading kubeconfig...                    
INFO[19:31:07 CEST] Downloading PKI...                           
INFO[19:31:08 CEST] Creating local backup...                      node=172.31.148.48
INFO[19:31:08 CEST] Ensure node local DNS cache...               
INFO[19:31:11 CEST] Activating additional features...            
INFO[19:31:36 CEST] Applying user provided addons...             
INFO[19:31:36 CEST] Applying addon "cluster-autoscaler"...       
INFO[19:31:46 CEST] Applying addons from the root directory...   
INFO[19:31:48 CEST] Creating credentials secret...               
INFO[19:31:50 CEST] Installing machine-controller...
```
 
### Step 4: Ensuring Cluster Access

The remaining steps of this tutorial assume that you have a running cluster and can access it using `kubectl`. If it is a new cluster, KubeOne automatically downloads the Kubeconfig file for the cluster. It’s named as `cluster_name>-kubeconfig`, where `<cluster_name>` is the name provided in the `terraform.tfvars` file. You can use it with kubectl such as:

```
kubectl --kubeconfig=<cluster_name>-kubeconfig
```

or export the KUBECONFIG environment variable:

```
export KUBECONFIG=$PWD/<cluster_name>-kubeconfig
```

### Step 5: Verifying Cluster Autoscaler Deployment

Before proceeding, make sure that cluster-autoscaler is deployed, running and healthy. You can do that using the following `kubectl` command:

```bash
$ kubectl get pod -l app=cluster-autoscaler -n kube-system
NAMESPACE             NAME                               READY   STATUS    RESTARTS   AGE
kube-system   cluster-autoscaler-7556c4f4cc-kqzzr        1/1    Running       0      8m11s
```

If that’s not the case, please make sure to investigate why cluster-autoscaler is not running. You can use the `kubectl describe pod -l app=cluster-autoscaler -n kube-system` command to describe the Pod and check its events. Note that if this is a new cluster, it might take up to 5-10 minutes for worker nodes to join the cluster — you can use `kubectl get nodes` to find out if all nodes are ready and healthy.

## Choosing Machinedeployment objects for Autoscaling

The Cluster Autoscaler only considers Machinedeployment with valid annotations. The annotations are used to control the minimum and the maximum number of replicas per Machinedeployment. You don't need to apply those annotations to all Machinedeployment objects; instead, they can be applied only on Machinedeployments that Cluster Autoscaler should consider.

```bash
cluster.k8s.io/cluster-api-autoscaler-node-group-min-size - the minimum number of replicas(must be greater than zero)

cluster.k8s.io/cluster-api-autoscaler-node-group-max-size - the maximum number of replicas(must be equal greater than min-size)
```

### Step 1: Choose Machinedeployment For Autoscaling

Run the following kubectl command to inspect the available Machinedeployments:

```bash
$ kubectl get machinedeployments -n kube-system
NAME       		        REPLICAS   AVAILABLE-REPLICAS   PROVIDER       OS     KUBELET  AGE
kb-cluster-eu-west-3a      1            1                 aws        ubuntu   1.20.4   10h
kb-cluster-eu-west-3b      1            1                 aws        ubuntu   1.20.4   10h
kb-cluster-eu-west-3c      1            1                 aws        ubuntu   1.20.4   10h
```

### Step 2: Annotate Machinedeployments

Run the following commands to annotate the Machinedeployment object. Make sure to replace the `Machinedeployment` name and `minimum/maximum` size with the appropriate values. In this case, we will use `kb-cluster-eu-west-3b.`

```bash
$ kubectl annotate machinedeployment -n kube-system kb-cluster-eu-west-3b cluster.k8s.io/cluster-api-autoscaler-node-group-min-size="1"
machinedeployment.cluster.k8s.io/kb-cluster-eu-west-3b annotated
```

```bash
$ kubectl annotate machinedeployment -n kube-system kb-cluster-eu-west-3b cluster.k8s.io/cluster-api-autoscaler-node-group-max-size="4"
machinedeployment.cluster.k8s.io/kb-cluster-eu-west-3b annotated
```

### Step 3: Test the Use Case

#### Step A
Check the CPU and memory resources. By default, each Machinedeployment represents a t3.medium instance with 2 vCPU and 4 GB RAM capacity. 

#### Step B
Create a 3-replica Deployment with a container request of 3 GB RAM and check the status. If everything works well,  all the components should be running. 

#### Step C
Scale the Deployment to 4 replicas using the `kubectl scale` command and check the status. For example, the new Pod replica should be pending as shown below due to lack of resources, which will trigger the Autoscaler to scale up the annotated Machinedeployment replicas to 2 from the original 1 and create a new node.

```bash
$ kubectl get pods
NAME                     READY   STATUS    RESTARTS   AGE
nginx-5769cf8f88-6lp7w   0/1    Pending       0       50s
nginx-5769cf8f88-mfqm8   1/1    Running       0       106s
nginx-5769cf8f88-p4kh9   1/1    Running       0       106s
nginx-5769cf8f88-x45l7   1/1    Running       0       106s
```

#### Step D: Check the Machinedeployments:

```bash
$ kubectl get machinedeployments -n kube-system
NAME                   REPLICAS  AVAILABLE-REPLICAS  PROVIDER   OS     KUBELET   AGE
kb-cluster-eu-west-3a     1           1               aws     ubuntu   1.21.5    28m
kb-cluster-eu-west-3b     2           2               aws     ubuntu   1.21.5    28m
kb-cluster-eu-west-3c     1           1               aws     ubuntu   1.21.5    28m
```

Once the annotated machinedeployment replica is ready, check the Pod once again. At this point, the new Pod should be up and running as shown below:

```bash
$ kubectl get pods
NAME                     READY    STATUS    RESTARTS    AGE
nginx-5769cf8f88-6lp7w    1/1     Running      0       3m54s
nginx-5769cf8f88-mfqm8    1/1     Running      0       4m50s
nginx-5769cf8f88-p4kh9    1/1     Running      0       4m50s
nginx-5769cf8f88-x45l7    1/1     Running      0       4m50s
```

#### Step E
Once the Pod is running, check the node with the `kubectl get node` command. If everything works fine, there should be a new node added to the existing nodes. 

```bash
NAME                                            STATUS         ROLES             AGE   VERSION
ip-172-31-10-117.eu-west-3.compute.internal     Ready    control-plane,master    35m   v1.21.5
ip-172-31-10-86.eu-west-3.compute.internal      Ready       <none>               29m   v1.21.5
ip-172-31-11-178.eu-west-3.compute.internal     Ready       <none>               86s   v1.21.5
ip-172-31-11-236.eu-west-3.compute.internal     Ready       <none>               29m   v1.21.5
ip-172-31-11-80.eu-west-3.compute.internal      Ready    control-plane,master    34m   v1.21.5
ip-172-31-12-254.eu-west-3.compute.internal     Ready       <none>               29m   v1.21.5
ip-172-31-12-78.eu-west-3.compute.internal      Ready    control-plane,master    33m   v1.21.5
```

## Summary:
That is it! You have successfully deployed Kubernetes autoscaler on the KubeOne Cluster and annotated the desired Machinedeployment you want the Autoscaler to consider. Please check the learn more below for more resources on Kubernetes Cluster Autoscaler, Kubermatic machine-controller, and KubeOne.

## Learn More

* Read more on [Kubernetes Cluster Autoscaler here][ca-faq-what-is]
* Learn more about Kubermatic machine-controller in the [following guide][machine-controller]
* You can easily provision a Kubernetes cluster using [KubeOne here][cluster-creation]
* You can find more information about deploying addons in the [Addons document][addons].

[concepts]: {{< ref "../../architecture/concepts/" >}}
[machine-controller]: {{< ref "../../guides/machine_controller/" >}}
[addons]: {{< ref "../../guides/addons/" >}}
[cluster-creation]: {{< ref "../../tutorials/creating_clusters/" >}}
[step-5]: {{< ref "../../tutorials/creating_clusters/#step-5" >}}
[embedded-addons]: {{< ref "../../guides/addons/#overriding-embedded-eddons" >}}
[ca-faq]: https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/FAQ.md
[ca-faq-what-is]: https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/FAQ.md#what-is-cluster-autoscaler
