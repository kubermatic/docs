+++
title = "Air-Gap Installation"
linkTitle = "Air-Gap Installation"
date = 2026-04-16T10:07:15+02:00
weight = 14
enterprise = true
+++

## Overview

Air-gap mode lets you install KubeLB Enterprise Edition in clusters that have no
network access to public container or chart registries. All container images and
Helm charts are mirrored to a private OCI registry inside your network, and the
KubeLB charts are configured to pull every image from that mirror.

What is supported:

- Registry rewrite for charts and images across the entire stack: manager, CCM, connection-manager,
  Envoy proxy data plane, and all addons, etc.
- A single `imagePullSecret` propagated to manager, CCM, connection-manager and
  all addon workloads, including manager-created Envoy proxy pods.
- A self-contained mirror bundle shipped inside the `kubelb-manager-ee` Helm
  chart at `airgapped/`. Everything you need to mirror is in there, including a script that uses `crane` to copy all images and charts to your mirror in one shot.

What is not supported:

- Mixing public and mirror registries. Air-gap mode is fail-closed; every image
  reference must resolve through the mirror.

{{% notice note %}}
This is an Enterprise Edition feature. The Community Edition charts do not
ship the `global.imageRegistry` plumbing.
{{% /notice %}}

## Prerequisites

- A private OCI registry where all the artifacts will be mirrored. It must be reachable from the air-gapped
  clusters and from a staging host with internet access (can be the same host).
- Credentials with push access to your mirror, pull access from inside the
  air-gapped clusters, and pull credentials for `quay.io/kubermatic/*` (the EE
  manager chart and EE images are private).
