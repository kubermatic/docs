+++
title = "Monitoring Etcd Ring and Replacing Corrupted Members"
date = 2022-04-05T12:00:00+02:00
+++

The etcd maintainers are no longer recommending running etcd v3.5 in
production. They have found out that if the etcd process is killed under high
load, occasionally some committed transactions are not reflected on all the
members. The problem affects etcd versions v3.5.0, v3.5.1, v3.5.2, and is
planned to be fixed in v3.5.3 (release date is TBD). You can check out the
[email from the etcd maintainers][etcd-email] for more details.

[etcd-email]: https://groups.google.com/a/kubernetes.io/g/dev/c/B7gJs88XtQc/m/rSgNOzV2BwAJ

We're deploying etcd v3.5 by default for all Kubernetes 1.22 and newer
clusters. We heavily advise taking the following actions:

* **If you are already running Kubernetes 1.22 or newer**
  * Follow the Enabling Etcd Corruption Checks part of the document to enable
    the etcd corruption checks. Those corruption checks will not fix the data
    consistency issues, but they'll prevent corrupted etcd members from joining
    or staying in the etcd ring
  * Make sure your cluster has sufficient CPU, memory, and storage
  * Monitor your cluster etcd ring to make sure there’s no corruption
  * Frequently backup your etcd ring. You can do that by setting up the
    [`backups-restic` addon][addons-backup]
* **If you are NOT running Kubernetes 1.22 or newer**
  * Postpone upgrades of existing clusters to or deploying new clusters with
    Kubernetes 1.22 or newer until a fixed etcd version is available from the
    etcd maintainers
 
[addons-backup]: {{< ref "../../examples/addons-backup" >}}

## Enabling Etcd Corruption Checks

The etcd corruption checks are enabled by default starting with KubeOne 1.4.1.
Before proceeding, make sure that you're running KubeOne 1.4.1 or newer. You
can do that by running the `version` command:

```shell
kubeone version
```

The `gitVersion` should be `1.4.1` or newer:

```
{
  "kubeone": {
    "major": "1",
    "minor": "4",
    "gitVersion": "1.4.1",
    "gitCommit": "d44b1a474a3894f1cf685b299fae1c725c1ccb1f",
    "gitTreeState": "",
    "buildDate": "2022-04-04T08:49:52Z",
    "goVersion": "go1.17.5",
    "compiler": "gc",
    "platform": "linux/amd64"
  },
  "machine_controller": {
    "major": "1",
    "minor": "43",
    "gitVersion": "v1.43.0",
    "gitCommit": "",
    "gitTreeState": "",
    "buildDate": "",
    "goVersion": "",
    "compiler": "",
    "platform": "linux/amd64"
  }
}
```

To enable the corruption checks, you need to **force upgrade** your cluster.
This means running the upgrade process without changing the Kubernetes version,
in order to trigger regenerating manifests for etcd.

```shell
kubeone apply -m kubeone.yaml -t tf.json --force-upgrade
```

This process might take up to 10 minutes. After it's done, you can use the
following command to validate that all etcd pods have required flags:

```shell
kubectl get pods -n kube-system -l component=etcd -o jsonpath='{range .items[*]}{.metadata.name}: {range .spec.containers[0].command[*]}{}{"\n"}{end}{"\n"}{end}'
```

Each etcd pods should have the following two flags:

```
--experimental-corrupt-check-time=240m
--experimental-initial-corrupt-check=true
```

If you run into any issue, create an issue in the KubeOne repository.

## Monitoring The Etcd Ring

{{% notice warning %}}
We strongly recommend setting up some monitoring and alerting stack that would
allow you to automatically receive alerts if an etcd member becomes corrupt.
{{% /notice %}}

We strongly recommend checking the status of the etcd ring frequently to
make sure there are no corrupted members.

### Checking etcd pods status

First, ensure that all etcd pods are Running.

```shell
kubectl get pods -n kube-system -l component=etcd
```

```
NAME                                                READY   STATUS    RESTARTS   AGE
etcd-ip-172-31-195-53.eu-west-3.compute.internal    1/1     Running   0          7m19s
etcd-ip-172-31-196-114.eu-west-3.compute.internal   1/1     Running   0          6m36s
etcd-ip-172-31-197-44.eu-west-3.compute.internal    1/1     Running   0          5m33s
```

If you see any pod that is restarting or not Running, you should check the logs
and then replace the affected etcd member if needed.

### Checking the etcd logs

Check logs for each etcd pod and make sure there are no logs related to the
etcd corruption.

You might use the following commands:

```shell
kubectl logs -n kube-system <etcd-pod-name>
kubectl logs -n kube-system <etcd-pod-name> | grep -i corrupt
```

