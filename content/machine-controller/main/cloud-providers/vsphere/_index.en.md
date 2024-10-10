+++
title = "VMware vSphere"
date = 2024-05-31T07:00:00+02:00
+++

## Supported versions

* 6.5
* 6.7
* 7.0

## Provider configuration

The vSphere provider accepts the following configuration parameters:

```yaml
# Can also be set via the env var 'VSPHERE_USERNAME' on the machine-controller
username: "<< VSPHERE_USERNAME >>"
# Can also be set via the env var 'VSPHERE_ADDRESS' on the machine-controller
# example: 'https://your-vcenter:8443'. '/sdk' gets appended automatically
vsphereURL: "<< VSPHERE_ADDRESS >>"
# Can also be set via the env var 'VSPHERE_PASSWORD' on the machine-controller
password: "<< VSPHERE_PASSWORD >>"
# datacenter name
datacenter: datacenter1
# VM template name
templateVMName: ubuntu-template
# Optional. Sets the networks on the VM. If no network is specified, the template default will be used.
networks:
  - network1
# Optional
folder: folder1
# Optional: Force VMs to be provisioned to the specified resourcePool
# Default is to use the resourcePool of the template VM
# example: kubeone or /DC/host/Cluster01/Resources/kubeone
resourcePool: kubeone
cluster: cluster1
# either datastore or datastoreCluster have to be provided.
datastore: datastore1
datastoreCluster: datastore-cluster1
# Can also be set via the env var 'VSPHERE_ALLOW_INSECURE' on the machine-controller
allowInsecure: true
# instance resources
cpus: 2
memoryMB: 2048
# Optional: Resize the root disk to this size. Must be bigger than the existing size
# Default is to leave the disk at the same size as the template
diskSizeGB: 10
```

### Datastore and DatastoreCluster

A `Datastore` is the basic unit of storage abstraction in vSphere storage (more details [here][datastore]).

A `DatastoreCluster` (sometimes referred to as StoragePod) is a logical grouping of `Datastores`,
it provides some resource management capabilities (more details [here][datastore_cluster]).

vSphere provider configuration in a `MachineDeployment` should specify either a `Datastore` or a
`DatastoreCluster`. If both are specified or if one of the two is missing the `MachineDeployment`
validation will fail.

{{% notice warning %}}
Note that the `datastore` or `datastoreCluster` specified in the `MachineDeployment` will be only
used for the placement of VM and disk files related to the VMs provisioned by the machine-controller.
They do not influence the placement of persistent volumes used by Pods, that only depends on the
cloud configuration given to the Kubernetes cloud provider running in control plane.
{{% /notice %}}

## Template VMs preparation

To use the machine-controller to create machines on VMware vSphere, you must first create a VM to be
used as a template.

{{% notice info %}}
`template VMs` in this document refers to regular VMs and not VM Templates according
to vSphere terminology. The difference is quite subtle, but VM Templates are not supported yet by
machine-controller.
{{% /notice %}}

Information about supported OS versions can be found [here]({{< relref "../../operating-systems#supported-os-versions" >}}).

### Ubuntu

Ubuntu OVA templates can be foud at <https://cloud-images.ubuntu.com/releases/22.04/release/ubuntu-22.04-server-cloudimg-amd64.ova>.

Follow the dedicated [Ubuntu Template VM guide]({{< relref "./template-vm/ubuntu" >}}).

### RHEL

Red Hat Enterprise Linux 8.x KVM Guest Images can be found at [Red Hat Customer Portal][rh_portal_rhel8].

Follow the generic [qcow2 guide]({{< relref "./template-vm/qcow2" >}}).

### RockyLinux

RockyLinux images can be found at the following link: <https://rockylinux.org/download>.

Follow the dedicated [RockyLinux Template VM guide]({{< relref "./template-vm/rockylinux" >}}).

[datastore]: https://docs.vmware.com/en/VMware-vSphere/6.7/com.vmware.vsphere.storage.doc/GUID-3CC7078E-9C30-402C-B2E1-2542BEE67E8F.html
[datastore_cluster]: https://docs.vmware.com/en/VMware-vSphere/6.7/com.vmware.vsphere.resmgmt.doc/GUID-598DF695-107E-406B-9C95-0AF961FC227A.html
[inflate_thin_virtual_disks]: https://docs.vmware.com/en/VMware-vSphere/6.7/com.vmware.vsphere.storage.doc/GUID-C371B88F-C407-4A69-8F3B-FA877D6955F8.html
[rh_portal_rhel8]: https://access.redhat.com/downloads/content/479/ver=/rhel---8/8.1/x86_64/product-software
