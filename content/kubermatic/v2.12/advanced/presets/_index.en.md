+++
title = "Presets"
date = 2019-06-13T12:01:35+02:00
weight = 3

+++

## Presets

With Presets you can specify default settings for new Cluster. Use Presets to reuse property settings across multiple providers.

### Core Concept

As a Kubermatic administrator with superuser access, you can define Presets type in a standard format using a YAML
definition, allowing the assignment of new credential types to supported providers. This allows you to define a custom
credential type that works in ways similar to existing credential types. For example, you could create a custom credential
type that injects access keys, passwords or network settings into Cloud object.

User can specify credential list with unique names for each provider. The API allows using only credential name and never exposes the credential values.
The proper credential name is used for credential injection.

If the Preset name is used together with standard credentials the preset is taken as a first.

### Prerequisites

A presets are optional for Kubermatic API. The Kubermatic API takes a flag:

- `presets` The optional file path for a file containing presets.

### Example

The following example shows the presets structure:

```yaml
presets:
  digitalocean:
    credentials:
      - name: digitalocean
        token:
  azure:
    credentials:
      - name: azure
        tenantId:
        subscriptionId:
        clientId:
        clientSecret:
        resourceGroup:
        vnet:
        subnet:
        routeTable:
        securityGroup:
  aws:
    credentials:
      - name: aws
        accessKeyId:
        secretAccessKey:
        vpcId:
        subnetId:
        routeTableId:
        instanceProfileName:
        securityGroupID:
  openstack:
    credentials:
      - name: openstack
        username:
        password:
        tenant:
        domain: DEFAULT
        network:
        securityGroups:
        floatingIpPool:
        routerID:
        subnetID:
  hetzner:
    credentials:
      - name: default
        token:
  vsphere:
    credentials:
      - name: default
        username:
        password:
        vmNetName:
  packet:
    credentials:
      - name: default
        apiKey:
        projectId:
        billingCycle:
  gcp:
    credentials:
      - name: default
        serviceAccount:
        network:
        subnetwork:

```
