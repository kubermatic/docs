+++
title = "Per-Test Method Cards"
date = 2026-06-11T09:00:00+02:00
weight = 3
+++

Each card records what the test creates, what "programmed" means for that resource, how
functionality is verified, the parameters used, what stopped the run, and the result with its
headroom.

## vpcsPerCluster: network tenants per cluster

| | |
|---|---|
| **Creates** | kube-ovn `Vpc` CRs (tenant logical routers), batched |
| **Programmed =** | OVN logical routers (`ovn-nbctl lr-list`), counted on the NB leader |
| **Functional verify** | per-checkpoint provisioning probe (new VPC create to Ready). VPC CRs flip Ready almost instantly, so the programmed logical-router count is the authoritative signal |
| **Parameters** | cap 10,000 · initialBatch 50 · growth ×1.5 · batchPause 5 s · distress samples 10 s × 3 |
| **Stop trigger** | configured cap, no distress; catch-up settled programming at 10,001 in about 9 minutes |
| **Result** | **10,000 validated** · 2026-06-08 · 1 h 06 m |
| **Peak vs danger line** | ovn-central memory about 2.0 / 14.4 GiB · northd about 1,605 m / 3,600 m · cp-node memory 31 / 90 % · **etcd 1,227 MB / about 1,600 MB, the nearest line (about 77 %)** |
| **Caveats** | cap-bound, so the real ceiling is above 10,000; etcd database size is the eventual binding factor for VPCs |

## subnetsPerCluster: subnets cluster-wide

| | |
|---|---|
| **Creates** | kube-ovn `Subnet` CRs spread across 5 VPCs |
| **Programmed =** | OVN logical switches (`ovn-nbctl ls-list`), NB leader |
| **Functional verify** | a netshoot pod placed into a live subnet at the top count obtained its OVN IP (10.195.231.2) and pinged the subnet gateway 3/3, 0 % loss, 0.57 ms, confirming the datapath genuinely forwards at 11.8 k subnets |
| **Parameters** | cap 20,000 · initialBatch 50 · growth ×1.5 · batchPause 5 s · 3 h catch-up window |
| **Stop trigger** | cap accepted (20,001 CRs); the published number is the programmed count that settled within the catch-up window |
| **Result** | **11,822 programmed and datapath-verified** · 2026-06-09 · 5 h 28 m |
| **Peak vs danger line** | northd at most 2,200 m / 3,600 m · ovn-central at most 4.2 / 14.4 GiB · cp-node memory at most 44 / 90 % · per-node ovs-ovn flat at about 256 MiB / 8 GiB |
| **Caveats** | catch-up-window-bound, not a wall: programming decelerated from about 52 to 17 subnets/min, so a longer window or a faster controller goes higher. The automated netshoot verify false-reported "no-IP" because its image pull took about 90 s, longer than the probe wait (fix queued); the manual verify above passed cleanly. Before the per-node agent memory bump (see the [tuning baseline]({{< ref "../tuning-and-findings" >}})), this test OOM-killed `ovs-ovn` at about 7.7 k subnets; that wall is gone |

## subnetsPerVPC: subnets in one tenant

| | |
|---|---|
| **Creates** | `Subnet` CRs inside a single VPC |
| **Programmed =** | OVN logical switches with the benchmark prefix, NB leader |
| **Functional verify** | the same netshoot gateway-ping pattern as subnetsPerCluster; a CLI smoke run of 101/100 validated the counter before the scale run |
| **Parameters** | cap 8,000 · initialBatch 50 · growth ×1.5 · batchPause 5 s · catch-up window |
| **Stop trigger** | configured cap, no distress; programming sustained about 46 to 48 subnets/min with no late deceleration, so the controller drained the whole backlog |
| **Result** | **8,001 programmed (full cap, settled)** · 2026-06-10 · 3 h 06 m |
| **Peak vs danger line** | ovn-central at most 4.3 / 14.4 GiB · cp-node memory at most 46 / 90 % · controller stable |
| **Caveats** | cap-bound, so the real ceiling is above 8,001 |

## networkPoliciesPerNamespace: firewall policies in one namespace

