+++
title = "Creating vSphere Template VMs"
date = 2022-10-31T12:00:00+02:00
enableToc = false
+++

This guide describes how to create templates VMs for vSphere to be used with
Terraform, Kubermatic KubeOne, and Kubermatic machine-controller. This is an
umbrella document — we have a dedicated guide for each operating system:

- [Ubuntu]({{< ref "./ubuntu/" >}})
- [CentOS 7]({{< ref "./centos/" >}})

Guides for other operating systems will be added in the future.

{{% notice warning %}}
The **template VM** in this guide refers to a regular vSphere VM and not VM
Templates according to the vSphere terminology. The difference is quite subtle,
but VM Templates are not supported yet by machine-controller.
{{% /notice %}}
