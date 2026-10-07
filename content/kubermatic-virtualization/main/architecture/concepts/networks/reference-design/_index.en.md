+++
title = "Reference Design"
date = 2026-09-08T00:00:00+00:00
weight = 25
draft = true
+++

These pages show complete platform layouts and **the role the [AZ Edge Router](../az-edge-router/)
plays in each**. They are architecture overviews, not installation guides: configuring the
workloads that run inside the VPCs (for example KKP or KubeLB) is out of scope here and covered
by those products' own documentation.

## The layers

| Layer | What it is |
|---|---|
| **Platform** | **one** Kubermatic Virtualization cluster, stretched across regions: Kube-OVN for networking, KubeVirt for compute. Regions are locality inside it, not separate installations. |
| **Tenancy** | one Kube-OVN VPC per tenant. A VPC is a routing domain of its own — isolated by default, with no path to the node network or to another VPC. |
| **Interconnect** | one [AZ Edge Router](../az-edge-router/) per region, multi-homed into every VPC it serves, with a separate VRF per VPC. |
| **Workload** | VMs inside each VPC, whatever they run. |

The central choice is that **a VPC is isolated, and stays isolated**. There is no data path from
one VPC to another. What a VPC offers to the outside it offers as a **published service**,
reached through the fabric and subject to whatever the external firewall permits.

The edge router does not soften that. Its jobs are egress, service advertisement, and carrying a
VPC's traffic **between regions** over the fabric when configured to — not joining VPCs to each other.

## Choose a design

| Design | Use it for |
|---|---|
| [VM workloads](vm-workloads/) | traditional VMs per tenant: the simplest layout, one VPC per tenant and one router per region |
| [KKP multi-tenant](kkp-multi-tenant/) | hosting Kubermatic Kubernetes Platform on the cluster, with a shared master/seed VPC and one VPC per tenant |

## Regions

There is one Kubermatic Virtualization cluster and it spans the regions. A region is a
**placement domain inside that cluster**. **VPCs are global, Subnets are regional**: a tenant is
one VPC cluster-wide, with one Subnet per region it is present in, and one edge router per region
serving the local subnets.

| Cluster-wide | Per region |
|---|---|
| the cluster and its operators | the hypervisors that contribute capacity |
| the VPCs — one per tenant | the **subnets** of each VPC |
| | one [AZ Edge Router](../az-edge-router/) serving that region's subnets |

A VM's region is decided by the subnet it is attached to. Traffic between a VPC's regional
subnets stays in OVN by default; it can be routed over the fabric instead — see
[Multi-region](../az-edge-router/multi-region/).
