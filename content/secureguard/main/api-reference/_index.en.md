+++
title = "API Reference"
date = 2026-06-13T09:00:00+02:00
weight = 13
description = "REST API of the SecureGuard backend proxy — authentication endpoints, cluster management, the Kubernetes API proxy, the route allowlist, and error semantics."
+++

The SecureGuard backend proxy exposes a REST API that mediates **all** Kubernetes API access. The dashboard communicates exclusively with these endpoints — the browser never contacts the Kubernetes API server directly. The same endpoints can be used for scripted integrations (e.g. registering clusters from CI).

## Base URL

| Environment | URL |
|---|---|
| Local development | `http://localhost:3001` |
| In-cluster (via Service) | `http://secureguard-proxy:3001` |
| Production (via Ingress) | `https://secureguard.yourdomain.com/api` |

## Health & Metrics

### `GET /healthz`

Unauthenticated health check, used for liveness/readiness probes.

```json
{ "status": "ok" }
```

### `GET /metrics`

Unauthenticated Prometheus metrics endpoint (scraped in-cluster). See [Monitoring]({{< ref "../advanced-configuration/#monitoring" >}}) for the metric names and Helm scrape configuration.

## Authentication Endpoints

These endpoints implement the OIDC authorization code flow with PKCE via Dex. They are unauthenticated — they manage their own auth lifecycle.

| Endpoint | Purpose |
|---|---|
| `GET /api/auth/login` | Initiates the OIDC login flow (redirect to Dex with a PKCE code challenge) |
| `GET /api/auth/callback` | Exchanges the authorization code for tokens, verifies the ID token, and stores user info in an HTTP-only session cookie |
| `GET /api/auth/logout` | Clears the session cookie |
| `GET /api/auth/user` | Returns the current user (or `401` with `{"authenticated": false}`) |

**`GET /api/auth/user` response:**

```json
{
  "authenticated": true,
  "user": {
    "email": "user@example.com",
    "name": "User Name",
    "sub": "CgVhZG1pbhIFbG9jYWw",
    "groups": ["admin", "developers"]
  },
  "csrfToken": "kSJ3…"
}
```

The `groups` claim drives impersonation and therefore Kubernetes RBAC.

### CSRF Contract

`csrfToken` is the session's CSRF token. Clients must echo it in the **`X-CSRF-Token`** request header on **all mutating requests** (POST/PUT/PATCH/DELETE) to any protected endpoint. Mutating requests without a matching token are rejected with `403`.

## Cluster Management

All cluster management endpoints require an authenticated session. Mutating endpoints additionally require the `X-CSRF-Token` header.

### `GET /api/clusters`

Lists all registered clusters. `status` is one of `connected`, `disconnected`, or `unknown`; `region` and `environment` are optional.

```json
[
  { "id": "kind-secureguard", "name": "kind-secureguard", "status": "connected" }
]
```

### `GET /api/clusters/{id}/health`

Health-checks a specific cluster by connecting to its Kubernetes API server.

```json
{ "id": "kind-secureguard", "status": "connected" }
```

### `POST /api/clusters/kubeconfig`

Uploads a kubeconfig to register new clusters. Each context becomes a Kubernetes Secret labeled `secureguard.io/cluster-kubeconfig=true`. Persistence is **synchronous**: the endpoint returns `200` only once the per-cluster Secrets are written; on failure the just-added clusters are rolled back and `502` is returned. The uploaded credential itself is never persisted — it is exchanged for a short-lived token at registration (see [Short-Lived Remote-Cluster Tokens]({{< ref "../advanced-configuration/#short-lived-remote-cluster-tokens" >}})).

**Content-Type:** `multipart/form-data`

| Field | Type | Required | Description |
|---|---|---|---|
| `kubeconfig` | file | Yes | The kubeconfig file to upload |
| `registerAgent` | string | No | Set to `"true"` to create an SGAgent CR |
| `clusterName` | string | No | Name for the SGAgent (defaults to the first context) |

```json
{ "contexts": ["cluster-1", "cluster-2"], "agentCreated": true }
```

### `DELETE /api/clusters/{id}`

Deregisters a cluster: deletes the per-cluster Secret and removes the cluster from the in-memory set. The management (default) cluster is protected and cannot be deleted.

```json
{ "deleted": "cluster-id" }
```

## Kubernetes API Proxy

