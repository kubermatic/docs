+++
title = "Upgrading from 1.11 to 1.12"
date = 2026-01-06T12:00:00+02:00
+++

This document contains important upgrade notes for upgrading from KubeOne 1.11 to v1.12. For the complete changelog,
please check the [complete v1.12.0 changelog on GitHub][changelog].

[changelog]: https://github.com/kubermatic/kubeone/blob/main/CHANGELOG/CHANGELOG-1.12.md

## Known Issues

Make sure to familiarize yourself with the known issues in KubeOne 1.12 before upgrading by checking the
[Known Issues document][known-issues].

[known-issues]: {{< ref "../../../known-issues" >}}

## Kubernetes Compatibility Changes

KubeOne 1.12 introduces support for Kubernetes 1.34. Support for Kubernetes 1.31 has been removed as this release
already reached End-of-Life (EOL).

If you have a Kubernetes cluster running 1.31 or earlier, you need to update to Kubernetes 1.32 or newer using KubeOne
1.11. For more information, check out the [Kubernetes compatibility document][k8s-compat].

[k8s-compat]: {{< ref "../../../architecture/compatibility/supported-versions/" >}}

## Linux Kernel Version Requirements

The minimum kernel version for Kubernetes 1.32 clusters is 4.19. It's recommended to use a kernel version 5.8 or newer.

### RHEL-like 8

RockyLinux 8 and RHEL 8 are not supported anymore because of their too old kernel version fall off minimal required
version by Kubernetes.

## Removals

`amzn2` has been completely removed.
