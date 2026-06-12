+++
title = "Configuration Maximums"
date = 2026-06-10T09:00:00+02:00
weight = 7
+++

This section lists the **validated configuration maximums** of a Kubermatic Virtualization
(KubeV) cluster — how many virtual machines, networks, firewall policies, subnets, routes and
similar objects a cluster reliably handles.

Every number in this section comes from an actual benchmark run against a live reference cluster
using the **ConfigMax** tool, a benchmark harness that ships with Kubermatic Virtualization. It
discovers limits by pushing a growing workload at the cluster and watching for the point where the
cluster pushes back. Nothing here is a paper estimate — each value was measured, and each value was
verified to be *functional*, not merely stored.

{{% notice note %}}
These maximums describe **one specific cluster shape** (listed below). A larger cluster scales
higher; a smaller cluster scales proportionally lower. Use these numbers as a sizing reference,
not as a hard product limit.
{{% /notice %}}

## What's in this section

- [Validated maximums]({{< ref "./validated-maximums" >}}) — the headline capacity table, plus a
  per-capability technical reference (why each run stopped, which component limits it).
- [Degradation]({{< ref "./degradation" >}}) — how many tenants fit before running workloads feel
  slowness.
- [Running ConfigMax]({{< ref "./running-configmax" >}}) — run the benchmark against your own
  cluster, via the in-cluster operator or the CLI binary.
- [Engineering reference]({{< ref "./engineering-reference" >}}) — measurement methodology, distress
  probes, per-test method cards, cluster tuning and findings.

## Test environment

All numbers in this section were measured on the reference cluster unless noted otherwise.

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
[engineering reference]({{< ref "./engineering-reference/tuning-and-findings" >}}).

## How to read these numbers

- **Every count is fully programmed and functionally verified.** A number in this section means
  the objects exist in the network control plane *and* demonstrably work — a pod in a freshly
  created subnet gets an IP address and pings its gateway, a service address answers with live
  backends, a firewall policy actually enforces. It does **not** mean "the API stored this many
  objects" — storage alone says nothing about whether the objects function.
- **Cap-bound numbers are lower bounds.** Runs push to a deliberately high configured cap. Where
  the cap was reached with the cluster showing no strain, read the value as "validated to at least
  N" — the real ceiling is higher.
- **Two questions, two kinds of number.** *Capacity* answers "how many of these objects fit."
  *Degradation* answers "how many tenants fit before running workloads feel slowness." They are
  different tests and are never mixed.
- **Per-tenant vs. cluster-wide.** Numbers that say "per tenant" or "per namespace" describe one
  tenant scope; cluster-wide totals are listed separately.
