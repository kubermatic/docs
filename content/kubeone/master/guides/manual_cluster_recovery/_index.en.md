+++
title = "Manual Cluster Recovery"
date = 2020-04-24T12:00:00+02:00
enableToc = true
+++

## Overview

There are various mechanisms used to keep Kubernetes clusters up and running,
such as high availability (HA), self-healing, and more. In many cases, even if
something fails, the cluster can get quickly recovered without any effect on
the workload.

In rare cases, such as when multiple instances fail at the same time, etcd
can lose the quorum, making the cluster fail completely. When that happens
the only possibility is to recreate the cluster and restore it from a backup.

This document explains how to manually recreate a cluster and recover from
a backup that was made previously.

## When Should I Recover The Cluster?

This approach should be used only when the etcd quorum is lost or when it's
impossible to repair the cluster for some other reason. The general rule is
that the etcd quorum should be satisfied as long as there are `(n/2)+1`
healthy etcd members in the etcd ring.

This guide can also be used if you want to migrate to the new infrastructure
or the new provider.

In other cases, you should first try to repair the cluster by following the
[manual cluster repair][manual-cluster-repair] guide.

## Terminology

* _etcd quorum_: an etcd cluster needs a majority of nodes (`(n/2)+1`),
  a _quorum_, to agree on updates to the cluster state
* _etcd ring_: a group of etcd instances forming a single etcd cluster.
* _etcd member_: a known peer instance (running on the control plane nodes) of
  etcd inside the etcd ring.
* _leader instance_: a VM instance where cluster PKI gets generated and first
  control plane components are launched at cluster initialization time.

## Goals

* Destroy/unprovision old, non-functional cluster
* Recreate a cluster from a previously made backup

## Non-goals (Out of the Scope)

* Create a backup
  * You can use our [backups addon][backups-addon] to automatically backup all
    important files and components.
* Repair a cluster without restoring from a backup
  * You can follow the [manual cluster repair][manual-cluster-repair] guide to
    repair the cluster if it's possible.

## Requirements

* [Restic][restic] installed on your local machine in case you've used our
  backups addon.

## Information About The Cluster Endpoint (Load Balancer)

As long as the cluster endpoint (load balancer address) is the same, the worker
nodes will automatically rejoin the new cluster after some time. Besides that,
you'll be able to use the old kubeconfig files to access the cluster.

In the case the cluster endpoint is different, the worker nodes and all
kubeconfig files must be recreated.

This is important, because even if the control plane nodes are down, the
workload should still be running on the worker nodes. Although, the workload
might be inaccessible and you'll not be able to do any changes, such as
schedule new pods or remove existing ones.

## Step 1 — Download and Unpack The Backup

{{% notice note %}}
In this guide, we will assume that you have used our [backups addon][backups-addon]
to create and manage backups. You can also use any other solution, but for a
successful recovery, you will need all files mentioned in this step.

[backups-addon]: {{< ref "../../examples/addons_backup" >}}
{{% /notice %}}

First, you need to instruct Restic how to access the S3 bucket containing
the backups by exporting the environment variables with credentials, bucket
name, and the encryption password:

```bash
export RESTIC_REPOSITORY="s3:s3.amazonaws.com/<<S3_BUCKET>>"
export RESTIC_PASSWORD="<<RESTIC_PASSWORD>>"

export AWS_ACCESS_KEY_ID="<<AWS_ACCESS_KEY_ID>>"
export AWS_SECRET_ACCESS_KEY="<<AWS_SECRET_ACCESS_KEY>>"
```

With the credentials and information about the bucket in place, you can now
list all available backups:

```bash
restic snapshots
```

You should see the output such as:

```
repository cd5add2d opened successfully, password is correct
ID        Time                 Host                                         Tags        Paths
-----------------------------------------------------------------------------------------------
b1ea3ff1  2020-04-21 16:41:46  ip-172-31-122-61.eu-west-3.compute.internal  etcd        /backup
c43ea2d7  2020-04-21 16:46:46  ip-172-31-122-61.eu-west-3.compute.internal  etcd        /backup
92f33a9c  2020-04-21 16:51:46  ip-172-31-122-61.eu-west-3.compute.internal  etcd        /backup
3ee8cc50  2020-04-21 16:56:47  ip-172-31-122-61.eu-west-3.compute.internal  etcd        /backup
a2bbd29f  2020-04-21 17:01:48  ip-172-31-122-61.eu-west-3.compute.internal  etcd        /backup
8d9a9d63  2020-04-21 17:06:49  ip-172-31-122-61.eu-west-3.compute.internal  etcd        /backup
-----------------------------------------------------------------------------------------------
6 snapshots
```

Copy the ID of the backup you want to restore the cluster from. You should use
the backup from when the cluster was fully-functional.

Run the following command to download the backup:

```bash
restic restore <<BACKUP_ID>> --target .
```

This command will download the backup to your current directory. After the
command is done, you should have the `backup` directory with the following
files:

```
backup
├── ip-172-31-122-61.eu-west-3.compute.internal-snapshot.db
└── pki
    ├── etcd
    │   ├── ca.crt
    │   └── ca.key
    └── kubernetes
        ├── ca.crt
        ├── ca.key
        ├── front-proxy-ca.crt
        ├── front-proxy-ca.key
        ├── sa.key
        └── sa.pub

3 directories, 9 files
```

## Step 2 — Unprovision The Existing Cluster

As the cluster is in the beyond repairable state, we want to start from scratch
and provision the cluster again. The first step is to unprovision the existing
cluster. There are two possible options: recreate the VM instances
(recommended) or reset the cluster using the `kubeone reset` command.

{{% notice tip %}}
The worker nodes should **not** be removed. Instead, we will attempt to reuse
the existing nodes by rejoining them to the new cluster.
{{% /notice %}}

