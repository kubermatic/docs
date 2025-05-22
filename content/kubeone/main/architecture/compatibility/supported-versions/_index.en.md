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

| KubeOne \ Kubernetes | 1.33 | 1.32 | 1.31 | 1.30 | 1.29[^1] |
| -------------------- | ---- | ---- | ---- | ---- | -------- |
| v1.11                | ✓    | ✓    | ✓    | ✓    |    -     |
| v1.10                | -    | ✓    | ✓    | ✓    |    -     |
| v1.9                 | -    | -    | ✓    | ✓    |    ✓     |

[^1]: Kubernetes 1.29 has reached End-of-Life (EOL) and is not supported any longer.
We strongly recommend upgrading to a newer supported Kubernetes release as soon as possible.

We recommend using a Kubernetes release that's not older than one minor release
than the latest Kubernetes release. For example, with 1.32 being the latest
release, we recommend running at least Kubernetes 1.31.

[upstream-supported-versions]: https://kubernetes.io/docs/setup/release/version-skew-policy/#supported-versions
