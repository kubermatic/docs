+++
title = "OperatingSystemManager"
date = 2022-08-20T12:00:00+02:00
weight = 6
description = "Learn how you can use Kubermatic OperatingSystemManager to manage and customize worker node configurations for more granular control over your kubernetes clusters."
+++

![OperatingSystemManager logo](/img/operatingsystemmanager/common/operating-system-manager-logo.png)

## What is OperatingSystemManager?

[Operating System Manager (OSM)][operating-system-manager] is an open source project by Kubermatic, it is responsible for creating and managing the required configurations for worker nodes in a Kubernetes cluster. It decouples operating system configurations into dedicated and isolable resources for better modularity and maintainability.

These isolated and extensible resources allow a high degree of customization which allows users to modify the worker node configurations to suit their use cases. This is useful for hybrid, edge, and air-gapped environments.

Configurations for worker nodes comprise of set of scripts used to prepare the node, install packages, configure networking, storage etc. These configurations prepare the nodes for running `kubelet`.

## Problem Statement

[Machine-Controller][machine-controller] is used to manage the worker nodes in KubeOne clusters. It depends on user-data plugins to generate the required configurations for worker nodes. Each operating system requires its own user-data plugin. These configs are then injected into the worker nodes using provisioning utilities such as [cloud-init](https://cloud-init.io) or [ignition](https://coreos.github.io/ignition). Eventually the nodes are bootstrapped to become a part of a kubernetes cluster.

This has been the norm till [machine-controller v1.54.0](<https://github.com/kubermatic/machine-controller/releases/tag/v1.54.0>) and it works as expected. Although over time, it has been observed that this workflow has certain limitations.

### Machine Controller Limitations

- Machine Controller expects **ALL** the supported user-data plugins to exist and be ready. User might only be interested in a subset of the available operating systems. For example, user might only want to work with `ubuntu`.
- The user-data plugins have templates defined [in-code](https://github.com/kubermatic/machine-controller/blob/v1.54.0/pkg/userdata/ubuntu/provider.go#L136). Which is not ideal since code changes are required to update those templates. Then those code changes need to become a part of the subsequent releases for machine-controller and KubeOne. So we need a complete release cycle to ship those changes to customers.
- Managing configs for multiple cloud providers, OS flavors and OS versions, adds a lot of complexity and redundancy in machine-controller.
- Since the templates are defined in-code, there is no way for an end user to customize them to suit their use-cases.
- Each cloud provider sets some sort of limits for the size of `user-data`, machine won't be created in case of non-compliance. For example, at the time of writing this, AWS has set a [hard limit of 16KB](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instancedata-add-user-data.html).
- Better support for air-gapped environments is required.

Operating System Manager was created to overcome these limitations.

[machine-controller]: https://github.com/kubermatic/machine-controller
[operating-system-manager]: https://github.com/kubermatic/operating-system-manager
