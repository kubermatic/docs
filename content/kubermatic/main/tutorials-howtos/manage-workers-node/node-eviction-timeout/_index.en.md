+++
title = "Node Eviction Timeout"
date = 2026-09-14T23:30:00+02:00
weight = 17
+++

When a worker node's machine is deleted, the machine-controller evicts its pods before deleting the cloud instance. The controller attempts to evict pods while respecting PodDisruptionBudgets, retrying until all pods are evicted or the configured timeout expires; after the timeout the instance is deleted even if pods remain, so a blocked eviction cannot stall machine deletion. The default timeout is two hours and is set by the [`skipEvictionAfter`]({{< relref "../../../references/crds/#machinecontrollersettings" >}}) field of your Kubermatic installation.

The `machine-controller.kubermatic.io/skip-eviction-after` annotation overrides the timeout for a single machineDeployment or machine. The value is a duration, for example `30m` or `2h`:

```bash
kubectl annotate machinedeployment --namespace kube-system <name> \
  machine-controller.kubermatic.io/skip-eviction-after=30m
```

To override a single machine, annotate the machine resource directly:

```bash
kubectl annotate machine --namespace kube-system <name> \
  machine-controller.kubermatic.io/skip-eviction-after=1h
```

The annotation on a machineDeployment is copied to new machines as they are created. Changing the value does not restart or replace existing machines. If the value cannot be parsed, the machine-controller logs the invalid value and applies the default timeout instead.

A value of `0` disables the timeout entirely: the machine-controller then keeps waiting for eviction as long as the node is Ready and a schedulable target node exists.

To skip eviction for a node entirely, use the `kubermatic.io/skip-eviction` annotation on the node. The two annotations solve different problems: one bounds how long eviction is attempted, the other disables it.
