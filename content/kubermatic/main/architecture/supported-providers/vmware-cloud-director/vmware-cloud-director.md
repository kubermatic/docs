+++
title = "VMware Cloud Director"
date = 2022-08-14T12:00:00+02:00
enableToc = true
weight = 7

+++

## Prepare VMware Cloud Director Environment

Prerequisites for provisioning Kubernetes clusters with the KKP are as follows:

1. An Organizational Virtual Data Center (VDC).
2. `Edge Gateway` is required for connectivity with the internet, network address translation, and network firewall.
3. Organizational Virtual Data Center network is connected to the edge gateway.
4. Ensure that the distributed firewalls are configured in a way that allows traffic flow within and out of the VDC.

Kubermatic Kubernetes Platform (KKP) integration has been tested with `VMware Cloud Director 10.4`.

## Configure the datacenter

Following settings can be configured at the `Seed` level

- `allowInsecure`: Disable TLS checks when interacting with VMware Cloud Director API.
- `catalog`: Default catalog to use for vApp templates.
- `storageProfile`: Default storage profile to use for provisioning disks.
- `templates`: Default templates for supported operating systems.
- `url`: The URL for the VMware Cloud Director API endpoint.

```yaml
apiVersion: kubermatic.k8c.io/v1
kind: Seed
metadata:
  name: kubermatic
  namespace: kubermatic
spec:
  # these two fields are only informational
  country: FR
  location: Paris

  # List of datacenters where this seed cluster is allowed to create clusters.
  datacenters:
    vmware-cloud-director-ger:
      country: DE
      location: Hamburg
      spec:
        vmwareclouddirector:
          allowInsecure: false
          catalog: <default-catalog-name>
          storageProfile: <default-storage-profile-name>
          templates:
            ubuntu: ubuntu
          url: <vmware-cloud-director-endpoint>
```

## CSI Driver

CSI driver settings can be configured at the cluster level when creating a cluster using UI or API. The following settings are required:

1. Storage Profile: Used for creating persistent volumes.
2. Filesystem: Filesystem to use for named disks. Allowed values are ext4 or xfs.

## Known Limitations

- External Cloud Controller Manager is not supported yet. Please refer to the [GitHub Issue](https://github.com/kubermatic/kubermatic/issues/10752) for more details.
