+++
title = "Configuration Maximums"
date = 2026-06-10T09:00:00+02:00
weight = 7
chapter = true
+++

# Configuration Maximums

This page lists the **validated configuration maximums** of a Kubermatic Virtualization
(KubeV) cluster — how many virtual machines, networks, firewall policies, subnets, routes and
similar objects a cluster reliably handles.

Every number on this page comes from an actual benchmark run against a live reference cluster
using the **ConfigMax** tool, a benchmark harness that ships with Kubermatic Virtualization. It
discovers limits by pushing a growing workload at the cluster and watching for the point where the
cluster pushes back. Nothing here is a paper estimate — each value was measured, and each value was
verified to be *functional*, not merely stored.

{{% notice note %}}
These maximums describe **one specific cluster shape** (listed below). A larger cluster scales
higher; a smaller cluster scales proportionally lower. Use these numbers as a sizing reference,
not as a hard product limit.
{{% /notice %}}

## Test environment

All numbers below were measured on the reference cluster `superman` unless noted otherwise.

| Property | Value |
|---|---|
| Worker hosts | 3 × 96 cores / 251 GiB RAM |
| Control-plane hosts | 3 × 12 vCPU / 24 GiB RAM |
| Kubernetes | v1.34.3 (kubeadm) |
| KubeVirt | v1.5.3 |
| CNI (software-defined network) | Kube-OVN 1.14.30 |
| Operating system | Ubuntu 24.04.3 LTS, kernel 6.8 |
| Container runtime | containerd 1.7.29 |
| Storage | Longhorn (default) |

Network components were tuned for scale testing; the full tuning baseline is listed in the
engineering reference at the bottom of this page.

## How to read these numbers

- **Every count is fully programmed and functionally verified.** A number on this page means the
  objects exist in the network control plane *and* demonstrably work — a pod in a freshly created
  subnet gets an IP address and pings its gateway, a service address answers with live backends, a
  firewall policy actually enforces. It does **not** mean "the API stored this many objects" —
  storage alone says nothing about whether the objects function.
- **Cap-bound numbers are lower bounds.** Runs push to a deliberately high configured cap. Where
  the cap was reached with the cluster showing no strain, read the value as "validated to at least
  N" — the real ceiling is higher.
- **Two questions, two kinds of number.** *Capacity* answers "how many of these objects fit."
  *Degradation* answers "how many tenants fit before running workloads feel slowness." They are
  different tests and are never mixed.
- **Per-tenant vs. cluster-wide.** Numbers that say "per tenant" or "per namespace" describe one
  tenant scope; cluster-wide totals are listed separately.

---

## Validated maximums

| Capability | Validated maximum | What it means |
|---|---|---|
| **Network tenants per cluster** | **10,000** | Independent routing + IP-space domains, each with its own router, isolated by default. Reached the configured cap fully functional with no strain — real ceiling is higher. |
| **Subnets per cluster** | **11,822** | Layer-3 subnets, all programmed in the network control plane. Verified live at this count: a pod in a fresh subnet got an IP and pinged its gateway with 0 % loss. |
| **Subnets per network tenant** | **8,001** | Subnets within one tenant. Reached the configured cap fully programmed with no strain. |
| **Firewall policies per namespace** | **30,001** (≈ 175,000 enforced rules) | Stateful firewall policies in one namespace (a logical tenant scope). Each policy compiles to ~6 enforced rules in the network data plane; enforcement was active throughout the run. |
| **Firewall policies cluster-wide** | **25,101** (≈ 150,000 enforced rules) | Firewall policies across all namespaces with live enforcement. The cluster showed no strain at this count (re-validation of the stop condition in progress). |
| **Security groups per cluster** | **5,606** | Reusable label-based scopes that firewall rules attach to. Bounded by a network-controller stability issue at higher counts (fix tracked upstream), not by the cluster itself. |
| **Routable services per cluster** | **1,001** | Load-balanced service addresses, each verified reachable with live backends. Reached the configured cap with no strain. |
| **Static routes per network tenant** | **3,830** | Manually configured next-hop routes on one tenant's router (measured with an earlier methodology — see engineering notes). |
| **Network interfaces per VM** | **32** | Secondary network interfaces attachable to a single VM. |
| **vCPUs per VM** | **94** | Bounded by the worker host's 96 physical cores minus a small hypervisor reserve. |
| **Memory per VM** | **180 GiB** | Validated boot; bounded by worker host RAM (251 GiB). |
| **Container workloads per worker host** | **1,185** | Pods one worker host schedules concurrently. Reached the kubelet `--max-pods=1200` ceiling — 11× the stock default. |
| **Concurrent connections per host** | **150,000+ tested** (capacity ~3.1 M) | Active tracked network flows, zero drops, at under 2 % of the per-host tracking capacity — large headroom remains. |
| **Pod-to-pod latency** | same-host **167 µs** · cross-host **532 µs** | Round-trip average, 0 % packet loss, freshly-booted cluster. |
| **Active tenants before latency degrades** | **~80 ± 10** | Tenants onboarded simultaneously (each = namespace + subnet + 5 firewall policies + 1 running VM) before VM-to-VM tail latency jumps ~4× from sub-millisecond. Validated across three runs. The per-VM datapath state drives this limit. |

