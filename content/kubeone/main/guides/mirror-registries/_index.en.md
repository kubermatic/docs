+++
title = "Using Mirror Registries"
date = 2021-12-01T12:00:00+02:00
enableToc = true
+++

## Introduction

{{% notice warning %}}
The ContainerRegistry API is available only starting with KubeOne 1.4 and
newer. Additionally, Docker supports only configuring the mirror registry for
`docker.io` images. As an alternative, you can follow the
[Overwriting Image Registries guide]({{< ref "../registry-configuration" >}})
guide, however it's considered as legacy. We recommend upgrading to KubeOne 1.4
and migrating to containerd.
{{% /notice %}}

This guide describes how to use mirror registries for images deployed by
KubeOne (Kubernetes core components, CNI plugins...). This is useful if don't
have access to the original registries (e.g. you're having an offline setup)
or if you want to workaround Docker Hub pull limits. To accomplish this, this
guide uses the [ContainerRegistry API][containerreg-api].

## Prerequisites

This guide assumes that:

* you have an image registry up and running
* all your nodes in the cluster can access the image registry

If you don't have an image registry, you can check out the
[Docker Registry][docker-reg-guide] as a possible solution.

## Configuring Mirror Registries

This section describes how to configure the mirror registries.

### Docker

{{% notice warning %}}
Docker supports configuring mirror registries only for `docker.io` images.
{{% /notice %}}

You can configure the mirror registries by adding the `containerRuntime`
stanza to your KubeOne configuration file, such as:

```yaml
apiVersion: kubeone.k8c.io/v1beta2
kind: KubeOneCluster
versions:
  kubernetes: 1.22.5
cloudProvider:
  aws: {}
containerRuntime:
  docker:
    registryMirrors:
      - http://host1.tld
      - https://host2.tld
```

For more information about the ContainerRuntime API for Docker, see the
[API reference][containerruntime-docker].

With this done, you can reconcile your cluster by running `kubeone apply`.

### Containerd

You can configure the mirror registries by adding the `containerRuntime`
stanza to your KubeOne configuration file, such as:

```yaml
apiVersion: kubeone.k8c.io/v1beta2
kind: KubeOneCluster
versions:
  kubernetes: 1.22.5
cloudProvider:
  aws: {}
containerRuntime:
  containerd:
    registries:
      myunknown.tld:
        mirrors:
        - host1.tld
        - https://host2.tld
        tlsConfig:
          insecureSkipVerify: true
        auth:
          username: "user1"
          password: "insecure"
```

`tlsConfig` and `auth` are optional. Make sure to replace the placeholder
values (`myunknown.tld`, `host1.tld`, `https://host2.tld`...).

For more information about the ContainerRuntime API for containerd, see the
[API reference][containerruntime-containerd].

With this done, you can reconcile your cluster by running `kubeone apply`.

#### Using the credentials file for the containerd registry configuration

The registry configuration can be also provided via the credentials file. This
is useful in case you're providing authentication credentials and you want to
keep them in a separate file.

The credentials file can look like the following one:

```yaml
registriesAuth: |
  apiVersion: kubeone.k8c.io/v1beta2
  kind: ContainerRuntimeContainerd
  registries:
    my-cool-registry.tld:
      auth:
        username: "stone"
        password: "bridge"
```

Make sure to have containerd explicitly enabled in the KubeOneCluster manifest:

```yaml
...
containerRuntime:
  containerd: {}
```

The credentials file is provided to the `kubeone apply` command using the
`--credentials`/`-c` flag, such as:

```
kubeone apply --manifest kubeone.yaml --credentials credentials.yaml
```

[containerreg-api]: {{< ref "../../references/kubeone-cluster-v1beta2#containerruntimecontainerd" >}}
[containerruntime-docker]: {{< ref "../../references/kubeone-cluster-v1beta2#containerruntimedocker" >}}
[containerruntime-containerd]: {{< ref "../../references/kubeone-cluster-v1beta2#containerruntimecontainerd" >}}
[docker-reg-guide]: https://docs.docker.com/registry/
