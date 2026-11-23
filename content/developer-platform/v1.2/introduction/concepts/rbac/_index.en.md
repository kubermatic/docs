+++
title = "RBAC"
weight = 5
aliases = ["/developer-platform/v1.2/platform-users/rbac/"]
+++

# RBAC in KDP

Authorisation (authZ) in KDP closely resembles
[Kubernetes RBAC](https://kubernetes.io/docs/reference/access-authn-authz/rbac/) since KDP uses kcp
as its API control plane. Besides the "standard" RBAC of Kubernetes, kcp implements concepts specific
to its multi-workspace nature. See
[upstream documentation](https://docs.kcp.io/kcp/v0.30/concepts/authorization/) for them.

## Members and service accounts

The KDP dashboard manages access with plain Kubernetes RBAC objects, so you can create the same
objects with `kubectl`.

**Members.** For each member and role, the dashboard creates a `ClusterRoleBinding` in the
workspace. The binding refers to the role's `ClusterRole` and has the user or group as its subject.
Users are identified by email address, groups by group name. Subject names get the prefix `oidc:`,
which the dashboard hides. For example, the user `jane@example.com` becomes the subject
`oidc:jane@example.com`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: acme-jane-user-developer
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: developer   # the ClusterRole you assigned
subjects:
  - apiGroup: rbac.authorization.k8s.io
    kind: User
    name: oidc:jane@example.com
```

If you create bindings with `kubectl`, use the `oidc:` prefix, or the dashboard won't list the
subject as a member.

**Service accounts.** A KDP service account is a Kubernetes `ServiceAccount` in one namespace of
the workspace. For each namespace role, the dashboard creates a `RoleBinding` in that namespace,
so those permissions only apply there. For each cluster-wide role, it creates a
`ClusterRoleBinding`, which applies across the whole workspace. Each token is a Secret of type
`kubernetes.io/service-account-token` in the service account's namespace, filled in by Kubernetes.
The `RoleBindings` and token Secrets have an owner reference to the service account, so Kubernetes
deletes them with it. The dashboard deletes the `ClusterRoleBindings` itself when you delete the
service account there.

For the dashboard steps, see
[Members and Roles]({{< ref "/developer-platform/v1.2/guides/platform-users/members-and-roles" >}}) and
[Service Accounts]({{< ref "/developer-platform/v1.2/guides/platform-users/service-accounts" >}}).

## Cross-workspace RBAC propagation

KDP copies `ClusterRoles` and `ClusterRoleBindings` from its base workspace (`root`) into the
workspaces below it, so organisations and projects get the same roles without anyone creating
them by hand. Existing objects with the same name in the target workspaces are overwritten.

To sync an object, annotate it in the base workspace with `kdp.k8c.io/sync-to-workspaces`. The value
says where it goes:

| Value | Synced to |
| ----- | --------- |
| `*` | Every workspace below the base, down to the depth limit. |
| `acme` | A bare name: only the direct child `root:acme`, such as one organisation. |
| `root:acme:team-a` | A full path: exactly that workspace, at any depth. |
| `acme,root:acme:team-a` | A comma-separated list of the above. |

The default roles shipped with KDP use `*`, so they exist in every workspace.

Keep in mind:

- **Depth limit.** Objects are synced at most 10 levels below the base. This is the controller
  manager's `--rbac-sync-max-depth` flag (`0` syncs nothing, `-1` syncs the whole tree), which the
  KDP Helm chart doesn't expose. Lowering it doesn't remove copies that were already made.
- **Workspaces must be ready.** A new workspace gets its copies once kcp has scheduled it.
- **Unexpected copies are deleted.** If a `ClusterRole` in a target workspace carries the
  `kdp.k8c.io/sync-to-workspaces` annotation but isn't a copy KDP expects there, KDP deletes it.
  Don't put this annotation on roles you create in organisations or projects.
- Synced objects are read-only on the dashboard's
  [RBAC page]({{< ref "/developer-platform/v1.2/guides/platform-users/members-and-roles#managing-roles-and-bindings-directly" >}}).

## Auto-generate Service ClusterRoles

KDP comes with the `apibinding-clusterroles-controller`, which picks up `APIBindings` with the label
`rbac.kdp.k8c.io/create-default-clusterroles=true`. It generates two `ClusterRoles` called
`services:<APIBinding>:developer` and `services:<APIBinding>:viewer`, named after the `APIBinding`, which give write and read permissions
respectively to all resources bound by the `APIBinding`.

Both `ClusterRoles` are aggregated to the "Developer" (`kdp:developer`) and "Member" (`kdp:member`) roles, if present.

If the auto-generated rules are not desired because workspace owners want to assign more granular
permissions, the recommendation is to create `APIBindings` without the mentioned labels and instead
create `ClusterRole` objects in their workspaces. The `APIBinding` status can help in identifying
which resources are available (to add them to `ClusterRoles`):

```yaml
status:
  [...]
  boundResources:
  - group: certs-demo.k8c.io # <- API group
    resource: certificates   # <- resource name
    schema:
      UID: 758377e9-4442-4706-bdd7-365991863931
      identityHash: 7b6d5973370fb0e9104ac60b6bb5df81fc2b2320e77618a042c20281274d5a0a
      name: vc517860e.certificates.certs-demo.k8c.io
    storageVersions:
    - v1alpha1
```

Creating such `ClusterRoles` is a manual process and follows the exact same paradigms as normal
Kubernetes RBAC. Manually created roles can still use the aggregation labels (see [RBAC Metadata]({{< ref "/developer-platform/v1.2/references/rbac-metadata" >}})) so
that their manual roles are aggregated to the "Developer" and "Member" meta-roles.

For the labels and annotations KDP reads on `ClusterRoles` and `APIBindings`, see
[RBAC Metadata]({{< ref "/developer-platform/v1.2/references/rbac-metadata" >}}).
