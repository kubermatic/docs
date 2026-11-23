+++
title = "Workspaces"
weight = 1
+++

KDP is built on [kcp](https://kcp.io), which runs many lightweight logical clusters in one
control plane. Each logical cluster is called a **workspace**. To its users, a workspace looks like
its own Kubernetes cluster: it has its own API endpoint, namespaces, RBAC and objects, and it can't
see the contents of other workspaces.

KDP uses workspaces for its tenants: every organisation and every project is a workspace.

## The workspace tree

Workspaces form a tree below kcp's `root` workspace:

```
root
|-- acme                 (organisation)
|   |-- team-a           (project)
|   |   `-- backend      (project)
|   `-- team-b           (project)
`-- globex               (organisation)
```

A workspace is identified by its **path**, the names from `root` down joined with colons, such as
`root:acme:team-a:backend`. The dashboard shows the path without `root:` in its URLs, for example
`/organizations/acme:team-a:backend/...`. Internally, kcp also gives every workspace a random
**cluster ID**, which some objects and logs show instead of the path.

## Organisations and projects

KDP defines two workspace types:

| Type | Created in | Can contain |
| ---- | ---------- | ----------- |
| `kdp-organization` | `root` only | Projects |
| `kdp-project` | An organisation or another project | Projects |

Projects can be nested as deep as you need. A workspace created inside an organisation or project
without a type becomes a project.

Every organisation and project gets KDP's own API (`core.kdp.k8c.io`) bound automatically, which
provides `Service` objects and the other KDP basics. Apart from that, each one starts empty and is
configured separately:

- **Services** are enabled per workspace. Enabling a service in an organisation doesn't enable it
  in the organisation's projects. See [Services]({{< ref "/developer-platform/v1.2/introduction/concepts/services" >}}).
- **Members and permissions** are set per workspace. KDP can copy shared roles from `root` into
  every workspace; see [RBAC]({{< ref "/developer-platform/v1.2/introduction/concepts/rbac" >}}).
- **Namespaces, service accounts, Secrets and objects** belong to one workspace only.

Deleting an organisation or project deletes its workspace with everything in it, including its
projects.

## Why workspaces and not namespaces

Many internal developer platforms separate tenants with namespaces and RBAC in a shared cluster.
Workspaces go further: each tenant gets a full Kubernetes API of its own, so tenants can create
their own namespaces, CRD-like APIs and cluster-wide RBAC without affecting each other, and there is
no shared list of namespaces or cluster-scoped objects to leak between them.

## Related topics

- [Organisations, Projects and Namespaces]({{< ref "/developer-platform/v1.2/guides/platform-users/organizations-and-projects" >}}):
  managing workspaces in the dashboard.
- [kcp on the Command Line]({{< ref "/developer-platform/v1.2/references/kcp-command-line" >}}):
  working with workspaces using `kubectl`.
