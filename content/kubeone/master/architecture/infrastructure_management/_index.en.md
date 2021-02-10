+++
title = "Infrastructure Management"
date = 2021-02-10T12:00:00+02:00
weight = 2
enableToc = true
+++

This document describes some of the possible approaches for managing the 
infrastructure needed for a Kubernetes cluster.

## Infrastructure For Control Plane

It's the user's responsibility to create and manage the infrastructure for the
control plane. In order to help with this, KubeOne integrates with Terraform by
reading the information about the infrastructure from the Terraform state, and
provides example Terraform configurations that can be used to get started. The
example Terraform configs can be found in the [KubeOne's GitHub repository][terraform-configs-github].

{{% notice note %}}
The example Terraform configurations are optimized for the CI and might not
be production-ready out of the box. We advise checking the
[Production Recommendations]({{< ref "../../cheat_sheets/production_recommendations" >}})
document for more details about making the example configurations suitable for
the production usage.
{{% /notice %}}

{{% notice note %}}
If you're using our example Terraform configs, requirements are satisfied
out of the box.
{{% /notice %}}

The following infrastructure requirements **must** be satisfied to successfully
provision a Kubernetes cluster using KubeOne:

* You need the appropriate number of instances dedicated for the control plane
  * You need **even** number of instances with a minimum of **three** instances
  for the Highly-Available control plane
  * If you decide to use a single-node control plane instead, one instance is
    enough, however, highly-available control plane is highly advised,
    especially in the production environments
* All control plane instances must satisfy the
  [system requirements for a kubeadm cluster][kubeadm-sysreq]
  * Minimum 2 vCPUs
  * Minimum 2 GB RAM
  * Operating system must be a [officially-supported by KubeOne][supported-os]
    (Ubuntu, Debian, CentOS, RHEL, Flatcar Linux)
  * Full network connectivity between all machines in the cluster
    (private network is recommended, but public is supported as well)
  * Unique hostname, MAC address, and product_uuid for every node
    * You can get the MAC address of the network interfaces using the command
    `ip link` or `ifconfig -a`
    * The product_uuid can be checked by using the command
     `sudo cat /sys/class/dmi/id/product_uuid`
  * Swap disabled. You MUST disable swap in order for the kubelet to work
    properly.
  * The following ports open: `6443`, `2379`, `2380`, `10250`, `10251`, `10252`
* For highly-available control plane, a load balancer pointing to the
  control plane instances (the Kubernetes API server) is required
  * Load balancer must include all control plane instances and distribute
    traffic to the TCP port 6443 (default port of the Kubernetes API server)
  * It's recommended to use a provider's offering for load balancers if such is
    available
  * If provider doesn't offer load balacners, you can create an instance and
    setup a solution such as HAProxy
  * Check out the [Load Balancer for Highly-Available Cluster example][ha-lb-example]
    to learn more about possible setups
* You must have an SSH key deployed on all control plane instances and
  SSH configured as described in the [Configuring SSH][ssh] document

Depending on the environment, you may need additional objects, such as VPCs,
firewall rules, or images. For [officially-supported
providers][supported-providers], we recommended checking our [example Terraform
configs][terraform-configs-github] as a reference what objects you should be
created.

## Infrastructure For Worker Nodes

Instances for worker nodes can be managed in two ways:

* using [Kubermatic machine-controller][machine-controller], which creates and
  provisions instances, and joins them a cluster, automatically
* using KubeOne Static Workers, by using the preferred tooling to create
  instances (e.g. Terraform) and then provision them using KubeOne

Using Kubermatic machine-controller is highly advised if your provider is
[officially-supported][supported-providers].
Otherwise, [KubeOne Static Workers][static-workers] are recommended instead.
More details about the machine-controller and the Cluster-API can be found in
the [Concepts][concepts] document.

The requirements for the worker instances are similar as for the control
plane instances:

* All instances must satisfy the
  [system requirements for a kubeadm cluster][kubeadm-sysreq]
  * Minimum 2 vCPUs
  * Minimum 2 GB RAM
  * Operating system must be a [officially-supported by KubeOne][supported-os]
    (Ubuntu, Debian, CentOS, RHEL, Flatcar Linux)
  * Full network connectivity between all machines in the cluster
    (private network is recommended, but public is supported as well)
  * Unique hostname, MAC address, and product_uuid for every node
    * You can get the MAC address of the network interfaces using the command
    `ip link` or `ifconfig -a`
    * The product_uuid can be checked by using the command
     `sudo cat /sys/class/dmi/id/product_uuid`
  * Swap disabled. You MUST disable swap in order for the kubelet to work
    properly.
  * The following ports open: `10250`, and optionally `30000-32767` for
    NodePort Services
* You must have an SSH key deployed on all control plane instances and
  SSH configured as described in the [Configuring SSH][ssh] document

## Terraform Integration

KubeOne integrates with Terraform by reading the Terraform state for the
information about the cluster, including:

* the Kubernetes API server load balancer endpoint
* nodes' public and private IP addresses, and hostnames
* SSH parameters (username, port, key)
* bastion/jump host parameters if the bastion host is used
* information needed to generate the [MachineDeployment objects][concepts-mc]
  which define worker nodes

To use the integration, you need to generate a Terraform state file using the
`terraform output -json` command. KubeOne consumes the generated Terraform
state file and reads the needed information. Therefore, the generated file
**must** strictly follow the format used by KubeOne. To accomplish this, you
must have the appropriate `output.tf` file co-located with other Terraform
files. The `output.tf` file defines the template for generating the state file, including where to look for the information about the infrastructure.

For more information about how the `output.tf` file should look like, you can
check our [example Terraform configs][terraform-configs-github] and the
[Terraform Integration Reference][terraform-reference].

{{% notice note %}}
The needed `output.tf` file already comes with all our
[example Terraform configs]({{< ref "." >}}).
{{% /notice %}}

[kubeadm-sysreq]: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#before-you-begin
[ssh]: {{< ref "../../guides/ssh#sshd-requirements-on-instances" >}}
[supported-providers]: {{< ref "../compatibility#supported-providers" >}}
[supported-os]: {{< ref "../compatibility#supported-operating-systems" >}}
[terraform-configs-github]: https://github.com/kubermatic/kubeone/tree/master/examples/terraform
[machine-controller]: https://github.com/kubermatic/machine-controller
[static-workers]: {{< ref "../../guides/static_workers" >}}
[concepts]: {{< ref "../concepts#kubermatic-machine-controller" >}}
[concepts-md]: {{< ref "../concepts#machinedeployments" >}}
[concepts-mc]: {{< ref "../concepts#kubermatic-machine-controller" >}}
[ha-lb-example]: {{< ref "../../examples/ha_load_balancing" >}}
[terraform-reference]: {{< ref "../../references/terraform_integration" >}}
