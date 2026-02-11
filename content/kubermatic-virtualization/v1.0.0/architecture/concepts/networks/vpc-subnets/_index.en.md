+++
title = "Networking"
date = 2025-07-18T16:06:34+02:00
weight = 15
+++
Kubermatic-Virtualization uses KubeOVN as a software defined network(SDN) and it supercharges Kubernetes networking by 
integrating it with Open Virtual Network (OVN) and Open vSwitch (OVS). These aren't new players; OVN and OVS are long-standing, 
industry-standard technologies in the Software-Defined Networking (SDN) space, predating Kubernetes itself. By leveraging 
their robust, mature capabilities, Kube-OVN significantly expands what Kubernetes can do with its network. 

## VPC
A VPC (Virtual Private Cloud) in Kube-OVN represents an isolated layer-3 network domain that contains one or more subnets.
Each VPC provides its own routing table and default gateway, allowing you to logically separate network traffic between
tenants or workloads.

Kubermatic Virtualization simplifies network setup by providing a default Virtual Private Cloud (VPC) and a default Subnet 
right out of the box. These are pre-configured to connect directly to the underlying node network, offering a seamless link 
to your existing infrastructure. This means you don't need to attach external networks to get started.

This design is a huge win for new users. It allows customers to dive into Kubermatic Virtualization and quickly establish 
network connectivity between their workloads and the hypervisor without wrestling with complex network configurations, 
external appliances, or advanced networking concepts. It's all about making the initial experience as straightforward 
and efficient as possible, letting you focus on your applications rather than network plumbing.


Here is an example of a VPC definition:  
```yaml
apiVersion: kubeovn.io/v1
kind: Vpc
metadata:
  name: custom-vpc
spec:
  cidr: 10.200.0.0/16
  enableNAT: false
  defaultGateway: ""
  staticRoutes:
    - cidr: 0.0.0.0/0
      nextHopIP: 10.200.0.1
```

| Field            | Description                                                                             |
| ---------------- | --------------------------------------------------------------------------------------- |
| `metadata.name`  | Name of the VPC. Must be unique within the cluster.                                     |
| `spec.cidr`      | The overall IP range for the VPC. Subnets under this VPC should fall within this range. |
| `enableNAT`      | Whether to enable NAT for outbound traffic. Useful for internet access.                 |
| `defaultGateway` | IP address used as the default gateway for this VPC. Usually left blank for automatic.  |
| `staticRoutes`   | List of manually defined routes for the VPC.                                            |

## Subnet

Subnets are the fundamental building blocks for network and IP management. They serve as the primary organizational unit
for configuring network settings and IP addresses. 

- Namespace-Centric: Each Kubernetes Namespace can be assigned to a specific Subnet.
- Automatic IP Allocation: Pods deployed within a Namespace automatically receive their IP addresses from the Subnet that 
Namespace is associated with.
- Shared Network Configuration: All Pods within a Namespace inherit the network configuration defined by their Subnet. This includes:
  - CIDR (Classless Inter-Domain Routing): The IP address range for the Subnet.
  - Gateway Type: How traffic leaves the Subnet.
  - Access Control: Network policies and security rules.
  - NAT Control: Network Address Translation settings.

Here is an example of a VPC definition:
```yaml
apiVersion: kubeovn.io/v1
kind: Subnet
metadata:
  name: my-custom-subnet
  namespace: kube-system
spec:
  cidrBlock: 10.16.0.0/16
  gateway: 10.16.0.1
  gatewayType: distributed
  excludeIps:
    - 10.16.0.1
    - 10.16.0.2..10.16.0.10
  protocol: IPv4
  natOutgoing: true
  private: false
  vpc: custom-vpc
  enableDHCP: true
  allowSubnets: []
  vlan: ""
  namespaces:
    - default
    - dev
  subnetType: overlay
```
| Field                | Description                                                                           |
|----------------------|---------------------------------------------------------------------------------------|
| `apiVersion`         | Must be `kubeovn.io/v1`.                                                              |
| `kind`               | Always set to `Subnet`.                                                               |
| `metadata.name`      | Unique name for the subnet resource.                                                  |
| `metadata.namespace` | Namespace where the subnet object resides. Usually `kube-system`.                     |
| `spec.cidrBlock`     | The IP range (CIDR notation) assigned to this subnet.                                 |
| `spec.gateway`       | IP address used as the gateway for this subnet.                                       |
| `spec.gatewayType`   | `centralized` or `distributed`. `distributed` allows egress from local node gateways. |
| `spec.excludeIps`    | IPs or IP ranges excluded from dynamic allocation.                                    |
| `spec.protocol`      | Can be `IPv4`, `IPv6`, or `Dual`.                                                     |
| `spec.natOutgoing`   | If true, pods using this subnet will have outbound NAT enabled.                       |
| `spec.private`       | If true, pod traffic is restricted to this subnet only.                               |
| `spec.vpc`           | Is the name of the VPC that the subnet belongs to.                                    |
| `spec.enableDHCP`    | Enables DHCP services in the subnet.                                                  |
| `spec.allowSubnets`  | List of subnets allowed to communicate with this one (used with private=true).        |
| `spec.vlan`          | Optional VLAN name (empty string means no VLAN).                                      |
| `spec.namespaces`    | Namespaces whose pods will be assigned IPs from this subnet.                          |
| `spec.subnetType`    | Can be `overlay`, `underlay`, `VLAN`, or `external`.                                  |
