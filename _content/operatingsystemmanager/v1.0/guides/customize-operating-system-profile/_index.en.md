+++
title = "Customize Operating System Profiles"
date = 2022-08-20T12:00:00+02:00
+++

One of the unique selling propositions for OSM is that it allows users to use custom OperatingSystemProfiles(OSPs). OSPs can be modified for various use cases; making them compatible with your infrastructure, installing and configuring custom/additional packages, customizing configurations for kubelet, container runtime, networking, storage etc.

{{% notice note %}}
For customization, new dedicated OSPs should be created by the end users. Updating the "default" OSPs is not recommended since they are managed by OSM itself and any changes will be reverted automatically.
{{% /notice %}}

## Create a custom OSP

As an example, let's modify the [default OSP for ubuntu](https://github.com/kubermatic/operating-system-manager/blob/master/deploy/osps/default/osp-ubuntu.yaml) and enable `swap memory`.

```yaml
{{< readfile "operatingsystemmanager/master/data/osp-ubuntu-swap-enabled.yaml" >}}
```

The changes we made to the OSP:

![Git Diff](/img/operatingsystemmanager/master/osp-ubuntu-swap-enabled.png?classes=shadow,border "Custom OperatingSystemProfile")

## Consume the custom OSP

Create/update your MachineDeployment to consume the custom OSP. The annotation `k8c.io/operating-system-profile` is used to specify the OSP for a MachineDeployment.

```yaml
apiVersion: cluster.k8s.io/v1alpha1
kind: MachineDeployment
metadata:
  name: << MACHINE_NAME >>
  namespace: kube-system
  annotations:
    k8c.io/operating-system-profile: "osp-ubuntu-swap-enabled"
spec:
  replicas: 1
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  selector:
    matchLabels:
      name: << MACHINE_NAME >>
  template:
    metadata:
      labels:
        name: << MACHINE_NAME >>
    spec:
      providerSpec:
        value:
          cloudProvider: "aws"
          cloudProviderSpec:
            region: "eu-central-1"
            availabilityZone: "eu-central-1a"
            vpcId: "vpc-name"
            subnetId: "subnet-id"
            instanceType: "t2.micro"
            instanceProfile: "kubernetes-v1"
            isSpotInstance: false
            diskSize: 50
            diskType: "gp2"
            ebsVolumeEncrypted: false
            ami: "my-custom-ami"
          operatingSystem: flatcar
          operatingSystemSpec:
            # 'provisioningUtility` is only used for flatcar os, can be set to ignition or cloud-init. Defaults to ignition.
            provisioningUtility: ignition
      versions:
        kubelet: "<< KUBERNETES_VERSION >>"
```

If you are updating the annotation on an existing MachineDeployment then the machines will not be rotated automatically. To perform a rotation for existing MachineDeployments please follow the guide at [Rolling Restart MachineDeploments][rolling-restart].

[rolling-restart]: {{< ref "../../cheat-sheets/rollout-machinedeployment" >}}
