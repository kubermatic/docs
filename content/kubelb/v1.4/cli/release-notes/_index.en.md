+++
title = "Release Notes"
date = 2024-03-15T00:00:00+01:00
weight = 40
+++

## Kubermatic KubeLB CLI  v0.2.0

- [Kubermatic KubeLB CLI  v0.2.0](#kubermatic-kubelb-cli--v020)
- [v0.2.0](#v020)
  - [Highlights](#highlights)
  - [Features](#features)

## v0.2.0

**GitHub release: [v0.2.0](https://github.com/kubermatic/kubelb-cli/releases/tag/v0.2.0)**

### Highlights

KubeLB CLI v0.2.0 introduces built-in tooling for migrating Ingress resources to Gateway API. As a **beta** feature, it supports migrating Ingress resources to Gateway API resources through a command-line interface and a web dashboard.

We support ingress-nginx as the source Ingress controller and Envoy Gateway as the target Gateway API implementation, for now.

Learn more in the [Ingress to Gateway API CLI documentation]({{< relref "../ingress-to-gateway-api" >}}).

### Features

- Add Ingress to Gateway API conversion CLI and web dashboard. ([#21](https://github.com/kubermatic/kubelb-cli/pull/21))