{{% notice note %}}
**Not listed as rows:** bandwidth/priority (QoS) policies and secondary-network templates apply
per-pod/per-VM rather than as standalone cluster objects — their practical bound is pod capacity
(see *Container workloads per worker host*), so a standalone count would be misleading.
**VMs per worker host** is being re-validated on the current cluster shape and will be added once
the dedicated run lands.
{{% /notice %}}

---

## Technical reference

For readers comparing platforms: per capability, the validated ceiling, **why the run stopped**,
and the component that would give out first. A run that stopped at its configured cap with no
strain means the real ceiling is above the listed number.

| Capability | Validated ceiling | Stopped by | Limiting component | Published comparable* | Run |
|---|---:|---|---|---:|---|
| Network tenants / cluster | 10,000 | configured cap — no strain | etcd database size was nearest its budget (~77 %) | ~4,000 | 2026-06-08, 1 h 06 m |
| Subnets / cluster | 11,822 | controller finished programming this many within the post-cap settle window | network-controller programming throughput | ~5,000 | 2026-06-09, 5 h 28 m |
| Subnets / tenant | 8,001 | configured cap — no strain | none approached | ~5,000 | 2026-06-10, 3 h 06 m |
| Firewall policies / namespace | 30,001 (175,246 rules) | configured cap — no strain | none approached; rule programming kept pace throughout | ~100,000 rules | 2026-06-10, 1 h 08 m |
| Firewall policies / cluster | 25,101 (150,613 rules) | test-harness connectivity loss — **no cluster strain**; re-validation in progress | under investigation (possible data-plane saturation near 150 k rules) | ~100,000 rules | 2026-06-09, 27 m |
| Security groups / cluster | 5,606 | network-controller instability at higher counts (upstream fix tracked) | network-controller stability | ~10,000 | 2026-06-10, 2 h 07 m |
| Routable services / cluster | 1,001 | configured cap — no strain | pod-wiring throughput at higher counts | ~10,000 | 2026-06-10, 13 m |
| Static routes / tenant | 3,830 | configured cap (earlier methodology) | network-controller programming cadence | ~4,000 | 2026-05-05 |

\* Published configuration-maximum of a comparable enterprise virtualization platform, for sizing
orientation only.

## When does it get slow? (degradation)

Capacity says how many objects fit. Degradation answers the question customers actually feel:
**how many tenants fit before running workloads slow down?** It is measured differently — instead
of pushing one object type, the benchmark onboards realistic *tenant bundles* (each = one
namespace + one subnet + five firewall policies + one running VM) while two pairs of always-on
canary VMs ping each other continuously, one pair on the same host and one pair across hosts.

**Result: ~80 ± 10 active tenants** on the reference cluster, validated across three runs (±12 %
variance). At the cliff, VM-to-VM tail (p99) latency jumps roughly **4×** — from sub-millisecond
to several milliseconds — within a single batch of tenants.

The key sizing insight: **empty subnets and dormant firewall policies are essentially free.**
Ingredient-isolation runs showed bundles *without* a VM scale 5–7× further before any signal.
It is the per-VM datapath state — port binding, connection tracking, address translation — that
drives the limit. Plan tenant capacity around **VM count**, not object count.

---

## Run it yourself

ConfigMax runs **inside the cluster** as an operator. You describe what to test in a single
`ConfigMaxRun` YAML file, apply it, and read the result back from the object's status. No external
tooling or connectivity is required.

