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
the component that would give out first, and **what was actually measured at the ceiling** —
the run date and the peak component readings against their danger lines, so a technical reader
can see what the cluster was doing the moment each number was recorded. A run that stopped at
its configured cap with no strain means the real ceiling is above the listed number.

Danger lines used by every run: etcd database at 80 % of its quota; network-control-plane
database memory at 85 % of its limit; control-plane host memory at 90 %; sustained
rule-compiler CPU saturation. Full per-test readings with named components, parameters and stop
triggers: [per-test method cards]({{< ref "../engineering-reference/method-cards" >}}).

| Capability (KubeV resource) | Validated ceiling | Stopped by | Limiting component | Measured at the ceiling (run date · duration) | Published comparable* |
|---|---:|---|---|---|---:|
| VPCs / cluster | 10,000 | configured cap — no strain | etcd database size was nearest its budget (~77 %) | etcd DB 1,227 MB of the ~1,600 MB danger line (**77 %**) · network-DB memory 2.0 of 14.4 GiB · rule-compiler CPU 1.6 of 3.6 cores · control-plane host memory 31 % of the 90 % line (2026-06-08 · 1 h 06 m) |  ~4,000 |
| Subnets / cluster | 11,822 | controller finished programming this many within the post-cap settle window | network-controller programming throughput | rule-compiler CPU ≤ 2.2 of 3.6 cores · network-DB memory ≤ 4.2 of 14.4 GiB · control-plane host memory ≤ 44 % of 90 % · per-host network-agent memory flat ~256 MiB of 8 GiB · live check: a pod dropped into a fresh subnet got its IP and pinged its gateway, 0 % loss (2026-06-09 · 5 h 28 m) | ~5,000 |
| Subnets / VPC | 8,001 | configured cap — no strain | none approached | network-DB memory ≤ 4.3 of 14.4 GiB · control-plane host memory ≤ 46 % of 90 % · programming sustained 46–48 subnets/min with no late slowdown (2026-06-10 · 3 h 06 m) | ~5,000 |
| NetworkPolicies / namespace | 30,001 (175,246 rules) | configured cap — no strain | none approached; rule programming kept pace throughout | network-DB memory ≤ 5 of 14.4 GiB · enforced-rule programming kept pace the whole run (~5.8 rules per policy, no backlog) · compiler and controller healthy (2026-06-10 · 1 h 08 m) | ~100,000 rules |
| NetworkPolicies / cluster | 120,001 (355,469 rules) | configured cap — no strain | none approached; an independent bystander probe watched the cluster's API virtual IP throughout — zero failures in ~4 h | steady 13.4 s per 500-policy batch (~2,200 policies/min) for the entire 3.5 h push · bystander probe on the cluster API address: **0 failures in 1,459 samples (~4 h)** · no component neared a danger line (2026-06-10 · 4 h 00 m) | ~100,000 rules |
| SecurityGroups / cluster | 5,606 | network-controller instability at higher counts (upstream fix tracked) | network-controller stability | central database, compiler and etcd all healthy — the network controller itself crashed under the 20,000-object reconcile load (memory-access race, 15 restarts: **this is the wall**) · programming decelerated 119 → 24 groups/min (2026-06-10 · 2 h 07 m) | ~10,000 |
| Services / cluster | 1,001 | configured cap — no strain | pod-wiring throughput at higher counts | backend pods 0 → 1,005 Ready during the run · programmed service addresses climbed 35 → 953 → **1,001 settled** (every address answered with a live backend) · no strain (2026-06-10 · 13 m) | ~10,000 |
| Static routes / VPC | 3,830 | configured cap (earlier methodology) | network-controller programming cadence | earlier methodology: stop rule was programmed-vs-requested route drift > max(200, 25 %); modern component readings not captured for this run (2026-05-05 · 1 h 04 m) | ~4,000 |

\* Published configuration-maximum of a comparable enterprise virtualization platform, for sizing
orientation only.
