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

KKP will typically drop support of minor versions of Kubernetes which have gone EOL.

One notable exception is when upgrading from an older version of Kubernetes might
require extensive migration of loads running within the updated clusters (e.g. API
version deprecations) -- in these cases KKP will maintain LIMITED support of an EOL
Kubernetes version(s) for an additional release cycle for the purpose of facilitating
these migrations.

## Supported Kubernetes Versions

In the following table you can find the supported Kubernetes versions for the
current KKP version.

| KKP version          | 1.36 | 1.35 | 1.34 | 1.33[^2] | 1.32[^2] | 1.31[^2] |
| -------------------- | ---- | ---- | ---- | ---- | ---- | ---- |
| 2.31.x               | ✓    | ✓    | ✓    | ✓    | --   | --   |
| 2.30.x               | --   | ✓    | ✓    | ✓    | ✓    | --   |
| 2.29.x               | --   | --   | ✓    | ✓    | ✓    | ✓    |

[^2]: Kubernetes releases below version 1.34 have reached End-of-Life (EOL). We strongly
recommend upgrading to a supported Kubernetes release as soon as possible. Refer to the
[Kubernetes website](https://kubernetes.io/releases/) for more information on the supported
releases.

The default Kubernetes version for new user clusters created with KKP 2.31 is v1.35.7.

Upgrades from a previous Kubernetes version are generally supported whenever a version is
marked as supported, for example KKP 2.31 supports updating clusters from Kubernetes 1.35 to 1.36.

## Provider Incompatibilities

KKP may have incompatibilities with cloud providers, e.g. because their in-tree cloud provider
implementation has been removed from upstream Kubernetes. From KKP 2.27.x, no provider incompatibilities exist.
