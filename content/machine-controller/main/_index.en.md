+++
title = "Kubermatic machine-controller"
date = 2024-05-31T07:00:00+02:00
weight = 7
description = "Learn how to use Kubermatic machine-controller to manage worker nodes across multiple cloud providers in a declarative way using Kubernetes native APIs."
+++

## What is machine-controller?

The Kubermatic machine-controller is a Kubernetes-native tool responsible for managing the lifecycle of worker nodes across various cloud providers. It uses the [Cluster API][1] to define machines as Kubernetes resources, enabling declarative management of worker nodes in Kubernetes clusters.

The machine-controller works in conjunction with the [Operating System Manager][2] to handle the provisioning and configuration of worker nodes across multi-cloud and on-premise environments.

[1]: https://cluster-api.sigs.k8s.io/
[2]: https://docs.kubermatic.com/operatingsystemmanager

## Motivation and Background

Kubernetes provides powerful abstractions for managing containerized workloads, but managing the underlying infrastructure (worker nodes) can be challenging, especially in multi-cloud environments. The machine-controller solves this problem by:

- **Declarative Node Management**: Define machines as Kubernetes custom resources, allowing you to manage infrastructure using familiar Kubernetes tools and patterns.
- **Multi-Cloud Support**: Provision and manage worker nodes across different cloud providers (AWS, Azure, GCP, OpenStack, etc.) using a consistent API.
- **Integration with Cluster API**: Leverages the industry-standard Cluster API for machine lifecycle management.
- **Automated Operations**: Handle node provisioning, upgrades, and decommissioning automatically based on declared state.

## Features

### What Works

- **Creation of worker nodes** on the following cloud providers:
  - Alibaba Cloud
  - AWS
  - Azure
  - DigitalOcean
  - Google Cloud Platform
  - Hetzner Cloud
  - KubeVirt
  - Linode
  - Nutanix
  - OpenNebula
  - OpenStack
  - VMware Cloud Director
  - VMware vSphere
  - Vultr

- **Operating System Support**: Multiple Linux distributions are supported:
  - Amazon Linux 2
  - Flatcar Linux
  - RedHat Enterprise Linux (RHEL)
  - Rocky Linux
  - Ubuntu

{{% notice note %}}
Not all operating systems work on all cloud providers. Please refer to the [Operating Systems]({{< ref "./references/operating-systems/" >}}) documentation for compatibility details.
{{% /notice %}}

### Supported Kubernetes Versions

machine-controller follows the Kubernetes [version support policy][3] as closely as possible.

Currently supported Kubernetes versions:

- 1.34
- 1.33
- 1.32
- 1.31

[3]: https://kubernetes.io/docs/setup/release/version-skew-policy/

### Community Providers

Some cloud providers implemented in machine-controller have been graciously contributed by community members. These providers are not part of the automated end-to-end tests and their status cannot be fully guaranteed. The machine-controller developers assume they are functional but can only offer limited support for new features or bugfixes.

**Community-supported providers:**

- Linode
- Vultr
- OpenNebula

### What Doesn't Work

- **Control plane node creation**: This is not planned at the moment. For full cluster lifecycle management including control plane, consider using [Kubermatic Kubernetes Platform (KKP)][4] or [KubeOne][5].

[4]: https://github.com/kubermatic/kubermatic
[5]: https://github.com/kubermatic/kubeone

## Table of Content

{{% children depth=5 %}}
{{% /children %}}

## Further Information

- [machine-controller - GitHub Repository](https://github.com/kubermatic/machine-controller)
- [Operating System Manager](https://docs.kubermatic.com/operatingsystemmanager)
- [Cluster API Documentation](https://cluster-api.sigs.k8s.io/)

Visit [kubermatic.com](https://www.kubermatic.com/) for further information.

{{% notice tip %}}
For latest updates follow us on Twitter [@Kubermatic](https://twitter.com/Kubermatic)
{{% /notice %}}

