+++
title = "Upgrading from 2.19 to 2.20"
date = 2022-02-01T00:00:39+01:00
weight = 115
+++

## API Group Change

Beginning with release 1.16, Kubernetes has introduced a [restriction on API groups](https://github.com/kubernetes/enhancements/tree/master/keps/sig-api-machinery/2337-k8s.io-group-protection). Using `*.k8s.io` or `*.kubernetes.io` is forbidden for non-approved, external APIs. This has affected a number of applications across the Kubernetes ecosystem.

KKP has always used `kubermatic.k8s.io` for its CRDs (since v2.18, in accordance with the upstream restriction, those were marked as `unapproved, legacy API`). With release v2.20 we **migrate to a new group, `kubermatic.k8c.io`**. This migration is the only change in KKP since version 2.19.

KKP makes strong use of owner references for the various resources in its API group and for other objects, like ClusterRoles. While this aids in keeping a consistent set of configurations, it poses challenges for migrating from one API group to another.

{{% notice note %}}
Migrating to KKP 2.20 requires a downtime of all reconciling and includes restarting the control planes of all userclusters across all Seeds.
{{% /notice %}}

### Migration Overview

The general migration procedure is as follows:

* Shutdown KKP controllers/dashboard/API.
* Create duplicate of all KKP resources in the new API groups.
* Adjust the owner references in the new resources.
* Remove finalizers and owner references from old objects.
* Delete old objects.
* Deploy new KKP 2.20 Operator.
* The operator will reconcile and restart the remaining KKP controllers, dashboard and API.

{{% notice note %}}
Creating clones of, for example, Secrets in a cluster namespace will lead to new resource versions on those cloned Secrets. These new resource versions will affect Deployments like the kube-apiserver once KKP is restarted and reconciles. This will in turn cause all Deployments/StatefulSets to rotate.

It is highly advisable to lower `spec.seedController.maximumParallelReconciles` in the KubermaticConfiguration to slow down the roll outs of usercluster control planes.
{{% /notice %}}

### Migration Guide

The `kubermatic-installer` offers a number of new subcommands to perform the migration automatically. Due to the complexity of the operation it is highly discouraged to attempt a manual migration.

Download the [KKP 2.20 release from GitHub](https://github.com/kubermatic/kubermatic/releases/tag/v2.20.0) and extract the archive on your machine.

```bash
wget https://github.com/kubermatic/kubermatic/releases/download/v2.20.0/kubermatic-ce-v2.20.0-linux-amd64.tar.gz
```

```bash
tar xzf kubermatic-ce-v2.20.0-linux-amd64.tar.gz
```

#### Preflight Checks

Before the migration can begin, a number of preflight checks need to happen first:

* No KKP resource must be marked as deleted.
* The new CRD files must be available on disk.
* All seed clusters must be reachable.
* Deprecated features which were removed in KKP 2.20 must not be used anymore.
* (only before actual migration) No KKP controllers/webhooks must be running.

The first step is to get the kubeconfig file for the KKP **master** cluster. Set the `KUBECONFIG` variable pointing to it:

```bash
export KUBECONFIG=/path/to/master.kubeconfig
```

You can now run the `preflight` subcommand in the kubermatic-installer:

```bash
./kubermatic-installer preflight
```

It will report any issues it finds:

```text
INFO[17:37:32] Creating Kubernetes client to the master cluster…
INFO[17:37:35] Retrieving Seeds…
INFO[17:37:35] Found 2 Seeds.
INFO[17:37:35] Creating Kubernetes client for each Seed…
INFO[17:37:39] Validating seed clients…                      phase=preflight
INFO[17:37:39] Validating all KKP resources are healthy…     phase=preflight
WARN[17:37:41] Cluster is in deletion.                       cluster=n86rmdp2cx phase=preflight seed=asia-south1-c
WARN[17:37:41] Cluster is in deletion.                       cluster=qpzkwrrs9m phase=preflight seed=asia-south1-c
WARN[17:37:41] Cluster is in deletion.                       cluster=v98rj5sbw9 phase=preflight seed=asia-south1-c
WARN[17:37:44] Cluster is in deletion.                       cluster=8bqj85btdp phase=preflight seed=europe-west3-c
WARN[17:37:44] EtcdRestore is in deletion.                   etcdrestore=vf6rh7ppw2 phase=preflight seed=europe-west3-c
WARN[17:37:44] Namespace is in deletion.                     namespace=cluster-2l584rhpjv phase=preflight seed=europe-west3-c
WARN[17:37:44] Namespace is in deletion.                     namespace=cluster-5ltvmn2jb2 phase=preflight seed=europe-west3-c
WARN[17:37:45] Resource health check failed: please ensure that no KKP resource is stuck before continuing  phase=preflight
INFO[17:37:45] Validating all new KKP CRDs exist…            phase=preflight
WARN[17:37:45] ❌ Operation failed: preflight checks failed: please correct the errors noted above and try again.
```

You have to ensure all problems are resolved before the next step can happen. Re-run the `preflight` command until it reports no problems.

#### Shutdown

Now it's time to **shutdown KKP** on the master and all seed clusters. This prevents any modifications to the original KKP resources while the migration is running, however no reconciling can happen in the meantime and the KKP dashboard/API are also not available. Take note that this also removes the validating/mutating webhook configurations (they will be recreated later by the KKP operator).

Ensure that the `KUBECONFIG` variable still points to your master cluster:

```bash
export KUBECONFIG=/path/to/master.kubeconfig
```

The installer includes a command to shutdown everything and remove the KKP webhooks. You must specify `--stop-the-world` to prevent accidental shutdowns:

```bash
./kubermatic-installer shutdown --stop-the-world=yes
```

```text
INFO[16:24:55] Creating Kubernetes client to the master cluster…
INFO[16:24:57] Retrieving Seeds…
INFO[16:24:58] Found 2 Seeds.
INFO[16:24:58] Creating Kubernetes client for each Seed…
INFO[16:25:01] Shutting down in cluster…                     master=true
INFO[16:25:02] Shutting down in cluster…                     seed=asia-south1-c
INFO[16:25:03] Shutting down in cluster…                     seed=europe-west3-c
INFO[16:25:04] All controllers have been scaled down to 0 replicas now.
INFO[16:25:04] Please run the `migrate-crds` command now to migrate your resources.
```

Adding the global `--verbose` flags offers more detail:

```text
$ ./kubermatic-installer --verbose shutdown --stop-the-world=yes
INFO[16:24:55] Creating Kubernetes client to the master cluster…
INFO[16:24:57] Retrieving Seeds…
INFO[16:24:58] Found 2 Seeds.
INFO[16:24:58] Creating Kubernetes client for each Seed…
INFO[16:25:01] Shutting down in cluster…                     master=true
DEBU[16:25:01] Scaling down…                                 deployment=kubermatic-operator master=true namespace=kubermatic
DEBU[16:25:01] Scaling down…                                 deployment=kubermatic-master-controller-manager master=true namespace=kubermatic
DEBU[16:25:01] Scaling down…                                 deployment=kubermatic-api master=true namespace=kubermatic
DEBU[16:25:01] Scaling down…                                 deployment=kubermatic-seed-controller-manager master=true namespace=kubermatic
DEBU[16:25:02] Removing…                                     master=true webhook=kubermatic-clusters
DEBU[16:25:02] Removing…                                     master=true webhook=kubermatic-seeds-kubermatic
DEBU[16:25:02] Removing…                                     master=true webhook=kubermatic-operating-system-configs
DEBU[16:25:02] Removing…                                     master=true webhook=kubermatic-operating-system-profiles
INFO[16:25:02] Shutting down in cluster…                     seed=asia-south1-c
DEBU[16:25:02] Deployment not found.                         deployment=kubermatic-operator namespace=kubermatic seed=asia-south1-c
DEBU[16:25:02] Deployment not found.                         deployment=kubermatic-master-controller-manager namespace=kubermatic seed=asia-south1-c
DEBU[16:25:02] Deployment not found.                         deployment=kubermatic-api namespace=kubermatic seed=asia-south1-c
DEBU[16:25:02] Scaling down…                                 deployment=kubermatic-seed-controller-manager namespace=kubermatic seed=asia-south1-c
DEBU[16:25:02] Scaling down…                                 deployment=usercluster-controller namespace=cluster-n86rmdp2cx seed=asia-south1-c
DEBU[16:25:03] Scaling down…                                 deployment=usercluster-controller namespace=cluster-qpzkwrrs9m seed=asia-south1-c
DEBU[16:25:03] Scaling down…                                 deployment=usercluster-controller namespace=cluster-v98rj5sbw9 seed=asia-south1-c
DEBU[16:25:03] Removing…                                     seed=asia-south1-c webhook=kubermatic-clusters
DEBU[16:25:03] Removing…                                     seed=asia-south1-c webhook=kubermatic-seeds-kubermatic
DEBU[16:25:03] Removing…                                     seed=asia-south1-c webhook=kubermatic-operating-system-configs
DEBU[16:25:03] Removing…                                     seed=asia-south1-c webhook=kubermatic-operating-system-profiles
INFO[16:25:03] Shutting down in cluster…                     seed=europe-west3-c
DEBU[16:25:03] Scaling down…                                 deployment=kubermatic-operator namespace=kubermatic seed=europe-west3-c
DEBU[16:25:04] Scaling down…                                 deployment=kubermatic-master-controller-manager namespace=kubermatic seed=europe-west3-c
DEBU[16:25:04] Scaling down…                                 deployment=kubermatic-api namespace=kubermatic seed=europe-west3-c
DEBU[16:25:04] Scaling down…                                 deployment=kubermatic-seed-controller-manager namespace=kubermatic seed=europe-west3-c
DEBU[16:25:04] Scaling down…                                 deployment=usercluster-controller namespace=cluster-25nxrsncfh seed=europe-west3-c
DEBU[16:25:04] Scaling down…                                 deployment=usercluster-controller namespace=cluster-2rmvzmmgpd seed=europe-west3-c
DEBU[16:25:04] Scaling down…                                 deployment=usercluster-controller namespace=cluster-7z5264tx27 seed=europe-west3-c
DEBU[16:25:04] Scaling down…                                 deployment=usercluster-controller namespace=cluster-8bqj85btdp seed=europe-west3-c
DEBU[16:25:04] Scaling down…                                 deployment=usercluster-controller namespace=cluster-b8z8xm2wbp seed=europe-west3-c
DEBU[16:25:04] Scaling down…                                 deployment=usercluster-controller namespace=cluster-dsb9skz8tv seed=europe-west3-c
DEBU[16:25:04] Scaling down…                                 deployment=usercluster-controller namespace=cluster-lfmm2c44bv seed=europe-west3-c
DEBU[16:25:04] Scaling down…                                 deployment=usercluster-controller namespace=cluster-lxt87pvl79 seed=europe-west3-c
DEBU[16:25:04] Scaling down…                                 deployment=usercluster-controller namespace=cluster-mbmfnv298m seed=europe-west3-c
DEBU[16:25:04] Scaling down…                                 deployment=usercluster-controller namespace=cluster-wjqkn2zm98 seed=europe-west3-c
DEBU[16:25:04] Removing…                                     seed=europe-west3-c webhook=kubermatic-clusters
DEBU[16:25:04] Removing…                                     seed=europe-west3-c webhook=kubermatic-seeds-kubermatic
DEBU[16:25:04] Removing…                                     seed=europe-west3-c webhook=kubermatic-operating-system-configs
DEBU[16:25:04] Removing…                                     seed=europe-west3-c webhook=kubermatic-operating-system-profiles
INFO[16:25:04] All controllers have been scaled down to 0 replicas now.
INFO[16:25:04] Please run the `migrate-crds` command now to migrate your resources.
```

#### Migration

Now it's time to perform the migration. Ensure that the `KUBECONFIG` variable still points to your master cluster:

```bash
export KUBECONFIG=/path/to/master.kubeconfig
```

{{% notice warning %}}
During the migration, the etcd StatefulSets have to be recreated, which in turn will cause all etcd Pods to be recreated. This causes a short donwtime for the usercluster while the Pods are starting up and etcd is regaining its quorum.

To lower the performance impact on seed clusters, the `migrate-crds` command has a `--etcd-timeout` flag which can be used to make the migration wait for each etcd StatefulSet to become ready before proceeding with the next one. The flag takes the maximum time to wait as a Go duration, e.g. "5m" for 5 minutes or "30s" for 30 seconds. By default this function is disabled (set to `0s`).

If the StatefulSet does not get ready within the timeout, a warning is logged and the migration continues with the next usercluster. This is so that even setting a very short timeout (5 seconds for example) can be a useful way to slow down the migration.
{{% /notice %}}

As the migration can take between 10 and 60 minutes (depending on the number of seed and user clusters), it can be a good idea to add the global `--verbose` flag to get a faster moving progress report.

When you're ready, start the migration:

```bash
./kubermatic-installer --verbose migrate-crds --etcd-timeout=1m
```

The installer will now

* perform the same preflight checks as the `preflight` command, plus it checks that no KKP controllers are running,
* create a backup of all KKP resources per seed cluster,
* install the new CRDs,
* migrate all KKP resources,
* adjust the owner references and
* optionally remove the old resources if `--remove-old-resources` was given (this can be done manually at any time later on).

{{% notice note %}}
The command is idempotent and can be interrupted and restarted at any time. It will have to go through already migrated resources again, though.
{{% /notice %}}

{{% notice note %}}
If `--remove-old-resources` is not specified, both the old and new CRDs will co-exist at the same time. While the KKP controllers are not affected by this, running commands like `kubectl get clusters` will not behave as expected. Users must be specific and use the fully qualified resource name, like `kubectl get clusters.kubermatic.k8c.io` (to get the new cluster versions) or `kubectl get clusters.kubermatic.k8s.io` (to see the old cluster versions).
{{% /notice %}}

#### Upgrade

Once the migration has completed, download the migrated `KubermaticConfiguration` (it has moved into the `kubermatic.k8c.io` API group) from the cluster. Consider downloading it into a different file name than your old version of it or make sure you have a backup of it.

```bash
kubectl get kubermaticconfigurations.kubermatic.k8c.io -n kubermatic kubermatic -o yaml > /path/to/config.yaml
```

Open the file and make sure to clean up the `metadata` section so it only contains `name` and `namespace`:

```yaml
metadata:
  name: kubermatic
  namespace: kubermatic
```

use the `kubermatic-installer` as normal to upgrade to KKP 2.20:

```bash
./kubermatic-installer deploy
```

Refer to the [CE installation]({{< ref "../../../installation/install_kkp_CE/" >}}) or [EE installation]({{< ref "../../../installation/install_kkp_EE/" >}}) guides for more information.

The new operator will reconcile the master/seed controllers and reset their replica counts, which in turn will will begin to reconcile the user clusters.

If `Seed` resources are checked into version control, consider downloading the migrated versions from the cluster as well (repeat if using EE and multiple `Seeds`):

```bash
kubectl get seeds.kubermatic.k8c.io -n kubermatic <SEED NAME> -o yaml > /path/to/seed.yaml
```

Clean up the metadata section as well so it only has `name` and `namespace` (or compare to your previous YAML files) before checking it into version control.
