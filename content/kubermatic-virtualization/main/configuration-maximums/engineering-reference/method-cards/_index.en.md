+++
title = "Per-Test Method Cards"
date = 2026-06-11T09:00:00+02:00
weight = 3
+++

Format: what the test creates → what "programmed" means → how functionality is verified → the
parameters used → what actually stopped the run → result and headroom.

## vpcsPerCluster — network tenants per cluster

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

## subnetsPerCluster — subnets cluster-wide

| | |
|---|---|
| **Creates** | kube-ovn `Subnet` CRs spread across 5 VPCs |
| **Programmed =** | OVN logical switches (`ovn-nbctl ls-list`), NB leader |
| **Functional verify** | netshoot pod dropped into a live subnet at the top count: got its OVN IP (10.195.231.2) and pinged the subnet gateway 3/3, 0 % loss, 0.57 ms — datapath genuinely forwards at 11.8 k subnets |
| **Parameters** | cap 20,000 · initialBatch 50 · growth ×1.5 · batchPause 5 s · 3 h catch-up window |
| **Stop trigger** | cap accepted (20,001 CRs); published number = programmed count settled within the catch-up window |
| **Result** | **11,822 programmed + datapath-verified** · 2026-06-09 · 5 h 28 m |
| **Peak vs danger line** | northd ≤ 2,200 m / 3,600 m · ovn-central ≤ 4.2 / 14.4 GiB · cp-node mem ≤ 44 / 90 % · per-node ovs-ovn flat ~256 MiB / 8 GiB |
| **Caveats** | catch-up-window-bound, NOT a wall — programming decelerated ~52→17 subnets/min; a longer window or faster controller goes higher. The *automated* netshoot verify false-reported "no-IP" (its image pull took ~90 s, longer than the probe wait — fix queued); the manual verify above passed cleanly. Before the per-node agent memory bump (see the [tuning baseline]({{< ref "../tuning-and-findings" >}})), this test OOM-killed `ovs-ovn` at ~7.7 k subnets — that wall is gone. |

## subnetsPerVPC — subnets in one tenant

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

## networkPoliciesPerNamespace — firewall policies in one namespace

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

## networkPoliciesPerCluster — firewall policies cluster-wide

| | |
|---|---|
| **Creates** | same policy shape spread across 10 namespaces, 21 enforcing pods |
| **Programmed =** | OVN ACL entries, NB leader |
| **Functional verify** | enforcement via the selected pods; ACL programming kept pace — 355,469 ACLs settled after the controller catch-up at the cap |
| **Parameters** | cap 120,000 · initialBatch 50 · growth ×1.5 (batch capped at 500) · batchPause 5 s · plus an independent bystander pod probing the apiserver service VIP (10.96.0.1) every 10 s for the whole run |
| **Stop trigger** | configured cap, no distress — steady ~13.4 s per 500-policy batch (~2,200 policies/min) for the full push; bystander VIP probe recorded **zero failures in 1,459 samples (~4 h)** |
| **Result** | **120,001 policies / 355,469 ACLs settled** · 2026-06-10 · 4 h 0 m |
| **Caveats** | an independent bystander pod monitors the cluster service VIP throughout the run, so a node-local connectivity hiccup on the benchmark pod cannot be mistaken for a data-plane wall — 355 k ACLs programmed with the VIP path clean throughout. The ACL-to-policy ratio falls at scale (~6 per policy at 25 k → ~3 at 120 k) as rules consolidate at the port-group level |

## securityGroupsPerCluster — security groups

| | |
|---|---|
| **Creates** | kube-ovn `SecurityGroup` CRs with full ingress/egress rules **including `remoteType: address`** (required — without it the controller rejects the rules with `not support sgRemoteType ''` and programs nothing) |
| **Programmed =** | OVN port-groups named `ovn.sg.configmax-*`, NB leader |
| **Functional verify** | SG `status.portGroup` populated + `ingress/egressLastSyncSuccess: true`; CLI smoke 101/100 before the scale run |
| **Parameters** | cap 20,000 · initialBatch 50 · growth ×1.5 · batchPause 5 s · catch-up window |
| **Stop trigger** | controller-stability-bound: kube-ovn-controller hit `fatal error: concurrent map read and map write` (a Go data race — crash, not OOM; 15 restarts) under the 20 k-SG reconcile load, capping settled programming |
| **Result** | **5,606 port-groups programmed** (20,001 CRs accepted) · 2026-06-10 · 2 h 07 m |
| **Peak vs danger line** | ovn-central / northd / etcd all healthy — the crash is in the kube-ovn controller, which the probes do not yet watch |
| **Caveats** | a kube-ovn 1.14.30 stability bug at scale (upstream report planned), not a fundamental OVN limit; programming decelerated 119→24 PGs/min; below the vSphere 10 k comparable for now |

## serviceEndpointsPerCluster — routable services

