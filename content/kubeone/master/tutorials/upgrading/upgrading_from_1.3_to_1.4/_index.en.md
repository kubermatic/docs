+++
title = "Upgrading from 1.3 to 1.4"
date = 2022-02-11T12:00:00+02:00
enableToc = true
+++

This document contains important upgrade notes for upgrading from KubeOne 1.3
to 1.4. For the complete changelog, please check the
[complete v1.4.0 changelog on GitHub][changelog].

## The v1beta2 API

KubeOne 1.4 introduces the new API version — v1beta2. The v1beta1
can still be used with KubeOne 1.4, but it's considered as deprecated and will
be removed in KubeOne 1.6+

Users can migrate to the new API version by running the following command:

```
kubeone config migrate --manifest kubeone.yaml
```

More information about what's changed in the new API version can be found
in [the API migration document][v1beta2].

## Support and Compatibility Policy Changes

The KubeOne 1.4 release brings some changes to the support and compatibility
policies.

### Kubernetes

The **minimum** supported Kubernetes version is now **1.20.0**. If you have
Kubernetes clusters running 1.19 or older, you need to use an older KubeOne
release to upgrade those clusters to v1.20 **before** upgrading to KubeOne 1.4.
Check out the [Compatibility guide][compatibility] for more information about
supported Kubernetes versions for each KubeOne release.

The Kubernetes 1.23 release is officially supported starting with this release.
Currently, Kubernetes 1.23 is **not** supported on **vSphere** clusters.

We recommend using a Kubernetes release that’s not older than one minor release
than the latest Kubernetes release. For example, with 1.22 being the latest
release, we recommend running at least Kubernetes 1.21.

Starting with this KubeOne release, we're also checking the maximum supported 
Kubernetes version, which is 1.23.

### Operating Systems

Starting with this release, we're **deprecating** support for **CentOS 8**
because CentOS 8 reached [End-of-Life (EOL) on January 31, 2022][centos-eol].
If you have a CentOS 8 cluster, we recommend switching to other operating
system or RHEL rebuild such as Rocky Linux.

{{% notice note %}}
We're researching about supporting alternative CentOS distributions and we'll
provide updates accordingly. In meanwhile, if you have any feedback on which
distribution should we support instead, feel free to create a GitHub issue or
reach out to us over product@kubermatic.com.
{{% /notice %}}

## Automatically Deploying the CSI Plugins

In KubeOne 1.3, the CSI plugin was automatically deployed for some providers
if `.cloudProvider.external` is enabled. Due to some upstream changes,
Kubernetes 1.23 and newer requires a CSI driver to be deployed for some
providers.

Therefore, we're now automatically deploying a CSI driver:

* unconditionally for DigitalOcean, Hetzner, Nutanix, and OpenStack
* if Kubernetes version is 1.23 or newer for AWS and Azure

In case of OpenStack, the `CSIMigrationOpenStack` feature gate is enabled by
default since Kubernetes 1.18, so the CSI driver will be used for all volumes
operations. Similar for AWS, Azure, and vSphere, the appropriate `CSIMigration`
feature gate is enabled since Kubernetes 1.23, so the CSI driver will be used
for all volumes operations.

The default StorageClass is **not** deployed by default. It can be deployed via
new [Addons API][addons-api] by enabling the `default-storage-class` addon, or
manually.

If you already have the CSI plugin deployed, you need to make sure that your
CSI plugin deployment is compatible with the KubeOne CSI plugin addon. You can
find the CSI addons in the [`addons` directory in the GitHub
repository][addons].

If your CSI plugin deployment is incompatible with the KubeOne CSI addon, you
can resolve it in one of the following ways:
      
* Delete your CSI deployment and let KubeOne install the CSI driver for you.
  **Note**: you'll **not** be able to mount volumes until you don't install the
  CSI driver again.
* Override the appropriate CSI addon with your deployment manifests. With this
  way, KubeOne will install the CSI plugin using your manifests. To do this,
  check out the [Overriding Embedded Addons section of the Addons
  document][addons-override] for instructions.

## Packet to Equinix Metal rebranding

Packet has got rebranded to Equinix Metal. We have changed the name of the
cloud provider from `packet` to `equinixmetal` in the v1beta2 API.

Additionally, we also support `METAL_AUTH_TOKEN` and `METAL_PROJECT_ID`
environment variables in addition to `PACKET_API_KEY` and `PACKET_PROJECT_ID`,
which will be removed after the deprecation period.

The example Terraform configs for Packet have been replaced with the example
Terraform configs for Equinix Metal. Overall, the configs are the same, but
the Equinix Metal are using the Equinix Metal Terraform provider and the
appropriate Terraform resources.

Existing Terraform configs for Packet can be converted to Equinix Metal by
following steps:

* Make a backup of your existing Terraform state
* Take the new Equinix Metal Terraform configs from `examples/terraform`
  directory
* Copy your Terraform state to the new Equinix Metal configs
* Run the following two commands:
    ```
    sed -i 's/packet_/metal_/g' terraform.tfstate
    sed -i 's/packethost\/packet/equinix\/metal/g' terraform.tfstate
    ```
* Run `terraform plan` and ensure there are no breaking changes that would
  cause instances to be recreated
* Run `terraform apply`

Alternative to `sed` is to use the `terraform import` command, but it requires
object IDs, which you would have to extract from the state manually.

## Amazon EKS-D support

Support for Amazon EKS-D has been removed in KubeOne 1.4. We recommend
switching to the upstream Kubernetes instead.

## Known Issues

* It's currently **not** possible to provision or upgrade to Kubernetes 1.23
  for clusters running on vSphere. This is because vSphere CCM and CSI don't
  support Kubernetes 1.23. We'll introduce Kubernetes 1.23 support for vSphere
  as soon as new CCM and CSI releases with support for Kubernetes 1.23 are out.
* It's not possible to run kube-proxy in IPVS mode on Kubernetes 1.23 clusters
  using Canal/Calico CNI. Trying to upgrade existing 1.22 clusters using IPVS
  to 1.23 will result in a validation error from KubeOne

[changelog]: https://github.com/kubermatic/kubeone/blob/master/CHANGELOG.md#v140
[v1beta2]: {{< ref "../../../guides/api_migration" >}}
[compatibility]: {{< ref "../../../architecture/compatibility" >}}
[centos-eol]: https://www.centos.org/centos-linux-eol/
[addons]: https://github.com/kubermatic/kubeone/tree/master/addons
