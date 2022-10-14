+++
title = "Operating System Manager"
date = 2022-08-05T12:00:00+02:00
enableToc = true
weight = 6
+++

## Introduction

[Operating System Manager (OSM)](https://github.com/kubermatic/operating-system-manager) is responsible for creating and managing the required configurations for worker nodes in a Kubernetes cluster. It decouples operating system configurations into dedicated and isolable resources for better modularity and maintainability.

These isolated and extensible resources allow a high degree of customization. This is useful for hybrid, edge, and air-gapped environments.

Configurations for worker nodes comprise of set of scripts used to prepare the node, install packages, configure networking, storage etc. These configurations prepare the nodes for running `kubelet`.

## Overview

[Machine-Controller](https://github.com/kubermatic/machine-controller) is used to manage the worker nodes in KubeOne clusters. It depends on user-data plugins to generate the required configurations for worker nodes. Each operating system requires its own user-data plugin. These configs are then injected into the worker nodes using provisioning utilities such as [cloud-init](https://cloud-init.io) or [ignition](https://coreos.github.io/ignition). Eventually the nodes are bootstrapped.

This has been the norm in KubeOne till KubeOne v1.4 and it works as expected. Although over time, it has been observed that this workflow has certain limitations.

## Machine Controller Limitations

- Machine Controller expects **ALL** the supported user-data plugins to exist and be ready. User might only be interested in a subset of the available operating systems. For example, user might only want to work with `ubuntu`.
- The user-data plugins have templates defined [in-code](https://github.com/kubermatic/machine-controller/blob/v1.53.0/pkg/userdata/ubuntu/provider.go#L136). Which is not ideal since code changes are required to update those templates. Then those code changes need to become a part of the subsequent releases for machine-controller and KubeOne. So we need a complete release cycle to ship those changes to customers.
- Managing configs for multiple cloud providers, OS flavors and OS versions, adds a lot of complexity and redundancy in machine-controller.
- Since the templates are defined in-code, there is no way for an end user to customize them to suit their use-cases.
- Each cloud provider sets some sort of limits for the size of `user-data`, machine won't be created in case of non-compliance. For example, at the time of writing this, AWS has set a [hard limit of 16KB](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instancedata-add-user-data.html).
- Better support for air-gapped environments is required.

Operating System Manager was created to overcome these limitations.

## Architecture

OSM introduces the following new resources as Kubernetes Custom Resource Definitions:

### OperatingSystemProfile

A resource that contains scripts for bootstrapping and provisioning the worker nodes, along with information about what operating systems and versions are supported for given scripts. Additionally, OSPs support templating so you can include some information from MachineDeployment or the OSM deployment itself.

Default OSPs for supported operating systems are provided/installed automatically by KubeOne. End users can create custom OSPs as well to fit their own use-cases.

OSPs are immutable by design and any modifications to an existing OSP requires a version bump in `.spec.version`.

### OperatingSystemConfig

Immutable resource that contains the **actual configurations** that are going to be used to bootstrap and provision the worker nodes. It is a subset of OperatingSystemProfile. OperatingSystemProfile is a template while OperatingSystemConfig is an instance rendered with data from OperatingSystemProfile, MachineDeployment, and flags provided at OSM command-line level.

OperatingSystemConfigs have a 1-to-1 relation with the MachineDeployment. A dedicated controller watches the MachineDeployments and generates the OSCs in `kube-system` and secrets in `cloud-init-settings` namespaces in the cluster. Machine Controller then waits for the bootstrapping and provisioning secrets to become available. Once they are ready, it will extract the configurations from those secrets and pass them as `user-data` to the to-be-provisioned machines.

For each MachineDeployment we have two types of configurations, which are stored in secrets:

1. **Bootstrap**: Configuration used for initially setting up the machine and fetching the provisioning configuration.
2. **Provisioning**: Configuration with the actual `cloud-config` that is used to provision the worker machine.

![Architecture](/img/kubeone/main/operating-system-manager/architecture.png?classes=shadow,border "Architecture")
