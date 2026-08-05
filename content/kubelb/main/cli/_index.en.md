+++
title = "KubeLB CLI"
date = 2025-08-27T10:07:15+02:00
weight = 30
description = "Use KubeLB CLI to provision load balancers, create secure tunnels, and migrate Ingress resources to Gateway API."
+++

![KubeLB CLI](/img/kubelb/common/logo.png?classes=logo-height)

## KubeLB CLI

KubeLB CLI is a command line tool that complements KubeLB and manages load balancing configurations for multiple tenants in Kubernetes and non-Kubernetes environments.

The source code is open source and available at [kubermatic/kubelb-cli](https://github.com/kubermatic/kubelb-cli).

{{% notice note %}}
**Feature stage: Beta / Technical Preview.** KubeLB CLI is supported for non-business-critical use, but its commands and configuration may change between releases. Test workflows before adopting them broadly.
{{% /notice %}}

## Installation

### Manual Installation

Download the pre-compiled binary for your system from the [releases page](https://github.com/kubermatic/kubelb-cli/releases) and copy it to the desired location.

{{% notice note %}}
KubeLB CLI is currently available for Linux, macOS, and Windows.
{{% /notice %}}

### Install using `go install`

With Go installed, build the binary from source:

```bash
go install github.com/kubermatic/kubelb-cli@v0.2.0
```

### Configuration

KubeLB CLI needs the tenant scoped kubeconfig and the tenant name to be configured either via environment variables or through the CLI flags. Environment variables are preferred as you don't have to specify them for each command.

```bash
export KUBECONFIG=/path/to/kubeconfig
export TENANT_NAME=my-tenant
```

## Table of Contents

{{% children depth=5 %}}
{{% /children %}}
