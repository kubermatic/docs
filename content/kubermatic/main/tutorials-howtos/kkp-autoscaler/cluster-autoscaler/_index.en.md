+++
title = "Cluster Autoscaler"
date = 2021-08-05T14:07:10+02:00
weight = 8
+++

This section deals with the usage of Kubernetes Cluster Autoscaler in a KKP User Cluster.

## What is a Cluster Autoscaler in Kubernetes?

Kubernetes Cluster Autoscaler is a tool that automatically adjusts the size of the worker’s node up or down depending on the consumption. This means that the cluster autoscaler, for example, automatically scale up a cluster by increasing the node count when there are not enough node resources for cluster workload scheduling and scale down when the node resources have continuously staying idle, or there are more than enough node resources available for cluster workload scheduling. In a nutshell, it is a component that automatically adjusts the size of a Kubernetes cluster so that all pods have a place to run and there are no unneeded nodes.

## KKP Cluster Autoscaler Usage

The Kubernetes Autoscaler in the KKP User cluster automatically scaled up/down when one of the following conditions is satisfied:

* Some pods failed to run in the cluster due to insufficient resources.
* There are nodes in the cluster that have been underutilised for an extended period (10 minutes by default) and can place their Pods on other existing nodes.

## Installing Kubernetes Autoscaler on User Cluster

You can install Kubernetes autoscaler on a running User cluster using the KKP addon mechanism, which is already built into the KKP Cluster dashboard.

**Step 1**

Create a KKP User cluster by selecting your project on the dashboard and click on "Create Cluster". More details can be found on the official [documentation]({{< ref "../../project-and-cluster-management/" >}}) page.

**Step 2**

When the User cluster is ready, check the pods in the `kube-system` namespace to know if any autoscaler is running.

![KKP Dashboard](../images/kkp-autoscaler-dashboard.png?classes=shadow,border "KKP Dashboard")

```bash
$ kubectl get pods -n kube-system
NAME                               READY     STATUS       RESTARTS    AGE
canal-gq9gc                        2/2       Running      0           21m
canal-tnms8                        2/2       Running      0           21m
coredns-666448b887-s8wv8           1/1       Running      0           25m
coredns-666448b887-vldzz           1/1       Running      0           25m
kube-proxy-2whcq                   1/1       Running      0           21m
kube-proxy-tstvd                   1/1       Running      0           21m
node-local-dns-4p8jr               1/1       Running      0           21m
```

As shown above, the cluster autoscaler is not part of the running Kubernetes components within the namespace.

**Step 3**

Add the Autoscaler to the User cluster under the addon section on the dashboard by clicking on the Addons and then `Install Addon.`

![Add Addon](../images/add-autoscaler-addon.png?classes=shadow,border "Add Addon")


Select Cluster Autoscaler:


![Select Autoscaler](../images/select-autoscaler.png?classes=shadow,border "Select Autoscaler")


Select install:


![Select Install](../images/install-autoscaler.png?classes=shadow,border "Select Install")



![Installation Confirmation](../images/autoscaler-confirmation.png?classes=shadow,border "Installation Confirmation")


**Step 4**

Go over to the cluster and check the pods in the `kube-system` namespace using the `kubectl` command.

```bash
$ kubectl get pods -n kube-system
NAME                                    READY           STATUS      RESTARTS    AGE
canal-gq9gc                            	2/2     	      Running   	0           32m
canal-tnms8                           	2/2     	      Running   	0           33m
cluster-autoscaler-58c6c755bb-9g6df   	1/1     	      Running   	0           39s
coredns-666448b887-s8wv8              	1/1     	      Running   	0           36m
coredns-666448b887-vldzz              	1/1     	      Running  		0           36m
```

As shown above, the cluster autoscaler has been provisioned and running.


## Annotating MachineDeployments for Autoscaling


The Cluster Autoscaler only considers MachineDeployment with valid annotations. The annotations are used to control the minimum and the maximum number of replicas per MachineDeployment. You don't need to apply those annotations to all MachineDeployment objects, but only on MachineDeployments that Cluster Autoscaler should consider. Annotations can be set either using the KKP Dashboard or manually with kubectl.

### KKP Dashboard

Annotations can be preconfigured at the time of cluster creation. Just put appropriate values in the Initial Nodes form.

![Set autoscaling annotations while creating cluster](../images/create-autoscaler-annotations.png?classes=shadow,border "Set autoscaling annotations while creating cluster")

If you already have an existing Machine Deployment, open an edit form and scroll down to `Advanced Settings` > `Node Autoscaling`.

![Set autoscaling annotations while editing MD](../images/edit-autoscaler-annotations.png?classes=shadow,border "Set autoscaling annotations while editing Machine Deployment")

### Manual setup

```bash
cluster.k8s.io/cluster-api-autoscaler-node-group-min-size - the minimum number of replicas (must be greater than zero)

cluster.k8s.io/cluster-api-autoscaler-node-group-max-size - the maximum number of replicas
```

