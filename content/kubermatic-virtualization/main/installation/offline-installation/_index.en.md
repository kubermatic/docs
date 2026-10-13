+++
title = "Offline Installation"
date = 2026-10-01T12:00:00+02:00
weight = 18
+++

This guide installs Kubermatic Virtualization in an air-gapped environment: a site whose machines have no access to
the internet. Everything the installation needs — container images, Helm charts and operating system packages — comes
as one offline bundle per release. The installer downloads the bundle on a machine with internet access; inside the air
gap, a jump host runs the bundle's two images as the site's package repository and registry. The installation then
runs from that mirror.

## Overview

| Step | Where | Command |
|---|---|---|
| 1. Download the bundle | A machine with internet access | `kubermatic-virtualization offline pull` |
| 2. Carry the folder into the site | — | Your usual transfer route (disk, file transfer) |
| 3. Check the folder | Jump host | `sha256sum` |
| 4. Start the mirror | Jump host | `docker load`, `docker run` |
| 5. Configure and install | Jump host | `kubermatic-virtualization apply` |

The bundle always matches the installer that downloads it: `offline pull` fetches the bundle of its own release, and
the folder carries the installer of that release for step 5.

## Requirements

| Machine | Requirements |
|---|---|
| Download machine | Linux, access to `quay.io`, the registry credentials of your Kubermatic Virtualization license, free disk of the bundle's size plus 10 % (about 30 GB for v1.3). Docker is not needed. |
| Jump host | Ubuntu 24.04 LTS (amd64) with root access, Docker Engine, `openssl`, `jq` and the `ca-certificates` package. An IPv4 address that the nodes reach; ports 80 and 5000 free. SSH access to the nodes. About 100 GB of free disk. |
| Nodes | Ubuntu 24.04 LTS (amd64) with `curl`, `gpg`, `sudo` and `systemd-resolved` installed — the standard Ubuntu 24.04 cloud image has all four. |
| Site | A DNS server the nodes can reach. It does not need to know any internet names. Node clocks set to the correct time. |

## Step 1 — Download the bundle

On the machine with internet access, run the installer of the release you want to install:

```bash
kubermatic-virtualization offline pull --output ./kubev-offline-v1.3.0
```

`offline pull` asks for the registry credentials of your license (or reads them from your Docker configuration, or
from `--username` and `--password-stdin`). It writes one folder: the two bundle images (the packages, and every
container image and Helm chart of the release), the release's commit marker, a checksum for every file, and the
installer itself. An interrupted download resumes when you run the same command again. A complete folder is
verified, not downloaded again.

At the end it prints two values. Keep them apart from the folder — for example in your change ticket:

```text
Carry these two values SEPARATELY from the folder (change ticket, e-mail):
  marker digest:    sha256:…
  installer sha256: …
```

## Step 2 — Carry the folder into the site

Copy the whole folder to the jump host with your usual transfer route.

## Step 3 — Check the folder

On the jump host, in the folder:

```bash
cd ./kubev-offline-v1.3.0
sha256sum --quiet -c SHA256SUMS && echo "all files intact"
jq -r .markerDigest COMPLETE
sha256sum bin/kubermatic-virtualization
```

Expect `all files intact`, then the `marker digest` and the `installer sha256` you carried separately. This confirms
that the copy is complete and that the installer you are about to run as root is the one Kubermatic published.

## Step 4 — Start the mirror

As root on the jump host, from the folder. Set the jump host's IP address that the nodes use:

```bash
IP=10.0.0.10
```

Load the two images:

```bash
tar -C images/a -c . | docker load
tar -C images/b -c . | docker load
```

Each prints `Loaded image: …`: the packages image (`…/kubev-offline-bundle-packages:<release>`) and the images image
(`…/kubev-offline-bundle-images:<release>`). The images image holds every container image and chart of the release
and takes about ten minutes to load. Note both names:

```bash
PACKAGES=quay.io/kubermatic/kubev-offline-bundle-packages:v1.3.0
IMAGES=quay.io/kubermatic/kubev-offline-bundle-images:v1.3.0
```

