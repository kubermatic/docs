+++
title = "VSphere"
date = 2018-07-04T12:07:15+02:00
weight = 7
pre = "<b></b>"
+++

## VSphere

### VM Images

When creating worker nodes for a user cluster, the user can specify an existing image. Defaults may be set in the [datacenters.yaml](https://docs.kubermatic.io/installation/install_kubermatic/#defining-the-datacenters).

Supported operating systems

* Ubuntu 16.04 [ova](https://cloud-images.ubuntu.com/releases/16.04/release/ubuntu-16.04-server-cloudimg-amd64.ova)
* CoreOS  [ova](https://stable.release.core-os.net/amd64-usr/current/coreos_production_vmware_ova.ova)

#### Importing the OVA:

1. Go into the VSphere WebUI, select your datacenter, right click onto it and choose "Deploy OVF Template"
1. Fill in the "URL" field with the appropriate url 
1. Click through the dialog until "Select storage"
1. Select the same storage you want to use for your machines
1. Select the same network you want to use for your machines
1. Leave everyhting in the "Customize Template" and "Ready to complete" dialog as it is
1. Wait until the VM got fully imported and the "Snapshots" => "Create Snapshot" button is not grayed out anymore
1. The template VM must have the disk.enableUUID flag set to 1, this can be done using the [govc tool](https://github.com/vmware/govmomi/tree/master/govc) with the following command:
```
$ govc vm.change -e="disk.enableUUID=1" -vm='/datacenter/vm/path/to/the/virtualmachine'
```

#### Modifications

Modifications like Network, disk size, etc. must be done in the ova template before creating a worker node from it.
If user clusters have dedicated networks, all user clusters therefore need a custom template. 

### VM Folder

During creation of a user cluster Kubermatic creates a dedicated VM folder in the root path on the Datastore (Defined in the [datacenters.yaml](https://docs.kubermatic.io/installation/install_kubermatic/#defining-the-datacenters)). 
That folder will contain all worker nodes of a user cluster.

### Credentials / Cloud-Config

Kubernetes needs to talk to the vSphere to enable Storage inside the cluster.
For this, kubernetes needs a config called `cloud-config`. 
This config contains all details to connect to a vCenter installation, including credentials.

As this Config must also be deployed onto each worker node of a user cluster, its recommended to have individual credentials for each user cluster. 

### Permissions

The vsphere user has to have to following permissions on the correct resources:

#### Seed Cluster

* Role `k8c-storage-vmfolder-propagate`
  * Granted at __VM Folder__, propagated
  * Permissions
    * VirtualMachine
      * Config
        * AddExistingDisk
        * AddNewDisk
        * AddRemoveDevice
        * RemoveDisk

* Role `k8c-storage-datastore-propagate`
  * Granted at __Datastore__, propagated
  * Permissions
    * Datastore
      * AllocateSpace
      * FileManagement (Low level file operations)

* Role `Read-only` (predefined)
  * Granted at ..., **not** propagated
    * Datacenter

#### User Cluster

* Role `k8c-user-datacenter`
  * Granted at __datacenter__ level, **not** propagated
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

* Role `k8c-user-cluster-propagate`
  * Granted at __cluster__ level, propagated
  * Needed for upload of `cloud-init.iso`
  * Permissions
    * Host
      * Configuration
        * System Management
    * Resource
      * Assign virtual machine to resource pool

* Role `k8c-user-datastore-propagate`
  * Granted at __datastore / datastore cluster__ level, propagated
  * Permissions
    * Datastore
      * Allocate space
      * Browse datastore

* Role `k8c-user-folder-propagate`
  * Granted at __folder__ level, propagated
  * Needed for managing the node VMs
  * Permissions
    * Folder
      * Create folder
      * Delete folder
    * Virtual machine
      * Configuration
        * Add or remove device
      * Interaction
        * Power Off
        * Power On
      * Inventory
        * Remove
      * Provisioning
        * Clone virtual machine
      * Snapshot management
        * Create snapshot
