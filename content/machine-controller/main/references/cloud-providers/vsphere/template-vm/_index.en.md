+++
title = "Creating vSphere Template VMs"
linkTitle = "vSphere Template VMs"
date = 2022-10-31T12:00:00+02:00
+++

This guide describes how to create templates VMs for vSphere to be used with
Terraform, machine-controller, and KubeOne and KKP. This is an umbrella
document — we have a basic guides that should server useful for every operating
system, plus guides that go into more detail for specific OS.

- [Generic OVA images]({{< ref "./ova/" >}})
- [Generic qcow2 images]({{< ref "./qcow2/" >}})
- [RockyLinux]({{< ref "./rockylinux/" >}})
- [Ubuntu]({{< ref "./ubuntu/" >}})

Guides for other operating systems will be added in the future.

## Best Practice: Add Multiple PV-SCSI Controllers

To improve disk performance and optimize CSI volume placement, configure your template VM with multiple **Paravirtual SCSI controllers** before converting it to a template.

### Recommended Configuration

- Add **3 additional PV-SCSI controllers** (total: 4).
- Set all controllers to **Paravirtual** mode.
- Boot disk should remain on the first controller; additional CSI volumes will automatically use the others.

This configuration helps distribute I/O load across multiple controllers, which is especially beneficial for workloads with high disk activity.

### References

- GitHub Issue: [Is it safe to use VMs configured with multiple SCSI controllers?](https://github.com/kubernetes-sigs/vsphere-csi-driver/issues/633)
- VMware KB: [VMware recommends implementing multiple SCSI controllers](https://knowledge.broadcom.com/external/article/392848/vms-with-multiple-vmdks-report-high-disk.html#:~:text=VMware%20recommends%20implementing%20multiple%20SCSI%20controllers)

{{% notice warning %}}
The **template VM** in this guide refers to a regular vSphere VM and not VM
Templates according to the vSphere terminology. The difference is quite subtle,
but VM Templates are not supported yet by machine-controller.
{{% /notice %}}
