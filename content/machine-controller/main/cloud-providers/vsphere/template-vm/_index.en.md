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

{{% notice warning %}}
The **template VM** in this guide refers to a regular vSphere VM and not VM
Templates according to the vSphere terminology. The difference is quite subtle,
but VM Templates are not supported yet by machine-controller.
{{% /notice %}}
