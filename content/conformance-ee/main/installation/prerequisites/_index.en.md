+++
title = "Prerequisites"
date = 2026-03-17T10:07:15+02:00
weight = 10
+++

Before installing Conformance EE, ensure the following prerequisites are met.

## Requirements

### Kubermatic Kubernetes Platform

Conformance EE is designed to test clusters managed by **Kubermatic Kubernetes Platform (KKP) Enterprise Edition**. You need:

- A running KKP installation (v2.30+)
- Access to the KKP API (admin or project-level credentials)
- A configured seed cluster with at least one cloud provider datacenter

### Kubernetes Cluster

A Kubernetes cluster is required to run Conformance EE as a Job:

- Kubernetes v1.30+
- `cluster-admin` privileges (or ability to create ClusterRoleBindings)
- Sufficient resources to run the conformance tester pod

### Cloud Provider

Currently, the following cloud providers are supported:

| Provider | Status |
|----------|--------|
| KubeVirt | Supported |

{{% notice note %}}
Additional providers may be supported in future releases.
{{% /notice %}}

### Enterprise Edition Subscription

Access to Conformance EE requires a valid **Kubermatic Enterprise Edition subscription**. This includes:

- Registry credentials for pulling the container image and downloading binaries
- Access to the `quay.io/kubermatic/conformance-ee` OCI registry

[Contact our solutions team](mailto:sales@kubermatic.com) if you need access.

### Tools

The following tools are needed to work with Conformance EE:

| Tool | Version | Purpose |
|------|---------|--------|
| kubermatic-ee-downloader | latest | Downloading the conformance-tester binary |

The `kubermatic-ee-downloader` is available for **Linux**, **Darwin (macOS)**, and **Windows** with support for both **amd64** and **arm64** architectures. See the [Container Image & Binary]({{< ref "../container-image/" >}}) page for download instructions.

## Network Access

The conformance tester requires network access to:

- **KKP API**: To create and manage clusters
- **Kubernetes API**: Of the seed cluster for job deployment and ConfigMap reporting
- **Container Registry**: `quay.io/kubermatic/conformance-ee` for pulling the test image
- **Infrastructure Provider APIs**: For cluster provisioning (e.g., KubeVirt API)
