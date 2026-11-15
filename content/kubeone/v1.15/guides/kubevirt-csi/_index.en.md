+++
title = "KubeVirt CSI Driver"
date = 2026-11-15T12:00:00+02:00
+++

On the KubeVirt provider, KubeOne deploys the [KubeVirt CSI driver][kubevirt-csi-driver] with the `csi-kubevirt`
addon. The driver provisions the volumes of the cluster as DataVolumes in the infra cluster, and hot-plugs them into
the VirtualMachines that run the nodes.

As of v1.15, the addon deploys the driver through [kubevirt-csi-driver-operator][kubevirt-csi-driver-operator]. You
configure the StorageClasses and VolumeSnapshotClasses of the cluster in the KubeOneCluster manifest, and KubeOne keeps
them in sync with it on every `kubeone apply`.

## KubeOne Support

KubeOne supports the following operations:

- Creating StorageClasses backed by StorageClasses of the infra cluster
- Creating VolumeSnapshotClasses backed by VolumeSnapshotClasses of the infra cluster
- Expanding volumes and taking volume snapshots
- Changing and removing configured StorageClasses and VolumeSnapshotClasses with `kubeone apply`, including changes to
  fields that are immutable on a StorageClass
- Migrating clusters that run the KubeVirt CSI driver deployed by previous KubeOne versions

