+++
title = "etcd Launcher"
weight = 30
+++

etcd Launcher is a lightweight wrapper around the `etcd` binary. It is responsible for reading information from KKP's Kubernetes
API types and flexibly control how the user cluster etcd ring is started.

## Release Timeline

- **v2.15.0**: KKP introduced etcd-launcher as an experimental feature.
- **v2.19.0**: Peer TLS connections have been added to etcd-launcher.
- **v2.22.0**: `EtcdLauncher` feature gate is enabled by default in `KubermaticConfiguration`.


## Comparison to static etcd

Prior to v2.15.0, user cluster etcd ring was based on a static StatefulSet with 3 pods running the etcd ring nodes.

With `etcd-launcher`, the etcd `StatefulSet` is updated to include:
- An init container that is responsible for copying the etcd-launcher into the main etcd pod.
- Additional environment variables used by the etcd-launcher and etcdctl binary for simpler operations.
- A liveness probe to improve stability.
- The pod command is updated to run the `etcd-launcher` binary instead of the etcd server binary.
- TLS encrypted peer connections (etcd node to etcd node communication).

## Global Configuration

The feature can be configured on a global level, e.g. to disable it for the whole KKP installation.

### Enabled by Default

By default, etcd Launcher is enabled because the `EtcdLauncher` feature gate in `KubermaticConfiguration` is defaulted accordingly.
If the feature gate is enabled, the etcd Launcher feature is enabled at the KKP installation level and the cluster feature gate will be
added to all user clusters.

### Disabling etcd Launcher

When etcd Launcher is enabled for all user clusters, the setting is "inherited" into all user clusters. It is not possible to
revert the settings for existing user clusters, but you can revert the changes in your `KubermaticConfiguration` so that new
clusters are not created with etcd-launcher. Just set the feature gate explicitly as shown below:

```yaml
# Snippet, not a complete file!
apiVersion: kubermatic.k8c.io/v1
kind: KubermaticConfiguration
metadata:
  name: <<mykubermatic>>
  namespace: kubermatic
spec:
  # FeatureGates are used to optionally enable certain features.
  featureGates:
    EtcdLauncher: false
```

## For a Specific User Cluster

If the feature gate was disabled explicitly, etcd Launcher can still be configured for individual user clusters.

### Enabling etcd Launcher
In this mode, the feature is only enabled for a specific user cluster. This can be done by editing the object cluster and
enabling the feature gate for `etcdLauncher`:

```bash
$ kubectl edit cluster 27k9rzjzs7
```

Edit the cluster spec to add the `etcdLauncher` feature gate, and set it to `true`:

```yaml
spec:
  features:
    etcdLauncher: true
```

Once the cluster object is updated, The etcd StatefulSet will start updating the etcd ring pods one by one,
replacing the old etcd run command with the etcd-launcher.

### Disabling etcd Launcher

It is not possible to disable etcd Launcher since v2.19.0, as the upgrade of peer connections to TLS changes
membership information of the etcd ring.

## Features

Enabling etcd Launcher enables cluster operators to perform several operational tasks that were not possible before.

### Scaling User Cluster etcd Rings

Without the etcd Launcher feature, the user cluster etcd ring runs as a simple and static 3-node ring.
With etcd-launcher enabled, it is now possible to resize the etcd ring to increase capacity and/or availability for user clusters.

Currently, the supported minimum etcd ring size is 3 nodes. This is required to maintain etcd quorum during operations.
The maximum supported size is 9 nodes, as recommended by etcd upstream.

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

### TLS Peer Connectivity

With etcd Launcher, peer connections between individual etcd nodes within an etcd ring get encrypted with mutual TLS (mTLS).
Be aware that existing etcd clusters (with or without etcd Launcher) will be upgraded to peer TLS connections if the
`etcdLauncher` feature gate is enabled on a cluster.

### Automated Persistent Volume Recovery

The etcd ring is created as a Kubernetes [StatefulSet](https://kubernetes.io/docs/tutorials/stateful-application/basic-stateful-set/).
For each etcd pod, a [PV](https://kubernetes.io/docs/concepts/storage/persistent-volumes/) is automatically created to provide
persistent storage for the pods.

Unfortunately, the Kubernetes StatefulSet controller doesn't automatically handle cases where a PV is unavailable.
This can happen for example if the storage backend is having availability issues or the node running the etcd pod is using network-attached
storage and becomes unavailable. In such cases, manual intervention is required to remove the related PVC and reset the StatefulSet.

With etcd-launcher enabled for a cluster, the recovery process is fully automatic. Once a pod PV becomes unavailable,
a controller will kick-in and remove the PVC and reset the StatefulSet.

{{% notice note %}}
Resetting the etcd StatefulSet means that all etcd nodes in the ring will be restarted. This means that the user cluster API
will have a momentary downtime until the etcd ring is available again.
{{% /notice %}}
