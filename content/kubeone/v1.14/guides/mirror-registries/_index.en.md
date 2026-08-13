+++
title = "Using Mirror Registries"
date = 2021-12-01T12:00:00+02:00
+++

## Introduction

This guide describes how to use mirror registries for images deployed by
KubeOne (Kubernetes core components, CNI plugins...). This is useful if don't
have access to the original registries (e.g. you're having an offline setup)
or if you want to workaround Docker Hub pull limits. To accomplish this, this
guide uses the [ContainerRegistry API][containerreg-api].

## Prerequisites

This guide assumes that:

* You have an image registry up and running
* All your nodes in the cluster can access the image registry

If you don't have an image registry, you can check out the
[Docker Registry][docker-reg-guide] as a possible solution.

## Configuring Mirror Registries

This section describes how to configure the mirror registries.

### Containerd

You can configure the mirror registries by adding the `containerRuntime`
stanza to your KubeOne configuration file, such as:

```yaml
apiVersion: kubeone.k8c.io/v1beta2
kind: KubeOneCluster
versions:
  kubernetes: 1.34.1
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

The credentials file is provided to the `kubeone apply` command using the
`--credentials`/`-c` flag, such as:

```
kubeone apply --manifest kubeone.yaml --credentials credentials.yaml
```

## docker.io pull rate limitations

docker.io registry introduced pretty low rate limits for unauthenticated requests. There are few workarounds:

* Buy docker subscription.
  How to use docker.io credentials is covered in the [section above][using-credentials].
* Setup own pull-through caching proxy.
* Use public pull-through caching proxy.

### Configuring Public Pull-through Caching Proxy

Google has launched caching public images proxy [mirror.gcr.io](https://cloud.google.com/artifact-registry/docs/pull-cached-dockerhub-images). Let's configure that one.

```yaml
apiVersion: kubeone.k8c.io/v1beta2
kind: KubeOneCluster

versions:
  kubernetes: 1.34.1

containerRuntime:
  containerd:
    registries:
      docker.io:
        mirrors:
        - mirror.gcr.io
```

## Alternatives

As an alternative, you can follow the [Overwriting Image Registries]({{< ref "../registry-configuration" >}}) guide, however it's considered as legacy.

[containerreg-api]: {{< ref "../../references/kubeone-cluster-v1beta2#containerruntimecontainerd" >}}
[containerruntime-containerd]: {{< ref "../../references/kubeone-cluster-v1beta2#containerruntimecontainerd" >}}
[docker-reg-guide]: https://docs.docker.com/registry/
[using-credentials]: #using-the-credentials-file-for-the-containerd-registry-configuration
