+++
title = "Manage a Cluster"
date = 2018-04-28T12:07:15+02:00
weight = 30

+++

## Manage a Cluster

### Cluster Overview

Via the menu item "Manage Cluster" you can display your active clusters.

![Cluster list](/img/master/getting_started/manage_cluster/cluster-list.png)

### Basic Cluster Information

The dashboard provides you with all important cluster information. You can check the status of your master components and worker nodes.

![Cluster details](/img/master/getting_started/manage_cluster/cluster-details.png)

### Adding New Nodes to Your Cluster

You can easily extend your cluster with new worker nodes. Kubermatic will automatically configure them and integrate them into your cluster.

![Add node deployment dialog](/img/master/getting_started/manage_cluster/cluster-add-nd.png)

### Connect to the Cluster

Kubermatic automatically creates your clusters `kubeconfig` file. It can be downloaded using the icon button on the left of the "Add Node Deployment" button.

To connect to your cluster configure `kubectl` command line tool to use your `kubeconfig` file

```bash
export KUBECONFIG=$PWD/<your-config-file>
```

You are now able to proxy into your cluster and run your favorite `kubectl` commands!

```bash
export KUBECONFIG=$(pwd)/<your-config-file>
kubectl get nodes

NAME                          STATUS    ROLES     AGE       VERSION
kubermatic-4js24fv79x-4cqsc   Ready     <none>    1h        v1.10.3
kubermatic-4js24fv79x-r2b9r   Ready     <none>    1h        v1.10.3
kubermatic-4js24fv79x-z2xn5   Ready     <none>    1h        v1.10.3
```
