+++
title = "Kubermatic KubeLB"
date = 2023-10-27T10:07:15+02:00
weight = 6
description = "Learn how you can use Kubermatic KubeLB to centrally provision and manage load balancers across multiple cloud and on-premise environments."
+++

![KubeLB logo](/img/kubelb/common/logo.png?classes=logo-height)

## What is KubeLB?

KubeLB is a project by Kubermatic, it is a Kubernetes native tool, responsible for centrally managing load balancers for Kubernetes clusters across multi-cloud and on-premise environments.

## Motivation and Background

Kubernetes does not offer any implementation for load balancers and in turn relies on the in-tree or out-of-tree cloud provider implementations to take care of provisioning and managing load balancers. This means that if you are not running on a supported cloud provider, your services of type `LoadBalancer` will never be allotted a load balancer IP address. This is an obstacle for bare-metal Kubernetes environments.

There are solutions available like [MetalLB][2], [Cilium][3], etc. that solve this issue. However, these solutions are focused on a single cluster where you have to deploy the application in the same cluster where you want the load balancers. This is not ideal for multi-cluster environments since you have to configure load balancing for each cluster separately, which makes IP address management not trivial.

KubeLB solves this problem by providing a centralized load balancer management solution for Kubernetes clusters across multi-cloud and on-premise environments.

[2]: https://metallb.universe.tf
[3]: https://cilium.io/use-cases/load-

## Table of Content

{{% children depth=5 %}}
{{% /children %}}

## Further Information

- [Introducing KubeLB](https://www.kubermatic.com/products/kubelb/)
- [KubeLB Whitepaper](https://www.kubermatic.com/static/KubeLB-Cloud-Native-Multi-Tenant-Load-Balancer.pdf)
- [KubeLB CE](https://github.com/kubermatic/kubelb)

Visit [kubermatic.com](https://www.kubermatic.com/) for further information.

{{% notice tip %}}
For latest updates follow us on Twitter [@Kubermatic](https://twitter.com/Kubermatic)
{{% /notice %}}
