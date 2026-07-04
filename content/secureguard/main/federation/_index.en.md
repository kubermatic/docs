+++
title = "Federation — Cross-Cluster Secret Distribution"
date = 2026-06-13T09:00:00+02:00
weight = 8
description = "Serve secret data to many clusters from a central SecureGuard instance over mTLS without exposing the backend secret stores — the federation broker, CRDs, fedclient, and resolution modes."
sitemapexclude = true
searchexclude = true
private = true
+++

Federation lets a central SecureGuard instance serve secret data to many
clusters **without exposing the backend secret stores to those clusters**. The
backend credentials (Vault, AWS, …) live in exactly one place — the federation
cluster — instead of being copied into every consuming cluster.

{{% notice note %}}
**Status:** opt-in and disabled by default. The federation **broker** and CRDs, the first-class **`fedclient`** consumer, and **both resolvers** — the lean Kubernetes-Secret resolver and the live ESO-library resolver (all providers) — are available. See *Resolution modes* below.
{{% /notice %}}

## Architecture

```text
   backend stores (Vault/AWS/…)
            ▲  (only the broker talks to these)
            │
   ┌────────┴─────────┐        pull over mTLS         ┌──────────────────┐
   │ Federation Broker │ ◄──── x-workload-token ───── │ remote ESO        │
   │ (federation/)     │       (SA token)             │ (Webhook provider)│
   └───────────────────┘                              └──────────────────┘
   central cluster: holds backend creds,              remote: holds only a
   NO write-creds to remote clusters                  token; no backend creds
```

Remote clusters **pull** from the broker; the central cluster holds no
write-credentials to any remote. The broker is a **separate trust boundary**
from the zero-knowledge dashboard proxy — its own binary and its own
least-privilege ServiceAccount. It is the only SecureGuard component that
handles real secret values, so it must never be colocated with the proxy.

## Custom Resources

Federation is configured with two cluster-scoped CRDs in the
`federation.secureguard.io/v1alpha1` group. They carry **references and policy
only — never secret values**.

### FederationServer

Declares what the broker exposes and which token issuers it trusts.

```yaml
apiVersion: federation.secureguard.io/v1alpha1
kind: FederationServer
metadata:
  name: default
spec:
  listen:
    port: 8443
    tls:
      secretRef: fed-server-tls          # Secret with tls.crt / tls.key
  trustedIssuers:                          # remote clusters whose SA tokens we accept
    - name: cluster-b
      issuerURL: https://oidc.cluster-b.example/sa
      audiences: [secureguard-federation]
  exposedStores:                           # backend stores the broker may resolve
    - name: prod-vault
      secretStoreRef:
        kind: ClusterSecretStore
        name: vault
        namespace: secrets-hub
```

### FederationAuthorization

A **deny-by-default** policy granting a remote identity read access to specific
stores and key globs. Without a matching policy, every request is denied.

```yaml
apiVersion: federation.secureguard.io/v1alpha1
kind: FederationAuthorization
metadata:
  name: allow-cluster-b-app
spec:
  identity:
    kubernetes:
      issuer: cluster-b
      serviceAccount: app/eso-fetcher     # namespace/name on the remote cluster
  allow:
    - store: prod-vault
      keys:
        - db/*                             # path.Match globs; "**" matches any depth
        - api/stripe
```

