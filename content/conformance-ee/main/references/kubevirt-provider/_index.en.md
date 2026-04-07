+++
title = "KubeVirt Provider"
date = 2026-03-17T10:07:15+02:00
weight = 30
+++

The KubeVirt provider is the reference implementation for Conformance EE's provider system. It handles infrastructure discovery and spec generation for KubeVirt-based clusters.

## Infrastructure Discovery

The provider queries the KubeVirt infrastructure cluster to enumerate available resources:

| Resource | API Group | Description |
|----------|-----------|-------------|
| VPCs | `kubeovn.io/v1` | Virtual private cloud networks |
| Subnets | `kubeovn.io/v1` | Network subnets (paired with parent VPC) |
| StorageClasses | `storage.k8s.io/v1` | Available storage backends |
| Instance Types | `instancetype.kubevirt.io/v1beta1` | VirtualMachineInstancetype resources |
| Preferences | `instancetype.kubevirt.io/v1beta1` | VirtualMachinePreference resources |

These discovered resources are converted into dynamic modifiers that expand the test matrix based on what's actually available in the target environment.

## Supported Distributions

The KubeVirt provider supports the following OS distributions for virtual machine disks:

| Distribution | Supported Versions |
|--------------|--------------------|
| Ubuntu | 20.04, 22.04 |
| RHEL | 8, 9 |
| Flatcar | 3374.2.2 |
| Rocky Linux | 8, 9 |

Custom image sources can be configured via the `imageSources` field in the configuration file.
