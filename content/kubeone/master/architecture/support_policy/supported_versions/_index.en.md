+++
title = "Supported Versions"
date = 2022-04-25T15:00:00+02:00
weight = 5

+++

This document describes the Kubernetes support and KubeOne versioning itself.

## Supported KubeOne Versions

KubeOne versions are expressed as x.y.z, where x is the major version, y is the
minor version, and z is the patch version.

KubeOne follows the Kubernetes release model and cycle, though for practical reasons
releases are a bit delayed to ensure compatibility with Kubernetes. In general,
the latest three minor versions of KubeOne are supported, i.e. 1.4, 1.3 and 1.2.
With the release of a new minor KubeOne version, support for the oldest supported
KubeOne version is dropped.

## Kubernetes Version Policy

A KubeOne minor version supports all Kubernetes versions which were supported upstream
at the time of its release. You can find more details about the upstream support
policy in the [Version Skew Policy](https://kubernetes.io/docs/setup/release/version-skew-policy/#supported-versions).

As time passes, patch versions of KubeOne will support new patch versions of Kubernetes
that have been released since, as well as drop old patch versions if they are
affected by critical bugs.

KubeOne will typically drop support of minor versions of Kubernetes which have gone EOL,
even during the lifecycle of a KubeOne minor version (e.g. from 1.4.1 to 1.4.2).
This of course results in any minor version of KubeOne being eventually limited to two
and later one minor version of Kubernetes.

One notable exception is when upgrading from an older version of Kubernetes might
require extensive migration of loads running within the updated clusters (e.g. API
version deprecations) -- in these cases KubeOne will maintain LIMITED support of an EOL
Kubernetes version(s) for an additional release cycle for the purpose of facilitating
these migrations.

## Supported Kubernetes Versions

In the following table you can find the supported Kubernetes versions for the
current KubeOne version.

| KubeOne version | 1.23\* | 1.22 | 1.21 | 1.20\*\* | 1.19\*\*   | 1.18\*\*   |
| ----------- | ------ | ---- | ---- | -------- | ---------- | ---------- |
| 1.4.x      | -      | ✓    | ✓    | ✓        | -          | -          |
| 1.3.x      | -      | ✓    | ✓    | ✓        | -          | -          |
| 1.2.x      | -      | ✓    | ✓    | ✓        | ✓          | -          |
| 1.1.x      | -      | -    | ✓    | ✓        | ✓          | ✓          |
| 1.0.x      | -      | -    | -    | ✓        | ✓          | ✓          |

\* Kubernetes 1.23 is currently not supported on ARM64 clusters with Canal CNI
and kube-proxy running in the IPVS mode.

\*\* Kubernetes 1.18, 1.19 and 1.20 releases have reached End-of-Life (EOL). We
strongly recommend upgrading to a supported Kubernetes release as soon as
possible.

Upgrades from a previous Kubernetes version are generally supported whenever a
version is marked as supported, for example KubeOne x.y supports updating clusters
from Kubernetes 1.a to 1.b.
