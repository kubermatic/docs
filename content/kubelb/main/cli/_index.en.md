+++
title = "KubeLB CLI"
date = 2025-08-27T10:07:15+02:00
weight = 30
description = "Use KubeLB CLI to provision load balancers, create secure tunnels, and migrate Ingress resources to Gateway API."
+++

![KubeLB CLI](/img/kubelb/common/logo.png?classes=logo-height)

## KubeLB CLI

KubeLB CLI is a command line tool that complements KubeLB and manages load balancing configurations for multiple tenants in Kubernetes and non-Kubernetes environments.

The source code is open source and available in the [kubermatic/kubelb](https://github.com/kubermatic/kubelb) repository under `cli/`. Before KubeLB v1.5.0, the CLI lived in its own repository, [kubermatic/kubelb-cli](https://github.com/kubermatic/kubelb-cli), and was versioned independently (last standalone release: v0.2.0).

{{% notice note %}}
**Feature stage: Beta / Technical Preview.** KubeLB CLI is supported for non-business-critical use, but its commands and configuration may change between releases. Test workflows before adopting them broadly.
{{% /notice %}}

## Installation

### Manual Installation

Starting with KubeLB v1.5.0, the CLI is released together with KubeLB from the [kubermatic/kubelb releases page](https://github.com/kubermatic/kubelb/releases) and shares the KubeLB version number. Download the `kubelb-cli_<version>_<os>_<arch>` archive for your platform; the binary inside is named `kubelb`.

```bash
VERSION=1.5.0
curl -LO https://github.com/kubermatic/kubelb/releases/download/v${VERSION}/kubelb-cli_${VERSION}_linux_amd64.tar.gz
tar -xzf kubelb-cli_${VERSION}_linux_amd64.tar.gz kubelb
sudo install kubelb /usr/local/bin/
```

Releases are signed with keyless cosign and carry provenance attestations. Verify a download with:

```bash
gh attestation verify kubelb-cli_${VERSION}_linux_amd64.tar.gz --repo kubermatic/kubelb
```

Releases before v1.5.0 were published from [kubermatic/kubelb-cli](https://github.com/kubermatic/kubelb-cli/releases) and signed with a static cosign key instead.

{{% notice note %}}
KubeLB CLI is currently available for Linux, macOS, and Windows.
{{% /notice %}}

### Build from source

With Go installed, build the binary from the `cli/` directory of the [kubermatic/kubelb](https://github.com/kubermatic/kubelb) repository:

```bash
git clone https://github.com/kubermatic/kubelb.git
cd kubelb/cli
make build
```

This creates the binary at `./bin/kubelb`.

### Configuration

KubeLB CLI needs the tenant scoped kubeconfig and the tenant name to be configured either via environment variables or through the CLI flags. Environment variables are preferred as you don't have to specify them for each command.

```bash
export KUBECONFIG=/path/to/kubeconfig
export TENANT_NAME=my-tenant
```

## Table of Contents

{{% children depth=5 %}}
{{% /children %}}
