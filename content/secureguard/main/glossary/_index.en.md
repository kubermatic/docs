+++
title = "Glossary"
date = 2026-06-13T09:00:00+02:00
weight = 12
description = "Plain-language definitions of every key term used across the SecureGuard documentation — from secrets and vaults to ESO resources, OIDC, and federation."
+++

Plain-language definitions of the terms used throughout the SecureGuard docs.
Skim it once, then refer back whenever a word is unclear. Terms are grouped by
theme; within each group they build on each other.

{{% notice tip %}}
**New to all of this?** Read the four **core ideas** first — Secret, Vault, Sync, and Dashboard — then dip into the rest as needed.
{{% /notice %}}

## Core Ideas (start here)

- **Secret** — Any sensitive value an app needs to run: a password, API key,
  database connection string, token, or TLS certificate. The whole point of
  SecureGuard is to store and deliver these safely.
- **Vault** — A dedicated, encrypted, audited place to store secrets. In
  SecureGuard, the vault is **OpenBao**. Apps never read from the vault
  directly — that's ESO's job.
- **Sync** — The continuous process of copying a secret from the vault into a
  Kubernetes `Secret` and keeping the copy up to date. If the value changes in
  the vault, the synced copy is updated automatically.
- **Dashboard** — SecureGuard's web UI: your "control room" for viewing and
  managing secret syncing. It deliberately **never shows real secret values**
  (you always see `••••••••`).

## The Three Building Blocks

- **OpenBao** — The open-source secrets vault **bundled** with SecureGuard
  (forked from HashiCorp Vault). It encrypts secrets, controls who can read
  them, and logs every access. It is an **opinionated default, not a
  requirement** — you can disable it and use any ESO-supported provider instead.
  See [OpenBao Basics]({{< ref "../openbao-basics/" >}}).
- **ESO (External Secrets Operator)** — The Kubernetes component that pulls
  secrets out of OpenBao (or AWS, GCP, Azure, etc.) and turns them into native
  Kubernetes `Secret` objects, then keeps them in sync. See
  [ESO Basics]({{< ref "../eso-basics/" >}}).
- **SecureGuard** — The dashboard + backend proxy that ties OpenBao and ESO
  together with a safe, easy-to-use management interface.

## Kubernetes Terms

- **Kubernetes** — The system that runs your containerized applications. If
  you're brand new, think of it as the "operating system for your cluster of
  servers."
- **Cluster** — One Kubernetes environment (a group of machines working
  together). SecureGuard can manage many clusters from one dashboard.
- **Namespace** — A folder-like way to divide a cluster into separate areas
  (e.g. `payments`, `frontend`). Most resources live inside a namespace. The
  dashboard's namespace selector filters everything by namespace.
- **Secret (Kubernetes)** — Kubernetes' built-in object for holding sensitive
  data. ESO **creates and updates** these for you from the vault. Apps consume
  them as environment variables or mounted files.
- **CRD (Custom Resource Definition)** — A way to teach Kubernetes about new
  object types beyond its built-ins. `ExternalSecret`, `SecretStore`,
  `PushSecret`, `ESODeployment`, `ESOVersion`, `SGAgent`, `FederationServer`,
  and `FederationAuthorization` are all CRDs.
- **CR (Custom Resource)** — An actual instance of a CRD (e.g. *one specific*
  `ExternalSecret` named `db-creds`).
- **Operator / Controller** — A program that watches CRs and makes the cluster
  match what they describe (a "reconciliation loop"). ESO and the SG Agent are
  controllers.
- **RBAC (Role-Based Access Control)** — Kubernetes' permission system. It
  decides who can see or change which resources. In SecureGuard, *your* RBAC
  determines what you can do in the dashboard.

## ESO Resource Types (what you'll manage in the UI)

- **SecretStore** — Configuration that tells ESO **how to connect** to a vault
  (server URL, auth method, credentials). Namespaced: usable only within its own
  namespace.
- **ClusterSecretStore** — The same idea as a SecretStore, but cluster-wide:
  any namespace can use it.
- **ExternalSecret** — Defines **what to fetch** from a store and **which
  Kubernetes Secret to create** from it. This is the object developers create
  most often.
- **PushSecret** — The reverse direction: takes an existing Kubernetes Secret
  and **pushes it up** into an external provider for safekeeping.
- **ReloaderConfig** — Wires a **notification source** (a Secret/ConfigMap
  change, a cloud event, a Vault audit event, a webhook, or a TCP socket) to a
  **trigger destination** (roll out a Deployment, or reconcile an ExternalSecret
  / PushSecret / WorkflowRunTemplate). Makes secret delivery event-driven instead
  of poll-based. Provided by the bundled **Reloader** companion project.
- **ESODeployment** — Describes how ESO itself should be **installed/upgraded**
  on a target cluster. The SG Agent acts on it.
- **ESOVersion** — One entry in the operator-curated **catalog of ESO releases**
  the dashboard offers when creating an ESODeployment.
- **SGAgent** — Represents a connected cluster's agent and its **heartbeat**
  (is it alive and reporting?).
- **Provider** — The external system a store talks to: OpenBao/Vault, AWS
  Secrets Manager, GCP Secret Manager, Azure Key Vault, and others. SecureGuard
  is provider-agnostic; OpenBao is just the bundled default.
- **`remoteRef` / key / path** — The address of a secret inside the provider
  (e.g. `secret/db/postgres`, key `password`).