### Option 1: Recreating the VM instances (Recommended)

The best approach is to destroy the old VM instances and create new ones. This
ensures that if anything is broken on the instance itself, it'll not affect
the newly provisioned cluster.

#### Recreating Instances Using Terraform

If you are using Terraform, you can mark instances for recreation using the
`taint` command. The `taint` command takes the resource type and the resource
name.

In case of AWS, the following taint commands should be used:

```bash
terraform taint 'aws_instance.control_plane[0]'
terraform taint 'aws_instance.control_plane[1]'
terraform taint 'aws_instance.control_plane[2]'
```

Running the `apply` command will recreate the instances and update the load
balancer to point to the new instances.

```bash
terraform apply
```

Export the new Terraform state file:

```bash
terraform output -json > tf.json
```

#### Recreating Instances Manually

If you are managing the infrastructure manually, you need to remove and create
instances using your preferred method for managing infrastructure. Once the
new instances are created, update the KubeOne configuration manifest.

The information about the instances are located in the `.controlPlane.hosts`
part of the configuration manifest:

```yaml
apiVersion: kubeone.k8c.io/v1beta2
kind: KubeOneCluster
name: demo-cluster
controlPlane:
  hosts:
  - privateAddress: '172.18.0.1'
    ...
  - privateAddress: '172.18.0.2'
    ...
  - privateAddress: '172.18.0.3'
    ...
```

### Option 2: Reset The Cluster Using KubeOne

{{% notice warning %}}
This is not recommended because if something is broken on the instance itself,
it can affect the newly created cluster as well.
{{% /notice %}}

If you're not able to recreate the VM instances you can reuse the existing
ones.

Unprovision the cluster by running the `reset` command such as:

```bash
kubeone reset config.yaml -t tf.json --destroy-workers=false
```

After this is done, ensure that the `/etc/kubernetes` directory is empty on all
control plane instances. You can do that by SSH-ing to each instance and
running:

```bash
sudo rm -rf /etc/kubernetes/*
```

## Step 3 — Install The Kubernetes Binaries

Once you have the new instances, you need to install the Kubernetes binaries
before you restore the backup. We'll not provision the new cluster at this
stage because we want to restore all the needed files first.

Run the following command to install the prerequisites and the Kubernetes
binaries:

```bash
kubeone install --manifest kubeone.yaml -t tf.json --no-init
```

## Step 4 — Restore The Backup

At this point, we want to restore the backup. We'll first restore the PKI and
then the etcd backup.

{{% notice note %}}
Tasks mentioned in this step should be run only on the leader control plane
instance. KubeOne will automatically synchronize files with other instances.
{{% /notice %}}

First, copy the downloaded backup to the leader control plane instance.
On Linux and macOS systems, that can be done using `rsync`, such as:

```bash
rsync -av ./backup user@leader-ip:~/
```

Use `-e 'ssh -J user@bastion-ip'` in the case when bastion host is used.

Once this is done, connect over SSH to the leader control plane instance.

### Restore the etcd PKI

Run the following command to restore the etcd PKI:

```bash
sudo rsync -av $HOME/backup/pki/etcd /etc/kubernetes/pki/
```

### Restore the Kubernetes PKI

Run the following command to restore the Kubernetes PKI:

```bash
sudo rsync -av $HOME/backup/pki/kubernetes/ /etc/kubernetes/pki
```

With PKI in the place, ensure correct ownership on the `/etc/kubernetes`
directory:

```bash
sudo chown -R root:root /etc/kubernetes
```

### Restore the etcd backup

The easiest way to restore the etcd snapshot is to run a Docker container using
the etcd image which comes with `etcdctl`. In this case, we can use the same
etcd image as used by Kubernetes.

Inside the container, we'll mount the `/var/lib` directory, as the etcd data
is by default located in the `/var/lib/etcd` directory. Besides the `/var/lib`
directory, we need to mount the backup directory and provide some information
about the cluster and the node.

Run the following command. Make sure to provide the correct hostname and IP
address.

{{% notice tip %}}
It's advised to use the same etcd `major.minor` version as used for creating
the snapshot.
{{% /notice %}}

```bash
sudo docker run --rm \
    -v $HOME/backup:/backup \
    -v /var/lib:/var/lib \
    -e ETCDCTL_API=3 \
    k8s.gcr.io/etcd:3.4.3-0 \
    etcdctl \
    snapshot restore \
    --data-dir=/var/lib/etcd \
    --name=<<INSTANCE-HOSTNAME-FQDN>> \
    --initial-advertise-peer-urls=https://<<LEADER-PRIVATE-IP-ADDRESS>>:2380 \
    --initial-cluster=<<INSTANCE-HOSTNAME-FQDN>>=https://<<LEADER-PRIVATE-IP-ADDRESS>>:2380 \
    /backup/etcd-snapshot.db
```

After the command is done, etcd data will be in the place. Other nodes will get
the data when they join the etcd cluster.

## Step 5 — Provision The New Cluster

Finally, with all the needed files in the place, along with the etcd data,
proceed with provisioning the new cluster.

On your local machine, run the `kubeone apply` command:

```bash
kubeone apply --manifest kubeone.yaml -t tf.json
```

The provisioning process takes about 5-10 minutes. If the cluster endpoint
(load balancer) is the same as the old one, the existing worker will join
the new cluster after some time. Otherwise, the machine-controller will create
the new worker nodes.

[backups-addon]: {{< ref "../../examples/addons_backup" >}}
[manual-cluster-repair]: {{< ref "../manual_cluster_repair/" >}}
[etcd-faq]: https://github.com/etcd-io/etcd/blob/master/Documentation/faq.md
[restic]: https://restic.net/
