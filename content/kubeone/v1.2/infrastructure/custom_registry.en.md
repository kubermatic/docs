+++
title = "Custom Registry"
date = 2020-10-27T12:00:00+02:00
weight = 4
+++

## RegistryConfiguration

It's possible to configure the central docker image registry to pull images from.

The `registryConfiguration.overwriteRegistry` specifies a custom Docker registry which will be used for all images
required by the KubeOne and KubeAdm. This also applies to addons deployed by KubeOne. This field doesn't modify the
user/organization part of the image. For example, if `overwriteRegistry` is set to `127.0.0.1:5000/example`, image
called `calico/cni` would translate to `127.0.0.1:5000/example/calico/cni`.

```yaml
apiVersion: kubeone.io/v1beta1
kind: KubeOneCluster
name: demo-cluster

versions:
  kubernetes: "1.18.6"

registryConfiguration:
  overwriteRegistry: "my.supercool.registry"
```

## image-loader.sh (requires linux)

There is a [hack/image-loader.sh][1] script to help retag images from the public registries to your custom registry. The
following commands will retag those images.

```bash
$ curl -L -o image-loader.sh https://raw.githubusercontent.com/kubermatic/kubeone/master/hack/image-loader.sh
$ chmod +x image-loader.sh
$ export KUBERNETES_VERSION=1.18.6
$ export TARGET_REGISTRY=my.supercool.registry
$ ./image-loader.sh
```

[1]: https://raw.githubusercontent.com/kubermatic/kubeone/master/hack/image-loader.sh
