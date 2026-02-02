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

#### Web Application Firewall (WAF)

With v1.3, KubeLB has introduced Web Application Firewall (WAF) capabilities as an Enterprise Edition (EE) **alpha** feature. With KubeLB WAF, you can protect your applications from SQL injection, XSS, and other injection attacks without application changes from a single point of control.

Learn more in the [KubeLB WAF tutorial]({{< relref "../tutorials/web-application-firewall" >}}).

#### Ingress to Gateway API Migration

Introducing automated conversion from Ingress to Gateway API resources **[Beta Feature]**:

- Covers essential ingress-nginx annotations
- Includes automatic Envoy Gateway policy generation for CORS, auth, timeouts, and rate limits. BackendTrafficPolicy, SecurityPolicy are generated against corresponding Ingress annotations by the converter
- Warnings for resources that require manual migration
- Standalone mode has been introduced for converter; this allows users to only run converter using KubeLB CCM without any other CCM feature. This is helpful when KubeLB is only deployed for this Ingress to Gateway API migration

Learn more in the [KubeLB Ingress to Gateway API Converter how-to]({{< relref "../ingress-to-gateway-api/kubelb-automation" >}}).

#### Supply Chain Security

KubeLB v1.3 introduces comprehensive supply chain security for both CE and EE:

