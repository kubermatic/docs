+++
title = "Compatibility Matrix"
date = 2022-08-20T12:00:00+02:00
weight = 6
+++

The page provides an overview for the supported operating systems on various cloud providers. These are the combinations that are covered by the "default" OperatingSystemProfiles that OSM will install in your cluster. Users can create custom OperatingSystemProfiles that work with a provider/OS combination that are not listed here.

The following operating systems are currently supported by the default OperatingSystemProfiles:

* Ubuntu 20.04 and 22.04
* RHEL beginning with 8.0 (support is cloud provider-specific)
* Flatcar (Stable channel)
* Rocky Linux beginning with 8.0
* CentOS beginning with 7.4 excluding stream versions
* Amazon Linux 2

## Operating System

|   | Ubuntu | CentOS | Flatcar | Amazon Linux 2 | RHEL | Rocky Linux |
|---|---|---|---|---|---|---|
| AWS | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Azure | ✓ | ✓ | ✓ | x | ✓ | ✓ |
| DigitalOcean  | ✓ | ✓ | x | x | x | ✓ |
| Equinix Metal  | ✓ | ✓ | ✓ | x | x | ✓ |
| Google Cloud Platform | ✓ | x | x | x | x | x |
| Hetzner | ✓ | x | x | x | x | ✓ |
| KubeVirt | ✓ | ✓ | ✓ | x | ✓ | ✓ |
| Nutanix | ✓ | ✓ | x | x | x | x |
| Openstack | ✓ | ✓ | ✓ | x | ✓ | ✓ |
| VMware Cloud Director | ✓ | x | x | x | x | x |
| VSphere | ✓ | ✓ | ✓ | x | ✓ | ✓ |

## Kubernetes Versions

Currently supported K8S versions are:

* 1.28
* 1.27
* 1.26