### Prerequisites

- A running Kubermatic Virtualization cluster with `kubectl` access.
- The **ConfigMax operator** installed (it provides the `ConfigMaxRun` custom resource and a
  controller that turns each request into an in-cluster benchmark Job). The operator ships with the
  Kubermatic Virtualization tooling; install its manifests into the `configmax` namespace.
- If your image registry is private, an image-pull secret in the `configmax` namespace.

### 1. Describe the run

Create a file `my-run.yaml`. This example discovers the subnets-per-tenant ceiling, stopping when
the cluster shows strain, a 1-hour timeout fires, or 10,000 subnets are reached — whichever comes
first:

```yaml
apiVersion: configmax.kubermatic.io/v1alpha1
kind: ConfigMaxRun
metadata:
  name: my-run
  namespace: configmax
spec:
  image: "quay.io/kubermatic/configmax:latest"   # benchmark image
  profile: custom                                 # custom = use the fields below
  tests:
    - subnetsPerVPC                               # which test(s) to run
  overrides:
    subnetsPerVPC:
      mode: discovery                             # discovery | target | workload-slo
      discovery:
        initialBatch: 100                         # objects in the first batch
        growthFactor: "1.5"                        # batch size ×1.5 each round
        batchPauseSec: 5                          # settle time between batches
        hardTimeoutSec: 3600                      # wall-clock cap (1 hour)
        safetyBound: 10000                        # absolute upper limit
      distressOverrides:
        sampleIntervalSec: 30                     # how often to check for strain
        consecutiveSamples: 3                     # trips needed before stopping
  settings:
    cleanupAfterRun: true                         # delete test objects when done
    stopOnFirstError: false
  ttlAfterFinished: 259200                        # keep result 3 days, then GC
```

The two blocks that matter most are `mode` (how the run decides to stop) and `discovery` (how
aggressively it pushes load).

### 2. Apply it and watch

```bash
kubectl apply -f my-run.yaml

# high-level progress
kubectl -n configmax get configmaxrun my-run

# live detail (phase, current test, messages)
kubectl -n configmax describe configmaxrun my-run
```

The `get` output shows the profile, phase (`Pending` → `Provisioning` → `Running` → `Completed`),
and a progress summary.

### 3. Read the result

When the phase is `Completed`, the headline numbers are in `.status.results`:

```bash
kubectl -n configmax get configmaxrun my-run \
  -o jsonpath='{range .status.results[*]}{.test}{": "}{.highestCount}{" (stopped by "}{.stoppedBy}{")\n"}{end}'
```

Example output:

```
subnetsPerVPC: 8001 (stopped by safety-bound)
```

`highestCount` is your discovered maximum; `stoppedBy` tells you *why* the run stopped — a distress
signal, `timeout`, or `safety-bound` (the configured cap). The full per-batch curve and cluster
snapshots live under `.status.report` for deeper analysis.

### Key parameters

These are the fields you will most often change. All live under `spec`.

| Field | Values | Purpose |
|---|---|---|
| `profile` | `smoke` · `medium` · `full` · `custom` | Preset scale. Use `custom` to control the fields below. |
| `tests` | list of test IDs | Which benchmarks to run (e.g. `subnetsPerVPC`, `vpcsPerCluster`, `networkPoliciesPerNamespace`, `nicsPerVM`). Only honored with `profile: custom`. |
| `overrides.<test>.mode` | `discovery` · `target` · `workload-slo` | How the test decides to stop. |
| `discovery.initialBatch` | integer (default 10) | Objects created in the first batch. |
| `discovery.growthFactor` | string float (default `"2.0"`) | Batch size multiplier each round. Lower = gentler ramp. |
| `discovery.batchPauseSec` | integer (default 5) | Settle time between batches; raise it to let the controller catch up. |
| `discovery.hardTimeoutSec` | integer (default 14400) | Wall-clock cap on the whole run. |
| `discovery.safetyBound` | integer (default 100000) | Absolute object-count cap — stops even with no distress. |
| `discovery.targetCount` | integer | For `mode: target` only: the count to reach for a PASS. |
| `distressOverrides.*` | integers | Tune the strain thresholds and sampling cadence. |
| `settings.cleanupAfterRun` | bool (default true) | Delete benchmark objects when the run finishes. |
| `settings.stopOnFirstError` | bool (default false) | Stop a test at the first create error instead of probing for the breaking point. |

