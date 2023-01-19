+++
title = "Upgrading Clusters"
date = 2021-02-10T12:00:00+02:00
weight = 5
+++

## Scope of The Upgrade Process

KubeOne takes care of upgrading `kubeadm` and `kubelet` binaries, running
`kubeadm upgrade` on all control plane nodes, upgrading components and addons
deploy by KubeOne, and optionally upgrading all MachineDeployments objects to
the desired Kubernetes version. Upgrades are done in-place, i.e. KubeOne
connects to nodes over SSH and runs commands needed to upgrade the node.

Worker nodes managed by Kubermatic machine-controller are upgraded using
the rolling-upgrade strategy, i.e. the old nodes are replaced with the new
ones. KubeOne Static Workers are upgraded in-place, similar to the control
plane nodes.

## Prerequisites

KubeOne is doing a set of preflight checks to ensure all prerequisites are
satisfied. The following checks are done by KubeOne:

* Docker, Kubelet and Kubeadm are installed,
* information about nodes from the Kubernetes API matches what we have in the
  KubeOne configuration (and Terraform state file),
* all nodes are healthy,
* the [Kubernetes version skew policy][k8s-skew] is satisfied.

Once the upgrade process starts for a node, KubeOne applies the
`kubeone.io/upgrade-in-progress` label on the Node object. This label is used
as a lock mechanism, so if upgrade fails or it's already in progress, you can't
start it again.

It's recommended to backup your cluster before running the upgrade process,
which can be done using the [Backups Addons][backups-addon].

Before running upgrade, please ensure that your KubeOne version supports
upgrading to the desired Kubernetes version. Check the
[Compatibility page][compatibility] for more details on supported Kubernetes
versions for each KubeOne release. You can check what KubeOne version you're
running using the `kubeone version` command.

## Upgrading The Cluster

You need to update the KubeOne configuration manifest to use the desired
Kubernetes version by changing the `versions.Kubernetes` field. It is possible
to upgrade only to the next minor release, or to any patch release as long as
the minor version is same or the next one.

After modifying the configuration manifest, you can use the `apply` command to
run upgrade. The `kubeone.yaml` file is the [configuration manifest][manifest]
and the `tf.json` file is the [Terraform state file][tf-json] (can be omitted if
the Terraform Integration is not used).

```bash
kubeone apply --manifest kubeone.yaml -t tf.json --upgrade-machine-deployments
```

{{% notice tip %}}
By default KubeOne does **not** update the MachineDeployment objects. If you
want to update them run the `apply` command with the
`--upgrade-machine-deployments` flag. This updates all MachineDeployment in the
cluster regardless of what's specified in the KubeOne configuration manifest
or Terraform state file.
{{% /notice %}}

{{% notice note %}}
If you encounter any issue with the `apply` command or you want to force the
upgrade process, you can run the upgrade command manually:
`kubeone upgrade --manifest kubeone.yaml -t tf.json`.
It’s recommended to use the `apply` command whenever it’s possible.
{{% /notice %}}

The `apply` command analyzes the given instances, verifies that there is
Kubernetes running on those instances, runs the preflight checks, and offers
you to upgrade the cluster if needed. You’ll be asked to confirm your intention
to upgrade the cluster by typing `yes`.

```
INFO[13:59:27 CEST] Determine hostname…
INFO[13:59:31 CEST] Determine operating system…
INFO[13:59:32 CEST] Running host probes…
INFO[13:59:33 CEST] Electing cluster leader…
INFO[13:59:33 CEST] Elected leader "ip-172-31-220-51.eu-west-3.compute.internal"…
INFO[13:59:36 CEST] Building Kubernetes clientset…
INFO[13:59:36 CEST] Running cluster probes…
The following actions will be taken:
Run with --verbose flag for more information.

	~ upgrade control plane node "ip-172-31-220-51.eu-west-3.compute.internal" (172.31.220.51): 1.18.5 -> 1.18.6
	~ upgrade control plane node "ip-172-31-221-177.eu-west-3.compute.internal" (172.31.221.177): 1.18.5 -> 1.18.6
	~ upgrade control plane node "ip-172-31-222-48.eu-west-3.compute.internal" (172.31.222.48): 1.18.5 -> 1.18.6
	~ ensure nodelocaldns
	~ ensure CNI
	~ ensure credential
	~ ensure machine-controller
	~ upgrade MachineDeployments

Do you want to proceed (yes/no):
```

After confirming your intention to upgrade the cluster, the process will start.
It usually takes 5-10 minutes for cluster to be upgraded. At the end, you
should see output such as the following one:

```
INFO[13:59:55 CEST] Determine hostname…
INFO[13:59:55 CEST] Determine operating system…
INFO[13:59:55 CEST] Generating kubeadm config file…
INFO[13:59:56 CEST] Uploading config files…                       node=172.31.222.48
INFO[13:59:56 CEST] Uploading config files…                       node=172.31.220.51
INFO[13:59:56 CEST] Uploading config files…                       node=172.31.221.177
INFO[13:59:57 CEST] Building Kubernetes clientset…
INFO[13:59:58 CEST] Running preflight checks…
INFO[13:59:58 CEST] Verifying that Docker, Kubelet and Kubeadm are installed…
INFO[13:59:58 CEST] Verifying that nodes in the cluster match nodes defined in the manifest…
INFO[13:59:58 CEST] Verifying that all nodes in the cluster are ready…
INFO[13:59:58 CEST] Verifying that there is no upgrade in the progress…
INFO[13:59:58 CEST] Verifying is it possible to upgrade to the desired version…
INFO[13:59:58 CEST] Labeling leader control plane…                node=172.31.220.51
INFO[13:59:58 CEST] Draining leader control plane…                node=172.31.220.51
INFO[14:00:07 CEST] Upgrading kubeadm binary on the leader control plane…  node=172.31.220.51
INFO[14:00:21 CEST] Running 'kubeadm upgrade' on leader control plane node…  node=172.31.220.51
INFO[14:00:44 CEST] Upgrading kubernetes system binaries on the leader control plane…  node=172.31.220.51
INFO[14:00:59 CEST] Uncordoning leader control plane…             node=172.31.220.51
INFO[14:01:00 CEST] Waiting 30s to ensure all components are up…  node=172.31.220.51
INFO[14:01:30 CEST] Unlabeling leader control plane…              node=172.31.220.51
INFO[14:01:30 CEST] Labeling follower control plane…              node=172.31.221.177
INFO[14:01:30 CEST] Draining follower control plane…              node=172.31.221.177
INFO[14:01:30 CEST] Upgrading Kubernetes binaries on follower control plane…  node=172.31.221.177
INFO[14:01:44 CEST] Running 'kubeadm upgrade' on the follower control plane node…  node=172.31.221.177
INFO[14:01:55 CEST] Upgrading kubernetes system binaries on the follower control plane…  node=172.31.221.177
INFO[14:02:14 CEST] Uncordoning follower control plane…           node=172.31.221.177
INFO[14:02:14 CEST] Waiting 30s to ensure all components are up…  node=172.31.221.177
INFO[14:02:44 CEST] Unlabeling follower control plane…            node=172.31.221.177
INFO[14:02:44 CEST] Labeling follower control plane…              node=172.31.222.48
INFO[14:02:44 CEST] Draining follower control plane…              node=172.31.222.48
INFO[14:02:53 CEST] Upgrading Kubernetes binaries on follower control plane…  node=172.31.222.48
INFO[14:03:10 CEST] Running 'kubeadm upgrade' on the follower control plane node…  node=172.31.222.48
INFO[14:03:24 CEST] Upgrading kubernetes system binaries on the follower control plane…  node=172.31.222.48
INFO[14:03:48 CEST] Uncordoning follower control plane…           node=172.31.222.48
INFO[14:03:48 CEST] Waiting 30s to ensure all components are up…  node=172.31.222.48
INFO[14:04:18 CEST] Unlabeling follower control plane…            node=172.31.222.48
INFO[14:04:18 CEST] Downloading PKI…
INFO[14:04:19 CEST] Downloading PKI files…                        node=172.31.220.51
INFO[14:04:20 CEST] Creating local backup…                        node=172.31.220.51
INFO[14:04:20 CEST] Ensure node local DNS cache…
INFO[14:04:21 CEST] Activating additional features…
INFO[14:04:22 CEST] Applying canal CNI plugin…
INFO[14:04:34 CEST] Creating credentials secret…
INFO[14:04:34 CEST] Installing machine-controller…
INFO[14:04:37 CEST] Installing machine-controller webhooks…
INFO[14:04:37 CEST] Waiting for machine-controller to come up…
INFO[14:05:03 CEST] Upgrade MachineDeployments…
```

If the upgrade process fails, it's recommended to continue manually and resolve
errors. In this case the `kubeone.io/upgrade-in-progress` label will prevent
you from running KubeOne again but you can ignore it using the `--force` flag.

## Changing Cluster Properties Using `kubeone upgrade`

In case you want to change some of the cluster properties (e.g. enable a new
feature), you can use the `upgrade` command to reconcile the changes.
Modify your manifest to include the desired changes, but don't change the
Kubernetes version (unless you want to upgrade the cluster), and then run the
`upgade` command with the `--force` flag:

```bash
kubeone upgrade --manifest kubeone.yaml -t tf.json --force
```

Alternatively, the `kubeone apply` command can be used as well:

```bash
kubeone apply --manifest kubeone.yaml -t tf.json --force-upgrade
```

The `--force` flag instructs KubeOne to ignore the preflight errors, including
the error saying that you're trying to upgrade to the already running version.
At the upgrade time, KubeOne ensures that the actual cluster configuration
matches the expected configuration, and therefore the `upgrade`
command can be used to modify cluster properties.

[compatibility]: {{< ref "../../architecture/compatibility" >}}
[k8s-skew]: https://kubernetes.io/docs/setup/version-skew-policy/
[backups-addon]: {{< ref "../../examples/addons_backup" >}}
[manifest]: {{< ref "../../architecture/concepts/#kubeone-configuration-manifest" >}}
[tf-json]: {{< ref "../../architecture/requirements/infrastructure_management/#terraform-integration" >}}
