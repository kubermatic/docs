+++
title = "KubeVirt"
date = 2021-02-01T14:46:15+02:00
weight = 7

+++

## KubeVirt (Technology Preview)
Once KubeVirt is installed as what the [official documentation](https://kubevirt.io/quickstart_cloud/) guides, a few
steps should be followed in order to use KubeVirt with KKP.

### StorageClass Requirements
KKP uses [Containerized Data Importer](https://github.com/kubevirt/containerized-data-importer) (CDI) to import images and
provision volumes to launch the VMs. CDI provides the ability to populate PVCs with VM images or other data upon creation.
The data can come from different sources: a URL, a container registry, another PVC (clone), or an upload from a client.
For more information about the requirements of Kubernetes in general and CDI in specific, please follow the documentation
for PV,PVC and DV [here](https://github.com/kubevirt/containerized-data-importer/blob/master/doc/basic_pv_pvc_dv.md).

To initialize a storage class from the KubeVirt infrastructure cluster on a user cluster, add `kubevirt-initialization.k8c.io/initialize-sc: 'true'` annotation to the storage class of your choice. 
This action has to take place before user cluster creation.

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

---
**NOTE**

All the resources related to VM on the KubeVirt cluster will be created in a dedicated namespace in the infrastructure cluster. This name follow the pattern `cluster-xyz`, where `xyz` is the `id` of the cluster created with KKP.

![Dedicated Namespace](/img/kubermatic/master/architecture/supported-providers/kubevirt/Dedicated-namespace.jpg)

How to know the `id` of the cluster created ?

![Cluster Id](/img/kubermatic/master/architecture/supported-providers/kubevirt/clusterid.png)

With the example of the previous image, the cluster `elastic-mayer` has a cluster id `gff5gnxc7r`, so all resources for this cluster are located in the `cluster-gff5gnxc7r` namespace in the KubeVirt infrastructure cluster.

---

#### Node assignment for VMs
To constrain a VM to run on specific KubeVirt cluster nodes, affinity and anti-affinity rules can be used. See above given MachineDeployment example.

---
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
To apply a `VirtualMachineInstancePreset` to a VM, this VirtualMachineInstancePreset should be created in the `default` namespace.
KKP will then copy into the dedicated `clusterxyz` namespace and start the VirtualMachine applying it.

![Preset Copy   ](/img/kubermatic/master/architecture/supported-providers/kubevirt/Preset.jpg)

A default `VirtualMachineInstancePreset` named `kubermatic-standard` is always added to the list by KKP (even if not existing in the `default` namespace).

```yaml
{
apiVersion: kubevirt.io/v1
kind: VirtualMachineInstancePreset
metadata:
  name: kubermatic-standard
spec:
  domain:
    resources:
      requests:
        cpu: 2
        memory: 8Gi
      limits:
        cpu: 2
        memory: 8Gi
  selector:
    matchLabels:
      kubevirt.io/flavor: kubermatic-standard
}
```

To create new a `VirtualMachineInstancePreset` usable to apply to new VMs, create it in the `default` namespace. It will be present in the `VM Flavor` dropdown list selection and be copied in the right namespace by KKP.

*Note 1:* Update of a `VirtualMachineInstancePreset` in the `default` namespace.

What happens if we update a `VirtualMachineInstancePreset` existing in the `default` namespace ?
- The updated `VirtualMachineInstancePreset` will be reconciled from the `default` namespace into the `cluster-xyz` namespace. Give it some time to be reconciled. The reconciliation interval is configurable (refer to `providerReconciliationInterval` in [Seed configuration](https://docs.kubermatic.com/kubermatic/master/tutorials-howtos/project-and-cluster-management/seed-cluster/))
- For all `VirtualMachineIsntances` already created, this will have no impact. Please refer to [KubeVirt Preset documentation](https://kubevirt.io/user-guide/virtual_machines/presets/#updating-a-virtualmachineinstancepreset)
- The update will then be effective for new `VirtualMachineIsntances`.

*Note 2:* Limitation of the list of reconciled fields.

Please note that not all fields of the `VirtualMachineInstance` are merged into the `VirtualMachineInstance`.
[](https://github.com/kubevirt/kubevirt/blob/main/pkg/virt-api/webhooks/mutating-webhook/mutators/preset.go#L123)
For the `domain`, only the following fields are merged:
- `CPU`
- `Firmware`
- `Clock`
- `Features`
- `Devices.Watchdog`
- `IOThreadsPolicy`

*Note3:* Migration to the instanceType API

Please note that in the next KKP release, we will migrate to the new *VirtualMachineInstancetype* ([alpha release](https://github.com/kubevirt/api/blob/main/instancetype/v1alpha1/types.go#L35)), as the *VirtualMachineInstancePreset* will be deprecated.
This will for example lift the limitation around the list of merged fields from the `VirtualMachineInstance` and provide deterministic behavior with immediate detection of merge conflicts.


---

### Advanced configuration

#### Advanced disk configuration

For the basic configuration, disk images are imported from a web server, via HTTP download, by specifying a URL when creating a cluster, at the `Inital Nodes` step, in the `Primary Disk` section as shown in the screenshot below.

![Primary Disk](/img/kubermatic/master/architecture/supported-providers/kubevirt/primary-disk.png)

#### Usage of Custom Local Disk Name instead of URL for disk image

However, it's possible to specify a Custom Local Disk name instead of a URL. This should be the name of a DataVolume that already exists in the cluster dedicated namespace of the KubeVirt infrastructure cluster (*cluster-zyz* namespace).
When specifying a DataVolume name instead of a URL, **the image disk will be cloned** instead of being downloaded from the HTTP source URL.  

**NOTE:** the source DataVolume must exist in the *cluster-xyz* namespace where the VM is created. Cloning across namespaces is not allowed.


![DataVolume cloning](/img/kubermatic/master/architecture/supported-providers/kubevirt/DV-cloning.png)

The source DataVolume can be created *manually* (not from KKP) by the user in the *cluster-xyz* namespace, or it can also be created using KKP when creating the cluster at the `Settings` step, with the `Advanced Disk configuration` panel.

![DataVolume creation](/img/kubermatic/master/architecture/supported-providers/kubevirt/Source-DV-creation.png)

In this panel, the user can add several Custom Local Disks (DataVolumes).
For each of them, the user must specify:
- the disk name (DataVolume name, must be compliant with [Kubernetes object names constraints](https://kubernetes.io/docs/concepts/overview/working-with-objects/names/))
- the Storage Class from a dropdown list
- the disk size
- the image disk URL for image download.

The same Custom Local Disk can be used as source of cloning for all the VMs (same MachineDeployment or not) in the same cluster.

---
#### Scheduling settings
It's possible to control how the tenant nodes are scheduled on the infrastructure nodes.
![Scheduling](/img/kubermatic/master/architecture/supported-providers/kubevirt/Scheduling.png)

We provide 3 different types of scheduling for the KubeVirt tenant nodes:
- Ensure co-location on the same infrastructure node (*Pod Affinity Preset*).
- Prevent co-location on the same infrastructure node (*Pod Anti Affinity Preset*).
- Schedule on nodes having some specific labels (*Node Affinity Preset*).

This setup is done in the `Initial Nodes` step of KKP dashboard when creating a cluster.

![Dashboard](/img/kubermatic/master/architecture/supported-providers/kubevirt/Dashboard-scheduling.png) 


For each of this scheduling types (*Pod Affinity Preset*, *Pod Anti Affinity Preset*, *Node Affinity Preset*), we can also specify if we want the affinity to be:
- *"hard"* 
-  *"soft"* 

To achieve this goal, we use the [KubeVirt VM Affinity and Anti-affinity capabilities](https://kubevirt.io/user-guide/operations/node_assignment/#affinity-and-anti-affinity).


*"hard"* or *"soft"* are related to the [Kubernetes: Assigning Pods to Nodes](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/). The following table shows the mapping:
| Affinity type | Kubernetes affinity                             |
|---------------|-------------------------------------------------|
| hard          | requiredDuringSchedulingIgnoredDuringExecution  |
| soft          | preferredDuringSchedulingIgnoredDuringExecution |


#### How scheduling settings influence a MachineDeployment object

Scheduling settings are represented in the *MachineDeployment* object under *spec.providerSpec.value.affinity*:

```yaml
kind: MachineDeployment
spec:
 // ...
  template:
    spec:
      providerSpec:
        value:
            // ....
            affinity:
              podAffinityPreset: "" # Allowed values: "", "soft", "hard"
              podAntiAffinityPreset: "" # Allowed values: "", "soft", "hard"
              nodeAffinityPreset:
                type: "" # Allowed values: "", "soft", "hard"
                key: "foo"
                values:
                  - bar
// ....
```

**Important Note**:
- `podAffinityPreset` and `podAntiAffinityPreset` are **mutually exclusive**. The Anti-Affinity setting works the opposite of Affinity.
- `podAffinityPreset` can be specified along with `nodeAffinityPreset`: this allows ensure that the KubeVirt tenant nodes are co-located on a single infrastructure node that has some specific labels.
- `podAntiAffinityPreset` can be specified along with `nodeAffinityPreset`: this prevents the KubeVirt tenant nodes from being co-located on the same infrastructure node, but be located on infrastructure nodes that have some specific labels.

---
1- **Usage of Pod Affinity Preset**

<details>
  <summary>With the following *MachineDeployment* specification</summary>

```yaml
kind: MachineDeployment
spec:
 // ...
  template:
    spec:
      providerSpec:
        value:
            // ....
            affinity:
              podAffinityPreset: "hard" # or "soft"
// ....
```
</details>

The following *VirtualMachine* specification will be generated
- with affinity type *"hard"*:
<details>
 <summary>VirtualMachine* specification</summary>

```yaml
kind: VirtualMachine
metadata:
  ...
spec:
  ...
  template:
    ...
    spec:
      affinity:
        podAffinity:
          requiredDuringSchedulingIgnoredDuringExecution: ### as affinity is "hard"
          - labelSelector:
              matchLabels:
                md: qqbxz6vqxl-worker-bjqdtt # label common to all VirtualMachines belonging to the same MachineDeployment
            topologyKey: kubernetes.io/hostname
```
</details>

- with affinity type *"soft"*:
<details>
 <summary>VirtualMachine* specification</summary>

```yaml
kind: VirtualMachine
metadata:
  ...
spec:
  ...
  template:
    ...
    spec:
      affinity:
        podAffinity:
          preferredDuringSchedulingIgnoredDuringExecution: ### as affinity is "soft"
          - labelSelector:
              matchLabels:
                md: qqbxz6vqxl-worker-bjqdtt # label common to all VirtualMachines belonging to the same MachineDeployment
            topologyKey: kubernetes.io/hostname
```
</details>

---
2- **Usage of Pod Anti Affinity Preset**

<details>
  <summary>With the following *MachineDeployment* specification</summary>

```yaml
kind: MachineDeployment
spec:
 // ...
  template:
    spec:
      providerSpec:
        value:
            // ....
            affinity:
              podAntiAffinityPreset: "hard" # or "soft"
// ....
```
</details>

The following *VirtualMachine* specification will be generated
- with affinity type *"hard"*:
<details>
 <summary>VirtualMachine* specification</summary>

```yaml
kind: VirtualMachine
metadata:
  ...
spec:
  ...
  template:
    ...
   spec:
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchLabels:
                md: qqbxz6vqxl-worker-bjqdtt # label common to all VirtualMachines belonging to the same MachineDeployment
            topologyKey: kubernetes.io/hostname
```
</details>

- with affinity type *"soft"*:
<details>
 <summary>VirtualMachine* specification</summary>

```yaml
kind: VirtualMachine
metadata:
  ...
spec:
  ...
  template:
    ...
    spec:
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution: ### as affinity is "soft"
          - labelSelector:
              matchLabels:
                md: qqbxz6vqxl-worker-bjqdtt # label common to all VirtualMachines belonging to the same MachineDeployment
            topologyKey: kubernetes.io/hostname
```
</details>

---
3- **Usage of Node Affinity Preset**

<details>
  <summary>With the following *MachineDeployment* specification</summary>

```yaml
kind: MachineDeployment
spec:
 // ...
  template:
    spec:
      providerSpec:
        value:
            // ....
            affinity:
              nodeAffinityPreset:
                type: "hard" # or "soft"
                key: "foo"
                values:
                  - bar
```
</details>

The following *VirtualMachine* specification will be generated
- with affinity type *"hard"*:

<details>
 <summary>VirtualMachine* specification</summary>

```yaml
kind: VirtualMachine
metadata:
  ...
spec:
  ...
  template:
    ...
   spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: foo
                operator: In
                values:
                - bar
```
</details>

- with affinity type *"soft"*:
<details>
  <summary>VirtualMachine* specification</summary>

 ```yaml
kind: VirtualMachine
metadata:
  ...
spec:
  ...
  template:
    ...
spec:
      affinity:
        nodeAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: foo
                operator: In
                values:
                - bar
```
</details>

---


### Enable KubeVirt monitoring
Install [prometheus-operator](https://github.com/prometheus-operator/prometheus-operator) on KubeVirt cluster.
Then update `KubeVirt` resource similar to this example:
```yaml
apiVersion: kubevirt.io/v1
kind: KubeVirt
metadata:
  name: kubevirt
spec:
  monitorNamespace: "<<PROMETHEUS_NAMESPACE>>"
  monitorAccount: "<<PROMETHEUS_SERVICE_ACCOUNT_NAME>>"
```
For more details refer this [document](https://kubevirt.io/user-guide/operations/component_monitoring/).

After completing the above setup, you can import this [KubeVirt-Dasboard](https://github.com/kubevirt/monitoring/tree/main/dashboards/grafana) in Grafana to monitor `KubeVirt` components.

Follow the below steps to import the dashboard in Grafana:
- Download this [KubeVirt-Dasboard](https://github.com/kubevirt/monitoring/tree/main/dashboards/grafana).
- Open Grafana and click on `+` icon on the left side of the application. After that select `Import` option.
- In the below window you can upload the [KubeVirt-Dasboard](https://github.com/kubevirt/monitoring/tree/main/dashboards/grafana) `json` file.
 
![Grafana Dashboard](/img/kubermatic/master/monitoring/kubevirt/grafana.png)