| | |
|---|---|
| **Creates** | `NetworkPolicy` objects with mixed allow and deny rules, **plus enforcing pods** that the policies select. Without selected pods, policies program nothing (the no-op trap) |
| **Programmed =** | OVN ACL entries, NB leader. The headline is the policy count; ACLs are reported separately and never conflated |
| **Functional verify** | enforcement active on the selected pods throughout; ACL programming kept pace the whole run (about 5.8 ACLs per policy, no lag) |
| **Parameters** | cap 30,000 · initialBatch 50 · growth ×1.5 · batchPause 5 s · params targetPodCount=2 |
| **Stop trigger** | configured cap, no distress |
| **Result** | **30,001 policies / 175,246 ACLs programmed** · 2026-06-10 · 1 h 08 m |
| **Peak vs danger line** | ovn-central at most 5 / 14.4 GiB · northd healthy · controller stable |
| **Caveats** | cap-bound. The 175 k ACLs are the actual enforced rules; 30 k policies is the configured cap, not a wall |

## networkPoliciesPerCluster: firewall policies cluster-wide

| | |
|---|---|
| **Creates** | the same policy shape spread across 10 namespaces, with 21 enforcing pods |
| **Programmed =** | OVN ACL entries, NB leader |
| **Functional verify** | enforcement through the selected pods; ACL programming kept pace, with 355,469 ACLs settled after the controller catch-up at the cap |
| **Parameters** | cap 120,000 · initialBatch 50 · growth ×1.5 (batch capped at 500) · batchPause 5 s · plus an independent bystander pod probing the apiserver service VIP (10.96.0.1) every 10 s for the whole run |
| **Stop trigger** | configured cap, no distress. Steady at about 13.4 s per 500-policy batch (about 2,200 policies/min) for the full push; the bystander VIP probe recorded **zero failures in 1,459 samples over about 4 hours** |
| **Result** | **120,001 policies / 355,469 ACLs settled** · 2026-06-10 · 4 h 0 m |
| **Caveats** | an independent bystander pod monitors the cluster service VIP throughout the run, so a node-local connectivity hiccup on the benchmark pod cannot be mistaken for a data-plane wall: 355 k ACLs were programmed with the VIP path clean throughout. The ACL-to-policy ratio falls at scale (about 6 per policy at 25 k, about 3 at 120 k) as rules consolidate at the port-group level |

## securityGroupsPerCluster: security groups

| | |
|---|---|
| **Creates** | kube-ovn `SecurityGroup` CRs with full ingress and egress rules, **including `remoteType: address`** (required; without it the controller rejects the rules with `not support sgRemoteType ''` and programs nothing) |
| **Programmed =** | OVN port-groups named `ovn.sg.configmax-*`, NB leader |
| **Functional verify** | SG `status.portGroup` populated plus `ingress/egressLastSyncSuccess: true`; a CLI smoke run of 101/100 before the scale run |
| **Parameters** | cap 20,000 · initialBatch 50 · growth ×1.5 · batchPause 5 s · catch-up window |
| **Stop trigger** | controller-stability-bound: kube-ovn-controller hit `fatal error: concurrent map read and map write` (a Go data race, a crash rather than an OOM; 15 restarts) under the 20 k-SG reconcile load, which capped settled programming |
| **Result** | **5,606 port-groups programmed** (20,001 CRs accepted) · 2026-06-10 · 2 h 07 m |
| **Peak vs danger line** | ovn-central, northd, and etcd all healthy; the crash is in the kube-ovn controller, which the probes do not yet watch |
| **Caveats** | a kube-ovn 1.14.30 stability bug at scale, not a fundamental OVN limit; programming decelerated from 119 to 24 port-groups/min |

## serviceEndpointsPerCluster: routable services

| | |
|---|---|
| **Creates** | `Service` objects each with a **real backend pod**. kube-ovn programs a service's OVN load-balancer VIP only once the service has Ready endpoints; VIPs without backends never program |
| **Programmed =** | OVN load-balancer **VIP entries** minus baseline, NB leader |
| **Functional verify** | VIPs answer through live backends; backends rose from 0 to 1,005 Ready during the run, and VIPs climbed 35, then 953, then 1,001 settled |
| **Parameters** | cap 1,000 · backendsPerService 1 · probe requires 3 **consecutive** real failures |
| **Stop trigger** | configured cap, no distress |
| **Result** | **1,001 services with functional VIPs (full cap)** · 2026-06-10 · 13 m |
| **Caveats** | cap-bound. Each functional service needs a wired backend pod, so higher caps are pod-wiring-throughput-bound. Service capacity depends on healthy pod wiring on every node: a memory-starved multus on a single node blocks backend wiring there, which silently suppresses endpoints and VIPs cluster-wide. The VIP probe requires 3 consecutive real failures before it stops a run, so a single not-yet-Ready backend cannot fake a ceiling |

