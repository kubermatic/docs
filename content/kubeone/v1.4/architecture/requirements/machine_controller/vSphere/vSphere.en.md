+++
title = "VSphere"
date = 2018-07-04T12:07:15+02:00
description = "Learn about the specific requirements of VMware vSphere used by the Kubermatic machine-controller"
weight = 7

+++

## vSphere


{{% notice note %}}
Permissions listed here are permission required by the Kubermatic machine-controller. Terraform, and components deployed by KubeOne (such as external cloud-controller-manager) might require additional permissions.
{{% /notice %}}


### VM Images

When creating worker nodes for a user cluster, the user can specify an existing image.

Supported operating systems

* CentOS beginning with 7.4 [qcow2](https://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.qcow2)
* CentOS 8 [qcow2](https://cloud.centos.org/centos/8/x86_64/images/CentOS-8-GenericCloud-8.4.2105-20210603.0.x86_64.qcow2)
* Ubuntu 18.04 [ova](https://cloud-images.ubuntu.com/releases/18.04/release/ubuntu-18.04-server-cloudimg-amd64.ova)
* Ubuntu 20.04 [ova](https://cloud-images.ubuntu.com/releases/focal/release/ubuntu-20.04-server-cloudimg-amd64.ova)
* Flatcar (Stable channel) [ova](https://stable.release.flatcar-linux.net/amd64-usr/current/flatcar_production_vmware_ova.ova)

#### Importing the OVA

1. Go into the VSphere WebUI, select your datacenter, right click onto it and choose "Deploy OVF Template"
1. Fill in the "URL" field with the appropriate url
1. Click through the dialog until "Select storage"
1. Select the same storage you want to use for your machines
1. Select the same network you want to use for your machines
1. Leave everything in the "Customize Template" and "Ready to complete" dialog as it is
1. Wait until the VM got fully imported and the "Snapshots" => "Create Snapshot" button is not grayed out anymore

#### Importing the QCOW2

1. Convert it to vmdk: `qemu-img convert -f qcow2 -O vmdk CentOS-7-x86_64-GenericCloud.qcow2 CentOS-7-x86_64-GenericCloud.vmdk`
1. Upload it to a Datastore of your vSphere installation
1. Create a new virtual machine that uses the uploaded vmdk as rootdisk

#### Modifications

Modifications like Network, disk size, etc. must be done in the ova template before creating a worker node from it.

### VM Folder

During creation of a machine deployment, the machine controller creates a dedicated VM folder in the root path on the Datastore.
That folder will contain all worker nodes of the machine deployment.

### Permissions

The vsphere user has to have to following permissions on the correct resources:

* Role `k8c-user-vcenter`
  * Granted at **vcenter** level, **not** propagated
  * Needed to customize VM during provisioning
  * Permissions
    * Profile-driven storage
      * Profile-driven storage view
    * VirtualMachine
      * Provisioning
        * Modify customization specification
        * Read customization specifications

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

* Role `k8c-user-cluster-propagate`
  * Granted at **cluster** level, propagated
  * Needed for upload of `cloud-init.iso` (Ubuntu and CentOS) or defining the Ignition config into Guestinfo (CoreOS)
  * Permissions
    * Host
      * Configuration
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

* Role k8s-network-attach
  * Granted for each network that should be used (distributed switch + network)
  * Permissions
    * Network
      * Assign network

* Role `k8c-user-datastore-propagate`
  * Granted at **datastore / datastore cluster** level, propagated
  * Permissions
    * Datastore
      * Allocate space
      * Browse datastore
      * Low level file operations

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

The described permissions have been tested with vSphere 6.7 and might be different for other vSphere versions.

#### Terraform Setup

It's also possible to create the roles by a terraform script. The following repo can be used as reference:
* https://github.com/kubermatic-labs/kubermatic-vsphere-permissions-terraform
