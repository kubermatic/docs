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

You can check what tools and versions provided by the downloader 

```bash
kubermatic-ee-downloader list
TOOL                        VERSIONS                         OS                       ARCH           DESCRIPTION
conformance-tester          latest-cli, v2.30.0-beta.1-cli   linux, darwin, windows   amd64, arm64   Kubermatic conformance cli
kubermatic-virtualization   latest, v1.1.0                   linux                    amd64          Kubermatic Virtualization installer
```

Once your credentials are set, run the downloader to retrieve and install the latest release of Kubermatic Virtualization:

```bash
kubermatic-ee-downloader get kubermatic-virtualization --username $USERNAME --password $PASSWORD
```

The downloader will authenticate, pull the latest binary artifact from the OCI registry, and install it in the current working directory. A successful run produces output similar to the following:

```
INFO[2026-04-23T14:23:55+01:00] Downloading tool                              arch=amd64 os=linux output=. registry=quay.io/kubermatic/kubermatic-virtualization tool=kubermatic-virtualization version=v1.1.0
DEBU[2026-04-23T14:24:06+01:00] Manifest retrieved                            layers=1
INFO[2026-04-23T14:24:06+01:00] Downloading binary layer                      media_type=application/octet-stream size="79.15 MB"
INFO[2026-04-23T14:24:06+01:00] Download complete                             path=./kubermatic-virtualization
```

Once complete, the `kubermatic-virtualization` binary is ready to use in your current directory.

### Downloading a Specific Version

By default, the downloader fetches the latest available release. If you need a specific version, use the `--version` (or `-V`) flag:

```bash
kubermatic-ee-downloader --username $USERNAME --password $PASSWORD --version v1.1.0
```