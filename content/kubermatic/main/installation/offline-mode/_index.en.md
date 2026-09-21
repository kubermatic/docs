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

- The container images used by KKP itself (e.g. `quay.io/kubermatic/kubermatic`)
- The images used by the various Helm charts used to deploy KKP (Envoy Gateway, cert-manager,
  Grafana, ...)
- The images used for creating a user cluster control plane (the Kubernetes apiserver,
  scheduler, metrics-server, ...).
- The images referenced by cluster [Addons]({{< ref "../../architecture/concept/kkp-concepts/addons/" >}}).
- The images referenced in system [Applications]({{< ref "../../tutorials-howtos/applications/" >}}).

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
Be aware that `kubermatic-installer mirror-images` will ignore repository overrides in the referenced `KubermaticConfiguration` and as such, a configuration file
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

### Mirroring Images with KubermaticConfiguration

The `mirrorImages` field in the `KubermaticConfiguration` allows you to specify additional container images to mirror during the `kubermatic-installer mirror-images` command, simplifying air-gapped setups.

Example:

```yaml
apiVersion: kubermatic.k8c.io/v1
kind: KubermaticConfiguration
metadata:
  name: kubermatic
spec:
  mirrorImages:
    - quay.io/kubermatic/kubelb-manager-ee:v1.1.0
```

## Listing Required Images

The `kubermatic-installer list-images` command prints every container image that `kubermatic-installer mirror-images` collects, without copying, re-tagging or pushing any image. It needs no target registry and no registry credentials. Use it to feed the image list into a registry pipeline, an image scanner or a software bill of materials.

It accepts the same flags as `kubermatic-installer mirror-images`, except for the registry argument. The `--dry-run`, `--load-from` and `--insecure` flags are omitted because they only affect the mirroring itself. Every remaining flag behaves the same way. For example, `--registry-prefix` filters the images collected from KKP versions, Helm charts and Applications; images from `spec.mirrorImages` and the static `web-terminal` image are always listed. The `--addons-path` and `--addons-image` flags behave as described in the Addons section above. The command ignores repository overrides in the referenced `KubermaticConfiguration`, so an offline configuration with overrides can be reused. The `CONFIG_YAML` and `HELM_VALUES` environment variables serve as fallbacks for `--config` and `--helm-values`.

Listing images requires:

- a `helm` binary, found on the `PATH` or set with `--helm-binary`
- a charts directory, passed with `--charts-directory`, the same flag the other installer subcommands use
- a `KubermaticConfiguration`, passed with `--config` or via the `CONFIG_YAML` environment variable
- an addons source: by default the command pulls the addons container image for the running KKP version from its registry; pass `--addons-path` with a local addons checkout to skip that pull

The command needs network access for the addons image pull and for the system Applications Helm chart downloads. The KKP Helm chart rendering from `--charts-directory` runs locally.

Run it with the same inputs as `kubermatic-installer mirror-images`:

```bash
./kubermatic-installer list-images \
  --charts-directory /path/to/the/extracted/charts \
  --config mykubermatic.yaml \
  --helm-values myhelmvalues.yaml
```

The command writes the sorted, deduplicated image references to stdout, one per line. Progress messages and errors go to stderr. Redirect stdout to a file to capture a plain image list:

```bash
./kubermatic-installer list-images \
  --charts-directory /path/to/the/extracted/charts \
  --config mykubermatic.yaml \
  --helm-values myhelmvalues.yaml \
  > images.txt
```

The resulting file holds only image references:

```bash
docker.io/bats/bats:v1.4.1
docker.io/bitnami/memcached-exporter:0.10.0-debian-11-r51
docker.io/bitnami/memcached:1.6.17-debian-11-r25
docker.io/calico/cni:v3.19.1
[...]
```

{{% notice info %}}
`kubermatic-installer list-images` still renders the Helm charts with the configured Helm binary. It also still pulls the addons image to scan the addon manifests inside it for container images, unless `--addons-path` points to a local addons directory.
{{% /notice %}}

