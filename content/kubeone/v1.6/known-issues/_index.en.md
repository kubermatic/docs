+++
title = "Known Issues"
date = 2023-02-21T09:00:00+02:00
description = "Known Issues in Kubermatic KubeOne"
weight = 99
+++

This page documents the list of known issues in Kubermatic KubeOne along with
possible workarounds and recommendations.

This list applies to KubeOne 1.6 releases. For KubeOne 1.5, please consider
the [v1.5 version of this document][known-issues-1.5]. For earlier releases,
please consult the [appropriate changelog][changelogs].

[known-issues-1.5]: {{< ref "../../v1.5/known-issues" >}}
[changelogs]: https://github.com/kubermatic/kubeone/tree/release/v1.6/CHANGELOG

## `node-role.kubernetes.io/master` taint not removed on upgrade when using KubeOne 1.6.0-rc.1

|              |                                                   |
|--------------|---------------------------------------------------|
| Status       | Fixed in KubeOne 1.6.0                            |
| Severity     | Critical                                          |
| GitHub issue | https://github.com/kubermatic/kubeone/pull/2688   |

Users who:

- used **KubeOne 1.6.0-rc.1** or built KubeOne manually on
  **[commit up to `8291a9f`][8291a9f]**, AND
- provisioned clusters running Kubernetes 1.25 OR upgraded clusters running
  Kubernetes 1.24 to Kubernetes 1.25

**are affected by this issue**.

[8291a9f]: https://github.com/kubermatic/kubeone/commit/8291a9f13408f7bc10e248c0c014d94e35e4fcad

### Description

Kubernetes removed the `node-role.kubernetes.io/master` taint in 1.25.
However, we had a bug in KubeOne that enforced this taint up until Kubernetes
1.26. Even if we don't put that taint for 1.26 clusters, Kubeadm is not going
to remove it upon upgrading to 1.26. That's because the migration logic that
was removing that taint has been already removed in 1.26.

### Recommendation

If you're affected by this issue, you have to manually untaint affected
control plane nodes. You can do that by using the following command:

```shell
kubectl taint nodes node-role.kubernetes.io/master- --all
```

**Not doing so might cause a major outage as we (both KubeOne and Kubeadm) stop
tolerating the `node-role.kubernetes.io/master` taint.**

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

**We do NOT recommend upgrading to KubeOne 1.6 and 1.5 at this time if you're 
using Calico VXLAN. Follow the linked GitHub issue and this page for updates.**

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

### 3. Networking issues with Cilium and Systemd based distributions

|              |                                                  |
|--------------|--------------------------------------------------|
| Status       | Workaround available                             |
| Severity     | High                                             |
| GitHub issue | https://github.com/cilium/cilium/issues/18706    |

### Description

A KubeOne clusters with Cilium CNI running on a systemd based distribution can get into an unstable network state.
We do not necessarily meet the [requirements for systemd based distribution](https://docs.cilium.io/en/v1.13/operations/system_requirements/#systemd-based-distributions) by default.

An update of systemd caused an incompatibility with Cilium. With that change systemd is managing external routes by default.
On a change in the network this can cause systemd to delete Cilium owned resources.

**Recommendation**

* Adjust systemd manually based on the [Cilium requirements](https://docs.cilium.io/en/v1.13/operations/system_requirements/#systemd-based-distributions).

* Use a custom OSP and configure systemd:

````yaml
apiVersion: operatingsystemmanager.k8c.io/v1alpha1
kind: CustomOperatingSystemProfile
metadata:
  name: cilium-ubuntu
  namespace: kubermatic
spec:
  bootstrapConfig:
    files:
      - content:
          inline:
            data: |
              [Network]
              ManageForeignRoutes=no
              ManageForeignRoutingPolicyRules=no
            encoding: b64
        path: /etc/systemd/networkd.conf
        permissions: 644
    modules:
      runcmd:
        - systemctl restart systemd-networkd.service
````
