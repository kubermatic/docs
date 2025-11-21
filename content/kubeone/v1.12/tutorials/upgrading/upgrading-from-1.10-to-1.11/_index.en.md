+++
title = "Upgrading from 1.10 to 1.11"
date = 2025-04-15T12:00:00+02:00
+++

This document contains important upgrade notes for upgrading from KubeOne 1.10
to v1.11. For the complete changelog, please check the
[complete v1.11.0 changelog on GitHub][changelog].

[changelog]: https://github.com/kubermatic/kubeone/blob/release/v1.12/CHANGELOG/CHANGELOG-1.11.md

## Known Issues

Make sure to familiarize yourself with the known issues in KubeOne 1.11 before
upgrading by checking the [Known Issues document][known-issues].

[known-issues]: {{< ref "../../../known-issues" >}}

## Kubernetes Compatibility Changes

KubeOne 1.11 introduces support for Kubernetes 1.33. Support for Kubernetes 1.30
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
