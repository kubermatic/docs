+++
title = "Upgrading"
date =  2018-10-17T14:35:34+02:00
weight = 30
+++

This section contains important upgrade notes you should read before upgrading Kubermatic Kubernetes Platform (KKP) to the next minor version.

## Upgrade Guides

{{% children %}}
{{% /children %}}

## General Guidelines

This section describes the recommended steps to be taken for every KKP upgrade, including from patch release to patch release.

### Create Backups

Even though regular backups should already be in place, it's always good to be
on the safe side and ensure that backups are made prior to upgrades.

The Velero chart, if installed, includes a backup job that copies all resources
(Clusters, Seeds, Users, Projects, ...) on a regular basis. Another option is
to simply use `kubectl` to dump all KKP resources:

```bash
export KUBECONFIG=...

while IFS= read -r crd; do
  echo "Dumping $crd ..."
  kubectl get $crd -A -o yaml > $crd.yaml
done <<< "$(kubectl get crd | grep kubermatic | cut -f1 -d' ')"
```

Backups must be done on the master and should be done on all seed clusters as
well.

### Upgrade Versioning Policy

KKP only supports upgrades from one minor version to the next (i.e. from 2.21 to 2.22).
You must not omit a minor version when doing an upgrade of your KKP installation
(i.e. 2.19 to 2.21 without upgrading to 2.20 in-between is not supported).

### Prepare for Reconciliation Load

Whenever KKP is upgraded, changes that affect possibly many user cluster control planes
can be rolled out. For example when new settings on Deployments are set, container
image versions or registries change, etc.

These mass-upgrades can cause severe load on seed clusters, depending on the
number of user clusters. To prevent overloads, KKP has a mechanism to limit the
number of parallel reconciliations that can be active at any time,
`MaximumParallelReconciles`. This defaults to `10` and can be tweaked by editing
the `KubermaticConfiguration` and setting `spec.seedController.maximumParallelReconciles`
accordingly.

It is generally good practice to lower the limit prior to performing an upgrade,
observing the seed cluster load afterwards and then resetting it again.
