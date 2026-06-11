+++
title = "Degradation Methodology"
date = 2026-06-11T09:00:00+02:00
weight = 2
+++

**Why bundles, not single resources.** Single-resource degradation cliffs ("~7,000 VPCs",
"~13,000 firewall policies") did not survive careful re-measurement: refined re-runs (2026-05-11,
median-of-3 baselines + statistical p99) showed batch-to-batch drift of ±40–50 % swamping any
signal — the "cliffs" were noise. Bundles of resources with a **running VM** produced a clean,
reproducible 4× cliff, because a VM creates real datapath state (port binding, conntrack, NAT)
while empty subnets and dormant policies cost almost nothing.

**Canary topology.** Two always-on probe pairs: a same-node VM pair and a cross-node pair (a
cross-VPC variant exists — traffic crosses the OVN datapath, conntrack and the VPC peering, the
closest match to real multi-tenant traffic).

**Measurement.** VM-to-VM **p99** latency per batch (p99 catches worst-case stutters that an
average hides). Ping-based; baseline = median of 3 runs (outlier rejection); p99 estimated as
`avg + 2.33 × mdev` so a single lost packet cannot fake a cliff.

**Thresholds:**

| Threshold | Type | Meaning |
|---|---|---|
| Warning | baseline +50 % p99, 3 consecutive samples | engineering early-warning — recorded, does not stop |
| SLO breach | p99 > **2 ms**, 3 consecutive samples | customer-facing stop — the published degradation number |

Why 2 ms: a typical app makes many network round-trips per user operation (a DB query can be
10–100 hops). At 2 ms per hop that is 20–200 ms per operation — a delay a customer feels. On this
cluster the healthy cross-node baseline is ~500 µs, so 2 ms ≈ 4× baseline. An engineering pick,
not a sacred constant — a real customer SLA would replace it. All capacity distress probes stay
active during degradation runs as a safety net; if capacity gives out before latency, the
published answer becomes "the cluster ran out of capacity before customers felt slowness."

**Provenance of the published ~80 ± 10.** Confirmed on the reference cluster, 2026-05-08, three
runs (trip at 90 / 120 / 140 bundles; the underlying cliff sits at ~80–90 in each trace; variance
±12 %). Bundle = 1 namespace + 1 subnet + 5 firewall policies + 1 running VM; the trip criterion
was sustained +5 % drift over baseline, and the observed cliff was a 4× p99 jump within one batch.
Ingredient isolation (same date): bundles *without* the VM tripped only at 550–575
(noise-bound — essentially free); bundles with **5 VMs** each tripped at 70 bundles (~350 VMs,
cliff ~40) — VM density dominates. The go-forward method (Small bundle: 2 subnets / 5 VMs /
10 firewall policies / 2 services / 1 security group per tenant; absolute 2 ms p99 SLO) is
defined and scheduled — **expected (theory)** until that run lands; ~80 ± 10 remains the
published, **confirmed** number.
