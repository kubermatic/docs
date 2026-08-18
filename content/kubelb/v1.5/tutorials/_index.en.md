+++
title = "Guides"
linkTitle = "Guides"
date = 2023-10-27T10:07:15+02:00
description = "Task-oriented guides for exposing workloads, managing tenants, tuning Envoy Proxy, and securing KubeLB traffic."
weight = 20
chapter = true
+++

Choose the path that matches your task:

- Start with [Tenants]({{< relref "./tenants" >}}) when connecting a cluster to KubeLB.
- Expose workloads with [TCP/UDP load balancing]({{< relref "./loadbalancer" >}}), [Ingress]({{< relref "./ingress" >}}), or [Gateway API]({{< relref "./gatewayapi" >}}).
- Tune data-plane behavior under [Envoy Proxy]({{< relref "./envoy-proxy" >}}).
- Configure certificates, DNS, secrets, and policies under [Security]({{< relref "./security" >}}).
- Build managed AI endpoints under [AI]({{< relref "./ai" >}}).

## All guides

{{% children depth=2 %}}
{{% /children %}}
