+++
title = "Node Eviction Timeout"
date = 2026-09-14T23:30:00+02:00
weight = 17
+++

When a machine is deleted, the machine-controller first evicts its pods, respecting PodDisruptionBudgets. If eviction does not finish before a timeout, the instance is deleted anyway. This way, a blocked eviction cannot stall machine deletion.

## Configure the Timeout

The timeout is set by the [`skipEvictionAfter`]({{< relref "../../../references/crds/#machinecontrollersettings" >}}) field:

- Cluster: `spec.componentsOverride.machineController.skipEvictionAfter`
- ClusterTemplate: the same path, inside the template's cluster spec
- Seed: `spec.defaultComponentSettings.machineController.skipEvictionAfter`

The Cluster value wins over the ClusterTemplate, which wins over the Seed.

| Value | Behavior |
|---|---|
| unset | The default of two hours applies. |
| `0s` | The timeout is disabled. |
| positive, for example `30m` | Eviction stops after this duration and the node is force-deleted. |
| negative | Rejected. |

```yaml
apiVersion: kubermatic.k8c.io/v1
kind: Cluster
spec:
  componentsOverride:
    machineController:
      skipEvictionAfter: 0s
```

With the timeout disabled, the machine waits for eviction as long as its node is Ready and a schedulable target node exists. Otherwise, eviction is still skipped.

## Override the Timeout for a Machine

The `machine-controller.kubermatic.io/skip-eviction-after` annotation overrides the timeout for a machineDeployment or a single machine:

```bash
kubectl annotate machinedeployment --namespace kube-system <name> \
  machine-controller.kubermatic.io/skip-eviction-after=30m
```

```bash
kubectl annotate machine --namespace kube-system <name> \
  machine-controller.kubermatic.io/skip-eviction-after=1h
```

- A machineDeployment annotation applies only to machines created afterwards.
- `0` disables the timeout.
- Negative or invalid values are logged and ignored. The cluster's timeout applies instead.

{{% notice warning %}}
In older machine-controller versions, an annotation value of `0` skipped eviction immediately. If you used `0` before upgrading, check that the new behavior is what you want.
{{% /notice %}}

## Skip Eviction Entirely

To skip eviction for a node, use the `kubermatic.io/skip-eviction` annotation on the node.
