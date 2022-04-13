+++
title = "KubeVirt"
date = 2021-02-01T14:46:15+02:00
weight = 7

+++

## KubeVirt
Once KubeVirt is installed as what the [official documentation](https://kubevirt.io/quickstart_cloud/) guides, a few
steps should be followed in order to use KubeVirt with KKP.

### StorageClass Requirements
KKP uses [Containerized Data Importer](https://github.com/kubevirt/containerized-data-importer) (CDI) to import images and
provision volumes to launch the VMs. CDI provides the ability to populate PVCs with VM images or other data upon creation.
The data can come from different sources: a URL, a container registry, another PVC (clone), or an upload from a client.
For more information about the requirements of Kubernetes in general and CDI in specific, please follow the documentation
for PV,PVC and DV [here](https://github.com/kubevirt/containerized-data-importer/blob/master/doc/basic_pv_pvc_dv.md).

### KubeVirt Operator and Containerized Data Importer Version
KKP supports KubeVirt Operator >= 0.19.0 and the Containerized Data Importer >= v1.19.0. There are no hard requirements
to run KubeVirt, however a Kubernetes cluster consists of 3 nodes with 2 CPUs, 4GB of RAM and 30GB of storage, to have a
minimal installation.

### KubeVirt Configuration Requirements
KubeVirt requires the following configuration to be used with KKP.
- In case your KubeVirt namespace has the ConfigMap 'kubevirt-config' then use this ConfigMap for adding the feature gates to it. Look at the path `{.data.feature-gates}`
- Otherwise, add the feature gate to the resource of type `KubeVirt`. There should be a single resource of this type and its name can be chosen arbitrarily.

The configuration KKP requires:
```yaml
apiVersion: kubevirt.io/v1
kind: KubeVirt
metadata:
  name: kubevirt
  namespace: kubevirt
spec:
  configuration:
    developerConfiguration:
      featureGates:
      - DataVolumes
      - SRIOV
      - LiveMigration
      - CPUManager
      - CPUNodeDiscovery
      - Sidecar
      - Snapshot
      - HotplugVolumes
```

More information on the KubeVirt feature gates can be found [here: KubeVirt Feature Gates](https://kubevirt.io/user-guide/operations/activating_feature_gates/#how-to-activate-a-feature-gate)

### Use KKP with KubeVirt
In order to allow KKP to provision VMs(worker nodes) in KubeVirt, users provide the kubeconfig of the Kubernetes cluster
where the KubeVirt cluster is running. Users can add the content of the kubeconfig file in the third step of the cluster
creation. The content should be base64 encoded.

### KKP MachineDeployment Sample
Here is a sample of a MachineDeployment that can be used to provision a VM:

```yaml
apiVersion: "cluster.k8s.io/v1alpha1"
kind: MachineDeployment
metadata:
  name: my-kubevirt-machine
  namespace: kube-system
spec:
  paused: false
  replicas: 1
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  minReadySeconds: 0
  selector:
    matchLabels:
      name: my-kubevirt-machine
  template:
    metadata:
      labels:
        name: my-kubevirt-machine
    spec:
      providerSpec:
        value:
          sshPublicKeys:
            - "<< YOUR_PUBLIC_KEY >>"
          cloudProvider: "kubevirt"
          cloudProviderSpec:
            auth:
              kubeconfig:
                value: '<< KUBECONFIG >>'
            virtualMachine:
              template:
                cpus: "1"
                memory: "2048M"
                primaryDisk:
                  osImage: "<< YOUR_IMAGE_SOURCE >>"
                  size: "10Gi"
                  storageClassName: "<< YOUR_STORAGE_CLASS_NAME >>"
            affinity:
              podAffinityPreset: "" # Allowed values: "", "soft", "hard"
              podAntiAffinityPreset: "" # Allowed values: "", "soft", "hard"
              nodeAffinityPreset:
                type: "" # Allowed values: "", "soft", "hard"
                key: "foo"
                values:
                  - bar
          operatingSystem: "ubuntu"
          operatingSystemSpec:
            distUpgradeOnBoot: false
            disableAutoUpdate: true
      versions:
        kubelet: "1.18.10"
```
#### Node assignment for VMs
To constrain a VM to run on specific KubeVirt cluster nodes, affinity and anti-affinity rules can be used. See above given MachineDeployment example.

#### Creating VM from Presets
To create a VM from existing `VirtualMachineInstancePresets`, add the following configuration under `cloudProviderSpec.virtualMachine` in MachineDeployment:
```yaml
virtualMachine:
  flavor:
    name: "<< VirtualMachineInstancePresets_NAME >>"
  template:
    primaryDisk:
      osImage: "<< YOUR_IMAGE_SOURCE >>"
      size: "10Gi"
      storageClassName: "<< YOUR_STORAGE_CLASS_NAME >>"
```

---
**NOTE**

All the resources related to VM on the KubeVirt cluster will be created in a dedicated namespace.

---