You can apply the annotations to MachineDeployments once the User cluster is provisioned and the MachineDeployments are created and running by following the steps below.

**Step 1**

Run the following kubectl command to check the available MachineDeployments:

```bash
$ kubectl get machinedeployments -n kube-system

NAME                        AGE  DELETED REPLICAS AVAILABLEREPLICAS PROVIDER  OS    VERSION
test-cluster-worker-v5drmq 3h56m            2             2           aws    ubuntu 1.19.9
test-cluster-worker-pndqd  3h59m            1             1           aws    ubuntu 1.19.9
```

**Step 2**

The annotation command will be used with one of the MachineDeployments above to annotate the desired MachineDeployments.  In this case, the  `test-cluster-worker-v5drmq` will be annotated, and the minimum and maximum will be set.

### Minimum Annotation

```bash
$ kubectl annotate machinedeployment -n kube-system test-cluster-worker-v5drmq cluster.k8s.io/cluster-api-autoscaler-node-group-min-size="1"

machinedeployment.cluster.k8s.io/test-cluster-worker-v5drmq annotated
```

### Maximum Annotation

```bash
$ kubectl annotate machinedeployment -n kube-system test-cluster-worker-v5drmq cluster.k8s.io/cluster-api-autoscaler-node-group-max-size="5"

machinedeployment.cluster.k8s.io/test-cluster-worker-v5drmq annotated
```


**Step 3**

Check the MachineDeployment description:

```bash
$ kubectl describe machinedeployments -n kube-system test-cluster-worker-v5drmq
Name:         test-cluster-worker-v5drmq
Namespace:    kube-system
Labels:       <none>
Annotations:  cluster.k8s.io/cluster-api-autoscaler-node-group-max-size: 5
              cluster.k8s.io/cluster-api-autoscaler-node-group-min-size: 1
              machinedeployment.clusters.k8s.io/revision: 1
API Version:  cluster.k8s.io/v1alpha1
Kind:         MachineDeployment
Metadata:
  Creation Timestamp:  2021-07-23T11:05:11Z
  Finalizers:
    foregroundDeletion
  Generate Name:  test-cluster-worker-v5drmq
  Generation:     1
  Managed Fields:
    API Version:  cluster.k8s.io/v1alpha1
    Fields Type:  FieldsV1
    fieldsV1:
      F:metadata:
……………………
```

As shown above, the MachineDeployment has been annotated with a minimum of 1 and a maximum of 5. Therefore, the cluster autoscaler will consider only the annotated MachineDeployment on the cluster.

## Edit KKP Autoscaler

To edit KKP Autoscaler, click on the three dots in front of the Cluster Autoscaler in the Addons section of the Cluster dashboard and select edit.

![Edit Autoscaler](../images/edit-autoscaler.png?classes=shadow,border "Edit Autoscaler")


## Delete KKP Autoscaler

You can delete autoscaler from where you edit it above and select delete.

![Delete Autoscaler](../images/delete-autoscaler.png?classes=shadow,border "Delete Autoscaler")


 Once it has been deleted, you can check the cluster to ensure that the cluster autoscaler has been deleted using the command `kubectl get pods -n kube-system`.


## Customize KKP Autoscaler

You can customize the cluster autoscaler addon in order to override the cluster autoscaler deployment definition to set or pass the required flag(s) by following the instructions provided [in the Addons document]({{< relref "../../../architecture/concept/kkp-concepts/addons/#custom-addons" >}}).

* [My cluster is below minimum / above maximum number of nodes, but CA did not fix that! Why?](https://github.com/kubernetes/autoscaler/blob/aff50d773e42f95baaae300f27e3b2e9cba1ea1b/cluster-autoscaler/FAQ.md#my-cluster-is-below-minimum--above-maximum-number-of-nodes-but-ca-did-not-fix-that-why)

* [I'm running cluster with nodes in multiple zones for HA purposes. Is that supported by Cluster Autoscaler?](https://github.com/kubernetes/autoscaler/blob/aff50d773e42f95baaae300f27e3b2e9cba1ea1b/cluster-autoscaler/FAQ.md#im-running-cluster-with-nodes-in-multiple-zones-for-ha-purposes-is-that-supported-by-cluster-autoscaler)


## Summary

That is it! You have successfully deployed a Kubernetes Autoscaler on a KKP Cluster and annotated the desired MachineDeployment, which Autoscaler should consider. Please check the learn more below for more resources on Kubernetes Autoscaler and how to provision a KKP User Cluster.

## Learn More

* Read more on [Kubernetes autoscaler here](https://github.com/kubernetes/autoscaler/blob/main/cluster-autoscaler/FAQ.md#what-is-cluster-autoscaler).
* You can easily provision a Kubernetes User Cluster using [KKP here]({{< relref "../../../tutorials-howtos/project-and-cluster-management/" >}})
