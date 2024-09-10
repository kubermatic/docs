+++
title = "Operating System Manager"
date = 2022-01-18T10:07:15+02:00
weight = 15
+++

[Operating System Manager (OSM)](https://github.com/kubermatic/operating-system-manager) is responsible for creating and managing the required configurations for worker nodes in a Kubernetes cluster. It decouples operating system configurations into dedicated and isolable resources for better modularity and maintainability.

Starting with KKP 2.21, OSM will be enabled by default for all the new user clusters. Although existing clusters require [manual migration][migrating-existing-clusters].

## Overview

[Machine-Controller](https://github.com/kubermatic/machine-controller) is used to create and manage worker nodes in KKP user clusters. It depends on user-data plugins to generate configurations for worker nodes. Each operating system requires its own user-data plugin. These configs are then injected in the worker nodes using provisioning utilities such as [cloud-init](https://cloud-init.io) or [ignition](https://coreos.github.io/ignition). Eventually the nodes are bootstrapped.

This has been the norm in KKP till v1.21 and it works as expected. Although over the time, it has been observed that this workflow has certain limitations.

## Machine Controller Limitations

- Machine Controller expects **ALL** the supported user-data plugins to exist and be ready. User might only be interested in a subset of the available operating systems. For example, user might only want to work with `ubuntu`.
- The user-data plugins have templates defined [in-code](https://github.com/kubermatic/machine-controller/blob/main/pkg/userdata/ubuntu/provider.go#L133). Which is not ideal because code changes are required to update those templates.
- Managing configs for multiple cloud providers, OS flavors and OS versions, adds a lot of complexity and redundancy in machine-controller.
- Since the templates are defined in-code, there is no way for an end user to customize them to suit their use-cases.
- Each cloud provider sets some sort of limits for the size of `user-data`, machine won't be created in case of non-compliance. For example, at the time of writing this, AWS has set a [hard limit of 16KB](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instancedata-add-user-data.html).
- Better support for air-gapped environments is required.

Operating System Manager was created to overcome these limitations.

## Architecture

OSM introduces the following new resources:

### OperatingSystemProfile

Templatized resource that represents the details of each operating system. OSPs are immutable and default OSPs for supported operating systems are provided/installed automatically by kubermatic. End users can create custom OSPs as well to fit their own use-cases.

Its dedicated controller runs in the **seed** cluster, in user cluster namespace, and operates on the `OperatingSystemProfile` custom resource in the `kube-system` namespace in user clusters. It is responsible for installing the default OSPs in user clusters.

### OperatingSystemConfig

Immutable resource that contains the actual configurations that are going to be used to bootstrap and provision the worker nodes. It is a subset of OperatingSystemProfile, rendered using OperatingSystemProfile, MachineDeployment and flags

Its dedicated controller runs in the **seed** cluster, in user cluster namespace, and is responsible for generating the OSCs in `kube-system` and secrets in `cloud-init-settings` namespace in the user cluster.

For each cluster there are at least two OSC objects:

1. **Bootstrap**: OSC used for initial configuration of machine and to fetch the provisioning OSC object.
2. **Provisioning**: OSC with the actual cloud-config that provision the worker node.

OSCs are processed by controllers to eventually generate **secrets inside each user cluster**. These secrets are then consumed by worker nodes.

![Architecture](architecture.png?classes=shadow,border "Architecture")

### Air-gapped Environment

This controller was designed by keeping air-gapped environments in mind. Customers can use their own VM images by creating custom OSP profiles to provision nodes in a cluster that doesn't have outbound internet access.

More work is being done to make it even easier to use OSM in air-gapped environments.

[migrating-existing-clusters]: {{< ref "./usage/#migrating-existing-clusters" >}}
