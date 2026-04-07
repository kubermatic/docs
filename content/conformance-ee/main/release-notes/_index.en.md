+++
title = "Release Notes"
date = 2026-03-17T10:07:15+02:00
weight = 60
+++

{{% notice warning %}}
This document is work in progress and might not be in a correct or up-to-date state.
{{% /notice %}}

## Conformance EE Releases

Release artifacts are published as container images:

- **Container Image**: `quay.io/kubermatic/conformance-ee`

### Latest (main)

The `main` branch tracks the latest development. Tagged releases follow semantic versioning.

#### Highlights

- Ginkgo v2-based test framework with combinatorial scenario generation
- SHA-256 deduplication for efficient cluster reuse
- Interactive Bubble Tea TUI for test configuration
- KubeVirt provider with full infrastructure discovery
- In-cluster execution via Kubernetes Jobs
- JUnit XML and ConfigMap live reporting
- Support for multiple Kubernetes versions and OS distributions
