+++
title = "Cluster Reconciliation (apply)"
date =  2020-07-13T17:39:14+03:00
weight = 1
+++

The cluster reconciliation process determines the actual state of the cluster
and takes actions based on the difference between actual and expected states.
The reconciliation is capable of automatically installing, upgrading, and
repairing the cluster. On top of that, reconciliation can change some cluster
properties, such as apply addons and create new worker nodes.

More information about the technical implementation can be found in the
[KubeOne Reconciliation Process (kubeone apply) proposal][apply-proposal].

## Using kubeone apply

Before getting started, make sure you have up-to-date Terraform output
file if you're using the Terraform integration:

```
terraform output -json > tf.json
```

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
kubeone apply --manifest config.yaml -t tf.json --auto-approve
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
  * If there are **not provisioned** or **unhealthy static worker nodes**, try
    to **provision/repair** them and/or **instruct** the operator about the
    needed steps.
  * If **all control plane and static worker nodes are healthy**:
    * If **upgrade is needed** (mismatch between expected and actual Kubernetes
    versions), run the upgrade process (`kubeone upgrade`).
      * If there are **new MachineDeployments**, **create** them.

### Repairing Unhealthy Clusters

The apply command has ability to detect is cluster in an unhealthy
state. The cluster is considered unhealthy if there's at least one
node that's unhealthy, which can happen if:

* kubelet is failing or not running
* API server is failing or unhealthy
* etcd is failing or unhealthy

In such a case, the operator needs to manually delete a broken instance,
update the KubeOne configuration file to remove the old instance and add
a new one, and then run the apply command again.

If Terraform is used for managing the infrastructure, the `taint` command
can be used to mark instance for recreation. Running `terraform apply` the
next time would recreate the instance. Make sure to update the Terraform output
file by running `terraform apply` again. For example:

```bash
terraform taint 'aws_instance.control_plane[<index-of-instance>]'
terraform apply
terraform output -json > tf.json
```

{{% notice warning %}}
If there are multiple unhealthy instances, it might be required to replace
and repair instance by instance in order to maintain the etcd quorum. KubeOne
recommends which instances are safe to be deleted without affecting the quorum.
It's strongly advised to follow the order or otherwise you're risking losing
the quorum and all cluster data. If it's not possible to repair the cluster
without affecting the quorum, KubeOne will fail to repair the cluster. In that
case, [disaster recovery]({{< ref "../maintenance/manual_cluster_recovery" >}}) might be required.
{{% /notice %}}

### Dynamic Workers (MachineDeployments) Reconciliation

The apply command doesn't modify or delete existing MachineDeployments.
The MachineDeployments are created by the apply command only if there's
another action to be taken, such as install or upgrade. Managing
MachineDeployments should be done by the operator either by using kubectl or
the Kubernetes API directly.

To make managing MachineDeployments easier, the operator can generate the
manifest containing all MachineDeployments defined in the KubeOne
configuration by using the `kubeone config machinedeployments` command:

```bash
kubeone config machinedeployments --manifest config.yaml -t tf.json
```

### Static Workers Reconciliation

The apply command doesn't remove or unprovision the static worker
nodes. That can be done by removing the appropriate instance manually.
If there is CCM (cloud-controller-manager) running in the cluster, the Node for
the removed worker should be deleted automatically. If there's no CCM, you can
remove the Node object manually using kubectl.

### Features Reconciliation

Currently, the apply command doesn't reconcile features. If you enable/disable
any feature on already provisioned cluster, you have to run the upgrade process
for changes to be in the effect. The upgrade process can be run using the
following upgrade command:

```bash
kubeone upgrade --manifest config.yaml -t . --force
```

[apply-proposal]: https://github.com/kubermatic/kubeone/blob/master/docs/proposals/20200224-apply.md