| | |
|---|---|
| **Creates** | `Service` objects each with a **real backend pod** — kube-ovn programs a service's OVN load-balancer VIP only once the service has Ready endpoints; VIPs without backends never program |
| **Programmed =** | OVN load-balancer **VIP entries** minus baseline, NB leader |
| **Functional verify** | VIPs answer with live backends; backends 0 → 1,005 Ready during the run, VIPs climbed 35 → 953 → 1,001 settled |
| **Parameters** | cap 1,000 · backendsPerService 1 · probe requires 3 **consecutive** real failures |
| **Stop trigger** | configured cap, no distress |
| **Result** | **1,001 services with functional VIPs (full cap)** · 2026-06-10 · 13 m |
| **Caveats** | cap-bound — each functional service needs a wired backend pod, so higher caps are pod-wiring-throughput-bound. Service capacity depends on healthy pod wiring on every node: a memory-starved multus on a single node blocks backend wiring there, which silently suppresses endpoints and VIPs cluster-wide. The VIP probe requires 3 consecutive real failures before it stops a run, so a single not-yet-Ready backend cannot fake a ceiling |

## vpcStaticRoutesPerVpc — static routes on one tenant router *(earlier methodology)*

| | |
|---|---|
| **Creates** | entries in `Vpc.spec.staticRoutes` (/32 host-routes, so the address space supports the full cap) |
| **Programmed =** | routes present in the OVN logical router, compared against requested (drift detection) |
| **Stop trigger** | route-drift rule: stop when programmed lags requested by more than max(200, 25 %) — i.e. the controller's programming cadence is the wall |
| **Parameters** | cap 4,000 · batchPause 120 s · adaptive batch capped at 200 past cumulative 500 |
| **Result** | **3,830** (last clean checkpoint at the 4,000 cap) · 2026-05-05 · 1 h 04 m |
| **Caveats** | predates the realistic-ceiling method (no functional datapath verify, no catch-up settle); rewrite deferred. 96 % of the vSphere 4,000 comparable |

## nicsPerVM · vcpusPerVM · memoryPerVM — per-VM hardware bounds

| | |
|---|---|
| **Method** | boot sweep: a VM per size step must reach Running within the boot timeout |
| **nicsPerVM** | all counts 2…32 booted cleanly (3 m 39 s at 32); 48+ failed the 5-minute multi-NIC boot wait — boot-timeout-bound, not a hard wall. **32** · 2026-05-05. vSphere comparable ~10 → 3× |
| **vcpusPerVM** | sweep [1…94]: all booted; 24.1 s boot at 94. **94** = 96 physical cores − host reserve · 2026-05-04 |
| **memoryPerVM** | sweep [1…180 GiB]: all booted on a cold cluster; 15.0 s boot at 180 GiB (worker had 0.9 GiB free at peak). **180 GiB** · 2026-05-04 |

## podsPerNode · conntrackLimits · networkLatency — runtime / data-plane

| | |
|---|---|
| **podsPerNode** | scheduled pods on one worker until kubelet refused: **1,185** + ~15 baseline = the kubelet `--max-pods=1200` ceiling · 2026-05-04 · 3 h 48 m. Sampler: OVS flows grew linearly (~70 flows per 100 pods, 20 k → 88 k cluster-wide); API create latency 8.5 → 10 s. Pushing further is a kubelet retune, not a network limit |
| **conntrackLimits** | 300 client pods × 500 concurrent connections = **150 k+ tracked flows**, ~175 k peak entries observed, 0 drops, ≤ 2.8 % of the per-host table (3,145,728 on a 251 GiB worker) · 2026-05-06 · 13 m. Massive headroom — the table would hold ~9.4 M cluster-wide |
| **networkLatency** | direct ICMP between pause pods: same-host **167 µs** avg (min 71 µs, max 2.17 ms), cross-host **532 µs** avg (min 369 µs, max 3.69 ms), 0 % loss · 2026-05-06, freshly-booted cluster. Data-plane latency scales with logical-object count (with ~14 k stale subnets present, the same cross-host path measures 1.84 ms) — the reason every ceiling is measured on a clean cluster |

## tenantScalingPerCluster — degradation by tenant bundle

| | |
|---|---|
| **Creates** | N tenant bundles. Small bundle (published): 1 namespace + 2 subnets + 5 VMs + 10 **enforcing** firewall policies (they select the VM's launcher pod) + 2 services + 1 security group per tenant |
| **Measures** | canary VM-to-VM p99 latency at every settled batch boundary (same-node pair + cross-node cross-VPC pair; light HTTP probe, median of 3 passes per boundary; baseline = median of 3 at identical intensity, both legs required) |
| **Stop trigger** | DUAL rule (2026-06-12): p99 > 2 ms floor AND > 4× this cluster's own baseline, each sustained 3 consecutive boundaries. Probe-lost abort: 3 consecutive empty measurements invalidate the run |
| **Result** | **flat through 120 tenants / 600 VMs (run cap)** · 2026-06-12 · cross-host p99 406–488 µs vs 430 µs baseline, all 24 boundaries measured — *confirmed*; degradation point above 120, higher-cap run scheduled. (Historical: ~80 ± 10 on the 2026-05-08 pre-upgrade cluster — superseded; see degradation methodology) |
| **Caveats** | idle VMs do not stress the data plane (a traffic-load variant is future work); per-boundary running-VM count not yet recorded in the curve (post-run VM phase audit used instead) |
