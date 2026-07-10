+++
title = "Installation & Deployment"
date = 2026-06-13T09:00:00+02:00
weight = 3
description = "Deploy Kubermatic SecureGuard across managed, bring-your-own-provider, and bring-your-own-ESO modes, with production hardening guidance."
+++

Kubermatic SecureGuard is designed to be highly flexible, offering several deployment modes depending on your existing infrastructure and production requirements.

SecureGuard ships with **OpenBao** (Vault-compatible secret engine), **Dex** (OIDC provider), **ESO**, and **Reloader** (event-driven rotation — trigger Deployment rollouts or ESO reconciles from Secret/ConfigMap changes, cloud events, or webhooks) as optional Helm sub-charts. Each component can be toggled independently via the Helm values file (`openbao.enabled`, `dex.enabled`, `eso.enabled`, `reloader.enabled`).

{{% notice note %}}
**OpenBao is optional and opinionated.** It's bundled so teams without a vault get a complete stack out of the box, but SecureGuard is **provider-agnostic** — it manages ESO, and ESO supports many backends (AWS Secrets Manager, GCP Secret Manager, Azure Key Vault, HashiCorp Vault, and others). If you already have a secrets backend, disable OpenBao (`--set openbao.enabled=false`) and point your `SecretStore`s at your provider. Dex is similarly optional if you already run an OIDC provider.
{{% /notice %}}

## Prerequisites

A local `kubectl` + `helm` v3 CLI and a Kubernetes cluster (v1.27 or newer
recommended) are the minimum. For any non-local install you also need the
platform pieces below — a bare cluster is **not** enough to reach a working,
TLS-terminated login.

