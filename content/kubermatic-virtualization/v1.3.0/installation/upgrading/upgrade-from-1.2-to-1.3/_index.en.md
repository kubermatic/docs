+++
title = "Upgrading to KubeV v1.3.0"
date = 2026-10-14T09:00:00+02:00
weight = 9
+++

{{% notice note %}}
Upgrading to KubeV v1.3.0 is supported from v1.2.x. If you are on an older release, upgrade
step by step over minor versions first.
{{% /notice %}}

This guide walks you through upgrading a Kubermatic Virtualization (KubeV) installation from
v1.2.x to v1.3.0. Read the full document before starting, then follow the
[general guidelines]({{< ref "../" >}}) (backups, minor-by-minor, repair-before-upgrade).

## What Changes in v1.3.0

The upgrade moves Kubernetes and every platform component to the versions of v1.3.0:

| Component | v1.2.0 | v1.3.0 |
|---|---|---|
| Kubernetes | v1.34.7 | v1.34.11 |
| KubeVirt | v1.6.5 | v1.7.4 |
| KubeVirt CDI | v1.64.0 | v1.65.0 |
| Longhorn | v1.9.1 | v1.10.2 |
| cert-manager | v1.18.5 | v1.21.2 |
| Kyverno | v1.15.3 (chart 3.5.3) | v1.16.4 (chart 3.6.4) |
| MetalLB | v0.15.3 | v0.16.1 |
| Multus CNI | v4.2.3 | v4.2.3 (chart v4.2.4) |
| Kube-OVN | v1.15.16 | v1.15.16 (unchanged) |

`kubermatic-virtualization version` prints the versions a binary installs; for Kyverno and
Multus it prints the chart version.

v1.3.0 also installs components that v1.2.0 did not have:

* **snapshot-controller** with the `snapshot.storage.k8s.io` CRDs, and the VolumeSnapshotClass
  `longhorn-snapshot-vsc` when Longhorn is the storage. Backups of running VMs use them.
* **Forklift**, for migrating VMs from VMware vSphere. Set `migration.enabled: false` to leave
  it out.
* **edge-router-manager**, which runs the edge routers of VPCs.
* the Multus **dynamic networks controller**, which adds and removes network interfaces of
  running VMs.

The `longhorn` StorageClass becomes `migratable`: a new VM disk on a ReadWriteMany block volume
can live-migrate. Existing volumes keep their access mode.

## How the Upgrade Runs

`kubermatic-virtualization apply` upgrades in this order:

1. **Pre-flight checks.** The installer checks the configuration, the registry credentials, the
   service range and which VMs can live-migrate (see
   [VMs That Cannot Live-Migrate](#vms-that-cannot-live-migrate)). A failed check stops the
   upgrade before anything changes.
2. **Control plane nodes**, one at a time: each is cordoned, drained and upgraded with
   `kubeadm upgrade`.
3. **Static worker nodes**, one at a time, in the order of `staticWorkers.hosts`: drained and
   upgraded the same way, or upgraded in place without a drain when they run a VM that cannot
   live-migrate.
4. **Kubelets** on every node, restarted on the new version in place.
5. **Platform components**: the KubeV CRDs, then every Helm release (KubeVirt, CDI, Longhorn,
   cert-manager, Kyverno, MetalLB, Multus, the KubeV components), then the KubeVirt, Kyverno and
   MetalLB configuration.

A drain deletes the pods on the node that no controller manages, such as leftover debug pods;
pods of a Deployment, StatefulSet or DaemonSet come back as usual. The `kubeadm upgrade` of the
control plane nodes also renews their certificates for another year.

The platform components come last on purpose. Until every node is upgraded, the installed
KubeVirt keeps running, so a drain live-migrates VMs between two virt-launchers of the same
version. KubeVirt v1.6 and v1.7 ship QEMU builds that cannot migrate a VM from one to the other,
so a drain into a new KubeVirt would fail.

### VMs That Cannot Live-Migrate

A drain moves a VM off its node with a live migration. A VM cannot live-migrate when, for
example:

* a disk is a ReadWriteOnce volume (the `longhorn` StorageClass of v1.2.0 created ReadWriteOnce
  volumes);
* it is connected to the pod network with a `bridge` interface;
* its eviction strategy is `None`, which tells KubeVirt to shut the VM down on a drain instead of
  migrating it.

Draining a node with such a VM would either wait on it forever or shut it down. The installer
therefore checks every node right before its turn:

* A **static worker** that runs such a VM is **upgraded in place**: it is cordoned while it
  upgrades, but not drained, and its VMs keep running. Workers whose VMs can all live-migrate are
  drained as usual.
* A **control plane node** is always drained. If a control plane node runs such a VM, the
  pre-flight check stops the upgrade and names the VM. Stop the VM or make it live-migratable,
  then run `apply` again.

On a single-node installation no VM has another node to go to, so every running VM has to be
stopped before the upgrade.

## Before You Upgrade

### Provide Registry Credentials

As in v1.2.0, the installer needs credentials for the KubeV images: either the top-level
`imagePullSecret` in `cluster.yaml`, or the `KUBEV_USERNAME` and `KUBEV_PASSWORD` environment
variables. Without them, the pre-flight check stops the upgrade. Air-gapped installations that
pull every image from `offlineSettings` mirrors do not need them.

### Check `networkConfiguration.serviceCIDR`

Up to v1.2.0 the installer did not pass `networkConfiguration.serviceCIDR` on: every cluster
runs its Services in `10.96.0.0/12`, whatever the configuration says. v1.3.0 uses the field, and
because a running cluster cannot move its Services to another range, `apply` compares it with the
cluster's range first and refuses a different one.

Read the range the cluster runs:

```bash
kubectl -n kube-system get configmap kubeadm-config \
  -o jsonpath='{.data.ClusterConfiguration}' | grep serviceSubnet
```

Set `networkConfiguration.serviceCIDR` in `cluster.yaml` to that value, or remove the field.

### Check the Cluster's Health

* Every node is `Ready`:

  ```bash
  kubectl get nodes
  ```

* KubeVirt is deployed and no VM is migrating:

  ```bash
  kubectl -n kubevirt get kubevirt kubevirt -o jsonpath='{.status.phase}{"\n"}'   # Deployed
  kubectl get virtualmachineinstancemigrations -A
  ```

* Every Longhorn volume that is in use is `healthy`, so a drain does not take away its last
  replica:

  ```bash
  kubectl -n longhorn-system get volumes.longhorn.io \
    -o custom-columns=NAME:.metadata.name,STATE:.status.state,ROBUSTNESS:.status.robustness
  ```

* Longhorn v1.10 no longer serves the `v1beta1` API. Every Longhorn CRD must store only
  `v1beta2`, which Longhorn v1.9 already ensures:

  ```bash
  kubectl get crd -o custom-columns=NAME:.metadata.name,STORED:.status.storedVersions | grep longhorn.io
  ```

* On every node that runs Longhorn volumes, `multipathd` leaves Longhorn's disks alone. Ubuntu
  runs `multipathd` by default, and when it claims the disk of a volume that attaches to the node,
  the VM cannot start (see
  [A VM does not start again after a restart](#a-vm-does-not-start-again-after-a-restart)). After
  the upgrade you restart VMs, which attaches their volumes again, so check every worker now:

  ```bash
  multipath -t | grep -A3 '^blacklist'
  ```

  If the output does not contain `devnode "^sd[a-z0-9]+"`, add this to `/etc/multipath.conf`
  and run `systemctl restart multipathd`:

  ```text
  blacklist {
      devnode "^sd[a-z0-9]+"
  }
  ```

### Find the VMs That Cannot Live-Migrate

List every running VM with its node, its eviction strategy and whether KubeVirt can live-migrate
it:

```bash
kubectl get vmi -A -o custom-columns='NAMESPACE:.metadata.namespace,NAME:.metadata.name,NODE:.status.nodeName,EVICTION:.spec.evictionStrategy,MIGRATABLE:.status.conditions[?(@.type=="LiveMigratable")].status,REASON:.status.conditions[?(@.type=="LiveMigratable")].message'
```

A VM with `MIGRATABLE` `False`, or with eviction strategy `None`, keeps running through the
upgrade only on a static worker (see
[VMs That Cannot Live-Migrate](#vms-that-cannot-live-migrate)). Move such VMs off the control
plane nodes, or stop them, before you upgrade. Plan one restart for each of them after the
upgrade, see [Move the VMs to the New KubeVirt](#move-the-vms-to-the-new-kubevirt).

## Run the Upgrade

1. Download the v1.3.0 binary into a directory of its own, so it does not replace the v1.2
   binary:

   ```bash
   ./kubermatic-ee-downloader get kubermatic-virtualization --version v1.3.0 --output ./v1.3.0 \
     --username $KUBEV_USERNAME --password $KUBEV_PASSWORD
   ./v1.3.0/kubermatic-virtualization version
   ```

2. Run `apply` from the directory that holds `cluster.yaml`, since the SSH key paths in it are
   relative to it:

   ```bash
   ./v1.3.0/kubermatic-virtualization apply -f cluster.yaml --verbose
   ```

   The command shows the configuration and asks for confirmation; `--auto-approve` skips the
   question. The detailed log is written to `/tmp/kubermatic-virtualization.log`
   (`--log-file` changes it).

When some VMs cannot live-migrate, the pre-flight check lists them and says that their workers
are upgraded in place. Each such worker is announced again when its turn comes, and at the end
the installer lists the VMs it kept running:

```text
[KubeV] These VMs cannot live-migrate, so a drain would shut them down or wait on them forever:
  • default/db-0 on worker-1: cannot migrate VMI: PVC db-0-disk is not shared, live migration requires that all PVCs must be shared (using ReadWriteMany access mode)
  • default/web-1 on worker-2: eviction strategy None, so a drain shuts it down
[KubeV] Their workers are upgraded in place, without a drain, and the VMs keep running.
...
[KubeV] Upgrading worker worker-1 in place, without a drain, to keep 1 VM running that cannot live-migrate
[KubeV] Upgrading worker worker-2 in place, without a drain, to keep 1 VM running that cannot live-migrate
...
[KubeV] These VMs cannot live-migrate and kept running on their workers through the upgrade:
  • default/db-0 on worker-1: restart it yourself if it must move to a new virt-launcher
  • default/web-1 on worker-2: KubeVirt restarts it by itself if it must move to a new virt-launcher
[KubeV] Once KubeVirt has rolled out, VMs still on a previous virt-launcher carry a label:
          kubectl get vmi -A -l kubevirt.io/outdatedLauncherImage
[KubeV] Restart each of those once, when it suits it: virtctl restart <name> -n <namespace>
```

On a cluster with three control plane nodes and three workers the upgrade takes about 30
minutes: most of it goes to the control plane nodes, a worker upgraded in place takes about a
minute. Do not interrupt the command. If it stops halfway, see
[Troubleshooting](#troubleshooting).

## After the Upgrade

### Verify the Upgrade

```bash
export KUBECONFIG=kubev-cluster-kubeconfig

kubectl get nodes                       # every node on v1.34.11
kubectl -n kubevirt get kubevirt kubevirt \
  -o jsonpath='{.status.phase} {.status.observedKubeVirtVersion}{"\n"}'   # Deployed v1.7.4
kubectl get pods -A | grep -v -E 'Running|Completed'
```

KubeVirt finishes its own update about five minutes after `apply` returns. Investigate any pod
that stays in `ImagePullBackOff`, `CrashLoopBackOff` or `Pending`.

### Upgrade the Longhorn Engine of the Volumes

Longhorn v1.10 is running now, but every volume still runs the v1.9.1 engine: Longhorn upgrades
the engine of existing volumes only when its setting
`concurrent-automatic-engine-upgrade-per-node-limit` is above `0`, and it is `0`. Upgrade the
engines before you restart any VM in [the next step](#move-the-vms-to-the-new-kubevirt), so
that one stop and start per VM moves both the VM and its volumes.

1. Check that every attached volume is `healthy`. Longhorn upgrades an attached, healthy volume
   live, while its VM keeps running, and a detached volume offline. It does not upgrade an
   attached volume that is not healthy, such as one rebuilding a replica, until it is healthy
   again.

   ```bash
   kubectl -n longhorn-system get volumes.longhorn.io \
     -o custom-columns=NAME:.metadata.name,STATE:.status.state,ROBUSTNESS:.status.robustness,ENGINE:.status.currentImage
   ```

2. Let Longhorn upgrade one volume per node at a time:

   ```bash
   kubectl -n longhorn-system patch settings.longhorn.io concurrent-automatic-engine-upgrade-per-node-limit \
     --type merge -p '{"value":"1"}'
   ```

3. Run the command of step 1 again until the engine of every volume ends in
   `longhorn-engine:v1.10.2`. On a cluster with 17 volumes, 10 of them
   attached to running VMs, this took under a minute; no VM restarted, paused or reported an
   I/O error.

4. Switch the automatic upgrade off again:

   ```bash
   kubectl -n longhorn-system patch settings.longhorn.io concurrent-automatic-engine-upgrade-per-node-limit \
     --type merge -p '{"value":"0"}'
   ```

A live upgrade moves a volume's replicas to the new instance manager pods at once, but its engine
keeps running in the v1.9.1 instance manager pod of its node until the volume is detached, for
example while its VM is stopped. Longhorn deletes an old instance manager pod as soon as nothing
runs in it any more, and the v1.9.1 engine image an hour after no volume uses it. Until then
both are expected; they do not affect the volumes.

### Move the VMs to the New KubeVirt

A running VM keeps the virt-launcher, and so the QEMU, it was started with. Once KubeVirt v1.7
is deployed, it moves running VMs to its own virt-launcher by itself:

* a VM that can live-migrate is live-migrated, without downtime;
* a VM that cannot, but whose eviction strategy allows it (`None`, `LiveMigrateIfPossible`, or
  none set), is **restarted** within a minute or two of KubeVirt's update, up to ten VMs a
  minute. It comes back with the same IP address.

A VM that can do neither, typically one with eviction strategy `LiveMigrate` on a ReadWriteOnce
disk, keeps its previous virt-launcher until you restart it. KubeVirt records a `FailedEvict`
warning event on it every minute until then; the VM itself is not affected. At the end of the
upgrade the installer lists the VMs it kept running and says which of them KubeVirt restarts by
itself. Once KubeVirt has rolled out, list the VMs still on a previous virt-launcher:

```bash
kubectl get vmi -A -l kubevirt.io/outdatedLauncherImage
```

Restart each of them once, when it suits the workload, from the KubeV dashboard or with
`virtctl`:

```bash
virtctl restart <vm-name> -n <namespace>
```

A restart that brings the VM back on the same node can keep its volumes attached, and then their
engines stay in the old Longhorn instance manager pod (see
[the previous step](#upgrade-the-longhorn-engine-of-the-volumes)). To move them as well, stop the
VM instead, wait until its volumes are `detached`, and start it again; the outage is a few
seconds longer than a restart:

```bash
virtctl stop <vm-name> -n <namespace>
kubectl -n longhorn-system get volumes.longhorn.io <volume> -o jsonpath='{.status.state}{"\n"}'   # detached
virtctl start <vm-name> -n <namespace>
```

The volume of a VM is the `VOLUME` of its disk's PersistentVolumeClaim
(`kubectl get pvc -n <namespace>`). Engines left in an old instance manager pod do no harm; they
move the next time their volume detaches.

A VM on a previous virt-launcher keeps working, but does not get the fixes of the new KubeVirt
until it restarts.

## Troubleshooting

### The upgrade stopped after the control plane

When `apply` stops after some nodes were upgraded, the nodes report different Kubernetes
versions, and a plain `apply` may find nothing left to upgrade on the control plane. Resume it
with `--force-upgrade`, which runs the upgrade again on every node:

```bash
./v1.3.0/kubermatic-virtualization apply -f cluster.yaml --force-upgrade
```

### A drain does not finish

A node drain waits until every VM on it has live-migrated. When a migration keeps failing, the
drain waits on it. Look at the migrations and the VM's events:

```bash
kubectl get virtualmachineinstancemigrations -A
kubectl describe vmi <vm-name> -n <namespace>
```

A VM that writes to its memory faster than the network can copy it may never finish migrating.
The installer allows KubeVirt to slow such a VM down (auto-converge) before the first drain. If a
migration still does not finish, stop the VM; the drain then goes on, and you start the VM again
after the upgrade.

### A VM does not start again after a restart

The VM stays `Starting`, and its `virt-launcher` pod stays in `Init` with a `FailedMount` event:

```text
MountVolume.MountDevice failed for volume "pvc-..." : rpc error: code = Internal desc = mount failed: exit status 32
... /dev/longhorn/pvc-... already mounted or mount point busy.
```

`multipathd` on the node has claimed the Longhorn disk of the volume. `multipath -ll` on that node
lists it as an `IET,VIRTUAL-DISK` map. Add the blacklist from
[Check the Cluster's Health](#check-the-clusters-health) to `/etc/multipath.conf` and run
`systemctl restart multipathd`, which also releases the disk. The kubelet mounts the volume at
its next retry, within two minutes, and the VM starts.

### The pre-flight check refuses VMs on control plane nodes

```text
[KubeV] ❌ These VMs run on control plane nodes and cannot live-migrate:
```

Stop the listed VMs, or make them live-migratable, and run `apply` again. Nothing was changed.

### `serviceCIDR` does not match the cluster

```text
networkConfiguration.serviceCIDR is 10.100.0.0/16, but the cluster's Services run in 10.96.0.0/12, and an installed cluster can't change its service range: set serviceCIDR to 10.96.0.0/12
```

Set `networkConfiguration.serviceCIDR` to the cluster's range, see
[Check networkConfiguration.serviceCIDR](#check-networkconfigurationservicecidr).
