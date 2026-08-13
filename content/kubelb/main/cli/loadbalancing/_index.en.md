+++
title = "Load Balancing"
linkTitle = "Load Balancers"
date = 2025-08-27T00:00:00+01:00
description = "Create public or private load balancers for external endpoints with KubeLB CLI."
weight = 20
+++

KubeLB CLI provisions load balancers, public or private depending on your configuration. KubeLB secures the endpoint with TLS certificates, creates DNS records, and manages the load balancing configuration.

## Prerequisites

See the [DNS](../../tutorials/security/dns/#enable-dns-automation) documentation to configure the Gateway or Ingress to manage DNS for the load balancer.

## Create a Load Balancer

Create a load balancer with the `kubelb loadbalancer create` command:

```bash
kubelb loadbalancer create my-app --endpoints 10.0.1.1:8080,10.0.1.2:8080 --hostname my-app.example.com
```

This creates a `LoadBalancer` resource that forwards traffic to the endpoints `10.0.1.1:8080` and `10.0.1.2:8080` and is accessible at `https://my-app.example.com`.

The hostname is optional; if omitted, KubeLB generates a random hostname when a wildcard domain is enabled for the tenant or globally.

![Demo animation](/img/kubelb/v1.2/loadbalancer.gif?classes=shadow,border "Load Balancer Demo")
