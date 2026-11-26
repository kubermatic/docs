+++
title = "Hetzner"
date = 2023-10-19T13:00:00+02:00
weight = 4
+++

KKP user clusters can use Hetzner Cloud (HCloud) to host worker nodes.

## Access Credentials

To provision a cluster on Hetzner, an API token must be provided to KKP.

## Load Balancers

The Hetzner cloud-controller-manager (CCM) creates a Hetzner Load Balancer for each Service of type `LoadBalancer`. Hetzner needs a location or a network zone for every Load Balancer. KKP sets the default location from the datacenter in the Seed:

- `spec.hetzner.location`, if set (e.g. `fsn1`).
- Otherwise, the location prefix of `spec.hetzner.datacenter` (e.g. `fsn1` for `fsn1-dc8`).

Service annotations override this default. To create a Load Balancer in another location, set the location annotation:

```yaml
metadata:
  annotations:
    load-balancer.hetzner.cloud/location: nbg1
```

The CCM ignores the network zone when a location is set. To use a network zone, also clear the default location:

```yaml
metadata:
  annotations:
    load-balancer.hetzner.cloud/location: ""
    load-balancer.hetzner.cloud/network-zone: eu-central
```

Changing the location of an existing Load Balancer has no effect. See the [upstream annotation reference](https://github.com/hetznercloud/hcloud-cloud-controller-manager/blob/main/docs/reference/load_balancer_annotations.md) for all options.
