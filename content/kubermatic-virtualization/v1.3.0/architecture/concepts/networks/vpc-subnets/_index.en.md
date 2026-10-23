+++
title = "VPCs and Subnets"
date = 2025-07-18T16:06:34+02:00
weight = 15
+++
Kubermatic-Virtualization uses KubeOVN as a software defined network(SDN) and it supercharges Kubernetes networking by 
integrating it with Open Virtual Network (OVN) and Open vSwitch (OVS). These aren't new players; OVN and OVS are long-standing, 
industry-standard technologies in the Software-Defined Networking (SDN) space, predating Kubernetes itself. By leveraging 
their robust, mature capabilities, Kube-OVN significantly expands what Kubernetes can do with its network. 

You manage these networks through KubeV's own API, `virtualization.k8c.io/v1alpha1`: the `VPC` and `Subnet` kinds,
which the dashboard creates for you too. They live in a namespace, like your VMs. For each one, the KubeV
controller-manager creates the matching Kube-OVN object and keeps it in line with your spec, so change your `VPC` and
`Subnet` objects, never the Kube-OVN objects behind them.

## VPC
A VPC (Virtual Private Cloud) represents an isolated layer-3 network domain that contains one or more subnets.
Each VPC provides its own routing table and default gateway, allowing you to logically separate network traffic between
tenants or workloads.

Kubermatic Virtualization simplifies network setup by providing a default Virtual Private Cloud (VPC) and a default Subnet 
right out of the box: the cluster's pod network, Kube-OVN's `ovn-cluster` VPC and `ovn-default` subnet. These are
pre-configured to connect directly to the underlying node network, offering a seamless link 
to your existing infrastructure. This means you don't need to attach external networks to get started.

This design is a huge win for new users. It allows customers to dive into Kubermatic Virtualization and quickly establish 
network connectivity between their workloads and the hypervisor without wrestling with complex network configurations, 
external appliances, or advanced networking concepts. It's all about making the initial experience as straightforward 
and efficient as possible, letting you focus on your applications rather than network plumbing.


Here is an example of a VPC definition:  
```yaml
apiVersion: virtualization.k8c.io/v1alpha1
kind: VPC
metadata:
  name: custom-vpc
  namespace: team-a
spec:
  staticRoutes:
    - cidr: 0.0.0.0/0
      nextHopIP: 10.200.0.254
```

| Field                  | Description                                                                                                  |
| ---------------------- | ------------------------------------------------------------------------------------------------------------ |
| `metadata.name`        | Name of the VPC. Must be unique within its namespace.                                                        |
| `metadata.namespace`   | Namespace the VPC belongs to. Its subnets, and the VMs that use them, live in the same namespace.            |
| `spec.staticRoutes`    | Routes of the VPC's router: a destination `cidr` and a `nextHopIP`. Optionally `policy` (`dst` or `src`), and `bfdID` and `ecmpMode` for BFD-monitored ECMP routes. |
| `spec.policyRoutes`    | Policy-based routing rules: an OVN `match` expression, an `action` (`allow`, `drop` or `reroute`), a `priority`, and a `nextHopIP` for `reroute`. |
| `spec.vpcPeerings`     | Peerings with other VPCs in the same namespace: the `remoteVpcRef` and the `localConnectIP` of this side.   |
| `spec.defaultSubnet`   | A subnet of this VPC that becomes the namespace's default network: pods and VMs in the namespace that name no network get their address from it. Usually left empty, as VMs are attached to a subnet explicitly. |
| `spec.enableExternal`  | Connects the VPC to the external network.                                                                    |
| `spec.enableBfd`, `spec.bfdPort` | Turns on Bidirectional Forwarding Detection on the VPC's router, and configures its BFD port.      |

The VPC's status shows its `phase`, the `subnets` that belong to it, and its `realName`: the name of the Kube-OVN VPC
behind it, `<namespace>-<name>`.

## VPCs are global, Subnets are regional

In a multi-region Kubermatic Virtualization deployment this distinction matters and is easy to
miss: a **VPC is global** — one VPC for the whole stretched cluster (one `Vpc` object, wrapped by the namespaced `virtualization.k8c.io` `VPC`), not replicated per
region and not aware of regions at all — while a **Subnet is the region-scoped unit** underneath
it. A tenant's VPC exists exactly **once**, cluster-wide; what varies by region is which Subnets
exist under it — one per region the tenant has workloads in, each with its own CIDR and gateway,
each labelled for its region (`topology.kubernetes.io/region: region-a`, plus `topology.kubernetes.io/zone: region-a` if an `AZEdgeRouter` selects subnets by zone). Every regional
Subnet still belongs to that same single VPC and its one logical router — a region is a
Subnet-level fact, not something the VPC itself has copies of.

