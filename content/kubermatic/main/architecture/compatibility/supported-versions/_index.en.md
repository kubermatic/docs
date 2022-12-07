+++
title = "Kubernetes"
date = 2020-09-16T20:07:15+02:00
weight = 1

+++

## Kubernetes Version Policy

A KKP minor version supports all Kubernetes versions which were supported upstream
at the time of its release. You can find more details about the upstream support
policy in the [Version Skew Policy](https://kubernetes.io/docs/setup/release/version-skew-policy/#supported-versions).

As time passes, patch versions of KKP will support new patch versions of Kubernetes
that have been released since, as well as drop old patch versions if they are
affected by critical bugs.

KKP will typically drop support of minor versions of Kubernetes which have gone EOL,
even during the lifecycle of a KKP minor version (e.g. from 2.16.1 to 2.16.2).
This of course results in any minor version of KKP being eventually limited to two
and later one minor version of Kubernetes.

One notable exception is when upgrading from an older version of Kubernetes might
require extensive migration of loads running within the updated clusters (e.g. API
version deprecations) -- in these cases KKP will maintain LIMITED support of an EOL
Kubernetes version(s) for an additional release cycle for the purpose of facilitating
these migrations.

## Supported Kubernetes Versions

In the following table you can find the supported Kubernetes versions for the
current KKP version.

| KKP version  | 1.25     | 1.24[^1] | 1.23[^1] | 1.22[^2] | 1.21[^2] | 1.20[^2] | 1.19[^2]   |
| ------------ | -------- | -------- | -------- | -------- | -------- | -------- | ---------- |
| 2.22.x[^not-out-yet] | ✓        | ✓        | ✓        | -        | -        | -        | -          |
| 2.21.x       | -        | ✓        | ✓        | ✓        | ✓        | -        | -          |
| 2.20.x       | -        | -        | ✓[^4]    | ✓        | ✓        | ✓        | -          |
| 2.19.x       | -        | -        | -        | ✓        | ✓        | ✓        | -          |
| 2.18.x[^3]   | -        | -        | -        | ✓        | ✓        | ✓        | ✓          |

[^1]: Kubernetes 1.24 and 1.23 are currently not supported on ARM64 clusters with Canal CNI and kube-proxy running in the IPVS mode.

[^2]: Kubernetes 1.19, 1.20, 1.21 and 1.22 releases have reached End-of-Life (EOL). We strongly recommend upgrading to a supported Kubernetes release as soon as possible.

[^3]: KKP 2.18 has reached End-of-Life (EOL). We strongly recommend upgrading to a supported KKP version as soon as possible.

[^4]: Kubernetes 1.23 support has been added in KKP 2.20.3.

[^not-out-yet]: KKP 2.22 has not been released yet.

Upgrades from a previous Kubernetes version are generally supported whenever a version is marked as supported, for example KKP 2.19 supports updating clusters from Kubernetes 1.20 to 1.21.
