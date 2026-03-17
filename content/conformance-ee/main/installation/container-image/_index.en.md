+++
title = "Container Image"
date = 2026-03-17T10:07:15+02:00
weight = 20
+++

Conformance EE is distributed as a container image and can be run either as a Kubernetes Job or locally via the interactive TUI.

## Container Image

The official container image is available at:

```
quay.io/kubermatic/conformance-ee
```

### Tags

| Tag | Description |
|-----|-------------|
| `latest` | Latest release |
| `v*` | Specific version (e.g., `v1.0.0`) |

### Pulling the Image

```bash
docker pull quay.io/kubermatic/conformance-ee:latest
```

## Building from Source

### Build the Container Image

```bash
git clone https://github.com/kubermatic/conformance-ee.git
cd conformance-ee

docker build -f Dockerfile.ginkgo \
  --build-arg IMAGE_TAG="quay.io/kubermatic/conformance-ee:dev" \
  -t quay.io/kubermatic/conformance-ee:dev .
```

The multi-stage Dockerfile:

1. **Build stage** (`golang:1.25`): Downloads Go modules, installs Ginkgo v2, compiles the test binary and conformance tester
2. **Runtime stage** (`distroless/base-debian12`): Minimal image containing only the compiled binaries

### Build the Binary Locally

```bash
go build -o conformance-tester ./cmd/
```

{{% notice note %}}
The locally built binary provides the interactive TUI for configuring and launching tests, but the actual test execution still runs as a Kubernetes Job using the container image.
{{% /notice %}}
