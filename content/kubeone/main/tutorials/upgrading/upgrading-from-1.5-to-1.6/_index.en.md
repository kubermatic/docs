+++
title = "Upgrading from 1.5 to 1.6"
date = 2023-02-21T12:00:00+02:00
+++

This document contains important upgrade notes for upgrading from KubeOne 1.5
to 1.6. For the complete changelog, please check the
[complete v1.6.0 changelog on GitHub][changelog].

[changelog]: https://github.com/kubermatic/kubeone/blob/main/CHANGELOG/CHANGELOG-1.6.md#v160---2023-02-23

## Known Issues

Make sure to familiarize yourself with the known issues in KubeOne 1.6 before
upgrading by checking the [Known Issues document][known-issues].

[known-issues]: {{< ref "../../../known-issues" >}}

## Kubernetes Compatibility Changes

KubeOne 1.6 introduces support for Kubernetes 1.26 and 1.25. Support for
Kubernetes versions prior to 1.24 is removed as those releases already
reached End-of-Life (EOL).

If you have a Kubernetes cluster running 1.23 or earlier, you need to update to
Kubernetes 1.24 or newer using KubeOne 1.5. For more information, check out
the [Kubernetes compatibility document][k8s-compat].

[k8s-compat]: {{< ref "../../../architecture/compatibility/supported-versions/" >}}

## Changes in The `node-role` Taints

Starting with Kubernetes 1.25, Kubeadm is not applying the
`node-role.kubernetes.io/master:NoSchedule` taint to the control plane nodes
any longer. The taint will be removed from existing nodes upon upgrading
from 1.24 to 1.25.

KubeOne already ensures that all pods have a proper toleration for the new
`node-role.kubernetes.io/control-plane:NoSchedule` taint upon upgrading from
1.23 to 1.24. We believe that this change shouldn't affect anyone, but
we want to raise awareness for it.

KubeOne will also perform checks to make sure that:

- there's no `node-role.kubernetes.io/master:NoSchedule` taint set on nodes in
  the KubeOneCluster manifest for clusters running Kubernetes 1.25+
- there are no nodes in the cluster running Kubernetes 1.25+ with the
  `node-role.kubernetes.io/master:NoSchedule` taint upon running
  `kubeone apply`

## OpenStack In-Tree Cloud Provider Removal

If you have OpenStack clusters running the in-tree cloud provider
(`.cloudProvider.external` is false or unset), you'll not be able to upgrade
those clusters to Kubernetes 1.26 as the OpenStack in-tree cloud provider has
been removed in Kubernetes 1.26. You have to [migrate your OpenStack clusters
to the external CCM/CSI as described here][ccm-migration].

[ccm-migration]: {{< ref "../../../guides/ccm-csi-migration/" >}}

## Other Notable Changes

- Example Terraform configs for all providers are now using Ubuntu 22.04 by
  default. If you're using the latest Terraform configs with an existing
  cluster, make sure to bind the operating system/image to the image that
  you're currently using, otherwise your instances will get recreated
- `control_plane_replicas` variable in Terraform configs for Hetzner is renamed
  to `control_plane_vm_count`. If you set the old variable explicitly, make
  sure to migrate to the new variable before migrating to the new configs
- Forbid PodSecurityPolicy feature for Kubernetes clusters running 1.25 and
  newer. PodSecurityPolicies got removed from Kubernetes in 1.25. For more
  details, see [the official blog post](https://kubernetes.io/blog/2021/04/06/podsecuritypolicy-deprecation-past-present-and-future/)
- Image references are changed from `k8s.gcr.io` to `registry.k8s.io`. This is
  done to keep up with [the latest upstream changes](https://github.com/kubernetes/enhancements/tree/master/keps/sig-release/3000-artifact-distribution).
  Please ensure that any mirrors you use are able to host `registry.k8s.io`
  and/or that firewall rules are going to allow access to `registry.k8s.io` to
  pull images. This change has been already introduced as part of KubeOne 1.5.4
  and 1.4.12 patch releases
- `.cloudProvider.csiConfig` is now a mandatory field for vSphere clusters
  using the external cloud provider (`.cloudProvider.external: true`)

For information about other changes, we recommend checking out the
[changelog][changelog].
