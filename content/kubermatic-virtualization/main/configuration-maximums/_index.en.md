+++
title = "Configuration Maximums"
date = 2026-06-10T09:00:00+02:00
weight = 7
+++

This section answers a sizing question: how many objects — virtual machines, networks,
firewall policies, subnets, services, routes — can one Kubermatic Virtualization (KubeV)
cluster reliably run? Every number was measured on a live reference cluster with the
**ConfigMax** benchmark tool and verified to actually work — none are paper estimates.

{{% notice note %}}
These maximums describe **one specific cluster shape** (the reference cluster, below). A
larger cluster scales higher, a smaller one lower. Use them as a sizing reference, not a
hard product limit.
{{% /notice %}}

## Pages in this section

- [Validated maximums]({{< ref "./validated-maximums" >}}) — **start here.** The headline "how
  many can I run" table, plus the technical breakdown of what limits each one.
- [Degradation]({{< ref "./degradation" >}}) — the other limit: how many tenants you can pack
  before running workloads start to feel slow (capacity says *fits*, this says *still fast*).
- [Running ConfigMax]({{< ref "./running-configmax" >}}) — reproduce any of these numbers on
  your own cluster, via the in-cluster operator or the CLI binary.
- [Engineering reference]({{< ref "./engineering-reference" >}}) — the "how we measured it":
  methodology, per-test method cards, and the cluster tuning behind the numbers.

## Key terms

| Term | What it means |
|---|---|
| **Validated maximum** | A count the cluster reached *and* that we confirmed still works — not just "the API accepted it." |
| **Functionally verified** | At that count, the objects do their job: a new VM gets an IP and pings out, a service answers with live backends, a firewall rule actually blocks traffic. |
| **Cap-bound** | The run hit our configured limit before the cluster showed any strain. Read it as "at least N" — the true ceiling is higher. |
| **Capacity** | How many of an object fit. This is the *Validated maximums* page. |
| **Degradation** | How many tenants run before workloads feel slow. A separate test — never mixed with capacity. |
| **Per tenant / per namespace** | The number applies to one tenant scope; cluster-wide totals are listed separately. |

## Reference cluster

All numbers were measured here unless noted otherwise.

| Property | Value |
|---|---|
| Kubermatic Virtualization | v1.1.0 |
| Worker hosts | 3 × 96 cores / 251 GiB RAM |
| Control-plane hosts | 3 × 12 vCPU / 24 GiB RAM |
| Kubernetes | v1.34.3 (kubeadm) |
| KubeVirt | v1.5.3 |
| CNI (software-defined network) | Kube-OVN 1.14.30 |
| Operating system | Ubuntu 24.04.3 LTS, kernel 6.8 |
| Container runtime | containerd 1.7.29 |
| Storage | Longhorn (default) |

Network components were tuned for scale testing; the full tuning baseline is in the
[engineering reference]({{< ref "./engineering-reference/tuning-and-findings" >}}).
