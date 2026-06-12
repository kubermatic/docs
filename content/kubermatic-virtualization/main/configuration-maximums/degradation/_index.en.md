+++
title = "Degradation — When Does It Get Slow?"
date = 2026-06-12T09:00:00+02:00
weight = 2
+++

Capacity says how many objects fit. Degradation answers the question customers actually feel:
**how many tenants fit before running workloads slow down?** It is measured differently — instead
of pushing one object type, the benchmark onboards realistic *tenant bundles* (each = one
namespace + two subnets + ten enforcing firewall policies + two services + one security group
+ five running VMs) while two pairs of always-on canary VMs measure VM-to-VM latency at every
settled batch, one pair on the same host and one pair across hosts.

**Result: no degradation through 120 tenants — 600 running VMs — the full extent of the run.**
Tail (p99) VM-to-VM latency stayed flat from the first tenant to the last:

| Stage | Active tenants | Cross-host p99 latency | Same-host p99 latency |
|---|---:|---|---|
| Baseline — no tenant workload | 0 | **430 µs** | **281 µs** |
| Entire run — every batch of five tenants measured | 5 – 120 | **406 – 488 µs** (worst +13 % over baseline) | **276 – 324 µs** |

Every batch boundary produced a valid measurement (the probe is required to deliver data —
a run with measurement gaps is discarded, never reported as "no degradation"). The run ended at
its configured tenant cap, not at a limit: **the degradation point sits above 120 tenants of
this shape**.

Two sizing insights for capacity planning:

- **The first practical wall is usually the resource allocation of per-node networking
  components, not the platform architecture.** Under-provisioned per-node networking agents
  degrade tenant networking long before any architectural limit; size those agents generously
  (see the tuning baseline in the engineering reference) and the tenant ceiling moves
  dramatically.
- **VM count drives datapath load.** Empty subnets and policies without attached workloads are
  essentially free; it is per-VM datapath state — port binding, connection tracking, address
  translation — that costs. Plan tenant capacity around running VM count, not object count.

Numbers on this page are measured on the reference cluster described in the engineering
reference. Your cluster's baseline and degradation point WILL differ — the benchmark ships with
the product (operator + CRD), so the most reliable way to get your number is to run it on your
own cluster.

How this is measured — canary topology and the dual stop rule — is documented in the
[degradation methodology]({{< ref "../engineering-reference/degradation-methodology" >}}).
