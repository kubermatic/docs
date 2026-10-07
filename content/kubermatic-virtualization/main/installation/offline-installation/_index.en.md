+++
title = "Offline Installation"
date = 2026-10-01T12:00:00+02:00
weight = 18
+++

This guide installs Kubermatic Virtualization in an air-gapped environment: a site whose machines have no access to
the internet. Everything the installation needs — container images, Helm charts and operating system packages — comes
as one offline bundle per release. The installer downloads the bundle on a machine with internet access, and turns it
into a verified mirror on a jump host inside the air gap. The installation then runs from that mirror.

## Overview

| Step | Where | Command |
|---|---|---|
| 1. Download the bundle | A machine with internet access | `kubermatic-virtualization offline pull` |
| 2. Carry the folder into the site | — | Your usual transfer route (disk, file transfer) |
| 3. Check the installer | Jump host | `sha256sum` |
| 4. Serve the mirror, check the nodes, write the configuration | Jump host | `kubermatic-virtualization offline serve` |
| 5. Install | Jump host | `kubermatic-virtualization apply` |

The bundle always matches the installer that downloads it: `offline pull` fetches the bundle of its own release, and
the folder carries the installer of that release for steps 3 to 5.

## Requirements

| Machine | Requirements |
|---|---|
| Download machine | Linux, access to `quay.io`, the registry credentials of your Kubermatic Virtualization license, free disk of the bundle's size plus 10 % (about 22 GB for v1.3). Docker is not needed. |
| Jump host | Ubuntu 24.04 LTS (amd64) with root access. Docker Engine using the containerd image store, as Ubuntu 24.04's `docker.io` package does. The `ca-certificates` package. An IPv4 address that the nodes reach; ports 80 and 5000 free. SSH access to the nodes. About 60 GB of free disk. |
| Nodes | Ubuntu 24.04 LTS (amd64) with `curl`, `gpg`, `sudo` and `systemd-resolved` installed — the standard Ubuntu 24.04 cloud image has all four. |
| Site | A DNS server the nodes can reach. It does not need to know any internet names. Node clocks set to the correct time. |

## Step 1 — Download the bundle

On the machine with internet access, run the installer of the release you want to install:

```bash
kubermatic-virtualization offline pull --output ./kubev-offline-v1.3.0
```

`offline pull` asks for the registry credentials of your license (or reads them from your Docker configuration, or
from `--username` and `--password-stdin`). It writes one folder: the three bundle images, the release's commit marker,
a checksum for every file, and the installer itself. An interrupted download resumes when you run the same command
again. A complete folder is verified, not downloaded again.

At the end it prints two values and the commands to run on the jump host. Keep the two values apart from the folder
— for example in your change ticket:

```text
Carry these two values SEPARATELY from the folder (change ticket, e-mail):
  marker digest:    sha256:…
  installer sha256: …

On the air-gapped jump host, before running anything from the folder:
  sha256sum ./kubev-offline-v1.3.0/bin/kubermatic-virtualization      # must print the installer sha256 above
Then, as root, with the marker digest you carried:
  ./kubev-offline-v1.3.0/bin/kubermatic-virtualization offline serve --from ./kubev-offline-v1.3.0 --marker-digest sha256:… --address <jump-host-ip> --config kubev.yaml
  (add --dns <site-dns-ip> when kubev.yaml names no networkConfiguration.dnsServerIP)
```

## Step 2 — Carry the folder into the site

Copy the whole folder to the jump host with your usual transfer route. `offline serve` re-checks every byte of it in
step 4, so a damaged copy is refused before anything changes on the jump host.

## Step 3 — Check the installer

On the jump host, before you run anything from the folder:

```bash
sha256sum ./kubev-offline-v1.3.0/bin/kubermatic-virtualization
```

The value must equal the `installer sha256` you carried separately. This confirms that the installer you are about to
run as root is the one Kubermatic published.

## Step 4 — Serve the mirror

Write your cluster configuration (`kubev.yaml`) as for any installation — see
[Declarative Installation]({{< ref "../declarative-installation" >}}) — with the site's DNS server in
`networkConfiguration.dnsServerIP`. You do not need to fill in `offlineSettings`: `offline serve` writes them.

Then, as root, with the installer from the folder:

```bash
sudo ./kubev-offline-v1.3.0/bin/kubermatic-virtualization offline serve \
  --from ./kubev-offline-v1.3.0 \
  --marker-digest sha256:… \
  --address 10.0.0.10 \
  --config kubev.yaml
```

`--marker-digest` is the marker digest you carried separately: `offline serve` checks the folder against it before it
uses anything from the folder. `--address` is the jump host's IP address that the nodes use. Add `--dns <ip>` when
`kubev.yaml` does not name a DNS server yet.

What `offline serve` does, in order:

1. **Checks the folder** — every file against its checksum, the images against the release's commit marker, the
   release against the installer's own version. Then it checks the jump host and its configuration, and logs in to
   every node over SSH (with the users and keys in `kubev.yaml`) to check the operating system, the required tools,
   and that the node gets an answer from the DNS server. Nothing on the jump host or the nodes changes in this step.
2. **Starts the mirror** — loads the images into Docker and starts two containers: the package repository on port 80
   and the container and Helm registry on port 5000, with a certificate from a certificate authority it creates for
   this host. It loads the licensed content into the registry and adds the certificate authority to the jump host's
   trust store.
