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

| KubeOne version | 1.26  | 1.25  | 1.24[^1] | 1.23[^2] | 1.22[^2] | 1.21[^2] | 1.20[^2] |
| --------------- | ----- | ----- | -------- | -------- | -------- | -------- | -------- |
| v1.6            | ✓     | ✓     | ✓        | -        | -        | -        | -        |
| v1.5            | -     | -     | ✓        | ✓        | ✓        | -        | -        |
| v1.4            | -     | -     | -        | ✓        | ✓        | ✓        | ✓        |

[^1]: Kubernetes 1.24 is scheduled to reach End-of-Life (EOL) on 2023-07-28.
We strongly recommend upgrading to a supported Kubernetes release as soon as possible.

[^2]: Kubernetes 1.23, 1.22, 1.21 and 1.20 have reached End-of-Life (EOL).
We strongly recommend upgrading to a supported Kubernetes release as soon as possible.

We recommend using a Kubernetes release that's not older than one minor release
than the latest Kubernetes release. For example, with 1.26 being the latest
release, we recommend running at least Kubernetes 1.25.

[upstream-supported-versions]: https://kubernetes.io/docs/setup/release/version-skew-policy/#supported-versions
[kubernetes-issue-93194]: https://github.com/kubernetes/kubernetes/issues/93194
