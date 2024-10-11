+++
title = "machine-controller"
date = 2024-05-31T07:00:00+02:00
+++

# machine-controller

## Features

### What Works

- Creation of worker nodes on…
  - Alibaba Cloud
  - AWS
  - Azure
  - DigitalOcean
  - Google Cloud Platform
  - Hetzner Cloud
  - KubeVirt
  - Nutanix
  - OpenStack
  - VMware Cloud Director
  - VMware vSphere
- Using any of these supported distributions ([not all distributions work on all providers](/docs/operating-system.md):
  - Amazon Linux 2
  - Flatcar Linux
  - RedHat Enterprise Linux (RHEL)
  - Rocky Linux
  - Ubuntu

### What Doesn't Work

- Creation of control plane nodes (not planned at the moment, consider using 3rd party tools like
  [KKP](https://github.com/kubermatic/kubermatic) or [KubeOne](https://github.com/kubermatic/kubeone))

## Supported Kubernetes Versions

machine-controller tries to follow the Kubernetes version
[support policy](https://kubernetes.io/docs/setup/release/version-skew-policy/) as close as possible.

Currently supported Kubernetes versions are:

- 1.31
- 1.30
- 1.29
- 1.28

## Community Providers

Some cloud providers implemented in machine-controller have been graciously contributed by community
members. Those cloud providers are not part of the automated end-to-end tests run by the
machine-controller developers and thus, their status cannot be guaranteed. The machine-controller
developers assume that they are functional, but can only offer limited support for new features or
bugfixes in those providers.

The current list of community providers is:

- Linode
- Vultr
- OpenNebula
