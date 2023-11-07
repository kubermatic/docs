
+++
title = "Cluster Autoscaler"
date = 2021-08-05T14:07:10+02:00
weight = 8
+++

This section deals with the usage of Kubernetes Cluster Autoscaler in a KKP User Cluster.

## What is a Cluster Autoscaler in Kubernetes?

Kubernetes Cluster Autoscaler is a tool that automatically adjusts the size of the worker’s node up or down depending on the consumption. This means that the autoscaler, for example, automatically scale up a Cluster by increasing the node count when there are not enough node resources for Cluster workload scheduling and scale down when the node resources have continuously staying idle, or there are more than enough node resources available for Cluster workload scheduling. In a nutshell, it is a component that automatically adjusts the size of a Kubernetes Cluster so that all pods have a place to run and there are no unneeded nodes.

## KKP Cluster Autoscaler Usage

The Kubernetes Autoscaler in the KKP Cluster automatically scaled up/down when one of the following conditions is satisfied:

* Some pods failed to run in the cluster due to insufficient resources.
* There are nodes in the cluster that have been underutilised for an extended period (10 minutes by default) and can place their Pods on other existing nodes.

## Installing Kubernetes Autoscaler on User Cluster

You can install Kubernetes autoscaler on a running User Cluster using the KKP addon mechanism, which is already built into the KKP Cluster dashboard.

**Step 1**

Create a KKP Cluster by selecting your project on the dashboard and click on "Create Cluster". More details can be found on the official [documentation]({{< ref "../project-and-cluster-management/" >}}) page.

**Step 2**

When the Cluster is ready, check the Pods in the kube-system Namespace to know if any Autoscaler is running.

![KKP Dashboard](/img/kubermatic/v2.24/tutorials/cluster-autoscaler/kkp_autoscaler_dashboard.png?classes=shadow,border "KKP Dashboard")

```bash
$ kubectl get pods -n kube-system

NAME                              READY      STATUS    RESTARTS       AGE
canal-gq9gc                        2/2       Running      0           21m

canal-tnms8                        2/2       Running      0           21m

coredns-666448b887-s8wv8           1/1       Running      0           25m

coredns-666448b887-vldzz           1/1       Running      0           25m

kube-proxy-2whcq                   1/1       Running      0           21m

kube-proxy-tstvd                   1/1       Running      0           21m

node-local-dns-4p8jr               1/1       Running      0           21m
```


As shown above, the Autoscaler is not part of the running Kubernetes components within the Namespace.

**Step 3**

Add the Autoscaler to the Cluster under the addon section on the dashboard by clicking on the Addons and then `Install Addon.`

![Add Addon](/img/kubermatic/v2.24/tutorials/cluster-autoscaler/add_autoscaler_addon.png?classes=shadow,border "Add Addon")


Select Cluster Autoscaler:


![Select Autoscaler](/img/kubermatic/v2.24/tutorials/cluster-autoscaler/select_autoscaler.png?classes=shadow,border "Select Autoscaler")


Select install:


![Select Install](/img/kubermatic/v2.24/tutorials/cluster-autoscaler/install_autoscaler.png?classes=shadow,border "Select Install")



![Installation Confirmation](/img/kubermatic/v2.24/tutorials/cluster-autoscaler/autoscaler_confirmation.png?classes=shadow,border "Installation Confirmation")


**Step 4**

Go over to the cluster and check the Pods in the kube-system Namespace using the `kubectl` command.

```bash
$ kubectl get pods -n kube-system

NAME                                   READY              STATUS    RESTARTS        AGE
canal-gq9gc                          	2/2     	      Running   	0           32m

canal-tnms8                           	2/2     	      Running   	0           33m

cluster-autoscaler-58c6c755bb-9g6df   	1/1     	      Running   	0           39s

coredns-666448b887-s8wv8              	1/1     	      Running   	0           36m

coredns-666448b887-vldzz              	1/1     	      Running  		0           36m
```

As shown above, the Autoscaler has been provisioned and running.


## Annotating MachineDeployments for Autoscaling


The Cluster Autoscaler only considers MachineDeployment with valid annotations. The annotations are used to control the minimum and the maximum number of replicas per MachineDeployment. You don't need to apply those annotations to all MachineDeployment objects, but only on MachineDeployments that Cluster Autoscaler should consider. Annotations can be set either using the KKP Dashboard or manually with kubectl.

### KKP Dashboard

Annotations can be preconfigured at the time of cluster creation. Just put appropriate values in the Initial Nodes form.

![Set autoscaling annotations while creating cluster](/img/kubermatic/v2.24/tutorials/cluster-autoscaler/create_autoscaler_annotations.png?classes=shadow,border "Set autoscaling annotations while creating cluster")

If you already have an existing Machine Deployment, open an edit form and scroll down to `Advanced Settings` > `Node Autoscaling`.

![Set autoscaling annotations while editing MD](/img/kubermatic/v2.24/tutorials/cluster-autoscaler/edit_autoscaler_annotations.png?classes=shadow,border "Set autoscaling annotations while editing Machine Deployment")

### Manual setup

```bash
cluster.k8s.io/cluster-api-autoscaler-node-group-min-size - the minimum number of replicas (must be greater than zero)

cluster.k8s.io/cluster-api-autoscaler-node-group-max-size - the maximum number of replicas
```

You can apply the annotations to MachineDeployments once the Cluster is provisioned and the MachineDeployments are created and running by following the steps below.

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

As shown above, the MachineDeployment has been annotated with a minimum of 1 and a maximum of 5. Therefore, the Autoscaler will consider only the annotated MachineDeployment on the Cluster.



## Edit KKP Autoscaler

To edit KKP Autoscaler, click on the three dots in front of the Cluster Autoscaler in the Addons section of the Cluster dashboard and select edit.

![Edit Autoscaler](/img/kubermatic/v2.24/tutorials/cluster-autoscaler/edit_autoscaler.png?classes=shadow,border "Edit Autoscaler")


## Delete KKP Autoscaler

You can delete Autoscaler from where you edit it above and select delete.

![Delete Autoscaler](/img/kubermatic/v2.24/tutorials/cluster-autoscaler/delete_autoscaler.png?classes=shadow,border "Delete Autoscaler")


 Once it has been deleted, you can check the Cluster to ensure that the Autoscaler has been deleted using `kubectl get pods -n kube-system` command.


## Summary

That is it! You have successfully deployed a Kubernetes Autoscaler on a KKP Cluster and annotated the desired MachineDeployment, which Autoscaler should consider. Please check the learn more below for more resources on Kubernetes Autoscaler and how to provision a KKP Cluster.

## Learn More

* Read more on [Kubernetes autoscaler here](https://github.com/kubernetes/autoscaler/blob/main/cluster-autoscaler/FAQ.md#what-is-cluster-autoscaler).
* You can easily provision a Kubernetes Cluster using [KKP here]({{< relref "../../tutorials-howtos/project-and-cluster-management/" >}})
