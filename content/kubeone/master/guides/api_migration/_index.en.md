+++
title = "Migrating to the KubeOneCluster v1beta2 API"
date = 2022-02-11T12:00:00+02:00
enableToc = true
+++

Starting with v1.4.0, KubeOne comes with a new v1beta2 version of the
KubeOneCluster API. The new API is similar to the v1beta2 API, with
a couple of improvements.

This document shows how to migrate from the v1beta1 API to the v1beta2
API, as well as, what has been changed between two versions.

It remains possible to use all KubeOne commands with the v1beta1 manifest,
however, it's strongly advised to migrate to the latest API version as soon
as possible.

{{% notice note %}}
To migrate to the v1beta2 API, you must upgrade KubeOne to v1.4.0 or newer.
{{% /notice %}}

## Migrating the manifest using the `config migrate` command

The `config migrate` command automatically migrates the v1beta1 manifests to
the new v1beta2 API. The command takes the path to the v1beta1 manifest
and prints the converted manifest to the standard output.

Example usage:

```bash
kubeone config migrate --manifest kubeone.yaml
```

{{% notice warning %}}
It's strongly advised to compare the old and new manifests to ensure that no
information is missing in the new manifest. If you see anything unexpected
and not covered by the [The API Changelog]({{< ref "#the-api-changelog" >}}) portion of this document, please
[file a new issue on GitHub](https://github.com/kubermatic/kubeone/issues/new?labels=kind%2Fbug&template=bug-report.md).
{{% /notice %}}

## The API Changelog

The API version of the new API is `v1beta2`. The kind remains `KubeOneCluster`.

### API group

The API group has been changed from `kubeone.io` to `kubeone.k8c.io`.

```yaml
# v1beta1 API
apiVersion: kubeone.io/v1beta1

# v1beta2 API
apiVersion: kubeone.k8c.io/v1beta2
```

### Addons path defaulting has been removed

The addons path has been defaulted to `./addons` in the v1beta1 API.
Additionally, the addons path was required and the directory must have existed.

To better support the embedded addons, we don't default the addons directory
to `./addons` any longer. Instead, the addons path isn't required as long as
you use only embedded addons.

The migration command will put set the addons path to `./addons` to keep the
backwards compatibility. If you only use the embedded addons, you can remove
the addons path manually after migrating the config file.

### The PodPresets feature has been removed

The PodPresets feature has been a no-op since Kubernetes 1.20 because the
feature was removed from Kubernetes. This feature is now removed from the
KubeOneCluster API as well.

### The AssetConfiguration API has been removed

The AssetConfiguration API has been removed in the v1beta2 API, along with
support for Amazon EKS-D clusters.

If you are using the AssetConfiguration API to mitigate the issue with the
CoreDNS image when using the overwrite registry feature, you can use the latest
image loader script or [the mirror registries][mirror-registries] feature.

[mirror-registries]: 

### Packet to Equinix Metal rebranding

Packet has got rebranded to Equinix Metal. We have changed the name of the
cloud provider from `packet` to `equinixmetal`.

```yaml
# v1beta1 API
cloudProvider:
  packet: {}

# v1beta2 API
cloudProvider:
  equinixmetal: {}
```

Additionally, we also support `METAL_AUTH_TOKEN` and `METAL_PROJECT_ID`
environment variables in addition to `PACKET_API_KEY` and `PACKET_PROJECT_ID`,
which will be removed after the deprecation period.

### Added features

The new API version also introduces many new features. We recommend checking
[the KubeOne 1.4.0 release changelog][changelog] for more information about the
new features.

[changelog]: https://github.com/kubermatic/kubeone/blob/master/CHANGELOG.md#v140---2022-02-16
