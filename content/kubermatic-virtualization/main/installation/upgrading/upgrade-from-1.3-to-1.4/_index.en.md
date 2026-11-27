+++
title = "Upgrading to KubeV v1.4.0"
date = 2026-11-23T09:00:00+01:00
weight = 8
+++

{{% notice note %}}
Upgrading to KubeV v1.4.0 is supported from v1.3.x. If you are on an older release, upgrade
step by step over minor versions first.
{{% /notice %}}

This guide lists what changes when you upgrade a Kubermatic Virtualization (KubeV) installation
from v1.3.x to v1.4.0. Read it before starting, then follow the
[general guidelines]({{< ref "../" >}}) (backups, minor-by-minor, repair-before-upgrade).

## What Changes in v1.4.0

### VMs Live-Migrate on a Node Drain

Up to v1.3, KubeV left KubeVirt's cluster-wide eviction strategy unset, so KubeVirt's own
default, `None`, applied: a node drain shut down every VM that did not set a strategy of its own,
even a VM that could live-migrate. Only VMs created in the dashboard with automatic node placement
had `LiveMigrate`.

From v1.4.0, the new setting `kubevirt.evictionStrategy` defaults to `LiveMigrate` on clusters where
VMs can run on more than one node, so a drain moves VMs to another node instead of stopping them.
Clusters with a single such node keep `None`: a single-node cluster, or one control plane node with
one worker. See
[Node Drains]({{< ref "../../../configuration-guide#node-drains" >}}) for the strategies and what
each does on a drain.

What this means for your VMs:

* **Running VMs keep their strategy until their next restart.** KubeVirt copies the strategy into
  a VM when it starts, and the upgrade restarts no VM. A VM started before the upgrade without a
  strategy of its own still has `None`, and a drain still shuts it down. Restart it when it suits
  you to give it `LiveMigrate`, see [Restart VMs to Pick Up the New Default](#restart-vms-to-pick-up-the-new-default).
* **A manual drain waits on a VM that cannot live-migrate.** Once a VM runs with `LiveMigrate`,
  `kubectl drain` no longer shuts it down when it cannot move, for example because a disk is a
  ReadWriteOnce volume. The drain waits until you stop the VM.
* **Upgrades do not wait.** As in v1.3, `apply` upgrades a worker that runs a VM that cannot
  live-migrate in place, without a drain. From v1.4.0 this also covers a VM that has no other node
  to go to: its node selector, required node affinity or tolerations allow no other ready node,
  for example when the only other nodes are tainted control plane nodes.
* **VMs placed on a specific node** in the dashboard's VM form get `evictionStrategy: None` from
  v1.4.0, so a drain stops them as before instead of waiting on them. A VM placed on a node
  before v1.4.0 has no strategy of its own and gets `LiveMigrate` at its next restart, after which
  a manual drain waits on it. It gets `None` when a change that needs a restart, such as a new
  size, is saved in the form, or set it yourself before the restart:

  ```bash
  kubectl patch vm <name> -n <namespace> --type merge -p '{"spec":{"template":{"spec":{"evictionStrategy":"None"}}}}'
  ```

To keep the previous behavior on every VM, set `kubevirt.evictionStrategy: None`.

## After the Upgrade

### Restart VMs to Pick Up the New Default

List the running VMs with their eviction strategy and whether they can live-migrate:

```bash
kubectl get vmi -A -o custom-columns='NAMESPACE:.metadata.namespace,NAME:.metadata.name,NODE:.status.nodeName,STRATEGY:.spec.evictionStrategy,MIGRATABLE:.status.conditions[?(@.type=="LiveMigratable")].status'
```

A VM with strategy `None` whose `VirtualMachine` sets no `spec.template.spec.evictionStrategy`
gets `LiveMigrate` at its next restart. Before restarting a VM placed on a specific node, give it
`None` as shown above, or a manual drain waits on it afterwards. Restart it when it suits the
workload:

```bash
virtctl restart <name> -n <namespace>
```
