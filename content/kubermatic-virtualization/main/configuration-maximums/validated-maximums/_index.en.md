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
| **NetworkPolicies per namespace** | **30,001** (≈ 175,000 enforced rules <sup>†</sup>) | **Stateful firewall policies inside one namespace** |
| **NetworkPolicies per cluster** | **120,001** (≈ 355,000 enforced rules <sup>†</sup>) | **Stateful firewall policies across all namespaces** |
| **SecurityGroups per cluster** | **5,606** | **Reusable firewall scopes** |
| **Services per cluster** | **1,001** | **Routable, load-balanced service addresses** |
| **Static routes per VPC** | **3,830** | **Next-hop routes on one tenant's router** |
| **NICs per VM** | **32** | **Secondary network interfaces on a single virtual machine** |
| **vCPUs per VM** | **94** | **Virtual CPUs on a single VM** |
| **Memory per VM** | **180 GiB** | **RAM on a single VM** |
| **Pods per worker node** | **1,185** | **Container workloads one host schedules concurrently** |
| **Pod-to-pod latency** | same-host **167 µs** · cross-host **532 µs** | **Best-case network round-trip on an idle cluster** |

<sup>†</sup> **Enforced rules** — the low-level allow/deny entries each NetworkPolicy compiles into
inside the network; one policy expands to several (~5.8 here). The policy count is what you
define and manage; the rule count is the real enforcement load on the cluster.

{{% notice note %}}
**Deliberately not given a row:**
- **QoS (bandwidth/priority) policies and secondary-network templates** — these attach per
  pod/VM, so their real limit is pod capacity (*Pods per worker node*), not a standalone count.
- **VMs per worker host** — being re-validated on the current cluster shape; added once that run lands.
- **Tenants before workloads slow down** — a degradation result, not a capacity maximum. See
  [Degradation]({{< ref "../degradation" >}}) (no slowdown through 120 tenants / 600 running VMs).
{{% /notice %}}

## How each maximum was found

Every count comes from the same routine, run by the **ConfigMax** tool against a freshly
cleaned reference cluster:

1. **Push.** Create the object in growing batches (50, then ×1.5 each round) until a stop
   condition hits.
2. **Check it works.** After each batch, verify the objects are *functional*, not just stored —
   a pod in a new subnet gets an IP and pings its gateway, a service answers with a live
   backend, a firewall rule actually blocks traffic.
3. **Watch the cluster.** Sample the control plane against fixed danger lines — etcd database at
   80 % of quota, `ovn-central` memory at 85 %, control-plane host memory at 90 %, sustained
   `ovn-northd` CPU saturation.
4. **Stop, and record why** (the *Stopped by* column below):
   - **a danger line is crossed** — the cluster is straining; the count just before is the ceiling;
   - **the object stops working** — a new one can't be programmed or verified in time;
   - **the configured cap is reached with no strain** — the real ceiling is *higher*, so the number is a lower bound.

The published maximum is the highest count that was both reached **and** verified working. The
technical table adds, per capability, the component that gave out first and what was observed at
the ceiling. Full per-test parameters:
[method cards]({{< ref "../engineering-reference/method-cards" >}}).

## Technical reference

Per capability: the validated ceiling, why the run stopped, the component that would give out
first, and what was observed at that point.

Want the raw numbers behind "what was observed" — etcd database size, `ovn-central` memory,
`ovn-northd` CPU and control-plane host memory at each ceiling? Every run's per-component
readings against their danger lines are in the
[per-test method cards]({{< ref "../engineering-reference/method-cards" >}}).

| Capability (KubeV resource) | Validated ceiling | Stopped by | Limiting component | At the ceiling |
|---|---:|---|---|---|
| VPCs / cluster | 10,000 | configured cap — no strain | etcd database size was nearest its budget (~77 %) | Nothing was strained: the busiest component, the etcd database, sat at only 77 % of its budget, so plenty of headroom remained. |
| Subnets / cluster | 11,822 | controller finished programming this many within the post-cap settle window | kube-ovn-controller programming throughput | Every component stayed well below its danger line. A pod placed in a fresh subnet got its IP and pinged its gateway at 0.57 ms with no packet loss — proof the subnets actually worked, not just existed. |
| Subnets / VPC | 8,001 | configured cap — no strain | none approached | No component came close to a danger line, and subnets kept being created at a steady 46–48 per minute with no slowdown. |
| NetworkPolicies / namespace | 30,001 (175,246 rules) | configured cap — no strain | none approached; rule programming kept pace throughout | Nothing was strained, and the firewall rules were programmed as fast as the policies were created (~5.8 rules per policy, no backlog). |
| NetworkPolicies / cluster | 120,001 (355,469 rules) | configured cap — no strain | none approached; an independent bystander probe watched the cluster's API virtual IP throughout — zero failures | No component came near a danger line. Policies were added at a steady ~2,200 per minute, and a separate probe confirmed the cluster's API stayed reachable the whole time — zero failures. |
| SecurityGroups / cluster | 5,606 | kube-ovn-controller instability at higher counts (upstream fix tracked) | kube-ovn-controller stability | etcd, ovn-central and ovn-northd all stayed healthy. The wall was the kube-ovn controller itself, which crashed repeatedly under the load (15 restarts) — a known bug being fixed upstream. |
| Services / cluster | 1,001 | configured cap — no strain | pod-wiring throughput at higher counts | Backend pods came up to 1,005 Ready and every service address answered with a live backend, with nothing on the cluster strained. |
| Static routes / VPC | 3,830 | configured cap (earlier methodology) | kube-ovn-controller programming cadence | Measured with an earlier method — detailed component readings weren't captured for this run. |
| Pod-to-pod latency (idle cluster) | same-host **167 µs** · cross-host **532 µs** avg RTT | n/a — direct measurement, not a push run | data-plane state: with ~14,000 leftover subnets present the same measurement read 1.84 ms cross-host — datapath cost scales with logical-object count, which is why every run starts from a fully cleaned cluster | A direct pod-to-pod ping on an idle cluster: ~167 µs within a host, ~532 µs across hosts, no packet loss. |

VM-to-VM latency **under tenant load** is a degradation measurement, not a capacity ceiling —
the current result (flat 406–488 µs cross-host through 120 tenants / 600 VMs) lives on the
[Degradation]({{< ref "../degradation" >}}) page.
