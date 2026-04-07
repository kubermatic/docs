+++
title = "Machine Modifiers"
date = 2026-03-17T10:07:15+02:00
weight = 20
+++

Machine modifiers define configuration axes for machine deployments within test clusters. They are split into **static** modifiers (hardcoded) and **dynamic** modifiers (discovered at runtime from the infrastructure cluster).

## Static Machine Modifiers

| Group                         | Options                                        | Description |
|-------------------------------|------------------------------------------------|-------------|
| `instance-type`               | none, discovered instance types                | KubeVirt VM instance type |
| `preference`                  | none, discovered preferences                   | KubeVirt VM preference |
| `dns-policy`                  | ClusterFirstWithHostNet, ClusterFirst, Default, None | Pod DNS resolution policy |
| `eviction-strategy`           | LiveMigrate, External                          | VM eviction behavior |
| `network-multiqueue`          | enabled, disabled                              | Network multi-queue support |
| `topology-spread-constraints` | enabled, disabled                              | Pod topology spread |

## Dynamic Machine Modifiers

These modifiers are discovered at runtime from the YAML configuration and infrastructure cluster:

| Group              | Source                                         | Description |
|--------------------|------------------------------------------------|-------------|
| `cpu`              | `resources.cpu` config values                  | VM CPU count |
| `memory`           | `resources.memory` config values               | VM memory size |
| `disk-size`        | `resources.diskSize` config values             | VM disk size |
| `storage-class`    | StorageClasses from infra cluster              | Storage backend |
| `node-affinity`    | Node names from infra cluster                  | Node placement |
| `image-source`     | `imageSources` config per distribution         | OS disk image |
| `nameservers`      | `nameservers` config                           | DNS nameservers |

## Datacenter Modifiers

Discovered from the KubeVirt infrastructure cluster:

| Group                    | Source                                         | Description |
|--------------------------|------------------------------------------------|-------------|
| `vpc`                    | VPC CRDs (`kubeovn.io/v1`)                    | Virtual private cloud |
| `kubevirt-vpc-subnet`    | Subnet CRDs per VPC                           | Network subnet |
| `kubevirt-storage-class` | StorageClasses from infra cluster              | Storage class |

## How Modifiers Work

Each modifier follows the same pattern as cluster modifiers: a **Name** for human identification, a **Group** for exclusive selection, and a modify function for spec mutation.
