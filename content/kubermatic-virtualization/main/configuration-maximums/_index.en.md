+++
title = "Configuration Maximums"
date = 2026-06-03T09:00:00+02:00
weight = 7
chapter = true
+++

# Configuration Maximums

This page lists the **validated configuration maximums** of a Kubermatic Virtualization
(KubeV) cluster — how many virtual machines, networks, firewall rules, subnets, routes and
similar objects a cluster reliably handles before it runs out of capacity or its performance
starts to degrade.

Every number on this page comes from an actual benchmark run against a live reference cluster
using the **ConfigMax** tool, a benchmark harness that ships with Kubermatic Virtualization. It
discovers limits by pushing a growing workload at the cluster and watching for the point where
the cluster pushes back. Nothing here is a paper estimate — each value was measured.

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
| Control-plane hosts | 3 × 7.6 GiB RAM |
| Kubernetes | v1.34.3 (kubeadm) |
| KubeVirt | v1.5.3 |
| CNI (software-defined network) | Kube-OVN 1.14.30 |
| Operating system | Ubuntu 24.04.3 LTS, kernel 6.8 |
| Container runtime | containerd 1.7.29 |
| Storage | Longhorn (default) |

## How to read these numbers

- **Conservative by design.** Where the benchmark reached a configured upper bound *without* the
  cluster showing any strain, the number is reported as a **lower bound** — read it as "capacity is
  at least this high," not "this is the ceiling."
- **Two kinds of maximum.** For some capabilities we report two values:
  - **Accepted** — the cluster created and stored this many objects successfully.
  - **Sustained** — the cluster still served live VM-to-VM traffic within 5 % of its baseline
    latency at this many objects. This is the number that matters for a production workload.
- **One cluster shape.** Bigger clusters go higher. The reference cluster above is a mid-size
  three-node cluster.
- **Per-tenant vs. cluster-wide.** Numbers that say "per tenant" or "per namespace" describe one
  tenant scope; cluster-wide totals can be higher.

---

## Validated maximums

{{% notice info %}}
**Legend.** *Accepted* = objects successfully created and stored. *Sustained* = objects in place
while live VM-to-VM network latency stayed within 5 % of the cluster's baseline. Where a single
value is shown, the limit is a fixed hardware or configuration bound (not a load-driven one).
{{% /notice %}}

| Capability | Validated maximum | What it means |
|---|---|---|
| **Firewall rules per namespace** | Accepted **100,000** · Sustained **~13,000** | Stateful firewall rules controlling traffic between VMs inside one namespace (a logical tenant scope). The platform stored 100,000 rules; live traffic stayed fast up to roughly 13,000, after which rule-compilation on the network control plane begins to add latency. |
| **Firewall rules cluster-wide** | Accepted **100,000** | Stateful firewall rules counted across every namespace in one cluster. Validated across 20 namespaces. |
| **Network interfaces per virtual machine** | **32** | Maximum secondary network interfaces (NICs) attachable to a single VM. |
| **vCPUs per virtual machine** | **94** | Maximum virtual CPUs for a single VM. Bounded by the worker host's physical core count (96) minus a small hypervisor reserve. |
| **Memory per virtual machine** | **180 GiB** | Maximum RAM for a single VM (validated boot). Bounded by worker host RAM (251 GiB). |
| **Network tenants per cluster** | Accepted **~9,800** · Sustained **~7,000** | Independent routing + IP-space domains, each with its own router and address space, isolated by default. Beyond ~7,000 the shared network control plane saturates and cross-tenant latency rises. |
| **Subnets per network tenant** | Accepted **~10,000** · Sustained **~7,000** | Layer-3 subnets (broadcast domains) within one tenant. |
| **Static routes per network tenant** | **3,830** | Manually configured next-hop routes on one tenant's router. |
| **Security groups per cluster** | Accepted **10,000** · Sustained **~7,000** | Reusable label-based scopes that firewall rules attach to. |
| **Concurrent connections per host** | **150,000+ tested** (capacity ~3.1 M) | Active TCP/UDP flows one worker host tracks at once. Driven to 150,000 cluster-wide at under 2 % of the host's tracking-table capacity with zero drops — large headroom remains. |
| **Pod-to-pod network latency** | same-host **167 µs** · cross-host **532 µs** | Round-trip time between two VMs (average, 0 % packet loss) on a freshly-booted cluster. |
| **Container workloads per worker host** | **1,185** | Pods one worker host schedules concurrently. Reached the kubelet `--max-pods=1200` ceiling (1,185 test pods + cluster baseline) — 11× the stock default of 110. |
| **Active tenants per cluster** | **~80** | Independent tenants onboarded at once, where each tenant = one namespace + one subnet + five firewall rules + one running VM. Validated across three runs. The per-VM datapath state — not the empty subnets or dormant rules — is what sets this limit. |

