+++
title = "Machine Rotation"
description = "Scenarios for machine rotation in Operating System Manager"
date = 2022-08-20T12:00:00+02:00
+++

Machine rotation is required against the following scenarios:

## Update in MachineDeployment

Machine Controller will rotate machines automatically when there is a new `revision` for the MachineDeployment i.e. any change in the `.spec.template` in the MachineDeployment.

OSM in that case will re-generate the OSC and secrets and annotate them with the `revision` number using `machinedeployment.clusters.k8s.io/revision` annotation. Machine Controller waits for the updated secrets and then provisions the machines.

In any other case where a new `revision` is not rolled out against a change in MachineDeployment. Users will have to manually rotate the machines. To perform this rotation for existing MachineDeployments please follow the guide at [Rolling Restart MachineDeploments][rolling-restart].

For example, manual rotation is required if user wants to change the OSP for a MachineDeployment.

```yaml
apiVersion: "cluster.k8s.io/v1alpha1"
kind: MachineDeployment
metadata:
  annotations:
    k8c.io/operating-system-profile: "osp-ubuntu"
```

## Update in OperatingSystemProfile

An update to `OperatingSystemProfile` will not result in an automatic rotation of the machines. This is an intentional design decision since an `OperatingSystemProfile` can be associated with multiple MachineDeployments. It is the user's responsibility to rotate the machines when the `OperatingSystemProfile` is updated. To perform this rotation for existing MachineDeployments please follow the guide at [Rolling Restart MachineDeploments][rolling-restart].

[rolling-restart]: {{< ref "../../cheat-sheets/rollout-machinedeployment" >}}
