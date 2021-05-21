+++
title = "Compatibility"
date = 2020-07-30T12:00:00+02:00
weight = 3
+++

This document shows what are compatible Kubernetes, Terraform, and operating
systems versions with the current KubeOne version.

## Supported Providers

KubeOne works on any infrastructure out of the box. Natively supported
providers have support for additional features and are frequently tested with
the current KubeOne version. The additional features include the KubeOne
Terraform integration and the integration with Kubermatic machine-controller.

KubeOne supports AWS, Azure, DigitalOcean, GCP, Hetzner Cloud,
OpenStack, Packet, and VMware vSphere.

## Supported Kubernetes Versions

Each KubeOne version supports Kubernetes versions supported by upstream at the
time of the KubeOne release. You can find more details about the upstream
support policy in the [Version Skew Policy document][upstream-supported-versions].

In the following table you can find the supported Kubernetes versions for the
current KubeOne version.


| KubeOne version | 1.21       | 1.20       | 1.19 | 1.18 | 1.17 |
| --------------- | ---------- | ---------- | ---- | ---- | ---- |
| v1.2+           | ✓ | ✓ | ✓    | ✓    | -   |
| v1.0+           | - | - | ✓    | ✓    | ✓\*   |

\* Kubernetes 1.17 has reached End-of-Life (EOL) and is not recommended
for new clusters.

Additionally, we do **not** recommend installing or upgrading to the following
Kubernetes versions:

* Releases **older than 1.18.4** as they are affected by multiple CVEs
* On **CentOS 7** releases **older than** 1.18.6 are **not** working
  properly due to some networking-related issues

## Supported Terraform Versions

The KubeOne Terraform integration requires Terraform **v0.12.0** or newer.

Additionally, the [example Terraform configs][terraform-configs] for some
providers may require a newer Terraform version:

* The example Terraform configs for AWS require Terraform **v0.12.10** or newer

For more details, you can check the `versions.tf` file that comes with the
example Terraform configs ([example `versions.tf` file][aws-versions-tf]).

## Supported Operating Systems

The following operating systems are supported:

* Ubuntu 18.04 (Bionic)
* Ubuntu 20.04 (Focal)
* Debian 10 (Buster)
* CentOS 7**
* CentOS 8
* RHEL 7
* RHEL 8
* Flatcar
* Amazon Linux 2***

\*\* Only Kubernetes versions 1.18.6 and newer are known to work properly with
CentOS 7.

\*\*\* Amazon Linux 2 currently requires you to manually specify URLs to all
binaries — Kubelet, Kubeadm, Kubectl, and CNI using the AssetConfiguration API.
Support for package managers on Amazon Linux 2 is planned for the future.

[upstream-supported-versions]: https://kubernetes.io/docs/setup/release/version-skew-policy/#supported-versions
[kubernetes-issue-93194]: https://github.com/kubernetes/kubernetes/issues/93194
[terraform-configs]: https://github.com/kubermatic/kubeone/tree/master/examples/terraform
[aws-versions-tf]: https://github.com/kubermatic/kubeone/blob/master/examples/terraform/aws/versions.tf