Sample manifests live in [`k8s/samples/federation/`](https://github.com/kubermatic/secureguard/blob/main/k8s/samples/federation/).

## Deploying the broker

The broker ships as the `federation/` module and is deployed via the Helm
chart, **disabled by default**:

```yaml
# values.yaml
federation:
  enabled: true
  serverName: default
  tls:
    secretName: fed-server-tls            # REQUIRED: server cert/key
  # mtls:
  #   clientCASecret: fed-client-ca       # optional: require client certs
  audiences: secureguard-federation
```

The broker runs under the dedicated `secureguard-federation` ServiceAccount
(read of the federation CRs, `tokenreviews:create`, and — for the interim
resolver — `secrets:get` in its hub namespace).

## Wire contract

```text
POST /secretstore/{store}/secrets/{secretName}
  header  x-workload-token: <projected SA token>
  body    {"remoteRef": {"key": "...", "property": "..."}}
  -> 200  {"value": "..."}  | 401 | 403 | 404
```

The broker authenticates the token via **per-issuer OIDC** (see below), evaluates
the request against `FederationAuthorization` (deny-by-default), resolves the
secret, and returns it. Client-supplied identity headers (`Impersonate-*`,
`X-Forwarded-*`) are stripped to prevent spoofing. Every serve and denial is
audited (principal + reference only — never the value).

### Authentication — per-issuer OIDC

Each remote cluster is its own OIDC issuer (its API server publishes
`/.well-known/openid-configuration` + a JWKS endpoint for its ServiceAccount
token signer). For every request the broker:

1. reads the token's `iss` claim and matches it to a `FederationServer`
   `trustedIssuers[]` entry;
2. fetches that issuer's JWKS (cached, auto-refreshed) and **cryptographically
   verifies** the token's signature, `exp`, and that its `aud` contains one of
   the issuer's `audiences` (falling back to the broker's default audience);
3. maps the token `sub` (`system:serviceaccount:<ns>:<name>`) to the identity
   `<ns>/<name>` and attributes it to the matched issuer's `name` (which
   `FederationAuthorization.identity.kubernetes.issuer` references).

Because verification uses only each issuer's **public** keys, the broker holds
**no credentials to any remote cluster** and supports arbitrarily many distinct
issuers. Configure them on the FederationServer:

```yaml
spec:
  trustedIssuers:
    - name: cluster-b
      issuerURL: https://oidc.cluster-b.example   # OIDC discovery base URL
      audiences: [secureguard-federation]
      # caBundle: <base64 PEM>                     # see "Private-CA issuers" below
```

Requirements: each remote must expose OIDC discovery reachable from the broker,
and remote pods must mint projected tokens with `aud: secureguard-federation`
(the fedclient and webhook templates already do).

#### Private-CA issuers (`caBundle`)

Discovery uses the system root CAs by default (and `http://` issuers via an
insecure-issuer context for dev). For an issuer served behind a private CA —
e.g. a cluster's own API-server SA issuer (`https://kubernetes.default.svc…`) —
set `trustedIssuers[].caBundle` to the issuer's CA (base64 PEM); the broker uses
it to verify TLS to the discovery + JWKS endpoints:

```yaml
spec:
  trustedIssuers:
    - name: cluster-b
      issuerURL: https://kubernetes.default.svc.cluster.local
      audiences: [secureguard-federation]
      caBundle: <base64 PEM CA bundle>
```

For a cluster's API-server issuer, the CA is its `kube-root-ca.crt` ConfigMap,
and the broker's anonymous discovery requests need the
`system:service-account-issuer-discovery` ClusterRole granted (e.g. to
`system:unauthenticated`).

## Consuming from a remote cluster (stock ESO)

A stock, open-source ESO can pull from the broker using its built-in
**Webhook provider** — no SecureGuard or enterprise components on the remote.

```yaml
# On the REMOTE cluster — a SecretStore that calls the broker.
apiVersion: external-secrets.io/v1
kind: ClusterSecretStore
metadata:
  name: secureguard-federation
spec:
  provider:
    webhook:
      url: "https://federation.central.example:8443/secretstore/prod-vault/secrets/{{ .remoteRef.key }}"
      method: POST
      headers:
        Content-Type: application/json
        x-workload-token: "{{ .token }}"            # from the secret ref below
      body: '{"remoteRef":{"key":"{{ .remoteRef.key }}"}}'
      result:
        jsonPath: "$.value"                          # extract {"value": "..."}
      secrets:
        - name: token
          secretRef:
            name: federation-token                   # holds the SA token
            key: token
      caBundle: <base64 broker CA>                   # trust the broker's TLS
---
apiVersion: external-secrets.io/v1
kind: ExternalSecret
metadata:
  name: db-creds
  namespace: app
spec:
  secretStoreRef:
    kind: ClusterSecretStore
    name: secureguard-federation
  target:
    name: db-creds
  data:
    - secretKey: password
      remoteRef:
        key: db/creds
```

### Authentication trade-off

