+++
title = "Offline Mode"
date = 2018-04-28T12:07:15+02:00
weight = 180

+++

It's possible to run KKP in an airgapped/offline environment by mirroring all required images to a local container
image registry. The `kubermatic-installer mirror-images` command is provided to aid in this process.

In general, to setup an airgapped system, the container images must be mirrored and the
Helm charts / KubermaticConfiguration need to be adjusted to point to the new registry.

## Mirroring Required Images

{{% notice info %}}
The functionality described in this section was provided by a tool called `image-loader` in previous KKP releases.
That tool does not exist as a standalone tool anymore and has been rolled into the Kubermatic Installer.
Previously, this functionality depended on a `docker` (or compatible) CLI to execute the actual mirroring
work. This is no longer the case and as such, `kubermatic-installer mirror-images` can be used on systems
without Docker.
{{% /notice %}}

There are a number of sources for container images used in a KKP setup:

* The container images used by KKP itself (e.g. `quay.io/kubermatic/kubermatic`)
* The images used by the various Helm charts used to deploy KKP (nginx, cert-manager,
  Grafana, ...)
* The images used for creating a user cluster control plane (the Kubernetes apiserver,
  scheduler, metrics-server, ...).
* The images referenced by cluster [Addons]({{< ref "../../architecture/concept/kkp-concepts/addons/" >}}).
* The images referenced in system [Applications]({{< ref "../../tutorials-howtos/applications/" >}}).

To make it easier to collect all required images, the `kubermatic-installer mirror-images` utility is provided.
It will scan KKP source code and Helm charts included in a KKP release to determine all images that need to be mirrored.
Once it has determined these, it will pull, re-tag and then push the images.

To use it, provide it with the `KubermaticConfiguration` as a YAML file and the `values.yaml` file used to install the Helm charts.

