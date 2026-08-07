+++
title = "Configuration Maximums"
date = 2026-06-10T09:00:00+02:00
weight = 20
+++

Configuration Maximums defines the tested capacity limits of a single Kubermatic Virtualization
(KubeV) cluster: the largest number of virtual machines, networks, firewall policies, subnets,
services, and routes it can run reliably at once. Each limit was validated on a live cluster, not
estimated. The pages that follow give the numbers, the factor that limits each one, and the steps
to reproduce them on your own cluster with the **ConfigMax** benchmark tool.

{{% notice note %}}
These maximums describe **one specific cluster configuration** (the reference cluster documented
below). A larger cluster will support higher figures, and a smaller cluster lower ones. They should be treated as a
sizing reference rather than a fixed product limit, and they can be reproduced on any cluster using
[Running ConfigMax]({{< ref "./running-configmax" >}}).
{{% /notice %}}

## Pages in this section

- [Validated maximums]({{< ref "./validated-maximums" >}}): the per-capability maximums, together
  with the limiting factor for each figure.
- [Degradation]({{< ref "./degradation" >}}): how many tenants a cluster carries before running
  workloads slow down, a separate measurement from raw capacity.
- [Running ConfigMax]({{< ref "./running-configmax" >}}): instructions for reproducing these
  figures on your own cluster.
- [Engineering reference]({{< ref "./engineering-reference" >}}): how the numbers were measured,
  the per-test method cards, and the cluster tuning they depend on.

## Key terms

| Term | Definition |
|---|---|
| **Validated maximum** | A count that the cluster reached and that was confirmed to remain functional, not merely accepted by the API. |
| **Lower bound** | A run that reached its configured cap before the cluster exhibited any strain. The figure should be read as "at least N"; the true ceiling is higher. |

## Reference cluster

All figures were measured on the following cluster.

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

The network components were tuned for scale testing by raising the memory and CPU limits on the
Kube-OVN control-plane and per-node agents. With the components left at their stock limits, the
cluster reaches lower figures.
