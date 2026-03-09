+++
title = "Debugging"
date = 2018-07-24T12:07:15+02:00
weight = 10
chapter = false
+++

## Debugging

### Check if the Kubermatic Kubernetes Platform (KKP) Components are Running

1. List the kubermatic pods to verify the status by executing the command `kubectl get pod -n kubermatic`.
1. If any of the listed pod is not running status, execute `kubectl logs -n kubermatic $PODNAME` to find out the issue.

The individual components and their purpose are:

* `kubermatic-ui`: Provides the UI.
* `kubermatic-api`: Provides the API.
* `master-controller`: Sets up access for users to projects and clusters.
* `controller-manager`: Creates all the components required for a cluster control plane.

### Check for Problems With an Individual User Cluster

1. Find the cluster-id by navigating to the details view of your cluster in the UI. The URL looks something like this, the cluster id is the last part: `https://kubermatic/projects/project-id/dc/dc-name/clusters/cluster-id`.
1. Get the `kubeconfig` of your seed cluster.
1. Check if there are any errors in the events for your cluster by executing `kubectl describe cluster cluster-id`.
1. Check if all pods for the cluster are in running status by executing `kubectl get pods -n cluster-$CLUSTER_ID`.
1. Check the log of the pod that is not running status by executing `kubectl logs -n cluster-$CLUSTER_ID $PODNAME`.
1. If you want to play around with flags or other settings for a pod, you can make KKP stop managing the cluster by running `kubectl edit cluster $CLUSTER_ID` and setting `.spec.pause` to `true`.
1. If you want more detailed logs from KKP, you can edit one of its deployments, e.G. `kubectl edit deployment kubermatic-controller-manager-v1 -n kubermatic`, and set the verbosity by adjusting the default of `-v=2` to e.g. `-v=4`.

### Check for Problems With Machines for an Individual User Cluster

1. Get the `kubeconfig` of your cluster via the UI.
1. Configure `kubectl` to use it by executing `export KUBECONFIG=$DOWNLOADED_KUBECONFIG_FILE`.
1. Get the machines by executing `kubectl get machine -n kube-system`.
1. Check the events for the machines by executing `kubectl describe machine -n kube-system $MACHINE_NAME`.
