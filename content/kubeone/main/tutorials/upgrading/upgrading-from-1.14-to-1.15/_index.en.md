+++
title = "Upgrading from 1.14 to 1.15"
date = 2026-11-13T12:00:00+02:00
+++

This document contains important upgrade notes for upgrading from KubeOne 1.14 to v1.15. For the complete changelog,
please check the [complete v1.15.0 changelog on GitHub][changelog].

[changelog]: https://github.com/kubermatic/kubeone/blob/main/CHANGELOG/CHANGELOG-1.15.md

## Known Issues

Make sure to familiarize yourself with the known issues in KubeOne 1.15 before upgrading by checking the
[Known Issues document][known-issues].

[known-issues]: {{< ref "../../../known-issues" >}}

## Kubernetes Compatibility Changes

KubeOne 1.15 introduces support for Kubernetes 1.37. Support for Kubernetes 1.34 has been removed. KubeOne 1.15
supports Kubernetes 1.35, 1.36 and 1.37.

If you have a Kubernetes cluster running 1.34 or earlier, you need to update to Kubernetes 1.35 or newer using KubeOne
1.14 before upgrading KubeOne. For more information, check out the [Kubernetes compatibility document][k8s-compat].

[k8s-compat]: {{< ref "../../../architecture/compatibility/supported-versions/" >}}

## cgroup v2 Requirement

Kubernetes deprecated cgroup v1 in 1.35, and starting with that release the kubelet refuses to start on cgroup v1
nodes by default. Since 1.35 is now the oldest Kubernetes version supported by KubeOne, all nodes, both control plane
and workers, must use cgroup v2.

You can check the cgroup version of a node with:

```shell
stat -fc %T /sys/fs/cgroup/
```

The output `cgroup2fs` means cgroup v2, and `tmpfs` means cgroup v1. Nodes still running cgroup v1 must be switched to
cgroup v2 (or replaced with an operating system image that uses it) before upgrading them to Kubernetes 1.35.

More information at https://kubernetes.io/docs/concepts/architecture/cgroups/ and
https://kubernetes.io/docs/reference/node/kernel-version-requirements/.

## PKI Backup Is No Longer Created by Default

`kubeone apply` and `kubeone local` no longer create the `<cluster-name>.tar.gz` PKI backup archive by default. The
archive contains sensitive credentials, such as the cluster CA key, so it's now only created when the `--backup` flag
is set explicitly. If your automation relies on this archive, add the flag to your commands, for example:

```shell
kubeone apply --manifest kubeone.yaml --tfjson tf.json --backup ./<cluster-name>.tar.gz
```

See [#4304](https://github.com/kubermatic/kubeone/pull/4304).

## Addons Are Applied With Server-Side Apply

Addons are now applied using server-side apply instead of `kubectl apply`. On the first `kubeone apply` with KubeOne
1.15:

- KubeOne takes over ownership of the fields that were previously set by client-side apply.
- Objects of the applied kinds that were removed from an addon are pruned.
- Changes made to addon-managed fields outside of KubeOne are overwritten, and this happens on every subsequent
  `kubeone apply` as well.

If you have manually modified any resources deployed by KubeOne addons (embedded or custom), move those changes into
the addon manifests, or into an [addon override][addons], before upgrading. Otherwise, they will be lost.

[addons]: {{< ref "../../../guides/addons" >}}

See [#4272](https://github.com/kubermatic/kubeone/pull/4272).

## Flatcar Linux Update Operator Is Deployed Only for Flatcar Clusters

The `unattended-upgrades` addon now deploys the Flatcar Linux Update Operator only if the cluster has at least one
Flatcar Linux node (control plane, static workers, dynamic workers or MachineDeployments).

On existing clusters without Flatcar nodes, the next `kubeone apply` prunes the `reboot-coordinator` namespace and its
workloads. The cluster-scoped ClusterRoles and ClusterRoleBindings are not removed automatically and can be deleted
manually after the upgrade:

```shell
kubectl delete clusterrolebinding flatcar-linux-update-agent flatcar-linux-update-operator
kubectl delete clusterrole flatcar-linux-update-agent flatcar-linux-update-operator
```

See [#4264](https://github.com/kubermatic/kubeone/pull/4264).

## KubeVirt CSI Driver Operator

The `csi-kubevirt` addon now deploys the KubeVirt CSI Driver operator. On existing KubeVirt clusters, the next
`kubeone apply` replaces the node plugin in the `kube-system` namespace with the DaemonSet managed by the operator.

StorageClasses and VolumeSnapshotClasses are now configured with the `cloudProvider.kubevirt.storageClasses` and
`cloudProvider.kubevirt.volumeSnapshotClasses` fields of the KubeOneCluster manifest. The bus of the KubeVirt
StorageClass now defaults to `scsi`.

See [#4307](https://github.com/kubermatic/kubeone/pull/4307) and
[#4309](https://github.com/kubermatic/kubeone/pull/4309).

## Cilium Hubble Certificates

The `hubble-generate-certs` job of the `cni-cilium` addon now fails if the Cilium CA (`kube-system/cilium-ca` Secret)
would expire before the newly issued certificates. Previously, the job succeeded until the CA had already expired. If
this job fails after the upgrade, rotate the Cilium CA.

See [#4232](https://github.com/kubermatic/kubeone/pull/4232).
