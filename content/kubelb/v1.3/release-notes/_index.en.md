+++
title = "Release Notes"
date = 2026-01-15T00:00:00+01:00
weight = 60
+++

## Kubermatic KubeLB v1.3

- [v1.3.0](#v130)
  - [Community Edition](#community-edition)
  - [Enterprise Edition](#enterprise-edition)

## v1.3.0

**GitHub release: [v1.3.0](https://github.com/kubermatic/kubelb/releases/tag/v1.3.0)**

### Highlights

#### Supply Chain Security

KubeLB v1.3 introduces comprehensive supply chain security measures aligned with industry standards and regulatory requirements:

- **Artifact Signing**: All container images, binaries, and Helm charts are cryptographically signed using [Sigstore Cosign](https://github.com/sigstore/cosign) with keyless signing. Customers can verify artifact integrity and provenance before deployment.
- **Software Bill of Materials (SBOM)**: Every release includes SBOMs in SPDX format (ISO/IEC 5962:2021) attached to all Docker images as OCI artifacts with signed attestations.
- **Automated Vulnerability Scanning**: All PRs are scanned for vulnerabilities before merge. Container images undergo Trivy scanning at release time, with HIGH/CRITICAL vulnerabilities blocking releases.
- **Dependency Management**: Dependabot continuously monitors dependencies for known vulnerabilities with automated update PRs.

These measures ensure compliance with NTIA Minimum Elements, Executive Order 14028 (software supply chain security), and SLSA (Supply-chain Levels for Software Artifacts) guidelines.

#### Community Edition(CE)

- **Observability**: Prometheus metrics are now available for CCM, Manager, and Envoy Control Plane. Grafana dashboards have been introduced for monitoring KubeLB components.
- **Graceful Envoy Shutdown**: Envoy Proxy now gracefully drains listeners before termination to avoid downtimes.
- **Overload Manager**: Configurable overload manager and global connection limits using custom Envoy bootstrap.
- **Custom Envoy Image**: Users can now specify a custom Envoy Proxy image through the EnvoyProxy configuration.

#### Enterprise Edition(EE)

- **Circuit Breakers**: Configurable circuit breakers for Envoy Clusters at Global or Tenant level.
- **Traffic Policies**: Support for Envoy Gateway's BackendTrafficPolicy and ClientTrafficPolicy.
- **Metrics**: Additional metrics for Connection Manager and EE components.

### Community Edition

#### Features

- Prometheus metrics for CCM, Manager, and Envoy Control Plane. ([#203](https://github.com/kubermatic/kubelb/pull/203))
- Grafana dashboards for KubeLB with support for metrics scraping through prometheus annotations or ServiceMonitors. ([#204](https://github.com/kubermatic/kubelb/pull/204))
- Upgrade to Gateway API v1.4. ([#199](https://github.com/kubermatic/kubelb/pull/199))
- Upgrade to Envoy Gateway v1.5.4. ([#148](https://github.com/kubermatic/kubelb/pull/148))
- Configuring overload manager and global connection limits using a custom Envoy bootstrap. ([#198](https://github.com/kubermatic/kubelb/pull/198))
- Gracefully shutdown Envoy Proxy and drain listeners before Envoy Proxy is terminated to avoid downtimes. ([#194](https://github.com/kubermatic/kubelb/pull/194))
- KubeLB is now built using Go 1.25.5. ([#191](https://github.com/kubermatic/kubelb/pull/191))
- Introduces a new `Image` field in the EnvoyProxy configuration to allow users to specify a custom Envoy Proxy image. ([#195](https://github.com/kubermatic/kubelb/pull/195))
- Upgrade to Envoy Proxy v1.36.4. ([#197](https://github.com/kubermatic/kubelb/pull/197))
- Upgrade addons: Envoy Gateway v1.6.1, Cert Manager v1.19.2, External DNS v1.20.0, MetalLB v0.15.3, KGateway v2.1.2. ([#202](https://github.com/kubermatic/kubelb/pull/202))
- Allow overriding kube-rbac-proxy image via Helm Values. ([#206](https://github.com/kubermatic/kubelb/pull/206))

#### Bug or Regression

- Fix backendRef namespace normalization for routes. ([#207](https://github.com/kubermatic/kubelb/pull/207))

#### Other (Cleanup, Flake, or Chore)

- Update kube-rbac-proxy to v0.20.1. ([#205](https://github.com/kubermatic/kubelb/pull/205))
- Automated migration from namespace to tenant resources has been removed. ([#190](https://github.com/kubermatic/kubelb/pull/190))

**Full Changelog**: <https://github.com/kubermatic/kubelb/compare/v1.2.0...v1.3.0>

### Enterprise Edition

**Enterprise Edition includes everything from Community Edition and more. The release notes below are for changes specific to just the Enterprise Edition.**

#### EE Features

- Circuit breakers for Envoy Clusters can now be configured at Global or Tenant level.
- Support for Envoy Gateway's BackendTrafficPolicy.
- Support for Envoy Gateway's ClientTrafficPolicy.
- Supply Chain Security for KubeLB Enterprise Edition.

#### EE Bug or Regression

- Fix a bug where routes having a parent Gateway in a different namespace were not being reconciled.
