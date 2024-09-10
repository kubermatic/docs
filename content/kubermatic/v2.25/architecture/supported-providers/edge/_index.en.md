+++
title = "Edge (Experimental)"
date = 2024-03-12T13:00:00+02:00
weight = 4
+++

KKP empowers you to build Kubermatic user clusters across a wide range of edge devices, from compact Internet of Things (IoT) 
field devices all the way up to powerful servers running in data centers.

{{% notice warning %}}
KKP Edge provider is marked as experimental and deploying it to production is on your own risk and we recommend using a
staging environment for testing before.
{{% /notice %}}

## Requirement
To leverage KKP's edge capabilities, you'll need to:

* Provide Target Devices: Identify the edge devices you want to function as worker nodes within your Kubermatic user cluster.
* Direct Machine Access: Ensure you have direct access methods (like SSH) to manage and configure these target devices.
* Network Connectivity: Establish a network connection between the target devices and the KKP seed. This allows the devices to communicate with the user cluster's API server.

## Usage

Once the edge provider has been activated in the seed object by updating the Datacenter spec, the edge provider will be available: 

```yaml
spec:
  country: US
  datacenters:
    edge-eu-de:
      country: US
      location: LA
      spec:
        edge: {}
```

While the KKP cluster control plane manages the overall environment, creating deployments for worker nodes differs from 
typical cloud provider setups. The key difference is MachineDeployments are used as references. Unlike other cloud providers 
where machine controller directly control machine orchestration, KKP uses MachineDeployments as references. They point to the 
desired nodes within the cluster where the underlying configurations are created.

{{% notice note %}}
Unlike traditional MachineDeployments, the `replicas` field in KKP's MachineDeployments doesn't directly control the number of worker nodes created. 
Instead, each MachineDeployment acts as a blueprint for a single worker node. This one-to-one mapping simplifies management by ensuring a 
clear relationship between the deployment and the corresponding node.
{{% /notice %}}

After creating the MachineDeployment, you can access a provisioning script within the deployment details. This script needs 
to be executed on the target device you want to add as a worker node to your cluster.

{{% notice note %}}
Currently, the edge provider only support Ubuntu 20.04 and 22.04 as an operating system. More support for other operating system will be added in the future. 
{{% /notice %}}

![Edge Machine Deployment Window](/img/kubermatic/v2.25/architecture/supported-providers/edge/edge-machine-deployment-window.png?classes=shadow,border "Edge Machine Deployment Window")