3. **Verifies the mirror through the network** — fetches every image and chart back from the registry and checks
   every byte, and installs the nodes' packages from the repository in a test container, trusting only the signing
   key the bundle names.
4. **Checks the nodes against the mirror** — each node must reach the registry and the repository, get the same
   signing key, and resolve every package the installation needs. The nodes' own package configuration is not
   changed.
5. **Writes the offline settings into `kubev.yaml`** and prints the command for step 5.

A successful run ends with:

```text
READY TO INSTALL: release v1.3.0, marker sha256:…
  registry  https://10.0.0.10:5000   83 artifacts, … every byte fetched back and hashed
  packages  http://10.0.0.10   signed by key …; the installer's apt calls get 175 packages
  trust     this host trusts the registry's certificate (…)
  pushes    anyone may pull; pushing needs the login kept root-only in /var/lib/kubermatic-virtualization/offline/push/config.json
  nodes     3 nodes reach the mirror and can install from it (…)
  config    kubev.yaml written (the previous file is kubev.yaml.bak-…)

Next, with the installer from the folder:
  KUBEV_USERNAME=airgap KUBEV_PASSWORD=unused ./kubev-offline-v1.3.0/bin/kubermatic-virtualization apply -f kubev.yaml
```

The settings it writes:

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
  packageRepositoryKeyFingerprint: <fingerprint of the bundle's package signing key>
networkConfiguration:
  dnsServerIP: 10.0.0.5
```

The key fingerprint ties the nodes to the bundle's package signing key; `offline serve` updates it whenever it
serves a new bundle. Only these keys change. Every other line of `kubev.yaml` — order, comments, formatting — stays as you wrote it, the
file keeps its owner and permissions, and the previous version is kept next to it as `kubev.yaml.bak-<time>`. If
`kubev.yaml` already points these keys at another registry, repository or DNS server, `offline serve` stops and shows
the difference; add `--overwrite-config` to replace them.

### Results

| Result | Meaning | What to do |
|---|---|---|
| `READY TO INSTALL` | The mirror is verified, every node can install from it, and `kubev.yaml` holds the offline settings. | Run the printed command (step 5). |
| `NOT READY: nodes cannot use the mirror` | The mirror is verified and keeps running, but at least one node failed a check; the output names the node and the check. `kubev.yaml` is not written. | Fix the cause on the site side (firewall, routing, DNS, clock), then run the same command again. |
| `MIRROR VERIFIED` | The run had no `--config`: the mirror is verified, the nodes were not checked. The settings to paste are printed. | Add the printed settings to `kubev.yaml`, or run again with `--config`. |

If a check fails before the mirror is started — a damaged folder, a node without `curl`, a port in use — the run
stops with the reason and nothing on the jump host has changed.

## Step 5 — Install

Run the command `offline serve` printed, from the jump host:

```bash
KUBEV_USERNAME=airgap KUBEV_PASSWORD=unused ./kubev-offline-v1.3.0/bin/kubermatic-virtualization apply -f kubev.yaml
```

Every image, chart and package now comes from the jump host. The two variables satisfy the installer's registry
credential prompt; the mirror does not need credentials.

## Virtual machine images

The bundle carries the platform. Add your own VM images to the jump host's registry from an OCI layout (a folder
holding one image, carried into the site like the bundle). Every `offline serve` run ends with the command for this
host: it runs the [ORAS](https://oras.land/) client that comes with the bundle, with the mirror's certificate authority
and the push login `offline serve` keeps for root. Anyone on the site network can pull from the registry; pushes need
that login.

```bash
sudo docker run --rm --network host \
  -v /var/lib/kubermatic-virtualization/offline/pub:/ca:ro \
  -v /var/lib/kubermatic-virtualization/offline/push/config.json:/push/config.json:ro -e DOCKER_CONFIG=/push \
  -v "$PWD/ubuntu-layout:/layout:ro" --entrypoint oras sha256:<as printed> \
  cp --from-oci-layout --to-ca-file /ca/ca.crt /layout:24.04 10.0.0.10:5000/containerdisks/ubuntu:24.04
```

Reference them in your VMs and data volumes as `docker://10.0.0.10:5000/containerdisks/ubuntu:24.04`.

Images you add live in the registry container. Push them again after `offline serve --stop` and after serving a new
release, before you run `apply`.

## Operating the mirror

- **Re-run** `offline serve` at any time with the same command. It checks everything again and changes only what
  differs: running containers stay, the registry content stays, and `kubev.yaml` is written only when a setting
  changed.
- **New address** — run `offline serve` with the new `--address`. The registry certificate is renewed for it, the
  content stays, and `kubev.yaml` is updated.
- **Status** — `offline serve --status` shows the release served, the last result, the certificate's expiry and the
  configurations that point at the mirror. It changes nothing.
- **Stop** — `offline serve --stop` removes the two containers and the trust-store entry; the loaded images stay for a
  later run. `--stop --purge` also removes the images `offline serve` loaded and what it created on the jump host:
  the certificate authority, the registry certificate and the push login. Keep the mirror running as long as the
  cluster uses it: new nodes, rescheduled pods and upgrades pull from it.
- **Next release** — download its bundle with that release's installer and serve it with that installer, push your
  VM images again, then run the `apply` command it prints. During the upgrade the nodes switch to the new release's
  package signing key.
