+++
title = "[Experimental] Etcd Launcher"
weight = 0
+++

Starting with version v2.15.0, KPP introduced etcd-launcher as an expermental feature. Etcd-launcher is a lightweight wrapper around the etcd binary. It's responsible for reading information from KPP API and flixibly control how the user cluster etcd ring is started.

### Spec updates
Prior to v2.15.0, user cluster etcd ring was based on a static StatefulSet with 3 pod running the etcd ring nodes.
With etcd-launcher, the etcd StatefulSet is updated to include:
- An init container that is responsible for copying the etcd-launcher into the main etcd pod.
- Additional environment variables used by the etcd-launcher and etcdctl binary for simpler operations.
- A liveness probe to improve stability.
- The pod command is updated to run etcd-launcher binary instead of the etcd server binary.

{{% notice warning %}}
etcd-launcher is an experimental feature. It should not be enabled unless all users clusters are operating nominally. It's possible that a user cluster etcd ring could fail to enable the feature if the etcd ring was not in a stable condition during the update.
{{% /notice %}}

Since this is an expermental feature, it's disabled by default. There are two modes to enable etcd-launcher support:
## Enable etcd-launcher for a specific user cluster
In this mode, the feature is only enabled for a specific user cluster. This can be done by editing the object cluster and enabling the feature flag for etcd-launcher:

```bash
$ kubectl edit cluster 27k9rzjzs7
```

Edit the cluster spec to add the `etcdLauncher` feature flag, and set it to `true`:

```yaml
spec:
  features:
    etcdLauncher: true
```

Once the cluster object is updated. The etcd StatefulSet will start updating the etcd ring pods one by one. Replacing the old etcd run command with the etcd-launcher.

#### Disabling etcd-launcher
In this mode, to disable etcd-launcher, you can simply remove the feature flag from the cluster spec, or set it to `false`.

## Enable etcd-launcher for all user clusters
In this mode, the feature is enabled on the seed controller manager level. The cluster feature flag will be added to all user clusters.

To enable etcd-launcher, the related feature should be enabled in the seed controller command. To do that, edit your KPP `values.yaml` file to add the feature gate:

```yaml
kubermatic:
  controller:
    featureGates: "EtcdLauncher=true"
```
Next, you need run the kubermatic-installer to update the controller deployment:

```bash
$ ./kubermatic-installer deploy --config kubermatic.yaml --helm-values values.yaml
```
This should update the seed controller manager deployment and enable etcd-launcher for all users clusters.

{{% notice note %}}
Once the seed controller manager is reloaded, all users clusters will get upgraded to use etcd-launcher. In seed clusters with a large number of user clusters, this might take some time depending on the applied `-max-parallel-reconcile` value (default is 10).
{{% /notice %}}


#### Disabling etcd-launcher
In this mode, to disable etcd-launcher, you need to revert the changes to the `values.yaml` file, and apply again. Additionally, you will need to disable it in each user cluster flag.

To disable etcd-launcher for a specific cluster you need to set the cluster level feature flag to `false`. This can be applied _before_ enabling the feature gate on the seed controller manager to prevent the cluster from being upgraded in the first place.


# Etcd Launcher Features
Enabling etcd-launcher enables clusters operators to perform several operational tasks that were not possible before. With the the v2.15.0 releases, etcd-launcher provides the following capabilities:

## Scaling user cluster etcd ring
Prior to version v2.15.0, the user cluster etcd ring ran as a simple and static 3-node ring. With etcd-launcher enabled, it's now possible to resize the etcd ring to increase capacity and/or availability for user clusters.

Currently, the supported minimum etcd ring size is 3 nodes. This is required to maintain etcd quorum during operations. The maximum supported size is 9 nodes, as recommended by etcd upstream.

To resize the etcd ring for a user cluster, you simply need to edit the cluster:

```bash
$ kubectl edit cluster 2j2q98dkzt
```

And set the required size in the cluster spec:

```yaml
spec:
  componentsOverride:
    etcd:
      clusterSize: 5
```

{{% notice warning %}}
The resizing process is currently a disruptive process. Nodes are added/removed one by one and the etcd ring is restarted to add or remove new nodes, which could disrupt the user cluster.
{{% /notice %}}

## Automated Persistent Volume Recovery
The etcd ring is created as a Kubernetes [StatefulSet](https://kubernetes.io/docs/tutorials/stateful-application/basic-stateful-set/). For each etcd pod, a [PV](https://kubernetes.io/docs/concepts/storage/persistent-volumes/) is automatically created to provide persistent storage for the pods.

Unfortunately, the kubernetes StatefulSet controller doesn't automatically handle cases where a PV is unavailable. In that case, manual intervention is required to remove the related PVC and reset the StatefulSet.

With etcd-launcher enabled for a cluster. The recovery process is fully automatic. Once a pod PV becomes unavailable, a controller will kick-in and remove the PVC and reset the StatefulSet.

{{% notice note %}}
Restting the etcd StatefulSet means that all etcd nodes in the ring will be restarted. This means that the user cluster API will have a momentary downtime until the etcd node is available again. 
{{% /notice %}}
