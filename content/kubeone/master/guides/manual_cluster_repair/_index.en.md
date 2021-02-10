+++
title = "Manual Cluster Repair"
date = 2020-04-01T12:00:00+02:00
enableToc = true
+++

## Overview

When one of the control plane instances fail (i.e. instance has failed at
cloud provider), it's necessary to replace the failed instance with a new one,
as fast as possible to avoid losing etcd quorum and blocking all
`kube-apiserver` operations.

This guide demonstrates how to restore your cluster to the normal state
(i.e. to have all kube-apiservers with etcd instances running and healthy).

## Terminology

* _etcd ring_: a group of etcd instances forming a single etcd cluster.
* _etcd member_: a known peer instance (running on the control plane nodes) of
  etcd inside the etcd ring.

## Goals

* Replace missing control plane node
* Restore etcd ring healthy state (i.e. odd number of healthy etcd members)
* Restore all other control plane components

## Non-goals (Out of the Scope)

* General cluster troubleshooting
* Cluster recovery from the backup
* Cluster migration

## Symptoms

* A control plane Node has disappeared from the
  `kubectl get node --selector node-role.kubernetes.io/master` output
* A control plane instance has grave but unknown issues (i.e. hardware
  issues) but it's still in running state
* A control plane instance is in terminated state

## The Recovery Plan

* Remove the malfunctioning instance
* Remove the former (now absent) etcd member from the known etcd peers list
* Create a fresh instance replacement
* Join new instance to the cluster as a control plane node

## Remove The Malfunctioning Instance

If the instance is not in the appropriate healthy state (i.e. underlying
hardware issues), and/or is unresponsive (for a myriad of reasons), it's often
easier to replace it then trying to fix it. Delete (in cloud console) the
malfunctioning instance if there is still one in the running state.

## Remove The Former Etcd Member From The Known Etcd Peers

Even when one etcd member is physically (and abruptly) removed, etcd ring still
hopes it might come back online at a later time. Unfortunately, this is not our
case and we need to let etcd ring know that dead etcd member is gone forever
(i.e. remove dead etcd member from the known peers list).

### Nodes

First of all, check your Nodes

```bash
kubectl get node --selector node-role.kubernetes.io/master -o wide
```

Failed control plane node will be displayed as NotReady or even absent from the
output (running Cloud Controller Manager will remove the Node object
eventually).

### etcd

Even when a control plane node is absent, there are still other alive nodes,
that contain healthy etcd ring members. Exec into the shell of one of those
alive etcd containers:

```bash
kubectl -n kube-system exec -it etcd-<ALIVE-HOSTNAME> sh
```

Setup client TLS authentication in order to be able to communicate with etcd:

```bash
export ETCDCTL_API=3
export ETCDCTL_CACERT=/etc/kubernetes/pki/etcd/ca.crt
export ETCDCTL_CERT=/etc/kubernetes/pki/etcd/healthcheck-client.crt
export ETCDCTL_KEY=/etc/kubernetes/pki/etcd/healthcheck-client.key
```

Retrieve currently known members list:

```bash
etcdctl member list
```

Example output:

```bash
2ce40012b4b4e4e6, started, ip-172-31-153-216.eu-west-3.compute.internal, https://172.31.153.216:2380, https://172.31.153.216:2379, false
2e39cf93b81fb7ed, started, ip-172-31-153-246.eu-west-3.compute.internal, https://172.31.153.246:2380, https://172.31.153.246:2379, false
6713c8f2e74fb553, started, ip-172-31-153-235.eu-west-3.compute.internal, https://172.31.153.235:2380, https://172.31.153.235:2379, false
```

By comparing the Nodes list with etcd members list (hostnames, IPs) we can find
the ID of the missing etcd member (dead etcd member would be missing from the
Nodes list, or will be in NotReady state).

For example, it's found that there is not control plane Node with IP
`172.31.153.235`. It means etcd member ID `6713c8f2e74fb553` is the one we are
looking for to remove.

To remove dead etcd member:

```bash
etcdctl member remove 6713c8f2e74fb553
Member 6713c8f2e74fb553 removed from cluster 4ec111e0dee094c3
```

Now, members list should display only 2 members.

```bash
etcdctl member list
```

Example output:

```bash
2ce40012b4b4e4e6, started, ip-172-31-153-216.eu-west-3.compute.internal, https://172.31.153.216:2380, https://172.31.153.216:2379, false
2e39cf93b81fb7ed, started, ip-172-31-153-246.eu-west-3.compute.internal, https://172.31.153.246:2380, https://172.31.153.246:2379, false
```

Exit the shell in the etcd pod.

## Create A Fresh Instance Replacement

Assuming you've used Terraform to provision your cloud infrastructure, use
`terraform apply` to restore cloud infrastructure to the declared state,
e.g. 3 control plane instances for the Highly-Available clusters.

From your local machine:

```bash
terraform apply
```

The result should be 3 running control plane VM instances. Two existing and
currently members of the cluster, and the fresh one which will be joined to the
cluster as replacement for failed VM.

### Provisioning Newly Created Instance using `kubeone apply`

`kubeone apply` will install Kubernetes binaries and dependencies on the
freshly created instance and join it back to the cluster as one of the control
plane nodes.

If you're using Terraform, make sure to regenerate the Terraform state file
using the `terraform output` command.

```bash
terraform output -json > tf.json
```

Run the following `apply` command:

```bash
kubeone apply --manifest kubeone.yaml -t tf.json
```

The `apply` command will analyze the cluster, and find the instance that needs
to be provisioned and joined the cluster. You'll be asked to confirm your
intention to provision a new node by typing `yes`.

```
INFO[15:33:55 CEST] Determine hostname…
INFO[15:33:59 CEST] Determine operating system…
INFO[15:34:02 CEST] Running host probes…
INFO[15:34:02 CEST] Electing cluster leader…
INFO[15:34:02 CEST] Elected leader "ip-172-31-220-51.eu-west-3.compute.internal"…
INFO[15:34:05 CEST] Building Kubernetes clientset…
INFO[15:34:06 CEST] Running cluster probes…
The following actions will be taken:
Run with --verbose flag for more information.
	+ join control plane node "ip-172-31-221-102.eu-west-3.compute.internal" (172.31.221.102) using 1.18.6
	+ ensure machinedeployment "marko-1-eu-west-3b" with 1 replica(s) exists
	+ ensure machinedeployment "marko-1-eu-west-3c" with 1 replica(s) exists
	+ ensure machinedeployment "marko-1-eu-west-3a" with 1 replica(s) exists

Do you want to proceed (yes/no):
```

After confirming the intention, KubeOne will start provisioning the newly
created instance. This can take several minutes. After the command is done,
you can run `kubectl get nodes` to verify that all nodes are running and
healthy.
