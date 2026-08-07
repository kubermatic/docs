+++
title = "Degradation Under Tenant Load"
date = 2026-06-12T09:00:00+02:00
weight = 2
+++

Capacity describes how many objects fit. Degradation addresses a different question: how many
tenants a cluster can carry before running workloads begin to slow down. It is measured
differently from capacity. Instead of pushing a single object type, the benchmark onboards
realistic *tenant bundles* (each one namespace,
two subnets, ten enforcing firewall policies, two services, one security group, and five running
VMs) while two pairs of always-on canary VMs measure VM-to-VM latency at every settled batch, one
pair on the same host and one pair across hosts.

**Result: no degradation through 120 tenants (600 running VMs), the full extent of the run.**
Tail (p99) VM-to-VM latency stayed flat from the first tenant to the last:

| Stage | Active tenants | Cross-host p99 latency | Same-host p99 latency |
|---|---:|---|---|
| Baseline (no tenant workload) | 0 | **430 µs** | **281 µs** |
| Entire run (every batch of five tenants measured) | 5 to 120 | **406 to 488 µs** (worst +13 % over baseline) | **276 to 324 µs** |

Every batch boundary produced a valid measurement (the probe is required to deliver data, and a
run with measurement gaps is discarded, never reported as "no degradation"). The run ended at its
configured tenant cap, not at a limit: **the degradation point sits above 120 tenants of this
shape**.

Two sizing insights for capacity planning:

- **The first practical wall is usually the resource allocation of per-node networking
  components, not the platform architecture.** Under-provisioned per-node networking agents
  degrade tenant networking long before any architectural limit; size those agents generously and
  the tenant ceiling rises substantially.
- **VM count drives datapath load.** Empty subnets and policies without attached workloads are
  essentially free; it is per-VM datapath state (port binding, connection tracking, and address
  translation) that costs. Plan tenant capacity around running VM count, not object count.

Numbers on this page were measured on the reference cluster described in the
[section overview]({{< ref "../_index.en.md" >}}). Your cluster's baseline and degradation point
will differ, so the most reliable way to obtain your own figures is to run the benchmark, which
ships with the product, on your own cluster.
