+++
title = "Compatibility Matrix"
date = 2022-08-20T12:00:00+02:00
weight = 6
+++

The page provides an overview for the supported operating systems on various cloud providers. These are the combinations that are covered by the "default" OperatingSystemProfiles that OSM will install in your cluster. Users can create custom OperatingSystemProfiles that work with a provider/OS combination that are not listed here.

The following operating systems are currently supported by the default OperatingSystemProfiles:

* Ubuntu 24.04
* RHEL 9.x (support is cloud provider-specific)
* Flatcar (Stable channel)
* Rocky Linux 9.x

## Operating System

|                       | Ubuntu | Flatcar | RHEL | Rocky Linux |
| --------------------- | ------ | ------- | ---- | ----------- |
| AWS                   | ✓      | ✓       | ✓    | ✓           |
| Azure                 | ✓      | ✓       | ✓    | ✓           |
| DigitalOcean          | ✓      | x       | x    | ✓           |
| Google Cloud Platform | ✓      | ✓       | x    | x           |
| Hetzner               | ✓      | x       | x    | ✓           |
| KubeVirt              | ✓      | ✓       | ✓    | ✓           |
| Nutanix               | ✓      | x       | x    | x           |
| Openstack             | ✓      | ✓       | ✓    | ✓           |
| VMware Cloud Director | ✓      | ✓       | x    | x           |
| VSphere               | ✓      | ✓       | ✓    | ✓           |

## Kubernetes Versions

Currently supported K8S versions are:

- 1.35
- 1.34
- 1.33
