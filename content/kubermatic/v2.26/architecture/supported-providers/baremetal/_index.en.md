+++
title = "Baremetal (Experimental)"
date = 2024-10-17T16:00:00+02:00
weight = 3
+++

The KKP Baremetal Provider allows you to seamlessly deploy and manage user clusters on physical bare-metal infrastructure. With this provider, you can integrate and manage your bare-metal servers as worker nodes, leveraging the flexibility and performance of physical hardware.

{{% notice warning %}}
The Baremetal provider is currently in the experimental phase. We recommend deploying it in a staging environment for testing before moving to production.
{{% /notice %}}

## Tinkerbell as a Provisioning Engine

KKP’s Baremetal provider uses Tinkerbell to automate the setup and management of bare-metal servers within Kubernetes clusters. Tinkerbell simplifies the process by handling critical tasks such as disk preparation, operating system installation, and network configuration. This reduces the need for manual intervention, allowing bare-metal servers to be set up quickly and consistently across different environments.

With Tinkerbell, the provisioning process is driven by workflows that ensure each server is configured according to the desired specifications. Whether you are managing servers in a single location or across multiple data centers, Tinkerbell provides a reliable and automated way to manage your physical infrastructure, making it as easy to handle as cloud-based resources.

## Requirement
To successfully use the KKP Baremetal provider with Tinkerbell, ensure the following:

* **Tinkerbell Cluster**: A working Tinkerbell cluster must be in place.
* **Direct Access to Servers**: You must have access to your bare-metal servers, allowing you to provision and manage them.
* **Network Connectivity**: Establish a network connection between the API server of Tinkerbell cluster and the KKP seed cluster. This allows the Kubermatic Machine Controller to communicate with the Tinkerbell stack.
* **Tinkerbell Hardware Objects**: Create Hardware Objects within Tinkerbell that represent each bare-metal server you want to provision as a worker node in your Kubernetes cluster.

## Usage

### Setting Up the Baremetal Provider

Start by activating the bare-metal provider in your KKP seed object:

```yaml
spec:
  country: DE
  datacenters:
    bm-europe-west3-c:
      country: DE
      location: Hamburg
      spec:
        baremetal:
          tinkerbell:
            images:
              http:
                operatingSystems:
                  ubuntu:
                    "22.04": http://example.com/ubuntu-image.raw.gz
```

### Creating Tinkerbell Hardware Objects 

In Tinkerbell, Hardware Objects represent your physical bare-metal servers. To successfully provision these servers as worker nodes in your Kubernetes cluster, each Hardware Object must accurately reflect the server’s characteristics, including details about disk devices, network interfaces, and the overall network configuration.

Before proceeding, ensure you gather the following information for each server:

* **Disk Devices**: Specify the available disk devices, including bootable storage.
* **Network Interfaces**: Define the network interfaces available on the server, including MAC addresses and interface names.
* **Network Configuration**: Configure the IP addresses, gateways, and DNS settings for the server's network setup.

It’s essential to allow PXE booting and workflows for the provisioning process. This is done by ensuring the following settings in the hardware spec object:

```yaml
netboot:
  allowPXE: true
  allowWorkflow: true
```

This configuration allows Tinkerbell to initiate network booting and enables iPXE to start the provisioning workflow for your bare-metal server.

This is an example for Hardware Object Configuration
```yaml
apiVersion: tinkerbell.org/v1alpha1
kind: Hardware
metadata:
  name: baremetal-server-0
  namespace: tink-system
spec:
  disks:
  - device: /dev/sda
  interfaces:
  - dhcp:
      arch: x86_64
      hostname: baremetal-server-0
      iface_name: <dev-name>
      ip:
        address: 10.20.0.210
        gateway: 10.20.0.1
        netmask: 255.255.255.0
      lease_time: 86400
      mac: aa:bb:cc:dd:ee:ff
      name_servers:
      - 1.1.1.1
      - 8.8.8.8
      uefi: true
    netboot:
      allowPXE: true
      allowWorkflow: true
```

### Powering  On Baremetal Servers 

After creating the Hardware Objects, power on your bare-metal servers and configure them for one-time network booting via iPXE. This boot process is crucial, as it allows the server to load a minimal in-memory operating system provided by Tinkerbell, which includes Docker.

Once the server boots, a `tink-worker` container is deployed. This container is responsible for executing the actions defined by the Machine Controller for the corresponding MachineDeployment.

### Creating The Baremetal Cluster in KKP Dashboard

Once your Tinkerbell environment is set up, and your bare-metal servers are ready, you can proceed to create the Baremetal cluster in the KKP dashboard. The critical part of this process is defining the *Baremetal Node settings* correctly, including the *Operating System Image* and **Hardware Settings**.
![Baremetal Machine Deployment](./baremetal-machine-initial-node.png.png?classes=shadow,border "Baremetal Machine Deployment")

{{% notice note %}}
Unlike traditional MachineDeployments, the `replicas` field in KKP's MachineDeployments doesn't directly control the number of worker nodes created.
Instead, each MachineDeployment acts as a blueprint for a single worker node. This one-to-one mapping simplifies management by ensuring a
clear relationship between the deployment and the corresponding node.
{{% /notice %}}

Once the MachineDeployment is created and reconciled, the provisioning workflow will start immediately. This process is executed by the `tink-worker` container, which runs inside the in-memory operating system provided by iPXE boot.

The Machine Controller generates the necessary actions for this workflow, which are then executed on the bare-metal server by the `tink-worker` container. The key actions include:

* **Wiping the Disk Devices**: All existing data on the disk will be erased to prepare for the new OS installation.
* **Installing the Operating System**: The specified OS image (e.g., Ubuntu 20.04 or 22.04) will be installed on the server.
* **Network Configuration**: The server’s network settings will be configured based on the Hardware Object and the defined network settings.
* **Cloud-init Propagation**: The Operating System Manager (OSM) will propagate the cloud-init settings to the node to ensure proper configuration of the OS and related services.

Once the provisioning workflow is complete, the bare-metal server will be fully operational as a worker node in the Kubernetes cluster.

{{% notice note %}}
Currently, the baremetal provider only support Ubuntu as an operating system. More support for other operating system will be added in the future.
{{% /notice %}}

## Future Enhancements

Currently, the Baremetal provider requires users to manually create Hardware Objects in Tinkerbell and manually boot up bare-metal servers for provisioning. However, future improvements aim to automate these steps to make the process smoother and more efficient. The goal is to eliminate the need for manual intervention by automatically detecting hardware, creating the necessary objects, and initiating the provisioning process without user input. This will make the Baremetal provider more dynamic and scalable, allowing users to manage their infrastructure with even greater ease and flexibility.