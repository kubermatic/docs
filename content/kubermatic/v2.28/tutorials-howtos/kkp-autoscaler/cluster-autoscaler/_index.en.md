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

- Some pods failed to run in the cluster due to insufficient resources.
- There are nodes in the cluster that have been underutilised for an extended period (10 minutes by default) and can place their Pods on other existing nodes.

## Installing Kubernetes Autoscaler on User Cluster

You can install the Kubernetes autoscaler on a running User Cluster using the KKP application, which is included in the default catalog of the Enterprise Edition.

{{% notice info %}}
The cluster-autoscaler addon is deprecated and should be replaced with the corresponding application. Ensure that the addon is removed from your cluster if it is currently installed.
{{% /notice %}}

### Installing kubernetes autoscaler as an application

The kubernetes autoscaler is from KKP version 2.27 part of the [Default Applications Catalog]({{<ref "../../../architecture/concept/kkp-concepts/applications/default-applications-catalog/" >}}) offering from the KKP(EE) installation.

### Migrating from Addon to Application

To migrate from the Cluster Autoscaler addon to the application, you must first disable reconciliation of the addon. Once this is done, the Autoscaler application will replace the addon automatically, without requiring any additional configuration. Be aware that this is only supported in enterprise edition.

### Installing kubernetes autoscaler

To enable the Cluster Autoscaler, simply enable the Autoscaler option when creating a User Cluster in the wizard, under the Initial Nodes step.

![Enable autoscaler in wizard](../images/enable-autoscaler-app.png?classes=shadow,border "Enable autoscaler in wizard")

Enabling the Autoscaler application will add it to the User Cluster as a system application.
You can modify its configuration values by clicking Edit Application Values.

![Edit Application Values](../images/edit-application-values.png?classes=shadow,border "Edit Application Values")

After clicking Edit Application Values, an Edit dialog will appear where you can customize the configuration values for the application.

![Edit Application Dialog](../images/edit-application-dialog.png?classes=shadow,border "Edit Application Dialog")

## Installing kubernetes autoscaler on existing cluster

To install the Autoscaler application on an existing cluster, simply add it from the Applications section in the User Cluster Details page.

![Add Autoscaler Application](../images/add-application.png?classes=shadow,border "Add Autoscaler Application")

Click Add Application to open the Add Application dialog. In the dialog, select and add the Cluster Autoscaler application.

![Add Application](../images/add-application-dialog.png?classes=shadow,border "Add Application")

After adding the application you can just assign the max/min values for the machine deployments from the edit machine deployment dialog.

## Annotating MachineDeployments for Autoscaling

The Cluster Autoscaler only considers MachineDeployment with valid annotations. The annotations are used to control the minimum and the maximum number of replicas per MachineDeployment. You don't need to apply those annotations to all MachineDeployment objects, but only on MachineDeployments that Cluster Autoscaler should consider. Annotations can be set manually with kubectl.

### Manual setup

```bash
cluster.k8s.io/cluster-api-autoscaler-node-group-min-size - the minimum number of replicas (must be greater than zero)

cluster.k8s.io/cluster-api-autoscaler-node-group-max-size - the maximum number of replicas
```

After the User Cluster is provisioned and its MachineDeployments are created and running, you can apply annotations to the MachineDeployments by following the steps below.

#### Step 1

Run the following kubectl command to check the available MachineDeployments:

```bash
kubectl get machinedeployments -n kube-system

NAME                        AGE  DELETED REPLICAS AVAILABLEREPLICAS PROVIDER  OS    VERSION
test-cluster-worker-v5drmq 3h56m            2             2           aws    ubuntu 1.19.9
test-cluster-worker-pndqd  3h59m            1             1           aws    ubuntu 1.19.9
```

#### Step 2

  The annotation command will be used with one of the MachineDeployments above to annotate the desired MachineDeployments.  In this case, the  `test-cluster-worker-v5drmq` will be annotated, and the minimum and maximum will be set.

### Minimum Annotation

```bash
kubectl annotate machinedeployment -n kube-system test-cluster-worker-v5drmq cluster.k8s.io/cluster-api-autoscaler-node-group-min-size="1"

machinedeployment.cluster.k8s.io/test-cluster-worker-v5drmq annotated
```

### Maximum Annotation

```bash
kubectl annotate machinedeployment -n kube-system test-cluster-worker-v5drmq cluster.k8s.io/cluster-api-autoscaler-node-group-max-size="5"

machinedeployment.cluster.k8s.io/test-cluster-worker-v5drmq annotated
```

#### Step 3

Check the MachineDeployment description:

```bash
kubectl describe machinedeployments -n kube-system test-cluster-worker-v5drmq

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

To modify the KKP Autoscaler configuration, go to the Applications section. Ensure that Show System Applications is enabled, then locate the Autoscaler application in the list and click the Edit button in the top-right corner of its card.

![Edit Autoscaler](../images/edit-application.png?classes=shadow,border "Edit Autoscaler")

## Summary

That is it! You have successfully deployed a Kubernetes Autoscaler on a KKP Cluster and annotated the desired MachineDeployment, which Autoscaler should consider. Please check the learn more below for more resources on Kubernetes Autoscaler and how to provision a KKP User Cluster.

## Learn More

- Read more on [Kubernetes autoscaler here](https://github.com/kubernetes/autoscaler/blob/master/README.md).
- You can easily provision a Kubernetes User Cluster using [KKP here]({{< relref "../../../tutorials-howtos/project-and-cluster-management/" >}})
