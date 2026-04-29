+++
title = "Supply Chain Security"
linkTitle = "Security"
date = 2026-01-16T00:00:00+02:00
weight = 25
+++

KubeLB v1.3 provides supply chain security for both Community Edition (CE) and Enterprise Edition (EE):

- **SBOM Generation**: SPDX format SBOMs for all binaries and container images
- **Keyless Artifact Signing**: Cosign signatures for binaries, images, and Helm charts
- **SBOM Attestation**: Signed SBOM attestations via Cosign
- **Immutable Releases**: Release artifacts cannot be modified after publication
- **Vulnerability Scanning**: Automated scanning in PRs and release pipeline
- **Dependency Monitoring**: Dependabot tracks and updates vulnerable dependencies

**CE Additional Features:**

- [OpenSSF Scorecard](https://securityscorecards.dev/) for security health metrics
- GitHub dependency graph
- GitHub attestations and provenance publishing

These features require a public GitHub repository.

## Editions

| Edition | Repository | Registry | Access |
|---------|------------|----------|--------|
| CE | `kubermatic/kubelb` | `quay.io/kubermatic/` | Public |
| EE | `kubermatic/kubelb-ee` | `quay.io/kubermatic/` | Licensed |

**Components:**

| Component | CE | EE |
|-----------|----|----|
| Manager | `kubelb-manager` | `kubelb-manager-ee` |
| CCM | `kubelb-ccm` | `kubelb-ccm-ee` |
| Connection Manager | — | `kubelb-connection-manager-ee` |

## Verify Container Image Signatures

{{< tabs name="verify-images" >}}
{{% tab name="Enterprise Edition" %}}

```bash
# Login required for EE images
docker login quay.io

cosign verify quay.io/kubermatic/kubelb-manager-ee:v1.3.0 \
  --certificate-identity-regexp="^https://github.com/kubermatic/kubelb-ee/.github/workflows/release.yml@refs/tags/v.*" \
  --certificate-oidc-issuer=https://token.actions.githubusercontent.com
```

{{% /tab %}}
{{% tab name="Community Edition" %}}

```bash
cosign verify quay.io/kubermatic/kubelb-manager:v1.3.0 \
  --certificate-identity-regexp="^https://github.com/kubermatic/kubelb/.github/workflows/release.yml@refs/tags/v.*" \
  --certificate-oidc-issuer=https://token.actions.githubusercontent.com
```

{{% /tab %}}
{{< /tabs >}}

## Verify Helm Chart Signatures

{{< tabs name="verify-helm" >}}
{{% tab name="Enterprise Edition" %}}

```bash
cosign verify quay.io/kubermatic/helm-charts/kubelb-manager-ee:v1.3.0 \
  --certificate-identity-regexp="^https://github.com/kubermatic/kubelb-ee/.github/workflows/release.yml@refs/tags/v.*" \
  --certificate-oidc-issuer=https://token.actions.githubusercontent.com
```

{{% /tab %}}
{{% tab name="Community Edition" %}}

```bash
cosign verify quay.io/kubermatic/helm-charts/kubelb-manager:v1.3.0 \
  --certificate-identity-regexp="^https://github.com/kubermatic/kubelb/.github/workflows/release.yml@refs/tags/v.*" \
  --certificate-oidc-issuer=https://token.actions.githubusercontent.com
```

{{% /tab %}}
{{< /tabs >}}

## Verify Release Checksums

Each release includes a `checksums.txt` file signed with Cosign.

{{< tabs name="verify-checksums" >}}
{{% tab name="Enterprise Edition" %}}

```bash
# Requires repository access
# Download checksums.txt and checksums.txt.sigstore.json from the release

cosign verify-blob --bundle checksums.txt.sigstore.json checksums.txt \
  --certificate-identity-regexp="^https://github.com/kubermatic/kubelb-ee/.github/workflows/release.yml@refs/tags/v.*" \
  --certificate-oidc-issuer=https://token.actions.githubusercontent.com
```

{{% /tab %}}
{{% tab name="Community Edition" %}}

```bash
# Download from GitHub release
curl -LO https://github.com/kubermatic/kubelb/releases/download/v1.3.0/checksums.txt
curl -LO https://github.com/kubermatic/kubelb/releases/download/v1.3.0/checksums.txt.sigstore.json

cosign verify-blob --bundle checksums.txt.sigstore.json checksums.txt \
  --certificate-identity-regexp="^https://github.com/kubermatic/kubelb/.github/workflows/release.yml@refs/tags/v.*" \
  --certificate-oidc-issuer=https://token.actions.githubusercontent.com
```

{{% /tab %}}
{{< /tabs >}}

## Software Bill of Materials (SBOM)

SBOMs are provided in SPDX format for all artifacts.

### Container Image SBOMs

SBOMs are attached to container images as OCI artifacts using [ORAS](https://oras.land).

{{< tabs name="download-sbom" >}}
{{% tab name="Enterprise Edition" %}}

```bash
# Login required
oras login quay.io

# Discover and pull SBOM
SBOM_DIGEST=$(oras discover --format json --artifact-type application/spdx+json \
  quay.io/kubermatic/kubelb-manager-ee:v1.3.0 | jq -r '.referrers[0].digest')
oras pull quay.io/kubermatic/kubelb-manager-ee@${SBOM_DIGEST} --output sbom/
```

{{% /tab %}}
{{% tab name="Community Edition" %}}

```bash
SBOM_DIGEST=$(oras discover --format json --artifact-type application/spdx+json \
  quay.io/kubermatic/kubelb-manager:v1.3.0 | jq -r '.referrers[0].digest')
oras pull quay.io/kubermatic/kubelb-manager@${SBOM_DIGEST} --output sbom/
```

{{% /tab %}}
{{< /tabs >}}

### Verify SBOM Attestation

{{< tabs name="verify-sbom" >}}
{{% tab name="Enterprise Edition" %}}

```bash
cosign verify-attestation quay.io/kubermatic/kubelb-manager-ee:v1.3.0 \
  --type spdxjson \
  --certificate-identity-regexp="^https://github.com/kubermatic/kubelb-ee/.github/workflows/release.yml@refs/tags/v.*" \
  --certificate-oidc-issuer=https://token.actions.githubusercontent.com
```

{{% /tab %}}
{{% tab name="Community Edition" %}}

```bash
cosign verify-attestation quay.io/kubermatic/kubelb-manager:v1.3.0 \
  --type spdxjson \
  --certificate-identity-regexp="^https://github.com/kubermatic/kubelb/.github/workflows/release.yml@refs/tags/v.*" \
  --certificate-oidc-issuer=https://token.actions.githubusercontent.com
```

{{% /tab %}}
{{< /tabs >}}

### Binary SBOMs

SBOMs for release binaries are available as GitHub release assets.

{{< tabs name="binary-sbom" >}}
{{% tab name="Enterprise Edition" %}}
Release assets (requires repository access):

- `kubelb_<version>_linux_amd64.sbom.spdx.json`
- `kubelb_<version>_linux_arm64.sbom.spdx.json`
- `ccm_<version>_linux_amd64.sbom.spdx.json`
- `ccm_<version>_linux_arm64.sbom.spdx.json`
- `connection-manager_<version>_linux_amd64.sbom.spdx.json`
- `connection-manager_<version>_linux_arm64.sbom.spdx.json`
{{% /tab %}}
{{% tab name="Community Edition" %}}

```bash
# All SBOMs are available in the GitHub release assets. Please refer to the GitHub release page for the latest version.
curl -LO https://github.com/kubermatic/kubelb/releases/download/v1.3.0/kubelb_v1.3.0_linux_amd64.sbom.spdx.json
```

{{% /tab %}}
{{< /tabs >}}

## Vulnerability Scanning

KubeLB enforces automated vulnerability scanning:

- All PRs scanned before merge
- Container images scanned with [Trivy](https://trivy.dev/) at release
- HIGH/CRITICAL vulnerabilities block releases
- [Dependabot](https://github.com/dependabot) monitors dependencies

Scan locally:

```bash
trivy image quay.io/kubermatic/kubelb-manager:v1.3.0
```

## Tools

- [Cosign](https://github.com/sigstore/cosign) — Artifact signing and verification
- [ORAS](https://oras.land) — OCI Registry As Storage

## Vulnerability Reporting

See [Vulnerability Reporting]({{< relref "./vulnerability-reporting" >}}) for security disclosure process.
