+++
title = "Debugging"
date = 2018-07-24T12:07:15+02:00
weight = 26
chapter = false
+++

## Debugging

### Check if the Kubermatic Kubernetes Platform (KKP) Components Are Running

1. Check on the kubermatic-pods by issuing a `kubectl get pod -n kubermatic`
1. If any of them is not running, execute `kubectl logs -n kubermatic $PODNAME` to find out the issue

The individual components and their purpose are:

* `kubermatic-ui`: Provides the UI
* `kubermatic-api`: Provides the API
* `master-controller`: Sets up access for users to projects and clusters
* `controller-manager`: Creates all the components required for a cluster control plane

### Check for Problems With an Individual User Cluster

1. Find the cluster-id by selecting going to the details view of your cluster in the UI. The URL looks something like this, the cluster id is the last part: `https://kubermatic/projects/project-id/dc/dc-name/clusters/cluster-id`
1. Get the `kubeconfig` for your seed cluster
1. Check if there are any errors in the events for the cluster in question by issuing a `kubectl describe cluster cluster-id`
1. Check if all pods for the cluster are running by executing `kubectl get pods -n cluster-$CLUSTER_ID`
1. If that is not the case, check the log of the pod in quesiton by issuing a `kubectl logs -n cluster-$CLUSTER_ID $PODNAME`
1. If you want to play around with flags or other settings for a pod, you can make KKP stop managing the cluster by running `kubectl edit cluster $CLUSTER_ID` and setting `.spec.pause` to `true`
1. If you want more detailled logs from KKP, you can edit one of its deployments, e.G. `kubectl edit deployment kubermatic-controller-manager-v1 -n kubermatic`, and set the verbosity by adjusting the default of `-v=2` to e.G. `-v=4`

### Check for Problems With Machines for an Individual User Cluster

1. Get the `kubeconfig` to your cluster via the UI
1. Configure `kubectl` to use it by running `export KUBECONFIG=$DOWNLOADED_KUBECONFIG_FILE`
1. Get the machines via `kubectl get machine -n kube-system`
1. Check the events for the machines by running `kubectl describe machine -n kube-system $MACHINE_NAME`
