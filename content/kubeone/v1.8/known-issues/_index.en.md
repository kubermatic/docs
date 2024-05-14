+++
title = "Known Issues"
date = 2023-02-21T09:00:00+02:00
description = "Known Issues in Kubermatic KubeOne"
weight = 99
+++

This page documents the list of known issues in Kubermatic KubeOne along with
possible workarounds and recommendations.

This list applies to KubeOne 1.8 release. For KubeOne 1.7, please consider
the [v1.7 version of this document][known-issues-1.7]. For earlier releases,
please consult the [appropriate changelog][changelogs].

[known-issues-1.7]: {{< ref "../../v1.7/known-issues" >}}
[changelogs]: https://github.com/kubermatic/kubeone/tree/main/CHANGELOG

## AzureDisk and AzureFile CSI drivers are not supported on CentOS 7

|              |                                                   |
|--------------|---------------------------------------------------|
| Status       | Mitigation provided                               |
| Severity     | Low                                               |
| GitHub issue | N/A                                               |

### Who's affected by this issue?

This issue affects only Azure clusters that are running CentOS 7.
Other CentOS-like and RHEL-like distributions, such as Rocky Linux,
are not affected.

### Description

Trying to mount a volume created using AzureDisk or AzureFile CSI driver
results in an error saying that operation is not supported.

### Mitigation

Given that [CentOS 7 is reaching end-of-life (EOL) on June 30, 2024][centos],
we strongly recommend migrating to another distribution.

If this is not doable for you at the moment, we recommend:

- Staying at KubeOne 1.7 until migrating to another supported distribution
- Using KubeOne 1.8 with an older version of AzureDisk and AzureFile CSI drivers.
  AzureDisk releases up to and including v1.28.5 and v1.29.2 are known to work
  with CentOS 7.

[centos]: https://www.redhat.com/en/topics/linux/centos-linux-eol

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
