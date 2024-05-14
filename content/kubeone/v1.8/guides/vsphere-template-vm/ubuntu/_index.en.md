+++
title = "Ubuntu Template VM"
date = 2022-10-31T12:00:00+02:00
+++

This guide describes how to create a template VM for vSphere running Ubuntu.
The template VM is supposed to be compatible with Terraform, Kubermatic KubeOne,
and Kubermatic machine-controller.

This guide has been tested with Ubuntu 22.04 and vSphere 7.0. Using other
versions of Ubuntu and/or vSphere might require some adjustments to the guide.
Concretely speaking, older Ubuntu versions might come with cloud-init not
compatible with vSphere and vApp. This might require taking addition steps to
get it working.

{{% notice warning %}}
The **template VM** in this guide refers to a regular vSphere VM and not VM
Templates according to the vSphere terminology. The difference is quite subtle,
but VM Templates are not supported yet by machine-controller.
{{% /notice %}}

## Requirements

You need to satisfy the following requirements before proceeding:

* Have access to the vSphere API via `govc` and vCenter
* Have the `govc` tool installed on your local machine

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

## Downloading an Ubuntu 22.04 VM

Ubuntu has dedicated [cloud images] built to be used on cloud platforms and
hypervisors such as vSphere. We'll use an OVA cloud image because it provides
the best compatibility with vSphere. OVA provides preinstalled Ubuntu VM that
can be uploaded to vSphere and used as such. That being said, you don't need
to install Ubuntu manually, that's already done for you.

The [following directory on the cloud images website][cloud-images-jammy]
contains the latest images for Ubuntu 22.04 (Jammy Jellyfish). Find and download
an OVA image from that directory or use the `curl` command below. The image
should be named something like `jammy-server-cloudimg-amd64.ova`. It's
recommended to verify checksums, but we'll omit that because of brevity.

You can download the image using curl:

```shell
curl -LO https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.ova
```

## Preparing Configuration for the VM

The next step is to extract the config from the downloaded OVA file and change
it as described in this step. We want to ensure that we can login to the VM
once we upload it to vSphere.

The easiest way to extract the config is using `govc`. The following command
will save the VM config to a file called `config.json`:

```shell
govc import.spec jammy-server-cloudimg-amd64.ova > config.json
```

Edit the `config.json` file in a text editor of your choice:
- Set `DiskProvisioning` to `thin`
  ```json
  ...
  "DiskProvisioning": "thin",
  ...
  ```
- Set `password` in `PropertyMapping` to a password that you want to use to
  login to the VM:
  ```json
  ...
    "PropertyMapping": [
      ...
      {
        "Key": "password",
        "Value": "<your-password>"
      }
    ],
    ...
  ```
- Set `Network` in `NetworkMapping` to the name of the network that you want
  to use:
  ```json
  ...
  "NetworkMapping": [
    {
      "Name": "VM Network",
      "Network": "<network-name>"
    }
  ],
  ...
  ```
- Ensure that following properties are configured as below:
  ```json
  ...
  "MarkAsTemplate": false,
  "PowerOn": false,
  "InjectOvfEnv": false,
  "WaitForIP": false,
  "Name": null
  ```

With that done, save the file, close the text editor and proceed to the next
step where we'll upload the VM to vSphere.

## Uploading the VM to vSphere

Now that the VM configuration is ready, we can upload the OVA file to vSphere.
That can be done using `govc` or via vCenter. We'll use `govc` for purposes
of this guide:

```bash
govc import.ova --options config.json jammy-server-cloudimg-amd64.ova
```

That might take a few minutes depending on your internet connection speed.
After upload is done, you should be able to see a newly-created VM in the
vCenter. Note the VM name as we will use it later — it should be something
along `jammy-server-cloudimg-amd64`.

