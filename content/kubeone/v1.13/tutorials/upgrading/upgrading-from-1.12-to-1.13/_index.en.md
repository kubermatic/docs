+++
title = "Upgrading from KubeOne 1.12 to 1.13"
date = 2026-04-09T12:00:00+02:00
+++

This document contains important upgrade notes for upgrading from KubeOne 1.12 to v1.13. For the complete changelog,
please check the [complete v1.13.0 changelog on GitHub][changelog].

[changelog]: https://github.com/kubermatic/kubeone/blob/main/CHANGELOG/CHANGELOG-1.13.md

## Known Issues

Make sure to familiarize yourself with the known issues in KubeOne 1.13 before upgrading by checking the
[Known Issues document][known-issues].

[known-issues]: {{< ref "../../../known-issues" >}}

## Kubernetes Compatibility Changes

KubeOne 1.13 introduces support for Kubernetes 1.35. Support for Kubernetes 1.32 has been removed as this release
already reached End-of-Life (EOL).

If you have a Kubernetes cluster running 1.32 or earlier, you need to update to Kubernetes 1.33 or newer using KubeOne
1.12. For more information, check out the [Kubernetes compatibility document][k8s-compat].

[k8s-compat]: {{< ref "../../../architecture/compatibility/supported-versions/" >}}

## Linux Kernel Version Requirements

The minimum kernel version for Kubernetes 1.33 clusters is 4.19. It's recommended to use a kernel version 5.8 or newer.

More information at https://kubernetes.io/docs/reference/node/kernel-version-requirements/.

### RHEL-like 8

RockyLinux 8 and RHEL 8 are not supported anymore because of their too old kernel version falling below the minimum
required version by Kubernetes.
