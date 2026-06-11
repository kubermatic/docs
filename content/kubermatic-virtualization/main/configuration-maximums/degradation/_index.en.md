+++
title = "Degradation — When Does It Get Slow?"
date = 2026-06-11T09:00:00+02:00
weight = 2
+++

Capacity says how many objects fit. Degradation answers the question customers actually feel:
**how many tenants fit before running workloads slow down?** It is measured differently — instead
of pushing one object type, the benchmark onboards realistic *tenant bundles* (each = one
namespace + one subnet + five firewall policies + one running VM) while two pairs of always-on
canary VMs ping each other continuously, one pair on the same host and one pair across hosts.

**Result: ~80 ± 10 active tenants** on the reference cluster, validated across three runs (±12 %
variance). The measured cross-host VM-to-VM tail (p99) latency, step by step:

| Stage | Active tenants | Cross-host p99 latency | Same-host p99 latency |
|---|---:|---|---|
| Baseline — empty cluster, no tenant workload | 0 | **~0.8 ms** | not recorded in this run |
| Steady — tenants onboarding, latency flat | 10 – 70 | **1.5 – 1.75 ms** | **1.4 – 1.5 ms** |
| Cliff — the jump happens within one batch of ten | **80** | **6.9 ms** | **2.4 ms** |
| Degraded — every batch after the cliff | 90 – 120 | **3 – 8 ms** (worst observed ~8.4 ms) | **6 – 7.6 ms** |

Cross-host traffic feels the cliff first (it crosses the shared datapath); same-host latency
follows one batch later, reaching 7.2 ms at 90 tenants. The two repeat runs reproduced the same
shape: both hit the cliff at **90 tenants** (one jumping 1.57 ms → 6.7 ms cross-host with
same-host rising 1.6 ms → 5.3 ms, the other settling ~3.5 ms sustained). A reproducible ~4×
degradation at ~80–90 tenants — not a one-off spike.

The key sizing insight: **empty subnets and dormant firewall policies are essentially free.**
Ingredient-isolation runs showed bundles *without* a VM scale 5–7× further before any signal.
It is the per-VM datapath state — port binding, connection tracking, address translation — that
drives the limit. Plan tenant capacity around **VM count**, not object count.

How this is measured — canary topology, thresholds, and the provenance of the published number —
is documented in the
[degradation methodology]({{< ref "../engineering-reference/degradation-methodology" >}}).
