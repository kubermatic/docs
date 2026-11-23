+++
title = "RBAC Metadata"
weight = 2
+++

Labels and annotations that KDP reads on RBAC objects and `APIBindings`. For how KDP RBAC works,
see [RBAC]({{< ref "/developer-platform/v1.2/introduction/concepts/rbac" >}}).

## ClusterRoles

### Labels

| Label                                    | Value      | Description                |
| ---------------------------------------- | ---------- | -------------------------- |
| `rbac.kdp.k8c.io/display`                | `"true"`   | Make the `ClusterRole` available for assignment to users in the KDP dashboard. |
| `rbac.kdp.k8c.io/aggregate-to-member`    | `"true"`   | Aggregate this `ClusterRole` into the "Member" role, which is used for basic membership in a workspace (i.e. mostly read-only permissions). |
| `rbac.kdp.k8c.io/aggregate-to-developer` | `"true"`   | Aggregate this `ClusterRole` into the "Developer" role, which is assigned to active contributors (creating and deleting objects). |

{{% notice note %}}
In the KDP dashboard you can assign **multiple roles to a user at once** via a multi-select
control, rather than one role per user.
{{% /notice %}}

### Annotations

| Annotation                     | Value      | Description                |
| ------------------------------ | ---------- | -------------------------- |
| `rbac.kdp.k8c.io/display-name` | String     | Display name in the KDP dashboard. The dashboard falls back to the `ClusterRole` object name if this is not set. |
| `rbac.kdp.k8c.io/description`  | String     | Description shown as help in the KDP dashboard for this `ClusterRole`. |

## APIBindings

### Labels

| Label                                         | Value    | Description                                                                                  |
| --------------------------------------------- | -------- | -------------------------------------------------------------------------------------------- |
| `rbac.kdp.k8c.io/create-default-clusterroles` | `"true"` | Create default ClusterRoles (developer and viewer) for resources bound by this `APIBinding`. |