- On a staging host that can reach both the public registries and your mirror the following tools:
    1. helm 3.8+
    2. kubectl 1.28+
    3. [Crane](https://github.com/google/go-containerregistry/tree/main/cmd/crane)

## Step 1: Fetch the air-gap bundle

The `kubelb-manager-ee` Helm chart ships a self-contained mirror bundle under
`airgapped/`. Pull the chart from a host with internet access and extract it:

```bash
# Pick the version you want to install.
VERSION=v1.4.0

helm pull oci://quay.io/kubermatic/helm-charts/kubelb-manager-ee \
  --version ${VERSION} --untar
cd kubelb-manager-ee/airgapped
```

You will find:

| File | Contents |
|------|----------|
| `artifacts.txt` | Union of `images.txt` + `charts.txt` (oci:// stripped) — the default input for `mirror-images.sh`. This includes all the artifacts(images, charts) shipped or used by KubeLB |
| `images.txt` | Every container image (manager + CCM + all addons) |
| `images-core.txt` | Manager + CCM + connection-manager + Envoy data plane (no addons) |
| `images-<addon>.txt` | Per-addon images: `agentgateway`, `cert-manager`, `envoy-gateway`, `external-dns`, `ingress-nginx`, `metallb` |
| `charts.txt` | The three OCI Helm charts as `oci://` references |
| `mirror-images.sh` | Copies every artifact in `artifacts.txt` to a target registry using `crane` |

All image references are pinned with sha256 digests at release time, so a
subsequent retag of an upstream image cannot silently change what you mirror.

## Step 2: Mirror images and charts to your registry

Authenticate `crane` to both the source registries (Quay credentials are
required because EE images and the EE manager chart are private) and your
target mirror, then run the bundled script:

```bash
MIRROR=mirror.internal

crane auth login quay.io -u <quay-user> -p <quay-token>
crane auth login ${MIRROR} -u <mirror-user> -p <mirror-pass>

# Mirror everything: images + charts in one shot.
./mirror-images.sh ${MIRROR}
```

The script preserves the path after the registry host and skips artifacts
already present at the same digest, so re-runs are cheap. To mirror a subset,
pass a different list:

```bash
# Only the core (no addons).
./mirror-images.sh ${MIRROR} images-core.txt

# Only one addon.
./mirror-images.sh ${MIRROR} images-metallb.txt
```

The mirror layout looks like this:

| Source | Mirror destination |
|--------|--------------------|
| `quay.io/kubermatic/kubelb-manager-ee:v1.3.5` | `mirror.internal/kubermatic/kubelb-manager-ee:v1.3.5` |
| `quay.io/jetstack/cert-manager-controller:v1.20.2` | `mirror.internal/jetstack/cert-manager-controller:v1.20.2` |
| `registry.k8s.io/ingress-nginx/controller:v1.15.1` | `mirror.internal/ingress-nginx/controller:v1.15.1` |
| `oci://quay.io/kubermatic/helm-charts/kubelb-manager-ee:v1.3.5` | `oci://mirror.internal/kubermatic/helm-charts/kubelb-manager-ee:v1.3.5` |

If you would rather drive `crane` yourself or feed the lists to a different
tool (Harbor replication, Artifactory remote, [`hauler`](https://hauler.dev)),
the `*.txt` files are stable, deterministic inputs — there is nothing
`mirror-images.sh` specific about them.

## Step 3: Create the image pull secret

Create a `docker-registry` Secret named `mirror-creds` in the `kubelb`
namespace on the management cluster and on every tenant cluster:

```bash
kubectl create namespace kubelb --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret docker-registry mirror-creds \
  --namespace kubelb \
  --docker-server=mirror.internal \
  --docker-username=<user> \
  --docker-password=<password>
```

The same secret name is referenced by every chart in the next steps via
`global.imagePullSecrets`. Use whatever name fits your convention; just keep it
consistent across the install commands below.

## Step 4: Install the KubeLB Manager

Install the manager chart on the management cluster, pointing it at the mirror:

```bash
helm install kubelb-manager \
  oci://mirror.internal/kubermatic/helm-charts/kubelb-manager-ee \
  --version v1.3.5 \
  --namespace kubelb --create-namespace \
  --set global.imageRegistry=mirror.internal \
  --set global.imagePullSecrets[0].name=mirror-creds
```

`global.imageRegistry` rewrites every image referenced by the chart, including
the manager binary, `kube-rbac-proxy`, the connection-manager, the Envoy proxy
data plane and the Envoy Gateway shutdown manager. `global.imagePullSecrets` is
propagated to every pod spec the chart and the manager controllers create.

If you need to install CRDs separately (for example, to manage them with a
GitOps tool), pull and untar the chart first and apply `crds/` before
`helm install`:

```bash
helm pull oci://mirror.internal/kubermatic/helm-charts/kubelb-manager-ee \
  --version v1.3.5 --untar
kubectl apply -f kubelb-manager-ee/crds/
```

## Step 5: Install the KubeLB CCM

Run the CCM install on every tenant cluster. The `kubelb` namespace must
already contain the cluster Secret produced by tenant registration (see
[Setup Tenant Cluster]({{< relref "../../installation/tenant-cluster" >}})) and
the `mirror-creds` pull secret created in Step 3.

```bash
helm install kubelb-ccm \
  oci://mirror.internal/kubermatic/helm-charts/kubelb-ccm-ee \
  --version v1.3.5 \
  --namespace kubelb --create-namespace \
  --set global.imageRegistry=mirror.internal \
  --set global.imagePullSecrets[0].name=mirror-creds \
  --set kubelb.clusterSecretName=kubelb-cluster \
  --set kubelb.tenantName=<unique-identifier-for-tenant>
```

## Step 6: Install the KubeLB Addons

The `kubelb-addons` chart bundles upstream community charts (`ingress-nginx`,
`envoy-gateway`, `cert-manager`, `external-dns`, `metallb`, `agentgateway`). The
published OCI chart ships with air-gap patches already applied to each addon's
templates, so the same `global.imageRegistry` value flows through to every
addon image:

```bash
helm install kubelb-addons \
  oci://mirror.internal/kubermatic/helm-charts/kubelb-addons \
  --version v0.3.2 \
  --namespace kubelb \
  --set global.imageRegistry=mirror.internal \
  --set global.imagePullSecrets[0].name=mirror-creds \
  --set ingress-nginx.enabled=true \
  --set envoy-gateway.enabled=true \
  --set cert-manager.enabled=true \
  --set cert-manager.crds.enabled=true
```

Only enable the addons you actually use. Each addon condition is gated by
`<addon>.enabled` in `charts/kubelb-addons/values.yaml`.

## Step 7: Verify the install

Check that every running pod references your mirror and not a public registry:

```bash
kubectl get pods --all-namespaces \
  -o jsonpath='{range .items[*]}{range .spec.containers[*]}{.image}{"\n"}{end}{end}' \
  | sort -u
```

Every line in the output should start with `mirror.internal/`. If any line
starts with `quay.io/`, `docker.io/`, `registry.k8s.io/`, `gcr.io/`,
`ghcr.io/` or `cr.agentgateway.dev/`, that container will fail to pull once
the cluster is fully air-gapped. Fix the override before disconnecting.

You can perform the same check against rendered output before applying:

```bash
helm template kubelb-addons oci://mirror.internal/kubermatic/helm-charts/kubelb-addons \
  --version v0.3.2 \
  -f addons-airgap-values.yaml \
  | grep -E '^\s*image:' | sort -u
```

## Troubleshooting

### `ImagePullBackOff` with `unauthorized` on a tenant cluster

The `mirror-creds` pull secret is missing from a namespace where KubeLB schedules
workloads. The CCM install only puts it in `kubelb`. If you have set
`kubelb.namespace` or the manager creates Envoy proxy pods in a different
namespace, copy the secret there too, or re-run Step 3 with the additional
namespace.

### An addon image still references a public registry

Re-render with `helm template ... --set global.imageRegistry=mirror.internal | grep image:`
to find the offender. If a specific image is not getting rewritten, file an
issue against `kubermatic/kubelb-ee` — the air-gap patch for that addon
chart needs an update.

### Manager-created Envoy proxy pods pull from `docker.io`

The Envoy data plane and the Envoy Gateway shutdown manager are exposed on the
manager chart as `kubelb.envoyProxy.image` and
`kubelb.envoyProxy.gracefulShutdown.shutdownManagerImage`. They are rewritten
automatically when `global.imageRegistry` is set on the manager chart. If you
have overridden either value explicitly, make sure your override already points
at the mirror — explicit values bypass the global rewrite.
