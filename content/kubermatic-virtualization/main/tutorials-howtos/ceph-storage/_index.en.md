+++
title = "Ceph Storage"
date = 2026-10-20T00:00:00+00:00
weight = 4
+++

This guide sets up <a href="https://ceph.io/" target="_blank" rel="noopener noreferrer">Ceph</a> as
storage for VM disks, on its own or next to Longhorn, and covers its day-2 operations. KubeV runs
Ceph with <a href="https://rook.io/" target="_blank" rel="noopener noreferrer">Rook</a>, on empty
disks of the cluster's own nodes.

KubeV sets Ceph up for block storage. It installs:

* the `ceph-block` StorageClass, which becomes the cluster's default StorageClass;
* a `ceph-block` VolumeSnapshotClass, so VM backups and snapshots work on Ceph;
* the Ceph toolbox, for the `ceph` commands below.

Ceph spreads every VM disk over all the disks of the cluster and keeps copies of it on several
nodes. VM disks on Ceph live-migrate, and a disk cloned from another disk on Ceph is created almost
at once, whatever its size.

## Before You Start

### Disks and Partitions

Ceph stores data only on block devices that hold nothing else: an empty disk, or an empty
partition. Unlike Longhorn, it cannot keep its data in a directory of the system disk, so every
node that is to store Ceph data needs one of these. A node without one still runs Ceph, but stores
no data.

* A disk must be empty: no partitions and no file system. A partition must have no file system.
  Ceph never takes a device that has a file system, and it formats the devices it takes.
* Each disk or partition must be at least 5 GiB. Use SSD or NVMe: Ceph on hard disks is slow for
  VMs.
* Disks and partitions must have names a regular expression can tell apart from the others, such
  as `nvme1n1` and `nvme2n1` for the data disks next to the system disk `nvme0n1`.

List a node's disks and partitions with `lsblk -f`. A disk Ceph can take shows no `FSTYPE` and no
partitions below it, and a partition Ceph can take shows no `FSTYPE`. To clear a disk that was used
before, and whose data you no longer need:

```bash
sudo wipefs --all /dev/nvme1n1
sudo sgdisk --zap-all /dev/nvme1n1
```

#### Nodes with a Single Disk

A node whose only disk holds the operating system can give Ceph a partition of it, if the disk has
unallocated space. Leave space free when you install the operating system, then create a partition
in that space, without a file system:

```bash
# Show the free space on the disk
sudo parted /dev/sda unit GiB print free

# Create a partition from the start of the free space (here 200 GiB) to the end of the disk
sudo parted /dev/sda mkpart primary 200GiB 100%

# The new partition, for example sda2, shows no FSTYPE
lsblk -f /dev/sda
```

Do not create a file system on it. A system disk whose space is all in use, by its partitions or by
an LVM volume group, cannot give Ceph a partition: shrinking the root file system is risky, and XFS
cannot be shrunk at all. Add a disk to such nodes instead.

Ceph on the system disk shares the disk with the operating system, and with Longhorn when it runs
too. That suits test clusters and the move from Longhorn to Ceph. While a VM disk moves from
Longhorn to Ceph, it needs room on both.

### Nodes

Ceph keeps each copy of the data on a different node, and keeps 3 copies by default. Production
clusters need at least 3 nodes with matching disks. A cluster of fewer nodes must set `replicas` to
1 or 2, which suits test clusters only: a failed node can then take data with it. With fewer than 3
nodes, Ceph also runs a single monitor, and every Ceph volume goes offline when its node fails.

Ceph runs on every node, the control plane included. A node without a matching disk runs Ceph's
monitors and managers, but stores no data.

### Resources

Ceph's daemons run next to the VMs and take their share of the nodes:

| Daemon | Where | Requests |
|---|---|---|
| OSD | one for each disk Ceph takes | 1 CPU, 4 GiB of memory |
| Monitor | three, or one on clusters of fewer than 3 nodes | 1 CPU, 1 GiB of memory |
| Manager | two, or one on a single-node cluster | 0.5 CPU, 512 MiB of memory |

### Network

Ceph uses the nodes' own network, not the Kube-OVN overlay. Every write is copied to as many nodes
as Ceph keeps copies, so give the nodes at least 10 GbE.

## Enabling Ceph

Add `ceph` to the `storage` section of the configuration file, with a filter that matches the data
disks:

```yaml
storage:
  ceph:
    deviceFilter: "^nvme[1-9]n1$"
```

`deviceFilter` is matched against the disk and partition names `lsblk` shows, without `/dev/`. The
filter is the same for every node, and each node matches it against its own disks and partitions,
so one filter can name different devices on different nodes. Some examples:

| Filter | Matches |
|---|---|
| `^nvme[1-9]n1$` | `nvme1n1` to `nvme9n1`, but not the system disk `nvme0n1` |
| `^sd[b-z]$` | `sdb` to `sdz`, but not the system disk `sda` |
| `^(sdb\|sdc)$` | `sdb` and `sdc` |
| `^(nvme1n1p3\|sda2)$` | the partition `nvme1n1p3` on the nodes that have it, and `sda2` on the others |

