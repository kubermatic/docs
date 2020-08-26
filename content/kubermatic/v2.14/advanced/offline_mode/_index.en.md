+++
title = "Kubermatic Offline Air Gapped Mode"
date = 2018-04-28T12:07:15+02:00
weight = 7

+++

### Download All Required Images

To aid in downloading all required images, Kubermatic provides the `image-loader` CLI utility. It can be used like
this:

```bash
image-loader \
  -versions charts/kubermatic/static/master/versions.yaml \
  -registry 172.20.0.2:5000 \
  -log-format=Console
```

### Worker Nodes Behind a Proxy

In situations where worker nodes will require a proxy to reach the internet, the datacenter specification for the
Seed cluster must be updated. This can be found in the [Seed]({{< ref "../../concepts/seeds" >}}) CRD. Find the
relevant seed via `kubectl`:

```bash
kubectl -n kubermatic get seeds
#NAME        AGE
#hamburg     143d
#frankfurt   151d
```

You will then find the datacenter inside the `spec.datacenters` list of the right Seed. You need to set a couple
of `node` settings:

```yaml
spec:
  datacenters:
    example-dc:
      location: Hamburg
      country: DE
      ...
      node:
        # Configure the address of the proxy
        # It will be configured on all worker nodes. It results in the HTTP_PROXY & HTTPS_PROXY
        # environment variables being set.
        http_proxy: "http://172.20.0.2:3128"

        # Worker nodes require access to a Docker registry; in case it is only accessible using
        # plain HTTP or it uses a self-signed certificate, it must be listed here.
        insecure_registries:
          - "172.20.0.2:5000"

        # The kubelet requires the pause image; if it's only accessible using a private registry,
        # the image name must be configured here.
        pause_image: "172.20.0.2:5000/kubernetes/pause:3.1"

        # ContainerLinux requires the hyperkube image; if it's only accessible using a private
        # registry, the image name must be configured here.
        hyperkube_image: "172.20.0.2:5000/kubernetes/hyperkube-amd64"
```

Edit your Seed either using `kubectl edit` or editing a local file and applying it with `kubectl apply`. From then
on new nodes in the configured datacenter will use the new node settings.