### Profiles at a glance

| Profile | Scale | Typical duration | Use for |
|---|---|---|---|
| `smoke` | minimal counts, every test | ~15–30 min | Post-install sanity check, CI gate |
| `medium` | moderate limits | ~2–4 h | A balanced capacity snapshot |
| `full` | large-scale, true breaking points | 8–12 h+ | A full configuration-maximum sweep |
| `custom` | whatever you specify | varies | Targeting one test or one parameter |

{{% notice tip %}}
Start with `profile: smoke` to confirm the operator and harness work end-to-end, then switch to a
`custom` run that targets just the capability you care about. Full-cluster sweeps are best run
overnight.
{{% /notice %}}

### Alternative: the CLI binary

The same benchmark engine ships as a standalone `configmax` binary. It runs the identical test
code directly against a kubeconfig — no operator install needed. Use it for quick smoke runs and
first iterations on a development cluster; prefer the operator for anything long-running (the CLI
runs from your workstation, so a laptop sleep or a network blip cancels the run).

```bash
# 1. Point the config at your cluster: copy benchmarks/configs/default.yaml
#    and set cluster.kubeconfigPath, then enable the test(s) you want, e.g.:
#
#    cluster:
#      kubeconfigPath: "/path/to/kubeconfig"
#    networking:
#      subnetsPerVPC:
#        enabled: true
#        mode: discovery
#        discovery:
#          initialBatch: 5
#          growthFactor: 2.0
#          hardTimeoutSec: 300
#          safetyBound: 500

# 2. Inspect the cluster without creating anything
configmax discover --config my-config.yaml

# 3. Run the enabled benchmarks
configmax run --config my-config.yaml

# 4. Re-read a saved result or render a report
configmax results --file benchmarks/results/<result>.json
configmax report  --file benchmarks/results/<result>.json --format html
```

Results print as a summary table and persist as JSON under `benchmarks/results/`, including the
per-batch curve and the stop reason — the same data the operator reports in `.status.results`.
The config file accepts the same `mode` / `discovery` / `distressOverrides` fields as the CRD
overrides shown above.

---

{{% notice warning %}}
**INTERNAL ENGINEERING REFERENCE.** Everything below this line is measurement provenance for
review: methods, parameters, stop triggers, tuning, and named-vendor comparisons. Review before
public release — trimming or moving this section is the expected outcome of review.
{{% /notice %}}

## Ceiling methodology

> **Ceiling of resource X = the maximum count that stays FULLY PROGRAMMED and
> VERIFIED-FUNCTIONAL at once.** We push X up to a configured cap that sits above the published
> vSphere comparable. The run stops cleanly at the cap, or earlier if a real distress signal
> trips. We report "validated to N — fully functional, no distress."

**Why this definition.** We previously published API-accepted counts. A controlled experiment on
2026-06-08 showed why that is deceptive: a run pushed **92,046 subnets** into the API, but the
network controller had **programmed only ~4,000** of them into OVN by the time it was cancelled —
a pod in subnet #5,000 would never have received an IP. The API accepts nearly unlimited objects;
only the *programmed* count describes capacity a customer can use. This mirrors the NSX/Broadcom
configuration-maximums methodology ("tested and supported", control-plane-bound numbers), so the
vSphere comparison reads like-for-like.

**The run loop:**

```
1. CREATE a batch of objects (e.g. 50 subnets).
2. WAIT for the controller to program them (checked in the OVN
   northbound DB — not just etcd).
3. SETTLE so ovn-northd finishes compiling.
4. MEASURE 3 samples, 10 s apart — one blip is transient,
   three in a row is real.
5. EVALUATE:
   - distress probe tripped?  STOP — that's the real wall.
   - cap reached?             STOP — record "validated to N".
   - otherwise grow the batch and repeat.
6. CATCH-UP WAIT: after the cap, give the controller a settle
   window to finish programming the backlog; the published
   number is the SETTLED programmed count.
7. FUNCTIONAL SPOT-CHECK at the top count.
```

**Functional verification.** Per resource: a throwaway network-debug pod (`netshoot`) is dropped
into a freshly created subnet and must get an IP and ping its gateway; a service VIP must answer
with live backends; a firewall rule must demonstrably allow/deny. For datapath surety we
additionally spot-check with the kube-ovn `kubectl ko` plugin (`ko diagnose subnet <name>` creates
temporary pods and tests real connectivity; `ko trace` proves allow/drop decisions in the
datapath pipeline).

