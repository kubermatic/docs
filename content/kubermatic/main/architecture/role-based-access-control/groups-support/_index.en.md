
+++
title = "Role Assignments for OIDC Groups"
date = 2022-08-05T10:00:00+02:00
weight = 1
enterprise = true
+++

[Roles]({{< relref "../" >}}) can always be associated with single users. For Enterprise Edition users it is also possible to associate KKP roles with groups as passed via the OIDC login flow. This will assign the role to anyone who is authenticated with the specific group.

## Considerations

- The list of groups a user is part of is passed by Dex. This depends on the Dex connector that has been configured and might slightly vary. Some connectors like the [Google connector](https://dexidp.io/docs/connectors/google/) require [special configuration](https://dexidp.io/docs/connectors/google/#fetching-groups-from-google) to be able to read group information.
- If you are not sure which groups you are part of, the `/api/v1/me` API endpoint returns information about the groups that KKP is aware of.
- For GitOps scenarios, the [`GroupProjectBinding` CRD]({{< relref "../../../references/crds/#groupprojectbinding">}}) can be used to replicate the UI-based workflow.

## Binding Roles to Groups

Group bindings can be configured from the "Members" project panel. For Enterprise Edition, an additional tab is available for groups:

![Group Bindings Overview](/img/kubermatic/main/architecture/group-rbac-view.png)

From this view, new group bindings can be created via the "Add Group" button.

![Group Binding Wizard](/img/kubermatic/main/architecture/group-rbac-add.png)

Be aware that group names are not further validated as KKP does not have access to a complete list of groups in the OIDC backend. This way, group permissions can be pre-provisioned even if no user with a specific group membership has signed into KKP yet.

The role associated with a group can be updated later on to reflect changes in responsibilities. Group bindings can later be removed from the list of bindings by deleting it from the list.

{{% notice note %}}
Be aware that as of KKP 2.21.0 (when this feature was introduced), there is no group support for MLA Grafana access yet.
{{% /notice %}}
