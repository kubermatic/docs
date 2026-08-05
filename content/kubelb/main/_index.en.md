+++
title = "Kubermatic KubeLB"
date = 2023-10-27T10:07:15+02:00
weight = 6
description = "Learn how KubeLB centralizes multi-tenant Layer 4 and Layer 7 load balancing for Kubernetes clusters across cloud, on-premises, and bare-metal environments."
+++

![KubeLB logo](/img/kubelb/common/logo.png?classes=logo-height)

## What is KubeLB?

KubeLB is a Kubernetes-native, multi-tenant load-balancing platform by Kubermatic. It centralizes Layer 4 and Layer 7 traffic management for fleets of Kubernetes clusters across cloud, on-premises, and bare-metal environments.

A management cluster runs the load-balancing data plane, while KubeLB Cloud Controller Manager (CCM) agents connect tenant clusters and propagate their requested configuration. Workloads continue to use Kubernetes APIs: Services of type `LoadBalancer` for Layer 4, and Ingress or Gateway API resources for Layer 7.

## Start Here

- [Understand the architecture]({{< relref "./architecture/" >}}) and how the management and tenant clusters interact.
- [Check compatibility]({{< relref "./compatibility-matrix/" >}}) and [compare Community and Enterprise features]({{< relref "./ce-ee-matrix/" >}}) before choosing a deployment.
- [Install KubeLB]({{< relref "./installation/" >}}), starting with the management cluster and then connecting tenant clusters.
- Expose workloads with a [Layer 4 `LoadBalancer` Service]({{< relref "./tutorials/loadbalancer/" >}}), [Ingress]({{< relref "./tutorials/ingress/" >}}), or the [Gateway API]({{< relref "./tutorials/gatewayapi/" >}}).
- [Migrate from Ingress to the Gateway API]({{< relref "./ingress-to-gateway-api/" >}}) with KubeLB automation, the CLI, or the dashboard.
- Operate KubeLB with the [dashboard]({{< relref "./dashboard/" >}}), review [security guidance]({{< relref "./security/" >}}), and check the [release notes]({{< relref "./release-notes/" >}}).

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
