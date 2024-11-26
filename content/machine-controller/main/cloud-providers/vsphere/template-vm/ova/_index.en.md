+++
title = "Creating a Template VM from a OVA image"
linkTitle = "Generic OVA"
date = 2022-10-31T12:00:00+02:00
+++

This document outlines the general procedure for adding new Template VMs in vSphere
for `.ova` images.

{{% notice warning %}}
The **template VM** in this guide refers to a regular vSphere VM and not VM
Templates according to the vSphere terminology. The difference is quite subtle,
but VM Templates are not supported yet by machine-controller.
{{% /notice %}}

## WebUI procedure

1. Go into the vSphere WebUI, select your datacenter, right click onto it and choose "Deploy OVF Template"
1. Fill in the "URL" field with the appropriate url pointing to the `OVA` file
1. Click through the dialog until "Select storage"
1. Select the same storage you want to use for your machines
1. Select the same network you want to use for your machines
1. Leave everything in the "Customize Template" and "Ready to complete" dialog as it is
1. Wait until the VM got fully imported and the "Snapshots" => "Create Snapshot" button is not grayed out anymore

## Command-line procedure

Prerequisites:

* [govc](https://github.com/vmware/govmomi/tree/main/govc): tested on version 0.37.2
* [jq](https://stedolan.github.io/jq/)

Procedure:

1. Download the `OVA` for the targeted OS.

    ```bash
    curl -sL "${OVA_URL}" -O .
    ```

2. Extract the specs from the `OVA`:

    ```bash
    govc import.spec $(basename "${OVA_URL}") | jq -r > options.json
    ```

3. Edit the `options.json` file with your text editor of choice.

    * Edit the `NetworkMapping` to point to the correct network.
    * Make sure that `PowerOn` is set to `false`.
    * Make sure that `MarkAsTemplate` is set to `false`.
    * Verify the other properties and customize according to your needs.
    e.g.

    ```json
    {
      "DiskProvisioning": "flat",
      "IPAllocationPolicy": "dhcpPolicy",
      "IPProtocol": "IPv4",
      "PropertyMapping": [
        {
          "Key": "guestinfo.hostname",
          "Value": ""
        },
        {
          "Key": "guestinfo.flatcar.config.data",
          "Value": ""
        },
        {
          "Key": "guestinfo.flatcar.config.url",
          "Value": ""
        },
        {
          "Key": "guestinfo.flatcar.config.data.encoding",
          "Value": ""
        },
        {
          "Key": "guestinfo.interface.0.name",
          "Value": ""
        },
        {
          "Key": "guestinfo.interface.0.mac",
          "Value": ""
        },
        {
          "Key": "guestinfo.interface.0.dhcp",
          "Value": "no"
        },
        {
          "Key": "guestinfo.interface.0.role",
          "Value": "public"
        },
        {
          "Key": "guestinfo.interface.0.ip.0.address",
          "Value": ""
        },
        {
          "Key": "guestinfo.interface.0.route.0.gateway",
          "Value": ""
        },
        {
          "Key": "guestinfo.interface.0.route.0.destination",
          "Value": ""
        },
        {
          "Key": "guestinfo.dns.server.0",
          "Value": ""
        },
        {
          "Key": "guestinfo.dns.server.1",
          "Value": ""
        }
      ],
      "NetworkMapping": [
        {
          "Name": "VM Network",
          "Network": "Kubermatic Default"
        }
      ],
      "MarkAsTemplate": false,
      "PowerOn": false,
      "InjectOvfEnv": false,
      "WaitForIP": false,
      "Name": null
    }
    ```

4. Create a VM from the `OVA`:

    ```bash
    govc import.ova -options=options.json $(basename "${OVA_URL}")
    ```
