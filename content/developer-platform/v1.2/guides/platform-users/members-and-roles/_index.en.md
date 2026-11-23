+++
title = "Members and Roles"
weight = 2
+++

This page explains how to give users and groups access to an organisation or project in the KDP
dashboard, and which roles you can assign to them. For the RBAC concepts behind this, see
[RBAC]({{< ref "/developer-platform/v1.2/introduction/concepts/rbac" >}}).

Membership applies to the current workspace. Each organisation and each project has its own
members. See [Organisations, Projects and Namespaces]({{< ref "/developer-platform/v1.2/guides/platform-users/organizations-and-projects" >}}).

A member is a user (identified by email address) or a group from your identity provider, together
with one or more roles. To manage members with `kubectl` instead, see
[Members and service accounts]({{< ref "/developer-platform/v1.2/introduction/concepts/rbac#members-and-service-accounts" >}}).

## Roles

Open **Members -> Roles** in the sidebar to see the roles you can assign, with their display name
and description. Choose **View Rules** in a role's row menu (**...**) to see what the role allows.
The **Cluster Role Rules** dialog lists each rule's API group, resources and allowed methods.

To add your own role, create a `ClusterRole` on the **RBAC** page (see below) or with `kubectl`.
It only shows up here, and can only be assigned to members, if it has the labels and annotations
listed in [RBAC Metadata]({{< ref "/developer-platform/v1.2/references/rbac-metadata" >}}).

## Managing roles and bindings directly

The **RBAC** page in the sidebar shows the plain Kubernetes RBAC objects of the current
organisation or project, on four tabs: **Roles**, **Role Bindings**, **Cluster Roles** and
**Cluster Role Bindings**. The Roles and Role Bindings tabs have a namespace selector.

- To create an object, click **Create** on its tab and enter it as YAML or JSON.
- To view, edit or delete one, use its row menu (**...**).

The **Source** column shows whether an object is **Local** or **Synchronized**. Synchronised
objects are copied in from a parent workspace (see
[RBAC]({{< ref "/developer-platform/v1.2/introduction/concepts/rbac#cross-workspace-rbac-propagation" >}}))
and are read-only here. Change them in the workspace they come from.

If someone else changes an object while you edit it, saving fails with a conflict. Reopen the
object and make your change again.

You need permission to list at least one of the four kinds to open this page.

When you enable a service with **Create default roles for resources managed by this service**,
KDP creates a developer and a viewer role for that service. They are aggregated into the general
"Developer" and "Member" roles. See [Consuming Services]({{< ref "/developer-platform/v1.2/guides/platform-users/consuming-services#enabling-a-service" >}}).

## Viewing members

Open **Members** in the sidebar. The table lists every user and group bound to a role in the current
workspace, with their **Kind** (User or Group) and their **Roles**. Use the **Kind** and **Role**
filters at the top to narrow the list.

Service accounts are not listed here. They have their own page; see
[Service Accounts]({{< ref "/developer-platform/v1.2/guides/platform-users/service-accounts" >}}).

To open this page you need permission to list `clusterrolebindings` in the workspace.

## Adding members

1. Click **Add Users** or **Add Groups**.
2. Enter an email address (users) or a group name (groups) and click **Add**. You can add several
   members before saving.
3. Each added member gets one role preselected. Use the role selector next to the member to choose
   one or more roles.
4. Click **Save Changes**.

To add members you need permission to create `clusterrolebindings`.

{{% notice note %}}
The dashboard does not check that a user or group exists in your identity provider. Check the
spelling: a binding for a misspelled email address grants nothing.
{{% /notice %}}

## Changing a member's roles

Open the member's row menu (**...**) and choose **Update Role**. Select the new set of roles and
click **Save Changes**. The dashboard creates bindings for added roles and removes the member from
bindings of removed roles.

The `workspace-admin` binding, which gives the workspace owner full access, is never shown or
changed in this dialog.

## Removing members

Open the member's row menu (**...**) and choose **Delete**, then confirm. The dashboard removes the
member from all their role bindings. A binding that has no subjects left is deleted.

- You can't delete yourself.
- The `workspace-admin` binding is never removed. A member who only has that binding can't be
  deleted from the dashboard.

To change or remove members you need permission to create and delete `clusterrolebindings`.

## Related topics

- [RBAC]({{< ref "/developer-platform/v1.2/introduction/concepts/rbac" >}})
- [Service Accounts]({{< ref "/developer-platform/v1.2/guides/platform-users/service-accounts" >}})