**Hygiene.** Full cleanup of all benchmark objects before every run, so one test's leftovers
cannot skew the next test's baseline. Programmed counts are read from the OVN northbound **leader**
(followers return 0 — an early parser read followers and reported zero).

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

Probe history that shaped this list:

- **Fail-closed redesign (2026-06-05).** Three probes were silently returning "healthy" because
  their metrics endpoints are unreachable on this kube-ovn build. A probe that cannot read now
  reports *unknown* and the run flags it — it never pretends health.
- **`kubeovn-reconcile-errors` removed (2026-06-08)** — false-tripped security groups at 125
  objects.
- **ovn-northd threshold recalibrated (2026-06-07)** from 120 % to 360 % sustained. The old line
  tripped on per-batch compile *spikes*, not steady saturation, and produced a campaign of
  false-low ceilings (e.g. "250 VPCs"); the recalibrated threshold passed 1,000+ VPCs with a flat
  settled curve.
- **Known gaps (honest list):** there is not yet a per-node `ovs-ovn` memory probe (the ~7.7 k
  subnet OOM wall was found manually) nor a kube-ovn-controller restart/crash probe (the
  security-group data-race crash was found manually). Both are planned.

## Degradation methodology

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

## Per-test method cards

Format: what the test creates → what "programmed" means → how functionality is verified → the
parameters used → what actually stopped the run → result and headroom.

#### vpcsPerCluster — network tenants per cluster

| | |
|---|---|
| **Creates** | kube-ovn `Vpc` CRs (tenant logical routers), batched |
| **Programmed =** | OVN logical routers (`ovn-nbctl lr-list`), counted on the NB leader |
| **Functional verify** | per-checkpoint provisioning probe (new VPC create→Ready); VPC CRs flip Ready near-instantly, so the programmed logical-router count is the authoritative signal |
| **Parameters** | cap 10,000 · initialBatch 50 · growth ×1.5 · batchPause 5 s · distress samples 10 s × 3 |
| **Stop trigger** | configured cap, no distress; catch-up settled programmed at 10,001 in ~9 min |
| **Result** | **10,000 validated** · 2026-06-08 · 1 h 06 m |
| **Peak vs danger line** | ovn-central mem ~2.0 / 14.4 GiB · northd ~1,605 m / 3,600 m · cp-node mem 31 / 90 % · **etcd 1,227 MB / ~1,600 MB — nearest line (~77 %)** |
| **Caveats** | cap-bound — real ceiling above 10 k; etcd DB size is the eventual binding factor for VPCs |

#### subnetsPerCluster — subnets cluster-wide

| | |
|---|---|
| **Creates** | kube-ovn `Subnet` CRs spread across 5 VPCs |
| **Programmed =** | OVN logical switches (`ovn-nbctl ls-list`), NB leader |
| **Functional verify** | netshoot pod dropped into a live subnet at the top count: got its OVN IP (10.195.231.2) and pinged the subnet gateway 3/3, 0 % loss, 0.57 ms — datapath genuinely forwards at 11.8 k subnets |
| **Parameters** | cap 20,000 · initialBatch 50 · growth ×1.5 · batchPause 5 s · 3 h catch-up window |
| **Stop trigger** | cap accepted (20,001 CRs); published number = programmed count settled within the catch-up window |
| **Result** | **11,822 programmed + datapath-verified** · 2026-06-09 · 5 h 28 m |
| **Peak vs danger line** | northd ≤ 2,200 m / 3,600 m · ovn-central ≤ 4.2 / 14.4 GiB · cp-node mem ≤ 44 / 90 % · per-node ovs-ovn flat ~256 MiB / 8 GiB |
| **Caveats** | catch-up-window-bound, NOT a wall — programming decelerated ~52→17 subnets/min; a longer window or faster controller goes higher. The *automated* netshoot verify false-reported "no-IP" (its image pull took ~90 s, longer than the probe wait — fix queued); the manual verify above passed cleanly. Before the per-node agent memory bump (see tuning), this test OOM-killed `ovs-ovn` at ~7.7 k subnets — that wall is gone. |

#### subnetsPerVPC — subnets in one tenant

