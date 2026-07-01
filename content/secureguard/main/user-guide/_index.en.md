+++
title = "User Guide"
date = 2026-06-13T09:00:00+02:00
weight = 6
description = "A feature-by-feature tour of the SecureGuard dashboard — managing ExternalSecrets, stores, push secrets, clusters, and federation from a read-mostly control room."
sitemapexclude = true
searchexclude = true
private = true
+++

This guide walks you through the key features of the SecureGuard dashboard. It assumes you have a running deployment (see [Getting Started]({{< ref "../getting-started/" >}})) and are logged in.

## What the Dashboard Can (and Can't) Do

SecureGuard is, by design, **mostly a read-only "control room."** It is built to
give you safe **visibility** into your secret-syncing setup, plus a few safe
**day-2 operations** — without ever exposing secret values and without turning
the browser into a general-purpose Kubernetes editor.

Most ESO resources (ExternalSecrets, SecretStores, PushSecrets, ReloaderConfigs)
are **created and edited outside the dashboard** — with `kubectl` or your GitOps
tool (Argo CD, Flux) — so they live in version control and code review. The
dashboard then lets you watch, troubleshoot, and run targeted actions on them.

| Resource | View | Create | Edit | Delete | Other actions |
|---|:---:|:---:|:---:|:---:|---|
| **ExternalSecret** | ✅ | — | — | ✅ | **Sync Now** (force a refresh) |
| **SecretStore / ClusterSecretStore** | ✅ | — | — | — | — |
| **PushSecret** | ✅ | — | — | ✅ | — |
| **Kubernetes Secret** | ✅ (masked) | — | — | — | — |
| **ReloaderConfig** | ✅ | — | — | ✅ | — |
| **ESODeployment** | ✅ | ✅ | ✅ | ✅ | Guided create/edit form |
| **Cluster** | ✅ | ✅ (upload kubeconfig) | — | ✅ | Health check |
| **Federation (Server / Authorization)** | ✅ | — | — | — | — |

{{% notice note %}}
**Why so read-only?** Each thing the browser can do must be explicitly allowed by the proxy's [route allowlist](https://github.com/kubermatic/secureguard/blob/main/docs/api-reference.md#route-allowlist). Keeping the surface small is a deliberate security choice — see [Architecture → Security Model]({{< ref "../architecture/#the-security-model" >}}). To create the resources marked "—" above, use `kubectl apply` or GitOps.
{{% /notice %}}

## Dashboard Overview

The Dashboard page provides an at-a-glance view of your secrets management posture:

- **Sync Status Breakdown** — How many ExternalSecrets are synced, pending, or errored
- **Provider Distribution** — Which external secret providers are in use across your stores
- **Recent Sync Errors** — The latest failures with direct links to affected resources
- **Namespace Breakdown** — Resource distribution across namespaces

## Managing ExternalSecrets

### Viewing ExternalSecrets

Navigate to **External Secrets** in the sidebar. The table shows all ExternalSecrets across your selected namespace(s) with:

- **Name** and **Namespace**
- **Sync Status** — `Synced` (green), `Pending` (amber), or `Error` (red)
- **Secret Store** — Which SecretStore or ClusterSecretStore the secret references
- **Last Synced** — Timestamp of the most recent successful sync
- **Refresh Interval** — How often ESO polls the external provider

Click any row to open the detail view, which includes:
- Full resource metadata
- Status conditions with timestamps
- Sync history timeline
- The complete resource as **read-only YAML** (you can copy it, but not edit it here)
- The target Kubernetes Secret (with values displayed as `••••••••`)

### Creating an ExternalSecret

ExternalSecrets are **not** created from the dashboard. Create them with
`kubectl` or your GitOps tool so they stay in version control. A minimal example:

```yaml
apiVersion: external-secrets.io/v1
kind: ExternalSecret
metadata:
  name: db-creds
  namespace: default
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: my-store          # an existing SecretStore/ClusterSecretStore
    kind: SecretStore
  target:
    name: db-creds          # the Kubernetes Secret ESO will create
  data:
    - secretKey: password   # key in the created Secret
      remoteRef:
        key: secret/db/postgres   # path in the provider
        property: password        # field at that path
```

```bash
kubectl apply -f db-creds-externalsecret.yaml
```

Within a few seconds it appears in the dashboard's **External Secrets** list,
where you can watch it sync. (See [ESO Basics]({{< ref "../eso-basics/" >}}) for what each
field means, and the [Glossary]({{< ref "../glossary/" >}}) for the terms.)

### Day-2 Actions: Sync Now and Delete

From an ExternalSecret's detail view you can:

- **Sync Now** — Force ESO to re-fetch from the provider immediately instead of
  waiting for the next refresh interval. (Technically, the dashboard adds a
  `force-sync` annotation; ESO reacts to it.) Use this after rotating a value in
  the provider and wanting it reflected right away.
- **Delete** — Remove the ExternalSecret. A confirmation dialog prevents
  accidental deletion. Editing an existing ExternalSecret is done via `kubectl`
  / GitOps, then re-viewed here.

## Managing SecretStores

SecretStores define **how** to connect to an external secret provider (OpenBao, AWS Secrets Manager, GCP Secret Manager, Azure Key Vault, etc.).

