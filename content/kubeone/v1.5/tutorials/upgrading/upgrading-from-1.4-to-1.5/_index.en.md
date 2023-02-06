+++
title = "Upgrading from 1.4 to 1.5"
date = 2022-08-30T12:00:00+02:00
+++

This document contains important upgrade notes for upgrading from KubeOne 1.4
to 1.5. For the complete changelog, please check the
[complete v1.5.0 changelog on GitHub][changelog].

[changelog]: https://github.com/kubermatic/kubeone/blob/main/CHANGELOG/CHANGELOG-1.5.md

## Known Issues

Make sure to familiarize yourself with the known issues in KubeOne 1.5 before
upgrading by checking the [Known Issues document][known-issues].

[known-issues]: {{< ref "../../../known-issues" >}}

## Important Information for RHEL Users on Azure

{{% notice warning %}}
If you have a RHEL-based cluster on Azure, you **MUST** adhere to the following
instructions **BEFORE** upgrading to KubeOne 1.5. Not doing so might result
in a failed upgrade where the cluster networking is broken after the Canal CNI
is updated from v3.22 to 3.23.
{{% /notice %}}

machine-controller v1.43.6 and earlier used in KubeOne 1.4.0-1.4.7 created RHEL
worker nodes with `firewalld` enabled. `firewalld` can conflict with Calico
causing the cluster networking to end up in a broken state when Calico is
updated to a newer version. This issue was fixed in machine-controller v1.43.7
by ensuring that `firewalld` is disabled. **machine-controller v1.43.7 is used
in KubeOne 1.4.8 and newer.**

Before upgrading to KubeOne 1.5, you **MUST**:

- Upgrade to KubeOne 1.4.8
- Run `kubeone apply` without changing the KubeOneCluster manifest or any other
  properties to trigger machine-controller update
- Rollout all RHEL-based MachineDeployments as described in the [Rolling
  Restart MachineDeployments guide][rollout-mds]. This will cause all Machines
  (Nodes) to get recreated

[rollout-mds]: {{< ref "../../../cheat-sheets/rollout-machinedeployment/" >}}

After that is done, you can safely upgrade to KubeOne 1.5.

## Kubernetes Compatibility Changes

KubeOne 1.5 introduces support for Kubernetes 1.24. Support for Kubernetes 1.21
is removed because it reached End-of-Life (EOL) on 2022-06-28.

If you have a Kubernetes cluster running 1.21 or earlier, you need to update to
Kubernetes 1.22 or newer using KubeOne 1.4. For more information, check out
the [Kubernetes compatibility document][k8s-compat].

[k8s-compat]: {{< ref "../../../architecture/compatibility/supported-versions/" >}}

## Changes in the node-role label, nodeSelectors, and taints/tolerations

[KEP 2067][kep-2067] introduced several changes related to the node-role labels
and taints:

- The `node-role.kubernetes.io/master` label is deprecated in 1.20 and removed
  in 1.24. Instead, `node-role.kubernetes.io/control-plane` is applied to all
  Kubernetes 1.20+ clusters upon provisioning and upgrading
- A new taint `node-role.kubernetes.io/control-plane:NoSchedule` is applied
  to all control plane nodes starting with Kubernetes 1.24 upon provisioning and
  upgrading
  - The old taint `node-role.kubernetes.io/master:NoSchedule` is still applied
    to all clusters. The old taint will be removed in Kubernetes 1.25. If you
    have workloads that could/should run on the control plane nodes, those
    workloads **MUST** tolerate both the old and the new taint
  - The affected workloads must be adapted to the new taint **BEFORE** upgrading
    to Kubernetes 1.24, otherwise, some workloads might not run at all or
    properly

Addons managed by KubeOne are adapted to the requirements mentioned above in
KubeOne 1.5. If you override any addons managed by KubeOne, make sure to update
those addons accordingly. It's **strongly recommended** to run `kubeone apply`
without changing the KubeOneCluster manifest or any other properties right
after upgrading KubeOne to 1.5. It's **required** to run `kubeone apply`
without changes before upgrading to Kubernetes 1.24.

Make sure that you adapt all your workloads that use the
`node-role.kubernetes.io/master` label or toleration as described above.
KubeOne 1.5 has a safeguard to prevent upgrading to Kubernetes 1.24 if there are
any workloads that aren't adapted.