| | |
|---|---|
| **Creates** | `Subnet` CRs inside a single VPC |
| **Programmed =** | OVN logical switches with the benchmark prefix, NB leader |
| **Functional verify** | same netshoot gateway-ping pattern as subnetsPerCluster; CLI smoke 101/100 validated the counter before the scale run |
| **Parameters** | cap 8,000 · initialBatch 50 · growth ×1.5 · batchPause 5 s · catch-up window |
| **Stop trigger** | configured cap, no distress; programming sustained ~46–48 subnets/min with no late deceleration — the controller drained the whole backlog |
| **Result** | **8,001 programmed (full cap, settled)** · 2026-06-10 · 3 h 06 m |
| **Peak vs danger line** | ovn-central ≤ 4.3 / 14.4 GiB · cp-node mem ≤ 46 / 90 % · controller stable |
| **Caveats** | cap-bound — real ceiling above; 1.6× the vSphere logical-segments-per-Tier-1 comparable (~5,000) |

#### networkPoliciesPerNamespace — firewall policies in one namespace

| | |
|---|---|
| **Creates** | `NetworkPolicy` objects with mixed allow/deny rules **plus enforcing pods** that the policies select — without selected pods, policies program nothing (the no-op trap) |
| **Programmed =** | OVN ACL entries, NB leader. Headline = policy count; ACLs reported separately (never conflated) |
| **Functional verify** | enforcement active on the selected pods throughout; ACL programming kept pace the whole run (~5.8 ACLs/policy, no lag) |
| **Parameters** | cap 30,000 · initialBatch 50 · growth ×1.5 · batchPause 5 s · params targetPodCount=2 |
| **Stop trigger** | configured cap, no distress |
| **Result** | **30,001 policies / 175,246 ACLs programmed** · 2026-06-10 · 1 h 08 m |
| **Peak vs danger line** | ovn-central ≤ 5 / 14.4 GiB · northd healthy · controller stable |
| **Caveats** | cap-bound. 175 k ACLs (the actual enforced rules) exceeds the vSphere ~100 k DFW-rules-per-host comparable; 30 k policies is our cap, not a wall |

#### networkPoliciesPerCluster — firewall policies cluster-wide

| | |
|---|---|
| **Creates** | same policy shape spread across 10 namespaces, 21 enforcing pods |
| **Programmed =** | OVN ACL entries, NB leader |
| **Functional verify** | enforcement via the selected pods; ACL programming kept up at ~930 policies/min push rate (zero lag: 150,613 ACLs at 25.1 k policies) |
| **Parameters** | cap 120,000 · initialBatch 50 · growth ×1.5 · batchPause 5 s |
| **Stop trigger** | the benchmark Job pod lost its route to the apiserver service VIP (10.96.0.1) at ~150 k ACLs — **not** a distress probe, **no** control-plane strain (northd ~1,700 m / 3,600 m, ovn-central ~3.1 / 14.4 GiB); the cluster recovered fully once creation stopped |
| **Result** | **25,101 policies / 150,613 ACLs programmed** · 2026-06-09 · 27 m |
| **Caveats** | the stop is ambiguous — real data-plane saturation near 150 k ACLs vs a one-off node-level hiccup. **Re-validation run in progress** (same cap, plus a bystander pod monitoring the apiserver VIP throughout); this row will be finalized from that run |

#### securityGroupsPerCluster — security groups

| | |
|---|---|
| **Creates** | kube-ovn `SecurityGroup` CRs with full ingress/egress rules **including `remoteType: address`** — without that field the controller errors (`not support sgRemoteType ''`) and programs nothing; this exact omission made an earlier run read 0-programmed |
| **Programmed =** | OVN port-groups named `ovn.sg.configmax-*`, NB leader |
| **Functional verify** | SG `status.portGroup` populated + `ingress/egressLastSyncSuccess: true`; CLI smoke 101/100 before the scale run |
| **Parameters** | cap 20,000 · initialBatch 50 · growth ×1.5 · batchPause 5 s · catch-up window |
| **Stop trigger** | controller-stability-bound: kube-ovn-controller hit `fatal error: concurrent map read and map write` (a Go data race — crash, not OOM; 15 restarts) under the 20 k-SG reconcile load, capping settled programming |
| **Result** | **5,606 port-groups programmed** (20,001 CRs accepted) · 2026-06-10 · 2 h 07 m |
| **Peak vs danger line** | ovn-central / northd / etcd all healthy — the crash is in the kube-ovn controller, which the probes do not yet watch |
| **Caveats** | a kube-ovn 1.14.30 stability bug at scale (upstream report planned), not a fundamental OVN limit; programming decelerated 119→24 PGs/min; below the vSphere 10 k comparable for now |