A VM's region is decided by whichever regional Subnet it's attached to, not by the VPC. See
[AZ Edge Router](../az-edge-router/) for how per-region traffic then reaches the outside world,
and how a region's `AZEdgeRouter` uses `subnetLabelSelector` to advertise only the Subnets that
belong to its own region even though it resolves the one, global VPC.

## Subnet

Subnets are the fundamental building blocks for network and IP management. They serve as the primary organizational unit
for configuring network settings and IP addresses. 

- VPC-Centric: Each Subnet belongs to one VPC in its own namespace, and shares that VPC's router.
- Automatic IP Allocation: VMs attached to a Subnet automatically receive their IP addresses from it.
- Shared Network Configuration: All VMs on a Subnet inherit the network configuration defined by it. This includes:
  - CIDR (Classless Inter-Domain Routing): The IP address range for the Subnet.
  - Gateway Type: How traffic leaves the Subnet.
  - Access Control: Network policies and security rules.
  - NAT Control: Network Address Translation settings.

Here is an example of a Subnet definition:
```yaml
apiVersion: virtualization.k8c.io/v1alpha1
kind: Subnet
metadata:
  name: my-custom-subnet
  namespace: team-a
spec:
  vpcRef: custom-vpc
  cidrBlock: 10.200.0.0/24
  gateway: 10.200.0.1
  gatewayType: distributed
  excludeIPs:
    - 10.200.0.1
    - 10.200.0.2..10.200.0.10
  protocol: IPv4
  natOutgoing: false
  private: false
  enableDHCP: true
```
| Field                | Description                                                                           |
|----------------------|---------------------------------------------------------------------------------------|
| `apiVersion`         | Must be `virtualization.k8c.io/v1alpha1`.                                             |
| `kind`               | Always set to `Subnet`.                                                               |
| `metadata.name`      | Name of the subnet. Must be unique within its namespace.                              |
| `metadata.namespace` | Namespace of the subnet. Must be the namespace of its VPC.                            |
| `spec.vpcRef`        | Name of the VPC the subnet belongs to, in the same namespace. Required.              |
| `spec.cidrBlock`     | The IP range (CIDR notation) assigned to this subnet. Required.                       |
| `spec.gateway`       | IP address used as the gateway for this subnet. Must be inside `cidrBlock`.           |
| `spec.gatewayType`   | `centralized` or `distributed`. `distributed` allows egress from local node gateways. |
| `spec.excludeIPs`    | IPs or IP ranges excluded from dynamic allocation.                                    |
| `spec.protocol`      | Can be `IPv4`, `IPv6`, or `Dual`.                                                     |
| `spec.natOutgoing`   | If true, VMs on this subnet will have outbound NAT enabled.                           |
| `spec.private`       | If true, traffic from outside this subnet is denied.                                  |
| `spec.enableDHCP`    | Enables DHCP services in the subnet.                                                  |
| `spec.provider`      | Kube-OVN provider of the subnet. Leave it empty: the controller-manager sets it to the subnet's own network attachment, which VMs use to attach. Ignored in KDP projects. |

Once the subnet is `Ready`, the controller-manager creates a `NetworkAttachmentDefinition` for it in the subnet's
namespace, and VMs attach to the subnet through it. The subnet's status shows its `phase`, `availableIPs` and `usedIPs`,
and its `realName`: the name of the Kube-OVN subnet behind it, `<namespace>-<name>-sn`, which is also the name of the
`NetworkAttachmentDefinition`. See [VMs Network Assignment]({{< ref "../vms-networks-assignment" >}}) for how a VM uses it.

Subnets on a physical VLAN, outside the overlay, are `UnderlaySubnet` objects. NAT gateways and elastic IPs, for
traffic between a VPC and the outside, are `NATGateway` and `ElasticIP` objects. All of them are described in the
[CRD reference]({{< ref "../../../../references/crds" >}}).

## Existing Kube-OVN networks

VPCs and subnets created directly in Kube-OVN, for example before KubeV managed networks, are adopted: the
controller-manager creates a `VPC` or `Subnet` for each of them, and they show up in the dashboard. A Kube-OVN VPC needs
an existing namespace for that, the first of its own `spec.namespaces`, or the one in its annotation
`virtualization.k8c.io/migration-namespace`. Its subnets follow it into that namespace. Kube-OVN's own default VPC and
subnets are not adopted.

Adopted objects are read-only: KubeV never changes or deletes the Kube-OVN object behind them, unless that object
carries the annotation `virtualization.k8c.io/adopt-writable: "true"` (KubeV may change it) or
`virtualization.k8c.io/adopt-deletable: "true"` (deleting the `VPC` or `Subnet` deletes it too). Label a Kube-OVN
object with `virtualization.k8c.io/migration=skip` to leave it out.
