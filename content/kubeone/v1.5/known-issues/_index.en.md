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

[changelogs]: https://github.com/kubermatic/kubeone/tree/main/CHANGELOG

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

## Canal CNI crashing after upgrading from KubeOne 1.x to 1.5

|              |                                                                             |
|--------------|-----------------------------------------------------------------------------|
| Status       | Fixed in KubeOne 1.5.4                                                      |
| Severity     | Low; rare issue affecting only clusters created with older KubeOne versions |
| GitHub issue | https://github.com/projectcalico/calico/issues/6442                         |

### Description

Cluster created with older KubeOne versions might be affected by an issue
where Canal (Calico) pods are stuck in CrashLoopBackoff after upgrading to
KubeOne 1.5. This is caused by upgrading Canal from an older version to v3.23.

### Recommendation

This issue is fixed in Calico v3.23.4+ which is used in KubeOne 1.5.4+

If you're encountering this issue, we strongly recommend upgrading to the latest
KubeOne patch release and running `kubeone apply` to upgrade you Canal CNI.

Alternatively, workaround is to manually modify the `default-ipv4-ippool`
`ippools.crd.projectcalico.org` object to add `vxlanMode: Never`. In this case,
see the linked upstream GitHub issue for more details.

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

If you're affected by this issue, we recommend creating VMs with a newer Flatcar
version or following the [cgroups v2 migration instructions][flatcar-cgroups].

[flatcar-cgroups]: https://www.flatcar.org/docs/latest/container-runtimes/switching-to-unified-cgroups#migrating-old-nodes-to-unified-cgroups

## vSphere CSI webhook certificates are generated with an invalid domain/FQDN

|              |                                                   |
|--------------|---------------------------------------------------|
| Status       | Fixed by [#2366](https://github.com/kubermatic/kubeone/pull/2366) in [KubeOne 1.5.1](https://github.com/kubermatic/kubeone/releases/tag/v1.5.1) |
| Severity     | High                                              |
| GitHub issue | https://github.com/kubermatic/kubeone/issues/2350 |

### Description

In KubeOne 1.5.0 we moved the vSphere CSI driver from the `kube-system`
namespace to the `vmware-system-csi` namespace. However, we didn't update the
domain/FQDN in certificates for CSI webhooks to use the new namespace. This
causes issues when communicating with the CSI webhooks as described in the
GitHub issue.

### Recommendation

This issue has been fixed in KubeOne 1.5.1, so we advise upgrading your KubeOne
installation to 1.5.1 or newer. You need to run `kubeone apply` to regenerate
certificates after upgrading KubeOne.

## CoreDNS PodDisruptionBudget is not cleaned up when disabled

|              |                                                     |
|--------------|-----------------------------------------------------|
| Status       | Fixed by [#2364](https://github.com/kubermatic/kubeone/pull/2364) in [KubeOne 1.5.1](https://github.com/kubermatic/kubeone/releases/tag/v1.5.1) |
| Severity     | Low                                                 |
| GitHub issue | https://github.com/kubermatic/kubeone/issues/2322   |

### Description

If the CoreDNS PodDisruptionBudget is enabled in the KubeOneCluster API,
and then disabled, `kubeone apply` will not remove the PDB object from the
cluster.

### Recommendation

This issue has been fixed in KubeOne 1.5.1, so we advise upgrading your KubeOne
installation to 1.5.1 or newer.

## `kubeone apply` might fail to recover if the SSH connection is interrupted

|              |                                                     |
|--------------|-----------------------------------------------------|
| Status       | Fixed by [#2345](https://github.com/kubermatic/kubeone/pull/2345) in [KubeOne 1.5.1](https://github.com/kubermatic/kubeone/releases/tag/v1.5.1) |
| Severity     | Low                                                 |
| GitHub issue | https://github.com/kubermatic/kubeone/issues/2319   |

### Description

`kubeone apply` might fail if the SSH connection is interrupted (e.g. VM is
restarted while kubeone apply is running).

### Recommendation

This issue has been fixed in KubeOne 1.5.1, so we advise upgrading your KubeOne
installation to 1.5.1 or newer.

## Internal Kubernetes endpoints unreachable on vSphere with Cilium/Canal

|              |                                                   |
|--------------|---------------------------------------------------|
| Status       | Workaround available                              |
| Severity     | Low                                               |
| GitHub issue | https://github.com/cilium/cilium/issues/21801 |

### Description
#### Symptoms

* Unable to perform CRUD operations on resources governed by webhooks (e.g. ValidatingWebhookConfiguration, MutatingWebhookConfiguration, etc.). The following error is observed:

```sh
Internal error occurred: failed calling webhook "webhook-name": failed to call webhook: Post "https://webhook-service-name.namespace.svc:443/webhook-endpoint": context deadline exceeded
```

* Unable to reach internal Kubernetes endpoints from pods/nodes.
* ICMP is working but TCP/UDP is not.

#### Cause

On recent enough VMware hardware compatibility version (i.e >=15 or maybe >=14), CNI connectivity breaks because of hardware segmentation offload. `cilium-health status` has ICMP connectivity working, but not TCP connectivity. cilium-health status may also fail completely.

### Recommendation

```sh
sudo ethtool -K ens192 tx-udp_tnl-segmentation off
sudo ethtool -K ens192 tx-udp_tnl-csum-segmentation off
```

These flags are related to the hardware segmentation offload done by the vSphere driver VMXNET3. We have observed this issue for both Cilium and Canal CNI running on Ubuntu 22.04.

We have two options to configure these flags for KubeOne installations:

* When configuring the VM template, set these flags as well.
* Create a [custom Operating System Profile]({{< ref "../architecture/operating-system-manager/usage#using-custom-operatingsystemprofile" >}}) and configure the flags there.

### References

* <https://github.com/cilium/cilium/issues/13096>
* <https://github.com/cilium/cilium/issues/21801>