The Webhook provider sends a token from a referenced `Secret`, so this MVP path
uses a **bearer ServiceAccount token** rather than a short-lived projected
token minted per request. Mint a scoped token for the `app/eso-fetcher`
ServiceAccount and store it in the `federation-token` Secret; rotate it
regularly. For the stronger, rotating-token path, use the first-class client
below. Prefer **mTLS** (`federation.mtls.clientCASecret`) where you need
stronger transport auth today.

## Consuming with the first-class client (fedclient)

`fedclient` is the consumer that uses a **short-lived, kubelet-rotated projected
ServiceAccount token** — audience-bound, with nothing persisted in the process.
It reads the token fresh from a mounted projected-token volume on every request,
so rotation is automatic and requires no extra RBAC or TokenRequest calls.

Run it as an init container (or sidecar) that fetches the secret into a shared
in-memory volume the app reads:

```yaml
initContainers:
  - name: fetch-secret
    image: quay.io/kubermatic/secureguard-fedclient:v0.2.0   # pin to a release tag, never :latest
    args:
      - --server=https://federation.central.example:8443
      - --store=prod-vault
      - --key=db/creds
      - --property=password
      - --ca=/etc/federation/ca/ca.crt
      - --output=/secrets/db-password
    volumeMounts:
      - { name: federation-token, mountPath: /var/run/secrets/federation, readOnly: true }
      - { name: federation-ca, mountPath: /etc/federation/ca, readOnly: true }
      - { name: secrets, mountPath: /secrets }
volumes:
  - name: federation-token
    projected:
      sources:
        - serviceAccountToken:
            audience: secureguard-federation   # must match the broker/authz
            expirationSeconds: 3600
            path: token
```

