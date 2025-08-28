+++
title = "Load Balancing"
date = 2025-08-27T00:00:00+01:00
weight = 20
+++

KubeLB CLI can be used to quickly provision Load Balancers that can be public/private based on your load balancing configurations and needs. KubeLB then takes care of securing your endpoint with TLS certificates, automatically creating DNS records, and managing the load balancing configurations.

## Pre-requisites

Please refer to the [DNS](../../tutorials/security/dns/#enable-dns-automation) documentation to configure the Gateway or Ingress to manage DNS for the load balancer.

## Create a Load Balancer

To create a load balancer, you can use the `kubelb loadbalancer create` command.

For example

```bash
kubelb loadbalancer create my-app --endpoints 10.0.1.1:8080,10.0.1.2:8080 --hostname my-app.example.com
```

This will create a Load Balancer resource that will forward traffic to the endpoints `10.0.1.1:8080` and `10.0.1.2:8080` and will be accessible at `https://my-app.example.com`.

Specifying hostname is optional and if not provided, KubeLB will generate a random hostname for you if the wildcard domain is enabled for the tenant or globally.

![Demo animation](/img/kubelb/v1.2/loadbalancer.gif?classes=shadow,border "Load Balancer Demo")

## Further actions

Further actions include:

- Updating the load balancer configuration
- Deleting the load balancer
- Getting the load balancer details
- Listing all the load balancers
