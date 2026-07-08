+++
title = "Advanced Configuration"
date = 2026-06-13T09:00:00+02:00
weight = 7
description = "Enterprise configuration for SecureGuard — custom OIDC identity providers, RBAC via impersonation, multi-cluster deployments, the ESO version catalog, and short-lived remote tokens."
+++

For enterprise environments, SecureGuard offers extensive configuration options targeting High Availability (HA), advanced authentication, and multi-cluster setups.

## Custom Identity Providers (OIDC via Dex)

By default, the `dex` component included in the SecureGuard Helm chart provisions a static mock user for local testing. In a production environment, you must configure Dex to federate authentication to your organization's primary Identity Provider (IDP).

Dex supports multiple connectors, including:
- GitHub
- Google
- LDAP / Active Directory
- SAML 2.0
- Generic OIDC (Okta, Auth0, Keycloak)

### Example: Configuring a GitHub Connector

To enable GitHub login for developers, update the `dex.config` section of your `values-production.yaml`.

```yaml
dex:
  config:
    issuer: https://dex.secureguard.yourcompany.com
    connectors:
    - type: github
      id: github
      name: GitHub
      config:
        clientID: $GITHUB_CLIENT_ID
        clientSecret: $GITHUB_CLIENT_SECRET
        redirectURI: https://dex.secureguard.yourcompany.com/callback
        orgs:
        - name: your-github-org
```
*Note: You must create an OAuth application in GitHub to obtain the Client ID and Secret, and ensure the `redirectURI` matches your Dex ingress.*

## User Authorization (RBAC via Impersonation)

Authentication is **mandatory** in SecureGuard, and authorization is delegated entirely to Kubernetes RBAC. The backend proxy authenticates to the Kubernetes API as its own service account and then **impersonates the logged-in user** on every request, using two headers derived from the user's OIDC token:

- `Impersonate-User` ← the `email` claim
- `Impersonate-Group` ← each entry in the `groups` claim

This means **what a user can see and do in the dashboard is exactly what their Kubernetes RBAC allows** — no more, no less. The proxy's own service account is *not* a backdoor: it only holds the `impersonate` verb plus the narrow permissions its controller/agent paths need. Any `Impersonate-*` headers supplied by the browser are stripped before the proxy sets its own, so a user cannot escalate by spoofing an identity.

{{% notice warning %}}
**Consequence:** a freshly authenticated user who has **no** RBAC bindings will be able to log in but will receive `403 Forbidden` from the API server for every resource. You must grant access explicitly, as shown below.
{{% /notice %}}

### Prerequisites

1. **Dex must emit a `groups` claim.** Group-based RBAC only works if your connector is configured to return groups (e.g. GitHub `orgs`/`teams`, an LDAP `groupSearch`, or an OIDC `groups` scope). Without it, bind roles to individual user emails instead.
2. **The proxy service account needs the `impersonate` verb** on `users` and `groups`. The bundled Helm chart already includes this rule:
   ```yaml
   - apiGroups: [""]
     resources: ["users", "groups"]
     verbs: ["impersonate"]
   ```

### Example: read-only access for a team (group-based)

Grant everyone in the `platform-engineers` OIDC group cluster-wide read access to ESO resources:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: secureguard-viewer
rules:
  - apiGroups: ["external-secrets.io"]
    resources: ["externalsecrets", "secretstores", "clustersecretstores", "pushsecrets"]
    verbs: ["get", "list", "watch"]
  - apiGroups: [""]
    resources: ["namespaces", "events", "secrets"]
    verbs: ["get", "list"]   # secret values are still redacted by the proxy
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: secureguard-viewer-platform-engineers
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: secureguard-viewer
subjects:
  # Group name must match the value Dex puts in the `groups` claim.
  - apiGroup: rbac.authorization.k8s.io
    kind: Group
    name: platform-engineers
