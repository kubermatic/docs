+++
title = "Operating Systems"
date = 2021-04-13T20:07:15+02:00
weight = 3

+++

## Kubernetes Node Operating System

KKP supports a multitude of operating systems. One of the unique features of KKP is the possibility to recombine different machine deployments and operating systems even in one cluster. If you intend to use more than one type of OS and/or CRI in one K8s cluster, please consult with Kubermatic Support.

The following operating systems are currently supported by Kubermatic:

* Ubuntu 20.04 and 22.04
* RHEL beginning with 8.0 (support is cloud provider-specific)
* Flatcar (Stable channel)
* Rocky Linux beginning with 8.0
* CentOS beginning with 7.4 excluding stream versions
* Amazon Linux 2

This table shows the combinations of operating systems and cloud providers that KKP supports:

|                       | Ubuntu | CentOS | Flatcar | RHEL | Amazon Linux 2 | Rocky Linux |
|-----------------------|--------|--------|---------|------|----------------|-------------|
| AWS                   | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Azure                 | ✓ | ✓ | ✓ | ✓ | x | ✓ |
| Digitalocean          | ✓ | ✓ | x | x | x | ✓ |
| Equinix Metal         | ✓ | ✓ | ✓ | x | x | ✓ |
| Google Cloud Platform | ✓ | x | x | x | x | x |
| Hetzner               | ✓ | x | x | x | x | ✓ |
| KubeVirt              | ✓ | ✓ | ✓ | ✓ | x | ✓ |
| Nutanix               | ✓ | ✓ | x | x | x | x |
| Openstack             | ✓ | ✓ | ✓ | ✓ | x | ✓ |
| VMware Cloud Director | ✓ | x | x | x | x | x |
| VSphere               | ✓ | ✓ | ✓ | ✓ | x | ✓ |

There could be more in the future since change is constant. This page will constantly be updated each time there is a new supported operating system.
