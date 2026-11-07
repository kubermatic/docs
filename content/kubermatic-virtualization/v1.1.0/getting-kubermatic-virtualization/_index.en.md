+++
title = "Getting Kubermatic Virtualization"
date = 2026-02-24T12:00:00+02:00
weight = 1
+++

## Overview

Kubermatic Virtualization can be obtained using the **Kubermatic EE Downloader**, a dedicated CLI tool that authenticates against Kubermatic's OCI registry and installs the binary for you.

## Using the Kubermatic Virtualization Downloader

The recommended way to get Kubermatic Virtualization is through the `kubermatic-ee-downloader` CLI tool. It handles authentication, artifact retrieval, and local installation in a single command.

### Getting the Downloader

The fastest way to install `kubermatic-ee-downloader` is to use the installation script:

```bash
curl -sfL https://raw.githubusercontent.com/kubermatic/kubermatic-ee-downloader/main/install.sh | sh
```

The script will download and install the `kubermatic-ee-downloader` binary automatically — no additional setup is required.

### Credentials

The downloader requires a username and password to authenticate against Kubermatic's OCI registry. To obtain your credentials, please contact [sales@kubermatic.com](mailto:sales@kubermatic.com)

It is recommended to store your credentials as environment variables:

```bash
export KUBEV_USERNAME=<your-username>
export KUBEV_PASSWORD=<your-password>
```

### Running the Downloader

You can check which tools and versions the downloader provides:

```bash
./kubermatic-ee-downloader list
TOOL                        VERSIONS                                                 OS                       ARCH           DESCRIPTION
conformance-tester          latest-cli, v0.1.1-cli, v0.1.0-cli, v2.30.0-beta.1-cli   linux, darwin, windows   amd64, arm64   Kubermatic conformance cli
kubermatic-virtualization   latest, v1.3.0, v1.2.1, v1.1.0                           linux                    amd64          Kubermatic Virtualization installer
```

Once your credentials are set, run the downloader to retrieve and install Kubermatic Virtualization v1.1.0:

```bash
./kubermatic-ee-downloader get kubermatic-virtualization --username $KUBEV_USERNAME --password $KUBEV_PASSWORD --version v1.1.0
```

The downloader will authenticate, pull the binary artifact from the OCI registry, and install it in the current working directory. A successful run produces output similar to the following:

```
INFO[2026-04-23T14:23:55+01:00] Downloading tool                              arch=amd64 os=linux output=. registry=quay.io/kubermatic/kubermatic-virtualization-installer tool=kubermatic-virtualization version=v1.1.0
DEBU[2026-04-23T14:24:06+01:00] Manifest retrieved                            layers=1
INFO[2026-04-23T14:24:06+01:00] Downloading binary layer                      media_type=application/octet-stream size="79.15 MB"
INFO[2026-04-23T14:24:06+01:00] Download complete                             path=./kubermatic-virtualization
```

### Making the CLI Available in Your PATH

The downloader saves the binary in the current working directory. The installation guides call it as `kubermatic-virtualization`, so move it into a directory on your `PATH`:

```bash
sudo mv kubermatic-virtualization /usr/local/bin/
```

Verify that it resolves:

```bash
kubermatic-virtualization version
```

### Downloading a Different Version

Without `--version`, the downloader fetches the newest available release. To fetch another release shown by `list`, pass it with the `--version` (or `-V`) flag of `get`:

```bash
./kubermatic-ee-downloader get kubermatic-virtualization --username $KUBEV_USERNAME --password $KUBEV_PASSWORD --version <version>
```

The binary is saved in the current working directory. Move it onto your `PATH` as shown above to use it in place of the previous version.