### Cluster & tooling
- A Kubernetes cluster (v1.27 or newer recommended).
- `kubectl` and `helm` v3 CLIs installed and pointed at the cluster.
- **Registry pull credentials** — SecureGuard's images are served from a
  **private** Quay repository. Without a pull secret the pods stay in
  `ImagePullBackOff` and `kubectl describe pod` shows `401 Unauthorized`. Create
  a docker-registry Secret and reference it:
  ```bash
  kubectl create secret docker-registry secureguard-pull \
    --namespace secureguard-system \
    --docker-server=quay.io \
    --docker-username='<robot-user>' \
    --docker-password='<robot-token>'
  ```
  ```yaml
  # values.yaml — reaches the first-party pods (and, via global, OpenBao + ESO)
  imagePullSecrets:
    - name: secureguard-pull
  global:
    imagePullSecrets:
      - name: secureguard-pull
  ```
  See the pull-secret keys in
  [`values.yaml`](https://github.com/kubermatic/secureguard/blob/main/charts/secureguard/values.yaml)
  (`imagePullSecrets`, `global.imagePullSecrets`, and per–sub-chart
  `dex.imagePullSecrets` / `reloader.imagePullSecrets`) for mirrored/air-gapped
  registries.

### Ingress, DNS & TLS (non-local installs)
- **An ingress controller and an `IngressClass`** (e.g. ingress-nginx). Set
  `ingress.className` to a class that exists in the cluster — the chart does not
  install a controller for you.
- **cert-manager plus a `ClusterIssuer`** (or a pre-created TLS Secret). The
  ingress examples below reference `cert-manager.io/cluster-issuer`; that issuer
  must already exist, or certificates never get issued and the browser sees TLS
  errors.
- **Wildcard DNS** for your SecureGuard host(s), pointed at the ingress
  controller's load-balancer address. Dex is served at `/dex` on the dashboard
  host and OpenBao on its own hostname, so a wildcard (e.g.
  `*.secureguard.example.com`) is the simplest fit. See
  [Install Order (DNS & TLS)](#install-order-dns--tls) for the exact sequence.

### Storage (stateful, non-dev installs)
- **A default `StorageClass`** (or an explicit `openbao.server.dataStorage.storageClass`).
  Production OpenBao runs as a Raft HA cluster and each replica needs a
  PersistentVolume; without a usable StorageClass the OpenBao pods stay
  `Pending`.
- **Size the volume up front.** Some StorageClasses (notably AWS EBS `gp2`/`gp3`
  with the default provisioner settings) do **not** support online volume
  expansion, so a PVC created too small cannot be grown in place later — pick a
  headroom-generous `openbao.server.dataStorage.size` at install time, or use a
  StorageClass with `allowVolumeExpansion: true`.

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
- **OpenBao** provides a Vault-compatible secret backend. By default it deploys as a **3-node integrated-Raft HA cluster that is automatically initialized and unsealed** — no manual `operator init`/unseal step is required (see [Self-Initialization](#openbao-self-initialization--unsealing)).
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
| Reloader (event-driven rotation) | `reloader.enabled` | `false` |
| **SG Agent Controller** (multi-cluster ESO lifecycle, heartbeats) | `sgAgent.enabled` | **`false`** |
| **Federation broker** (cross-cluster secret serving) | `federation.enabled` | **`false`** |

{{% notice note %}}
The **SG Agent** and **Federation** are opt-in. Without `sgAgent.enabled=true` there are no ESODeployment reconciliation, heartbeats, or ESO auto-discovery — the related dashboard pages stay empty. See [Multi-Cluster Deployments]({{< ref "../advanced-configuration/#multi-cluster-deployments" >}}) and the [Federation guide]({{< ref "../federation/" >}}).
{{% /notice %}}

**Automatic wiring** (each can be disabled):

- **Session secret** — `auth.sessionSecret` is auto-generated on first install and kept stable across upgrades if left empty. Set it explicitly when running multiple releases that must share sessions.
- **OpenBao self-initialization** (`openbao.init.enabled`, default `true`) — an ordered post-install/upgrade hook Job (weight 0) runs `operator init`, unseals every Raft node, enables the Kubernetes auth method, and creates a chart admin role — then **revokes the root token** (it is never persisted). The Shamir unseal key shares are stored in the `<release>-openbao-keys` Secret. See [Self-Initialization](#openbao-self-initialization--unsealing).
- **Kubernetes auth for ESO** (`openbao.kubernetesAuth.enabled`, default `true`) — a post-install Job (weight 5) configures the KV v2 engine, the ESO read policy, and the `eso-role` bound to the ESO ServiceAccount. Under self-init it authenticates via the chart admin role (no root token exists).
- **Dex → OpenBao login** (`openbao.oidc.enabled`, default `true`) — a post-install Job (weight 10) configures OpenBao's OIDC auth method so users can log in to the OpenBao UI with the same Dex identity, also via the chart admin role.
- **Default ClusterSecretStore** (`eso.vaultSecretStore.enabled`, default `true`) — when both ESO and OpenBao are enabled, the chart creates a ready-to-use `ClusterSecretStore` named `openbao-backend` pointing at the bundled OpenBao (KV v2).
- **Projected SA tokens** — `serviceAccount.tokenExpirationSeconds` (default `3600`) controls the lifetime of the proxy/agent tokens; the kubelet rotates them automatically.

---

## Install Order (DNS & TLS)

On a cloud cluster the ingress load-balancer address only exists **after** the
chart is installed, and cert-manager can only issue a certificate once DNS
resolves to that address. Follow this order for a first install with ingress +
TLS enabled:

1. **Install the chart** with ingress enabled and your hostname(s) set (see the
   [Ingress & TLS](#ingress--tls) values). The dashboard, Dex, and OpenBao come
   up, but TLS is not valid yet.
2. **Read the load-balancer address** the ingress controller was assigned:
   ```bash
   kubectl get ingress -n secureguard-system
   kubectl get svc -n <ingress-controller-namespace> \
     -o jsonpath='{.items[*].status.loadBalancer.ingress[*].hostname}{"\n"}'
   ```
3. **Create the wildcard DNS record** (e.g. `*.secureguard.example.com`)
   pointing at that hostname/IP. Wait for it to propagate.
4. **cert-manager issues `secureguard-tls`.** Once DNS resolves, the ACME
   HTTP-01/DNS-01 challenge completes and the certificate Secret becomes `Ready`:
   ```bash
   kubectl get certificate -n secureguard-system
   ```
5. **Log in** at `https://secureguard.example.com`.

{{% notice info %}}
No component restart is required between these steps. The proxy performs OIDC
discovery against Dex with automatic retry/back-off, so it **self-heals** once
the certificate is issued and Dex becomes reachable over HTTPS — you do not need
to restart the proxy after `secureguard-tls` goes `Ready`.
{{% /notice %}}

---

## Dev Mode for Testing

By default OpenBao runs as a 3-node Raft HA cluster that the chart initializes and unseals for you. For local development or testing you usually don't want three replicas or persistent state — enable `dev` mode instead, where OpenBao runs as a single in-memory node that is automatically unsealed but loses all data on restart:

```bash
helm install secureguard oci://quay.io/kubermatic/helm-charts/secureguard \
  --namespace secureguard-system \
  --create-namespace \
  --set openbao.server.dev.enabled=true
```

{{% notice warning %}}
Dev mode is intended only for local testing. Secrets are stored in-memory and will be lost when the pod restarts. Do not use dev mode in production.
{{% /notice %}}

If you want persistent storage but only a single node (e.g. a small staging cluster), run the standalone `file` backend instead of Raft HA:

```bash
helm install secureguard oci://quay.io/kubermatic/helm-charts/secureguard \
  --namespace secureguard-system \
  --create-namespace \
  --set openbao.server.standalone.enabled=true \
  --set openbao.server.ha.enabled=false
```

{{% notice tip %}}
**Node sizing.** Even the default (non-dev) install schedules a fair number of
pods — dashboard + proxy, Dex, three OpenBao replicas, and the ESO
controller/webhook/cert-controller — plus the init/config hook Jobs. For a
local `kind`/minikube walkthrough, prefer dev mode (single in-memory OpenBao,
no PVCs) on a node with at least ~4 vCPU / 8 GiB free; the full Raft HA default
additionally needs a working `StorageClass` and enough headroom for three
persistent OpenBao replicas.
{{% /notice %}}

---

## Production Hardening

When moving to production, several configurations MUST be applied to ensure a secure, resilient platform. This section covers the availability-oriented settings; for the full security checklist (authentication, RBAC, container security, CSP), work through the [Security Hardening guide]({{< ref "../security-hardening/" >}}).

### High Availability (HA)

High Availability with Raft integrated storage is the **chart default**: OpenBao runs as a 3-node cluster, each replica keeping its own copy of the data (no external Consul/etcd needed). Use an odd replica count (3 or 5) so leader elections always have a quorum, and size the data storage for your secret volume.

```yaml
openbao:
  server:
    ha:
      enabled: true
      replicas: 3       # odd number for quorum
      raft:
        enabled: true
    dataStorage:
      enabled: true
      size: 20Gi
```

### OpenBao Self-Initialization & Unsealing

A freshly deployed OpenBao is **sealed** and must be initialized and unsealed before it can serve secrets. The chart automates this so no manual `operator init`/unseal is required (`openbao.init.enabled`, default `true`):

- A weight-0 post-install/upgrade hook Job runs `operator init` on the leader, unseals every Raft node, bootstraps Kubernetes auth + a chart admin role, and then **revokes the root token** — it is used once in memory and never persisted.
- The Shamir unseal **key shares** are stored in the `<release>-openbao-keys` Secret (`keyShares: 5`, `keyThreshold: 3` by default).

{{% notice warning %}}
**Back up the `<release>-openbao-keys` Secret — immediately after the first install, as a day-one step.** Without the unseal keys you cannot unseal OpenBao and your secrets are unrecoverable. Copy it out of the cluster to your organization's secrets manager / offline escrow (do **not** leave the only copy in the same cluster it protects), then verify you can read it back:

```bash
kubectl get secret <release>-openbao-keys -n secureguard-system -o yaml > openbao-keys.backup.yaml
```

For break-glass admin access (the root token is revoked after init and never persisted), run `bao operator generate-root` using the stored key shares.
{{% /notice %}}

```yaml
openbao:
  init:
    enabled: true        # self-init + unseal (default)
    keyShares: 5
    keyThreshold: 3
    # secretName: ""     # defaults to <release>-openbao-keys
```

**Restart behavior (Shamir seal).** With the default Shamir seal, a pod that restarts comes back **sealed**. The init hook re-unseals every node on each `helm upgrade`; to also re-unseal automatically between upgrades, enable the periodic sweep:

```yaml
openbao:
  init:
    unsealCronJob:
      enabled: true
      schedule: "*/5 * * * *"
```

### Automatic Unsealing with a KMS (higher security)

For the strongest posture — survives restarts with no unseal key shares stored in a Secret — use **KMS auto-unseal** instead of Shamir self-init. Disable the init Job and add a `seal` stanza to the Raft config so OpenBao unseals itself against your cloud KMS on every start:

```yaml
openbao:
  server:
    ha:
      enabled: true
      replicas: 3
      raft:
        enabled: true
        config: |
          ui = true
          listener "tcp" { tls_disable = 1
            address = "[::]:8200" cluster_address = "[::]:8201" }
          storage "raft" { path = "/openbao/data"
            retry_join { leader_api_addr = "http://<rel>-openbao-0.<rel>-openbao-internal:8200" }
            retry_join { leader_api_addr = "http://<rel>-openbao-1.<rel>-openbao-internal:8200" }
            retry_join { leader_api_addr = "http://<rel>-openbao-2.<rel>-openbao-internal:8200" } }
          seal "awskms" {
            region     = "eu-west-1"
            kms_key_id = "alias/openbao-unseal"
          }
          service_registration "kubernetes" {}
  init:
    enabled: false       # KMS unseals automatically; no self-init Job or key-shares Secret
```

OpenBao also supports `gcpckms`, `azurekeyvault`, and `transit` seal types — swap the `seal` stanza accordingly.

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
