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
technical table adds, per capability, the component that gave out first and its peak readings at
the ceiling. Full per-test parameters:
[method cards]({{< ref "../engineering-reference/method-cards" >}}).

## Technical reference

Per capability: the validated ceiling, why the run stopped, the component that would give out
first, and its peak readings the moment the number was recorded.

| Capability (KubeV resource) | Validated ceiling | Stopped by | Limiting component | Measured at the ceiling (run date · duration) | Published comparable* |
|---|---:|---|---|---|---:|
| VPCs / cluster | 10,000 | configured cap — no strain | etcd database size was nearest its budget (~77 %) | etcd DB 1,227 MB of the ~1,600 MB danger line (**77 %**) · ovn-central memory 2.0 of 14.4 GiB · ovn-northd CPU 1.6 of 3.6 cores · control-plane host memory 31 % of the 90 % line · new-VPC provisioning latency ~10 ms (CR flips Ready near-instantly — the programmed logical-router count is the authoritative signal) (2026-06-08 · 1 h 06 m) |  ~4,000 |
| Subnets / cluster | 11,822 | controller finished programming this many within the post-cap settle window | kube-ovn-controller programming throughput | ovn-northd CPU ≤ 2.2 of 3.6 cores · ovn-central memory ≤ 4.2 of 14.4 GiB · control-plane host memory ≤ 44 % of 90 % · per-host ovs-ovn memory flat ~256 MiB of 8 GiB · live latency check at 11.8 k subnets: a pod dropped into a fresh subnet got its IP and pinged its gateway at **0.57 ms RTT, 0 % loss** (2026-06-09 · 5 h 28 m) | ~5,000 |
| Subnets / VPC | 8,001 | configured cap — no strain | none approached | ovn-central memory ≤ 4.3 of 14.4 GiB · control-plane host memory ≤ 46 % of 90 % · programming sustained 46–48 subnets/min with no late slowdown · same gateway-ping datapath verify pattern as subnets-per-cluster (2026-06-10 · 3 h 06 m) | ~5,000 |
| NetworkPolicies / namespace | 30,001 (175,246 rules) | configured cap — no strain | none approached; rule programming kept pace throughout | ovn-central memory ≤ 5 of 14.4 GiB · enforced-rule (ACL) programming kept pace the whole run (~5.8 ACLs per policy, no backlog) · ovn-northd and kube-ovn-controller healthy (2026-06-10 · 1 h 08 m) | ~100,000 rules |
| NetworkPolicies / cluster | 120,001 (355,469 rules) | configured cap — no strain | none approached; an independent bystander probe watched the cluster's API virtual IP throughout — zero failures in ~4 h | steady 13.4 s per 500-policy batch (~2,200 policies/min) for the entire 3.5 h push · bystander probe on the cluster API virtual IP: **0 failures in 1,459 samples (~4 h)** · no component neared a danger line (2026-06-10 · 4 h 00 m) | ~100,000 rules |
| SecurityGroups / cluster | 5,606 | kube-ovn-controller instability at higher counts (upstream fix tracked) | kube-ovn-controller stability | ovn-central, ovn-northd and etcd all healthy — kube-ovn-controller itself crashed under the 20,000-object reconcile load (concurrent map read/write race, 15 restarts: **this is the wall**) · port-group programming decelerated 119 → 24/min (2026-06-10 · 2 h 07 m) | ~10,000 |
| Services / cluster | 1,001 | configured cap — no strain | pod-wiring throughput at higher counts | backend pods 0 → 1,005 Ready during the run · OVN load-balancer VIPs climbed 35 → 953 → **1,001 settled** (every VIP answered with a live backend) · no strain (2026-06-10 · 13 m) | ~10,000 |
| Static routes / VPC | 3,830 | configured cap (earlier methodology) | kube-ovn-controller programming cadence | earlier methodology: stop rule was programmed-vs-requested route drift > max(200, 25 %); modern component readings not captured for this run (2026-05-05 · 1 h 04 m) | ~4,000 |
| Pod-to-pod latency (idle cluster) | same-host **167 µs** · cross-host **532 µs** avg RTT | n/a — direct measurement, not a push run | data-plane state: with ~14,000 leftover subnets present the same measurement read 1.84 ms cross-host — datapath cost scales with logical-object count, which is why every run starts from a fully cleaned cluster | same-host avg 167 µs (min 71 µs, max 2.17 ms) · cross-host avg 532 µs (min 369 µs, max 3.69 ms) · 0 % packet loss, direct ICMP between pods (2026-05-06 · freshly-booted cluster) | n/a |

\* Published configuration-maximum of a comparable enterprise virtualization platform, for sizing
orientation only.

VM-to-VM latency **under tenant load** is a degradation measurement, not a capacity ceiling —
the current result (flat 406–488 µs cross-host through 120 tenants / 600 VMs) lives on the
[Degradation]({{< ref "../degradation" >}}) page.