Once the VM is uploaded, you'll need to upgrade the VM compatibility to version
15 or newer (it's recommended to use the latest version). Go to vCenter, find
the VM, right click on it in the right pane, go to the **Compatibility** menu
and then click on **Upgrade VM Compatibility...**. This should open a pop-up
window with a dropdown menu where you can choose the VM compatibility level.
Choose the latest available level and then proceed to upgrade the VM.
Once the VM is upgraded, go to the next step of this guide to prepare the VM
to be used as a template VM by KubeOne.

## Preparing the VM

We'll configure the VM to be used as a template VM by KubeOne and
machine-controller. Before proceeding, power on the VM via vCenter and open
the Web Console or connect to the VM via SSH.

Once the VM is booted, you'll see a prompt to enter credentials in the Web
Console. Login with username `ubuntu` and use the password that you've chosen
earlier when preparing the `config.json` file.

For the sake of simplicity, switch to the `root` user:

```shell
sudo -i
```

As a first step, make sure that the VM is up-to-date:

```shell
apt-get update
apt-get dist-upgrade -y
```

Next, ensure that you have cloud-init and VMware Tools installed:

```shell
apt-get install cloud-init open-vm-tools
```

Ensure that a service for VMware Tools is enabled and started:

```shell
systemctl enable --now vmtoolsd
```

For Ubuntu VMs, you need to take additional steps to ensure that each VM
cloned from this template VM has unique IP and MAC addresses. More information
about this can be found in [VMware KB82229].

[VMware KB82229]: https://kb.vmware.com/s/article/82229

Run the following command to reset the `machine-id` property of the VM:

```shell
echo -n > /etc/machine-id
rm /var/lib/dbus/machine-id
ln -s /etc/machine-id /var/lib/dbus/machine-id
```

With that done, we need to configure networking for the VM. The following
step assumes that you want to use DHCP for your VM. This might be different
depending on your vSphere setup.

List all files in the `/etc/netplan` directory. There should be a file named
as `50-*.yaml`. Open that file with a text editor of your choice. Remove
everything from that file and paste the following contents:

```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    default:
      match:
        name: e*
      dhcp4: yes
      dhcp-identifier: mac
```

Save the file and exit the text editor. Finally, apply the network configuration
and ensure that you still have network connectivity afterwards.

```shell
netplan apply
```

If there are any additional adjustments that you want to make to the VM, you
should do those adjustments now before proceeding.

To make sure the VM is fresh and can be used as a template, and that vApp
works as expected, it's recommended to clean the cloud-init data:

```shell
cloud-init clean
cloud-init clean -l
```

Finally, power off the VM:

```shell
poweroff
```

{{% notice note %}}
If you ever boot the template VM again, you will need to repeat steps from
deleting the machine-id to cleaning the cloud-init data again.
{{% /notice %}}

## Configuring the VM Properties and Enabling vApp

There are few steps that you should take to ensure the VM will work correctly
as a template for Terraform and machine-controller.

First, right click on the VM in the right pane and select **Edit Settings...**.
Ensure that **CD/DVD drive 1** is set to **Client Device**, then click on that
drive and ensure that **Device Mode** is set to **Passthrough CD-ROM**. Click on
**OK** button to confirm the changes.

Finally, go to the **Configure** tab and then choose vApp Options. Click on
the **Edit** button and ensure that:
- **Enable vApp options** is checked
- **IP protocol** is set to the appropriate protocol
- In the **OVF Details** tab, both **ISO image** and **VMware Tools** must be checked

Confirm the changes by clicking on the **OK** button.

## Conclusion

The VM configuration is now completely done and the VM can be used as a
template VM for both Terraform and machine-controller.

[cloud images]: https://cloud-images.ubuntu.com/
[cloud-images-jammy]: https://cloud-images.ubuntu.com/jammy/current/

## Known Issues

* Internal Kubernetes endpoints unreachable on vSphere with Cilium/Canal on VMXNET3 adapter, see [this issue](../../../known-issues/#internal-kubernetes-endpoints-unreachable-on-vsphere-with-ciliumcanal) for more details and workaround.
