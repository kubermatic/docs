+++
title = "RedHat Enterprise Linux"
date = 2024-05-31T07:00:00+02:00
+++

Cloud providers which are listed below, support using RHEL as an operating system option:

- AWS
- Azure
- GCE
- KubeVirt
- OpenStack
- vSphere

## AWS

First of all the RHEL gold image AMIs have to be enabled from the
[RedHat Customer Portal](https://access.redhat.com/public-cloud/aws) (this requires a
[cloud-provider subscription](https://access.redhat.com/public-cloud)).

Afterwards, new images will be added to the aws account under EC2-> Images-> AMIs-> Private Images.
Once the images are available in the aws account, the image id for RHEL (supported versions are
mentioned [here]({{< relref "../../operating-systems#supported-os-versions" >}})) should be then added to the
`MachineDeployment` spec to the field `ami`.

## Azure

RedHat provides images for Azure, [documentation](https://access.redhat.com/articles/uploading-rhel-image-to-azure)
is available on RH customer portal.

The `MachineDeployment` field `.spec.template.spec.providerSpec.value.cloudProviderSpec.imageID`
should reference the ID of the uploaded VM.

{{% notice info %}}
Azure RHEL images starting from 7.6.x don't support cloud-init as their documentation states
[here](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/using-cloud-init#rhel). Thus,
custom images can be used with a cloud-init pre-installed to solve this issue. Follow this
[documentation](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/cloudinit-prepare-custom-image)
to prepare an image with cloud-init support.
{{% /notice %}}

## GCE

RedHat also provides Gold Access Image for GCE and those can be fetched just like aws and azure. The `MachineDeployment` field `.spec.template.spec.providerSpec.value.cloudProviderSpec.customImage` should reference the ID of the used image.

{{% notice info %}}
RHEL images in GCE don't support cloud-init. Thus, custom images can be used with a cloud-init
pre-installed to solve this issue. Follow this [documentation][1] to upload custom RHEL images.

[1]: https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/deploying_red_hat_enterprise_linux_8_on_public_cloud_platforms/assembly_deploying-a-rhel-image-as-a-compute-engine-instance-on-google-cloud-platform_deploying-a-virtual-machine-on-aws
{{% /notice %}}

## KubeVirt

In order to create machines which run RHEL as an operating system in KubeVirt cloud provider, the
image should be available and fetched via an endpoint. This endpoint should be then added to the
`MachineDeployment` field `.spec.template.spec.providerSpec.value.cloudProviderSpec.sourceURL`. For
more information about the supported images please refer to the [documentation from KubeVirt CDI](https://kubevirt.io/2018/containerized-data-importer.html).

## OpenStack

Once RHEL images (e.g: Red Hat Enterprise Linux 8.x KVM Guest Image) are uploaded to OpenStack, the
image name should be used in the `MachineDeployment` field
`.spec.template.spec.providerSpec.value.cloudProviderSpec.image`.

## vSphere

Find out [here]({{< relref "../../cloud-providers/vsphere" >}}) how to deploy a template VM in vSphere.