### Output Modes

All output modes are opt-in. With none of them set, the command keeps printing the sorted, deduplicated, one-image-per-line list, so scripts that redirect stdout are unaffected.

`--show-source` appends a second, tab-separated column with the origin of each image. The origin labels are:

- `application-definition/<chart-name>`: the system application catalog chart the image comes from
- `addon/<addon-name>`: the addon manifest the image comes from
- `installer-chart`: the installer Helm charts rendered from `--charts-directory`
- `reconciler@<version>`: the user cluster machinery for that KKP version; etcd-backup entries print under this label too
- `mirror-images`: an entry from `spec.mirrorImages`
- `static`: a hardcoded entry such as the web-terminal image

An image with several origins carries them comma-joined on one line:

```bash
quay.io/kubermatic/kubermatic:v2.31.0	reconciler@v2.31,mirror-images
registry.k8s.io/pause:3.10	installer-chart,static
```

`--charts` prints only the Helm charts collected from the system Applications, one per line, instead of the images. Each line is the chart's registry, name and chart version:

```bash
quay.io/kubermatic-mirror/helm-charts/cilium:1.13.3
```

`-o json` replaces the plain list with a JSON Lines stream. Every line is one record, a chart or an image:

```json
{"kind":"chart","name":"cilium","chartVersion":"1.13.3","origin":"application-definition","source":"oci://quay.io/kubermatic-mirror/helm-charts"}
{"kind":"image","image":"quay.io/kubermatic/http-prober:v0.5.1","origins":[{"origin":"reconciler","version":"v2.31"},{"origin":"mirror-images"}]}
```

Chart records come first, then the image records. On `kubermatic-installer list-images`, `-o` is a local flag that sets the output format and shadows the root log-format flag of the same name; the root log-format flag keeps its meaning on every other subcommand. Only `json` is supported; `yaml` fails with `invalid output format "yaml", supported formats: json`. `--charts` combined with `-o json` prints only the chart records.

### Differences from mirror-images --dry-run

Before `kubermatic-installer list-images` existed, `kubermatic-installer mirror-images --dry-run` was the workaround for listing images. The two commands differ in three ways:

- `mirror-images --dry-run` still requires a positional argument, the target registry or a `local://` archive path, even though it pushes nothing. `kubermatic-installer list-images` requires no registry argument at all.
- `kubermatic-installer list-images` has no `--dry-run` flag; listing is always effectively a dry run.
- `mirror-images --dry-run -o json` logs the images as JSON log lines on stderr, so capturing the list needs `2>&1` and jq. `kubermatic-installer list-images` prints the images themselves on stdout, one per line.

Both commands run the same image collection, including the Helm chart rendering and the addons image pull described above.

## Mirroring Binaries 

The `kubermatic-installer mirror-binaries` command is designed to **mirror and host essential binaries** required by the Operating System Profiles for provisioning user clusters in **offline/airgapped environments**. This includes critical components like:

- **Kubernetes binaries**: `kubeadm`, `kubelet`, `kubectl`  
- **CNI plugins** (e.g., bridge, ipvlan, loopback, macvlan, etc)  
- **CRI tools** (e.g., `crictl`)  
- Tar packages and checksums for integrity verification  

{{% notice info %}}
The default output directory (`/usr/share/nginx/html/`) requires root permissions. To avoid running the command as root, specify a custom directory using the `--output-dir` flag. For offline scenarios, it is recommended to run this command on a dedicated system, as such environments often rely on a central server to host container images and binaries, as it mirrors the files directly to the filesystem. Alternatively, you can bundle the mirrored files into a container for easier distribution.
{{% /notice %}}

### Key Features

#### Mirrors Original Domain Structure

  Binaries are stored in the **exact directory hierarchy** as their original domains (e.g., `containernetworking/plugins/releases/v1.5.1/...`). This allows **DNS-based redirection** of domains like `github.com` or `k8s.gcr.io` to your local/offline server, ensuring the OSP fetches binaries from the mirrored paths **without URL reconfiguration** or **Operating System Profile** changes.  

