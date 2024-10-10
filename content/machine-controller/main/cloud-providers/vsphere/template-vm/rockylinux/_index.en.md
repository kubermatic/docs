+++
title = "RockyLinux Template VM"
linkTitle = "RockyLinux"
date = 2022-10-31T12:00:00+02:00
+++

This guide describes how to create a template VM for vSphere running RockyLinux.
The template VM is supposed to be compatible with Terraform, machine-controller,
KubeOne and KKP.

{{% notice warning %}}
The **template VM** in this guide refers to a regular vSphere VM and not VM
Templates according to the vSphere terminology. The difference is quite subtle,
but VM Templates are not supported yet by machine-controller.
{{% /notice %}}

## Requirements

You need to satisfy the following requirements before proceeding:

* Have access to the vSphere API via `govc` and vCenter
* Have the following tools installed on your local machine: `govc`, `qemu-img`,
  and `virt-customize` (comes with the `libguestfs-tools` package)

## Preparing Local Environment

Before getting started, you should prepare your local environment by exporting
`GOVC_` environment variables with the information about your vSphere setup:

```shell
export GOVC_URL="https://<url>"
export GOVC_USERNAME="<username>"
export GOVC_PASSWORD="<password>"
export GOVC_INSECURE=false # set to true if you don't have a valid/trusted certificate
export GOVC_DATASTORE="<datastore-name>"
```

## Downloading RockyLinux VM

We'll download RockyLinux `qcow2` image. `qcow2` is a hard drive with preinstalled
RockyLinux that can be used for creating (vSphere) VMs. That being said, you don't
need to install RockyLinux manually, that's already done for you.

The `qcow2` image can be downloaded from the [official RockyLinux website][rockylinux].
Download the latest available `qcow2` file. At the time of writing this document,
the latest available file is called `Rocky-9-GenericCloud-Base.latest.x86_64.qcow2`.
It's recommended to verify checksums, but we'll omit that because of brevity.

[rockylinux]: https://rockylinux.org/download

## Preparing and Uploading the RockyLinux qcow2 File

The downloaded RockyLinux installation comes in `qcow2` format, however, we need
VMDK format so that it can be used with vSphere. Additionally, we need to login
to the VM to configure it. The installation comes with `root` and `rocky` users,
but neither has a password set, so it's not possible to login to the VM using
those users.

First, we'll set the password for the `root` user using the `virt-customize`
tool:

```shell
sudo virt-customize -a Rocky-9-GenericCloud-Base.latest.x86_64.qcow2 --root-password 'password:<insert-your-password-here>'
```

Customizing the VM might take a minute or two. Once that's done, we can convert
the `qcow2` file to `vmdk` using `qemu-img`:

```shell
qemu-img convert -O vmdk -o subformat=streamOptimized "./Rocky-9-GenericCloud-Base.latest.x86_64.qcow2" "Rocky-9-GenericCloud-Base.latest.x86_64.vmdk"
```

Converting the image to vmdk might take several minutes. Finally, once that is
done, we can upload the `vmdk` file to vSphere using `govc` or using vCenter.
We'll use `govc` for purposes of this guide:

```shell
govc import.vmdk -dc=<datacenter-name> -pool=/<datacenter-name>/host/<cluster-name>/Resources -ds=<datastore-name> "./Rocky-9-GenericCloud-Base.latest.x86_64.vmdk"
```

That might take a few minutes depending on your internet connection speed.
In the next step, we'll create a new vSphere VM using the uploaded `vmdk` file
as the hard drive.

## Creating a Template VM

Go to vCenter and create a new Virtual Machine. You can name and place the
VM however you prefer. When asked about compatibility, choose the latest
available compatibility level. For Guest OS, choose Linux and CentOS 9 (64bit).

When asked to customize the hardware, you should take the following steps:

- remove the existing hard drive
- click on **Add New Device** and choose **Existing Hard Disk**
  - Find the uploaded `vmdk` file and then click on the **OK** button
- choose **Client Device** for **New CD/DVD Drive** and ensure that
  **Device Mode** is set to **Passthrough Mode** for that CD/DVD drive

Proceed with creating the VM. Once the VM is created, power it on and proceed
to the next step.

## Preparing the VM

We'll configure the VM to be used as a template VM by KubeOne and
machine-controller. Before proceeding, power on the VM via vCenter and open
the Web Console or connect to the VM via SSH.

Once the VM is booted, you'll see a prompt to enter credentials in the Web
Console. Login with username `root` and use the password that you've chosen
earlier.

{{% notice note %}}
Working with the web console can be cumbersome sometimes. To work around this,
you could _temporarily_ edit the `/etc/ssh/sshd_config`, set `PermitRootLogin yes`,
restart the SSH daemon using `systemctl restart sshd` and then SSH into the VM.

Be sure to undo your changes to the `sshd_config` before powering off the machine!
{{% /notice %}}

As a first step, make sure that the VM is up-to-date:

```shell
yum update
```

Next, ensure that you have the following packages installed:

```shell
yum install \
  cloud-init \
  open-vm-tools \
  curl \
  wget \
  sudo \
  vim \
  epel-release
```

Once the `epel-release` package is installed, you can install `pip` which
will be used later:

```shell
yum install python2-pip
```

Ensure that a service for VMware Tools is enabled and started:

```shell
systemctl enable --now vmtoolsd
```

As a final step, we'll cleanup the VM so that it can be used as a template.

First, we'll ensure that there's no hardcoded MAC address in the network
configuration. Run `ip addr` and note the name of your network interface,
for example `eth0`. Locate and open a network configuration file for your
network interface. Network configuration files are located in
`/etc/sysconfig/network-scripts` and are named as `ifcfg-<interface-name>`.
For example:

```shell
vi /etc/sysconfig/network-scripts/ifcfg-eth0
```

Locate the line starting with `HWADDR=...`. If there's such line, remove it
completely, then save the file and close the text editor. If there's no such
line, you don't need to take any action and can just close the text editor.

Then, remove generated SSH host keys. They'll be regenerated upon the next
boot:

```shell
rm -f /etc/ssh/ssh_host_*
```

Proceed to remove logs from `/var/log` and installation logs from the `/root`
directory:

```shell
find /var/log -type f -exec truncate --size=0 {} \;
rm -f /root/anaconda-ks.cfg /root/original-ks.cfg
```

We can also cleanup temporary directories:

```shell
rm -rf /tmp/* /var/tmp/*
```

To make sure VMs are provisioned from the template correctly, we also have to
reset the seed and machine-id:

```shell
rm -f /var/lib/systemd/random-seed
echo -n > /etc/machine-id
```

Finally, to make sure that cloud-init works as expected, it's recommended to
clean the cloud-init data:

```shell
cloud-init clean
cloud-init clean -l
```

Finally, power off the VM:

```shell
poweroff
```

{{% notice note %}}
If you ever boot the template VM again, you will need to repeat the cleanup
steps again.
{{% /notice %}}

## Conclusion

The VM configuration is now completely done and the VM can be used as a
template VM for both Terraform and machine-controller.
