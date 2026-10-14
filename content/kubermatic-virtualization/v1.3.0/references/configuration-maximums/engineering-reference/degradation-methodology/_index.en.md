+++
title = "Degradation Methodology"
date = 2026-06-12T09:00:00+02:00
weight = 2
+++

**Why bundles rather than single resources.** Single-resource degradation cannot be measured
reliably: batch-to-batch drift of ±40 to 50 % in the latency probe swamps any single-resource
signal, so a cliff read from one resource type alone is noise. Bundles of resources that include
**running VMs** produce a clean signal, because a VM creates real datapath state (port binding,
conntrack, and NAT), while empty subnets and dormant policies cost almost nothing. Bundles without
VMs scale 5 to 7 times further before any signal appears, which confirms that VM density dominates
datapath cost. The published bundle (Small) is one namespace, two subnets, ten enforcing
NetworkPolicies, two services, one security group, and five VMs per tenant. The policies select the
tenant VM's launcher pod (verified: OVN port-groups carry the VM's port as a member), so each
tenant adds real ACL datapath cost rather than no-op objects.

**Canary topology.** Two always-on probe pairs are used: a same-node VM pair and a cross-node,
cross-VPC pair. The cross-node pair's traffic crosses the OVN datapath, conntrack, and the VPC
peering, which is the closest match to real multi-tenant traffic.

**Measurement.** VM-to-VM **p99** latency is recorded at every settled batch boundary, because p99
catches worst-case stutters that an average hides. A light HTTP request probe (low connection
count, short duration) runs three passes per boundary and takes the median, so a single outlier
pass cannot fake a cliff. The baseline is measured the same way (median of three at identical
intensity); a heavier baseline than the boundary would make drift permanently negative and blind
the trip.

**Stop rule (dual).** The run stops and publishes a degradation count only when both conditions
hold at the same boundaries, each sustained for three consecutive settled boundaries:

| Leg | Condition | Why it exists |
|---|---|---|
| Absolute floor | p99 above **2 ms** | latency high enough for an application to feel; on its own it is unfair to clusters whose healthy baseline is already near 2 ms |
| Relative | p99 above **4× this cluster's own baseline** | far above this cluster's normal; on its own it would trip a fast cluster (for example 100 µs rising to 900 µs) at values nothing feels |

| Threshold | Type | Meaning |
|---|---|---|
| Warning | baseline +50 % p99, three consecutive boundaries | an engineering early warning; recorded, does not stop the run |
| Degradation stop | absolute floor and relative leg, each three consecutive boundaries | the published degradation number |

The 2 ms floor is chosen because a typical application makes many network round-trips per user
operation (a database query can be 10 to 100 hops); at 2 ms per hop that is 20 to 200 ms per
operation, a delay a customer feels. The 4× ratio is chosen because degradation in this system
arrives as a step rather than a slope, and observed cliffs are jumps of 4× or more within one or
two batches. Both values are engineering choices rather than fixed constants, and a real customer
SLA replaces the floor. Because the relative leg is anchored to the cluster's own measured
baseline, the rule transfers across cluster shapes: running the benchmark on a given cluster adapts
the trip point to that cluster's normal.

**Measurement-integrity rules.**

- **Probe-lost abort.** Three consecutive boundaries with no measurement abort the run as invalid
  (`vm-latency-probe-lost`), and it publishes nothing. A measurement gap must never read as "no
  degradation."
- **Recovery before counting a failure.** A failed boundary measurement first triggers a canary IP
  refresh and one re-measurement inside the same boundary, because a canary VM that restarts under
  load can change its IP address.
- **Baseline completeness.** The baseline is refused unless both the same-node and cross-node legs
  are non-zero; a stored baseline with a missing leg is discarded and re-measured.
- All capacity distress probes stay active during degradation runs as a safety net. If capacity
  gives out before latency does, the published answer becomes "the cluster ran out of capacity
  before customers felt any slowdown."

**Provenance of the published result.** On the reference cluster, in an image-pinned run, latency
stayed **flat through 120 tenants and 600 VMs (the run's tenant cap)**: baseline same-host 281 µs
and cross-host 430 µs, all 24 boundaries measured with zero probe failures, and cross-host p99
between 406 and 488 µs throughout (worst case 13 % above baseline, never near the warning let alone
the stop). The degradation point is **above 120 tenants** of this shape. A representative result
requires properly resourced per-node networking agents (see the tuning baseline); memory-starved
node agents produce latency cliffs that look architectural but are not.