```

### Example: namespaced read/write for a single user (email-based)

Grant `alice@yourcompany.com` full control of ESO resources, but only in the `payments` namespace:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: secureguard-editor
  namespace: payments
rules:
  - apiGroups: ["external-secrets.io"]
    resources: ["externalsecrets", "secretstores", "pushsecrets"]
    verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
  - apiGroups: [""]
    resources: ["events", "secrets"]
    verbs: ["get", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: secureguard-editor-alice
  namespace: payments
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: secureguard-editor
subjects:
  # User name must match the value Dex puts in the `email` claim.
  - apiGroup: rbac.authorization.k8s.io
    kind: User
    name: alice@yourcompany.com
```

### Verifying a user's effective access

Use `kubectl auth can-i` with `--as` / `--as-group` to confirm a binding behaves as expected before the user logs in — this mirrors exactly what the proxy does:

```bash
# As the user (email claim)
kubectl auth can-i list externalsecrets.external-secrets.io \
  --namespace payments --as alice@yourcompany.com

# As a group member (groups claim)
kubectl auth can-i list secretstores.external-secrets.io \
  --as-group platform-engineers
```

If these return `no`, the user will see `403` errors in the dashboard until the appropriate Role/ClusterRole binding is created.

## Multi-Cluster Deployments

A central principle of SecureGuard is centralized governance. You deploy the core SecureGuard stack (OpenBao, Dex, Dashboard, Proxy) in a central "Management" cluster, and use the **SG Agent Controller** to manage ESO lifecycle on "Target" clusters.

### Architecture Overview

1.  **Management Cluster**: Runs OpenBao, SecureGuard Dashboard, Backend Proxy, SG Agent Controller, and Dex.
2.  **Target Clusters**: Run the External Secrets Operator (ESO), deployed and managed by the SG Agent Controller via `ESODeployment` CRDs.

