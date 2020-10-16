+++
title = "Presets"
date = 2019-06-13T12:01:35+02:00
weight = 50

+++

With Presets you can specify default settings for new Cluster. Use Presets to reuse property settings across multiple providers.

### Core Concept

As a Kubermatic Kubernetes Platform (KKP) administrator with superuser access, you can define Preset types in a Kubernetes Custom Resource Definition (CRD),
allowing the assignment of new credential types to supported providers. This allows you to define a custom credential type
that works in ways similar to existing credential types. For example, you could create a custom credential type that injects
access keys, passwords or network settings into Cloud object.

Users can specify a credential list with unique names for the group of providers. This credential set can be used for every
logged in user or can be filtered out by email domain.

The API allows using only credential names and never exposes the credential values.
The proper credential name is used for credential injection.

If the Preset name is used together with standard credentials the preset is taken as a first.

### Example

The following example shows an example for a Preset CRD:

```yaml
apiVersion: kubermatic.k8s.io/v1
kind: Preset
metadata:
  name: example
spec:
  requiredEmailDomains:
    - example.com
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
    datastore:
    datastoreCluster:
    datacenter:
  kubevirt:
    kubeconfig:
```

This file defines credentials for all listed providers. The accessible name for this preset is `example`. Only users with
`example.com` domain can see this preset. Lack of the `requiredEmailDomains` field makes the preset available for everyone.