- **Refresh interval** — How often ESO re-checks the provider for changes
  (e.g. `1h`). Shorter = fresher, but more requests.

## OpenBao / Vault Terms

- **Secret Engine** — A module inside OpenBao that stores or generates secrets.
  The most common is **KV (Key/Value)** for static secrets.
- **KV v1 vs v2** — Two versions of the Key/Value engine. v2 adds versioning of
  secret values. SecureGuard's samples use KV v2 mounted at `secret/`.
- **Auth Method** — How a user or machine proves its identity to OpenBao. ESO
  uses the **Kubernetes** auth method (it presents a ServiceAccount token).
- **Sealing / Unsealing** — A sealed OpenBao knows where its encrypted data is
  but **can't decrypt it** until it's "unsealed" with the master key. By default
  SecureGuard **self-initializes** OpenBao: the chart runs `operator init`,
  unseals every node, and stores the Shamir key shares in the
  `<release>-openbao-keys` Secret (back it up). For restart-resilient production,
  use **KMS Auto-Unseal** (e.g. AWS KMS) so pods unseal themselves on restart.
  See [OpenBao Basics]({{< ref "../openbao-basics/" >}}).
- **Dynamic Secrets** — Credentials OpenBao generates on demand with a built-in
  expiry (TTL), instead of storing a static value.
- **Audit Device** — OpenBao's logging of every read/write, for compliance.
- **Dev mode** — A throwaway OpenBao mode that keeps secrets in memory and
  auto-unseals. Great for testing; **never for production** (data is lost on
  restart).

## Authentication & Security Terms

- **OIDC (OpenID Connect)** — The standard login protocol SecureGuard uses for
  the dashboard. You log in through your identity provider rather than a local
  password.
- **Dex** — A small identity service bundled with SecureGuard that speaks OIDC
  and can connect to GitHub, Google, LDAP, Okta, etc. It's the dashboard's
  "login broker."
- **IdP (Identity Provider)** — Your organization's source of user accounts
  (e.g. Google Workspace, GitHub, Active Directory). Dex federates to it.
- **PKCE** — A security add-on to the OIDC login flow that prevents stolen
  login codes from being reused. Handled automatically.
- **Session cookie** — A short-lived, HTTP-only cookie the proxy gives your
  browser after login. It proves you're logged in; it is **not** a secret value.
- **Impersonation** — On every request, the proxy tells Kubernetes "treat this
  as user *alice@example.com* in groups *X, Y*." Kubernetes RBAC then decides
  what's allowed. This is why **your** permissions govern what you see.
- **Zero-knowledge (client)** — The guarantee that the browser/UI **never
  receives real secret values** — they're stripped at the proxy. Hence the
  unconditional `••••••••`.
- **Redaction** — The proxy replacing secret values with `REDACTED`/`••••••••`
  before responses leave the server.
- **Route allowlist** — The fixed list of Kubernetes API paths the proxy is
  willing to forward. Anything not on the list is rejected with `403`.
- **Least privilege** — Giving each component only the permissions it truly
  needs. The proxy and agent run under separate, narrowly-scoped accounts.

## SecureGuard Architecture Terms

- **Backend Proxy** — The Go service that sits between the browser and
  Kubernetes. It logs you in, enforces the route allowlist, and redacts secret
  values. The browser talks **only** to the proxy, never to Kubernetes directly.
- **SG Agent (Agent Controller)** — A controller that installs/upgrades ESO on
  remote clusters (via `ESODeployment`) and reports cluster health (via
  `SGAgent`).
- **Management cluster** — The central cluster running the dashboard, proxy,
  OpenBao, Dex, and the agent.
- **Target / remote cluster** — A cluster managed *from* the management cluster
  (where ESO is deployed and secrets are delivered).
- **Kubeconfig** — A file containing the address and credentials for a cluster.
  You upload one to add a cluster to the dashboard.

## Federation Terms (advanced, optional)

- **Federation** — Letting one central SecureGuard serve secret values to many
  clusters **without** copying the backend credentials into each one. Disabled
  by default. See [Federation]({{< ref "../federation/" >}}).
- **Federation Broker** — The standalone service that actually serves those
  values over mTLS. It's the **only** component that handles real secret values,
  kept isolated from the zero-knowledge proxy.
- **FederationServer / FederationAuthorization** — CRDs that declare what the
  broker exposes and which remote identities may read which keys (deny-by-default).
- **fedclient** — A small client that runs on a remote cluster (or a CI job/VM)
  to fetch a secret from the broker using a short-lived, rotating token.
- **mTLS (mutual TLS)** — TLS where *both* sides present certificates, so the
  broker and client each verify the other.

## Operations Terms

- **Helm / chart / values** — Helm is Kubernetes' package manager; a "chart" is
  the package (SecureGuard ships as one), and a `values.yaml` file holds your
  configuration choices.
- **Sub-chart** — A chart bundled inside another (SecureGuard bundles OpenBao,
  Dex, ESO, and Reloader as optional sub-charts).
- **High Availability (HA)** — Running multiple replicas so the service survives
  a node or pod failure.
- **Raft / Integrated Storage** — OpenBao's built-in clustered storage used for
  HA. The bundled OpenBao runs as a 3-node Raft cluster by default, with no
  external Consul/etcd dependency.
- **Stale secret** — A synced Secret that hasn't refreshed within its expected
  interval — the dashboard flags these so you can investigate.
