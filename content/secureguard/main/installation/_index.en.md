+++
title = "Installation & Deployment"
date = 2026-06-13T09:00:00+02:00
weight = 3
description = "Deploy Kubermatic SecureGuard across managed, bring-your-own-provider, and bring-your-own-ESO modes, with production hardening guidance."
sitemapexclude = true
searchexclude = true
private = true
+++

Kubermatic SecureGuard is designed to be highly flexible, offering several deployment modes depending on your existing infrastructure and production requirements.

SecureGuard ships with **OpenBao** (Vault-compatible secret engine), **Dex** (OIDC provider), and **ESO** as optional Helm sub-charts. Each component can be toggled independently via the Helm values file.

{{% notice note %}}
**OpenBao is optional and opinionated.** It's bundled so teams without a vault get a complete stack out of the box, but SecureGuard is **provider-agnostic** — it manages ESO, and ESO supports many backends (AWS Secrets Manager, GCP Secret Manager, Azure Key Vault, HashiCorp Vault, and others). If you already have a secrets backend, disable OpenBao (`--set openbao.enabled=false`) and point your `SecretStore`s at your provider. Dex is similarly optional if you already run an OIDC provider.
{{% /notice %}}

## Prerequisites
- A Kubernetes cluster (v1.27 or newer recommended)
- `helm` v3 CLI installed

## Deployment Modes

SecureGuard's Helm chart bundles all necessary Custom Resource Definitions (CRDs) and sub-chart dependencies (OpenBao, Dex, ESO).

### 1. Managed (Default)
In this mode, all components are installed automatically by the SecureGuard Helm chart. This is recommended for clusters that do not already have an established secret manager.

```bash
helm install secureguard oci://quay.io/kubermatic/helm-charts/secureguard \
  --namespace secureguard-system \
  --create-namespace
```

- **Dex** provides OIDC authentication.
- **OpenBao** provides a Vault-compatible secret backend (standalone/production mode by default).
- **ESO** manages external secrets, connected to OpenBao via Kubernetes auth.
- **OpenBao UI** will be available by default at `:30820/ui` (NodePort) or via Ingress.

### 2. Bring Your Own Provider (External Vault, AWS, GCP, Azure, …)

You don't have to use the bundled OpenBao. SecureGuard manages ESO, and ESO can
talk to any of its [supported providers](https://external-secrets.io/latest/provider/aws-secrets-manager/).
Disable the bundled OpenBao and point your `SecretStore`/`ClusterSecretStore`
resources at your own backend.

**Example — an existing HashiCorp Vault or OpenBao cluster:**

```bash
helm install secureguard oci://quay.io/kubermatic/helm-charts/secureguard \
  --namespace secureguard-system \
  --create-namespace \
  --set openbao.enabled=false \
  --set openbao.externalUrl=https://my-vault.company.internal:8200
```

**Example — a cloud provider (no vault to deploy at all):**

```bash
helm install secureguard oci://quay.io/kubermatic/helm-charts/secureguard \
  --namespace secureguard-system \
  --create-namespace \
  --set openbao.enabled=false
```

*Note: With any external provider you configure the `SecretStore` resources to
authenticate against that provider (e.g. Kubernetes auth for Vault/OpenBao, IRSA
for AWS, Workload Identity for GCP). The dashboard, proxy, and ESO behave
identically regardless of which provider you choose.*

### 3. Bring Your Own ESO
If your target clusters already have the External Secrets Operator installed and managed by another platform team, you can instruct SecureGuard to deploy only the UI and Proxy, skipping the ESO installation.

```bash
helm install secureguard oci://quay.io/kubermatic/helm-charts/secureguard \
  --namespace secureguard-system \
  --create-namespace \
  --set eso.enabled=false
```

---

## Dev Mode for Testing

By default, OpenBao starts in `standalone` (production-oriented) mode, meaning it writes to persistent storage and requires manual initialization and unsealing.

For local development or testing, you can enable `dev` mode, where secrets are stored in-memory, automatically unsealed, but lost upon restart:

```bash
helm install secureguard oci://quay.io/kubermatic/helm-charts/secureguard \
  --namespace secureguard-system \
  --create-namespace \
  --set openbao.server.dev.enabled=true
```

{{% notice warning %}}
Dev mode is intended only for local testing. Secrets are stored in-memory and will be lost when the pod restarts. Do not use dev mode in production.
{{% /notice %}}

---

## Production Hardening

When moving to production, several configurations MUST be applied to ensure a secure, resilient platform.

### High Availability (HA)

Enable High Availability with Raft integrated storage and increase the replica count (typically 3 or 5).

Example `values-production.yaml` snippet:
```yaml
openbao:
  server:
    ha:
      enabled: true
      replicas: 3
```

### Automatic Unsealing
In production, you should not manually unseal the OpenBao cluster every time a pod restarts. Configure an auto-unseal mechanism such as AWS KMS, GCP KMS, Transit, or Azure Key Vault.

```yaml
openbao:
  server:
    ha:
      enabled: true
      replicas: 3
    seal:
      type: awskms
      config:
        region: eu-west-1
        kms_key_id: "alias/openbao-unseal"
```

### Ingress & TLS
Ensure that traffic to the SecureGuard dashboard, the proxy, and OpenBao is encrypted via TLS. Configure Ingress annotations to use a tool like cert-manager for automatic certificate provisioning.

```yaml
ingress:
  enabled: true
  className: "nginx"
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
  hosts:
    - host: secureguard.yourdomain.com
      paths:
        - path: /
          pathType: ImplementationSpecific
  tls:
    - secretName: secureguard-tls
      hosts:
        - secureguard.yourdomain.com
```

### Tenant Isolation
For multi-tenant environments, the recommendation is deploying distinct secrets management vaults to limit the blast radius. You can deploy multiple, namespace-scoped instances of OpenBao behind the SecureGuard dashboard, isolating teams at the infrastructure level.

---

## RBAC, Network Policies & Resource Limits

The SecureGuard Helm chart includes templates for RBAC, network policies, and resource limits. These are critical for production deployments.

### RBAC

The chart provisions a dedicated `ServiceAccount`, `ClusterRole`, and `ClusterRoleBinding` (see [`k8s/rbac.yaml`](https://github.com/kubermatic/secureguard/blob/main/k8s/rbac.yaml)). The ClusterRole grants the proxy read access to the Kubernetes resources it manages (ExternalSecrets, SecretStores, Secrets, Events, etc.) and nothing more. Review and restrict these permissions further if your deployment does not use all SecureGuard features.

```yaml
rbac:
  create: true
  # Set to false if you manage RBAC externally
```

### Network Policies

The chart includes optional `NetworkPolicy` resources that restrict ingress and egress traffic to the SecureGuard components. Enable these in production to limit the blast radius of a potential compromise:

```yaml
networkPolicy:
  enabled: true
  # Restricts proxy ingress to the Ingress controller
  # Restricts proxy egress to the Kubernetes API server and OpenBao
```

### Resource Limits

Always set resource requests and limits for all SecureGuard components in production. The chart exposes these under each component's `resources` key:

```yaml
proxy:
  resources:
    requests:
      cpu: 100m
      memory: 128Mi
    limits:
      cpu: 500m
      memory: 256Mi

ui:
  resources:
    requests:
      cpu: 50m
      memory: 64Mi
    limits:
      cpu: 200m
      memory: 128Mi
```
