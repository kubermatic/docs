+++
title = "Cluster Reconciliation (apply)"
date =  2020-07-13T17:39:14+03:00
+++

{{% notice warning %}}
In order to use the apply command, KubeOne v1.0.0 is required. Since KubeOne
v1.0.0 is still unreleased, the apply command might not be stable, so
it's currently not recommended to use it in production.
{{% /notice %}}

The cluster reconciliation process determines the actual state of the cluster
and takes actions based on the difference between actual and expected states.
The reconciliation is capable of automatically installing, upgrading, and
repairing the cluster. On top of that, reconciliation can change some cluster
properties, such as apply addons and create new worker nodes.

More information about the technical implementation can be found in the
[KubeOne Reconciliation Process (kubeone apply) proposal][apply-proposal].

## Using kubeone apply

The cluster reconciliation is implemented under the `kubeone apply` command
which has similar semantics as other KubeOne commands.

You can use the following command:

```bash
kubeone apply --manifest config.yaml -t .
```

For more details about available flags and properties, run the command with
the `-h` flag:

```bash
kubeone apply -h
```

By default, the `apply` command expects the user confirmation before taking
any action. If you are running `kubeone apply` in a script and/or without
terminal and ability to confirm actions, you can use the `--auto-approve`
flag:

```bash
kubeone apply --manifest config.yaml -t . --auto-approve
```

## Reconciliation Process

The reconciliation process is explained in details in the
[technical proposal][apply-proposal]. This section includes important details
about the reconciliation process that you should be aware of.

The actual state of the cluster is determined by running a set of probes
(Bash scripts and Kubernetes API requests) on the cluster instances.

The expected state is defined with the KubeOne configuration manifest, and
optionally with the Terraform state.

The general reconciliation workflow is based on:

* If cluster is **not provisioned**, run the installation process
  (`kubeone install`).
* If the cluster **is provisioned**:
  * If there are **unhealthy control plane nodes**, try to **repair** the cluster
    and/or **instruct** the operator about the needed steps.
  * If **all control plane nodes are healthy**:
    * If **upgrade is needed** (mismatch between expected and actual Kubernetes
    versions), run the upgrade process `kubeone upgrade`.
    * If there are **new MachineDeployments**, **create** them.
    * If there are **new, modified, or unhealthy static worker nodes**, **reconcile**
      the changes.

{{% notice note %}}
The apply command doesn't modify or delete existing
MachineDeployments. Such operations should be done by the operator either by
using kubectl or Kubernetes API directly. The operator can generate the
manifests containing all MachineDeployments defined in the KubeOne
configuration by using the `kubeone config machinedeployments` command.
{{% /notice %}}

{{% notice note %}}
The apply command doesn't remove or unprovision the static worker
nodes. That can be done by removing the appropriate instance manually.
{{% /notice %}}

[apply-proposal]: https://github.com/kubermatic/kubeone/blob/master/docs/proposals/20200224-apply.md
