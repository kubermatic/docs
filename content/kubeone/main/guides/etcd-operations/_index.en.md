+++
title = "Etcd Operations"
date = 2026-11-14T12:00:00+02:00
+++

KubeOne provides tooling for day-to-day operation of the etcd cluster that backs a KubeOne-managed Kubernetes cluster:

- the `kubeone etcd` command group, used to inspect etcd members, disarm alarms, defragment members, and take snapshots
- the `controlPlaneComponents.etcd` API field, used to tune the etcd storage quota and auto-compaction
- preconfigured `etcdctl` environment variables in the etcd static pod, so that `etcdctl` works inside the pod without
  any extra flags

## The `kubeone etcd` Command

All `kubeone etcd` subcommands connect to the etcd cluster over the SSH tunnel to the control plane leader node, using
the same TLS credentials that KubeOne uses internally. No direct network access to the etcd ports is required. Like
other KubeOne commands, they need the KubeOne manifest and, if used, the Terraform/OpenTofu output:

```shell
kubeone etcd <subcommand> --manifest kubeone.yaml -t tf.json
```

The available subcommands are:

| Subcommand                      | Description                                                         |
| ------------------------------- | ------------------------------------------------------------------- |
| `members`                       | List etcd cluster members, their URLs, learner status, and alarms   |
| `disarm [member-name] \| --all` | Disarm active alarms on a single member or on all members           |
| `defragment <member-name>`      | Defragment the storage of a single member to release wasted space   |
| `snapshot <file>`               | Save a point-in-time snapshot of the etcd data to a local file      |

Etcd member names are the hostnames of the control plane nodes. Use `kubeone etcd members` to look them up.

### Listing Members

`kubeone etcd members` lists the members of the etcd cluster, together with their peer and client URLs, learner status,
and any active alarms:

```shell
kubeone etcd members --manifest kubeone.yaml -t tf.json
```

```
ID                    NAME             PEER-URLS                    CLIENT-URLS                  IS-LEARNER  ALARMS
1234567890123456789   control-plane-0  [https://10.0.0.10:2380]     [https://10.0.0.10:2379]     false       []
2345678901234567890   control-plane-1  [https://10.0.0.11:2380]     [https://10.0.0.11:2379]     false       [NOSPACE]
3456789012345678901   control-plane-2  [https://10.0.0.12:2380]     [https://10.0.0.12:2379]     false       []
```

Use `--output json` (or `-o json`) to get machine-readable output:

```shell
kubeone etcd members --manifest kubeone.yaml -t tf.json -o json
```

```json
[
  {
    "ID": 1234567890123456789,
    "Name": "control-plane-0",
    "PeerURLs": ["https://10.0.0.10:2380"],
    "ClientURLs": ["https://10.0.0.10:2379"],
    "IsLearner": false,
    "Alarms": []
  }
]
```

### Disarming Alarms

Etcd raises an alarm when a member hits a problem that needs operator action. The most common one is `NOSPACE`,
raised when the member's database reaches the backend quota (see [Configuring Etcd](#configuring-etcd)). While a
`NOSPACE` alarm is active, the etcd cluster only accepts read and delete requests, so the Kubernetes API server can't
create or update any objects.

