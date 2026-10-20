+++
title = "Resetting a Cluster"
date = 2026-10-20T09:00:00+02:00
weight = 19
+++

`kubermatic-virtualization reset` tears down a Kubermatic Virtualization (KubeV) cluster and
returns its nodes to the state they were in before KubeV, so that you can install KubeV on them
again or use them for something else.

{{% notice warning %}}
Reset cannot be undone. It deletes every virtual machine, disk and volume on the cluster, wipes the
Longhorn and Ceph data on the nodes, and removes containerd with every container image and the
Kubernetes packages. Backups in external object storage are not touched.
{{% /notice %}}

## Before You Start

* Use the configuration file the cluster was installed with. Reset reaches the nodes over SSH and
  the cluster through it, the same way `apply` does.
* Every node in the configuration must be reachable over SSH. Remove a node that is gone for good
  from the configuration first; reset then leaves it alone.
* Back up what you want to keep, such as VM backups to external object storage (see
  [VM Backup and Restore]({{< ref "../../tutorials-howtos/vm-backup-restore/" >}})).

## Running Reset

```bash
kubermatic-virtualization reset -f cluster.yaml
```

Reset lists the nodes it is about to wipe and asks for confirmation before it changes anything.

| Flag | Description |
| ---- | ----------- |
| `-f`, `--file` | The KubeV configuration file. Required. |
| `--reboot` | Reboot the nodes once they are clean. This clears what only a reboot clears: the Open vSwitch datapath, and the network devices, routes, policy rules and sysctls Kubernetes and Kube-OVN set in the kernel. |
| `-y`, `--auto-approve` | Skip the confirmation prompt. |
| `--log-file` | Where the detailed log goes. Defaults to `kubermatic-virtualization.log` in the system's temporary directory. |
| `-v`, `--verbose` | Print more detail. |
| `--log-format` | `text` (default) or `json`. |

To reset and reboot the nodes without a prompt, for example in automation:

```bash
kubermatic-virtualization reset -f cluster.yaml --reboot --auto-approve
```

## What Reset Does

1. **Deletes the virtual machines.** VM pools, VMs and their running instances go first, so that
   no VM still holds a volume or a network attachment. In KDP mode, reset first stops the sync
   agent that would copy VMs from KDP back into the cluster.
2. **Uninstalls every Helm release.** Releases you installed yourself go first, then the platform
   from the top down, and the pod network last. Each component removes what it put on the nodes:
   * KubeVirt and CDI remove their workloads and volumes.
   * Longhorn deletes its volumes.
   * Rook deletes the Ceph cluster, and its cleanup jobs wipe `/var/lib/rook` and the disks Ceph
     used on each node. Before that, reset deletes the volume claims still on Ceph and the pods
     using them, so that no node keeps a Ceph volume attached.
   * Kube-OVN gives back the interfaces its provider networks took, and removes Open vSwitch, its
     routes and its firewall rules.

   A release whose uninstall hooks fail is uninstalled without them, and reset tells you so.
3. **Resets Kubernetes** on every node and removes the Kubernetes packages.
4. **Cleans every node.** It removes containerd with every container image, the kubelet's state,
   Longhorn's data in `/var/lib/longhorn` and on the other disks Longhorn used, Ceph's data in
   `/var/lib/rook`, and the files of the CNI plugins, Multus, Open vSwitch, OVN, KubeVirt and
   KubeOne. It also removes the firewall rules of kube-proxy and Kube-OVN, and the Kubernetes and
   Docker package repositories KubeOne added. On a node that has Docker installed, containerd
   stays and only the Kubernetes images are removed.
5. **Reboots the nodes**, with `--reboot`.

Finally, reset removes the files `apply` wrote to the working directory: `kubev-cluster-kubeconfig`
and, with basic authentication, `kubev-basic-auth-credentials`.

## When the Cluster Cannot Be Reached

If the Kubernetes API does not answer, for example because the control plane is already broken,
reset skips steps 1 and 2 and cleans the nodes directly. Two things are then left to you:

* Longhorn disks other than `/var/lib/longhorn` are only wiped on nodes where an earlier reset
  recorded them.
* Ceph's disks are not wiped by Rook. Reset names each disk that still holds Ceph data. Wipe those
  as described in Rook's [teardown guide](https://rook.io/docs/rook/latest/Storage-Configuration/ceph-teardown/#zapping-devices)
  before Ceph or anything else uses them again.

## Stopping and Running Reset Again

Reset can be run again at any time: it picks up where it stopped, whether it failed or was
interrupted. Press Ctrl-C once to stop it at its next step, or twice to stop it at once. When reset
fails, the log file has the details.

## Reading the Summary

At the end, reset prints:

* **Removed from this machine**: the files it removed from the working directory.
* **Worked around**: the problems it got past, such as a release uninstalled without its hooks or
  a disk it could not wipe. Check these.
* **Left in place**: what reset does not undo, listed below for your cluster.

## What Reset Leaves in Place

Reset leaves what lives outside the nodes, and what it cannot know the state of from before KubeV:

* KubeOne's node preparation: swap stays off and its `/etc/fstab` entries removed, ufw or
  firewalld stays disabled, and SELinux stays permissive on RHEL-like nodes.
* With Longhorn: `open-iscsi` and `nfs-common` (`iscsi-initiator-utils` and `nfs-utils` on
  RHEL-like nodes) stay installed and `iscsid` enabled.
* In offline mode: the nodes keep resolving through the configured DNS server, and keep installing
  packages from the configured package repository.
* With an external KDP: KubeV stays registered in KDP, and the VMs users created stay in their KDP
  projects. Remove them with a kcp admin kubeconfig.
* With nested KDP: the SSH key pair `apply` generated for the KDP VMs, on the machine reset runs on.
* A Ceph cluster outside KubeV that Rook connects to in external mode: its data is not touched.
* Until the nodes reboot, the kernel keeps the sysctls, kernel modules, routes and policy rules
  Kubernetes and Kube-OVN set. Reboot the nodes, or run reset with `--reboot`.