Download the latest KKP release, you will need both the `kubermatic-installer` binary and the `charts` directory. Extract the KKP release locally and then run the `kubermatic-installer`.
Note that you need [Helm 3.x](https://helm.sh/) installed on your machine.

```bash
./kubermatic-installer mirror-images localhost:5000 \
  --charts-directory /path/to/the/extracted/charts \
  --config mykubermatic.yaml \
  --helm-values myhelmvalues.yaml \
  --dry-run
```

{{% notice info %}}
Be aware that `kubermatic-installer mirror-images` will ignore repository overrides in the referenced `KubermaticConfiguration` and as such, a configuraiton file
used to deploy an offline setup with respective overrides can be reused. **However, no such logic is available for Helm charts**. To ensure that the correct
images are extracted from Helm charts, it is highly recommended to maintain a secondary Helm values file that does not include any image repository overrides.
{{% /notice %}}

Remove `--dry-run` to let the tool actually mirror container images. Output for the command will look like this:

```bash
INFO[0002] 🚀 Collecting images…
INFO[0068] 🚀 Rendering Helm charts…                      charts-directory=charts
INFO[0087] 🚀 Rendering system Applications Helm charts…
INFO[0087] Retrieving images…                            application-name=cilium
INFO[0088] Image found                                   source-image="anx-cr.io/anexia/anx-cloud-controller-manager:1.5.1" target-image="localhost:5000/anexia/anx-cloud-controller-manager:1.5.1"
INFO[0088] Image found                                   source-image="docker.io/bats/bats:v1.4.1" target-image="localhost:5000/bats/bats:v1.4.1"
INFO[0088] Image found                                   source-image="docker.io/bitnami/memcached-exporter:0.10.0-debian-11-r51" target-image="localhost:5000/bitnami/memcached-exporter:0.10.0-debian-11-r51"
INFO[0088] Image found                                   source-image="docker.io/bitnami/memcached:1.6.17-debian-11-r25" target-image="localhost:5000/bitnami/memcached:1.6.17-debian-11-r25"
INFO[0088] Image found                                   source-image="docker.io/calico/cni:v3.19.1" target-image="localhost:5000/calico/cni:v3.19.1"
[...]
INFO[0087] ✅ Finished listing images.                    all-image-count=215 copied-image-count=0
```

Output will include information about the source of an image and the destination that the command will attempt to copy it to when run without `--dry-run`. If you seek to have machine-readable output (e.g. to process images with your own), pass `-o json` for JSON output.

### Authentication

To authenticate while pulling and pushing images (e.g. to work around unauthenticated pull limitations on DockerHub and to push to registries
that require authentication), `kubermatic-installer mirror-images` will attempt to discover credentials also used by `docker` and `podman`.
That means it will look for `~/.docker/config.json` (`%USERPROFILE%\.docker\config.json` on Windows) and `${XDG_RUNTIME_DIR}/containers/auth.json`
and look for credentials for the involved registries (both source and target).

This behaviour can be overridden by setting the `DOCKER_CONFIG` environment variable. Note that this needs to reference a directory
containing a `config.json` file, not reference the file itself.

### Partial Mirroring

In some cases (e.g. when registry mirrors are configured only for a subset of upstream registries), you might want to only mirror
some images instead of all of them. For that, a flag called `--registry-prefix` has been added. It can be used to pass a prefix
against which all images will be filtered.

For example, to only mirror images from [DockerHub](https://hub.docker.com/),
pass `--registry-prefix 'docker.io'` to `kubermatic-installer mirror-images`.

### Addons


Note that by default, `kubermatic-installer mirror-images` will determine the addons container image
based on the `KubermaticConfiguration` file, pull it down and then extract the addon manifests from
the image, so that it can then scan them for container images to mirror.

You can skip this step by pointing the command to a local directory that contains all addons with the `--adons-path` flag:

```bash
./kubermatic-installer mirror-images 172.20.0.2:5000 \
  --charts-directory /path/to/the/extracted/charts \
  --config mykubermatic.yaml \
  --helm-values myhelmvalues.yaml \
  --addons-path /path/to/my/addons \
  --dry-run
```

If a [custom addons image]({{< ref "../../architecture/concept/kkp-concepts/addons/#custom-addons" >}}) is used,
you should pass the `--addons-image` flag instead to reference a non-standard addon image to extract images from.

## Configuring KKP

After having mirrored all required container images, it's time to adjust the KKP configuration
to point to the new images. For this the KubermaticConfiguration allows to override the
image repository (but not the tag!) for all used images. Likewise, all Helm charts have
options to reconfigure the repository as well.

For example, Dex can be installed by overwriting `dex.image.repository` either in the
`values.yaml` file or on the command line:

```bash
helm -n oauth upgrade \
  --values myvalues.yaml \
  --set "dex.image.repository=172.20.0.2:5000/dexidp/dex" \
  oauth .
```

{{% notice note %}}
When adjusting the `values.yaml`, do not use the same file for `kubermatic-installer mirror-images`, as it would
attempt to mirror `172.20.0.2:5000/dexidp/dex` to `172.20.0.2:5000/dexidp/dex` (a no-op).
Either provide `kubermatic-installer mirror-images` with a stock configuration or set the overridden image repositories
via `--set` when using Helm.
{{% /notice %}}

Likewise, carefully go through the [KubermaticConfiguration]({{< ref "../../tutorials-howtos/kkp-configuration" >}})
and adjust the `dockerRepository` fields:

```yaml
spec:
  masterController:
    dockerRepository: 172.20.0.2:5000/kubermatic/kubermatic
  seedController:
    dockerRepository: 172.20.0.2:5000/kubermatic/kubermatic
  ui:
    dockerRepository: 172.20.0.2:5000/kubermatic/dashboard
  # etc.
```

Re-apply the updated configuration to make the KKP Operator reconcile the setup:

```bash
kubectl apply -f mykubermatic.yaml
```

### Worker Nodes Behind a Proxy

In situations where worker nodes will require a proxy to reach the internet, the datacenter specification for the
Seed cluster must be updated. 
Find the relevant seed via `kubectl`:

```bash
kubectl -n kubermatic get seeds
```

Output will be similar to this:
```bash
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
