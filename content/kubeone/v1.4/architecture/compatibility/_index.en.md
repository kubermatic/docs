+++
title = "Compatibility"
date = 2021-02-10T12:00:00+02:00
weight = 4
enableToc = true
+++

This document shows what are compatible Kubernetes, Terraform, and operating
systems versions with the current KubeOne version.

## Supported Providers

KubeOne works on any infrastructure out of the box. Natively supported
providers have support for additional features and are frequently tested with
the current KubeOne version. The additional features include the KubeOne
Terraform integration and the integration with Kubermatic machine-controller.

KubeOne supports AWS, Azure, DigitalOcean, GCP, Hetzner Cloud, Nutanix\*,
OpenStack, Packet, and VMware vSphere.

\* Nutanix is supported as of KubeOne 1.4.0.

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

| KubeOne version | 1.23  | 1.22\*  | 1.21\*    | 1.20\*    | 1.19\*   |
| --------------- | ----- | ------- | --------- | --------- | -------- |
| v1.4+           | ✓     | ✓       | ✓         | ✓         | -        |
| v1.3            | -     | ✓       | ✓         | ✓         | ✓        |
| v1.2            | -     | -       | ✓         | ✓         | ✓        |

\* Kubernetes 1.22, 1.21, 1.20, and 1.19 have reached End-of-Life (EOL).
We strongly recommend upgrading to a supported Kubernetes release as soon as
possible.

We recommend using a Kubernetes release that's not older than one minor release
than the latest Kubernetes release. For example, with 1.23 being the latest
release, we recommend running at least Kubernetes 1.22.

## Supported Terraform Versions

The KubeOne Terraform integration requires Terraform **v1.0** or newer.

For more details, you can check the `versions.tf` file that comes with the
example Terraform configs ([example `versions.tf` file][aws-versions-tf]).

## Supported Operating Systems

The following operating systems are supported:

* Ubuntu 18.04 (Bionic)
* Ubuntu 20.04 (Focal)
* CentOS 7
* CentOS 8
* RHEL 8.0, 8.1, 8.2, 8.3\*, 8.4\*
* Flatcar
* Amazon Linux 2

\* RHEL 8.3 and 8.4 are supported only with KubeOne 1.3.3 and newer.

[upstream-supported-versions]: https://kubernetes.io/docs/setup/release/version-skew-policy/#supported-versions
[kubernetes-issue-93194]: https://github.com/kubernetes/kubernetes/issues/93194
[terraform-configs]: https://github.com/kubermatic/kubeone/tree/master/examples/terraform
[aws-versions-tf]: https://github.com/kubermatic/kubeone/blob/master/examples/terraform/aws/versions.tf
