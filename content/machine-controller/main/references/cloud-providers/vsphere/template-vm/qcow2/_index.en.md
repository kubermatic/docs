+++
title = "Creating a Template VM from a qcow2 image"
linkTitle = "Generic qcow2"
date = 2022-10-31T12:00:00+02:00
+++

This document outlines the general procedure for adding new Template VMs in vSphere
for `.qcow2` images.

{{% notice warning %}}
The **template VM** in this guide refers to a regular vSphere VM and not VM
Templates according to the vSphere terminology. The difference is quite subtle,
but VM Templates are not supported yet by machine-controller.
{{% /notice %}}

## Prerequisites

* vSphere (tested on version 6.7)
* govc (tested on version 0.37.2)
* qemu-img (tested on version 4.2.0)
* curl or wget

## Procedure

1. Download the guest image in qcow2 format end export an environment variable
   with the name of the file.

    ```bash
    # The URL below is just an example
    image_url="https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64-disk-kvm.img"
    image_name="$(basename -- "${image_url}" | sed 's/.img$//g')"
    curl -sL "${image_url}" -O .
    ```

2. Convert it to vmdk e.g.

    ```bash
    qemu-img convert -O vmdk -o subformat=streamOptimized "./${image_name}.qcow2" "${image_name}.vmdk"
    ```

3. Upload to vSphere using WebUI or GOVC:

    Make sure to replace the parameters on the command below with the correct values specific to
    your vSphere environment.

    ```bash
    govc import.vmdk -dc=dc-1 -pool=/dc-1/host/cl-1/Resources -ds=ds-1 "./${image_name}.vmdk"
    ```

4. Inflate the created disk (see [VMware documentation][inflate_thin_virtual_disks] for more details)

    ```bash
    govc datastore.disk.inflate -dc dc-1 -ds ds-1 "${image_name}/${image_name}.vmdk"
    ```

5. Create a new virtual machine using that image with vSphere WebUI.
6. During the `Customize Hardware` step:
    1. Remove the disk present by default
    2. Click on `ADD NEW DEVICE`, select `Existing Hard Disk` and select the disk previously created.
7. The vm is ready to be used by the `MachineController` by referencing its name in the field `.spec.template.spec.providerSpec.value.cloudProviderSpec.templateVMName` of the `MachineDeployment`.