You should see the following log message on all etcd members:

```
{"level":"info","ts":"2022-04-05T11:16:26.368Z","caller":"etcdserver/corrupt.go:116","msg":"initial corruption checking passed; no corruption","local-member-id":"f39a5c54fd589f35"}
```

The periodic corruption checks (every 4 hours) are done only on the leader etcd
member, where you should see a log message such as the following one:

```
{"level":"info","ts":"2022-04-05T13:29:52.601Z","caller":"etcdserver/corrupt.go:244","msg":"finished peer corruption check","number-of-peers-checked":2}
```

If you see any logs mentioning that your etcd member is corrupted you **MUST**
follow the Replacing a Corrupted Etcd Member section of this document to
replace it.

## Replacing a Corrupted Etcd Member

If you found that you have a corrupted etcd member, you **MUST** replace it
**as soon as possible**. Replacing is done by resetting the node where the
corrupted member is running, and then letting KubeOne join it a cluster again.

{{% notice warning %}}
This guide assumes that only one etcd member is affected, i.e. that the etcd
quorum is still satisfied. If your etcd ring lost the quorum, it might not be
possible to recover it by following this guide.
{{% /notice %}}

First, determine the node where the corrupted etcd member is running. You can
do that by running the following command:

```shell
kubectl get pods -o wide -n kube-system -l component=etcd
```

The node name can be found in the `NODE` column. Write it down as you'll need
it for other commands.

```shell
NAME                                                READY   STATUS    RESTARTS   AGE    IP               NODE                                           NOMINATED NODE   READINESS GATES
etcd-ip-172-31-195-53.eu-west-3.compute.internal    1/1     Running   0          108m   172.31.195.53    ip-172-31-195-53.eu-west-3.compute.internal    <none>           <none>
etcd-ip-172-31-196-114.eu-west-3.compute.internal   1/1     Running   0          92m    172.31.196.114   ip-172-31-196-114.eu-west-3.compute.internal   <none>           <none>
etcd-ip-172-31-197-44.eu-west-3.compute.internal    1/1     Running   0          89m    172.31.197.44    ip-172-31-197-44.eu-west-3.compute.internal    <none>           <none>
```

For the purpose of this guide, we'll consider that
`etcd-ip-172-31-196-114.eu-west-3.compute.internal` is a corrupted etcd member,
and the node where this member is running is
`ip-172-31-196-114.eu-west-3.compute.internal`.

You'll also need the IP address, so you can SSH to the node. You can find the
IP address by checking the Terraform state or with `kubectl`. Depending on
your setup, you might need to use a bastion host to access the node (in which
case you can find the bastion IP address in the Terraform state).

Drain the node, so all pods get rescheduled to other nodes.

```shell
kubectl drain --ignore-daemonsets --delete-emptydir-data <node-name>
```

You should see output such as the following one:

```
node/ip-172-31-196-114.eu-west-3.compute.internal cordoned
WARNING: ignoring DaemonSet-managed Pods: kube-system/canal-dg7bk, kube-system/ebs-csi-node-ldjq9, kube-system/kube-proxy-k9gkv, kube-system/node-local-dns-2cqxm
node/ip-172-31-196-114.eu-west-3.compute.internal drained
```

Once done, SSH to the node:

```shell
ssh <username>@<ip-address>
ssh -J <bastion-username>@<bastion-ip> <username>@<ip-address> # if running behind a bastion host (jumphost)
```

Reset the node by running the `kubeadm reset` command:

```shell
sudo kubeadm reset --force
```

After that is done, you can close the SSH session. You'll need to manually
remove the Node object before proceeding.

```shell
kubectl delete node <node-name>
```

```
node "ip-172-31-196-114.eu-west-3.compute.internal" deleted
```

Finally, you can run `kubeone apply` to rejoin the node:

```shell
kubeone apply -m kubeone.yaml -t tf.json
```

KubeOne should confirm that the node will be joined to the cluster:

```
The following actions will be taken:
Run with --verbose flag for more information.
        + join control plane node "ip-172-31-196-114.eu-west-3.compute.internal" (172.31.196.114) using 1.23.5
        + ensure machinedeployment "<cluster-name>-eu-west-3a" with 1 replica(s) exists
        + ensure machinedeployment "<cluster-name>-eu-west-3b" with 1 replica(s) exists
        + ensure machinedeployment "<cluster-name>-eu-west-3c" with 1 replica(s) exists
```

If that's the case, type `yes` to proceed. Once KubeOne is done, run
`kubectl get nodes` to confirm that the node has joined the cluster.

With that done, your cluster is recovered. Since it's still running etcd v3.5,
you should continue monitoring your etcd ring. If you encounter any issues
along the way, please create an issue in the KubeOne repository.