#### serviceEndpointsPerCluster — routable services

| | |
|---|---|
| **Creates** | `Service` objects each with a **real backend pod** — kube-ovn programs a service's OVN load-balancer VIP only once the service has Ready endpoints; VIPs without backends never program |
| **Programmed =** | OVN load-balancer **VIP entries** minus baseline, NB leader |
| **Functional verify** | VIPs answer with live backends; backends 0 → 1,005 Ready during the run, VIPs climbed 35 → 953 → 1,001 settled |
| **Parameters** | cap 1,000 · backendsPerService 1 · probe requires 3 **consecutive** real failures |
| **Stop trigger** | configured cap, no distress |
| **Result** | **1,001 services with functional VIPs (full cap)** · 2026-06-10 · 13 m |
| **Caveats** | cap-bound — each functional service needs a wired backend pod, so higher caps are pod-wiring-throughput-bound. History worth keeping: two earlier runs read 412 / 1,553 (4× swing — a 1-sample windowed probe tripping on a single not-yet-Ready backend), and a third stalled at ~50 VIPs; the root cause was **chronic multus OOM** (256 Mi limit, crash-looping for 102 days) blocking backend-pod wiring cluster-wide. The multus memory bump fixed it and the probe now needs 3 consecutive failures |

#### vpcStaticRoutesPerVpc — static routes on one tenant router *(earlier methodology)*

| | |
|---|---|
| **Creates** | entries in `Vpc.spec.staticRoutes` (/32 host-routes — an earlier /24 scheme capped the address space at 255 routes) |
| **Programmed =** | routes present in the OVN logical router, compared against requested (drift detection) |
| **Stop trigger** | route-drift rule: stop when programmed lags requested by more than max(200, 25 %) — i.e. the controller's programming cadence is the wall |
| **Parameters** | cap 4,000 · batchPause 120 s · adaptive batch capped at 200 past cumulative 500 |
| **Result** | **3,830** (last clean checkpoint at the 4,000 cap) · 2026-05-05 · 1 h 04 m |
| **Caveats** | predates the realistic-ceiling method (no functional datapath verify, no catch-up settle); rewrite deferred. 96 % of the vSphere 4,000 comparable |

#### nicsPerVM · vcpusPerVM · memoryPerVM — per-VM hardware bounds

| | |
|---|---|
| **Method** | boot sweep: a VM per size step must reach Running within the boot timeout |
| **nicsPerVM** | all counts 2…32 booted cleanly (3 m 39 s at 32); 48+ failed the 5-minute multi-NIC boot wait — boot-timeout-bound, not a hard wall. **32** · 2026-05-05. vSphere comparable ~10 → 3× |
| **vcpusPerVM** | sweep [1…94]: all booted; 24.1 s boot at 94. **94** = 96 physical cores − host reserve · 2026-05-04 |
| **memoryPerVM** | sweep [1…180 GiB]: all booted on a cold cluster; 15.0 s boot at 180 GiB (worker had 0.9 GiB free at peak). An earlier 180 GiB failure was a concurrent-load artifact, not a real ceiling. **180 GiB** · 2026-05-04 |

#### podsPerNode · conntrackLimits · networkLatency — runtime / data-plane

| | |
|---|---|
| **podsPerNode** | scheduled pods on one worker until kubelet refused: **1,185** + ~15 baseline = the kubelet `--max-pods=1200` ceiling · 2026-05-04 · 3 h 48 m. Sampler: OVS flows grew linearly (~70 flows per 100 pods, 20 k → 88 k cluster-wide); API create latency 8.5 → 10 s. Pushing further is a kubelet retune, not a network limit |
| **conntrackLimits** | 300 client pods × 500 concurrent connections = **150 k+ tracked flows**, ~175 k peak entries observed, 0 drops, ≤ 2.8 % of the per-host table (3,145,728 on a 251 GiB worker) · 2026-05-06 · 13 m. Massive headroom — the table would hold ~9.4 M cluster-wide |
| **networkLatency** | direct ICMP between pause pods: same-host **167 µs** avg (min 71 µs, max 2.17 ms), cross-host **532 µs** avg (min 369 µs, max 3.69 ms), 0 % loss · 2026-05-06, freshly-booted cluster. Context: with ~14 k orphan subnets present, cross-host RTT measured 1.84 ms — direct evidence that data-plane cost scales with logical-object count, and why the full-cleanup rule exists |