Make a certificate for the registry, valid for the jump host's address, and trust it on the jump host:

```bash
mkdir -p /etc/kubev-offline/tls
openssl req -x509 -newkey rsa:4096 -nodes -days 3650 -subj "/CN=$IP" -addext "subjectAltName=IP:$IP" \
  -keyout /etc/kubev-offline/tls/zot.key -out /etc/kubev-offline/tls/zot.crt
cp /etc/kubev-offline/tls/zot.crt /usr/local/share/ca-certificates/kubev-offline-registry.crt
update-ca-certificates
```

Start the package repository on port 80 and the registry on port 5000:

```bash
docker run -d --name kubev-offline-packages --restart unless-stopped -p 80:80 "$PACKAGES"
docker run -d --name kubev-offline-registry --restart unless-stopped -p 5000:5000 \
  -v /etc/kubev-offline/tls:/etc/zot/tls:ro "$IMAGES"
```

Check both:

```bash
curl -fsS "https://$IP:5000/v2/_catalog" | jq '.repositories | length'
curl -fsS "http://$IP/key.asc" | gpg --show-keys
jq -r .aptKeyFingerprint bundle.json
```

Expect the number of repositories the registry holds, then the repository's signing key, whose fingerprint (the line
under `pub`) is the one `jq` prints last: the repository is signed with the key the bundle names. Anyone on the site network can pull from and push to the registry.

## Step 5 — Configure and install

Write your cluster configuration (`kubev.yaml`) as for any installation — see
[Declarative Installation]({{< ref "../declarative-installation" >}}) — and add the offline settings for this jump host:

```yaml
offlineSettings:
  enabled: true
  containerRegistry:
    address: https://10.0.0.10:5000
    insecure: true
  helmRegistry:
    address: https://10.0.0.10:5000
    insecure: false
  packageRepository: http://10.0.0.10
  packageRepositoryKeyFingerprint: <the fingerprint jq printed in step 4>
networkConfiguration:
  dnsServerIP: 10.0.0.5
```

`packageRepositoryKeyFingerprint` ties the nodes to the bundle's package signing key. `dnsServerIP` is the site's
DNS server.

Then install from the jump host, in the directory that holds `kubev.yaml`, with the installer from the folder:

```bash
KUBEV_USERNAME=airgap KUBEV_PASSWORD=unused ./kubev-offline-v1.3.0/bin/kubermatic-virtualization apply -f kubev.yaml
```

Every image, chart and package now comes from the jump host. The two variables satisfy the installer's registry
credential prompt; the mirror does not need credentials.

## Virtual machine images

The bundle carries the platform. Add your own VM images to the jump host's registry from an OCI layout (a folder
holding one image, carried into the site like the bundle), with the [ORAS](https://oras.land/) client that comes in
the images image:

```bash
docker run --rm --network host -v /etc/kubev-offline/tls/zot.crt:/ca.crt:ro \
  -v "$PWD/ubuntu-layout:/layout:ro" --entrypoint oras "$IMAGES" \
  cp --from-oci-layout --to-ca-file /ca.crt /layout:24.04 "$IP:5000/containerdisks/ubuntu:24.04"
```

Reference them in your VMs and data volumes as `docker://10.0.0.10:5000/containerdisks/ubuntu:24.04`.

Images you add live in the registry container. Push them again when you replace that container.

## Operating the mirror

- Keep both containers running as long as the cluster uses them: new nodes, rescheduled pods and upgrades pull from
  them. They restart with Docker.
- **New address** — make and trust a new certificate for it (step 4), restart the registry container, and update the
  addresses in `kubev.yaml`.
- **Next release** — download its bundle with that release's installer, check it (step 3), load its two images,
  replace both containers with the new images, push your VM images again, set `packageRepositoryKeyFingerprint` to
  the new bundle's key, then run `apply` with that release's installer. During the upgrade the nodes switch to the new
  release's package signing key.