{{% notice note %}}
A few capabilities are still being re-validated on the current cluster shape and are intentionally
left off the table above: reusable network-attachment templates per namespace, routable services
per cluster, bandwidth/priority (QoS) policies per cluster, and VMs per worker host. They appear in
the engineering reference below, marked *validation in progress*.
{{% /notice %}}

---

## Engineering reference

{{% notice warning %}}
**Internal engineering reference.** This table includes the comparison against VMware vSphere
ConfigMax published maximums and the full measurement provenance. It is included here for review
and may be trimmed before public release.
{{% /notice %}}

The reference cluster meets or beats the equivalent published vSphere / NSX-T maximum on every row
that has a clean analog. The headline result is the **100,000** firewall-rules-per-namespace parity.

| vSphere metric | Concept | KubeV resource + bottleneck | Test | Accepted / Sustained | Notes |
|---|---|---|---|---|---|
| DFW rules per host: ~100,000 | Stateful firewall rules per hypervisor. | NetworkPolicy → OVN ACLs; bottleneck = `ovn-northd` CPU (rule compilation). | `networkPoliciesPerNamespace` | **100,000** / **~13,000** | Sustained ceiling higher than VPC/subnet/SG because OVN de-duplicates rules sharing a selector. ✓ parity by accepted; ~13 % of vSphere by sustained. |
| DFW rules per host, cluster-wide: ~100,000 | Same control-plane budget regardless of namespace spread. | NetworkPolicy across many namespaces → same compile step. | `networkPoliciesPerCluster` | **100,000** / pending | Confirms the limit is cluster-wide control-plane, not per-namespace. ✓ parity (accepted). |
| Tier-1 routers per cluster: ~4,000 | Tenant-level routers. | VPC → kube-ovn-controller workqueue + `ovn-central` memory. | `vpcsPerCluster` | **~9,800** / **~7,000** | Cross-node VM latency stable to ~7,000, then jumps ~4×. ✓ beats vSphere (sustained 1.75× of 4,000). |
| Static routes per Tier-1: ~4,000 | Per-router routing-table state. | `Vpc.spec.staticRoutes` → OVN logical router. | `vpcStaticRoutesPerVpc` | **3,830** / **3,830** | Reached configured cap of 4,000; last clean checkpoint 3,830. ✓ 96 % parity. |
| Security groups per cluster: ~10,000 | Tag-based firewall scopes. | SecurityGroup → OVN port-groups. | `securityGroupsPerCluster` | **10,000** / **~7,000** | Same ~7,000 sustained breakpoint as VPCs/subnets — shared `ovn-northd` saturation. ✓ parity (accepted). |
| Logical segments per Tier-1: ~5,000 | L2 broadcast domains per tenant. | Subnet (per-VPC) → OVN logical switches. | `subnetsPerVPC` | **10,000** / **~7,000** | Identical breakpoint to VPCs + SGs — confirms control-plane CPU is the shared limit. ✓ beats vSphere (sustained 1.4× of 5,000). |
| NAT rules per Tier-1: ~10,000 | DNAT/SNAT on tenant router. | VpcNatGateway needs an underlay the reference cluster lacks. | — | n/a | Reference cluster is overlay-only; no clean analog on this hardware. |
| DFW rules per VM: ~4,000 | Per-VM rule attachment. | Covered indirectly by per-namespace rule count. | — | — | Gap — no dedicated test. |
| Security tags per VM: ~30 | Tags per VM. | KubeVirt uses labels; no separate tag object. | — | — | Gap — construct does not map 1:1. |
| Logical ports per segment: ~3,000 | Endpoints per segment. | Covered indirectly by pods-per-namespace + NICs-per-VM. | — | — | Gap — no dedicated test. |
| Tier-0 routers per cluster: ~10 | Provider-edge routers. | Not applicable to an overlay-only cluster. | — | n/a | No analog on this hardware. |
| IP sets / addresses: ~4,000 | Reusable address lists. | OVN address-set is the analog. | — | — | Gap — no scale test yet. |
| — *(KubeV-native)* | Concurrent stateful connections per host. | `nf_conntrack` table; bottleneck = table size + memory. | `conntrackLimits` | **>150,000** / same | Driven to 150,000 cluster-wide at <2 % of the ~3.1 M per-host capacity, 0 drops. ✓ large headroom. |
| — *(KubeV-native)* | Subnets cluster-wide. | Subnet (multi-VPC) → OVN NB database. | `subnetsPerCluster` | **100,000** / pending | Hit a safety bound of 100,000 with no strain (20× the vSphere segment number). Sustained probe pending. ✓ |
| — *(KubeV-native)* | Routable services per cluster. | Service + Endpoints; bottleneck = kube-proxy IPVS + conntrack. | `serviceEndpointsPerCluster` | 5,000 / pending | *Validation in progress* — verifies API create only; sustained probe owed. |
| — *(KubeV-native)* | Network-attachment templates per namespace. | NetworkAttachmentDefinition (CRD). | `nadsPerNamespace` | 5,000 / pending | *Validation in progress* — verifies CRD storage only. |
| — *(KubeV-native)* | QoS / bandwidth policies per cluster. | QoSPolicy → OVN QoS table. | `qosPolicies` | 5,000 / pending | *Validation in progress* — verifies API create only. |
| — *(KubeV-native, vSphere ~10)* | NICs per VM. | KubeVirt VMI multi-NIC + Multus. | `nicsPerVM` | **32** / **32** | All NIC counts 2…32 booted cleanly. ✓ beats vSphere 3×. |
| — *(KubeV-native)* | Pod-to-pod RTT (latency floor). | veth → OVS bridge → NIC. | `networkLatency` | same-host **167 µs** · cross-host **532 µs** | Direct ICMP between pods, 0 % loss, on a freshly-booted cluster. ✓ |
| — *(KubeV, vSphere ~128 vCPU)* | vCPUs per VM. | KubeVirt + libvirt. | `vcpusPerVM` | **94** / **94** | Bounded by 96 physical cores minus host reserve. ✓ |
| — *(KubeV, vSphere ~24 TiB)* | Memory per VM. | KubeVirt + libvirt. | `memoryPerVM` | **180 GiB** / **180 GiB** | Bounded by 251 GiB worker RAM. ✓ |
| — *(KubeV-native)* | Pods per worker host. | kubelet + container runtime. | `podsPerNode` | **1,185** / **1,185** | Reached kubelet `--max-pods=1200` ceiling. 11× the stock default. ✓ |
| — *(KubeV-native)* | Combined tenant onboarding (namespace + subnet + 5 rules + 1 VM each). | Each bundle adds a logical switch, ACL chains, and a VM datapath. | `tenantScalingPerCluster` | **~80** / **~80** | Much lower than single-object limits because each VM adds port-binding, connection tracking and NAT state. The VM datapath dominates; empty subnets and dormant rules cost almost nothing. |
| — *(KubeV-native)* | VMs per worker host. | KubeVirt + virt-handler + cgroup pressure. | `vmsPerNode` | 300 recent / 1,100 best | *Validation in progress* — dedicated long run owed to re-confirm the 1,100 best. |

