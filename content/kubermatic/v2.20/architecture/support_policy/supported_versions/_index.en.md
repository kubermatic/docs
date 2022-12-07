+++
title = "Supported Versions"
date = 2020-09-16T20:07:15+02:00
weight = 5

+++

This document describes the Kubernetes support and KKP versioning itself.

## Supported KKP Versions

KKP versions are expressed as x.y.z, where x is the major version, y is the
minor version, and z is the patch version.

KKP follows the Kubernetes release model and cycle, though for practical reasons
releases are a bit delayed to ensure compatibility with Kubernetes. In general,
the latest three minor versions of KKP are supported, i.e. 2.19, 2.18 and 2.17.
With the release of a new minor KKP version, support for the oldest supported
KKP version is dropped.

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

| KKP version | 1.23  |1.22[^1] | 1.21[^1] | 1.20[^1] | 1.19[^1] | 1.18[^1] |
| ----------- | ----- |-------- | -------- | -------- | -------- | -------- |
| 2.20.x      | ✓[^3] | ✓       | ✓        | ✓        | -        | -        |
| 2.19.x      | -     | ✓       | ✓        | ✓        | -        | -        |
| 2.18.x      | -     | ✓       | ✓        | ✓        | ✓        | -        |
| 2.17.x      | -     | -       | ✓        | ✓        | ✓        | ✓        |
| 2.16.x      | -     | -       | -        | ✓        | ✓        | ✓        |

[^1]: Kubernetes 1.22 and lower have reached End-of-Life (EOL). We strongly recommend upgrading to a supported Kubernetes release as soon as possible.

[^2]: KKP 2.18 and lower have reached End-of-Life (EOL). We strongly recommend upgrading to a supported KKP release as soon as possible.

[^3]: Kubernetes 1.23 support has been added in KKP 2.20.3.

Upgrades from a previous Kubernetes version are generally supported whenever a
version is marked as supported, for example KKP 2.17 supports updating clusters
from Kubernetes 1.18 to 1.21.
