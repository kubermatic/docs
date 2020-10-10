+++
title = "Manage Worker Nodes via CLI"
date = 2020-01-08T12:07:15+02:00
weight = 100
+++

Worker nodes can be managed via the web dashboard as described [here](../08-manage-node-deployments/). Once you have installed [kubectl](../07-using-kubectl/), you can also manage them via the command line interface (CLI) in order to automate creation, deletion and upgrades of nodes.

## List All Available Nodes

To get a list of all nodes execute:

```bash
kubectl get nodes -o wide
```

Every node is managed by a machine resource in the `kube-system` namespace, which are bundled into machineDeployments (for more information [see documentation](https://github.com/kubernetes-sigs/cluster-api/blob/master/docs/book/src/architecture/controllers/machine-deployment.md)).
To list all machineDeployment resources, execute:

```bash
kubectl get machineDeployments --namespace kube-system
```

## Manage Worker Nodes

If you want to change a machineDeployment, you can edit the machineDeployment resource directly:

```bash
kubectl edit machineDeployment ${machineDeployment} --namespace kube-system
```

When a machineDeployment is edited, the machineController will take care of updating the respective machines. Further explanation to the existing fields and update strategies can be found in the [Cluster API documentation](https://github.com/kubernetes-sigs/cluster-api).
