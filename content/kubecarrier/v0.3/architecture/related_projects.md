---
title: Related Projects
weight: 40
date: 2021-02-10T11:30:00+02:00
---

## What is the difference to OLM / Crossplane?

The [Operator Lifecycle Manager](https://github.com/operator-framework/operator-lifecycle-manager) and [Crossplane](https://crossplane.io/) are both projects that manage installation, upgrade and deletion of Operators and their CustomResourceDefinitions in a Kubernetes cluster.

KubeCarrier on the other hand is just working with existing CustomResourceDefinitions and already installed Operators.
As both OLM and Crossplane are driven by CRDs, they can be combined with KubeCarrier to manage their configuration across clusters.

## What is the difference to KubeFed - Kubernetes Federation?

The [Kubernetes Federation Project](https://github.com/kubernetes-sigs/kubefed) was created to distribute Workload across Kubernetes Clusters for e.g. geo-replication and disaster recovery.
It's intentionally low-level to work for generic workload to be spread across clusters.

While KubeCarrier is also operating on multiple clusters, KubeCarrier operates on a higher abstraction level.
KubeCarrier assigns applications onto single pre-determined Kubernetes clusters. Kubernetes Operators that enable these applications, may still use KubeFed underneath to spread the workload across clusters.
