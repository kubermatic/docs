+++
title = "Kubermatic Virtualization Components"
date = 2025-07-18T16:06:34+02:00
weight = 5
+++

The following list is only applicable for the Kubermatic-Virtualization version that is currently available. Kubermatic has a strong emphasis 
on security and reliability of provided software and therefore releases updates regularly that also include component updates.


| Kubermatic-Virtualization Component | Version  |
|:-----------------------------------:|:--------:|
|             Kubernetes              | v1.34.11 |
|              KubeVirt               |  v1.7.4  |
|  Containerized Data Importer (CDI)  | v1.65.0  |
|               KubeOVN               | v1.15.16 |
|              KubeOne                | v1.13.4  |
|               Kyverno               | v1.16.4  |
|            Cert Manager             | v1.21.2  |
|               MetalLB               | v0.16.1  |
|              Multus CNI             | v4.2.4   |
|              Longhorn               | v1.10.2  |
|                Rook                 | v1.20.9  |
|                Ceph                 | v20.2.4  |
|              Forklift               | v2.12.1  |

In [KDP mode]({{< ref "../../../kdp-integration" >}}), the same layer and nested installations also install KDP v1.2.1
with kcp v0.32.3.
