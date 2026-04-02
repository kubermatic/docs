+++
title = "Container Image & Binary"
date = 2026-03-17T10:07:15+02:00
weight = 20
+++

Conformance EE is distributed through Kubermatic's enterprise OCI registry. Since it is a private repository, all artifacts are obtained using the **kubermatic-ee-downloader** tool or by pulling the container image with valid registry credentials.

{{% notice note %}}
Access requires a valid Kubermatic Enterprise Edition subscription. [Contact our solutions team](mailto:sales@kubermatic.com) for access.
{{% /notice %}}

## Downloading the Binary

The `kubermatic-ee-downloader` CLI tool downloads the conformance-tester binary from the OCI registry and saves it locally. This is the recommended way to obtain the binary for local or TUI-based usage.

### Getting kubermatic-ee-downloader

Download the appropriate binary for your platform from the [kubermatic-ee-downloader releases](https://github.com/kubermatic/kubermatic-ee-downloader/releases):

| Platform | Architecture | Binary |
|----------|-------------|--------|
| Linux | amd64 | `kubermatic-downloader_linux_amd64` |
| Linux | arm64 | `kubermatic-downloader_linux_arm64` |
| macOS | amd64 | `kubermatic-downloader_darwin_amd64` |
| macOS | arm64 | `kubermatic-downloader_darwin_arm64` |
| Windows | amd64 | `kubermatic-downloader_windows_amd64` |
| Windows | arm64 | `kubermatic-downloader_windows_arm64` |

### Authentication

Credentials are resolved in the following order:

1. **CLI flags** — `--username` and `--password`
2. **Docker config** — `~/.docker/config.json` (e.g., after `docker login`)
3. **Interactive prompt** — if credentials are still missing, the tool asks on stdin

### Download the Conformance Tester

List available tools:

```bash
kubermatic-ee-downloader list
```

Example output:

```
TOOL               VERSIONS    OS                      ARCH        DESCRIPTION
conformance-tester latest-cli linux,darwin,windows    amd64,arm64 Kubermatic conformance cli
```

Download the conformance-tester binary:

```bash
kubermatic-ee-downloader get conformance-tester
```

Download a specific version to a custom directory:

```bash
kubermatic-ee-downloader get conformance-tester \
  --version v1.2.0 \
  --output /usr/local/bin
```

With explicit registry credentials:

```bash
kubermatic-ee-downloader get conformance-tester \
  --username <your-username> \
  --password <your-password>
```

### CLI Reference

| Flag | Short | Description |
|------|-------|-------------|
| `--username` | `-u` | Registry username |
| `--password` | `-p` | Registry password |
| `--verbose` | `-v` | Enable verbose logging |
| `--version` | `-V` | Tool version (default: tool-specific or "latest") |
| `--arch` | | Target architecture (e.g. amd64, arm64) |
| `--os` | | Target operating system (e.g. linux, darwin, windows) |
| `--registry` | `-r` | Override OCI registry (default: tool's registry) |
| `--output` | `-o` | Output directory (default: `.`) |
| `--output` | `-o` | Output directory (default: `.`) |

## Container Image

For in-cluster deployment (e.g., running as a Kubernetes Job), the container image is available at:

```
quay.io/kubermatic/conformance-ee
```

Pull with Docker using your registry credentials:

```bash
docker login quay.io
docker pull quay.io/kubermatic/conformance-ee:latest
```

### Tags

| Tag | Description |
|-----|-------------|
| `latest` | Latest release |
| `v*` | Specific version (e.g., `v1.0.0`) |
