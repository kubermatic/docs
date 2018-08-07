+++
title = "Replacing a member"
date = 2018-07-24T12:07:15+02:00
weight = 0
pre = "<b></b>"
+++

## Intro

As the etcd gets managed by a StatefulSet with PVC's, replacing a member should mostly never needed.
Scenarios though could be:
- A PV of an etcd member got corrupted or even deleted

#### Pausing the cluster
Replacing a failed etcd member requires manual intervention.
As the StatefulSet needs to be modified, the affected cluster needs to be disabled from the controllers management:
```bash
# set cluster.spec.paused=true
kubectl edit cluster xxxxxxxxxx
```

#### Replacing the etcd member

First, the member needs to removed from the etcd-internal member management. Otherwise we risk quorum loss during the restore procedure:
```bash
# Exec into the pod
kubectl -n cluster-xxxxxxxxxx exec -ti etcd-1 sh

# Inside the pod
export ETCDCTL_API=3
export ETCD_ARGS='--cacert /etc/etcd/ca/ca.crt --cert /etc/etcd/client/apiserver-etcd-client.crt --key /etc/etcd/client/apiserver-etcd-client.key --endpoints https://localhost:2379'
etcdctl ${ETCD_ARGS} member list
#  1edc8e27256b30a9, started, etcd-2, http://etcd-2.etcd.cluster-xxxxxxxxxx.svc.cluster.local:2380, https://10.44.36.62:2379,https://etcd-2.etcd.cluster-xxxxxxxxxx.svc.cluster.local:2379
#  253869731a787437, started, etcd-0, http://etcd-0.etcd.cluster-xxxxxxxxxx.svc.cluster.local:2380, https://10.44.36.61:2379,https://etcd-0.etcd.cluster-xxxxxxxxxx.svc.cluster.local:2379
#  e2ee7cf8c0f39103, started, etcd-1, http://etcd-1.etcd.cluster-xxxxxxxxxx.svc.cluster.local:2380, https://10.44.37.62:2379,https://etcd-1.etcd.cluster-xxxxxxxxxx.svc.cluster.local:2379

# Remove etcd-0 by its ID
etcdctl ${ETCD_ARGS} member remove 253869731a787437
```

Afterwards we need to change the initial-state of the etcd cluster. 
The initial state is a configuration flag on the etcd. It tells the etcd member that it should start a new cluster or join an existing one (Respecting already existing data).
As we replace a member, it will need to know that it should join an existing cluster.

Therefore we need to set the `--initial-cluster-state` flag to `existing`:
```bash
# Look for export INITIAL_STATE="new" and update to export INITIAL_STATE="existing"
kubectl -n cluster-xxxxxxxxxx edit statefulset etcd
# Wait for all etcd pods to restart (the failed member will fail to start)
```

Now add the member manually to the etcd-internal member management:
```bash
# Exec into the pod
kubectl -n cluster-xxxxxxxxxx exec -ti etcd-1 sh

export ETCDCTL_API=3
export ETCD_ARGS='--cacert /etc/etcd/ca/ca.crt --cert /etc/etcd/client/apiserver-etcd-client.crt --key /etc/etcd/client/apiserver-etcd-client.key --endpoints https://localhost:2379'
etcdctl ${ETCD_ARGS} member list
# 1edc8e27256b30a9, started, etcd-2, http://etcd-2.etcd.cluster-xxxxxxxxxx.svc.cluster.local:2380, https://10.44.36.93:2379,https://etcd-2.etcd.cluster-xxxxxxxxxx.svc.cluster.local:2379
# e2ee7cf8c0f39103, started, etcd-1, http://etcd-1.etcd.cluster-xxxxxxxxxx.svc.cluster.local:2380, https://10.44.37.101:2379,https://etcd-1.etcd.cluster-xxxxxxxxxx.svc.cluster.local:2379

# Add the member back
etcdctl ${ETCD_ARGS} member add etcd-0 --peer-urls=http://etcd-0.etcd.cluster-xxxxxxxxxx.svc.cluster.local:2380
```

Now we can remove the failed Pod and delete its PVC. Both will be recreated:
```bash
# Delete the pvc (will get automatically recreated)
kubectl -n cluster-xxxxxxxxxx delete pvc data-etcd-0
# Delete the pod
kubectl -n cluster-xxxxxxxxxx delete pod etcd-0
# The pod will be recreated and be in a Crashloop
```

The etcd pod (etcd-0) should now start and sync with the existing members.
Now wait until all pods are being displayed as ready.

#### Unpausing the cluster
As the etcd is now back and all members are healthy, we can reset the `paused` flag on the cluster:
```bash
# set cluster.spec.paused=false
kubectl edit cluster xxxxxxxxxx
```
