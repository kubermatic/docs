+++
title = "Upgrading from 1.7 to 1.8"
date = 2024-05-14T12:00:00+02:00
+++

This document contains important upgrade notes for upgrading from KubeOne 1.7
to 1.8. For the complete changelog, please check the
[complete v1.8.0 changelog on GitHub][changelog].

[changelog]: https://github.com/kubermatic/kubeone/blob/main/CHANGELOG/CHANGELOG-1.8.md

## Known Issues

Make sure to familiarize yourself with the known issues in KubeOne 1.8 before
upgrading by checking the [Known Issues document][known-issues].

[known-issues]: {{< ref "../../../known-issues" >}}

## Kubernetes Compatibility Changes

KubeOne 1.8 introduces support for Kubernetes 1.29 and 1.28. Support for
Kubernetes versions prior to 1.27 is removed as those releases already
reached End-of-Life (EOL).

If you have a Kubernetes cluster running 1.26 or earlier, you need to update to
Kubernetes 1.27 or newer using KubeOne 1.7. For more information, check out
the [Kubernetes compatibility document][k8s-compat].

[k8s-compat]: {{< ref "../../../architecture/compatibility/supported-versions/" >}}

## `vmType` Property Is Required in Cloud Config for Azure Clusters

{{% notice warning %}}
**This change must be done at latest _before_ upgrading to Kubernetes 1.28.**
{{% /notice %}}

Starting with Kubernetes 1.28, Azure CCM (Cloud Controller Manager) requires
specifying the `vmType` property in the cloud config if you use Standard Virtual
Machines instead of Virtual Machine Scale Sets (VMSS). KubeOne, by default,
uses Standard Virtual Machines, so this change is mandatory for all
Azure setups.

Add the following `vmType` property to your cloud config in your KubeOneCluster
manifest (`kubeone.yaml`):

```yaml
apiVersion: kubeone.k8c.io/v1beta2
kind: KubeOneCluster
cloudProvider:
  azure: {}
  external: true
  cloudConfig: |
    {
      ...
      "vmType": "standard"
    }
...
```

The change will be propagated the next time you run `kubeone apply`.

## External CCM/CSI Required for Azure and GCE Cluster Running Kubernetes 1.29 and newer

External CCM/CSI is required for Azure and GCE clusters starting with Kubernetes
1.29. If your clusters are using the in-tree cloud provider (`.cloudProvider.external`
is `false` or unset), you must migrate your clusters to the external CCM/CSI before
upgrading to Kubernetes 1.29. Please check [the documentation for more details about
the CCM/CSI  migration][ccm-migration].

[ccm-migration]: {{< ref "../../../guides/ccm-csi-migration/" >}}

## ‘kured’ Has Been Removed From the ‘unattended-upgrades’ Addon

As part of our efforts to migrate towards Helm charts for managing addons,
we removed `kured` from the `unattended-upgrades` addon. `kured` can now
be installed using `helmReleases` feature, such as:

```
apiVersion: kubeone.k8c.io/v1beta2
kind: KubeOneCluster
helmReleases:
  - chart: kured
    repoURL: https://kubereboot.github.io/charts
    namespace: kube-system
    version: 5.4.5
...
```

The documentation for this Helm chart can be found on [GitHub][kured-helm].

This way, you can more easily get the latest `kured` versions, but also have 
many more configuration options. For configuration options, check the Helm
chart documentation linked above.

[kured-helm]: https://github.com/kubereboot/charts/tree/main/charts/kured

## Example Terraform Configs Refactor

### Azure

The example Terraform configs for Azure are refactored to use the Standard SKU
Load Balancers instead of Basic SKU LBs. The Basic SKU Load Balancers are
deprecated and it's strongly recommended to use Standard SKU LBs for new
clusters.

Existing clusters should continue using the SKU they use at the moment,
as migrating from Basic to Standard SKU requires downtime and manual steps
that are yet to be documented. Additionally, it's recommend to keep using
the old example Terraform configs for existing clusters.

### Hetzner

The example Terraform configs for Hetzner are refactored to randomly generate
the private network to be used for the cluster. If you're migrating to the new
Terraform configs for an existing cluster, you need to take the following steps
to ensure that your private network is not deleted upon running `terraform apply`:

- Set `ip_range` variable in `terraform.tfvars` to the IP range that you're using
  currently. By default, `192.168.0.0/16` has been used previously
- Run `terraform plan` and make sure that it doesn't intend to remove your private
  network. If everything is okay, you can proceed by running `terraform apply`

## Precedence of Credentials Defined in the Credentials File

Previously, the credentials defined via environment variables had the top priority.
This is however in contrary with what we have documented and what is expected from
the credentials file feature.

This has been fixed in KubeOne 1.8, so that the credentials file (if provided) has
a priority over the environment variables.

If you use both the credentials file and the environment variables, we recommend
double-checking your credentials file to make sure the credentials are up to date,
as those credentials will be applied on the next `kubeone apply` run.

For information about other changes, we recommend checking out the
[changelog][changelog].
