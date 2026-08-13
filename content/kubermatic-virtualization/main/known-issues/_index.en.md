+++
title = "Known Issues"
date = 2026-07-23T00:00:00+00:00
weight = 7
+++

## Overview

This page lists known issues in Kubermatic Virtualization together with their
current status and any available workarounds. Each entry states the versions it
applies to, so you can quickly tell whether your environment is affected.

## Flatcar worker nodes fail to bootstrap on KubeVirt 1.6.x (Ignition not applied)

**Applies to:** Kubermatic Virtualization v1.2.0 and newer (ships KubeVirt
v1.6.5). The underlying defect is present in KubeVirt v1.6.4 and newer.
**Scope:** Flatcar Linux worker nodes only. Ubuntu and other cloud-init based
operating systems are **not** affected.
**Status:** Upstream KubeVirt fix open, not yet released. The machine-controller
workaround is released (v1.66.1, backported to v1.65.5) and bundled in KKP
v2.30.6 and newer (see below).

### Problem

Flatcar-based user-cluster worker VMs start and receive an IP address, but they
never receive their Ignition configuration. As a result `kubeadm` is never
installed, no `bootstrap.service` runs, and the node never joins the user
cluster. Ubuntu worker pools on the same infrastructure provision normally.

### Root Cause

Flatcar receives its provisioning config through a QEMU firmware-config argument
(`-fw_cfg name=opt/com.coreos/config`), which lives in the `qemu:commandline`
section of the VM's libvirt domain. Ubuntu instead uses cloud-init / `noCloud`,
delivered as a disk.

Starting with KubeVirt v1.6.4, the PCIe-hotplug port reservation writes the
libvirt domain definition a second time. That code path performs an XML
round-trip that cannot preserve the `qemu` XML namespace, so the second write
drops the `qemu:commandline` block — and with it the `-fw_cfg` argument that
carries Flatcar's Ignition payload. The VM therefore boots from a definition
that no longer points at its Ignition config. This is an upstream KubeVirt
defect, not a Kubermatic Virtualization or machine-controller bug — the Ignition
data itself is generated and written to disk correctly.

### Workaround

KubeVirt exposes a per-VM annotation, `kubevirt.io/placePCIDevicesOnRootComplex`,
that disables the extra hotplug-port reservation and therefore skips the second
domain write, so the `-fw_cfg` argument is preserved on Flatcar nodes.

machine-controller sets this annotation automatically for Flatcar machines as of
[kubermatic/machine-controller#2057](https://github.com/kubermatic/machine-controller/pull/2057),
released in machine-controller v1.66.1 and backported to v1.65.5.

#### Upgrade KKP to a release that bundles the fix (recommended)

Kubermatic Kubernetes Platform (KKP) v2.30.6 and newer ship machine-controller
v1.65.5, which sets the annotation for you. Upgrade KKP and recreate the affected
Flatcar nodes.

#### Pin the machine-controller image

If you run a KKP v2.30.x release older than v2.30.6 and cannot upgrade yet, pin
machine-controller to the release containing the fix in your
`KubermaticConfiguration`:

```yaml
spec:
  userCluster:
    machineController:
      imageTag: v1.65.5
```

Remove this override once you upgrade to a KKP release that already bundles the
fix.

On KKP v2.29.x and v2.28.x the fix is not part of the bundled machine-controller
line (v1.64.x and v1.62.x respectively). Set the annotation manually instead, as
described below.

#### Set the annotation manually

If you can neither upgrade nor pin machine-controller, set the annotation
`kubevirt.io/placePCIDevicesOnRootComplex` to `"true"` yourself, using one of the
options below.

**Existing user cluster (affected MachineDeployment)**

Patch the `MachineDeployment` in the user cluster (namespace `kube-system`), then
recreate the Flatcar nodes:

```bash
kubectl -n kube-system patch machinedeployment <flatcar-worker-pool> --type merge \
  -p '{"spec":{"template":{"metadata":{"annotations":{"kubevirt.io/placePCIDevicesOnRootComplex":"true"}}}}}'
```

The annotation only takes effect on newly created machines, so existing Flatcar
nodes must be recreated for the fix to apply.

**New user cluster / MachineDeployment**

Add the annotation under `spec.template.metadata.annotations` at creation time,
either in the `MachineDeployment` YAML, or directly from the KKP dashboard during
user cluster or MachineDeployment creation:

```yaml
apiVersion: cluster.k8s.io/v1alpha1
kind: MachineDeployment
metadata:
  name: <flatcar-worker-pool>
  namespace: kube-system
spec:
  template:
    metadata:
      annotations:
        kubevirt.io/placePCIDevicesOnRootComplex: "true"
```

**Note:** The annotation must sit on `spec.template.metadata.annotations`, not the
MD's top-level metadata. This is what reaches the VM.

### Limitations and trade-offs

- **The workaround is Flatcar-specific.** It is applied only to Flatcar machines
  and does not change behaviour for any other operating system.
- **Drawback:** setting `placePCIDevicesOnRootComplex` places all PCI devices on
  the root complex and disables PCIe hotplug for those VMs. This has no practical
  impact on worker nodes, which do not hotplug PCI devices.
- **Temporary.** This is a workaround, not a permanent fix. It should be removed
  once the upstream KubeVirt fix is available in the KubeVirt version shipped
  with Kubermatic Virtualization.

### References

- KubeVirt root-cause issue: [kubevirt/kubevirt#16901](https://github.com/kubevirt/kubevirt/issues/16901)
- KubeVirt fix (open): [kubevirt/kubevirt#18460](https://github.com/kubevirt/kubevirt/pull/18460)
- machine-controller workaround: [kubermatic/machine-controller#2057](https://github.com/kubermatic/machine-controller/pull/2057)
