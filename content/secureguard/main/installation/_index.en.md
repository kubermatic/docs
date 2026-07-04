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

SecureGuard ships with **OpenBao** (Vault-compatible secret engine), **Dex** (OIDC provider), **ESO**, and **Reloader** (automatic workload restarts on secret changes) as optional Helm sub-charts. Each component can be toggled independently via the Helm values file (`openbao.enabled`, `dex.enabled`, `eso.enabled`, `reloader.enabled`).

{{% notice note %}}
**OpenBao is optional and opinionated.** It's bundled so teams without a vault get a complete stack out of the box, but SecureGuard is **provider-agnostic** — it manages ESO, and ESO supports many backends (AWS Secrets Manager, GCP Secret Manager, Azure Key Vault, HashiCorp Vault, and others). If you already have a secrets backend, disable OpenBao (`--set openbao.enabled=false`) and point your `SecretStore`s at your provider. Dex is similarly optional if you already run an OIDC provider.
{{% /notice %}}

## Prerequisites
- A Kubernetes cluster (v1.27 or newer recommended)
- `helm` v3 CLI installed

## Deployment Modes

SecureGuard's Helm chart bundles all necessary Custom Resource Definitions (CRDs) and sub-chart dependencies (OpenBao, Dex, ESO, Reloader).

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
talk to any of its [supported providers](https://external-secrets.io/latest/introduction/stability-support/).
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
If your target clusters already have the External Secrets Operator installed and managed by another platform team, disable the bundled ESO sub-chart. The dashboard and proxy still work with the existing ESO installation — SecureGuard simply skips installing its own.

```bash
helm install secureguard oci://quay.io/kubermatic/helm-charts/secureguard \
  --namespace secureguard-system \
  --create-namespace \
  --set eso.enabled=false
```

*Note: This only disables the ESO sub-chart. Dex and OpenBao still deploy according to their own toggles (`dex.enabled`, `openbao.enabled`) — combine flags as needed for your environment. The [SG Agent]({{< ref "../architecture/" >}}) also auto-discovers externally installed ESO instances on managed clusters and surfaces them read-only in the dashboard.*

---

## What the Chart Deploys (and Wires Up)

Beyond installing the components, the chart performs several pieces of automation worth knowing about:

| Component / behaviour | Value | Default |
|---|---|---|
| Dashboard UI + backend proxy | (always deployed) | — |
| Dex OIDC provider | `dex.enabled` | `true` |
| OpenBao | `openbao.enabled` | `true` |
| External Secrets Operator | `eso.enabled` | `true` |
| Reloader (workload restarts) | `reloader.enabled` | `false` |
| **SG Agent Controller** (multi-cluster ESO lifecycle, heartbeats) | `sgAgent.enabled` | **`false`** |
| **Federation broker** (cross-cluster secret serving) | `federation.enabled` | **`false`** |

{{% notice note %}}
The **SG Agent** and **Federation** are opt-in. Without `sgAgent.enabled=true` there are no ESODeployment reconciliation, heartbeats, or ESO auto-discovery — the related dashboard pages stay empty. See [Multi-Cluster Deployments]({{< ref "../advanced-configuration/#multi-cluster-deployments" >}}) and the [Federation guide]({{< ref "../federation/" >}}).
{{% /notice %}}

**Automatic wiring** (each can be disabled):

- **Session secret** — `auth.sessionSecret` is auto-generated on first install and kept stable across upgrades if left empty. Set it explicitly when running multiple releases that must share sessions.
- **Dex → OpenBao login** (`openbao.oidc.enabled`, default `true`) — a post-install Job configures OpenBao's OIDC auth method so users can log in to the OpenBao UI with the same Dex identity.
- **Kubernetes auth for ESO** (`openbao.kubernetesAuth.enabled`, default `true`) — a post-install Job enables OpenBao's `kubernetes` auth method and creates the `eso-role` bound to the ESO ServiceAccount.
- **Default ClusterSecretStore** (`eso.vaultSecretStore.enabled`, default `true`) — when both ESO and OpenBao are enabled, the chart creates a ready-to-use `ClusterSecretStore` named `openbao-backend` pointing at the bundled OpenBao (KV v2).
- **Projected SA tokens** — `serviceAccount.tokenExpirationSeconds` (default `3600`) controls the lifetime of the proxy/agent tokens; the kubelet rotates them automatically.

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

When moving to production, several configurations MUST be applied to ensure a secure, resilient platform. This section covers the availability-oriented settings; for the full security checklist (authentication, RBAC, container security, CSP), work through the [Security Hardening guide]({{< ref "../security-hardening/" >}}).

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
Ensure that traffic to the SecureGuard dashboard, the proxy, and OpenBao is encrypted via TLS. The chart provides **three independent ingress blocks**: `ingress` (dashboard + proxy), `dexIngress` (Dex, exposed at `/dex` on the dashboard host), and `openbaoIngress` (OpenBao UI/API on its own hostname). Configure Ingress annotations to use a tool like cert-manager for automatic certificate provisioning.

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

{{% notice tip %}}
The chart ships a `values-production.yaml` with a production-oriented starting point: 2 replicas, ingress + TLS enabled, NetworkPolicies and PodDisruptionBudgets on, OpenBao with persistent data/audit storage, and required-secret placeholders (`auth.sessionSecret`, `auth.oidc.clientSecret`). Use it as the base for your own values file.
{{% /notice %}}

### Tenant Isolation
For multi-tenant environments, the recommendation is deploying distinct secrets management vaults to limit the blast radius. You can deploy multiple, namespace-scoped instances of OpenBao behind the SecureGuard dashboard, isolating teams at the infrastructure level. For lighter-weight, policy-level isolation within a single instance, OpenBao's namespace feature is an alternative — see [OpenBao Basics]({{< ref "../openbao-basics/" >}}).

### OpenBao UI Exposure
The bundled OpenBao ships with its web UI enabled. In production, either serve it only via an authenticated, TLS-terminated ingress (`openbaoIngress`) or disable it entirely:

```yaml
openbao:
  ui:
    enabled: false
```

---

## RBAC, Network Policies & Resource Limits

The SecureGuard Helm chart includes templates for RBAC, network policies, and resource limits. These are critical for production deployments.

### RBAC

The chart provisions a dedicated `ServiceAccount`, `ClusterRole`, and `ClusterRoleBinding` for each component. The proxy's ClusterRole deliberately grants **no standing read access** to ExternalSecrets, SecretStores, or Secrets: every Kubernetes API request is impersonated as the logged-in user, so what each user can see and do is governed by the RBAC bound to *their* user/groups — not by the proxy's own permissions. The proxy itself holds only the `impersonate` verb plus narrow bookkeeping permissions (SGAgent registration and per-cluster kubeconfig Secret access). See [User Authorization]({{< ref "../advanced-configuration/#user-authorization-rbac-via-impersonation" >}}) and [RBAC Configuration]({{< ref "../security-hardening/#rbac-configuration" >}}).

```yaml
serviceAccount:
  create: true
  # Set to false and provide `name` if you manage the ServiceAccount externally
```

### Network Policies

The chart includes optional `NetworkPolicy` resources that restrict ingress and egress traffic to the SecureGuard components. Enable these in production to limit the blast radius of a potential compromise:

```yaml
networkPolicy:
  enabled: true
  # Restricts proxy ingress to the Ingress controller
  # Restricts proxy egress to the Kubernetes API server and OpenBao
```

For the full policy details and a custom-policy example, see [Security Hardening → Network Policies]({{< ref "../security-hardening/#network-policies" >}}).

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
