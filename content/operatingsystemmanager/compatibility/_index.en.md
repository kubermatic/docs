+++
title = "Compatibility Matrix"
date = 2022-08-20T12:00:00+02:00
weight = 6
+++

The page provides an overview for the supported operating systems on various cloud providers. These are the combinations that are covered by the "default" OperatingSystemProfiles that OSM will install in your cluster. Users can create custom OperatingSystemProfiles that work with a provider/OS combination that are not listed here.

## Operating System

|   | Ubuntu | CentOS | Flatcar | Amazon Linux 2 | RHEL | Rocky Linux |
|---|---|---|---|---|---|---|
| AWS | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Azure | ✓ | ✓ | ✓ | x | ✓ | ✓ |
| DigitalOcean  | ✓ | ✓ | x | x | x | ✓ |
| Equinix Metal  | ✓ | ✓ | ✓ | x | x | ✓ |
| Google Cloud Platform | ✓ | x | x | x | x | x |
| Hetzner | ✓ | ✓ | x | x | x | ✓ |
| KubeVirt | ✓ | ✓ | ✓ | x | ✓ | ✓ |
| Nutanix | ✓ | ✓ | x | x | x | x |
| Openstack | ✓ | ✓ | ✓ | x | ✓ | ✓ |
| VMware Cloud Director | ✓ | x | x | x | x | x |
| VSphere | ✓ | ✓ | ✓ | x | ✓ | ✓ |

## Kubernetes Versions

Currently supported K8S versions are:

- 1.25
- 1.24
- 1.23
