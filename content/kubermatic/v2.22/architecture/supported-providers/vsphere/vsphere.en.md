+++
title = "vSphere"
date = 2018-07-04T12:07:15+02:00
weight = 7

+++

{{% notice warning %}}
The Kubernetes vSphere driver contains bugs related to detaching volumes from offline nodes. See the [**Volume detach bug**](#volume-detach-bug) section for more details.
{{% /notice %}}

## VM Images

When creating worker nodes for a user cluster, the user can specify an existing image. Defaults may be set in the [seed cluster `spec.datacenters.EXAMPLEDC.vsphere.endpoint`]({{< ref "../../../tutorials-howtos/project-and-cluster-management/seed-cluster" >}}).

Supported operating systems

* CentOS beginning with 7.4 excluding stream versions [qcow2](https://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.qcow2)
* CentOS 8 [qcow2](https://cloud.centos.org/centos/8/x86_64/images/CentOS-8-GenericCloud-8.4.2105-20210603.0.x86_64.qcow2)
* Ubuntu 18.04 [ova](https://cloud-images.ubuntu.com/releases/18.04/release/ubuntu-18.04-server-cloudimg-amd64.ova)
* Ubuntu 20.04 [ova](https://cloud-images.ubuntu.com/releases/focal/release/ubuntu-20.04-server-cloudimg-amd64.ova)
* Flatcar (Stable channel) [ova](https://stable.release.flatcar-linux.net/amd64-usr/current/flatcar_production_vmware_ova.ova)


### Importing the OVA

1. Go into the VSphere WebUI, select your datacenter, right click onto it and choose "Deploy OVF Template"
1. Fill in the "URL" field with the appropriate url
1. Click through the dialog until "Select storage"
1. Select the same storage you want to use for your machines
1. Select the same network you want to use for your machines
1. Leave everything in the "Customize Template" and "Ready to complete" dialog as it is
1. Wait until the VM got fully imported and the "Snapshots" => "Create Snapshot" button is not grayed out anymore

### Importing the QCOW2

1. Convert it to vmdk: `qemu-img convert -f qcow2 -O vmdk CentOS-7-x86_64-GenericCloud.qcow2 CentOS-7-x86_64-GenericCloud.vmdk`
1. Upload it to a Datastore of your vSphere installation
1. Create a new virtual machine that uses the uploaded vmdk as rootdisk

### Modifications

Modifications like Network, disk size, etc. must be done in the ova template before creating a worker node from it.
If user clusters have dedicated networks, all user clusters therefore need a custom template.

## VM Folder

During creation of a user cluster Kubermatic Kubernetes Platform (KKP) creates a dedicated VM folder in the root path on the Datastore (Defined in the [seed cluster `spec.datacenters.EXAMPLEDC.vsphere.datastore`]({{< ref "../../../tutorials-howtos/project-and-cluster-management/seed-cluster" >}})).
That folder will contain all worker nodes of a user cluster.

## Credentials / Cloud-Config

Kubernetes needs to talk to the vSphere to enable Storage inside the cluster.
For this, kubernetes needs a config called `cloud-config`.
This config contains all details to connect to a vCenter installation, including credentials.

As this Config must also be deployed onto each worker node of a user cluster, its recommended to have individual credentials for each user cluster.

## Permissions

The vsphere user has to have to following permissions on the correct resources:

### User Cluster Could Controller Manager / CSI
**Note:** Below roles were updated based on [vsphere-storage-plugin-roles] for external CCM which is available from kkp v2.18+ and vsphere v7.0.2+

For provisioning actions of the KKP seed cluster, a technical user (e.g. `cust-ccm-cluster`) is needed:

* Role `k8c-ccm-storage-vmfolder-propagate`
  * Granted at **VM Folder** and **Template Folder**, propagated
  * Permissions
    * Virtual machine
      * Change Configuration
        * Add existing disk
        * Add new disk
        * Add or remove device
        * Remove disk
    * Folder
      * Create folder
      * Delete dolder

```
$ govc role.ls k8c-ccm-storage-vmfolder-propagate
Folder.Create
Folder.Delete
VirtualMachine.Config.AddExistingDisk
VirtualMachine.Config.AddNewDisk
VirtualMachine.Config.AddRemoveDevice
VirtualMachine.Config.RemoveDisk
```

* Role `k8c-ccm-storage-datastore-propagate`
  * Granted at **Datastore**, propagated
  * Permissions
    * Datastore
      * Allocate space
      * Low level file operations

```
$ govc role.ls k8c-ccm-storage-datastore-propagate
Datastore.AllocateSpace
Datastore.FileManagement
```

* Role `Read-only` (predefined)
  * Granted at ..., **not** propagated
    * Datacenter

```
$ govc role.ls ReadOnly
System.Anonymous
System.Read
System.View
```
### User Cluster

For provisioning actions of the KKP in scope of an user cluster, a technical user (e.g. `cust-user-cluster`) is needed:

* Role `k8c-user-vcenter`
  * Granted at **vcenter** level, **not** propagated
  * Needed to customize VM during provisioning
  * Permissions
    * CNS
      * Searchable
    * Profile-driven storage
      * Profile-driven storage view
    * VirtualMachine
      * Provisioning
        * Modify customization specification
        * Read customization specifications

```
$ govc role.ls k8c-user-vcenter
Cns.Searchable
InventoryService.Tagging.ObjectAttachable
StorageProfile.View
System.Anonymous
System.Read
System.View
VirtualMachine.Provisioning.ModifyCustSpecs
VirtualMachine.Provisioning.ReadCustSpecs
```

* Role `k8c-user-datacenter`
  * Granted at **datacenter** level, **not** propagated
  * Needed for cloning the template VM (obviously this is not done in a folder at this time)
  * Permissions
    * Datastore
      * Allocate space
      * Browse datastore
      * Low level file operations
      * Remove file
    * vApp
      * vApp application configuration
      * vApp instance configuration
    * Virtual Machine
      * Change CPU count
      * Memory
      * Settings
    * Inventory
      * Create from existing

```
$ govc role.ls k8c-user-datacenter
Datastore.AllocateSpace
Datastore.Browse
Datastore.DeleteFile
Datastore.FileManagement
InventoryService.Tagging.ObjectAttachable
System.Anonymous
System.Read
System.View
VApp.ApplicationConfig
VApp.InstanceConfig
VirtualMachine.Config.CPUCount
VirtualMachine.Config.Memory
VirtualMachine.Config.Settings
VirtualMachine.Inventory.CreateFromExisting
```

* Role `k8c-user-cluster-propagate`
  * Granted at **cluster** level, propagated
  * Needed for upload of `cloud-init.iso` (Ubuntu and CentOS) or defining the Ignition config into Guestinfo (CoreOS)
  * Permissions
    * Host
      * Configuration
        * Storage partition configuration
        * System Management
      * Local operations
        * Reconfigure virtual machine
    * Resource
      * Assign virtual machine to resource pool
      * Migrate powered off virtual machine
      * Migrate powered on virtual machine
    * vApp
      * vApp application configuration
      * vApp instance configuration

```
$ govc role.ls k8c-user-cluster-propagate
Folder.Create
Host.Config.Storage
Host.Config.SystemManagement
Host.Local.ReconfigVM
Resource.AssignVMToPool
Resource.ColdMigrate
Resource.HotMigrate
VApp.ApplicationConfig
VApp.InstanceConfig
```

* Role k8c-network-attach
  * Granted for each network that should be used (distributed switch + network)
  * Permissions
    * Network
      * Assign network

```
$ govc role.ls k8c-network-attach
Network.Assign
```

* Role `k8c-user-datastore-propagate`
  * Granted at **datastore / datastore cluster** level, propagated
  * Permissions
    * Datastore
      * Allocate space
      * Browse datastore
      * Low level file operations

```
$ govc role.ls k8c-user-datastore-propagate
Datastore.AllocateSpace
Datastore.Browse
Datastore.FileManagement
```

* Role `k8c-user-folder-propagate`
  * Granted at **VM Folder** and **Template Folder** level, propagated
  * Needed for managing the node VMs
  * Permissions
    * Folder
      * Create folder
      * Delete folder
    * Global
      * Set custom attribute
    * Virtual machine
      * Change Configuration
      * Edit Inventory
      * Guest operations
      * Interaction
      * Provisioning
      * Snapshot management

```
$ govc role.ls k8c-user-folder-propagate
Folder.Create
Folder.Delete
Global.SetCustomField
InventoryService.Tagging.ObjectAttachable
System.Anonymous
System.Read
System.View
VirtualMachine.Config.AddExistingDisk
VirtualMachine.Config.AddNewDisk
VirtualMachine.Config.AddRemoveDevice
VirtualMachine.Config.AdvancedConfig
VirtualMachine.Config.Annotation
VirtualMachine.Config.CPUCount
VirtualMachine.Config.ChangeTracking
VirtualMachine.Config.DiskExtend
VirtualMachine.Config.DiskLease
VirtualMachine.Config.EditDevice
VirtualMachine.Config.HostUSBDevice
VirtualMachine.Config.ManagedBy
VirtualMachine.Config.Memory
VirtualMachine.Config.MksControl
VirtualMachine.Config.QueryFTCompatibility
VirtualMachine.Config.QueryUnownedFiles
VirtualMachine.Config.RawDevice
VirtualMachine.Config.ReloadFromPath
VirtualMachine.Config.RemoveDisk
VirtualMachine.Config.Rename
VirtualMachine.Config.ResetGuestInfo
VirtualMachine.Config.Resource
VirtualMachine.Config.Settings
VirtualMachine.Config.SwapPlacement
VirtualMachine.Config.ToggleForkParent
VirtualMachine.Config.Unlock
VirtualMachine.Config.UpgradeVirtualHardware
VirtualMachine.GuestOperations.Execute
VirtualMachine.GuestOperations.Modify
VirtualMachine.GuestOperations.ModifyAliases
VirtualMachine.GuestOperations.Query
VirtualMachine.GuestOperations.QueryAliases
VirtualMachine.Interact.AnswerQuestion
VirtualMachine.Interact.Backup
VirtualMachine.Interact.ConsoleInteract
VirtualMachine.Interact.CreateScreenshot
VirtualMachine.Interact.CreateSecondary
VirtualMachine.Interact.DefragmentAllDisks
VirtualMachine.Interact.DeviceConnection
VirtualMachine.Interact.DisableSecondary
VirtualMachine.Interact.DnD
VirtualMachine.Interact.EnableSecondary
VirtualMachine.Interact.GuestControl
VirtualMachine.Interact.MakePrimary
VirtualMachine.Interact.Pause
VirtualMachine.Interact.PowerOff
VirtualMachine.Interact.PowerOn
VirtualMachine.Interact.PutUsbScanCodes
VirtualMachine.Interact.Record
VirtualMachine.Interact.Replay
VirtualMachine.Interact.Reset
VirtualMachine.Interact.SESparseMaintenance
VirtualMachine.Interact.SetCDMedia
VirtualMachine.Interact.SetFloppyMedia
VirtualMachine.Interact.Suspend
VirtualMachine.Interact.TerminateFaultTolerantVM
VirtualMachine.Interact.ToolsInstall
VirtualMachine.Interact.TurnOffFaultTolerance
VirtualMachine.Inventory.Create
VirtualMachine.Inventory.CreateFromExisting
VirtualMachine.Inventory.Delete
VirtualMachine.Inventory.Move
VirtualMachine.Inventory.Register
VirtualMachine.Inventory.Unregister
VirtualMachine.Provisioning.Clone
VirtualMachine.Provisioning.CloneTemplate
VirtualMachine.Provisioning.CreateTemplateFromVM
VirtualMachine.Provisioning.Customize
VirtualMachine.Provisioning.DeployTemplate
VirtualMachine.Provisioning.DiskRandomAccess
VirtualMachine.Provisioning.DiskRandomRead
VirtualMachine.Provisioning.FileRandomAccess
VirtualMachine.Provisioning.GetVmFiles
VirtualMachine.Provisioning.MarkAsTemplate
VirtualMachine.Provisioning.MarkAsVM
VirtualMachine.Provisioning.ModifyCustSpecs
VirtualMachine.Provisioning.PromoteDisks
VirtualMachine.Provisioning.PutVmFiles
VirtualMachine.Provisioning.ReadCustSpecs
VirtualMachine.State.CreateSnapshot
VirtualMachine.State.RemoveSnapshot
VirtualMachine.State.RenameSnapshot
VirtualMachine.State.RevertToSnapshot

```

* Role `k8c-user-tags`
  * Granted at datacenter level, propagated
  * Provides permission to create vSphere tags for a dedicated category, which are required by KKP seed controller manager
  * Permissions
    * vSphere Tagging
      * Create vSphere Tag
      * Delete vSphere Tag
      * Assign or Unassign vSphere Tag on an Object

```
$ govc role.ls k8c-user-tags
InventoryService.Tagging.CreateTag
InventoryService.Tagging.DeleteTag
InventoryService.Tagging.AttachTag
InventoryService.Tagging.ObjectAttachable
System.Anonymous
System.Read
System.View
```

{{% notice warning %}} Note: If a category id is assigned to a user cluster, KKP would claim the ownership of any tags
it creates. KKP would try to delete tags assigned to the cluster upon cluster deletion. Thus, make sure that the assigned
category isn't shared across other lingering resources. {{% /notice %}}

{{% notice warning %}} Note: Tags can be attached to machine deployments regardless if the tags are created via KKP or not.
If a tag was not attached to the user cluster, machine controller will only detach it.{{% /notice %}}

The described permissions have been tested with vSphere 7.0.U2 and might be different for other vSphere versions.

### Terraform Setup

It's also possible to create the roles by a terraform script. The following repo can be used as reference:
* https://github.com/kubermatic-labs/kubermatic-vsphere-permissions-terraform

## Datastores and Datastore Clusters

*Datastores* in vSphere are an abstraction for storage.
A *Datastore Cluster* is a collection of datastores with shared resources and a
shared management interface.

In KKP *Datastores* are used for two purposes:

* Storing the VMs files for the worker nodes of vSphere user clusters.
* Generating the vSphere cloud provider storage configuration for user clusters.
  In particular to provide the `default-datastore` value, that is the default
  datastore for dynamic volume provisioning.

*Datastore Clusters* can only be used for the first purpose as it cannot be
specified directly in [vSphere cloud configuration][vsphere-cloud-config].

There are three places where Datastores and Datastore Clusters can be configured
in KKP:

* At datacenter level (configured in the [Seed CRD]({{< ref "../../../tutorials-howtos/project-and-cluster-management/seed-cluster" >}})))
  it is possible to
  specify the default *Datastore* that will be used for user clusters dynamic
  volume provisioning and workers VMs placement in case no *Datastore* or
  *Datastore Cluster* is specified at cluster level.
* At *Cluster* level it is possible to provide either a *Datastore* or a
  *Datastore Cluster* respectively with `spec.cloud.vsphere.datastore` and
  `spec.cloud.vsphere.datastoreCluster` fields.
* It is possible to specify *Datastore* or *Datastore Clusters* in a preset
  than is later used to create a user cluster from it.

These settings can also be configured as part of the "Advanced Settings" step
when creating a user cluster from the [KKP dashboard]({{< ref "../../../tutorials-howtos/project-and-cluster-management/#create-cluster" >}}).

[vsphere-cloud-config]: https://docs.vmware.com/en/VMware-vSphere-Container-Storage-Plug-in/2.0/vmware-vsphere-csp-getting-started/GUID-BFF39F1D-F70A-4360-ABC9-85BDAFBE8864.html?hWord=N4IghgNiBcIMYQK4GcAuBTATgWgJYBMACAYQGUBJEAXyA
[vsphere-storage-plugin-roles]: https://docs.vmware.com/en/VMware-vSphere-Container-Storage-Plug-in/2.0/vmware-vsphere-csp-getting-started/GUID-0AB6E692-AA47-4B6A-8CEA-38B754E16567.html#GUID-043ACF65-9E0B-475C-A507-BBBE2579AA58__GUID-E51466CB-F1EA-4AD7-A541-F22CDC6DE881


## Known Issues

### Volume Detach Bug

After a node is powered-off, the Kubernetes vSphere driver doesn't detach disks associated with PVCs mounted on that node. This makes it impossible to reschedule pods using these PVCs until the disks are manually detached in vCenter.

Upstream Kubernetes has been working on the issue for a long time now and tracking it under the following tickets:

* <https://github.com/kubernetes/kubernetes/issues/63577>
* <https://github.com/kubernetes/kubernetes/issues/61707>
* <https://github.com/kubernetes/kubernetes/issues/67900>
* <https://github.com/kubernetes/kubernetes/issues/71829>
* <https://github.com/kubernetes/kubernetes/issues/75342>

## Internal Kubernetes endpoints unreachable

### Symptoms

* Unable to perform CRUD operations on resources governed by webhooks (e.g. ValidatingWebhookConfiguration, MutatingWebhookConfiguration, etc.). The following error is observed:

```sh
Internal error occurred: failed calling webhook "webhook-name": failed to call webhook: Post "https://webhook-service-name.namespace.svc:443/webhook-endpoint": context deadline exceeded
```

* Unable to reach internal Kubernetes endpoints from pods/nodes.
* ICMP is working but TCP/UDP is not.

### Cause

On recent enough VMware hardware compatibility version (i.e >=15 or maybe >=14), CNI connectivity breaks because of hardware segmentation offload. `cilium-health status` has ICMP connectivity working, but not TCP connectivity. cilium-health status may also fail completely.

### Solution

```sh
sudo ethtool -K ens192 tx-udp_tnl-segmentation off
sudo ethtool -K ens192 tx-udp_tnl-csum-segmentation off
```

These flags are related to the hardware segmentation offload done by the vSphere driver VMXNET3. We have observed this issue for both Cilium and Canal CNI running on Ubuntu 22.04.

We have two options to configure these flags for KKP installations:

* When configuring the VM template, set these flags as well.
* Create a [custom Operating System Profile]({{< ref "../../../tutorials-howtos/operating-system-manager/usage#custom-operatingsystemprofiles" >}}) and configure the flags there.

### References

* <https://github.com/cilium/cilium/issues/13096>
* <https://github.com/cilium/cilium/issues/21801>