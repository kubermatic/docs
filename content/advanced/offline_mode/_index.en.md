+++
title = "Kubermatic Offline Mode"
date = 2018-04-28T12:07:15+02:00
weight = 7
pre = "<b></b>"
+++

### Kubermatic offline mode

## Download all required images

To aid in downloading all required images, Kubermatic provides the `image-loader` CLI utility. It can be used like
this:

```bash
image-loader \
  -versions charts/kubermatic/static/master/versions.yaml \
  -registry 172.20.0.2:5000 \
  -log-format=Console
```

## Worker nodes behind a proxy

In situations where worker nodes will require a proxy to reach the internet, the `datacenters.yaml` must be modified:

```yaml
...
  gcp-westeurope:
    location: "Europe West (Germany)"
    seed: europe-west3-a
    country: DE
    provider: gcp
    spec:
      gcp:
        region: europe-west3
        zone_suffixes:
        - a
    node:
      # Configure the address of the proxy
      # It will be configured on all worker nodes. It results in the HTTP_PROXY & HTTPS_PROXY environment variable being set.
      http_proxy: "http://172.20.0.2:3128"
      # Worker nodes require access to a docker registry, in case it is only accessible using http or it uses a self signed certificate, they must be listed here
      insecure_registries:
        - 172.20.0.2:5000
      # The kubelet requires the pause image, if its only accessible using a private registry, the image name must be configured here
      pause_image: "172.20.0.2:5000/kubernetes/pause:3.1"
      # ContainerLinux requires the hyperkube image, if its only accessible using a private registry, the image name must be configured here
      hyperkube_image: "172.20.0.2:5000/kubernetes/hyperkube-amd64"
```
