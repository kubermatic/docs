+++
title = "Overwriting Image Registries"
date = 2021-12-01T12:00:00+02:00
+++

## Introduction

{{% notice warning %}}
A newer version of this guide based on the ContainerRegistry API is available
[here]({{< ref "../mirror-registries" >}}).
{{% /notice %}}

This guide describes how to overwrite image registries for images deployed by
KubeOne (Kubernetes core components, CNI plugins...). This is useful if don't
have access to the original registries (e.g. you're having an offline setup)
or if you want to workaround Docker Hub pull limits. To accomplish this, this
guide uses the [RegistryConfiguration API][regconfig-api].

## Prerequisites

This guide assumes that:

* You have an image registry up and running
* All your nodes in the cluster can access the image registry
* The image registry allows unauthenticated access (support for providing image registry credentials is planned for KubeOne 1.4)
* If you're using containerd for your cluster, the image registry must support TLS

If you don't have an image registry, you can check out the
[Docker Registry][docker-reg-guide] as a possible solution.

## Mirroring Images with `kubeone mirror-images`

KubeOne provides a built-in command `kubeone mirror-images` to simplify mirroring all required images (Kubernetes core components, CNI plugins, etc.) to your private registry. This command replaces the older `image-loader.sh` script and supports advanced filtering and multi-version mirroring.

### Prerequisites

1. **Registry Setup**: Ensure your registry is accessible by all cluster nodes and supports TLS if using containerd.
2. **Authentication**: The registry must allow unauthenticated access (support for credentials is planned for future releases).
3. **KubeOne CLI**: Use KubeOne v1.5.0 or newer.

### Usage

The `kubeone mirror-images` command pulls, re-tags, and pushes images to your registry. Use the following syntax:

```bash
kubeone mirror-images \
  [--filter base,optional,control-plane] \
  [--kubernetes-versions v1.34.1,v1.33.5] \
  [--insecure]  # Allow pushing to insecure registries (HTTP) \
  --registry <your-registry>
```

#### Key Flags:
- `--filter`: Select image groups (comma-separated):
  - `base`: Core images (OSM, DNS Cache, Calico, Machine-Controller).
  - `optional`: Add-ons like CCMs and CSI Drivers.
  - `control-plane`: Only Kubernetes core components (kube-apiserver, etcd, etc.).
- `--kubernetes-versions`: Specify versions (comma-separated). If omitted, **all KubeOne-supported versions are mirrored**.
- `--insecure`: Skip TLS verification for registries using HTTP (useful for local/insecure setups).

### Examples

#### 1. Mirror All Base Images for Specific Versions
```bash
kubeone mirror-images \
  --filter base \
  --kubernetes-versions v1.34.1,v1.33.5 \
  registry.example.com:5000
```

#### 2. Mirror Only Control-Plane Images For All Supported Versions
```bash
kubeone mirror-images \
  --filter control-plane \
  registry.example.com:5000
```

### Benefits of `kubeone mirror-images`
- **Simpler Workflow**: No need to manually download or manage scripts.
- **Multi-Version Support**: Mirror images for multiple Kubernetes versions in one command.
- **Granular Control**: Use filters to mirror only the images you need.
- **Automated Retagging**: Handles registry prefixes (e.g., `docker.io` → `registry.example.com`).

## Overriding Image Registries

You can override the image registries by adding the `registryConfiguration`
stanza to your KubeOne configuration file, such as:

```yaml
apiVersion: kubeone.k8c.io/v1beta2
kind: KubeOneCluster
versions:
  kubernetes: 1.34.1
cloudProvider:
  aws: {}
registryConfiguration:
  overwriteRegistry: '127.0.0.1:5000'
  insecureRegistry: false
```

Make sure to replace the `overwriteRegistry` value with the URL of your image
registry. If your image registry doesn't support TLS access, make sure to set
`insecureRegistry` to `true`.

{{% notice warning %}}
As stated in the prerequisites, if you're using containerd, `insecureRegistry`
option is not supported, i.e. your image registry **must** support the TLS
access.
{{% /notice %}}

With this done, you can reconcile your cluster by running `kubeone apply --force-upgrade`.

## Known Issues

Kubeadm uses `<your-registry>/coredns:<tag>` semantics for overriding the CoreDNS image registry from Kubernetes 1.22+ release.

The image loader script that comes with KubeOne has addressed this case. If you're using a custom solution for
preloading images, please make sure to handle this case as appropriate.

## Alternatives

{{% notice warning %}}
We **heavily advise** using the approach described above. This section shows
possible alternatives that should be used **ONLY** in the case when you are
**NOT** able to use the approach described above.
{{% /notice %}}

As an alternative, you can follow the [Using Mirror Registries]({{< ref "../mirror-registries" >}}) guide.

[regconfig-api]: {{< ref "../../references/kubeone-cluster-v1beta2#registryconfiguration" >}}
[docker-reg-guide]: https://docs.docker.com/registry/
[img-loader]: https://github.com/kubermatic/kubeone/blob/main/hack/image-loader.sh
