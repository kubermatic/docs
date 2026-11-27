+++
title = "What's New"
weight = 2
+++

This page lists what changed between KDP 1.1 and 1.2. Use the latest 1.2 patch release, currently
1.2.1. See
[Compatibility]({{< ref "/developer-platform/v1.2/introduction/compatibility" >}}).

## For platform users

- **AI agents over MCP.** KDP can host an MCP server behind a public HTTPS gateway, and the user
  menu has a **Connect AI agent** dialog with the client configuration. See
  [AI Tooling]({{< ref "/developer-platform/v1.2/guides/platform-users/ai-tooling" >}}).
- **RBAC page.** A new page lists the Kubernetes roles and role bindings in an organisation or
  project, and lets you edit and delete them.
- **Cluster-wide roles for service accounts.** Service accounts can now be given roles that apply
  to the whole workspace, not just their namespace. See
  [Service Accounts]({{< ref "/developer-platform/v1.2/guides/platform-users/service-accounts" >}}).
- **Default workspace.** You can mark an organisation or project as your default; the dashboard
  opens there after login.
- **Easier navigation.** The project list shows each project's status, the sidebar can be
  resized and services hidden from it, and the dashboard version is shown in the footer.
- **Preselected permission claims.** When you add a service, the permissions it asks for come
  from the service catalogue and are preselected.
- **Dark mode** and many accessibility fixes.

## For service providers

- **Logo uploads.** Service and Blueprint logos are uploaded to and served from the new KDP
  storage server.
- **Restricting where a service can be used.** The `catalog.kdp.k8c.io/disallow-workspace-types`
  annotation keeps a service's objects out of organisations or projects. The API rejects them and
  the dashboard shows the service as read-only there.
- **Link to your own UI.** The `catalog.kdp.k8c.io/external-link-url` annotation adds an
  **Open** button for your service in the dashboard.
- **Dynamic form fields.** Forms can fill a field's options from other resources.
- **Blueprints** support kro collections (`forEach`), and the Blueprint editor's AI assistant is
  on by default.
- **More service settings.** See
  [Configuring Services]({{< ref "/developer-platform/v1.2/guides/service-providers/configuring-services" >}}).

## For platform administrators

- **New components:** the storage server (on by default), an admission webhook in the KDP
  controller manager, and the MCP server and gateway (off by default).
- **Targeted RBAC sync.** `kdp.k8c.io/sync-to-workspaces` now accepts full workspace paths such as
  `root:acme:team-a`, which match at any depth, and syncing stops 10 levels below `root`. See
  [RBAC]({{< ref "/developer-platform/v1.2/introduction/concepts/rbac#cross-workspace-rbac-propagation" >}}).
- **Configurable ingress** class and annotations for the front-proxy.
- **Removed:** the dashboard's `features.aiAgent` and
  `features.kubeconfigDownload.enabled` settings.

To upgrade from 1.1, see
[Upgrading to 1.2]({{< ref "/developer-platform/v1.2/guides/platform-administration/upgrade" >}}).