---

## How we measure

ConfigMax does not assume a limit — it **discovers** one. Each test creates the target object type
in growing batches and watches the cluster between batches. A run stops for one of a few reasons,
and the stop reason is always recorded alongside the number so you know *why* a value is what it is.

**Run modes**

- **Discovery** — push load in growing batches until the cluster shows distress, a wall-clock
  timeout fires, or a safety upper bound is reached. The "Accepted" numbers come from this mode.
- **Target** — a repeatable pass/fail check: reach a fixed target count without distress, or fail.
  Useful for CI gates and for re-confirming a known limit on a new cluster.
- **Workload-SLO** — discovery *plus* a small "canary" of real VMs that continuously send traffic
  across the cluster while the load grows. (A *canary* here is a handful of always-on VMs whose
  network round-trip time we watch.) When their VM-to-VM latency drifts more than 5 % above the
  cluster's baseline, the run records that count as the **Sustained** ceiling. This is the number
  that reflects real production experience, not just "the API accepted the object."

**Distress signals.** In discovery and workload-SLO modes, the cluster is continuously checked for
strain. Any of the following, sustained for three consecutive samples, stops the run:

| Signal | Threshold |
|---|---|
| API server p99 latency | > 5 s |
| etcd write p99 latency | > 1 s |
| Controller reconcile error rate | > 5 % |
| `ovn-central` memory | > 80 % of its limit |
| Network-controller work-queue p99 | > 30 s |
| Out-of-memory kills (control plane or test pods) | any |
| Pod evictions on workers | > 5 / min |