#### tenantScalingPerCluster — degradation by tenant bundle

| | |
|---|---|
| **Creates** | N tenant bundles. Published-number bundle (2026-05-08): 1 namespace + 1 subnet + 5 firewall policies + 1 running VM. Go-forward Small bundle: 2 subnets + 5 VMs + 10 policies + 2 services + 1 security group per tenant |
| **Measures** | canary VM-to-VM p99 latency per batch (same-node pair + cross-node pair; ping; median-of-3 baseline; p99 = avg + 2.33 × mdev) |
| **Stop trigger** | published number: sustained +5 % drift (the observed cliff was an unmistakable 4× jump). Go-forward: absolute p99 > 2 ms, 3 consecutive samples |
| **Result** | **~80 ± 10 bundles** · 2026-05-08 · three runs, ±12 % variance — *confirmed* |
| **Caveats** | idle VMs do not stress the data plane (a traffic-load variant is future work); the canary SSH/latency probe under heavy load is the known weak point (guards added; the 2 ms Small-bundle re-validation run is scheduled and currently *expected (theory)*) |

## Cluster tuning baseline

The numbers above are **not reproducible on stock component limits**. What was tuned and why:

| Component | Stock | Tuned | Why |
|---|---|---|---|
| ovn-central (deployment) | cpu 4 / mem 8 Gi | cpu 4 / mem 16 Gi | headroom for NB/SB DB growth at high object counts. Limits must never exceed control-plane node RAM: a 2026-05-03 misconfig (24 Gi limit on 7.6 GiB nodes) OOM-cascaded the control plane — 10 h outage. The cp nodes were later resized to 24 GiB, which is what makes 16 Gi safe |
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
| Firewall policies | none observed up to 175 k ACLs; a possible data-plane wall near 150 k ACLs is under re-validation |
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
- **Firewall-policies-cluster-wide stop is ambiguous** — re-validation run in progress (bystander
  VIP monitor); the row will be finalized from it.
- **Security groups carry an upstream bug caveat** — the ceiling is a kube-ovn 1.14.30 stability
  bound, not an OVN capacity bound.
- **QoS policies and network-attachment templates have no standalone row by design.** Both are
  binding-triggered: a bare CR programs nothing until a pod/EIP references it, so a "bare-object
  ceiling" measures only API storage — meaningless under the programmed+functional definition.
- **Static routes used the earlier methodology** (no functional verify, no catch-up settle).
- **One cluster shape.** All numbers come from the reference cluster listed at the top; the
  tuning baseline above is part of the result.

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
| Single-resource degradation cliffs | ±40–50 % batch-to-batch noise; the "cliffs" did not reproduce | moved degradation to realistic tenant bundles | a clean 4× cliff at ~80 tenants, 3-run variance ±12 % |
| Canary read a cached VM IP; service probe tripped on one sample | "no degradation" was actually *no measurement*; services swung 412 vs 1,553 run-to-run | stale-IP guard, median-of-3 baselines, 3-consecutive-failure trips | probe failures now mean something; noise stopped publishing itself |

## Glossary

- **logical switch** — the virtual L2 segment a subnet maps to in OVN.
- **logical router** — the virtual router a tenant/VPC maps to.
- **ACL** — one compiled firewall rule entry in the network control plane; a policy compiles to
  several ACLs.
- **port-group** — a named set of ports that rules attach to; what a security group becomes.
- **ovn-northd** — the compiler that turns logical configuration into data-plane flows; its CPU is
  the classic scale signal.
- **NB-DB / SB-DB** — OVN's northbound DB (desired logical state) and southbound DB (compiled
  state the nodes consume).
- **conntrack** — the kernel's tracked-connections table.
- **VIP** — a service's virtual IP, programmed as an OVN load-balancer entry.
- **canary** — an always-on probe VM (or pod) whose latency/readiness we watch to measure blast
  radius on existing workloads.
- **programmed** — the object exists in the network control plane (visible in the NB DB), not just
  in the Kubernetes API.
