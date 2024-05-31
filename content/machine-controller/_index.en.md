+++
title = "machine-controller"
date = 2024-05-31T07:00:00+02:00
+++

# machine-controller

## Features

### What Works

- Creation of worker nodes on AWS, Digitalocean, OpenStack, Azure, Google Cloud Platform, Nutanix,
  VMWare Cloud Director, VMWare vSphere, Hetzner Cloud and Kubevirt
- Using Ubuntu, Flatcar, CentOS 7 or Rocky Linux 8 distributions
  ([not all distributions work on all providers](/docs/operating-system.md))

### What Doesn't Work

- Master creation (Not planned at the moment)

## Supported Kubernetes Versions

machine-controller tries to follow the Kubernetes version
[support policy](https://kubernetes.io/docs/setup/release/version-skew-policy/) as close as possible.

Currently supported Kubernetes versions are:

- 1.30
- 1.29
- 1.28
- 1.27

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
