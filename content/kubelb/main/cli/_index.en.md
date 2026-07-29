+++
title = "KubeLB CLI"
date = 2025-08-27T10:07:15+02:00
weight = 30
description = "Learn how you can use KubeLB CLI to provision Load Balancers and tunnels to expose local workloads"
+++

![KubeLB CLI](/img/kubelb/common/logo.png?classes=logo-height)

## KubeLB CLI

KubeLB CLI is a command line tool that complements KubeLB and manages load balancing configurations for multiple tenants in Kubernetes and non-Kubernetes environments.

The source code is open source and available at [kubermatic/kubelb-cli](https://github.com/kubermatic/kubelb-cli).

{{% notice note %}}
KubeLB CLI is currently in beta feature stage and is not yet ready for production use. We are actively working on the feature set and taking feedback from the community and our customers to improve the CLI.
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
