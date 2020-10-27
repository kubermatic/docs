+++
title = "Offline Mode"
date = 2018-04-28T12:07:15+02:00
weight = 7

+++

It's possible to run KKP in an airgapped/offline environment, by mirroring all required
Docker images to a local Docker registry. The `image-loader` utility is provided to aid
in this process.

In general, to setup an airgapped system, the Docker images must be mirrored and the
Helm charts / KubermaticConfiguration need to be adjusted to point to the new registry.

### Download All Required Images

There are a number of sources for the Docker images used in a KKP setup:

* The Docker images used by KKP itself (e.g. `quay.io/kubermatic/kubermatic`)
* The images used by the various Helm charts used to deploy KKP (nginx, cert-manager,
  Grafana, ...)
* The images used for creating a usercluster control plane (the Kubernetes apiserver,
  scheduler, metrics-server, ...).
* The images referenced by cluster addons.

To make it easier to collect all required images, the `image-loader` utility is provided.
It will scan the Helm charts and uses the KKP code itself to determine all images that
need to be mirrored. Once it has determined these, it will pull, re-tag and then push
the images.

To use it, provide it with the `values.yaml` file used to install the Helm charts.

The image-loader is included in the regular KKP Docker images (i.e.
`quay.io/kubermatic/api`). It is recommended to extract the binary out of the
Docker image and use it locally, as a Helm 3 binary is also required to use it.

```bash
CONTAINER_ID=$(docker create --name copier quay.io/kubermatic/api:v2.13.10)
docker cp $CONTAINER_ID:/usr/local/bin/image-loader .
docker rm $CONTAINER_ID
```

It is important to use the image-loader that ships with the KKP version you're using,
as this will ensure that it finds the same images actually used in the clusters later on.

As the next step, download the Helm charts for your KKP version from the
[kubermatic-installer](https://github.com/kubermatic/kubermatic-installer/) repository.
Once you have the charts and the image-loader, you can run the loader like so:

```bash
./image-loader \
  -helm-values-file myhelmvalues.yaml \
  -charts-path /path/to/the/extracte/charts \
  -registry 172.20.0.2:5000 \
  -dry-run
```

Remove the `-dry-run` to let the tool actually download and push Docker images.

#### Addons

Note that by default, the image-loader will determine the configured addons Docker image
from the Helm values, pull it down and then extract the addon manifests from the image,
so that it can then scan them for Docker images to mirror.

You can skip this step by pointing the image-loader to a local directory that contains
all addons, like so:

```bash
./image-loader \
  -helm-values-file myhelmvalues.yaml \
  -charts-path /path/to/the/extracte/charts \
  -addons-path /path/to/my/addons \
  -registry 172.20.0.2:5000 \
  -dry-run
```

### Configuring KKP

After having mirrored all required Docker images, it's time to adjust the KKP configuration
to point to the new images. For this the Helm values.yaml allows to override the
Docker repository for all used images. This is true for the `kubermatic` chart as well as
all other Helm charts.

For example, Dex can be installed by overwriting `dex.image.repository` either in the
`values.yaml` file or on the command line:

```bash
helm -n oauth upgrade \
  --values myvalues.yaml \
  --set "dex.image.repository=172.20.0.2:5000/dexidp/dex" \
  oauth .
```

{{% notice note %}}
When adjusting the `values.yaml`, do not use the same file for the image-loader, as it would
attempt to mirror `172.20.0.2:5000/dexidp/dex` to `172.20.0.2:5000/dexidp/dex` (a no-op).
Either provide the image-loader with a stock configuration or set the overridden image repositories
via `--set` when using Helm.
{{% /notice %}}

Once the `values.yaml` has been updated, re-deploy all affected Helm charts.

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
