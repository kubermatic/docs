+++
title = "Getting Kubermatic Virtualization"
date = 2026-02-24T12:00:00+02:00
weight = 1
+++

## Overview

Kubermatic Virtualization can be obtained in two ways: using the **Kubermatic Virtualization Downloader**, a dedicated CLI tool that authenticates against Kubermatic's OCI registry and installs the binary for you, or by pulling the artifact directly using **ORAS** if you prefer working with OCI registries manually.

## Using the Kubermatic Virtualization Downloader

The recommended way to get Kubermatic Virtualization is through the `kubev-downloader` CLI tool. It handles authentication, artifact retrieval, and local installation in a single command.

### Getting the Downloader

The fastest way to install `kubev-downloader` is to use the installation script:

```bash
curl -sfL https://get.virtualization.k8c.io | sh
```

The script will download and install the `kubev-downloader` binary automatically — no additional setup is required.

### Credentials

The downloader requires a username and password to authenticate against Kubermatic's OCI registry. To obtain your credentials, please contact [sales@kubermatic.com](mailto:sales@kubermatic.com)

It is recommended to store your credentials as environment variables:

```bash
export USERNAME=<your-username>
export PASSWORD=<your-password>
```

### Running the Downloader

Once your credentials are set, run the downloader to retrieve and install the latest release of Kubermatic Virtualization:

```bash
kubev-downloader --username $USERNAME --password $PASSWORD
```

The downloader will authenticate, pull the latest binary artifact from the OCI registry, and install it in the current working directory. A successful run produces output similar to the following:

```
INFO[12:42:11 CET] Initializing Kubermatic Virtualization Downloader  output=. tag=v1.1.0
INFO[12:42:11 CET] Starting artifact retrieval from our OCI registry  tag=v1.1.0
INFO[12:42:12 CET] Retrieving the binary artifact
INFO[12:42:24 CET] Downloading binary artifact                   digest="sha256:0ffdfa591b57ee14963c846a86a2ecfc931a20976c8812f7bd13731ffb708430" size="78.99 MB"
INFO[12:42:24 CET] Binary artifact downloaded successfully       size="78.99 MB"
INFO[12:42:24 CET] Installing binary                             path=kubermatic-virtualization permissions=0755 size_bytes=82828164
INFO[12:42:24 CET] Installation completed successfully           binary=kubermatic-virtualization path=.
```

Once complete, the `kubermatic-virtualization` binary is ready to use in your current directory.

### Downloading a Specific Version

By default, the downloader fetches the latest available release. If you need a specific version, use the `--tag` (or `-t`) flag:

```bash
kubev-downloader --username $USERNAME --password $PASSWORD --tag v1.1.0
```

---

## Using ORAS

If you prefer to pull Kubermatic Virtualization directly from the OCI registry, you can use [ORAS (OCI Registry As Storage)](https://oras.land/), a CLI tool for working with OCI artifacts.

### Installing ORAS

Follow the [official ORAS installation guide](https://oras.land/docs/installation) for your platform. On macOS with Homebrew:

```bash
brew install oras
```

On Linux, download the latest release binary and place it on your `$PATH`:

```bash
VERSION=$(curl -s https://api.github.com/repos/oras-project/oras/releases/latest | grep tag_name | cut -d '"' -f4 | sed 's/v//')
curl -LO "https://github.com/oras-project/oras/releases/download/v${VERSION}/oras_${VERSION}_linux_amd64.tar.gz"
tar -xzf oras_${VERSION}_linux_amd64.tar.gz
sudo mv oras /usr/local/bin/
```

### Logging In to the Registry

Before pulling, authenticate with the Kubermatic registry using your credentials:

```bash
oras login quay.io --username $USERNAME --password $PASSWORD
```

### Pulling the Latest Version

To pull the latest release of Kubermatic Virtualization, first retrieve the latest version tag from the public Kubermatic release API, then pass it to `oras pull`:

```bash
VERSION=$(curl -w '%{url_effective}' -I -L -s -S https://github.com/kubermatic/kubev-downloader/releases/latest -o /dev/null | sed -e 's|.*/||')
oras pull quay.io/kubermatic/kubermatic-virtualization:${VERSION}
```

### Pulling a Specific Version

If you need a particular release, set the version explicitly:

```bash
VERSION=v9.0.0
oras pull quay.io/kubermatic/kubermatic-virtualization:${VERSION}
```

A successful pull produces output similar to the following:

```
✓ Pulled      kubermatic-virtualization                                                                 79.1/79.1 MB 100.00%    31s
  └─ sha256:b8b54b306e0c92e5da81777fc4373d858f439b5f2767c54d177fea7407db8523
✓ Pulled      application/vnd.oci.image.manifest.v1+json                                                  852/852  B 100.00%  251µs
  └─ sha256:d3d3428ad153bc52eb5494fc353baaae3b940422d698c9e9c6bd0b2d8b1ec725
Pulled [registry] quay.io/kubermatic/kubermatic-virtualization:v9.0.0
Digest: sha256:d3d3428ad153bc52eb5494fc353baaae3b940422d698c9e9c6bd0b2d8b1ec725
```

{{% notice note %}}
Always verify the digest of the downloaded artifact against the value provided in the release notes to ensure the integrity of the binary.
{{% /notice %}}

---

## Verifying the Installation

Regardless of which installation method you used, you can verify that `kubermatic-virtualization` is correctly installed by checking its version:

```bash
kubermatic-virtualization version
```