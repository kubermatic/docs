+++
title = "Validated Maximums"
date = 2026-06-11T09:00:00+02:00
weight = 1
+++

Each capability is identified by its corresponding Kubermatic Virtualization or Kubernetes
resource; the *Description* column states the platform-neutral concept. Most of these figures are
**validated lower bounds**: the run reached a configured cap while the cluster showed no strain,
which indicates that the true ceiling is higher. Where a figure is a genuine hard limit, this is
noted in the [technical reference](#technical-reference).

| Capability (KubeV resource) | Validated maximum | Description |
|---|---|---|
| VPCs per cluster | **10,000** | Network tenants per cluster |
| Subnets per cluster | **11,822** | Layer-3 subnets cluster-wide |
| Subnets per VPC | **8,001** | Subnets within one network tenant |
| NetworkPolicies per namespace | **30,001** | Stateful firewall policies within a single namespace |
| NetworkPolicies per cluster | **120,001** | Stateful firewall policies across all namespaces |
| SecurityGroups per cluster | **5,606** | Reusable firewall scopes |
| Services per cluster | **1,001** | Routable, load-balanced service addresses |
| Static routes per VPC | **3,830** | Next-hop routes on a single tenant's router |
| NICs per VM | **36** | Secondary network interfaces on a single virtual machine |
| vCPUs per VM | **94** | Virtual CPUs on a single virtual machine |
| Memory per VM | **180 GiB** | RAM on a single virtual machine |
| Pods per worker node | **1,185** | Container workloads scheduled concurrently on one host |
| Pod-to-pod latency | same-host **167 µs** · cross-host **532 µs** | Best-case network round-trip on an idle cluster |

{{% notice note %}}
**Tenant density before workload performance degrades** is reported separately. On the reference
cluster, virtual-machine-to-virtual-machine latency remained stable through **120 tenants and 600
running virtual machines** (the run's configured cap), with a worst case of 13 % above baseline and
no observed slowdown. This is a degradation measurement rather than a capacity maximum, and
therefore is not assigned a row above. See [Degradation]({{< ref "../degradation" >}}) for detail.
{{% /notice %}}

## How each maximum was determined

Every figure is produced by the same procedure, executed by the **ConfigMax** tool against a
freshly cleaned reference cluster:

1. Create the objects in progressively larger batches until a stop condition is met.
2. After each batch, verify that the objects are functional rather than merely stored. A pod placed
   in a new subnet must obtain an IP address and reach its gateway, and a service must respond
   through a live backend.
3. Sample the control plane against fixed danger thresholds, including etcd database size, Kube-OVN
   control-plane memory and CPU, and control-plane host memory.
4. Stop when a danger threshold is crossed (the count immediately prior is the ceiling), when an
   object ceases to function, or when the configured cap is reached with no strain (the figure is
   then a lower bound).

The published maximum is the highest count that was both reached and verified to be functional.

## Technical reference

The following table lists, for each capability, the validated ceiling, the reason the run stopped,
and the component expected to be the first limiting factor.

| Capability (KubeV resource) | Validated ceiling | Stop reason | Limiting component |
|---|---:|---|---|
| VPCs / cluster | 10,000 | Configured cap reached; no strain | etcd database size (closest to its budget, approximately 77 %) |
| Subnets / cluster | 11,822 | Controller completed programming this count within the settle window | Kube-OVN controller programming throughput |
| Subnets / VPC | 8,001 | Configured cap reached; no strain | None approached its danger line |
| NetworkPolicies / namespace | 30,001 | Configured cap reached; no strain | None approached its danger line |
| NetworkPolicies / cluster | 120,001 | Configured cap reached; no strain | None approached its danger line |
| SecurityGroups / cluster | 5,606 | Kube-OVN controller instability at higher counts (upstream fix tracked) | Kube-OVN controller stability |
| Services / cluster | 1,001 | Configured cap reached; no strain | Pod-wiring throughput at higher counts |
| Static routes / VPC | 3,830 | Configured cap reached | Kube-OVN controller programming cadence |
| NICs / VM | 36 | Hard wall at 40 NICs (interfaces never finish wiring) | Per-node network-sandbox wiring; a longer boot timeout does not lift it |
| vCPUs / VM | 94 | Host core count (hardware) | Worker physical cores |
| Memory / VM | 180 GiB | Host RAM (hardware) | Worker RAM |
| Pods / worker node | 1,185 | kubelet `--max-pods` ceiling | kubelet (a configuration limit, not a network limit) |
| Pod-to-pod latency (idle) | same-host 167 µs · cross-host 532 µs | Direct measurement, not a scaling run | Increases with logical-object count; every run begins from a clean cluster |

{{% notice note %}}
**Enforced rules.** Each NetworkPolicy compiles into several low-level allow and deny entries within
the network (approximately six per policy in these runs). The policy count above is the figure that
an operator defines and manages; the underlying enforcement load is higher. At the cluster maximum,
120,001 policies programmed approximately 355,000 enforced rules with no observed strain.
{{% /notice %}}
