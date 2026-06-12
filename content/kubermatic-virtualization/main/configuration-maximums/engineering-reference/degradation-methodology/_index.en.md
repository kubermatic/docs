+++
title = "Degradation Methodology"
date = 2026-06-12T09:00:00+02:00
weight = 2
+++

**Why bundles, not single resources.** Single-resource degradation cannot be measured reliably:
batch-to-batch drift of ±40–50 % in the latency probe swamps any single-resource signal, so a
"cliff" read from one resource type alone is noise. Bundles of resources with **running VMs**
produce a clean signal, because a VM creates real datapath state (port binding, conntrack, NAT)
while empty subnets and dormant policies cost almost nothing. The published bundle (Small): 1
namespace + 2 subnets + 10 enforcing NetworkPolicies + 2 services + 1 security group + 5 VMs per
tenant. The policies select the tenant VM's launcher pod (verified: OVN port-groups carry the
VM's port as a member), so each tenant adds real ACL datapath cost — not no-op objects.

**Canary topology.** Two always-on probe pairs: a same-node VM pair and a cross-node, cross-VPC
pair (traffic crosses the OVN datapath, conntrack and the VPC peering — the closest match to
real multi-tenant traffic).

**Measurement.** VM-to-VM **p99** latency at every settled batch boundary (p99 catches worst-case
stutters that an average hides). A light HTTP request probe (low connection count, short
duration) runs three passes per boundary and takes the median, so a single outlier pass cannot
fake a cliff; the baseline is measured the same way (median of 3, identical intensity — a heavier
baseline than boundary makes drift permanently negative and blinds the trip).

**Stop rule (dual, 2026-06-12).** The run stops and publishes a degradation count only when BOTH
conditions hold at the same boundaries, each sustained for 3 consecutive settled boundaries:

| Leg | Condition | Why it exists |
|---|---|---|
| Absolute floor | p99 > **2 ms** | latency high enough for an application to feel; alone it is unfair to clusters whose healthy baseline is already near 2 ms |
| Relative | p99 > **4× this cluster's own baseline** | far above THIS cluster's normal; alone it trips fast clusters (e.g. 100 µs → 900 µs) at values nothing feels |

| Threshold | Type | Meaning |
|---|---|---|
| Warning | baseline +50 % p99, 3 consecutive boundaries | engineering early-warning — recorded, does not stop |
| Degradation stop | absolute floor AND relative leg, each 3 consecutive boundaries | the published degradation number |

Why 2 ms: a typical app makes many network round-trips per user operation (a DB query can be
10–100 hops). At 2 ms per hop that is 20–200 ms per operation — a delay a customer feels. Why 4×:
every cliff observed on the reference cluster has been a ≥4× jump within one or two batches —
degradation in this system arrives as a step, not a slope. Both values are engineering picks, not
sacred constants — a real customer SLA replaces the floor. Because the relative leg is anchored
to the cluster's **own measured baseline**, the rule transfers across cluster shapes: run the
benchmark on your cluster and the trip point adapts to your normal.

**Measurement-integrity rules (2026-06-12).**

- **Probe-lost abort.** Three consecutive boundaries with no measurement abort the run as
  INVALID (`vm-latency-probe-lost`) — it publishes nothing. A silent measurement gap must never
  read as "no degradation" (an earlier run failed exactly this way and was discarded).
- **Recovery before counting a failure.** A failed boundary measurement first triggers a canary
  IP refresh + one re-measure inside the same boundary (a canary VM that restarts under load can
  change IP).
- **Baseline completeness.** The baseline is refused unless BOTH the same-node and cross-node
  legs are non-zero; a stored baseline with a missing leg is discarded and re-measured (early
  runs silently ran with the same-node leg blind).
- All capacity distress probes stay active during degradation runs as a safety net; if capacity
  gives out before latency, the published answer becomes "the cluster ran out of capacity before
  customers felt slowness."

**Provenance of the current published result.** 2026-06-12, reference cluster, image-pinned run:
**flat to 120 tenants / 600 VMs (the run's tenant cap)** — baseline same-host 281 µs / cross-host
430 µs; all 24 boundaries measured with zero probe failures; cross-host p99 406–488 µs throughout
(max +13 % over baseline — never near the warning, let alone the stop). The degradation point of
the current platform is **above 120 tenants** of this shape; higher-cap runs are scheduled.

**Superseded: the ~80 ± 10 cliff (2026-05-08).** Three runs on an earlier benchmark generation
reproduced a 4× cliff at ~80–90 bundles. That result is no longer representative: it was measured
(a) on a cluster whose per-node networking agents were memory-starved (the multus agent was
crash-looping at a 256 Mi limit; the per-node OVN agent had a 1 Gi limit that OOM-killed under
load), (b) with firewall policies that never actually enforced (no pod carried the selected
label), and (c) with a one-legged baseline (same-host leg unrecorded). After the cluster fixes
and the bundle-realism fix, the 2026-06-12 run carried 7.5× more VMs with enforcing policies and
showed zero movement. The engineering lesson stands: **per-node networking agent resourcing is
the first degradation wall** — fix that before reading any tenant-scale cliff as architectural.
Ingredient isolation from that era remains valid: bundles without VMs tripped only at 550–575
(noise-bound — essentially free); VM density dominates datapath cost.