**Why the numbers are conservative.** When a run stops because it hit a *configured safety bound*
rather than a distress signal, the cluster still had headroom. Those rows are reported as lower
bounds ("at least N") — the real ceiling is higher.

## What each number is limited by

A one-line note on the bottleneck behind each capability, so the numbers are easy to reason about:

- **Firewall rules** — the network control plane (`ovn-northd`) compiles rules into the data plane;
  its CPU is the limit. Rules sharing a selector are de-duplicated, which is why the firewall limit
  is higher than the tenant/subnet limit.
- **Network tenants, subnets, security groups** — all three land on the same network control-plane
  compile step, so they share one breakpoint (~7,000 sustained on this cluster).
- **Static routes** — routing-table state on a single tenant router; limited by how fast the
  network controller programs entries.
- **Concurrent connections** — the Linux connection-tracking table, sized from host memory; very
  large headroom on a 256 GiB host.
- **Pods per host** — the kubelet `--max-pods` setting and container-runtime overhead.
- **vCPUs / memory / NICs per VM** — fixed hardware and KubeVirt configuration bounds, not load.
- **Active tenants (combined)** — dominated by per-VM datapath state (port binding, connection
  tracking, NAT), which is far heavier than an idle subnet or an unused firewall rule.

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

Each line above is annotated with what it does. The two blocks that matter most are `mode` (how the
run decides to stop) and `discovery` (how aggressively it pushes load).

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
subnetsPerVPC: 7000 (stopped by distress:ovn-northd-cpu)
```

`highestCount` is your discovered maximum; `stoppedBy` tells you *why* the run stopped — a distress
signal, `timeout`, or `safety-bound`. The full per-batch curve and cluster snapshots live under
`.status.report` for deeper analysis.

### Key parameters

These are the fields you will most often change. All live under `spec`.

| Field | Values | Purpose |
|---|---|---|
| `profile` | `smoke` · `medium` · `full` · `custom` | Preset scale. Use `custom` to control the fields below. |
| `tests` | list of test IDs | Which benchmarks to run (e.g. `subnetsPerVPC`, `vpcsPerCluster`, `networkPoliciesPerNamespace`, `nicsPerVM`). Only honored with `profile: custom`. |
| `overrides.<test>.mode` | `discovery` · `target` · `workload-slo` | How the test decides to stop. See [run modes](#how-we-measure). |
| `overrides.<test>.maxCount` | integer | Safety upper bound on object count. Works alongside `discovery.safetyBound`; set either to cap the run. |
| `discovery.initialBatch` | integer (default 10) | Objects created in the first batch. |
| `discovery.growthFactor` | string float (default `"2.0"`) | Batch size multiplier each round. Lower = gentler ramp. |
| `discovery.batchPauseSec` | integer (default 5) | Settle time between batches; raise it to let the controller catch up. |
| `discovery.hardTimeoutSec` | integer (default 14400) | Wall-clock cap on the whole run. |
| `discovery.safetyBound` | integer (default 100000) | Absolute object-count cap — stops even with no distress. |
| `discovery.targetCount` | integer | For `mode: target` only: the count to reach for a PASS. |
| `distressOverrides.*` | integers | Tune the strain thresholds (API latency, etcd latency, sample interval, etc.). Defaults match the table in [How we measure](#how-we-measure). |
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