Alarms aren't cleared automatically. Once you've fixed the root cause, for example by compacting and
[defragmenting](#defragmenting-members) the members or by increasing the quota, disarm the alarms on a specific member:

```shell
kubeone etcd disarm control-plane-1 --manifest kubeone.yaml -t tf.json
```

Or disarm all alarms on all members at once:

```shell
kubeone etcd disarm --all --manifest kubeone.yaml -t tf.json
```

A member name and `--all` are mutually exclusive. Exactly one of them must be given.

{{% notice warning %}}
If you disarm a `NOSPACE` alarm without freeing space first, etcd raises it again as soon as the database hits the
quota.
{{% /notice %}}

### Defragmenting Members

After compaction, etcd's database file keeps its size on disk: the freed space is only reused internally. Defragmenting
a member releases this space back to the filesystem and lowers the database size that counts against the quota.

```shell
kubeone etcd defragment control-plane-0 --manifest kubeone.yaml -t tf.json
```

The command defragments every client URL of the given member.

{{% notice note %}}
A member blocks all reads and writes while it's being defragmented. Defragment one member at a time, and wait for each
to finish before you start on the next one.
{{% /notice %}}

### Taking Snapshots

`kubeone etcd snapshot` saves a point-in-time snapshot of the etcd data to a local file on the machine running
KubeOne:

```shell
kubeone etcd snapshot etcd-snapshot.db --manifest kubeone.yaml -t tf.json
```

Use `-` as the file name to write the snapshot to stdout, for example to compress it or upload it straight to object
storage:

```shell
kubeone etcd snapshot - --manifest kubeone.yaml -t tf.json | gzip > etcd-snapshot.db.gz
```

To restore a cluster from a snapshot, follow the [Manual Cluster Recovery][manual-cluster-recovery] guide.

{{% notice note %}}
This command takes a one-off snapshot. For regular, scheduled backups, use the
[`backups-restic` addon][addons-backup].
{{% /notice %}}

## Configuring Etcd

The optional `controlPlaneComponents.etcd` field exposes common etcd tuning parameters:

```yaml
apiVersion: kubeone.k8c.io/v1beta2
kind: KubeOneCluster
versions:
  kubernetes: "1.37.2"
controlPlaneComponents:
  etcd:
    # Translated into the etcd --quota-backend-bytes flag.
    quotaBackendBytes: 8589934592 # 8 GiB
    # Translated into the etcd --auto-compaction-retention flag.
    autoCompactionRetention: 1h
    # Translated into the etcd --auto-compaction-mode flag.
    autoCompactionMode: periodic # periodic | revision
```

| Field                     | etcd flag                     | Description                                                                                                                                                             |
| ------------------------- | ----------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `quotaBackendBytes`       | `--quota-backend-bytes`       | Maximum size of the etcd database in bytes. When it's reached, etcd raises a `NOSPACE` alarm. If unset, the etcd default (2 GiB) is used. Must be at least 2 GiB.        |
| `autoCompactionRetention` | `--auto-compaction-retention` | How much key history etcd keeps before compacting it. With `periodic` mode, a duration (such as `30m` or `1h`) or a number of hours. With `revision` mode, a number of revisions. If unset, the etcd default is used. |
| `autoCompactionMode`      | `--auto-compaction-mode`      | How `autoCompactionRetention` is interpreted: `periodic` (time based) or `revision` (revision count based). If unset, the etcd default (`periodic`) is used.             |

Each field is only passed to etcd when it's set. KubeOne validates the configuration and fails if:

- `quotaBackendBytes` is set to a value below 2 GiB (`2147483648` bytes)
- `autoCompactionMode` is set to anything other than `periodic` or `revision`
- `autoCompactionRetention` is neither a valid duration (such as `30m` or `1h`) nor an integer

{{% notice note %}}
The etcd documentation recommends a `quotaBackendBytes` of at most 8 GiB. Make sure the control plane nodes have enough
disk space and memory for the configured quota.
{{% /notice %}}

### Applying the Configuration

New clusters get the configuration when they're provisioned with `kubeone apply`. To change the configuration of an
existing cluster, update the manifest and run `kubeone apply` with the `--force-upgrade` flag. This reconfigures the
control plane nodes, and restarts their etcd members, one by one:

```shell
kubeone apply --manifest kubeone.yaml -t tf.json --force-upgrade
```

## Using `etcdctl` Inside the Etcd Pod

For clusters running Kubernetes 1.31 or newer, KubeOne sets the following environment variables in the etcd static
pod:

| Variable            | Value                                             |
| ------------------- | ------------------------------------------------- |
| `ETCDCTL_CACERT`    | `/etc/kubernetes/pki/etcd/ca.crt`                 |
| `ETCDCTL_CERT`      | `/etc/kubernetes/pki/etcd/healthcheck-client.crt` |
| `ETCDCTL_KEY`       | `/etc/kubernetes/pki/etcd/healthcheck-client.key` |
| `ETCDCTL_ENDPOINTS` | `https://127.0.0.1:2379`                          |

This means you can `kubectl exec` into an etcd pod and run `etcdctl` directly, without passing any certificate or
endpoint flags:

```shell
kubectl -n kube-system exec -it etcd-control-plane-0 -- etcdctl endpoint status --cluster -w table
```

```shell
kubectl -n kube-system exec -it etcd-control-plane-0 -- etcdctl alarm list
```

Existing clusters get the environment variables the next time their control plane nodes are reconfigured, for example
by running `kubeone apply --force-upgrade` or by upgrading Kubernetes.

[manual-cluster-recovery]: {{< ref "../manual-cluster-recovery" >}}
[addons-backup]: {{< ref "../../examples/addons-backup" >}}
