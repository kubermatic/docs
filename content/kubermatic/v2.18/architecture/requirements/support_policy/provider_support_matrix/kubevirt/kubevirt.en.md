+++
title = "KubeVirt"
description = "Once KubeVirt is installed, a few steps should be followed to use KubeVirt with KKP. Read on the document to get a complete understanding of these steps."
date = 2021-02-01T14:46:15+02:00
weight = 7

+++

## KubeVirt (Technology Preview)
Once KubeVirt is installed as what the [official documentation](https://kubevirt.io/quickstart_cloud/) guides, a few
steps should be followed in order to use KubeVirt with KKP.

### Storage

#### KubeVirt Operator and Containerized Data Importer Version
KKP supports KubeVirt Operator >= 0.19.0 and the Containerized Data Importer >= v1.19.0. There are no hard requirements
to run KubeVirt, however a Kubernetes cluster consists of 3 nodes with 2 CPUs, 4GB of RAM and 30GB of storage, to have a
minimal installation.

#### KubeVirt infrastructure cluster StorageClass Requirements
KKP uses [Containerized Data Importer](https://github.com/kubevirt/containerized-data-importer) (CDI) to import images and
provision volumes to launch the VMs. CDI provides the ability to populate PVCs with VM images or other data upon creation.
The data can come from different sources: a URL, a container registry, another PVC (clone), or an upload from a client.
For more information about the requirements of Kubernetes in general and CDI in specific, please follow the documentation
for PV,PVC and DV [here](https://github.com/kubevirt/containerized-data-importer/blob/master/doc/basic_pv_pvc_dv.md).

#### User cluster StorageClass Requirements
For each user cluster, KKP deploys a [KubeVirt CSI Driver Operator](https://github.com/kubermatic/kubevirt-csi-driver-operator) that provisions a [KubeVirt CSI Driver](https://github.com/kubevirt/csi-driver).
The only requirement for new user clusters is to manually deploy a storage class with appropriate configuration
that points to the storage class from the infrastructure cluster.

Example storage class configuration:

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: kubevirt
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
provisioner: csi.kubevirt.io
parameters:
  infraStorageClassName: standard   # name of the storage class on the infrastructure cluster
  bus: scsi
```

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
