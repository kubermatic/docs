+++
title = "Prerequisites"
date = 2026-03-17T10:07:15+02:00
weight = 10
+++

Before installing Conformance EE, ensure the following prerequisites are met.

## Requirements

### Kubermatic Kubernetes Platform

Conformance EE is designed to test clusters managed by **Kubermatic Kubernetes Platform (KKP) Enterprise Edition**. You need:

- A running KKP installation (v2.25+)
- Access to the KKP API (admin or project-level credentials)
- A configured seed cluster with at least one cloud provider datacenter

### Kubernetes Cluster

A Kubernetes cluster is required to run Conformance EE as a Job:

- Kubernetes v1.27+
- `cluster-admin` privileges (or ability to create ClusterRoleBindings)
- Sufficient resources to run the conformance tester pod

### Cloud Provider

Currently, the following cloud providers are supported:

| Provider | Status |
|----------|--------|
| KubeVirt | Supported |

{{% notice note %}}
Additional providers can be added by implementing the `Provider` interface. See the [architecture documentation]({{< ref "../../architecture/" >}}) for details.
{{% /notice %}}

### Tools

For local development and building:

| Tool | Version | Purpose |
|------|---------|---------|
| Go | 1.25+ | Building the conformance tester binary |
| Docker | 20.10+ | Building the container image |
| kubectl | v1.27+ | Interacting with Kubernetes clusters |
| Ginkgo | v2.28+ | Running tests locally (optional) |

## Network Access

The conformance tester requires network access to:

- **KKP API**: To create and manage clusters
- **Kubernetes API**: Of the seed cluster for job deployment and ConfigMap reporting
- **Container Registry**: `quay.io/kubermatic/conformance-ee` for pulling the test image
- **Infrastructure Provider APIs**: For cluster provisioning (e.g., KubeVirt API)
