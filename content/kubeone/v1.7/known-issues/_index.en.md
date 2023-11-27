+++
title = "Known Issues"
date = 2023-09-08T09:00:00+02:00
description = "Known Issues in Kubermatic KubeOne"
weight = 99
+++

This page documents the list of known issues in Kubermatic KubeOne along with
possible workarounds and recommendations.

This list applies to KubeOne 1.7 releases. For KubeOne 1.6, please consider
the [v1.6 version of this document][known-issues-1.6]. For earlier releases,
please consult the [appropriate changelog][changelogs].

[known-issues-1.6]: {{< ref "../../v1.6/known-issues" >}}
[changelogs]: https://github.com/kubermatic/kubeone/tree/main/CHANGELOG

## KubeOne is unable to upgrade AzureDisk CSI driver upon upgrading KubeOne from 1.6 to 1.7

|              |                                                   |
|--------------|---------------------------------------------------|
| Status       | Fixed in KubeOne 1.7.2                            |
| Severity     | High for clusters running on Azure                |
| GitHub issue | https://github.com/kubermatic/kubeone/pull/2971   |

Users who used **KubeOne 1.6 or earlier** to provision a cluster running on
Microsoft Azure **are affected by this issue**.

### Description

We upgraded AzureDisk CSI driver to a newer version in KubeOne 1.7.
This upgrade changed the subject name in the
`csi-azuredisk-node-secret-binding` ClusterRoleBinding object from
`csi-azuredisk-node-secret-role` to `csi-azuredisk-node-sa`. However, the
subject name is immutable, requiring the ClusterRoleBinding object to be
replaced. Trying to upgrade KubeOne from 1.6 to 1.7.0 or 1.7.1 results in
KubeOne getting stuck while updating the AzureDisk CSI driver.

### Recommendation

KubeOne 1.7.2 is configured to replace the `csi-azuredisk-node-secret-binding`
ClusterRoleBinding object if the subject name is
`csi-azuredisk-node-secret-role`. We recommend using KubeOne 1.7.2 or newer
if you're upgrading from KubeOne 1.6.

This issue can also be mitigated manually by removing the ClusterRoleBinding
object if KubeOne is stuck trying to upgrade the AzureDisk CSI driver:

```shell
kubectl delete clusterrolebinding csi-azuredisk-node-secret-binding
```

## Cilium CNI is not working on clusters running CentOS 7

|              |                                                   |
|--------------|---------------------------------------------------|
| Status       | Known Issue                                       |
| Severity     | Low                                               |
| GitHub issue | N/A                                               |

### Description

Cilium CNI is not supported on CentOS 7 because it's using too older kernel
version which is not supported by Cilium itself. For more details, consider
[the official Cilium documentation][cilium-requirements].

[cilium-requirements]: https://docs.cilium.io/en/v1.13/operations/system_requirements/

### Recommendation

Please consider using an operating system with a newer kernel version, such
as Ubuntu, Rocky Linux, and Flatcar. See
[the official Cilium documentation][cilium-requirements] for a list of
operating systems and versions supported by Cilium.

## Internal Kubernetes endpoints unreachable on vSphere with Cilium/Canal

|              |                                                   |
|--------------|---------------------------------------------------|
| Status       | Workaround available                              |
| Severity     | Low                                               |
| GitHub issue | https://github.com/cilium/cilium/issues/21801     |

### Description

#### Symptoms

* Unable to perform CRUD operations on resources governed by webhooks (e.g. ValidatingWebhookConfiguration, MutatingWebhookConfiguration, etc.). The following error is observed:

```sh
Internal error occurred: failed calling webhook "webhook-name": failed to call webhook: Post "https://webhook-service-name.namespace.svc:443/webhook-endpoint": context deadline exceeded
```

* Unable to reach internal Kubernetes endpoints from pods/nodes.
* ICMP is working but TCP/UDP is not.

#### Cause

On recent enough VMware hardware compatibility version (i.e >= 15 or maybe >= 14), CNI connectivity breaks because of hardware segmentation offload. `cilium-health status` has ICMP connectivity working, but not TCP connectivity. cilium-health status may also fail completely.

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
