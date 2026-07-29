+++
title = "Kubermatic KubeLB"
date = 2023-10-27T10:07:15+02:00
weight = 6
description = "Learn how you can use Kubermatic KubeLB to centrally provision and manage load balancers across multiple cloud and on-premise environments."
+++

![KubeLB logo](/img/kubelb/common/logo.png?classes=logo-height)

## What is KubeLB?

KubeLB is a Kubernetes-native tool by Kubermatic that centrally manages Layer 4 and Layer 7 load balancing configurations for Kubernetes clusters across multi-cloud and on-premise environments.

## Motivation and Background

Kubernetes does not offer any implementation for load balancers and in turn relies on the in-tree or out-of-tree cloud provider implementations to take care of provisioning and managing load balancers. This means that if you are not running on a supported cloud provider, your services of type `LoadBalancer` will never be allotted a load balancer IP address. This is an obstacle for bare-metal Kubernetes environments.

There are solutions available like [MetalLB][2], [Cilium][3], etc. that solve this issue. However, these solutions are focused on a single cluster where you have to deploy the application in the same cluster where you want the load balancers. This is not ideal for multi-cluster environments since you have to configure load balancing for each cluster separately, which makes IP address management not trivial.

Application load balancing has the same constraint: an external application like [ingress-nginx][4] or [Envoy Gateway][5] needs to be deployed in the cluster, and securing traffic requires further tools to manage DNS, TLS certificates, and web application firewalls.

KubeLB solves this problem with a centralized management cluster that runs the data plane for multiple Kubernetes clusters across multi-cloud and on-premise environments. Load balancing for a whole fleet of clusters is configured and enforced in one place, with a consistent experience for developers. Air-gapped environments without internet access are supported in the Enterprise Edition; see the [Air-Gap Installation]({{< relref "./installation/air-gap" >}}) guide.

[2]: https://metallb.universe.tf
[3]: https://cilium.io/use-cases/load-balancer/
[4]: https://kubernetes.github.io/ingress-nginx/
[5]: https://gateway.envoyproxy.io/

## Table of Contents

{{% children depth=1 %}}
{{% /children %}}

## Further Reading

- [Introducing KubeLB](https://www.kubermatic.com/products/kubelb/)
- [KubeLB Whitepaper](https://www.kubermatic.com/static/KubeLB-Cloud-Native-Multi-Tenant-Load-Balancer.pdf)
- [KubeLB - GitHub Repository](https://github.com/kubermatic/kubelb)

Visit [kubermatic.com](https://www.kubermatic.com/) for further information.

{{% notice tip %}}
For latest updates follow us on Twitter [@Kubermatic](https://twitter.com/Kubermatic)
{{% /notice %}}
