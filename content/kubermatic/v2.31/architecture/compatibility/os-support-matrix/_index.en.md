+++
title = "Operating Systems"
date = 2021-04-13T20:07:15+02:00
weight = 3

+++

## Kubernetes Node Operating System

KKP supports a multitude of operating systems. One of the unique features of KKP is the possibility to recombine different machine deployments and operating systems even in one cluster. If you intend to use more than one type of OS and/or CRI in one K8s cluster, please consult with Kubermatic Support.

The following operating systems are currently supported by Kubermatic:

- Ubuntu 22.04 and 24.04 LTS
- RHEL 9.x
- Flatcar (Stable channel)
- Rocky Linux 9.x

**Note:** CentOS was removed as a supported OS in KKP 2.26.3

This table shows the combinations of operating systems and cloud providers that KKP supports:

|                       | Ubuntu | Flatcar | RHEL | Rocky Linux |
|-----------------------|--------|---------|------|-------------|
| AWS                   | ✓ | ✓ | ✓ | ✓ |
| Azure                 | ✓ | ✓ | ✓ | ✓ |
| Digitalocean          | ✓ | x | x | ✓ |
| Edge                  | ✓ | x | x | x |
| Google Cloud Platform | ✓ | ✓ | x | x |
| Hetzner               | ✓ | x | x | ✓ |
| KubeVirt              | ✓ | ✓ | ✓ | ✓ |
| Nutanix               | ✓ | x | x | x |
| Openstack             | ✓ | ✓ | ✓ | ✓ |
| VMware Cloud Director | ✓ | ✓ | x | x |
| VSphere               | ✓ | ✓ | ✓ | ✓ |

There could be more in the future since change is constant. This page will constantly be updated each time there is a new supported operating system.
