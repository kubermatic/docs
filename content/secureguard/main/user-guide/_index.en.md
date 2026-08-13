+++
title = "User Guide"
date = 2026-06-13T09:00:00+02:00
weight = 6
description = "A feature-by-feature tour of the SecureGuard dashboard — managing ExternalSecrets, stores, push secrets, clusters, and federation from a read-mostly control room."
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
**Why so read-only?** Each thing the browser can do must be explicitly allowed by the proxy's [route allowlist]({{< ref "../api-reference/#route-allowlist" >}}). Keeping the surface small is a deliberate security choice — see [Architecture → Security Model]({{< ref "../architecture/#the-security-model" >}}). To create the resources marked "—" above, use `kubectl apply` or GitOps.
{{% /notice %}}

## Dashboard Overview

The Dashboard page provides an at-a-glance view of your secrets management posture:

- **Sync Status Breakdown** — How many ExternalSecrets are synced, pending, errored, or **stale** (see [stale detection](#stale-detection) below)
- **Infrastructure Metrics** — When the SG Agent is enabled: ESO Deployments running/errored and SG Agents healthy/unhealthy
- **Provider Distribution** — Which external secret providers are in use across your stores
- **Recent Sync Errors** — The latest failures with direct links to affected resources
- **External Store Links** — Deep links to the admin consoles of the providers in use (OpenBao UI, AWS/GCP/Azure consoles)
- **Cluster & Namespace Breakdown** — Resource distribution across clusters and namespaces

## Managing ExternalSecrets

### Viewing ExternalSecrets

Navigate to **External Secrets** in the sidebar. The table shows all ExternalSecrets across your selected namespace(s) with:

- **Name** and **Namespace**
- **Sync Status** — `Synced` (green), `Pending` (amber), `Error` (red), or `Stale`
- **Secret Store** — Which SecretStore or ClusterSecretStore the secret references
- **Last Synced** — Timestamp of the most recent successful sync
- **Refresh Interval** — How often ESO polls the external provider

Use the search box and the **Status** / **SecretStore** filters to narrow the list.

### Stale Detection

An ExternalSecret is flagged **Stale** when its last successful sync is older than **twice its `refreshInterval`** — a sign that ESO is running but silently failing to refresh (provider unreachable, credentials expiring, controller wedged). Stale secrets get their own dashboard metric and list filter so they don't hide behind a green `Synced` condition.

Click any row to open the detail view, which includes:
- Full resource metadata
- Status conditions with timestamps
- Sync history timeline
- Key mappings (`spec.data` / `spec.dataFrom`) and target template
- The complete resource as **read-only YAML** (you can copy it, but not edit it here)
- The target Kubernetes Secret (with values displayed as `••••••••`)

### Debugging a Failed Sync (Sync Error Drawer)

For an errored ExternalSecret, the detail view offers a **Debug** action that opens the **Sync Error Drawer**: a side panel combining the resource's condition timeline, related Kubernetes events, and **remediation hints** — pattern-matched suggestions for common failures (e.g. access denied → check the provider policy attached to the store's role). This is usually the fastest path from a red badge to a root cause without leaving the browser.

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

ReloaderConfigs make secret delivery **event-driven**: they wire notification **sources** to trigger **destinations**, so a change propagates the instant it happens instead of on ESO's next poll. On the **Reloaders** page you can **view** all ReloaderConfigs and their status, open a detail view (with **Notification Sources** and **Trigger Destinations** tabs), and **delete** one. They are created with `kubectl` / GitOps and specify:

- **Notification sources** — what to listen to: a Kubernetes `Secret` or `ConfigMap` change, a cloud event (GCP Pub/Sub, AWS SQS, Azure Event Grid), a HashiCorp Vault audit-log event, a generic webhook, or a TCP socket.
- **Trigger destinations** — what to act on: roll out a **Deployment**, or make an **ExternalSecret** / **PushSecret** reconcile immediately, or a **WorkflowRunTemplate**.

Common patterns: restart a Deployment when its Secret rotates, or trigger ESO to re-fetch on a cloud event/webhook rather than waiting for `refreshInterval`. See the [External Secrets Reloader docs](https://external-secrets.github.io/reloader/) for the full source/destination catalog.

## ESODeployments

ESODeployments manage the ESO operator lifecycle across clusters — the one resource with a full **create/edit form** in the dashboard:

1. Navigate to **ESO Deployments**
2. View the status of ESO installations across your connected clusters
3. Create or update ESODeployments to install, upgrade, or remove ESO from target clusters
4. Monitor deployment phases: `Deploying`, `Running`, `Upgrading`, `Deleting`, `Error`, and `Discovered` (see below)

### The Create/Edit Form

The guided form validates as you type and covers:

- **Target cluster** and installation **namespace**
- **ESO version** — picked from the operator-curated [ESO Version Catalog]({{< ref "../advanced-configuration/#eso-version-catalog-esoversion-crd" >}}), newest first, with the `latest`-flagged release preselected
- **Scope** — cluster-wide or restricted to specific target namespaces (with optional exclusions; system namespaces are filtered out)
- **High availability** — replica count
- **Image & update schedule** — custom image repository and an optional cron schedule for automated image updates
- **Deploy Reloader** — optionally co-deploy the Reloader controller for event-driven rotation (see [ReloaderConfigs](#reloaderconfigs))

A **Form ↔ YAML** toggle lets you switch to a full YAML editor at any point — the round-trip is lossless, so YAML keys the form doesn't know about are preserved.

### Conflict Pre-Validation

Before you submit, the form checks the new deployment against existing ESODeployments on the same effective cluster and warns about:

- **Namespace overlap** — two namespaced deployments targeting the same namespace
- **Multiple cluster-scoped deployments** on one cluster
- **Cluster scope covering a namespaced deployment**

The SG Agent performs the same checks server-side and surfaces violations as a `Conflict` condition on the resource — blocking (`Error`) or advisory (`Warning`) depending on severity.

### Externally Installed ESO (Discovered)

The SG Agent periodically scans connected clusters for ESO installations **it didn't deploy** (e.g. installed by another platform team). These appear as read-only `eso-ext-*` ESODeployments in the `Discovered` phase with `managementMode: external`, showing the discovered image and replica count. SecureGuard never modifies them — they exist so the dashboard shows the complete picture. To adopt such a cluster, remove the external installation and create a managed ESODeployment for it.

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

The **Event Stream** page shows a live feed of Kubernetes events related to ESO resources, aggregated across all selected clusters. Use it for:

- Monitoring sync activity across all ExternalSecrets
- Spotting error patterns in real-time
- Debugging failed syncs without needing `kubectl`

Controls: filter by **Type** (Normal/Warning) and **Reason**, **Pause/Resume** the feed, and **Clear** the buffer. Each event links to its involved object's detail page. The feed polls every 10 seconds and keeps the most recent 500 events.

## Relationship Visualization

The **Visualization** page renders your secret-syncing topology in two views:

- **Graph view** — an interactive, auto-laid-out graph of clusters, SecretStores/ClusterSecretStores, ExternalSecrets, target Kubernetes Secrets, and ESODeployments. Zoom, pan, rotate the layout, auto-arrange, and use the minimap for orientation.
- **List view** — the same relationships as expandable per-cluster trees: each store expands to show its referencing ExternalSecrets and their target Secrets.

Click any node to navigate to its detail page. Both views respect the global cluster and namespace selectors.

## Multi-Cluster Management

### Cluster Selector

The **cluster selector** in the top bar lets you scope the view to a specific cluster or view resources across all clusters. In "All Clusters" mode the dashboard queries every registered cluster in parallel and tags each row with its origin cluster. The selection is persisted in the URL (`?cluster=...`), so filtered views are shareable and bookmarkable.

### Adding Clusters

Navigate to **Clusters** (the Cluster Management page) and click **Add Cluster**. A three-step wizard walks you through registration:

1. **Configure** — Choose a cluster name (lowercase RFC 1123), an environment label, and whether to register an **SG Agent** for the cluster. Registering an agent enables heartbeat health reporting and ESO lifecycle management (ESODeployments) on that cluster; without it, the cluster is view-only through the proxy.
2. **Setup** — The wizard generates the exact `kubectl` commands to run against the target cluster: they create a dedicated least-privilege, read-only ServiceAccount for SecureGuard. Use **Copy All Commands** and run them with cluster-admin rights on the target.
3. **Upload** — Drag-and-drop or select the kubeconfig. Each context becomes a registered cluster.

On upload, the proxy immediately replaces the kubeconfig's credential with a **short-lived, self-renewing token** — the uploaded credential is never persisted. See [Short-Lived Remote-Cluster Tokens]({{< ref "../advanced-configuration/#short-lived-remote-cluster-tokens" >}}).

### Cluster Health & Day-2 Actions

The Cluster Management page shows the health of all connected clusters, their environment, an **SG Agent badge** (active / stale / none) with the last heartbeat, and per-cluster actions:

- **Test Connection** — Run an on-demand connectivity check against the cluster's API server.
- **Delete Cluster** — Deregister a cluster (with confirmation). This removes the per-cluster kubeconfig Secret from the management cluster; the **management cluster itself cannot be deleted**. Resources on the remote cluster are not touched — clean up the remote ServiceAccount manually if you're decommissioning the integration.

Unhealthy clusters are flagged with the reason (unreachable, auth expired, etc.). The cluster detail page additionally shows the SG Agent's status conditions and the ESODeployments targeting that cluster.

## Namespace Filtering

The **namespace selector** in the top bar filters all views by namespace. Select "All Namespaces" to see resources across the entire cluster.

The selected namespace is persisted in the URL (`?namespace=...`), making it shareable and bookmarkable.

## Understanding the Security Model

As you use the dashboard, keep these security principles in mind:

- **Secret values are never visible** — the proxy redacts all secret data before it reaches your browser. There is no "reveal" button because there is nothing to reveal.
- **No secret data in browser storage** — values are not stored in URL parameters, browser history, local storage, or any cache.
- **All changes go through the proxy** — the browser never contacts the Kubernetes API server directly. The proxy enforces route allowlisting and secret redaction.
- **Credential fields are references** — when creating SecretStores, you provide the *name* of a Kubernetes Secret containing credentials, not the credentials themselves.