Each proxied request is **impersonated as the logged-in user** (`Impersonate-User` / `Impersonate-Group`), so Kubernetes RBAC governs access. Only paths in the [route allowlist](#route-allowlist) are forwarded; everything else is rejected with `403 Forbidden`.

The allowlist is **query-aware**: streaming requests (`?watch=true`, `?follow=…`) are rejected on all paths — the dashboard polls instead. Mutating proxy requests require the `X-CSRF-Token` header.

| Endpoint | Target |
|---|---|
| `* /api/kube/{path}` | The **default (management) cluster's** API server — the path is forwarded as-is |
| `* /api/clusters/{id}/kube/{path}` | A **specific cluster's** API server, by the ID from `GET /api/clusters` |

**Example:**

```text
GET /api/clusters/prod-us-east/kube/apis/external-secrets.io/v1/externalsecrets
→ proxied to prod-us-east: GET /apis/external-secrets.io/v1/externalsecrets
```

## Route Allowlist

The allowlist is **method-aware**: each path pattern permits only specific HTTP methods. The dashboard is largely read-only — most resources allow `GET` only, and mutating verbs are limited to the few flows the UI actually performs. Notably, Kubernetes `Secret` objects are **read-only** through the proxy.

| API Group | Resource | Methods Allowed |
|---|---|---|
| Core (`v1`) | API discovery (`/api`) | `GET` |
| Core (`v1`) | Namespaces | `GET` (list) |
| Core (`v1`) | Events (cluster-wide & namespaced) | `GET` (list) |
| Core (`v1`) | Secrets (cluster-wide, namespaced & single) | `GET` (read-only) |
| `external-secrets.io/v1` | ExternalSecret | `GET` (list); `GET`/`DELETE`/`PATCH` (single) |
| `external-secrets.io/v1` | SecretStore | `GET` (list & single) |
| `external-secrets.io/v1` | ClusterSecretStore | `GET` (list & single) |
| `external-secrets.io/v1alpha1` | PushSecret | `GET` (list); `GET`/`DELETE` (single) |
| `reloader.external-secrets.io/v1alpha1` | ReloaderConfig (`configs`) | `GET` (list); `GET`/`DELETE` (single) |
| `deploy.secureguard.io/v1alpha1` | ESODeployment | `GET` (cluster list); `GET`/`POST` (namespaced list/create); `GET`/`DELETE`/`PATCH` (single) |
| `deploy.secureguard.io/v1alpha1` | ESOVersion | `GET` (read-only catalog) |
| `agent.secureguard.io/v1alpha1` | SGAgent | `GET` (list) |
| `federation.secureguard.io/v1alpha1` | FederationServer | `GET` (list & single) |
| `federation.secureguard.io/v1alpha1` | FederationAuthorization | `GET` (list & single) |
| `authorization.k8s.io/v1` | SelfSubjectAccessReview | `POST` |

{{% notice note %}}
**Federation CRs are read-only here.** `FederationServer` and `FederationAuthorization` carry references and policy only — never secret values. Secret serving happens in the separate [federation broker]({{< ref "../federation/" >}}), not through this proxy.
{{% /notice %}}

### Secret Value Redaction

All responses containing Kubernetes Secrets (`v1/Secret` or `v1/SecretList`) are intercepted by the proxy. The `.data` and `.stringData` fields have their **values** replaced with `"REDACTED"` while key names are preserved. This is the zero-knowledge guarantee — secret content never reaches the browser, regardless of the caller's RBAC.

## Environment Variables

See the canonical table in [Advanced Configuration → Proxy Configuration]({{< ref "../advanced-configuration/#environment-variables" >}}).

## Cluster Discovery

The per-cluster kubeconfig Secrets (labeled `secureguard.io/cluster-kubeconfig=true`) are the runtime source of truth for cluster membership. Each registered cluster — including the management cluster — is one Secret named `cluster-kc-<cluster-id>` whose `config` data key holds a single-context kubeconfig.

When running in-cluster, the proxy and the agent discover clusters by **watching these Secrets via an informer** scoped to `POD_NAMESPACE`: new registrations and deletions propagate to every replica at runtime, with no pod restart. When `KUBECONFIG` is set (local development), a kubeconfig file is used instead.

## Error Responses

All errors use a consistent JSON format:

```json
{ "error": "Human-readable error message" }
```

| Status Code | Meaning |
|---|---|
| `400` | Bad request (invalid input, malformed kubeconfig) |
| `403` | Forbidden (path not in allowlist, watch/streaming request, missing or invalid CSRF token, insufficient user RBAC, or management cluster deletion) |
| `404` | Cluster not found |
| `502` | Upstream failure (cluster onboarding or per-cluster Secret persistence failed, invalid cluster TLS configuration) |
| `503` | No clusters available |
