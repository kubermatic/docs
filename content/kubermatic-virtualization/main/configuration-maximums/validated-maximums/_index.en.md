+++
title = "Validated Maximums"
date = 2026-06-11T09:00:00+02:00
weight = 1
+++

Capabilities are named by their actual Kubermatic Virtualization / Kubernetes resource; the
*What it means* column gives the platform-neutral concept for readers coming from other
virtualization stacks. Full detail per capability — stop reason and limiting component — is in
the [technical reference](#technical-reference) below.

| Capability (KubeV resource) | Validated maximum | What it means |
|---|---|---|
| **VPCs per cluster** | **10,000** | **Network tenants per cluster** |
| **Subnets per cluster** | **11,822** | **Layer-3 subnets cluster-wide** |
| **Subnets per VPC** | **8,001** | **Subnets within one network tenant** |
| **NetworkPolicies per namespace** | **30,001** (≈ 175,000 enforced rules) | **Stateful firewall policies inside one namespace** |
| **NetworkPolicies per cluster** | **120,001** (≈ 355,000 enforced rules) | **Stateful firewall policies across all namespaces** |
| **SecurityGroups per cluster** | **5,606** | **Reusable firewall scopes** |
| **Services per cluster** | **1,001** | **Routable, load-balanced service addresses** |
| **Static routes per VPC** | **3,830** | **Next-hop routes on one tenant's router** |
| **NICs per VM** | **32** | **Secondary network interfaces on a single virtual machine** |
| **vCPUs per VM** | **94** | **Virtual CPUs on a single VM** |
| **Memory per VM** | **180 GiB** | **RAM on a single VM** |
| **Pods per worker node** | **1,185** | **Container workloads one host schedules concurrently** |
| **Pod-to-pod latency** | same-host **167 µs** · cross-host **532 µs** | **Best-case network round-trip on an idle cluster** |

{{% notice note %}}
**Not listed as rows:** bandwidth/priority (QoS) policies and secondary-network templates apply
per-pod/per-VM rather than as standalone cluster objects — their practical bound is pod capacity
(see *Pods per worker node*), so a standalone count would be misleading.
**VMs per worker host** is being re-validated on the current cluster shape and will be added once
the dedicated run lands.
**How many tenants fit before workloads slow down (~80 ± 10)** is a degradation result, not a
capacity maximum — see [Degradation]({{< ref "../degradation" >}}).
{{% /notice %}}

## Technical reference

For readers comparing platforms: per capability, the validated ceiling, **why the run stopped**,
and the component that would give out first. A run that stopped at its configured cap with no
strain means the real ceiling is above the listed number.

| Capability (KubeV resource) | Validated ceiling | Stopped by | Limiting component | Published comparable* |
|---|---:|---|---|---:|
| VPCs / cluster | 10,000 | configured cap — no strain | etcd database size was nearest its budget (~77 %) | ~4,000 |
| Subnets / cluster | 11,822 | controller finished programming this many within the post-cap settle window | network-controller programming throughput | ~5,000 |
| Subnets / VPC | 8,001 | configured cap — no strain | none approached | ~5,000 |
| NetworkPolicies / namespace | 30,001 (175,246 rules) | configured cap — no strain | none approached; rule programming kept pace throughout | ~100,000 rules |
| NetworkPolicies / cluster | 120,001 (355,469 rules) | configured cap — no strain | none approached; an independent bystander probe watched the cluster's API virtual IP throughout — zero failures in ~4 h | ~100,000 rules |
| SecurityGroups / cluster | 5,606 | network-controller instability at higher counts (upstream fix tracked) | network-controller stability | ~10,000 |
| Services / cluster | 1,001 | configured cap — no strain | pod-wiring throughput at higher counts | ~10,000 |
| Static routes / VPC | 3,830 | configured cap (earlier methodology) | network-controller programming cadence | ~4,000 |

\* Published configuration-maximum of a comparable enterprise virtualization platform, for sizing
orientation only.
