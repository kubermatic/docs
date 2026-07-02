+++
title = "Ceiling Methodology"
date = 2026-06-11T09:00:00+02:00
weight = 1
+++

> **Ceiling of resource X = the maximum count that stays FULLY PROGRAMMED and
> VERIFIED-FUNCTIONAL at once.** We push X up to a configured cap that sits above the published
> vSphere comparable. The run stops cleanly at the cap, or earlier if a real distress signal
> trips. We report "validated to N — fully functional, no distress."

**Why this definition.** API-accepted counts are deceptive: the API accepts nearly unlimited
objects, while the network controller programs them into OVN far more slowly. In a controlled
measurement, **92,046 subnets** were accepted by the API while only **~4,000** of them were
programmed — a pod in subnet #5,000 would never have received an IP. Only the *programmed* count
describes capacity a customer can use. This mirrors the NSX/Broadcom configuration-maximums
methodology ("tested and supported", control-plane-bound numbers), so the vSphere comparison
reads like-for-like.

**The run loop:**

![Ceiling-test run loop](./assets/ceiling-test-run-loop.png)

**Functional verification.** Per resource: a throwaway network-debug pod (`netshoot`) is dropped
into a freshly created subnet and must get an IP and ping its gateway; a service VIP must answer
with live backends; a firewall rule must demonstrably allow/deny. For datapath surety we
additionally spot-check with the kube-ovn `kubectl ko` plugin (`ko diagnose subnet <name>` creates
temporary pods and tests real connectivity; `ko trace` proves allow/drop decisions in the
datapath pipeline).

**Hygiene.** Full cleanup of all benchmark objects before every run, so one test's leftovers
cannot skew the next test's baseline. Programmed counts are read from the OVN northbound
**leader** (followers return 0).

## Distress probes

A run stops early only on **real** resource distress, sustained for **3 consecutive samples**
taken 10 s apart:

| Signal | Danger line | What exceeding it means |
|---|---|---|
| etcd DB size | 80 % of quota (2 GiB → ~1.6 GB) | at 100 % etcd goes read-only → cluster-wide write outage |
| ovn-central memory | 85 % of limit (16 GiB → ~14.4 GiB) | OOM-kill → southbound-DB replay → minutes of network-control-plane disruption |
| Control-plane node memory | 90 % | kernel OOM-kills pods (apiserver risk) |
| ovn-northd CPU | 360 % of one core, sustained | steady compile saturation — new-workload programming lags |
| Southbound-DB size | watched for services runs | OVN load-balancer table growth |
| ovs-ovn memory (worst pod per node) | 80 % of the DaemonSet limit (8 GiB → ~6.6 GiB) | each node's `ovn-controller` holds the whole cluster's logical-flow set; an OOM-kill here is a per-node datapath wall — no pod on that node can wire until it recovers |
| kube-ovn-controller restarts | ≥ 1 new restart above the run-start baseline | the controller crashed or was killed mid-run — programming throughput from that run is no longer trustworthy (a Go data race at 20 k security groups produced exactly this) |

Probe design notes:

- **Fail-closed.** A probe that cannot read its metric reports *unknown* and the run flags it —
  it never pretends health.
- **Sustained, not spiky.** The ovn-northd CPU threshold targets steady compile saturation;
  per-batch compile *spikes* are expected and are judged only at the settled batch boundary, so a
  transient spike cannot end a run.
- **Restart baseline.** The kube-ovn-controller restart probe baselines pre-existing restart
  counts at run start and trips only on *new* restarts, so leftover counts from past incidents on
  a live cluster never trip a run.
- **Tunable.** Every threshold can be overridden per run via `distressOverrides` (e.g.
  `ovsOvnMemoryPct`, `kubeovnControllerRestarts`, `ovnCentralMemoryPct`).
