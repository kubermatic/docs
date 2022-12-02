+++
title = "KubeVirt (Technology Preview)"
date = 2021-02-01T14:46:15+02:00
enableToc = true
weight = 7

+++

## Installation

### Requirements
Kubernetes cluster where KubeVirt is installed (KubeVirt infrastructure cluster) must be in range of [supported KKP Kubernetes clusters](https://docs.kubermatic.com/kubermatic/v2.21/tutorials-howtos/operating-system-manager/compatibility/#kubernetes-versions). The strong recommendation is to use the latest supported version.

The infrastructure cluster must have installed:
* KubeVirt >= 0.57 and support the selected Kubernetes version.
* Containerized Data Importer that supports the selected KubeVirt and Kubernetes version.

Visit [KubeVirt compatibility page](https://docs.kubermatic.com/kubermatic/v2.21/tutorials-howtos/operating-system-manager/compatibility/#kubernetes-versions) to find out which version of KubeVirt you can install on your infrastructure cluster.

A minimal Kubernetes cluster should consist of 3 nodes with 2 CPUs, 4GB of RAM and 30GB of storage.

### KubeVirt on Kubernetes

Follow the [official guide](https://kubevirt.io/user-guide/operations/installation/#installing-kubevirt-on-kubernetes) to install KubeVirt on Kubernetes

### Configuration

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
      - LiveMigration
      - CPUManager
      - CPUNodeDiscovery
      - Sidecar
      - Snapshot
      - HotplugVolumes
```

More information on the KubeVirt feature gates can be found [here: KubeVirt Feature Gates](https://kubevirt.io/user-guide/operations/activating_feature_gates/#how-to-activate-a-feature-gate)

---

## Usage
In order to allow KKP to provision VMs(worker nodes) in KubeVirt, users provide the kubeconfig of the Kubernetes cluster
where the KubeVirt cluster is running (called the infra cluster).
Users can add the content of the kubeconfig file in the third step of the cluster creation.
The **kubeconfig must be base64** encoded.

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
            clusterName: <cluster-id>
            auth:
              kubeconfig:
                value: "<< KUBECONFIG_BASE64 >>"
            virtualMachine:
              instancetype:
                name: "standard-2"
                kind: "VirtualMachineInstancetype" # Allowed values: "VirtualMachineInstancetype"/"VirtualMachineClusterInstancetype"
              preference:
                name: "sockets-advantage"
                kind: "VirtualMachinePreference" # Allowed values: "VirtualMachinePreference"/"VirtualMachineClusterPreference"
              template:
                cpus: "1"
                memory: "2048M"
                primaryDisk:
                  osImage: "<< YOUR_IMAGE_SOURCE >>"
                  size: "10Gi"
                  storageClassName: "<< YOUR_STORAGE_CLASS_NAME >>"
            affinity:
              nodeAffinityPreset:
                type: "" # Allowed values: "", "soft", "hard"
                key: "foo"
                values:
                  - bar
            topologySpreadConstraints:
              - maxSkew: "1"
                topologyKey: "kubernetes.io/hostname"
                whenUnsatisfiable: "" # Allowed values: "DoNotSchedule", "ScheduleAnyway"
          # Can also be `centos`, must align with he configured registryImage above
          operatingSystem: "ubuntu"
          operatingSystemSpec:
            distUpgradeOnBoot: false
            disableAutoUpdate: true
            # 'rhelSubscriptionManagerUser' is only used for rhel os and can be set via env var `RHEL_SUBSCRIPTION_MANAGER_USER`
            rhelSubscriptionManagerUser: "<< RHEL_SUBSCRIPTION_MANAGER_USER >>"
            # 'rhelSubscriptionManagerPassword' is only used for rhel os and can be set via env var `RHEL_SUBSCRIPTION_MANAGER_PASSWORD`
            rhelSubscriptionManagerPassword: "<< RHEL_SUBSCRIPTION_MANAGER_PASSWORD >>"
            # 'rhsmOfflineToken' if it was provided red hat systems subscriptions will be removed upon machines deletions, and if wasn't
            # provided the rhsm will be disabled and any created subscription won't be removed automatically
            rhsmOfflineToken: "<< REDHAT_SUBSCRIPTIONS_OFFLINE_TOKEN >>"
      versions:
        kubelet: 1.23.13

```

All the resources related to VM on the KubeVirt cluster will be created in a dedicated namespace in the infrastructure cluster.
This name follow the pattern `cluster-xyz`, where `xyz` is the `id` of the cluster created with KKP.

![Dedicated Namespace](/img/kubermatic/main/architecture/supported-providers/kubevirt/Dedicated-namespace.jpg)

How to know the `id` of the cluster created ?

![Cluster Id](/img/kubermatic/main/architecture/supported-providers/kubevirt/clusterid.png)

With the example of the previous image, the cluster `elastic-mayer` has a cluster id `gff5gnxc7r`,
so all resources for this cluster are located in the `cluster-gff5gnxc7r` namespace in the KubeVirt infrastructure cluster.

### Virtual Machines Scheduling
It is possible to control how the tenant nodes are scheduled on the infrastructure nodes.
![Scheduling](/img/kubermatic/main/architecture/supported-providers/kubevirt/Scheduling.png)

We provide control of the user cluster nodes scheduling over topology spread constraints and node affinity presets mechanisms. You can use a combination of them, or they can work independently:
- Spread across a given topology domains (*TopologySpreadConstraints*).
- Schedule on nodes having some specific labels (*Node Affinity Preset*).


{{% notice note %}}
`Pod Affinity Preset` and `Pod Anti Affinity Preset` are deprecated. Migration to `TopologySpreadConstraints` does not affect existing MachineDeployment and corresponding VMs.
If existing MachineDeployment has Pod Affinity/Anti-Affinity Preset spec, it will remain the same. But any update of existing MachineDeployment will trigger creation of new VMs which will not have Pod Affinity/Anti-Affinity Preset spec
, instead they will have default topology spread constraint. Refer to the migration notes from KKP 2.21 to KKP 2.22
{{% /notice %}}

TopologySpreadConstraint for VMs are related to [Kubernetes:Pod Topology Spread Constraints](https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/). Below is the description of different fields of a `TopologySpreadConstraints`:

| Field             | Description                                                                 |
|-------------------|-----------------------------------------------------------------------------|
| maxSkew           | degree to which VMs may be unevenly distributed                             |
| topologyKey       | key of infra-node labels                                                    |
| whenUnsatisfiable | indicates how to deal with a VM if it doesn't satisfy the spread constraint |

The allowed values for `whenUnsatisfiable` are as follows:
- `DoNotSchedule` tells the scheduler not to schedule if it doesn't satisfy the spread constraint.
- `ScheduleAnyway` tells the scheduler to schedule the VM in any location, but giving higher precedence to topologies that would help reduce the skew.

For *Node Affinity Preset* scheduling type, we can specify if we want the affinity to be:
- *"hard"*
-  *"soft"*

To achieve this goal, we use the [KubeVirt VM Affinity and Anti-affinity capabilities](https://kubevirt.io/user-guide/operations/node_assignment/#affinity-and-anti-affinity).


*"hard"* or *"soft"* are related to the [Kubernetes: Assigning Pods to Nodes](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/). The following table shows the mapping:
| Affinity type | Kubernetes affinity                             |
|---------------|-------------------------------------------------|
| hard          | requiredDuringSchedulingIgnoredDuringExecution  |
| soft          | preferredDuringSchedulingIgnoredDuringExecution |


#### How scheduling settings in the MachineDeployment influence a VirtualMachine object

Scheduling settings are represented in the *MachineDeployment* object under *spec.providerSpec.value.affinity* and *spec.providerSpec.value.topologySpreadConstraints*:

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
                type: "" # Allowed values: "", "soft", "hard"
                key: "foo"
                values:
                  - bar
            topologySpreadConstraints:
              - maxSkew: "1"
                topologyKey: "kubernetes.io/hostname"
                whenUnsatisfiable: "" # Allowed values: "DoNotSchedule", "ScheduleAnyway"
// ....
```

{{< tabs name="Scheduling settings" >}}
{{% tab name="Usage of Custom TopologySpreadConstraints" %}}

With the following `MachineDeployment` specification that contains a custom `topologySpreadConstraints` section

```yaml
kind: MachineDeployment
spec:
 // ...
  template:
    spec:
      providerSpec:
        value:
            // ....
          topologySpreadConstraints:
              - maxSkew: "1"
                topologyKey: "zone"
                whenUnsatisfiable: "DoNotSchedule"
// ....
```

the following `VirtualMachine` specification will be generated from above `MachineDeployment`

```yaml
kind: VirtualMachine
metadata:
  ...
spec:
  ...
  template:
    ...
    spec:
      topologySpreadConstraints:
        - maxSkew: 1
          topologyKey: zone
          whenUnsatisfiable: DoNotSchedule
          labelSelector:
            matchLabels:
              md : qqbxz6vqxl-worker-bjqdtt # label common to all VirtualMachines belonging to the same MachineDeployment
```

{{% /tab %}}
{{% tab name="Usage of Default TopologySpreadConstraints" %}}

If **no** `topologySpreadConstraints` is defined, a **default** `topologySpreadConstraints` will be generated in the `MachineDeployment`,

With the following `MachineDeployment` specification

```yaml
kind: MachineDeployment
spec:
 // ...
  template:
    spec:
      providerSpec:
        value:
            // ....
          // topologySpreadConstraints: # none defined
           
// ....
```

Find below the content of the default `topologySpreadConstraints` generated (if no `topologySpreadConstraints` is specified in the `MachineDeployment`).

```yaml
kind: VirtualMachine
metadata:
  ...
spec:
  ...
  template:
    ...
    spec:
      topologySpreadConstraints:
        - maxSkew: 1
          topologyKey: kubernetes.io/hostname
          whenUnsatisfiable: ScheduleAnyway
          labelSelector:
            matchLabels:
              md : qqbxz6vqxl-worker-bjqdtt # label common to all VirtualMachines belonging to the same MachineDeployment
```
{{% /tab %}}

{{% tab name="Usage of Node Affinity Preset (hard)" %}}

With the following `MachineDeployment` specification (`nodeAffinityPreset.type="hard"`)

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
                type: "hard" 
                key: "foo"
                values:
                  - bar
```

The following *VirtualMachine* specification will be generated

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
{{% /tab %}}
{{% tab name="Usage of Node Affinity Preset (soft)" %}}

With the following `MachineDeployment` specification ((`nodeAffinityPreset.type="soft"`))

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
                type: "soft" 
                key: "foo"
                values:
                  - bar
```

The following *VirtualMachine* specification will be generated

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
{{% /tab %}}
{{< /tabs >}}

---

### Virtual Machines Templates

{{% notice note %}}
`VirtualMachineInstancePresets` (`flavor` ) is deprecated. Migration to `Instancetype` and `Preference` does not affect existing MachineDeployment and corresponding VMs but a manual migration of the `MachineDeployment` must be done before any update (including re-scale)
Refer to the migration notes from KKP 2.21 to KKP 2.22 (can be done safely after KKP was upgraded from 2.21 to 2.22)
{{% /notice %}}


KKP allows to benefit from [Kubevirt Instancetypes and Preferences](https://kubevirt.io/user-guide/virtual_machines/instancetypes/).

Instancetypes and preferences provide a way to define a set of resource, performance and other runtime characteristics, allowing users to reuse these definitions across multiple VirtualMachines.

There are 2 categories of instancetypes that you can use:
- **Kubermatic**: some instancetypes/preferences provided by default by Kubermatic.
- **Custom**: instancetypes/preferences that you can freely provide.

This can be done at the *Initial Nodes* step during the cluster creation.
![Instancetypes Preferences](/img/kubermatic/main/architecture/supported-providers/kubevirt/instancetypes-preferences.png)

{{% notice note %}}
You can display the content of any instancetype/preference by pressing the `View` button.
{{% /notice %}}



#### How the Templates settings in the MachineDeployment settings affect the VirtualMachine object

{{< tabs name="Template settings" >}}
{{% tab name="Custom InstanceTypes/Preferences" %}}
If you select some **Custom** Instancetype/Preference, for example *custom-instancetype-1*/*custom-preference-1*, the following `MachineDeployment` will be created.


```yaml
kind: MachineDeployment
spec:
 // ...
  template:
    spec:
      providerSpec:
        value:
            // ....
            virtualMachine:
              instancetype:
                name: "custom-instancetype-1"
                kind: "VirtualMachineClusterInstancetype"
              preference:
                name: "custom-preference-1"
                kind: "VirtualMachineClusterPreference" 
```

which will create a `VirtualMachine` with this specification:

```yaml
piVersion: kubevirt.io/v1
kind: VirtualMachine
metadata:
  // ---
spec:
  // ...
  instancetype:
    kind: VirtualMachineClusterInstancetype
    name: custom-instancetype-1
  preference:
    kind: VirtualMachineClusterPreference
    name: custom-preference-1
  template:
```

{{% /tab %}}

{{% tab name="Kubermatic InstanceTypes/Preferences" %}}
If you select some **Kubermatic** Instancetype/Preference, for example *standard-2*/*sockets-advantage*, the following `MachineDeployment` will be created

```yaml
kind: MachineDeployment
spec:
 // ...
  template:
    spec:
      providerSpec:
        value:
            // ....
            virtualMachine:
              instancetype:
                name: "standard-2"
                kind: "VirtualMachineInstancetype"
              preference:
                name: "socket-advantage"
                kind: "VirtualMachinePreference" 
```

which will create a `VirtualMachine` with this specification:

```yaml
piVersion: kubevirt.io/v1
kind: VirtualMachine
metadata:
  // ---
spec:
  // ...
  instancetype:
    kind: VirtualMachineInstancetype
    name: stadard-2
  preference:
    kind: VirtualMachinePreference
    name: socket-advantage
  template:
```

{{% /tab %}}
{{< /tabs >}}

#### Specification of the Kubermatic provided instancetype/preferences

{{% notice note %}}
The **Kubermatic** instancetypes/preferences are created in the dedicated `cluster-xyz` namespace in the KubeVirt infrastructure cluster. 
They are namespaced resources.
{{% /notice %}}

{{< tabs name="Kubermatic instancetypes" >}}

{{% tab name="standard-2 instancetype" %}}
```yaml
apiVersion: instancetype.kubevirt.io/v1alpha1
kind: VirtualMachineInstancetype
metadata:
  name: standard-2
spec:
  cpu:
    guest: 2
  memory:
    guest: 8Gi
```
{{% /tab %}}
{{% tab name="standard-4 instancetype" %}}
```yaml
apiVersion: instancetype.kubevirt.io/v1alpha1
kind: VirtualMachineInstancetype
metadata:
  name: standard-4
spec:
  cpu:
    guest: 4
  memory:
    guest: 16Gi
```
{{% /tab %}}
{{% tab name="standard-8 instancetype" %}}
```yaml
apiVersion: instancetype.kubevirt.io/v1alpha1
kind: VirtualMachineInstancetype
metadata:
  name: standard-8
spec:
  cpu:
    guest: 8
  memory:
    guest: 32Gi
```
{{% /tab %}}
{{% tab name="socket-advantage preference" %}}
```yaml
apiVersion: instancetype.kubevirt.io/v1alpha1
kind: VirtualMachinePreference
metadata:
  name: sockets-advantage
spec:
  cpu:
    preferredCPUTopology: preferSockets
```
{{% /tab %}}
{{< /tabs >}}

#### How to provide your own **Custom** instancetypes and preferences


Just create some `VirtualMachinClusterInstancetype` and/or some `VirtualMachineClusterPreference` (cluster-wide resources) in the KubeVirt infrastructure cluster and you are can use them to template your VMs.

---

### Virtual Machines Disks

#### Basic Disk Configuration

For the basic configuration, disk images are imported from a web server, via HTTP download,
by specifying a URL when creating a cluster, at the `Inital Nodes` step, in the `Primary Disk` section as shown in the screenshot below.

![Primary Disk](/img/kubermatic/main/architecture/supported-providers/kubevirt/primary-disk.png)

#### Custom Local Disk

Custom local disks are disks created during cluster initialization that can be referenced later when creating nodes.
Reference the custom local disk by name in the node's primary disk field.
**The disk will be cloned** instead of being downloaded from the HTTP source URL.

The feature relies on Data Volumes from the [Containerized Data Importer](https://github.com/kubevirt/containerized-data-importer/) project.
Custom local disk creates a Data Volume on KubeVirt cluster in the user cluster namespace.

**NOTE:** the source DataVolume (Custom Local Disk) must exist in the *cluster-xyz* namespace where the VM is created.
Cloning across namespaces is not allowed.

![DataVolume cloning](/img/kubermatic/main/architecture/supported-providers/kubevirt/DV-cloning.png)

The source DataVolume can be created *manually* (not from KKP) by the user in the *cluster-xyz* namespace,
or it can also be created using KKP when creating the cluster at the `Settings` step, with the `Advanced Disk configuration` panel.

![DataVolume creation](/img/kubermatic/main/architecture/supported-providers/kubevirt/Source-DV-creation.png)

In this panel, the user can add several Custom Local Disks (DataVolumes).
For each of them, the user must specify:
- the disk name (DataVolume name, must be compliant with [Kubernetes object names constraints](https://kubernetes.io/docs/concepts/overview/working-with-objects/names/))
- the Storage Class from a dropdown list
- the disk size
- the image disk URL for image download.

The same Custom Local Disk can be used as source of cloning for all the VMs (same MachineDeployment or not) in the same cluster.

#### Secondary Disks

Secondary disks are additional disks that can be attached to nodes (up to three disks).
The feature is under heavy development, and it is functionality might change over time.

Currently, blank Data Volumes are being created and attached to nodes, meaning it is up to the cluster admin to
format the disks that they are being usable.

**It is not recommended to use those disks in production environment yet.**

### Storage Class Initialization
KKP uses [Containerized Data Importer](https://github.com/kubevirt/containerized-data-importer) (CDI) to import images and
provision volumes to launch the VMs. CDI provides the ability to populate PVCs with VM images or other data upon creation.
The data can come from different sources: a URL, a container registry, another PVC (clone), or an upload from a client.
For more information about Containerized Data Importer project, please follow the documentation
[here](https://github.com/kubevirt/containerized-data-importer/blob/main/doc/basic_pv_pvc_dv.md).

**To initialize a storage class on a user cluster that exists on the KubeVirt infrastructure cluster.
add `kubevirt-initialization.k8c.io/initialize-sc: 'true'` annotation to the storage class of your choice.
This action has to take place before user cluster creation.**

---

## Monitoring
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

![Grafana Dashboard](/img/kubermatic/main/monitoring/kubevirt/grafana.png)

## Breaking Changes

Please be aware that between KKP 2.20 and KKP 2.21, a breaking change to the `MachineDeployment` API for KubeVirt has occurred. For more details, please [check out the 2.20 to 2.21 upgrade notes]({{< ref "../../../tutorials-howtos/upgrading/upgrade-from-2.20-to-2.21/#kubevirt-migration" >}}).

## Migration from KKP 2.21 to KKP 2.22

{{% notice note %}}
Note that the VMs (and their workload) created from `MachineDeployments` with KKP 2.21 are not affected by the migration from KKP 2.21 to KKP 2.22 **if no update is done in the `MachineDeployment`**. You can safely perform the *MachineDeployment* manual migration after KKP upgrade from 2.21 to 2.22. `MachineDeployments` (and associated VM/VMIs) do not require any action before the migration from KKP 2.21 to KKP 2.22.
{{% /notice %}}

{{% notice warning %}}
However, if you already have KKP 2.21 installed and a KubeVirt cluster created with it, please be aware that there are some spec change for MachineDeployments that will require some manual update before any update to the *MachineDeployment* (including scaling it), please follow the below migration guide.
{{% /notice %}}



### Features that need some manual migration of the `MachineDeployment`:

List of deprecated/updated features that require some manual update in the `MachineDeployment`:


| Topic                      | Deprecated /Upgraded                                          | In Favor of               | Mandatory/Optional migration |
|----------------------------|------------------------------------------------------|---------------------------|-------|
| Virtual Machine Scheduling | Deprecated: `Pod Affinity Preset` and `Pod Anti Affinity Preset` | `TopologySpreadConstraints` | **Optional**: only if your `MachineDeployment` did contain `podAffinityPreset` or `podAntiAffinityPreset` |
| Virtual Machines Templating | Deprecated: `Flavor`            | `Instancetype` and `Preference`           | **Optional**: only if your `MachineDeployment` did contain `flavor` |
| Upgrade of [KubeVirt CCM](https://github.com/kubevirt/cloud-provider-kubevirt) from v0.2.0 to v0.4.0 | Upgrade Kubevirt CCM version            | (needed for LoadBalancer services)        | **Mandatory**: all existing `MachineDeployment` must be updated |

{{% notice warning %}}
**Perform all the needed migration of your existing `MachineDeployment` following the below procedure according to each topic that needs migration.**
Updating the `MachineDeployment` will create a new `VirtualMachine`  - Perform all the needed changes at once.
{{% /notice %}}



{{< tabs name="Migration of existing `MachineDeployment" >}}
{{% tab name="Upgrade of KubeVirt CCM" %}}
With KKP 2.22 KubeVirt CCM is upgraded from v0.2.0 to v0.4.0. From v0.3.0 on it requires new labels on VMs to correctly route the traffic to services.

Newly created VMs will have these labels automatically but for existing VMs and VMIs there is manual action required on your KubeVirt cluster.

Just set:

**MachineDeployment.spec.template.spec.providerSpec.value.cloudProviderSpec.clusterName to your cluster ID.**

How to get **cluster-id** is explained before in this page.  

```yaml
apiVersion: "cluster.k8s.io/v1alpha1"
kind: MachineDeployment
metadata:
  name: my-kubevirt-machine
spec:
  // ....
  template:
    metadata:
      labels:
        name: foo
    spec:
      providerSpec:
          // ...
          cloudProvider: "kubevirt"
          cloudProviderSpec:
            clusterName: <cluster-id> ### ADD THIS FIELD
```

{{% /tab %}}
{{% tab name="Scheduling" %}}

If you had `MachineDeployment.spec.template.spec.providerSpec.value.cloudProviderSpec.affinity.podAffinityPreset` or `MachineDeployment.spec.template.spec.providerSpec.value.cloudProviderSpec.affinity.podAntiAffinityPreset` in your specification, replace it with `TopologySpreadConstraints`.

```yaml
apiVersion: "cluster.k8s.io/v1alpha1"
kind: MachineDeployment
//...
spec:
  //...
  template:
    metadata:
      labels:
        name: my-kubevirt-machine
    spec:
      providerSpec:
        value:
          cloudProvider: "kubevirt"
          cloudProviderSpec:
            virtualMachine:
              //....
            affinity:
              # Deprecated: Use topologySpreadConstraints instead.
              podAffinityPreset: "" # Allowed values: "", "soft", "hard"
              # Deprecated: Use topologySpreadConstraints instead.
              podAntiAffinityPreset: "" # Allowed values: "", "soft", "hard"
```
Refer to the **Virtual Machines Scheduling** section for details.

{{% /tab %}}
{{% tab name="Templating" %}}

If you had `MachineDeployment.spec.template.spec.providerSpec.value.cloudProviderSpec.virtualMachine.flavor`in your specification, replace it with `instancetype`/`preference`.

```yaml
apiVersion: "cluster.k8s.io/v1alpha1"
kind: MachineDeployment
//...
spec:
  //...
  template:
    metadata:
      labels:
        name: my-kubevirt-machine
    spec:
      providerSpec:
        value:
          cloudProvider: "kubevirt"
          cloudProviderSpec:
            virtualMachine:
              //....
              # Deprecated: Use instancetype/preference instead
              flavor:
                name: "<< VirtualMachineInstancePresets_NAME >>"
```
Refer to the **Virtual Machines Templates** section for details.

{{% /tab %}}
{{< /tabs >}}
