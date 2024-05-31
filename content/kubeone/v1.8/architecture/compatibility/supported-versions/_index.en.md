+++
title = "Kubernetes"
date = 2024-03-06T00:00:00+00:00
weight = 1

+++

## Supported Kubernetes Versions

Each KubeOne version supports Kubernetes versions supported by upstream at the
time of the KubeOne release. You can find more details about the upstream
support policy in the [Version Skew Policy document][upstream-supported-versions].

In the following table you can find the supported Kubernetes versions for the
current KubeOne version.

| KubeOne \ Kubernetes | 1.30 | 1.29 | 1.28 | 1.27[^1] | 1.26[^2] | 1.25[^2] |
| -------------------- | ---- | ---- | ---- | -------- | -------- | -------- |
| v1.8.1               | ✓    | ✓    | ✓    | ✓        | -        | -        |
| v1.8                 | -    | ✓    | ✓    | ✓        | -        | -        |
| v1.7                 | -    | -    | -    | ✓        | ✓        | ✓        |

[^1]: Kubernetes 1.27 will be reaching End-of-Life (EOL) on 2024-06-28.
We strongly recommend upgrading to a newer Kubernetes release as soon as possible.

[^2]: Kubernetes 1.26 and 1.25 have reached End-of-Life (EOL) and are not supported
any longer. We strongly recommend upgrading to a newer supported Kubernetes release
as soon as possible.

We recommend using a Kubernetes release that's not older than one minor release
than the latest Kubernetes release. For example, with 1.30 being the latest
release, we recommend running at least Kubernetes 1.29.

[upstream-supported-versions]: https://kubernetes.io/docs/setup/release/version-skew-policy/#supported-versions