[kep-2067]: https://github.com/kubernetes/enhancements/blob/master/keps/sig-cluster-lifecycle/kubeadm/2067-rename-master-label-taint/README.md

## Operating System Manager (OSM) is Enabled By Default

We introduced Operating System Manager (OSM) in KubeOne 1.4 as an optional
addon for managing the user-data used to provision the worker nodes managed
by machine-controller.

OSM has reached GA (v1.0.0) and is now enabled by default for all KubeOne
clusters with machine-controller enabled.

Existing worker nodes will not be migrated to use OSM automatically. The user
needs to manually rollout all MachineDeployments to start using OSM. This can
be done by following the steps described in the [Rolling Restart
MachineDeploments document][rollout-mds].

To learn more about OSM, how it works, and how to use it, we recommend checking
out the following documents:

- [OSM architecture][osm-arch]
- [OSM usage guide][osm-usage]

If you wish to opt-out from using OSM, check out the [OSM usage guide][osm-usage]
for instructions. This is **NOT** recommended because the old approach is
considered as legacy and deprecated, and it'll be removed in a future release.

[osm-arch]: {{< ref "../../../architecture/operating-system-manager/" >}}
[osm-usage]: {{< ref "../../../architecture/operating-system-manager/usage/" >}}

### Flatcar Provisioning Utility

OSM currently supports only Ignition provisioning utility for Flatcar machines.
If you have Flatcar-based MachineDeployments that use the cloud-init
provisioning utility, you need to change the provisioning utility to `ignition`
or leave it empty (defaults to `ignition`). The provisioning utility can be
changed by running `kubectl edit` for each MachineDeployment in the `kube-system`
(e.g. `kubectl edit machinedeployment -n kube-system <name>`), locating the
`provisioningUtility` field, and changing its value as described. KubeOne 1.5
has a safeguard used to prevent enabling OSM if there are any Flatcar-based
MachineDeployments that use the `cloud-init` provisioning utility.

Check out the [OSM usage guide][osm-usage] for more information about migrating
to the `ignition` provisioning utility.

{{% notice note %}}
AWS Flatcar-based MachineDeployments created by KubeOne 1.4 use the `cloud-init`
provisioning utility. Other providers should be using `ignition` unless specified
otherwise.
{{% /notice %}}

## vSphere CSI moved to the `vmware-system-csi` namespace

The vSphere CSI driver got moved from the `kube-system` to the `vmware-system-csi`
namespace in this release. This has been done because the vSphere CSI driver
development team strongly recommends running the CSI driver in its dedicated
namespace. Otherwise, some features might not work at all.

This change shouldn't affect any volumes, PVCs/PVs, or Snapshots. This change
doesn't require any user action.

The CSI driver will be moved to the new namespace upon running `kubeone apply`
for the first time after upgrading to KubeOne 1.5.

## Other Notable Changes

- `workers_replicas` variable has been renamed to
  `initial_machinedeployment_replicas` in example Terraform configs for Hetzner.
- Change default instance size in example Terraform configs for Equinix Metal
  to `c3.small.x86` because `t1.small.x86` is not available any longer. If
  you're using the latest Terraform configs for Equinix Metal with an existing
  cluster, make sure to explicitly set the instance size (`device_type` and
  `lb_device_type`) in `terraform.tfvars` or otherwise your instances might get
  recreated.
- Remove the `hcloud-volumes` StorageClass deployed automatically by Hetzner CSI
  driver in favor of `hcloud-volumes` StorageClass deployed by the
  `default-storage-class` addon. If you're using the `hcloud-volumes`
  StorageClass, make sure that you have the `default-storage-class` addon
  enabled before upgrading to KubeOne 1.5.
- Update secret name for `backup-restic` addon to `kubeone-backups-credentials`.
  Manual migration steps are needed for users running KKP on top of a KubeOne
  installation and using both `backup-restic` addon from KubeOne and
  `s3-exporter` from KKP. Ensure that the `s3-credentials` Secret with keys
  `ACCESS_KEY_ID` and `SECRET_ACCESS_KEY` exists in `kube-system` namespace and
  doesn't have the label `kubeone.io/addon:`. Remove the label if it exists.
  Otherwise, `s3-exporter` won't be functional.

For information about other changes, we recommend checking out the
[changelog][changelog].
