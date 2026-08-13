+++
title = "Cluster Tuning and Limits"
date = 2026-06-11T09:00:00+02:00
weight = 4
+++

## Cluster tuning baseline

The published numbers are **not reproducible on stock component limits**. The table below lists
what was tuned and why.

| Component | Stock | Tuned | Why |
|---|---|---|---|
| ovn-central (deployment) | cpu 4 / mem 8 Gi | cpu 4 / mem 16 Gi | headroom for NB and SB database growth at high object counts. **The limit must never exceed control-plane node RAM**: an oversized limit lets ovn-central grow past physical memory, and the kernel then OOM-kills the control-plane node, apiserver and etcd included. 16 Gi is safe on 24 GiB control-plane nodes; scale the limit to your own nodes |
| ovn-central probes | timeout 45 s | timeout 300 s, failureThreshold 10 | database replay after a pod restart exceeds 45 s at high object counts, so the longer timeout prevents kubelet from killing pods mid-replay |
| kube-ovn-controller | cpu 2 / mem 4 Gi | cpu 8 / mem 8 Gi | workqueue drain at high object counts (runs on 251 GiB workers) |
| ovs-ovn (DaemonSet, every node) | cpu 2 / mem 1 Gi | cpu 4 / mem 8 Gi | each node's `ovn-controller` holds the **whole cluster's** logical-flow set; the 1 Gi stock limit OOM-killed it at about 7.7 k subnets, which was the real per-node datapath wall before the bump |
| kube-ovn-cni (DaemonSet) | mem 1 Gi | mem 2 Gi | headroom for pod-wiring churn at scale |
| kube-multus-ds (DaemonSet) | mem 256 Mi | mem 1 Gi | at the stock limit multus OOM-crash-looped (92 to 514 restarts over 102 days), which blocked **all** pod wiring on affected nodes and surfaced as a false 50-service ceiling |

## First binding factor per capability

| Resource | First binding factor |
|---|---|
| Network tenants (VPCs) | etcd database size (77 % of its danger line at 10 k; everything else below 50 %) |
| Subnets | network-controller programming throughput; before tuning, per-node `ovs-ovn` memory (1 Gi OOM at about 7.7 k) |
| Firewall policies | none observed up to 355 k ACLs cluster-wide (cap-bound) |
| Security groups | kube-ovn-controller stability (a concurrent-map data race at the 20 k-SG load, an upstream bug) |
| Services | pod-wiring throughput (every functional VIP needs a Ready backend pod) |
| Static routes | controller programming cadence (drift between requested and programmed) |
| Combined tenants (degradation) | per-VM datapath state (port binding, conntrack, and NAT); empty objects are nearly free |

## Interpretation caveats

- **Cap-bound versus wall-bound.** Cap-bound means the run reached its configured cap while
  healthy, so the value is a lower bound. Wall-bound means something real stopped it (named in the
  tables). Only security groups and static routes are wall-bound; every other number published here
  is cap-bound or window-bound.
- **Catch-up-window-bound numbers understate the ceiling.** The subnetsPerCluster figure of 11,822
  is where programming settled within a 3-hour window, not a wall. A longer window or a faster
  controller raises it.
- **Security groups carry an upstream-bug caveat.** The ceiling is a kube-ovn 1.14.30 stability
  bound, not an OVN capacity bound.
- **QoS policies and network-attachment templates have no standalone row by design.** Both are
  binding-triggered: a bare CR programs nothing until a pod or EIP references it, so a bare-object
  ceiling would measure only API storage, which is meaningless under the programmed-and-functional
  definition.
- **Static routes used the earlier methodology** (no functional verify, no catch-up settle).
- **One cluster shape.** All numbers come from the reference cluster listed in the
  [section overview]({{< ref "../../_index.en.md" >}}); the tuning baseline above is part of the
  result.
