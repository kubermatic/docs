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
KubeOne 1.4 supports only Kubernetes 1.20 and newer. Clusters running
Kubernetes 1.19 or older must be upgraded with an older KubeOne release
according to the table below.
{{% /notice %}}

| KubeOne version | 1.24  | 1.23  | 1.22  | 1.21\*  | 1.20\*\*  | 1.19\*\*   |
| --------------- | ----- | ----- | ----- | ------- | --------- | ---------- |
| v1.5            | ✓     | ✓     | ✓     | -       | -         | -          |
| v1.4            | -     | ✓     | ✓     | ✓       | ✓         | -          |
| v1.3            | -     | -     | ✓     | ✓       | ✓         | ✓          |

\* Kubernetes 1.21 is in the [maintenance mode] which means that only critical
and security issues are fixed. It's strongly recommended to upgrade to a newer
Kubernetes version as soon as possible.

\*\* Kubernetes 1.20 and 1.19 have reached End-of-Life (EOL). We strongly
recommend upgrading to a supported Kubernetes release as soon as possible.

We recommend using a Kubernetes release that's not older than one minor release
than the latest Kubernetes release. For example, with 1.24 being the latest
release, we recommend running at least Kubernetes 1.23.

[upstream-supported-versions]: https://kubernetes.io/docs/setup/release/version-skew-policy/#supported-versions
[maintenance mode]: https://kubernetes.io/releases/patch-releases/#support-period
[kubernetes-issue-93194]: https://github.com/kubernetes/kubernetes/issues/93194