### Example Workflow

```bash
./kubermatic-installer mirror-binaries \
  --config config.yaml \
  --architectures=amd64 \ # allows you to specify a comma-separated list of CPU architectures
  --output-dir /var/www/html  # Local directory to host mirrored binaries

INFO[0000] 🚀 Starting mirroring for architecture: amd64 
INFO[0007] ✅ CNI plugins download complete for amd64.   
INFO[0011] ✅ CRI tools download complete for all available Kubernetes versions (amd64). 
INFO[0033] ✅ Kube binaries download complete for all available Kubernetes versions (amd64). 
INFO[0033] ✅ Finished loading images.      
```

### Example of the Directory Structure

```bash
.
├── containernetworking          # CNI plugins (Container Network Interface)
│   └── plugins
│       └── releases
│           └── download
│               └── v1.5.1       # CNI plugins version
│                   ├── cni-plugins-linux-amd64-v1.5.1.tgz      # Binary tarball
│                   └── cni-plugins-linux-amd64-v1.5.1.tgz.sha256  # Checksum
│
├── kubernetes-sigs              # CRI tools (Container Runtime Interface)
│   └── cri-tools
│       └── releases
│           └── download
│               └── v1.29.0      # CRI tools version
│                   ├── crictl-v1.29.0-linux-amd64.tar.gz       # Binary tarball
│                   └── crictl-v1.29.0-linux-amd64.tar.gz.sha256  # Checksum
│
└── release                      # Kubernetes core components
    └── v1.29.0                  # Kubernetes version
        └── bin
            └── linux
                └── amd64
                    ├── kubeadm          # Kubernetes cluster bootstrapping tool
                    ├── kubeadm.sha256   # Checksum
                    ├── kubectl          # Kubernetes CLI
                    ├── kubectl.sha256
                    ├── kubelet          # Kubernetes node agent
                    └── kubelet.sha256
```

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
and adjust the `dockerRepository` fields and the Helm-related registry settings shown below:

```yaml
spec:
  masterController:
    dockerRepository: 172.20.0.2:5000/kubermatic/kubermatic
  seedController:
    dockerRepository: 172.20.0.2:5000/kubermatic/kubermatic
  ui:
    dockerRepository: 172.20.0.2:5000/kubermatic/dashboard
  # etc.
  # Overwrite the OCI Helm repository that should be used to install applications
  applications:
    defaultApplicationCatalog:
      helmRepository: oci://172.20.0.2:5000/kubermatic/charts
      helmRegistryConfigFile: # optional
        # refers to a k8s Secret within the KKP installation Namespace, annotated with apps.kubermatic.k8c.io/secret-type: helm
        name: helmregistry-secret
        key: .dockerconfigjson
  userCluster:
    applications:
      insecureSkipTLSVerify: false # applies to spec.applications.defaultApplicationCatalog.helmRepository
      plainHTTP: false             # applies to spec.applications.defaultApplicationCatalog.helmRepository
    systemApplications:
      helmRepository: oci://172.20.0.2:5000/kubermatic/charts
      insecureSkipTLSVerify: false
      plainHTTP: false
      helmRegistryConfigFile: # optional
        # refers to a k8s Secret within the KKP installation Namespace, annotated with apps.kubermatic.k8c.io/secret-type: helm
        name: helmregistry-secret
        key: .dockerconfigjson
```

Re-apply the updated configuration to make the KKP Operator reconcile the setup:

```bash
kubectl apply -f mykubermatic.yaml
```

An alternative to overwriting the application Helm repository within the KubermaticConfiguration is to configure the Helm repository within a separate ApplicationCatalog resource.
For more information, see the [Application Catalog Manager Guide]({{< ref "../../tutorials-howtos/applications/application-catalog-manager" >}}).

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
