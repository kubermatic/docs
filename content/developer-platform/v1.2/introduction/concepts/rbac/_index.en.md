+++
title = "RBAC"
weight = 3
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
the workspace. For each of its roles, the dashboard creates a `RoleBinding` in that namespace, so
the service account's permissions only apply there. Each token is a Secret of type
`kubernetes.io/service-account-token` in the same namespace, filled in by Kubernetes. The role
bindings and token Secrets have an owner reference to the service account, so deleting the service
account deletes them too.

For the dashboard steps, see
[Members and Roles]({{< ref "/developer-platform/v1.2/guides/platform-users/members-and-roles" >}}) and
[Service Accounts]({{< ref "/developer-platform/v1.2/guides/platform-users/service-accounts" >}}).

## Cross-workspace RBAC propagation

KDP implements controllers that allow propagation of `ClusterRoles` and `ClusterRoleBindings` to
children workspaces of the workspace that they are in. Be aware that existing resources with the same
names in the children workspaces will be overwritten.

To sync a `ClusterRole` or `ClusterRoleBinding`, annotate it with `kdp.k8c.io/sync-to-workspaces="*"`.
In the future, the feature might allow to only sync to specific child workspaces, but for now it only
supports syncing to all "downstream" workspace.

The default roles shipped with KDP are annotated like this to be provided in all workspaces.

## Auto-generate Service ClusterRoles

KDP comes with the `apibinding-clusterroles-controller`, which picks up `APIBindings` with the label
`rbac.kdp.k8c.io/create-default-clusterroles=true`. It generates two `ClusterRoles` called
`services:<API>:developer` and `services:<API>:viewer`, which give write and read permissions
respectively to all resources bound by the `APIBinding`.

Both `ClusterRoles` are aggregated to the "Developer" and "Member" roles (if present).

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
