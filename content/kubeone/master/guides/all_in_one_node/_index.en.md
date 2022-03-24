+++
title = "All In One Node"
date = 2022-03-21T12:13:28+02:00
enableToc = true
+++

Sometimes it's needed to create a one-node-cluster, which will host control
plane components and as well the usual workloads. It's possible to do so with
small tweaks.

The setup of "one node fits all" or all-in-one in general is a [usual KubeOne cluster][kubeone-tutorial],
the only difference would be: removed [taints][taints-glossary] from the Node.

## What is preventing "all in one" by default?

Every control plane Node in the cluster will, by default, have the following
taints, which prevents any "accidental" workloads to land on the control plane
Nodes.

```yaml
- effect: NoSchedule
  key: node-role.kubernetes.io/master
```

So we need to get rid of them.

## How to remove the default control plane taint?

In order to remove the default tains from the control plane Nodes we need to
ether edit the terraform output (in case when it's in use) or to specify empty
tains array in the YAML.

### Drop control plane taints using terraform output

In the `output.tf` file, add `untaint = true` to the `control_plane` like shows
in the diff bellow.

```diff
 output "kubeone_hosts" {
   description = "Control plane endpoints to SSH to"
 
   value = {
     control_plane = {
+      untaint = true
       ...
     }
   }
```

### Drop control plane taints using kubeone config

In case if you don't use terraform but rather write whole config manually:

```diff
 apiVersion: kubeone.k8c.io/v1beta2
 kind: KubeOneCluster
 name: demo-cluster
 
 controlPlane:
   hosts:
     - publicAddress: "x.x.x.1"
       hostname: "k1-cp-1"
+     taints: []
```

[taints-glossary]: https://kubernetes.io/docs/reference/glossary/?core-object=true#term-taint
[kubeone-tutorial]: {{< ref "../../tutorials/creating_clusters/" >}}
