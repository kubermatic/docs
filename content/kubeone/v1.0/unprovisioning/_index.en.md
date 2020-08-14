+++
title = "Unprovisioning"
date = 2020-04-01T12:00:00+02:00
weight = 10
+++

{{% notice warning %}}
**Unprovisioning the cluster removes the Kubernetes installation. All worker
nodes, workload, and data will be permanently deleted!**
{{% /notice %}}

The goal of the unprovisioning process is to destroy the cluster. It should
be used only if you don't need the cluster anymore and want to free up the
cloud resources.

## Unprovisioning Kubernetes

You can revert the provision process using the `reset` command, such as:

```bash
kubeone reset --manifest kubeone.yaml -t tf.json
```

This command removes all worker nodes (by removing the MachineDeployment
objects) and runs `kubeadm reset` on each control plane node to remove the
Kubernetes installation. If you want to opt-out from removing worker nodes
(MachineDeployments), you can set the `--destroy-workers` flag to `false`:

```bash
kubeone reset --manifest kubeone.yaml -t tf.json --destroy-workers=false
```

Docker and Kubernetes binaries are not removed by the `reset` command.
Optionally, if you want to remove the Kubernetes binaries (`kubeadm`,
`kubelet`, and `kubectl`), you can use the `--remove-binaries` flag:

```bash
kubeone reset --manifest kubeone.yaml -t tf.json --remove-binaries
```

After resetting the cluster, you can destroy the infrastructure.
If you use Terraform, continue to the next section. Otherwise, you'll have to
manually delete resources using your preferred approach (e.g. cloud console).

## Removing Infrastructure Using Terraform

If you use Terraform to manage the infrastructure, you can simply destroy all
resources using the `destroy` command. Terraform will show what resources will
be destroyed and will ask you to confirm your intentions by typing `yes`.

{{% notice note %}}
If you're running cluster on GCP, you will be required to manually remove
Routes created by kube-controller-manager using cloud console before running
`terraform destroy`.
{{% /notice %}}

```bash
terraform destroy
```
