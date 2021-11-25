+++
title = "Etcd Launcher"
weight = 30
+++

Starting with version v2.15.0, KKP introduced etcd-launcher as an experimental feature. Etcd-launcher is a lightweight wrapper around the etcd binary. It's responsible for reading information from KKP API and flexibly control how the user cluster etcd ring is started.

In v2.19.0, peer TLS connections have been added to etcd-launcher. Existing etcd clusters (with or without etcd-launcher) will be upgraded to peer TLS connections if the etcd-launcher feature gate is enabled on a cluster.

### Spec updates
Prior to v2.15.0, user cluster etcd ring was based on a static StatefulSet with 3 pods running the etcd ring nodes.
With etcd-launcher, the etcd StatefulSet is updated to include:
- An init container that is responsible for copying the etcd-launcher into the main etcd pod.
- Additional environment variables used by the etcd-launcher and etcdctl binary for simpler operations.
- A liveness probe to improve stability.
- The pod command is updated to run etcd-launcher binary instead of the etcd server binary.

{{% notice warning %}}
etcd-launcher is an experimental feature. It should not be enabled unless all users clusters are operating nominally. It's possible that a user cluster etcd ring could fail to enable the feature if the etcd ring was not in a stable condition during the update.
{{% /notice %}}

Since this is an experimental feature, it's disabled by default. There are two modes to enable etcd-launcher support:

## Etcd-launcher for all user cluster (Seed level)

#### Enabling etcd-launcher
In this mode, the feature is enabled on the seed-cluster level. The cluster feature flag will be added to all user clusters.

To enable etcd-launcher, the related feature should be enabled in the [Kubermatic CRD]({{< ref "../../../tutorials_howtos/kkp_configuration" >}}). To do that, edit your your KubermaticConfiguration file to include the featureGate:

```yaml
# Snippet, not a complete file!
apiVersion: operator.kubermatic.io/v1alpha1
kind: KubermaticConfiguration
metadata:
  name: <<mykubermatic>>
  namespace: kubermatic
spec:
  # FeatureGates are used to optionally enable certain features.
  featureGates:
    EtcdLauncher:
      enabled: true
```

Next, simply apply the updated CRD:

```bash
$ kubectl apply -f kubermatic_config.yaml
```

This will update the KKP Operator Deployment and enable etcd-launcher for all users clusters.

{{% notice note %}}
Once the seed controller manager is reloaded, all users clusters will get upgraded to use etcd-launcher. In seed clusters with a large number of user clusters, this might take some time depending on the applied `-max-parallel-reconcile` value (default is 10). Refer to the [Prepare for Reconciliation Load]({{< ref "../../../tutorials_howtos/upgrading" >}}) section for more information.
{{% /notice %}}


#### Disabling etcd-launcher
In this mode, to disable etcd-launcher, you need to revert the changes to the `values.yaml` file, and apply again. Additionally, you will need to disable it in each user cluster flag.

To disable etcd-launcher for a specific cluster you need to set the cluster level feature flag to `false`. This can be applied _before_ enabling the feature gate on the seed controller manager to prevent the cluster from being upgraded in the first place.


## Etcd-launcher for a specific user cluster

#### Enabling etcd-launcher
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

Once the cluster object is updated, The etcd StatefulSet will start updating the etcd ring pods one by one. Replacing the old etcd run command with the etcd-launcher.

#### Disabling etcd-launcher
In this mode, to disable etcd-launcher, you can simply remove the feature flag from the cluster spec, or set it to `false`.


# Etcd Launcher Features
Enabling etcd-launcher enables cluster operators to perform several operational tasks that were not possible before. With the the v2.15.0 releases, etcd-launcher provides the following capabilities:

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

Unfortunately, the Kubernetes StatefulSet controller doesn't automatically handle cases where a PV is unavailable. This can happen for example if the storage backend is having availability issues or the node running the etcd pod is using network-attached storage and becomes unavailable. In such cases, manual intervention is required to remove the related PVC and reset the StatefulSet.

With etcd-launcher enabled for a cluster, the recovery process is fully automatic. Once a pod PV becomes unavailable, a controller will kick-in and remove the PVC and reset the StatefulSet.

{{% notice note %}}
Resetting the etcd StatefulSet means that all etcd nodes in the ring will be restarted. This means that the user cluster API will have a momentary downtime until the etcd ring is available again.
{{% /notice %}}
