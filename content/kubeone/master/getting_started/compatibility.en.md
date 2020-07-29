+++
title = "Compatibility Information"
date = 2020-07-29T12:00:00+02:00
weight = 2
+++

This document shows what are compatible Kubernetes, Terraform, and operating
systems versions with the current KubeOne version.

## Supported Providers

KubeOne works on any infrastructure out of the box. Natively supported
providers have support for additional features and are frequently tested with
the current KubeOne version. The additional features include the KubeOne
Terraform integration and the integration with Kubermatic machine-controller.

KubeOne supports AWS, Azure, DigitalOcean, GCP, Hetzner Cloud,
OpenStack, and VMware vSphere.

## Supported Kubernetes Versions

Each KubeOne version supports Kubernetes versions supported by upstream at the
time of the KubeOne release. You can find more details about the upstream
support policy in the [Version Skew Policy document][upstream-supported-versions].

In the following table you can find the supported Kubernetes versions for the
current KubeOne version.


| KubeOne version | 1.19       | 1.18 | 1.17 | 1.16 | 1.15 |
| --------------- | ---------- | ---- | ---- | ---- | ---- |
| v1.0.0+         | unreleased | +    | +    | +*   | -    |

\* Kubernetes 1.16 will be supported as long as it's supported by upstream.
It's supposed to reach End-of-Life several weeks after the 1.19 release.

Additionally, we do **not** recommend installing or upgrading to the following
Kubernetes versions:

* **1.16.13** due to an upstream bug with health checks for
  kube-controller-manager and kube-scheduler (more details can be found in the
  [issue #93194][kubernetes-issue-93194])
* Releases **older than 1.16.11/1.17.7/1.18.4** as they are affected by
  multiple CVEs
* On **CentOS 7** releases **other than** 1.18.6/1.17.9/1.16.13 are **not**
  working properly due to some networking-related issues

## Supported Terraform Versions

The KubeOne Terraform integration requires Terraform **v0.12.0** or newer.

Additionally, the [example Terraform scripts][terraform-scripts] for some
providers may require a newer Terraform version:

* The example Terraform scripts for AWS require Terraform **v0.12.10** or newer

For more details, you can check the `versions.tf` file that comes with the
example Terraform scripts ([example `versions.tf` file][aws-versions-tf]).

## Supported Operating Systems

The following operating systems are supported:

* Ubuntu 18.04 (Bionic)
* Ubuntu 20.04 (Focal)
* CentOS 7**
* CentOS 8
* RHEL 7
* RHEL 8
* CoreOS
* Flatcar

\*\* Only Kubernetes versions 1.18.6 and 1.17.9 are known to work properly with
CentOS 7.

[upstream-supported-versions]: https://kubernetes.io/docs/setup/release/version-skew-policy/#supported-versions
[kubernetes-issue-93194]: https://github.com/kubernetes/kubernetes/issues/93194
[terraform-scripts]: https://github.com/kubermatic/kubeone/tree/master/examples/terraform
[aws-versions-tf]: https://github.com/kubermatic/kubeone/blob/master/examples/terraform/aws/versions.tf