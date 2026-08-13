+++
title = "Upgrading from 1.9 to 1.10"
date = 2025-04-15T12:00:00+02:00
+++

This document contains important upgrade notes for upgrading from KubeOne 1.9
to 1.10. For the complete changelog, please check the
[complete v1.10.0 changelog on GitHub][changelog].

[changelog]: https://github.com/kubermatic/kubeone/blob/main/CHANGELOG/CHANGELOG-1.10.md

## Known Issues

Make sure to familiarize yourself with the known issues in KubeOne 1.10 before
upgrading by checking the [Known Issues document][known-issues].

[known-issues]: {{< ref "../../../known-issues" >}}

## Kubernetes Compatibility Changes

KubeOne 1.9 introduces support for Kubernetes 1.32. Support for Kubernetes 1.29
has been removed as this release already reached End-of-Life (EOL).

If you have a Kubernetes cluster running 1.29 or earlier, you need to update to
Kubernetes 1.30 or newer using KubeOne 1.9. For more information, check out
the [Kubernetes compatibility document][k8s-compat].

[k8s-compat]: {{< ref "../../../architecture/compatibility/supported-versions/" >}}

## Linux Kernel Version Requirements

The minimum kernel version for Kubernetes 1.32 clusters is 4.19. It's recommended to use a kernel version 5.8 or
newer.

Trying to provision a cluster with Kubernetes 1.32 or upgrade an existing cluster to Kubernetes 1.32, where nodes are
not satisfying this requirement, will result in a pre-flight check failure.

Some operating system versions, such as RHEL 8, do not meet this requirement and therefore do not support
Kubernetes 1.32 or newer.

## Calico VXLAN Optional Addon Removal

The Calico VXLAN optional addon has been removed from KubeOne. We have included this addon as an example showing how to
create a custom addon to deploy a CNI. However, this addon has been non-function for the past several release, and we
made the decision to remove it from KubeOne.

If you still need and use this addon, we advise using the [addons mechanism] to deploy it. You can find the addon
source manifests on an earlier KubeOne release branch, e.g. [`release/v1.9`][calico-vxlan-1-9].

[addons mechanism]: {{< ref "../../../guides/addons/" >}}
[calico-vxlan-1-9]: https://github.com/kubermatic/kubeone/tree/9bdb7c73dc3cae7f89cc7553cbd80195b8669698/addons/calico-vxlan

## Disallow Using machine-controller And operating-system-manager With `.cloudProvider.none`

Starting with this release, using machine-controller and/or operating-system-manager with the cloud provider none
(`.cloudProvider.none`) is disallowed. This change has been introduced because both components are tied to a cloud
provider and we can't provide proper support for all functionalities if we don't what cloud provider are you using.

If you're affected by this change, you have to either disable machine-controller and/or operating-system-manager,
or switch from the cloud provider `none` to a supported cloud provider.

For information about other changes, we recommend checking out the
[changelog][changelog].