## vpcStaticRoutesPerVpc: static routes on one tenant router *(earlier methodology)*

| | |
|---|---|
| **Creates** | entries in `Vpc.spec.staticRoutes` (/32 host-routes, so the address space supports the full cap) |
| **Programmed =** | routes present in the OVN logical router, compared against requested (drift detection) |
| **Stop trigger** | route-drift rule: stop when programmed lags requested by more than max(200, 25 %), so the controller's programming cadence is the wall |
| **Parameters** | cap 4,000 · batchPause 120 s · adaptive batch capped at 200 past cumulative 500 |
| **Result** | **3,830** (last clean checkpoint at the 4,000 cap) · 2026-05-05 · 1 h 04 m |
| **Caveats** | predates the current ceiling method (no functional datapath verify, no catch-up settle); a rewrite is deferred |

## nicsPerVM · vcpusPerVM · memoryPerVM: per-VM hardware bounds

| | |
|---|---|
| **Method** | boot sweep: one VM per size step must reach Running within the boot timeout |
| **nicsPerVM** | all counts from 2 to 36 booted cleanly (32 in 4 m 21 s, 36 in 4 m 9 s, flat with no upward trend). 40 NICs never boot: the VM sits in `ContainerCreating` for the full 20-minute timeout. The disk is Ready and the VM never reports Failed, so this is not a hypervisor or PCI-slot limit; it is the per-node network sandbox (CNI/Multus) unable to wire 40 interfaces. Raising the boot timeout from 5 to 20 minutes only moved the ceiling from 32 to 36, so a longer timeout does not lift the 40 wall. **36** · 2026-06-16 |
| **vcpusPerVM** | sweep [1 to 94]: all booted; 24.1 s boot at 94. **94** = 96 physical cores minus host reserve · 2026-05-04 |
| **memoryPerVM** | sweep [1 to 180 GiB]: all booted on a cold cluster; 15.0 s boot at 180 GiB (the worker had 0.9 GiB free at peak). **180 GiB** · 2026-05-04 |

## podsPerNode · networkLatency: runtime and data-plane

| | |
|---|---|
| **podsPerNode** | scheduled pods on one worker until kubelet refused: **1,185** plus about 15 baseline, which is the kubelet `--max-pods=1200` ceiling · 2026-05-04 · 3 h 48 m. Sampler: OVS flows grew linearly (about 70 flows per 100 pods, 20 k to 88 k cluster-wide); API create latency rose from 8.5 to 10 s. Pushing further is a kubelet retune, not a network limit |
| **networkLatency** | direct ICMP between pause pods: same-host **167 µs** average (min 71 µs, max 2.17 ms), cross-host **532 µs** average (min 369 µs, max 3.69 ms), 0 % loss · 2026-05-06, freshly-booted cluster. Data-plane latency scales with logical-object count (with about 14 k stale subnets present, the same cross-host path measured 1.84 ms), which is why every ceiling is measured on a clean cluster |

## tenantScalingPerCluster: degradation by tenant bundle

| | |
|---|---|
| **Creates** | N tenant bundles. The Small bundle (published) is 1 namespace, 2 subnets, 5 VMs, 10 **enforcing** firewall policies (they select the VM's launcher pod), 2 services, and 1 security group per tenant |
| **Measures** | canary VM-to-VM p99 latency at every settled batch boundary (a same-node pair and a cross-node, cross-VPC pair; light HTTP probe, median of 3 passes per boundary; baseline is the median of 3 at identical intensity, both legs required) |
| **Stop trigger** | dual rule: p99 above the 2 ms floor and above 4× this cluster's own baseline, each sustained 3 consecutive boundaries. Probe-lost abort: 3 consecutive empty measurements invalidate the run |
| **Result** | **flat through 120 tenants / 600 VMs (run cap)**: cross-host p99 406 to 488 µs against a 430 µs baseline, all 24 boundaries measured; the degradation point is above 120 |
| **Caveats** | idle VMs do not stress the data plane (a traffic-load variant is future work); the per-boundary running-VM count is not yet recorded in the curve |
