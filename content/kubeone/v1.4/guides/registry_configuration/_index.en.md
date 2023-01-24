+++
title = "Overwriting Image Registries"
date = 2021-12-01T12:00:00+02:00
+++

## Introduction

{{% notice warning %}}
A newer version of this guide based on the ContainerRegistry API is available
[here]({{< ref "../mirror_registries" >}}).
{{% /notice %}}

This guide describes how to overwrite image registries for images deployed by
KubeOne (Kubernetes core components, CNI plugins...). This is useful if don't
have access to the original registries (e.g. you're having an offline setup)
or if you want to workaround Docker Hub pull limits. To accomplish this, this
guide uses the [RegistryConfiguration API][regconfig-api].

{{% notice note %}}
The RegistryConfiguration API can currently only override all image registries,
including non-Docker registries such as `k8s.gcr.io` and `quay.io`. We're
planning to extend the functionality in KubeOne 1.4 to allow overriding only
`docker.io` registry. 
{{% /notice %}}

## Prerequisites

This guide assumes that:

* you have an image registry up and running
* all your nodes in the cluster can access the image registry
* the image registry allows unauthenticated access (support for providing
  image registry credentials is planned for KubeOne 1.4)
* if you're using containerd for your cluster, the image registry must support
  TLS

If you don't have an image registry, you can check out the
[Docker Registry][docker-reg-guide] as a possible solution.

## Preloading Images

Another prerequisites for this guide to work is that your image registry has
all images needed for your cluster to work preloaded.

To make this task easier, we provide the image loader script that:

* pulls all images used by components deployed by KubeOne (CNI,
  metrics-server...) and Kubeadm (Kubernetes core components and CoreDNS)
* re-tag those images so the image registry (e.g. `docker.io`) is replaced
  with the image registry provided by the user
* push re-tagged images to your (mirror) image registry

The image loader script (`image-loader.sh`) comes in the KubeOne release
archive, under the `hack` directory. It can also be found on [GitHub in the
`hack` directory][img-loader]. If you're downloading the script from GitHub,
it's recommended to switch to the appropriate tag depending on which KubeOne
version you're using.

Once you have downloaded the script, you can run it in the following way.
Make sure to replace `KUBERNETES_VERSION` with the Kubernetes version you plan
to use (without the `v` prefix), as well as, replace the `TARGET_REGISTRY` with
the address to your image registry.

```
KUBERNETES_VERSION=1.22.5 TARGET_REGISTRY=127.0.0.1:5000 ./image-loader.sh
```

The preloading process can take a several minutes, depending on your
connection speed.

## Overriding Image Registries

You can override the image registries by adding the `registryConfiguration`
stanza to your KubeOne configuration file, such as:

```yaml
apiVersion: kubeone.k8c.io/v1beta2
kind: KubeOneCluster
versions:
  kubernetes: 1.22.5
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

With this done, you can reconcile your cluster by running `kubeone apply`.

## Known Issues

Kubeadm uses different semantics for overriding the CoreDNS image registry.
The image that will be used for CoreDNS depends on the Kubernetes version:

* for 1.21 => `<your-registry>/coredns/coredns:<tag>` will be used as the
  CoreDNS image
* for all other release (including 1.22+) => `<your-registry>/coredns:<tag>`
  will be used as the CoreDNS image

The image loader script that comes with KubeOne 1.3.3 or newer has been fixed
to specially address this case. If you're using a custom solution for
preloading images, please make sure to handle this case as appropriate.

## Alternatives

{{% notice warning %}}
We **heavily advise** using the approach described above. This section shows
possible alternatives that should be used **ONLY** in the case when you are
**NOT** able to use the approach described above.
{{% /notice %}}

{{% notice note %}}
We plan on introducing a new registry mirrors functionality in KubeOne 1.4 as
an alternative to the overwrite registry functionality. The new functionality
will be able to override only specific registries such as `docker.io`.
{{% /notice %}}

The alternative to the RegistryConfiguration API if you don't want to override
image registry for all images is to change the YAML manifests used by KubeOne
to deploy the desired component. This can be done by overriding the appropriate
embedded addon which deploys the desired component, as described in the
[Addons document][override-addons].

{{% notice warning %}}
If you're overriding addons, you **MUST** manually update the desired addons
when updating KubeOne, or otherwise, you might end up with a non-working
cluster.
{{% /notice %}}

[regconfig-api]: {{< ref "../../references/kubeone_cluster_v1beta2#registryconfiguration" >}}
[docker-reg-guide]: https://docs.docker.com/registry/
[img-loader]: https://github.com/kubermatic/kubeone/blob/master/hack/image-loader.sh
[override-addons]: {{< ref "../addons#overriding-embedded-eddons" >}}