Ceph takes every empty disk and partition that matches, on every node. Keep the filter as narrow
as the names allow, so that it does not also match an empty device on another node that you meant
to keep for something else.

Then apply the configuration:

```bash
kubermatic-virtualization apply -f cluster.yaml
```

After installing Ceph, the installer waits until Ceph serves storage: its pool is ready, and Ceph
stores data on as many nodes as it keeps copies. This takes a few minutes. When Ceph cannot take
enough disks, `apply` stops after 20 minutes and says how many nodes Ceph found disks on.

See [Storage]({{< ref "../../configuration-guide#storage" >}}) in the Configuration Guide for all
the fields.

## Running Ceph Next to Longhorn

Ceph and Longhorn can run in the same cluster:

```yaml
storage:
  longhorn: {}
  ceph:
    deviceFilter: "^nvme[1-9]n1$"
```

* `ceph-block` becomes the default StorageClass, and `longhorn` stays. VM disks that do not name a
  StorageClass go to Ceph. Disks already on Longhorn stay there.
* The filter must not match `sd` names. Longhorn attaches its volumes to the nodes as `sd` disks,
  and a blank one could match. The installer warns about such a filter.
* With [KDP]({{< ref "../../kdp-integration" >}}) installed on the same cluster, KDP's own volumes
  stay on Longhorn. On Ceph alone, they go to Ceph. `apply` refuses a storage change that would move
  them, because a volume cannot change its StorageClass.

### Moving VMs from Longhorn to Ceph

KubeV does not move disks between storage on its own. To move a VM's disk, give the VM a disk on
`ceph-block` in place of the Longhorn one, either by
<a href="https://kubevirt.io/user-guide/storage/volume_migration/" target="_blank" rel="noopener noreferrer">migrating the volume</a>
while the VM runs, or by restoring a backup to `ceph-block`.

Once no volume is left on Longhorn, remove `longhorn` from the configuration and apply it. `apply`
refuses to remove Longhorn while volumes are still on it.

## Checking Ceph

```bash
# Rook's view of the cluster
kubectl -n rook-ceph get cephcluster,cephblockpool

# Ceph's own view: health, monitors, disks and capacity
kubectl -n rook-ceph exec deploy/rook-ceph-tools -- ceph status
kubectl -n rook-ceph exec deploy/rook-ceph-tools -- ceph osd tree
kubectl -n rook-ceph exec deploy/rook-ceph-tools -- ceph df
```

When Ceph takes fewer disks than expected, the logs of the `rook-ceph-osd-prepare` pods say which
disks Rook skipped, and why:

```bash
kubectl -n rook-ceph logs -l app=rook-ceph-osd-prepare --tail=-1
```

## Day-2 Operations

### Capacity

Usable space is the raw space of the disks divided by the number of copies. Ceph warns when a disk
is 85% full and stops all writes, for every VM on Ceph, at 95%. Keep it below about 75%, and add
disks or nodes before it fills up.

### Adding Disks and Nodes

Add a node to the configuration and apply it. Rook finds the node's matching disks on its own. A
disk added to a node that is already in the cluster is found when Rook next looks at the cluster.
To make it look now, restart its operator:

```bash
kubectl -n rook-ceph rollout restart deploy/rook-ceph-operator
```

Ceph then spreads the existing data over the new disks, which slows VM disks down for a while.

### Removing Nodes and Replacing Disks

Before you remove a node from the configuration, or replace a failed disk, take its disks out of
Ceph as Rook's
<a href="https://rook.io/docs/rook/latest/Storage-Configuration/Advanced/ceph-osd-mgmt/" target="_blank" rel="noopener noreferrer">OSD management guide</a>
describes, and let Ceph copy their data elsewhere first. Removing a node with data on it can leave
Ceph without enough copies, or without some data.

A cluster that goes below 3 nodes must also lower `replicas`: `apply` refuses a configuration that
keeps more copies than there are nodes.

### Removing Ceph

`apply` refuses to remove `ceph` from the configuration while the Ceph cluster KubeV installed
runs, because uninstalling it would take the storage away from every volume on it. Move the
volumes off Ceph and tear the Ceph cluster down as Rook's
<a href="https://rook.io/docs/rook/latest/Storage-Configuration/ceph-teardown/" target="_blank" rel="noopener noreferrer">teardown guide</a>
describes, then remove `ceph` and apply the configuration.

`kubermatic-virtualization reset` tears the whole KubeV cluster down. It deletes the Ceph cluster
and has Rook wipe `/var/lib/rook` and Ceph's disks on every node.

## Limitations

* Ceph serves block storage only. KubeV sets up no shared file system (CephFS) and no object
  storage (S3).
* Ceph runs on the cluster's own nodes. Connecting KubeV to an existing Ceph cluster outside it
  is not supported yet.
* Ceph uses the nodes' main addresses. A separate storage network cannot be configured yet.
* One filter chooses the devices of every node. Choosing different devices for each node, and
  LVM logical volumes, which no filter matches, is not supported yet.
