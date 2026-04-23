+++
title = "Kubernetes"
date = 2026-04-23T00:00:00+00:00
weight = 1

+++

## Supported Kubernetes Versions

Each KubeOne version supports Kubernetes versions supported by upstream at the
time of the KubeOne release. You can find more details about the upstream
support policy in the [Version Skew Policy document][upstream-supported-versions].

In the following table you can find the supported Kubernetes versions for the
current KubeOne version.

| KubeOne \ Kubernetes | 1.35 | 1.34 | 1.33 | 1.32 | 1.31 |
| -------------------- | ---- | ---- | ---- | ---- | -----|
| v1.13                |  ✓  |  ✓  |  ✓  |  -   |  -   |
| v1.12                |  -   |  ✓  |  ✓  | ✓   |  -   |
| v1.11                |  -   |  -   |  ✓  | ✓   |  ✓  |

We recommend using a Kubernetes release that's not older than one minor release than the latest Kubernetes release. For
example, with 1.35 being the latest supported release, we recommend running at least Kubernetes 1.34.

[upstream-supported-versions]: https://kubernetes.io/docs/setup/release/version-skew-policy/#supported-versions
