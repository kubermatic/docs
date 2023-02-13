+++
title = "Upgrading"
date =  2018-10-17T14:35:34+02:00
weight = 30
+++

This section contains important upgrade notes you should read before upgrading Kubermatic Kubernetes Platform (KKP) to the next minor version.

## Upgrade Guide

- [Upgrading from 2.21 to 2.22]({{< ref "./upgrade-from-2.21-to-2.22/" >}})

### Older Upgrade Guides

- [Upgrading from 2.20 to 2.21]({{< ref "./upgrade-from-2.20-to-2.21/" >}})
- [Upgrading from 2.19 to 2.20]({{< ref "./upgrade-from-2.19-to-2.20/" >}})

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

Backups must be done on the master and should be done on all seed cluster as
well.

### Upgrade Versioning Policy

KKP only supports upgrades from one minor version to the next (i.e. from 2.20 to 2.21).
You must not omit a minor version when doing an upgrade of your KKP installation
(i.e. 2.19 to 2.21 without upgrading to 2.20 in-between is not supported).

### Prepare for Reconciliation Load

Whenever KKP is upgraded, changes that affect possibly many cluster control-planes
can be rolled out. For example when new settings on Deployments are set, Docker
image versions or registries change, etc.

These mass-upgrades can cause severe load on the seed clusters, depending on the
number of user clusters. To prevent overloads, KKP has a mechanism to limit the
number of parallel reconciliations that can be active at any time,
`MaximumParallelReconciles`. This defaults to `10` and can be tweaked by editing
the `KubermaticConfiguration` and setting `spec.seedController.maximumParallelReconciles`
accordingly.

It is generally good practice to lower the limit prior to performing an upgrade,
observing the seed cluster load afterwards and then resetting it again.

## Upgrade Procedure

Unless otherwise noted in the upgrade notes for the given KKP minor version, the
upgrade procedure is roughly as follows. The exact paths may vary slightly
in-between minor releases, but the procedure is the same.

For KKP releases prior to 2.14, refer to https://github.com/kubermatic/kubermatic-installer to download the Helm charts
and configuration files. For KKP releases since 2.14, download the appropriate archive from
https://github.com/kubermatic/kubermatic/releases and extract it locally on your computer.

It's now time to perform any manual upgrade steps and update the Helm `values.yaml`
file used to install the charts (a single file for all charts is recommended, but
one `values.yaml` per chart is also possible).

After updating Helm values and possibly the local `KubermaticConfiguration` file, running `kubermatic-installer`
will upgrade the Helm charts installed by KKP and KKP itself:

```sh 
$ path/to/kubermatic-installer deploy kubermatic-master \
  --config path/to/kubermaticconfiguration.yaml \
  --helm-values path/to/values.yaml \
  --storageclass aws \ # adjust as appropriate
  --force
```

Observe KKP pods in the `kubermatic` namespace while they rotate to new component version to monitor the upgrade.
User clusters should start updating to adjust for changes introduced with the new KKP releases as well.
