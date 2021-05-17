+++
title = "KubeVirt"
date = 2021-02-01T14:46:15+02:00
weight = 7

+++

## KubeVirt
Once KubeVirt is installed as what the [official documentation](https://kubevirt.io/quickstart_cloud/) guides, a few
steps should be followed in order to use KubeVirt with machine-controller.

[comment]: <> (Todo: not sure about this)
### Storage Requirements
The machine-controller uses [Containerized Data Importer](https://github.com/kubevirt/containerized-data-importer) (CDI) to import images and
provision volumes to launch the VMs. The data can come from different sources: a URL, a container registry, or an upload from a client.

[comment]: <> (Todo: not sure about this)
### KubeVirt Operator and Containerized Data Importer Version
The machine-controller supports KubeVirt Operator >= 0.19.0 and the Containerized Data Importer >= v1.19.0. There are no hard requirements
to run KubeVirt, however a Kubernetes cluster consists of 3 nodes with 2 CPUs, 4GB of RAM and 30GB of storage, to have a
minimal installation.

### MachineDeployment Sample
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
            storageClassName: "<< YOUR_STORAGE_CLASS_NAME >>"
            pvcSize: "10Gi"
            sourceURL:
            cpus: "1"
            memory: "2048M"
            kubeconfig:
              value: '<< KUBECONFIG >>'
            namespace: kube-system
          operatingSystem: "ubuntu"
          operatingSystemSpec:
            distUpgradeOnBoot: false
            disableAutoUpdate: true
      versions:
        kubelet: "1.18.10"
```
