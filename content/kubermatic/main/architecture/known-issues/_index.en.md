+++
title = "Known Issues"
date = 2022-07-22T12:22:15+02:00
weight = 25

+++

## Overview

This page documents the list of known issues and possible work arounds/solutions.

## User Cluster API Servers Fail to Start on Seed with Cilium CNI

### Problem

When upgrading to or installing KKP in version 2.24.0 or 2.24.1, kube-apiserver components fail to start with log output similar to the snippet below:

```json
{"level":"error","time":"2023-11-30T10:43:46.518Z","caller":"etcd-launcher/main.go:116","msg":"Operation failed: failed to initialize etcd cluster configuration: failed to get API group resources: unable to retrieve the complete list of server APIs: kubermatic.k8c.io/v1: Get \"https://10.96.0.1:443/apis/kubermatic.k8c.io/v1\": dial tcp 10.96.0.1:443: i/o timeout."}
```

This problem arises when Cilium is used as CNI for the underlying seed cluster.

It was fixed in KKP 2.24.2, see relevant issue: [kubermatic/kubermatic#12874](https://github.com/kubermatic/kubermatic/issues/12874).

### Root Cause

A bug in Cilium tracked as [cilium/cilium#12277](https://github.com/cilium/cilium/issues/12277) and [cilium/cilium#20550](https://github.com/cilium/cilium/issues/20550).

Kubernetes `NetworkPolicy` documentation [implies that allowing node access via CIDRs is supposed to work](https://kubernetes.io/docs/concepts/services-networking/network-policies/#what-you-can-t-do-with-network-policies-at-least-not-yet):

> Node specific policies (you can use CIDR notation for these, but you cannot target nodes by their Kubernetes identities specifically).

But Cilium does not properly allow traffic even though `NetworkPolicies` with node CIDRs are in place.

### Solution

At the moment (with KKP v2.24.0), there are two options available:

1. [Disable kube-apiserver NetworkPolicies in Seeds with Cilium as CNI]({{< ref "../../tutorials-howtos/networking/apiserver-policies/#in-a-seed-cluster" >}})
2. Manually creating a single `CiliumClusterwideNetworkPolicy` object (this is a cluster-scoped resource, i.e. global) to allow the erroneously blocked traffic:

```yaml
apiVersion: cilium.io/v2
kind: CiliumClusterwideNetworkPolicy
metadata:
  name: cilium-seed-apiserver-allow
spec:
  egress:
  - toEntities:
    - kube-apiserver
  endpointSelector:
    matchLabels:
      app: apiserver
```

## Ubuntu 22.04 Cloud Image Issue on VMware Cloud Director

### Problem

The issue arises in Ubuntu 22.04 cloud image OVAs starting from version 20230602 when they are run on VMware Cloud Director. This problem disrupts the provisioning of new Kubernetes nodes using machine-controller due to interruptions caused by reboots.

### Root Cause

The root cause of this issue can be traced back to a change in the default settings of open-vm-tools. These changes, in turn, affect the behavior of cloud-init during startup, leading to the disruptive behavior observed when provisioning new Kubernetes nodes. Specifically, the open-vm-tools.service starts before cloud-init, and it runs with the default timeout (30 seconds).

### Solution

One interim [solution](https://github.com/canonical/cloud-init/issues/4188#issuecomment-1695041510) in this scenario is to create a custom Ubuntu 22.04 image with the following setting preconfigured
in /etc/vmware-tools/tools.conf file.
```
[deployPkg]
wait-cloudinit-timeout=0
```
This adjustment will help ensure that the issue no longer disrupts the provisioning of new Kubernetes nodes on the affected Ubuntu 22.04 cloud images running on VMware Cloud Director provider.

For additional details and discussions related to this issue, you can refer to the following GitHub issues:
- [open-vm-tools](https://github.com/vmware/open-vm-tools/issues/684).
- [cloud-init](https://github.com/canonical/cloud-init/issues/4188).
