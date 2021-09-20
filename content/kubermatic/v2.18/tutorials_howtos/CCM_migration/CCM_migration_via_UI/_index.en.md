+++
title = "CCM migration via UI"
date = 2021-07-29T12:07:15+02:00
weight = 10

+++

This manual explains how to migrate to using external Cloud Controller Managers for supported providers via UI.

## Cloud Controller Manager (CCM)

The [CCM](https://kubernetes.io/docs/concepts/architecture/cloud-controller/) (Cloud Controller Manager) is a Kubernetes
control plane component that embeds cloud-specific control logic. There are two different kinds of Cloud controller managers:
in-tree and out-of-tree. According to the Kubernetes [design proposal](https://github.com/kubernetes/enhancements/tree/master/keps/sig-cloud-provider/2395-removing-in-tree-cloud-providers),
the in-tree code is "code that lives in the core Kubernetes repository [k8s.io/kubernetes](https://github.com/kubernetes/kubernetes/)",
while the out-of-tree code is "code that lives in an external repository outside of [k8s.io/kubernetes](https://github.com/kubernetes/kubernetes/)".

The first cloud-specific interaction logic was completely in-tree, bringing in a not-negligible amount of problems,
among which the dependency of the CCM release cycle from the Kubernetes core release cycle and the difficulty to add new providers
to the Kubernetes core code. Then, the Kubernetes community moved toward the out-of-tree implementation by introducing
a plugin mechanism that allows different cloud providers to integrate their platforms with Kubernetes.

### CCM migration status
To allow migration from in-tree to out-of-tree CCM for existing cluster, the cluster details view has been extended by a
section in the top area, the "External CCM Migration Status", that indicates the status of the CCM migration.

![Cluster Details View](ccm_migration_cluster_view.png?height=350px&classes=shadow,border "Cluster Details View")

The "External CCM Migration Status" can have four different possible values:

#### Not needed
The cluster already uses the external CCM.
![ccm_migration_not_needed](ccm_migration_not_needed.png?height=60px&classes=shadow,border)

#### Supported
KKP supports the external CCM for the given cloud provider, therefore the cluster can be migrated.
![ccm_migration_supported](ccm_migration_supported.png?height=130px&classes=shadow,border)

When clicking on this button, a windows pops up to confirm the migration.
![ccm_migration_supported](ccm_migration_confirm.png?height=200px&classes=shadow,border)

#### In progress
External CCM migration has already been enabled for the given cluster, and the migration is in progress.
![ccm_migration_in_progress](ccm_migration_in_progress.png?height=60px&classes=shadow,border)

#### Unsupported
KKP does not support yet the external CCM for the given cloud provider.
![ccm_migration_unsupported](ccm_migration_unsupported.png?height=60px&classes=shadow,border)

### Roll out the machineDeployments
Once the CCM migration has been enabled by clicking on the "Supported" button, the migration procedure will hang in 
"In progress" status until all the `machineDeployments` will be rolled out. To roll out a `machineDeployment` get into 
the `machineDeployment` view and click on the circular arrow in the top right.
![ccm_migration_md](ccm_migration_machine_deployment.png?height=300px&classes=shadow,border)

Then, you will be asked to confirm the restart operation.
![ccm_migration_confirm_rollout](ccm_migration_confirm_rollout.png?height=200px&classes=shadow,border)

Once all the `machineDeployments` will be rolling restarted, the status will get into "Not needed" status to indicate
that there is no need for CCM migration.
