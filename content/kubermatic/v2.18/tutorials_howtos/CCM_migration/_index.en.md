+++
title = "CCM migration"
date = 2021-07-29T14:07:15+02:00
weight = 40

+++

This manual explains how to migrate to using external Cloud Controller Managers for supporting providers.

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

### Out-of-tree CCM migration

Since the Kubernetes community has planned to deprecate and then remove all the code related to in-tree cloud
controller managers and the Kubernetes documentation explain how to migrate from in-tree to out-of-tree CCM, KKP itself
needed a mechanism to allow users to migrate their clusters to the out-of-tree implementation, as detailed below.

The CCM/CSI migration is supported only for the following providers so far:
* Openstack
* vSphere

{{% notice note %}}
The latest vSphere CSI driver [release](https://vsphere-csi-driver.sigs.k8s.io/releases/v2.3.0.html) does not support 
Kubernetes 1.22, hence it is **not** possible to *upgrade* already migrated vSphere clusters to Kubernetes 1.22, *migrate*
existing vSphere 1.22 clusters, and *create* new vSphere clusters with Kubernetes 1.22 (new clusters are by default controlled by the external CCM).
{{% /notice %}}

### Enabling the external cloud provider

The migration is specific per user cluster, meaning that it is activated by the `externalCloudProvider` feature in the
cluster spec.

```yaml
apiVersion: kubermatic.k8s.io/v1
kind: Cluster
metadata:
  name: crh4xbxz5f
spec:
...
  exposeStrategy: NodePort
  features:
    externalCloudProvider: true
  humanReadableName: determined-raman
...
```

When this feature gets enabled in a cluster belonging to a supported cloud provider, a mutating webhook patches the cluster
by adding two different annotations, producing the following cluster:

```yaml
apiVersion: kubermatic.k8s.io/v1
kind: Cluster
metadata:
  annotations:
    ccm-migration.k8c.io/migration-needed: ""
    csi-migration.k8c.io/migration-needed: ""
  name: crh4xbxz5f
spec:
...
  exposeStrategy: NodePort
  features:
    externalCloudProvider: true
  humanReadableName: determined-raman
...
```

The addition of the `externalCloudProvider` feature triggers the following operations:
* Deployment in the user cluster of the components being part of both the Cloud Controller Manager and the CSI controller
manager.
* Patch of The Machine controller deployment to configure the external cloud provider for the new machines.
* Addition of a condition related to the ccm migration to the cluster status.

### Finalize the CCM migration

The last step to complete the CCM migration is the rolling restart of all the machineDeployments in the user cluster. 
To do so via  cli, simply follow the guide in the machine-controller [documentation](https://docs.kubermatic.com/kubeone/master/cheat_sheets/rollout_machinedeployment/).

Performing the rolling update of all the machineDeployments implies the deletion of all the machines (hence all the nodes) and
their recreation. Since the MachineController has been patched to configure the external cloud provider for the new machines,
all the recreated machines will be configured to use the out-of-tree CCM. You can check this condition by verifying that
the new machines have the `ExternalCloudProvider` annotation:

```yaml
apiVersion: cluster.k8s.io/v1alpha1
kind: Machine
metadata:
  annotations:
    forceRestart: "1627548987807804576"
    v1.kubelet-featuregates.machine-controller.kubermatic.io/RotateKubeletServerCertificate: "true"
    v1.kubelet-flags.machine-controller.kubermatic.io/ExternalCloudProvider: "true"
  creationTimestamp: "2021-07-29T08:56:47Z"
...
```

Once all the machineDeployments are rolled out, and the new machines have the aforementioned annotation, the cluster
condition `CSIKubeletMigrationCompleted` will be set to true, and the migration is considered completed.

### Disabling the external CCM

Since the Kubernetes community is on the way to deprecating in-tree CCM, once the `externalCloudProvider` feature gets
enabled, it cannot be disabled.