### SecretStore vs. ClusterSecretStore

- **SecretStore** — Namespaced. Only ExternalSecrets in the same namespace can reference it.
- **ClusterSecretStore** — Cluster-scoped. ExternalSecrets in any namespace can reference it.

Both types are managed from the **Secret Stores** page. Use the tab selector to switch between the two.

### Viewing a SecretStore

SecretStores are **view-only** in the dashboard — create and edit them with
`kubectl` or GitOps. The list shows each store's provider and its `Ready`
status; the detail view shows the full configuration as read-only YAML and the
store's status conditions.

When you look at a store's configuration, note that **credential fields are
references, not raw values**: a store points to an existing Kubernetes Secret
(by name and key) that holds the actual provider credentials — the dashboard
never shows or accepts the credentials themselves.

## Managing PushSecrets

PushSecrets are the reverse flow — they push Kubernetes Secrets **upstream** to an external provider.

On the **Push Secrets** page you can **view** all PushSecrets and their sync
status, open a detail view, and **delete** a PushSecret. Creating a PushSecret is
done with `kubectl` or GitOps (the dashboard has no create form). A PushSecret
specifies the source Kubernetes Secret, the target SecretStore, the destination
path in the provider, and which keys to push.

## Viewing Kubernetes Secrets

The **Secrets** page lists all Kubernetes Secrets in the selected namespace(s). For each secret:

- **ESO-managed** secrets are clearly tagged, showing which ExternalSecret created them
- **Secret values are never displayed** — all value fields show `••••••••`
- **Key names** are visible, allowing you to verify the correct keys exist
- **Stale detection** — Secrets that haven't been refreshed within their expected interval are flagged

This page is view-only — Kubernetes Secrets are created and updated by ESO (from
your ExternalSecrets), not edited by hand in the dashboard.

## ReloaderConfigs

ReloaderConfigs trigger automatic workload restarts when synced secrets change.
On the **Reloaders** page you can **view** all ReloaderConfigs and their status,
and **delete** one. They are created with `kubectl` / GitOps and specify:

- **Target workload** (Deployment, StatefulSet, or DaemonSet)
- **Secret references** to watch
- **Reload strategy** (rolling restart vs. annotation bump)

## ESODeployments

ESODeployments manage the ESO operator lifecycle across clusters:

1. Navigate to **ESO Deployments**
2. View the status of ESO installations across your connected clusters
3. Create or update ESODeployments to install, upgrade, or remove ESO from target clusters
4. Monitor deployment phases: `Deploying`, `Running`, `Upgrading`, `Error`

## Federation

The **Federation** page provides read-only visibility into cross-cluster secret
distribution — letting a central SecureGuard instance serve secret data to many
clusters without exposing the backend stores. It has two tabs:

- **Servers** — `FederationServer` resources, which declare what the broker
  exposes (backend stores) and which token issuers it trusts, with Ready status.
- **Authorizations** — `FederationAuthorization` policies, which grant a specific
  remote identity read access to specific stores and key globs (deny-by-default).

These resources carry **references and policy only — never secret values**.
Secret serving happens in the separate federation broker, not in the dashboard
proxy. Federation is opt-in and disabled by default. For setup, the broker, the
`fedclient` consumer, and resolution modes, see the [Federation guide]({{< ref "../federation/" >}}).

## Event Stream

The **Event Stream** page shows real-time Kubernetes events related to ESO resources. Use it for:

- Monitoring sync activity across all ExternalSecrets
- Spotting error patterns in real-time
- Debugging failed syncs without needing `kubectl`

## Relationship Visualization

The **Visualization** page renders an interactive graph showing relationships between:

- ExternalSecrets → SecretStores / ClusterSecretStores
- ExternalSecrets → target Kubernetes Secrets
- PushSecrets → source Kubernetes Secrets

Click any node to navigate to its detail page. Use the controls to zoom, pan, and re-layout the graph.

## Multi-Cluster Management

### Cluster Selector

The **cluster selector** in the top bar lets you scope the view to a specific cluster or view resources across all clusters.

### Adding Clusters

1. Navigate to **Clusters** (the Cluster Management page)
2. Click **Upload Kubeconfig** and select a kubeconfig file
3. Each context in the kubeconfig becomes a new cluster
4. Optionally register an SGAgent for the cluster

### Cluster Health

The Cluster Management page shows the health status of all connected clusters. Unhealthy clusters are flagged with the reason (unreachable, auth expired, etc.).

## Namespace Filtering

The **namespace selector** in the top bar filters all views by namespace. Select "All Namespaces" to see resources across the entire cluster.

The selected namespace is persisted in the URL (`?namespace=...`), making it shareable and bookmarkable.

## Understanding the Security Model

As you use the dashboard, keep these security principles in mind:

- **Secret values are never visible** — the proxy redacts all secret data before it reaches your browser. There is no "reveal" button because there is nothing to reveal.
- **No secret data in browser storage** — values are not stored in URL parameters, browser history, local storage, or any cache.
- **All changes go through the proxy** — the browser never contacts the Kubernetes API server directly. The proxy enforces route allowlisting and secret redaction.
- **Credential fields are references** — when creating SecretStores, you provide the *name* of a Kubernetes Secret containing credentials, not the credentials themselves.
