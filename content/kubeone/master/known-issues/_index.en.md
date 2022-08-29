+++
title = "Known Issues"
date = 2022-08-29T09:00:00+02:00
description = "Known Issues in Kubermatic KubeOne"
weight = 99
+++

This page documents the list of known issues in Kubermatic KubeOne along with
possible workarounds and recommendations.

This list applies to KubeOne 1.5 releases. For earlier releases, please
consult the [appropriate changelog][changelogs].

[changelogs]: https://github.com/kubermatic/kubeone/tree/master/CHANGELOG

## Pod connectivity is broken for Calico VXLAN clusters

|              |                                                   |
|--------------|---------------------------------------------------|
| Status       | Being Investigated                                |
| Severity     | High for clusters using Calico VXLAN addon        |
| GitHub issue | https://github.com/kubermatic/kubeone/issues/2192 |

### Description

Clusters running Calico VXLAN might not be able to reach ClusterIP Services
from a node where the pod is running.

### Recommendation

**We do NOT recommend upgrading to KubeOne 1.5 at this time if you're using
Calico VXLAN. Follow the linked GitHub issue and this page for updates.**

## KubeOne is failing to provision a cluster on upgraded Flatcar VMs

|              |                                                   |
|--------------|---------------------------------------------------|
| Status       | Workaround available                              |
| Severity     | Low                                               |
| GitHub issue | https://github.com/kubermatic/kubeone/issues/2318 |

### Description

KubeOne is failing to provision a cluster on Flatcar VMs that are upgraded from
a version prior to 2969.0.0 to a newer version. This only affects VMs that were
never used with KubeOne; existing KubeOne clusters are not affected by this
issue.

### Recommendation

If you're affected by this issue, we recommend creating VMs with newer Flatcar
version or following the [cgroups v2 migration instructions][flatcar-cgroups].

[flatcar-cgroups]: https://www.flatcar.org/docs/latest/container-runtimes/switching-to-unified-cgroups#migrating-old-nodes-to-unified-cgroups

## CoreDNS PodDisruptionBudget is not cleaned up when disabled

|              |                                                     |
|--------------|-----------------------------------------------------|
| Status       | Fix planned for KubeOne 1.5.1; Workaround available |
| Severity     | Low                                                 |
| GitHub issue | https://github.com/kubermatic/kubeone/issues/2322   |

### Description

If the CoreDNS PodDisruptionBudget is enabled in the KubeOneCluster API,
and then disabled, `kubeone apply` will not remove the PDB object from the
cluster.

### Recommendation

If you're affected by this issue, you can manually remove the
PodDisruptionBudget object created by KubeOne.

## `kubeone apply` might fail to recover if the SSH connection is interrupted

|              |                                                     |
|--------------|-----------------------------------------------------|
| Status       | Being Investigated                                  |
| Severity     | Low                                                 |
| GitHub issue | https://github.com/kubermatic/kubeone/issues/2319   |

### Description

`kubeone apply` might fail if the SSH connection is interrupted (e.g. VM is
restarted while kubeone apply is running).

### Recommendation

In this case, it's enough to run `kubeone apply` again and KubeOne should be
able to continue as usual.
