+++
title = "Upgrading from 1.13 to 1.14"
date = 2026-07-29T12:00:00+02:00
+++

This document contains important upgrade notes for upgrading from KubeOne 1.13 to v1.14. For the complete changelog,
please check the [complete v1.14.0 changelog on GitHub][changelog].

[changelog]: https://github.com/kubermatic/kubeone/blob/main/CHANGELOG/CHANGELOG-1.14.md

## Known Issues

Make sure to familiarize yourself with the known issues in KubeOne 1.13 before upgrading by checking the
[Known Issues document][known-issues].

[known-issues]: {{< ref "../../../known-issues" >}}

## Kubernetes Compatibility Changes

KubeOne 1.14 introduces support for Kubernetes 1.36. Support for Kubernetes 1.33 has been removed as this release
already reached End-of-Life (EOL).

If you have a Kubernetes cluster running 1.33 or earlier, you need to update to Kubernetes 1.34 or newer using KubeOne
1.13. For more information, check out the [Kubernetes compatibility document][k8s-compat].

[k8s-compat]: {{< ref "../../../architecture/compatibility/supported-versions/" >}}

## Linux Kernel Version Requirements

The minimum kernel version for Kubernetes 1.34 clusters is 5.2. It's recommended to use a kernel version 5.13 or later.

More information at https://kubernetes.io/docs/reference/node/kernel-version-requirements/.

## CCM/CSI migration removed

All CCM/CSI migration tooling has been removed. The `kubeone migrate to-ccm-csi` command is now a no-op (kept only for backward compatibility) since Kubernetes has fully moved on from in-tree cloud providers and CSI migration. If any of your clusters are still running with the in-tree cloud provider (`.cloudProvider.external: false`) and haven't completed the CCM/CSI migration, complete it using KubeOne v1.13 or earlier **before** upgrading to v1.14. See [#4096](https://github.com/kubermatic/kubeone/pull/4096).