- **SBOM Generation**: SPDX format (ISO/IEC 5962:2021) SBOMs for all binaries and container images
- **Keyless Artifact Signing**: [Sigstore Cosign](https://github.com/sigstore/cosign) signatures for binaries, images, and Helm charts
- **SBOM Attestation**: Signed SBOM attestations via Cosign
- **Immutable Releases**: Release artifacts cannot be modified after publication
- **Vulnerability Scanning**: Automated scanning in PRs and release pipeline (HIGH/CRITICAL block releases)
- **Dependency Monitoring**: Dependabot tracks and updates vulnerable dependencies

Community Edition Additional Features:

- [OpenSSF Scorecard](https://securityscorecards.dev/) for security health metrics
- GitHub dependency graph
- GitHub attestations and provenance publishing

These measures ensure compliance with NTIA Minimum Elements, Executive Order 14028, and SLSA guidelines.

Learn more in the [Supply Chain Security documentation]({{< relref "../security" >}}).

#### Community Edition (CE)

- **[Ingress to Gateway API Migration]({{< relref "../ingress-to-gateway-api/kubelb-automation" >}}) (Beta)**: Automated conversion from Ingress to Gateway API resources.
- **[Observability]({{< relref "../tutorials/observability" >}})**: Prometheus metrics for CCM, Manager, and Envoy Control Plane. Grafana dashboards for monitoring KubeLB components.
- **Revamped E2E Tests**: E2E tests revamped to use chainsaw framework, now running in CI/CD pipeline.
- **[Graceful Envoy Shutdown]({{< relref "../tutorials/envoy-proxy/graceful-shutdown" >}})**: Envoy Proxy gracefully drains listeners before termination to avoid downtimes.
- **[Overload Manager]({{< relref "../tutorials/envoy-proxy/overload-manager" >}})**: Configurable overload manager and global connection limits using custom Envoy bootstrap.
- **[Custom Envoy Image]({{< relref "../references/ce#envoyproxy" >}})**: Custom Envoy Proxy image through the EnvoyProxy configuration.

#### Enterprise Edition (EE)

- **[Web Application Firewall]({{< relref "../tutorials/web-application-firewall" >}}) (WAF)**: WAF capabilities as an **alpha** feature.
- **[Circuit Breakers]({{< relref "../tutorials/envoy-proxy/circuit-breakers" >}})**: Configurable circuit breakers for Envoy Clusters at Global or Tenant level.
- **[Traffic Policies]({{< relref "../tutorials/gatewayapi/backend-traffic-policy" >}})**: Support for Envoy Gateway's [BackendTrafficPolicy]({{< relref "../tutorials/gatewayapi/backend-traffic-policy" >}}) and [ClientTrafficPolicy]({{< relref "../tutorials/gatewayapi/client-traffic-policy" >}}).
- **[Metrics]({{< relref "../tutorials/observability/metrics-and-dashboards/" >}})**: Additional metrics for Connection Manager and EE components.

### Community Edition

#### Features

- Introduces automated conversion from Ingress to Gateway API resources. ([#249](https://github.com/kubermatic/kubelb/pull/249))
- Add supply chain security: signing, SBOMs, and security documentation. ([#220](https://github.com/kubermatic/kubelb/pull/220))
- Prometheus metrics for CCM, Manager, and Envoy Control Plane. ([#203](https://github.com/kubermatic/kubelb/pull/203))
- Grafana dashboards for KubeLB with support for metrics scraping through prometheus annotations or ServiceMonitors. ([#204](https://github.com/kubermatic/kubelb/pull/204))
- Grafana dashboard for Envoy Proxy monitoring. ([#246](https://github.com/kubermatic/kubelb/pull/246))
- Overhaul e2e testing infrastructure with Chainsaw framework, adding comprehensive Layer 4/7 test coverage. ([#217](https://github.com/kubermatic/kubelb/pull/217))
- Upgrade to Gateway API v1.4. ([#199](https://github.com/kubermatic/kubelb/pull/199))
- Upgrade to Envoy Gateway v1.5.4. ([#148](https://github.com/kubermatic/kubelb/pull/148))
- Configuring overload manager and global connection limits using a custom Envoy bootstrap. ([#198](https://github.com/kubermatic/kubelb/pull/198))
- Gracefully shutdown Envoy Proxy and drain listeners before Envoy Proxy is terminated to avoid downtimes. ([#194](https://github.com/kubermatic/kubelb/pull/194))
- TCP listeners have been replaced with HTTP listeners for HTTP traffic i.e. Ingress, HTTPRoute, GRPCRoute. ([#240](https://github.com/kubermatic/kubelb/pull/240))
- KubeLB is now built using Go 1.25.5. ([#191](https://github.com/kubermatic/kubelb/pull/191))
- KubeLB is now built using Go 1.25.6. ([#238](https://github.com/kubermatic/kubelb/pull/238))
- Introduces a new `Image` field in the EnvoyProxy configuration to allow users to specify a custom Envoy Proxy image. ([#195](https://github.com/kubermatic/kubelb/pull/195))
- Upgrade to Envoy Proxy v1.36.4. ([#197](https://github.com/kubermatic/kubelb/pull/197))
- Upgrade addons: Envoy Gateway v1.6.1, Cert Manager v1.19.2, External DNS v1.20.0, MetalLB v0.15.3, KGateway v2.1.2. ([#202](https://github.com/kubermatic/kubelb/pull/202))
- Allow overriding kube-rbac-proxy image via Helm Values. ([#206](https://github.com/kubermatic/kubelb/pull/206))

#### Bug or Regression

- Routes should create unique services instead of shared services. ([#250](https://github.com/kubermatic/kubelb/pull/250))
- Fix backendRef namespace normalization for routes. ([#207](https://github.com/kubermatic/kubelb/pull/207))

#### Other (Cleanup, Flake, or Chore)

- Update kube-rbac-proxy to v0.20.1. ([#205](https://github.com/kubermatic/kubelb/pull/205))
- Bump addons in kubelb-manager to v0.3.0. ([#234](https://github.com/kubermatic/kubelb/pull/234))
- Automated migration from namespace to tenant resources has been removed. ([#190](https://github.com/kubermatic/kubelb/pull/190))

**Full Changelog**: <https://github.com/kubermatic/kubelb/compare/v1.2.0...v1.3.0>

### Enterprise Edition

**Enterprise Edition includes everything from Community Edition and more. The release notes below are for changes specific to just the Enterprise Edition.**

#### EE Features

- Web Application Firewall (WAF) capabilities as an **alpha** feature.
- Circuit breakers for Envoy Clusters can now be configured at Global or Tenant level.
- Support for Envoy Gateway's BackendTrafficPolicy.
- Support for Envoy Gateway's ClientTrafficPolicy.

#### EE Bug or Regression

- Fix a bug where routes having a parent Gateway in a different namespace were not being reconciled.

### Release Artifacts

#### Community Edition

For Community Edition, the release artifacts are available on [GitHub Releases](https://github.com/kubermatic/kubelb/releases/tag/v1.3.0).

#### Enterprise Edition

<details>
<summary><b>Docker Images</b></summary>

```bash
# Login to registry
docker login quay.io -u <username> -p <password>

# kubelb manager
docker pull quay.io/kubermatic/kubelb-manager-ee:v1.3.0

# ccm
docker pull quay.io/kubermatic/kubelb-ccm-ee:v1.3.0

# connection-manager
docker pull quay.io/kubermatic/kubelb-connection-manager-ee:v1.3.0
```

</details>

<details>
<summary><b>Helm Charts</b></summary>

```bash
# kubelb-manager
helm pull oci://quay.io/kubermatic/helm-charts/kubelb-manager-ee --version v1.3.0

# kubelb-ccm
helm pull oci://quay.io/kubermatic/helm-charts/kubelb-ccm-ee --version v1.3.0

# kubelb-addons
helm pull oci://quay.io/kubermatic/helm-charts/kubelb-addons --version v0.3.0
```

</details>

<details>
<summary><b>SBOMs</b></summary>

Container image SBOMs are attached as OCI artifacts and attested with cosign.

**Pull SBOM:**

```bash
# Login to registry
oras login quay.io -u <username> -p <password>

## kubelb-manager
SBOM_DIGEST=$(oras discover --format json --artifact-type application/spdx+json \
  quay.io/kubermatic/kubelb-manager-ee:v1.3.0 | jq -r '.referrers[0].digest')
oras pull quay.io/kubermatic/kubelb-manager-ee@${SBOM_DIGEST} --output sbom/

## kubelb-ccm
SBOM_DIGEST=$(oras discover --format json --artifact-type application/spdx+json \
  quay.io/kubermatic/kubelb-ccm-ee:v1.3.0 | jq -r '.referrers[0].digest')
oras pull quay.io/kubermatic/kubelb-ccm-ee@${SBOM_DIGEST} --output sbom/

## kubelb-connection-manager
SBOM_DIGEST=$(oras discover --format json --artifact-type application/spdx+json \
  quay.io/kubermatic/kubelb-connection-manager-ee:v1.3.0 | jq -r '.referrers[0].digest')
oras pull quay.io/kubermatic/kubelb-connection-manager-ee@${SBOM_DIGEST} --output sbom/
```

**Verify SBOM attestation:**

```bash
cosign verify-attestation quay.io/kubermatic/kubelb-manager-ee:v1.3.0 \
  --type spdxjson \
  --certificate-identity-regexp="^https://github.com/kubermatic/kubelb-ee/.github/workflows/release.yml@refs/tags/v.*" \
  --certificate-oidc-issuer=https://token.actions.githubusercontent.com

cosign verify-attestation quay.io/kubermatic/kubelb-ccm-ee:v1.3.0 \
  --type spdxjson \
  --certificate-identity-regexp="^https://github.com/kubermatic/kubelb-ee/.github/workflows/release.yml@refs/tags/v.*" \
  --certificate-oidc-issuer=https://token.actions.githubusercontent.com

cosign verify-attestation quay.io/kubermatic/kubelb-connection-manager-ee:v1.3.0 \
  --type spdxjson \
  --certificate-identity-regexp="^https://github.com/kubermatic/kubelb-ee/.github/workflows/release.yml@refs/tags/v.*" \
  --certificate-oidc-issuer=https://token.actions.githubusercontent.com
```

</details>

<details>
<summary><b>Verify Signatures</b></summary>

**Docker images:**

```bash
cosign verify quay.io/kubermatic/kubelb-manager-ee:v1.3.0 \
  --certificate-identity-regexp="^https://github.com/kubermatic/kubelb-ee/.github/workflows/release.yml@refs/tags/v.*" \
  --certificate-oidc-issuer=https://token.actions.githubusercontent.com

cosign verify quay.io/kubermatic/kubelb-ccm-ee:v1.3.0 \
  --certificate-identity-regexp="^https://github.com/kubermatic/kubelb-ee/.github/workflows/release.yml@refs/tags/v.*" \
  --certificate-oidc-issuer=https://token.actions.githubusercontent.com

cosign verify quay.io/kubermatic/kubelb-connection-manager-ee:v1.3.0 \
  --certificate-identity-regexp="^https://github.com/kubermatic/kubelb-ee/.github/workflows/release.yml@refs/tags/v.*" \
  --certificate-oidc-issuer=https://token.actions.githubusercontent.com
```

**Helm charts:**

```bash
cosign verify quay.io/kubermatic/helm-charts/kubelb-manager-ee:v1.3.0 \
  --certificate-identity-regexp="^https://github.com/kubermatic/kubelb-ee/.github/workflows/release.yml@refs/tags/v.*" \
  --certificate-oidc-issuer=https://token.actions.githubusercontent.com

cosign verify quay.io/kubermatic/helm-charts/kubelb-ccm-ee:v1.3.0 \
  --certificate-identity-regexp="^https://github.com/kubermatic/kubelb-ee/.github/workflows/release.yml@refs/tags/v.*" \
  --certificate-oidc-issuer=https://token.actions.githubusercontent.com

cosign verify quay.io/kubermatic/helm-charts/kubelb-addons:v0.3.0 \
  --certificate-identity-regexp="^https://github.com/kubermatic/kubelb/.github/workflows/release.yml@refs/tags/addons-v.*" \
  --certificate-oidc-issuer=https://token.actions.githubusercontent.com
```

**Release checksums (requires repository access):**

```bash
cosign verify-blob --bundle checksums.txt.sigstore.json checksums.txt \
  --certificate-identity-regexp="^https://github.com/kubermatic/kubelb-ee/.github/workflows/release.yml@refs/tags/v.*" \
  --certificate-oidc-issuer=https://token.actions.githubusercontent.com
```

</details>

<details>
<summary><b>Tools</b></summary>

- [Cosign](https://github.com/sigstore/cosign) - Container signing
- [ORAS](https://oras.land) - OCI Registry As Storage

</details>
