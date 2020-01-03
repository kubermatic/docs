+++
title = "Presets"
date = 2019-06-13T12:01:35+02:00
weight = 3
pre = "<b></b>"
+++

## Presets

With Presets you can specify default settings for new Cluster. Use Presets to reuse property settings across multiple providers.

### Core concept

As a Kubermatic administrator with superuser access, you can define Presets type in a standard format using static YAML
file or Kubernetes Custom Resource Definition (CRD) struct that represents the Preset, allowing the assignment of new
credential types to supported providers. This allows you to define a custom credential type that works in ways similar
to existing credential types. For example, you could create a custom credential type that injects access keys, passwords
or network settings into Cloud object.

Users can specify a credential list with unique names for the group of providers. This credential set can be used for every
logged in user or can be filtered out by email domain.
 
The API allows using only credential names and never exposes the credential values.
The proper credential name is used for credential injection.

If the Preset name is used together with standard credentials the preset is taken as a first.

### Prerequisites

A presets are optional for Kubermatic API. The Kubermatic API takes a flags:

- `presets` The optional file path for a YAML file containing presets.
- `dynamic-presets` The optional flag to enable dynamic presets. This parameter has a higher priority than `presets`.
 

### Examples

The following example shows the static presets structure:

```yaml
presets:
  items:
    - metadata:
        name: example
      spec:
        requiredEmailDomain: "example.com"
        aws:
          accessKeyId: 
          secretAccessKey: 
          vpcId: 
        azure:
          tenantId: 
          subscriptionId: 
          clientId: 
          clientSecret:
        digitalocean:
          token: 
        gcp:
          serviceAccount:
        hetzner:
          token: 
        openstack:
          username: 
          password: 
          tenant: 
          domain: DEFAULT
          floatingIpPool: ext-net
        packet:
          apiKey: 
          projectId: 
        vsphere:
          username: 
          password: 
        kubevirt:
          kubeconfig:
```
This file defines credentials for all listed providers. The accessible name for this preset is `example`. The only user
with `example.com` domain can see this preset. Lack of the `requiredEmailDomain` field makes the preset available for everyone.
This file can be also extended for the new item with a different preset name.
 
Another example shows the CRD structure:

```yaml
apiVersion: kubermatic.k8s.io/v1
kind: Preset
metadata:
  name: example
spec:
  aws:
    accessKeyId: 
    secretAccessKey: 
    vpcId: 
  azure:
    tenantId: 
    subscriptionId: 
    clientId: 
    clientSecret: 
  digitalocean:
    token: 
  gcp:
    serviceAccount: 
  hetzner:
    token: 
  openstack:
    username: 
    password: 
    tenant: 
    domain: DEFAULT
    floatingIpPool: ext-net
  packet:
    apiKey: 
    projectId: 
  vsphere:
    username: 
    password:
  kubevirt:
    kubeconfig:
```
