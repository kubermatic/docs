+++
title = "Upgrading from 1.2 to 1.3"
date = 2021-09-10T12:00:00+02:00
+++

This document contains important upgrade notes for upgrading from KubeOne 1.2
to 1.3. For the complete changelog, please check the
[complete v1.3.0 changelog on GitHub][changelog].

## Support and Compatibility Policy Changes

The KubeOne 1.3 release brings some changes to the support and compatibility
policies.

### Kubernetes

The **minimum** supported Kubernetes version is now **1.19.0**. If you have
Kubernetes clusters running 1.18 or older, you need to use an older KubeOne
release to upgrade those clusters to v1.19 **before** upgrading to KubeOne 1.3.
Check out the [Compatibility guide][compatibility] for more information about
supported Kubernetes versions for each KubeOne release.

The Kubernetes 1.22 release is officially supported starting with this release.

We recommend using a Kubernetes release that’s not older than one minor release
than the latest Kubernetes release. For example, with 1.22 being the latest
release, we recommend running at least Kubernetes 1.21.

### Terraform

In addition, the **minimum** Terraform version is now **1.0.0**. All
example Terraform configurations provided by KubeOne work only with Terraform
1.0.0 or newer. You might be able to continue using an older version of
Terraform with existing/older configurations, but we don't provide any support
for older Terraform versions and we **strongly recommend** upgrading to 1.0.0
as soon as possible.

{{% notice note %}}
You can check the
[following KubeOne PR](https://github.com/kubermatic/kubeone/pull/1376) as an
example how to modify existing Terraform configurations to support Terraform
1.0 and newer.
{{% /notice %}}

### Operating Systems

Starting with this release, we're **dropping** support for **Debian 10**,
**Debian 11**, and **RHEL 7** clusters. If you have a Debian cluster, we
recommend switching to other operating system such as Ubuntu. If you have a
RHEL 7 cluster, we recommend switching to RHEL 8 which is supported.

Support for CentOS 8 clusters is **deprecated** starting with KubeOne 1.3
release and it will be entirely **removed** in KubeOne 1.4. CentOS 8 announced
that it will reach [End-Of-Life (EOL) on December 31, 2021][centos-eol].
CentOS 7 remains supported by KubeOne for now.

{{% notice note %}}
We're researching about supporting alternative CentOS distributions and we'll
provide updates accordingly. In meanwhile, if you have any feedback on which
distribution should we support instead, feel free to create a GitHub issue or
reach out to us over product@kubermatic.com.
{{% /notice %}}

Amazon Linux 2 is now a supported operating system for general Kubernetes
clusters.

## `kubeone reset` Confirmation

The `kubeone reset` command **requires** an **explicit confirmation** like the
`apply` command. This change has been announced with KubeOne 1.2 release, and
it's now in the effect. Running the command will show a recap of which nodes
will be reset and which Machines will be destroyed. The command can be approved
by typing `yes` or using the `--auto-approve` flag.

{{% notice note %}}
If you're using `kubeone reset` as part of an automated script (e.g. in a CI
pipeline), you should adjust your scripts to use the `--auto-approve` flag, so
you're not asked to explicitly confirm the command.
{{% /notice %}}

## Addons Reorganization

KubeOne Addons can now be organized into subdirectories. It currently remains
possible to put addons in the root of the addons directory, however, this is
option is considered as **deprecated** as of this release. We highly recommend
all users to reorganize their addons into subdirectories, where each
subdirectory is for YAML manifests related to one addon.

### Example Reorganization

For example, if you provided `./addons` as the addons directory (using 
`.addons.path` in the KubeOneCluster manifest), you should move all YAML
manifest located in the root of `./addons` directory to dedicated
subdirectories.

Let's say you have two YAML manifests — one for cluster-autoscaler and another
for backups. Your `./addons` directory currently looks like this:

```
addons
├── backups-restic.yaml
└── cluster-autoscaler.yaml
```

After the reorganization, the `./addons` directory should look like this:

```
addons
├── backups-restic
│   └── backups-restic.yaml
└── cluster-autoscaler
    └── cluster-autoscaler.yaml
```

{{% notice warning %}}
Addons can be organized into subdirectories, but only one level of
subdirectories is supported. For example, `./addons/example-addon-1` is
supported and YAML manifest in that directory will be deployed, but
`./addons/example-addon-1/subdirectory-2` directory will be entirely ignored.
{{% /notice %}}

## Automatically Deploying the CSI Plugins

The CSI plugin is now **deployed automatically** for Hetzner, OpenStack, and
vSphere clusters with external cloud provider (i.e. `.cloudProvider.external` 
enabled).

{{% notice warning %}}
vSphere CSI plugin requires the CSI configuration to be provided via the
newly-added `cloudProvider.csiConfig` field. If it's not provided, the CSI
plugin will **not** be automatically deployed. More information about the CSI
plugin configuration can be found in the
[vSphere CSI docs](https://vsphere-csi-driver.sigs.k8s.io/driver-deployment/installation.html#create_csi_vsphereconf).
In addition, the vSphere CSI plugin requires vSphere version 6.7u3.
{{% /notice %}}

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

## Known Issues

* It's currently **not** possible to provision or upgrade to Kubernetes 1.22
  for clusters running on vSphere. This is because vSphere CCM and CSI don't
  support Kubernetes 1.22. We'll introduce Kubernetes 1.22 support for vSphere
  as soon as new CCM and CSI releases with support for Kubernetes 1.22 are out.
* Newly-provisioned Kubernetes 1.22 clusters or clusters upgraded from
  Kubernetes 1.21 to 1.22 using KubeOne 1.3.0-alpha.1 use a metrics-server
  version incompatible with Kubernetes 1.22. This might impact deleting
  Namespaces that manifests by the Namespace being stuck in the Terminating
  state. This can be fixed by upgrading KubeOne to v1.3.0-rc.0 or newer and
  running `kubeone apply`.
* The new Addons API requires the addons directory path (`.addons.path`) to be
  provided and the directory must exist (it can be empty), even if only
  embedded addons are used. If the path is not provided, it'll default to
  `./addons`.

[changelog]: https://github.com/kubermatic/kubeone/blob/master/CHANGELOG.md#v130
[compatibility]: {{< ref "../../../architecture/compatibility" >}}
[centos-eol]: https://www.centos.org/centos-linux-eol/
[addons-api]: {{< ref "../../../guides/addons" >}}
[addons]: https://github.com/kubermatic/kubeone/tree/release/v1.3/addons
[addons-override]: {{< ref "../../../guides/addons#overriding-embedded-eddons" >}}