{{% notice warning %}}
**RBAC is per-cluster and impersonated — a user needs bindings on _every_ cluster they touch, including targets.** The proxy impersonates the logged-in user on the API server of whichever cluster a request targets (see [User Authorization](#user-authorization-rbac-via-impersonation)). A user who is bound on the management cluster but has **no** Role/ClusterRole binding on a target cluster can select that cluster in the dashboard but sees only `403 Forbidden` for its ExternalSecrets, SecretStores, and Secrets. Create the equivalent bindings for the user/groups on each target cluster — the management-cluster binding does not carry over.
{{% /notice %}}

### Automated Multi-Cluster Setup (ESODeployment)

The SG Agent Controller automates ESO deployment to target clusters. Create an `ESODeployment` resource on the management cluster:

```yaml
apiVersion: deploy.secureguard.io/v1alpha1
kind: ESODeployment
metadata:
  name: eso-prod-cluster
  namespace: secureguard-system
spec:
  targetCluster: prod-us-east
  esoVersion: v2.6.0
  scope: cluster
  ha:
    enabled: true
    replicas: 2
  rbac:
    createClusterRoles: true
    createRoleBindings: true
```

The controller will:
1. Connect to the target cluster using the per-cluster kubeconfig Secret
2. Deploy ESO with the specified version and configuration
3. Monitor the deployment status and report back via the `ESODeployment` status field

{{% notice note %}}
**Only ESO 2.x is supported.** `esoVersion` must be `v2.0.0` or newer; the end-of-life 0.x line is no longer offered. The set of versions the dashboard presents is driven by the **ESO Version Catalog** (see below), not a hardcoded list.
{{% /notice %}}

### Conflict Detection

The agent validates every ESODeployment against the others targeting the same effective cluster and reports violations as a `Conflict` condition (also shown as a printer column in `kubectl get esodeployments`):

| Conflict | Severity | Meaning |
|---|---|---|
| `MultipleClusterScope` | Error (blocking) | Two cluster-scoped ESO installations on one cluster |
| `NamespaceOverlap` | Error (blocking) | Two namespaced deployments claim the same namespace |
| `ClusterScopeCoversNamespaced` | Warning (advisory) | A cluster-scoped deployment already covers a namespaced one |

Blocking conflicts keep the resource in the `Error` phase until resolved. The dashboard's create/edit form runs the same checks client-side, so most conflicts are caught before the resource is ever submitted.

### Discovery of Externally Installed ESO

Every 60 seconds the agent scans connected clusters for ESO installations it does not manage (e.g. installed directly by another team). Each one is represented as a **read-only** ESODeployment named `eso-ext-<cluster>` with `managementMode: external` and phase `Discovered`, recording the discovered image and replica count. SecureGuard never modifies external installations — the CRs exist so the dashboard reflects reality and conflict detection can take them into account.

### ESO Version Catalog (ESOVersion CRD)

The ESO versions offered in the dashboard's ESODeployment create/edit form are
**not hardcoded** — they are sourced from cluster-scoped `ESOVersion` resources
(`deploy.secureguard.io/v1alpha1`). This lets operators curate which ESO releases
are available per environment without rebuilding the dashboard: add a release by
applying a CR, retire one by setting `deprecated: true`.

```yaml
apiVersion: deploy.secureguard.io/v1alpha1
kind: ESOVersion
metadata:
  name: v2-6-0          # cluster-scoped; one CR per release
spec:
  version: v2.6.0        # semver (v2.0.0 or newer); shown in the picker
  latest: true           # marks the recommended/default selection
  deprecated: false      # when true, hidden from new deployments
  releaseDate: "2026-05-04"
  minKubeVersion: "1.23"   # minimum Kubernetes version of the *target* cluster for this ESO release
  notes: Latest stable release.
```

Behaviour in the dashboard:

- The version picker lists every non-`deprecated` `ESOVersion`, sorted newest-first.
- The CR flagged `latest: true` is labelled `(latest)` and used as the default;
  if none is flagged, the newest version wins.
- The proxy exposes this catalog **read-only** (`GET` on `esoversions`); writes
  are rejected by the route allowlist. Curate the catalog with `kubectl apply`
  or via the SG Agent, which holds manage permissions on `esoversions`.

A starter catalog covering `v2.0.0`–`v2.6.0` ships with the SecureGuard release manifests — apply one `ESOVersion` CR per release you want to offer, following the example above. If the catalog is empty or unreachable, the form falls back to the version already set on the resource (so editing existing deployments still works).

### Manual Multi-Cluster Setup

If you prefer to manage ESO installations manually, you can deploy ESO independently and connect target clusters to the central OpenBao:

1.  Ensure the Management OpenBao API (`https://openbao.secureguard.yourcompany.com`) is reachable from the Target cluster nodes.
2.  Configure Kubernetes authentication in OpenBao for the Target cluster. This requires setting up a Kubernetes Auth Role in the central OpenBao instance that trusts the Service Account tokens issued by the Target cluster's API server.
3.  Deploy ESO to the Target Cluster (pin a supported **2.x** release — see the [version catalog](#eso-version-catalog-esoversion-crd)):
    ```bash
    helm install external-secrets external-secrets/external-secrets \
      --namespace external-secrets \
      --create-namespace \
      --version 2.6.0 \
      --set installCRDs=true
    ```
4.  Create a `ClusterSecretStore` in the Target cluster pointing to the Central OpenBao URL.

### Adding Clusters to the Dashboard

Clusters can be added to the SecureGuard dashboard by uploading a kubeconfig file via the UI or the API:

```bash
curl -X POST http://localhost:3001/api/clusters/kubeconfig \
  -F "kubeconfig=@/path/to/target-kubeconfig" \
  -F "registerAgent=true" \
  -F "clusterName=prod-us-east"
```

This creates per-cluster Secrets and optionally registers an SGAgent CR. See the [API Reference]({{< ref "../api-reference/" >}}) for details.

## Proxy Configuration

The backend proxy is configured via environment variables. The Helm chart sets these from your values; the full list below is useful for custom deployments and debugging.

### Environment Variables

| Variable | Default | Description |
|---|---|---|
| `OIDC_ISSUER_URL` | — (**required**) | Dex/OIDC issuer URL — the proxy exits if unset (auth is mandatory) |
| `OIDC_CLIENT_ID` | `secureguard` | OIDC client ID |
| `OIDC_CLIENT_SECRET` | — | OIDC client secret |
| `OIDC_REDIRECT_URI` | `http://localhost:30080/api/auth/callback` | OAuth2 callback URL |
| `DEX_PUBLIC_URL` | — | External Dex URL for browser redirects (when it differs from the in-cluster issuer URL) |
| `SESSION_SECRET` | — (**required**) | Secret for signing session cookies. Must be stable across restarts and shared by all replicas — the proxy refuses to start without it. The Helm chart auto-generates a stable value if `auth.sessionSecret` is left empty |
| `PORT` | `3001` | Proxy listen port |
| `DEFAULT_CONTEXT` | current-context | Default kubeconfig context for `/api/kube/*` |
| `POD_NAMESPACE` | `default` | Namespace watched for per-cluster kubeconfig Secrets |
| `KUBECONFIG` | — | Path to a kubeconfig file (local development only; in-cluster the proxy discovers clusters from labeled Secrets instead) |
| `REMOTE_TOKEN_DIR` | `$TMPDIR/secureguard-tokens` | Writable directory for the rotating per-cluster token files (see below) |
| `ALLOWED_ORIGIN` | unset | Exact origin allowed for cross-origin (CORS) API access. Unset: no CORS headers are sent and browsers enforce the same-origin policy |
| `COOKIE_SECURE` | auto | Force the `Secure` cookie flag on (`true`) or off (`false`); by default it is derived from the redirect URI scheme |
| `LOG_LEVEL` | `info` | Log verbosity: `debug`, `info`, `warn`, or `error` (structured JSON logs on stderr) |

### Route Allowlist

The proxy only forwards Kubernetes API paths explicitly listed in `proxy/internal/proxy/routes.go`. If you add a new CRD and need dashboard access, you must add the corresponding path patterns to the allowlist. See [API Reference — Route Allowlist]({{< ref "../api-reference/#route-allowlist" >}}) for the current list.

### Short-Lived Remote-Cluster Tokens

When you register a remote cluster you upload its kubeconfig, which usually
carries a long-lived (often admin) credential. The proxy **never persists that
credential**. Instead, at registration it replaces it with a short-lived,
self-renewing token so nothing long-lived is ever stored:

1. **Bootstrap (once):** the uploaded credential is used a single time to
   provision a dedicated least-privilege ServiceAccount
   (`secureguard-system/secureguard-remote`) and ClusterRole on the **remote**
   cluster. That ClusterRole grants exactly two things: `impersonate` on
   users/groups (so per-user RBAC still applies), and `create` on its *own*
   `serviceaccounts/token` (scoped by `resourceNames`).
2. **Mint + discard:** an initial bound token is minted via the TokenRequest API.
   The proxy stores only the server URL, CA, and that token — the uploaded
   credential is discarded.
3. **Self-renew:** a background loop renews the token before it expires using the
   remote SA's own `serviceaccounts/token` permission, rewriting a per-cluster
   token file under `REMOTE_TOKEN_DIR`. The proxy transport re-reads the file per
   request. The agent does the same for clusters it talks to.

This RBAC lives on the **remote** cluster and is created programmatically at
registration — it is intentionally **not** part of the management-cluster RBAC
templates. The management-cluster proxy/agent
ServiceAccounts do **not** need `create` on `serviceaccounts/token`, because
their own management-cluster identity is the kubelet-projected token, and all
minting happens against the remote cluster with the remote SA's self-granted
permission.

Minting is unconditional — there is no "store the credential as-is" mode. A
kubeconfig whose credential cannot provision the remote ServiceAccount (for
example a narrowly scoped bearer token) is **rejected at registration**.
Exec-plugin credentials (EKS/GKE/AKS) are the one exception: they are stored
unchanged because client-go rotates them natively, so there is nothing to mint.

The only related Helm knob is the writable scratch directory for the rotating
token files (the container root filesystem is read-only):

```yaml
proxy:
  remoteTokenDir: /var/run/secureguard/tokens
```

{{% notice note %}}
**Recovery window:** because nothing long-lived is stored, an outage longer than the token TTL requires re-registering the cluster. Widen the window by requesting a longer TTL.
{{% /notice %}}

## RBAC and Network Policies

The Helm chart includes templates for RBAC, NetworkPolicies, and PodDisruptionBudgets. Enable them in your values file:

```yaml
# RBAC (enabled by default)
serviceAccount:
  create: true

# Network policies
networkPolicy:
  enabled: true

# Pod Disruption Budget
podDisruptionBudget:
  enabled: true
  minAvailable: 1
```

For detailed RBAC configuration, see the [Security Hardening Guide]({{< ref "../security-hardening/" >}}).

## Storage Backends

The bundled OpenBao deploys as a **3-node integrated-Raft (HA) cluster by default** — each replica keeps its own copy of the data with no external storage dependency. This is the recommended backend for modern deployments.

If your infrastructure team mandates a different backend, OpenBao also supports PostgreSQL, Consul, or cloud-specific storage (e.g., AWS DynamoDB, GCP Spanner). Configure it — along with a KMS `seal` stanza for auto-unseal — by editing the `openbao.server.ha.raft.config` HCL block (see [Installation → OpenBao Self-Initialization & Unsealing]({{< ref "../installation/#openbao-self-initialization--unsealing" >}})).

## Monitoring

All SecureGuard Go components expose **Prometheus metrics**:

- **Proxy** — `/metrics` on the main listen port (unauthenticated, no session required):

  | Metric | Type | Description |
  |---|---|---|
  | `secureguard_proxy_requests_total` | counter | Kubernetes API proxy requests by cluster and upstream status code |
  | `secureguard_proxy_upstream_duration_seconds` | histogram | Upstream Kubernetes API request duration by cluster |
  | `secureguard_proxy_allowlist_rejections_total` | counter | Requests rejected by the route allowlist |
  | `secureguard_proxy_secret_redactions_total` | counter | Secret responses redacted before reaching the browser, by kind |
  | `secureguard_proxy_managed_clusters` | gauge | Clusters currently registered |
  | `secureguard_proxy_token_refreshers` | gauge | Active per-cluster short-lived token refreshers |

- **SG Agent** — controller-runtime metrics on `:8082` (`-metrics-addr`), health probes on `:8081` (`-health-addr`).
- **Federation broker** — metrics on `:8080` (`-metrics-addr`), health probes on `:8081` (`-health-addr`), both plaintext and separate from the TLS serving port.

### Scraping with the Prometheus Operator

The Helm chart creates headless metrics Services (`metrics.enabled`, default `true`) and can generate `ServiceMonitor` / `PodMonitor` resources for the Prometheus Operator:

```yaml
metrics:
  enabled: true
  serviceMonitor:
    enabled: true        # requires the monitoring.coreos.com/v1 CRDs
    interval: 30s
    scrapeTimeout: 10s
  # Alternative for setups that scrape pods directly:
  podMonitor:
    enabled: false
```

### Other Observability Signals

- **Pod health**: the proxy exposes `/healthz`; agent and federation expose `/healthz` and `/readyz` on their health ports — all used for liveness/readiness probes.
- **Cluster health**: the `/api/clusters/{id}/health` endpoint checks connectivity to each cluster's API server (surfaced as the status dot in the dashboard).
- **Logs**: all components emit structured JSON logs to stdout/stderr. Verbosity is controlled via `LOG_LEVEL` on the proxy and the `logLevel` Helm values (`sgAgent.logLevel`, `federation.logLevel`).
- **Kubernetes events**: use the Event Stream page in the dashboard or `kubectl get events` for real-time activity.
