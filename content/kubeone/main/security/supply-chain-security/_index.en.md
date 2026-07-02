+++
title = "Supply Chain Security"
date = 2026-07-02T00:00:00+02:00
weight = 20
+++

Starting from v1.14, KubeOne provides supply chain security for the KubeOne CLI binary:

- **SBOM Generation**: SPDX-JSON SBOMs for each platform binary
- **Keyless Artifact Signing**: Cosign keyless signatures for the release checksum file
- **Immutable Releases**: Release artifacts cannot be modified after publication
- **Vulnerability Scanning**: govulncheck runs on every pull request
- **Dependency Monitoring**: Dependabot tracks and updates vulnerable Go dependencies

## Release Artifacts

Each KubeOne release publishes the following assets to [GitHub Releases](https://github.com/kubermatic/kubeone/releases):

```
kubeone_<version>_linux_amd64.zip
kubeone_<version>_linux_arm64.zip
kubeone_<version>_darwin_amd64.zip
kubeone_<version>_darwin_arm64.zip
kubeone_<version>_linux_amd64.sbom.spdx.json
kubeone_<version>_linux_arm64.sbom.spdx.json
kubeone_<version>_darwin_amd64.sbom.spdx.json
kubeone_<version>_darwin_arm64.sbom.spdx.json
kubeone_<version>_checksums.txt
kubeone_<version>_checksums.txt.sigstore.json
```

## Prerequisites

Install [Cosign](https://docs.sigstore.dev/cosign/system_config/installation/) to verify signatures:

```bash
# macOS
brew install cosign

# Linux
curl -O -L "https://github.com/sigstore/cosign/releases/latest/download/cosign-linux-amd64"
sudo mv cosign-linux-amd64 /usr/local/bin/cosign
sudo chmod +x /usr/local/bin/cosign
```

## Verify Release Checksums

Each release includes a `checksums.txt` file covering all release assets (zip archives and SBOMs), signed with [Cosign](https://github.com/sigstore/cosign) keyless signing via GitHub Actions OIDC.

```bash
VERSION=v1.14.0

curl -LO https://github.com/kubermatic/kubeone/releases/download/${VERSION}/kubeone_${VERSION#v}_checksums.txt
curl -LO https://github.com/kubermatic/kubeone/releases/download/${VERSION}/kubeone_${VERSION#v}_checksums.txt.sigstore.json

cosign verify-blob \
  --bundle kubeone_${VERSION#v}_checksums.txt.sigstore.json \
  --certificate-identity-regexp="^https://github.com/kubermatic/kubeone/.github/workflows/release.yml@refs/tags/v.*" \
  --certificate-oidc-issuer=https://token.actions.githubusercontent.com \
  kubeone_${VERSION#v}_checksums.txt
```

Expected output: `Verified OK`

## Verify Archive Integrity

After verifying the signature of `checksums.txt`, verify the downloaded archive against the recorded checksum:

```bash
VERSION=v1.14.0
OS=linux
ARCH=amd64

curl -LO https://github.com/kubermatic/kubeone/releases/download/${VERSION}/kubeone_${VERSION#v}_${OS}_${ARCH}.zip

grep "kubeone_${VERSION#v}_${OS}_${ARCH}.zip" kubeone_${VERSION#v}_checksums.txt | sha256sum --check
```

Expected output: `kubeone_1.14.0_linux_amd64.zip: OK`

## Software Bill of Materials (SBOM)

Each platform binary has a corresponding SBOM in SPDX-JSON format listing all Go module dependencies included in that build. SBOMs are published as GitHub Release assets.

### Download SBOM

```bash
VERSION=v1.14.0
OS=linux
ARCH=amd64

curl -LO https://github.com/kubermatic/kubeone/releases/download/${VERSION}/kubeone_${VERSION#v}_${OS}_${ARCH}.sbom.spdx.json
```

### Inspect SBOM

```bash
# List all dependency packages
jq '.packages[].name' kubeone_1.14.0_linux_amd64.sbom.spdx.json

# Count total dependencies
jq '.packages | length' kubeone_1.14.0_linux_amd64.sbom.spdx.json
```

## Vulnerability Scanning

### Automated Scanning

Every pull request against the `main` branch runs [govulncheck](https://pkg.go.dev/golang.org/x/vuln/cmd/govulncheck), which performs call-graph analysis to detect vulnerabilities in reachable code paths. HIGH and CRITICAL vulnerabilities block merging.

[Dependabot](https://github.com/dependabot) monitors Go module dependencies and opens automated PRs for vulnerable dependency updates.

### Local Scanning

Run govulncheck locally against the KubeOne source:

```bash
go run golang.org/x/vuln/cmd/govulncheck@latest ./...
```

## How Signing Works

KubeOne uses [Sigstore](https://sigstore.dev) keyless signing — no long-lived private keys are stored or managed. The signing identity is bound to the GitHub Actions workflow that produced the release.

At release time:

1. GitHub Actions generates an OIDC token proving the workflow identity
2. Cosign exchanges the OIDC token with Sigstore's [Fulcio](https://github.com/sigstore/fulcio) CA for a short-lived signing certificate
3. The certificate and signature are bundled into the `.sigstore.json` file
4. The signing event is recorded in the [Rekor](https://rekor.sigstore.dev) public transparency log

The `--certificate-identity-regexp` flag in the verification command pins the exact workflow that is permitted to produce valid signatures, preventing any other source from forging a trusted signature.

## Tools

- [Cosign](https://github.com/sigstore/cosign) — Artifact signing and verification
- [Syft](https://github.com/anchore/syft) — SBOM generation
- [govulncheck](https://pkg.go.dev/golang.org/x/vuln/cmd/govulncheck) — Go vulnerability scanner
