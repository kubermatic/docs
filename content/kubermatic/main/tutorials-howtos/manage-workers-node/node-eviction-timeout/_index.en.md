+++
title = "Node Eviction Timeout"
date = 2026-09-14T23:30:00+02:00
weight = 17
+++

When a worker node's machine is deleted, the machine-controller evicts its pods before deleting the cloud instance. The eviction respects PodDisruptionBudgets and keeps retrying until the pods are gone. A blocked eviction can stall machine deletion, so the controller stops waiting after a timeout and deletes the instance anyway. The default timeout is two hours and is set by your Kubermatic installation.

The `machine-controller.kubermatic.io/skip-eviction-after` annotation overrides the timeout for a single machineDeployment or machine. The value is a duration, for example `30m` or `2h`:

```bash
kubectl annotate machinedeployment --namespace kube-system <name> \
  machine-controller.kubermatic.io/skip-eviction-after=30m
```

To override a single machine, annotate the machine resource directly:

```bash
kubectl annotate machine --namespace kube-system <name> \
  machine-controller.kubermatic.io/skip-eviction-after=30m
```

The annotation on a machineDeployment is copied to new machines as they are created. Changing the value does not restart or replace existing machines. If the value cannot be parsed, the machine-controller logs the invalid value and applies the default timeout instead.

To skip eviction for a node entirely, use the `kubermatic.io/skip-eviction` annotation on the node. The two annotations solve different problems: one bounds how long eviction is attempted, the other disables it.
