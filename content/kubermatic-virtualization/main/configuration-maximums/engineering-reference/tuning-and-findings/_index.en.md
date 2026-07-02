+++
title = "Tuning and Findings"
date = 2026-06-11T09:00:00+02:00
weight = 4
+++

## Cluster tuning baseline

The published numbers are **not reproducible on stock component limits**. What was tuned and why:

| Component | Stock | Tuned | Why |
|---|---|---|---|
| ovn-central (deployment) | cpu 4 / mem 8 Gi | cpu 4 / mem 16 Gi | headroom for NB/SB DB growth at high object counts. **Limits must never exceed control-plane node RAM** — an over-sized limit lets ovn-central grow past physical memory and the kernel OOM-kills the control-plane node (apiserver and etcd included). 16 Gi is safe on 24 GiB control-plane nodes; scale the limit to your nodes |
| ovn-central probes | timeout 45 s | timeout 300 s, failureThreshold 10 | DB replay after a pod restart exceeds 45 s at high object counts — prevents kubelet killing pods mid-replay |
| kube-ovn-controller | cpu 2 / mem 4 Gi | cpu 8 / mem 8 Gi | workqueue drain at high object counts (runs on 251 GiB workers) |
| ovs-ovn (DaemonSet, every node) | cpu 2 / mem 1 Gi | cpu 4 / mem 8 Gi | each node's `ovn-controller` holds the **whole cluster's** logical-flow set; the 1 Gi stock limit OOM-killed it at ~7.7 k subnets — the real per-node datapath wall before the bump |
| kube-ovn-cni (DaemonSet) | mem 1 Gi | mem 2 Gi | pod-wiring churn headroom at scale |
| kube-multus-ds (DaemonSet) | mem 256 Mi | mem 1 Gi | chronic OOM-crashloop (92–514 restarts over 102 days) blocked **all** pod wiring on affected nodes — surfaced as a fake 50-service ceiling |

## Bottleneck register — what breaks first

| Resource | First binding factor |
|---|---|
| Network tenants (VPCs) | etcd DB size (77 % of its danger line at 10 k; everything else < 50 %) |
| Subnets | network-controller programming throughput; before tuning, per-node `ovs-ovn` memory (1 Gi OOM at ~7.7 k) |
| Firewall policies | none observed up to 355 k ACLs cluster-wide (cap-bound) |
| Security groups | kube-ovn-controller stability (concurrent-map data race at 20 k-SG load — upstream bug) |
| Services | pod-wiring throughput (every functional VIP needs a Ready backend pod) |
| Static routes | controller programming cadence (drift between requested and programmed) |
| Combined tenants (degradation) | per-VM datapath state — port binding, conntrack, NAT; empty objects are nearly free |

## Caveats register

- **Cap-bound vs wall-bound.** Cap-bound = the run hit its configured cap healthy; the value is a
  lower bound. Wall-bound = something real stopped it (named in the tables). Only security groups
  and static routes are wall-bound; everything else published here is cap- or window-bound.
- **Catch-up-window-bound numbers understate.** subnetsPerCluster's 11,822 is where programming
  settled within a 3 h window — not a wall. A longer window or a faster controller raises it.
- **Security groups carry an upstream bug caveat** — the ceiling is a kube-ovn 1.14.30 stability
  bound, not an OVN capacity bound.
- **QoS policies and network-attachment templates have no standalone row by design.** Both are
  binding-triggered: a bare CR programs nothing until a pod/EIP references it, so a "bare-object
  ceiling" measures only API storage — meaningless under the programmed+functional definition.
- **Static routes used the earlier methodology** (no functional verify, no catch-up settle).
- **One cluster shape.** All numbers come from the reference cluster listed in the
  [section overview]({{< ref "../../_index.en.md" >}}); the tuning baseline above is part of the result.

## How we got here — findings and fixes

| What we did first | What we found | What we changed | Improvement |
|---|---|---|---|
| Counted API-accepted objects as the maximum | 92,046 subnets accepted, only ~4,000 programmed — pods past #4,000 would never get an IP | redefined ceiling: fully programmed + functionally verified | numbers became defensible ("tested + supported", not "etcd stored it") |
| Treated provisioning-latency rise as the ceiling | a subnet run false-stopped at 412 while the cluster was healthy | latency became observability-only; degradation is a separate table | the same test then validated 11,822 subnets |
| Ran with stock `ovs-ovn` (1 Gi) | per-node OOM at ~7.7 k subnets — each node's agent holds the whole cluster's flow set | bumped ovs-ovn 1 → 8 Gi (safe after the cp-node resize) | subnet ceiling 6,807 → 11,822 (1.74×), datapath-verified |
| Trusted multus defaults (256 Mi) | chronic OOM-crashloop for 102 days silently blocked pod wiring → services stalled at ~50 VIPs | bumped multus to 1 Gi | services 50 → 1,001 (full cap); fixed cluster-wide pod wiring |
| Security-group rules without `remoteType` | the controller errored per-SG; 20 k CRs accepted, 0 programmed | added `remoteType: address` to every rule | 0 → 5,606 programmed; also exposed an upstream controller data race at 20 k |
| Static routes as /24 networks | the address scheme capped at 255 routes | switched to /32 host-routes | 150 → 3,830 (25×) |
| Firewall probe on a port no rule allowed | 100 % apparent enforcement failure at tiny counts | added the probe port to every policy's allow-list | false ceiling removed; the real enforcement ceiling became measurable |
| Probes that could not reach their metrics endpoint reported "healthy" | three blind probes silently vouched for the cluster | fail-closed: an unreadable probe reports *unknown* | no more false confidence; one invalid probe removed entirely |
| northd CPU trip at 120 % of a core | it tripped on compile spikes — a whole campaign of ceilings was false-low (e.g. "250 VPCs") | recalibrated to 360 % sustained | the same test then passed 1,000+ VPCs with a flat settled curve |
| Single-resource degradation cliffs | ±40–50 % batch-to-batch noise; the "cliffs" did not reproduce | moved degradation to realistic tenant bundles | a clean, reproducible bundle-level signal |
| Tenant-scale latency cliff with memory-starved node agents | per-node networking agents under default limits (crash-looping multus, 1 Gi per-node OVN agent) produced a 4× latency cliff at ~80 tenants that looked architectural | resourced the agents per the tuning baseline; firewall policies made to actually enforce | flat latency through 120 tenants / 600 VMs — the cliff was infrastructure starvation, not a platform limit |
| Canary read a cached VM IP; service probe tripped on one sample | "no degradation" was actually *no measurement*; services swung 412 vs 1,553 run-to-run | stale-IP guard, median-of-3 baselines, 3-consecutive-failure trips | probe failures now mean something; noise stopped publishing itself |
| A cluster-wide policy run died mid-push with the cluster healthy | the benchmark pod itself had lost its network — the harness was the victim, not the cluster | re-ran with an independent bystander pod probing the cluster's API virtual IP every 10 s | 25,101 → 120,001 policies (full cap; zero probe failures in ~4 h) |
