+++
title = "RBAC"
weight = 2
+++

# RBAC in KDP

Authorization (authZ) in KDP closely resembles
[Kubernetes RBAC](https://kubernetes.io/docs/reference/access-authn-authz/rbac/) since KDP uses kcp
as its API control plane. Besides the "standard" RBAC of Kubernetes, kcp implements concepts specific
to its multi-workspace nature. See
[upstream documentation](https://docs.kcp.io/kcp/v0.22/concepts/authorization/) for them.

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
Kubernetes RBAC. Manually created roles can still use the aggregation labels (documented below) so
that their manual roles are aggregated to the "Developer" and "Member" meta-roles.

## Well-Known Metadata

### ClusterRoles

#### Labels

| Label                                    | Value      | Description                |
| ---------------------------------------- | ---------- | -------------------------- |
| `rbac.kdp.k8c.io/display`                | `"true"`   | Make the `ClusterRole` available for assignment to users in the KDP dashboard. |
| `rbac.kdp.k8c.io/aggregate-to-member`    | `"true"`   | Aggregate this `ClusterRole` into the "Member" role, which is used for basic membership in a workspace (i.e. mostly read-only permissions). |
| `rbac.kdp.k8c.io/aggregate-to-developer` | `"true"`   | Aggregate this `ClusterRole` into the "Developer" role, which is assigned to active contributors (creating and deleting objects). |

#### Annotations

| Annotation                     | Value      | Description                |
| ------------------------------ | ---------- | -------------------------- |
| `rbac.kdp.k8c.io/display-name` | String     | Display name in the KDP dashboard. The dashboard falls back to the `ClusterRole` object name if this is not set. |
| `rbac.kdp.k8c.io/description`  | String     | Description shown as help in the KDP dashboard for this `ClusterRole`. |

### APIBindings

#### Labels

| Label                                         | Value    | Description                                                                                  |
| --------------------------------------------- | -------- | -------------------------------------------------------------------------------------------- |
| `rbac.kdp.k8c.io/create-default-clusterroles` | `"true"` | Create default ClusterRoles (developer and viewer) for resources bound by this `APIBinding`. |
