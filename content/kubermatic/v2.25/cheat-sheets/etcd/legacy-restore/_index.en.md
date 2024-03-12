+++
title = "Restoring from Backup"
date = 2018-07-24T12:07:15+02:00
weight = 20

+++

{{% notice warning %}}
This page documents a **manual** restore procedure in case the legacy backup controllers were used to create
the backup object in question. KKP v2.24 has removed the legacy backup controllers. The current implementation
supports [automated restores]({{< ref "../../../tutorials-howtos/etcd-backups/" >}}), so this procedure should 
**not** be used. Use the restore functionality in KKP directly instead.
{{% /notice %}}

## Intro

The etcds of the user-clusters are being backed up on a configured interval.
This document will lead through the process of restoring a complete etcd StatefulSet from a single snapshot.

### Pausing the Cluster

Restoring a etcd requires manual intervention.
As the StatefulSet needs to be modified, the affected cluster needs to be removed from the controllers management:

```bash
# set cluster.spec.pause=true
kubectl edit cluster xxxxxxxxxx
```

### Pausing the StatefulSet

To restore an etcd, the etcd must not be running.
Therefore the etcd statefulset must be configured to just execute a `exec /bin/sleep 86400`.

```bash
# change command to run 'exec /bin/sleep 86400'
kubectl -n cluster-xxxxxxxxxx edit statefulset etcd
```

### Deleting All PVCs

To ensure that we start on each pod with a empty disk, we delete all PVC's.
The StatefulSet will create new ones with empty PV's automatically.

```bash
kubectl -n cluster-xxxxxxxxxx delete pvc -l app=etcd
```

### Deleting All Pods

To ensure all Pods start with the sleep command and with new PV's, all etcd pods must be deleted.

```bash
kubectl -n cluster-xxxxxxxxxx delete pod -l app=etcd
```

### Restoring etcd (Must Be Executed on All etcd Pods)

The restore command is different for each member. Make sure to update it gets executed.

```bash
# Copy snapshot into pod
kubectl cp snapshot.db cluster-xxxxxxxxxx/etcd-0:/var/run/etcd/
# Exec into the pod
kubectl -n cluster-xxxxxxxxxx exec -ti etcd-0 sh

cd /var/run/etcd/
# Inside the pod, restore from the snapshot
# This command is specific to each member.
export MEMBER=etcd-0
export CLUSTER_ID=xxxxxxxxxx
```

#### With etcd-launcher Enabled

If `etcd-launcher` is enabled (which it is by default since KKP v2.22), the restore command needs to use TLS-enabled endpoints:

```bash
etcdctl snapshot restore snapshot.db \
  --name ${MEMBER} \
  --initial-cluster etcd-0=https://etcd-0.etcd.cluster-${CLUSTER_ID}.svc.cluster.local:2381,etcd-1=https://etcd-1.etcd.cluster-${CLUSTER_ID}.svc.cluster.local:2381,etcd-2=https://etcd-2.etcd.cluster-${CLUSTER_ID}.svc.cluster.local:2381 \
  --initial-cluster-token ${CLUSTER_ID} \
  --initial-advertise-peer-urls https://${MEMBER}.etcd.cluster-${CLUSTER_ID}.svc.cluster.local:2381 \
  --data-dir /var/run/etcd/pod_${MEMBER}/
```

#### With etcd-launcher Disabled

If `etcd-launcher` is disabled (which is not recommended), the restore command needs to use plain HTTP networking:

```bash
etcdctl snapshot restore snapshot.db \
  --name ${MEMBER} \
  --initial-cluster etcd-0=http://etcd-0.etcd.cluster-${CLUSTER_ID}.svc.cluster.local:2380,etcd-1=http://etcd-1.etcd.cluster-${CLUSTER_ID}.svc.cluster.local:2380,etcd-2=http://etcd-2.etcd.cluster-${CLUSTER_ID}.svc.cluster.local:2380 \
  --initial-cluster-token ${CLUSTER_ID} \
  --initial-advertise-peer-urls http://${MEMBER}.etcd.cluster-${CLUSTER_ID}.svc.cluster.local:2380 \
  --data-dir /var/run/etcd/pod_${MEMBER}/
```

### Un-Pausing the Cluster

To let the kubermatic Kubernetes Platform (KKP)-controller-manager update the etcd to normal state, un-pause it.

```bash
# set cluster.spec.pause=false
kubectl edit cluster xxxxxxxxxx
```

### Delete etcd-Pods

As the rolling-update of the etcd won't finish, all etcd pods must be manually.

```bash
kubectl -n cluster-xxxxxxxxxx delete pod -l app=etcd
```