{{% notice warning %}}
The first `kubeone apply` with KubeOne v1.15 on an existing KubeVirt cluster replaces the CSI node plugin. See
[Upgrading Existing Clusters](#upgrading-existing-clusters) before you upgrade.
{{% /notice %}}

## Prerequisites

- The cluster uses the KubeVirt provider (`cloudProvider.kubevirt`), and `cloudProvider.disableBundledCSIDrivers` is
  not set.
- Every StorageClass and VolumeSnapshotClass that you reference already exists in the infra cluster.
- To use volume snapshots, the infra cluster kubeconfig (the `KUBEVIRT_KUBECONFIG` credential) needs `create`, `get`
  and `delete` permissions on `volumesnapshots.snapshot.storage.k8s.io` in the `infraNamespace`. This is only needed if
  you configure `volumeSnapshotClasses`.

## Configuring StorageClasses and VolumeSnapshotClasses

Add `storageClasses` and `volumeSnapshotClasses` to `cloudProvider.kubevirt` in the KubeOneCluster manifest:

```yaml
apiVersion: kubeone.k8c.io/v1beta3
kind: KubeOneCluster
versions:
  kubernetes: "1.37.2"
cloudProvider:
  kubevirt:
    infraNamespace: tenant-a
    storageClasses:
      - infraStorageClassName: standard
        isDefaultClass: true
        volumeBindingMode: WaitForFirstConsumer
        allowVolumeExpansion: true
        reclaimPolicy: Delete
        bus: scsi
      - infraStorageClassName: fast-ssd
        allowVolumeExpansion: true
        zones:
          - zone-a
        labels:
          tier: fast
    volumeSnapshotClasses:
      - infraVolumeSnapshotClass: csi-snapclass
        isDefaultClass: true
        deletionPolicy: Delete
```

The operator names each class after the infra class it's backed by, with a `kubevirt-` prefix. The example above
creates the StorageClasses `kubevirt-standard` and `kubevirt-fast-ssd`, and the VolumeSnapshotClass
`kubevirt-csi-snapclass`.

Both lists are optional. If neither is set, KubeOne deploys the driver but no StorageClass or VolumeSnapshotClass,
and you have to create your own `csi.kubevirt.io` StorageClasses.

### StorageClass Fields

| Field                   | Description                                                                                       | Default     |
|-------------------------|---------------------------------------------------------------------------------------------------|-------------|
| `infraStorageClassName` | Name of the StorageClass in the infra cluster. Required.                                          |             |
| `isDefaultClass`        | Marks the StorageClass as the default StorageClass of the cluster.                                | `false`     |
| `volumeBindingMode`     | `Immediate` or `WaitForFirstConsumer`.                                                            | `Immediate` |
| `allowVolumeExpansion`  | Allows PersistentVolumeClaims of the StorageClass to be expanded.                                 | `false`     |
| `reclaimPolicy`         | `Delete` or `Retain`.                                                                             | `Delete`    |
| `bus`                   | Disk bus used to attach the volumes to the VirtualMachines: `virtio`, `scsi` or `sata`.           |             |
| `zones`                 | Restricts the provisioned volumes to the given zones (`topology.kubernetes.io/zone`).             |             |
| `regions`               | Restricts the provisioned volumes to the given regions (`topology.kubernetes.io/region`).         |             |
| `labels`                | Labels to set on the StorageClass.                                                                |             |

### VolumeSnapshotClass Fields

| Field                      | Description                                                                     | Default  |
|----------------------------|---------------------------------------------------------------------------------|----------|
| `infraVolumeSnapshotClass` | Name of the VolumeSnapshotClass in the infra cluster. Required.                 |          |
| `isDefaultClass`           | Marks the VolumeSnapshotClass as the default VolumeSnapshotClass of the cluster. | `false`  |
| `deletionPolicy`           | `Delete` or `Retain`.                                                           | `Delete` |

See the [API reference][api-reference] for the full specification.

### Validation

KubeOne validates the configuration before it changes anything in the cluster. The validation fails if:

- `infraStorageClassName` or `infraVolumeSnapshotClass` is empty
- an infra class name, with the `kubevirt-` prefix added, isn't a valid DNS subdomain name
- an infra class name appears more than once in the same list
- more than one entry of a list has `isDefaultClass: true`
- `bus`, `volumeBindingMode`, `reclaimPolicy` or `deletionPolicy` has an unsupported value
- `storageClasses` or `volumeSnapshotClasses` is set together with `cloudProvider.disableBundledCSIDrivers: true`.
  Without the bundled CSI driver, nothing would create the classes

## Applying Changes

Run `kubeone apply` after you change `storageClasses` or `volumeSnapshotClasses`. KubeOne waits up to 5 minutes for
the StorageClasses, and then up to 5 more minutes for the VolumeSnapshotClasses, to match the manifest.

The operator can't change most fields of an existing StorageClass, because they're immutable. KubeOne handles this for
you:

- A StorageClass whose `bus`, `volumeBindingMode`, `reclaimPolicy`, `allowVolumeExpansion`, `zones`, `regions` or
  `labels` changed is deleted, and the operator recreates it with the new values.
- A StorageClass or VolumeSnapshotClass removed from the manifest is deleted.
- VolumeSnapshotClasses are updated in place by the operator.

Recreating a StorageClass doesn't affect existing PersistentVolumes, because Kubernetes only reads a StorageClass when
a volume is provisioned or expanded. A new PersistentVolumeClaim of a StorageClass that is being recreated stays
`Pending` until the StorageClass exists again.

{{% notice warning %}}
KubeOne only manages classes created by the operator. StorageClasses and VolumeSnapshotClasses that you created
yourself aren't touched, unless one of them is named `kubevirt-<name>` for a configured entry. The operator adopts such
a class, and KubeOne may delete and recreate it from the manifest.
{{% /notice %}}

## Upgrading Existing Clusters

Previous KubeOne versions deployed the CSI node plugin as the `kube-system/kubevirt-csi-node` DaemonSet. The operator
runs its own node plugin, the `kubevirt-csi-driver/kubevirt-csi-node` DaemonSet. Both use the same host paths, so they
can't run on a node at the same time.

The first `kubeone apply` with KubeOne v1.15 on an existing KubeVirt cluster:

1. Deletes the `kube-system/kubevirt-csi-node` DaemonSet and waits until its pods are gone. Then it deletes the
   `kube-system/kubevirt-csi-node-sa` ServiceAccount, the `kubevirt-csi-node-cr` ClusterRole, the
   `kubevirt-csi-node-binding` ClusterRoleBinding and the `kube-system/driver-config` ConfigMap.
2. Applies the `csi-kubevirt` addon: the operator, the updated CSI controller and the `Tenant` object.
3. Waits until the operator has created the configured StorageClasses and VolumeSnapshotClasses.

Between steps 1 and 2, nodes run no CSI node plugin. Volumes that are already mounted keep working, but new attach,
mount and unmount operations wait until the new node plugin pod is ready on the node. The node plugin images don't
change, so the new pods usually start without pulling images.

Existing PersistentVolumes keep working, because the driver name `csi.kubevirt.io` doesn't change. StorageClasses that
you created yourself keep working as well.

## How It Works

The `csi-kubevirt` addon deploys:

- The `tenants.csiprovisioner.kubevirt.io` CustomResourceDefinition.
- kubevirt-csi-driver-operator, as the `kubevirt-csi-driver/kubevirt-csi-driver-operator` Deployment. If
  `registryConfiguration.overwriteRegistry` is set, the operator pulls the node plugin images from that registry.
- The CSI controller, as the `kube-system/kubevirt-csi-controller` Deployment. It talks to the infra cluster with the
  credentials from the `kube-system/kubeone-ccm-credentials` Secret, and includes the `csi-snapshotter` and
  `csi-resizer` sidecars for snapshots and volume expansion.
- A cluster-scoped `Tenant` object named `tenant`, rendered from `cloudProvider.kubevirt.storageClasses` and
  `cloudProvider.kubevirt.volumeSnapshotClasses`.

From the `Tenant`, the operator creates the `csi.kubevirt.io` CSIDriver, the node plugin DaemonSet in the
`kubevirt-csi-driver` namespace, and the StorageClasses and VolumeSnapshotClasses.

On KubeVirt, KubeOne applies the `csi-kubevirt` addon after the `csi-external-snapshotter` addon, which provides the
snapshot CRDs that the VolumeSnapshotClasses need.

## Troubleshooting

If `kubeone apply` fails while waiting for the StorageClasses or VolumeSnapshotClasses, check the operator logs:

```shell
kubectl logs -n kubevirt-csi-driver deployment/kubevirt-csi-driver-operator
```

If the operator pod isn't running, check that its image can be pulled. When you use a mirror registry, run
`kubeone config images` to list all images that the registry must have.

[kubevirt-csi-driver]: https://github.com/kubevirt/csi-driver
[kubevirt-csi-driver-operator]: https://github.com/kubermatic/kubevirt-csi-driver-operator
[api-reference]: {{< ref "../../references/kubeone-cluster-v1beta3#kubevirtspec" >}}