Full example: [`docs/examples/fedclient-sidecar.yaml`](https://github.com/kubermatic/secureguard/blob/main/docs/examples/fedclient-sidecar.yaml).
`fedclient` exits with a [distinct code per broker outcome](#cli-reliability-version-retries-exit-codes)
and never logs the token or the secret value; it can also be used as a one-shot
CLI for debugging (`--insecure` for dev TLS).

This is preferable to the Webhook bearer-token path because the token is
short-lived and rotated, and is the recommended consumer for clusters where you
can run the client. The library lives in `federation/internal/client` and can be
embedded directly.

### Off-cluster: CI pipelines, VMs, laptops, non-K8s containers

The projected-token volume above is rotated by the **kubelet**, so it only
exists inside a pod. Off cluster there is no kubelet to refresh it — a token read
from a file simply expires and the broker starts returning `401`. For those
environments `fedclient` can **mint and renew the token itself** via the
Kubernetes TokenRequest API (`--token-source=kube`), so it stays valid without a
kubelet. It needs only:

1. network access to an API server where the consuming ServiceAccount lives
   (selected via `--kubeconfig`/`--context`, or the default `KUBECONFIG`/
   `~/.kube/config`), and
2. RBAC allowing the kubeconfig's bootstrap credential to mint that SA's token —
   `create` on the `serviceaccounts/<name>/token` subresource.

The minted token is audience-bound (`--audience`, default
`secureguard-federation`), short-lived (`--token-ttl`, default `1h`), held only
in memory, and re-minted within its refresh window. As today, the broker's
cluster must trust the SA's token issuer (the same prerequisite as the projected
path).

```bash
# Laptop / CI: one-shot fetch, minting a short-lived token via TokenRequest.
fedclient \
  --server=https://federation.central.example:8443 \
  --store=prod-vault --key=db/creds --property=password \
  --ca=./broker-ca.crt \
  --token-source=kube \
  --token-sa=app/eso-fetcher \
  --audience=secureguard-federation \
  --output=./db-password
```

The minimal RBAC for the bootstrap credential the kubeconfig authenticates as:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: fedclient-mint-token
  namespace: app
rules:
  - apiGroups: [""]
    resources: ["serviceaccounts/token"]
    resourceNames: ["eso-fetcher"]
    verbs: ["create"]
```

**CI pipelines** usually inject a short-lived token as a masked secret instead of
a kubeconfig. Use the static source, reading the value from an env var so it
never appears in `argv` or logs:

```bash
fedclient ... --token-source=static --token-env=FED_TOKEN
```

**Long-running hosts** (a VM daemon or a non-Kubernetes container) keep the
secret current with `--watch`: `fedclient` re-fetches on an interval and renews
the minted token in the background, shutting down cleanly on `SIGINT`/`SIGTERM`.

```bash
fedclient \
  --server=https://federation.central.example:8443 \
  --store=prod-vault --key=db/creds --property=password \
  --ca=/etc/federation/ca.crt \
  --token-source=kube --token-sa=app/eso-fetcher \
  --watch --interval=10m \
  --output=/run/federation/db-password
```

| Source              | Renewal                                  | Use it for                                       |
| ------------------- | ---------------------------------------- | ------------------------------------------------ |
| `file` (default)    | kubelet rotates the projected-token file | In-pod init container / sidecar                  |
| `kube`              | self-mints via TokenRequest, in process  | CI with a kubeconfig, VMs, laptops, non-K8s hosts |
| `static`            | none (inject a fresh token each run)     | CI with a short-lived token secret               |

### CLI reliability: version, retries, exit codes

`fedclient --version` prints the build version (injected at build time) and exits
`0`.

For flaky networks (CI runners, NAT gateways) the one-shot path can retry
transient failures with capped exponential backoff. Retries are **opt-in**
(`--retries=0` by default) and only apply to transient errors — `401`/`403`/`404`
are deterministic and never retried. In `--watch` mode the same retry policy
covers the initial fetch so a flaky start does not abort a long-running sidecar.

```bash
fedclient ... --retries=5 --retry-delay=2s   # 1 initial try + up to 5 retries
```

The process exit code distinguishes the broker outcome so scripts can branch
without parsing stderr:

| Exit code | Meaning                                                        |
| --------- | -------------------------------------------------------------- |
| `0`       | success (also `--version` / `--help`)                          |
| `1`       | configuration, TLS, network, `5xx`, or any other error         |
| `11`      | `401` Unauthenticated — token invalid, expired, or wrong audience |
| `13`      | `403` Forbidden — no `FederationAuthorization` for this identity/key |
| `14`      | `404` Not Found — unknown store or key                         |

## Resolution modes

The broker selects a resolver via the image it runs (chosen with
`federation.eso.enabled` in the chart). Both satisfy the same `Resolver`
interface — the wire contract and auth are identical.

- **Interim — Kubernetes-Secret (default image, `secureguard-federation`):**
  serves values from Kubernetes Secrets that already exist on the hub cluster
  (e.g. materialized by a central ESO). The `secretStoreRef.namespace` is the
  lookup namespace and the request key is the Secret name. Lean image, no ESO
  dependency.
- **Live — ESO providers (`secureguard-federation-eso`):** imports **all** ESO
  providers and resolves on demand directly against the backend (Vault/AWS/GCP/…)
  with **nothing at rest**. The broker reads the ESO `SecretStore`/
  `ClusterSecretStore` named by each `exposedStores[].secretStoreRef`, builds the
  provider client, and fetches the secret per request. Enable with:

  ```yaml
  federation:
    enabled: true
    eso:
      enabled: true   # runs the -eso image + grants the ESO read RBAC
    tls: { secretName: fed-server-tls }
  ```

  Trade-offs: the `-eso` image is large (every provider SDK → bigger CVE
  surface — built and scanned separately from the lean images), and it grants
  the broker **cluster-wide read of ESO stores + their auth Secrets** (a real
  privilege increase; see [Security note](#security-notes)). It lives in its own
  Go module (`federation/resolve-eso`) so the default broker stays ESO-free.
  The ESO source is vendored as a pinned git submodule (currently **v2.6.0**);
  providers compile in via the `all_providers` build tag.

## Security notes

- The broker handles real secret values and is isolated from the
  zero-knowledge proxy — never colocate them.
- Authorization is deny-by-default; scope `allow[].keys` as tightly as possible.
- Enable etcd encryption-at-rest and treat the federation cluster as a hardened
  tier.
- No secret values are logged, cached, or persisted; audit logs record
  references only.
