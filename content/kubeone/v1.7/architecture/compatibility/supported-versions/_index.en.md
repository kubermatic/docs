+++
title = "Kubernetes"
date = 2020-09-16T20:07:15+02:00
weight = 1

+++

## Supported Kubernetes Versions

Each KubeOne version supports Kubernetes versions supported by upstream at the
time of the KubeOne release. You can find more details about the upstream
support policy in the [Version Skew Policy document][upstream-supported-versions].

In the following table you can find the supported Kubernetes versions for the
current KubeOne version.

{{% notice warning %}}
KubeOne 1.5 and 1.6 support only Kubernetes 1.22 and newer. Clusters running
Kubernetes 1.21 or older must be upgraded with an older KubeOne release
according to the table below.
{{% /notice %}}

| KubeOne version | 1.28  | 1.27  | 1.26  | 1.25  | 1.24[^1] |
| --------------- | ----- | ----- | ----- | ----- | -------- |
| v1.7            | -     | ✓     | ✓     | -     | -        |
| v1.6            | -     | ✓     | ✓     | ✓     | ✓        |

[^1]: Kubernetes 1.24 has reached End-of-Life (EOL) on 2023-07-28.
We strongly recommend upgrading to a supported Kubernetes release as soon as possible.

We recommend using a Kubernetes release that's not older than one minor release
than the latest Kubernetes release. For example, with 1.27 being the latest
release, we recommend running at least Kubernetes 1.26.

[upstream-supported-versions]: https://kubernetes.io/docs/setup/release/version-skew-policy/#supported-versions
