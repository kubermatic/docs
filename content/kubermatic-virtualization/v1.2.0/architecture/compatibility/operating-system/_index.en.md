+++
title = "Operating Systems"
date = 2025-07-18T16:06:34+02:00
weight = 3
+++

## Supported Operating Systems

The following operating systems are supported:

* Ubuntu 20.04 (Focal)
* Ubuntu 22.04 (Jammy Jellyfish)
* Ubuntu 24.04 (Noble Numbat)
* Rocky Linux 8
* RHEL 8.0, 8.1, 8.2, 8.3, 8.4
* Flatcar

{{% notice warning %}}
The minimum kernel version for Kubernetes 1.32 clusters is 4.19. Some operating system versions, such as RHEL 8,
do not meet this requirement and therefore do not support Kubernetes 1.32 or newer.
{{% /notice %}}