+++
title = "Organizations, Projects and Namespaces"
weight = 1
aliases = ["/developer-platform/v1.2/platform-users/organizations-and-projects/"]
+++

This page shows how to find your way around the KDP dashboard, and how to create and delete
organizations, projects and namespaces.

Organizations and projects are kcp workspaces, and projects can be nested as deep as you need. Each
one has its own services, members, service accounts and namespaces. For how workspaces fit
together, see the [Overview]({{< ref "/developer-platform/v1.2" >}}). Everything in the rest of the
platform user docs works the same in an organization and in a project.

## Navigating the dashboard

The dashboard shows the workspace path in the URL, with path segments joined by colons. For example,
`/organizations/acme:team-a:backend/...` is the project `backend`, inside project `team-a`, inside
organization `acme`.

After you log in, the dashboard shows the list of organizations you can access. Selecting one opens
its **Service Catalog**.

Once you are inside an organization or project, the dashboard has three navigation areas:

- **Header**: the **Service Catalog** button, the organization/project selector, and the user menu.
  The user menu has **Download Kubeconfig** and **Log out**. The kubeconfig logs you in through
  your identity provider (it needs the `kubectl` `oidc-login` plugin), and its current context is
  the organization or project you are in. See
  [kcp on the Command Line]({{< ref "/developer-platform/v1.2/references/kcp-command-line" >}}).
- **Sidebar, Services section**: one entry for each service enabled in the current workspace. An entry
  opens the list of that service's objects (see [Managing Resources]({{< ref "/developer-platform/v1.2/guides/platform-users/managing-resources" >}})).
- **Sidebar, Manage section**: **Services**, **Blueprints**, **Projects**, **Members** (with
  **Roles** below it), **Service Accounts**, **Namespaces**, **Config Maps** and **Secrets**.
  **Blueprints** only appears when the Blueprints feature is enabled.

You can collapse the sidebar to icons with the toggle button at its top.

Sidebar entries are not filtered by your permissions. When a page needs a permission you don't
have, its create or delete actions are hidden.

### Switching organizations and projects

The selector in the header shows the current organization or project. A spinning icon next to it
means the workspace is not ready yet. Open the selector to see:

- **Current Organization** / **Current Project**.
- **Other Organizations** / **Other Projects**, the siblings of the current workspace.
- **Navigate Up**, the parent workspaces of a nested project.
- **View Full Organization Tree**, a dialog with the whole tree. Expand rows to load their children
  and click **Select** to switch.

Switching keeps you on the same page type. For example, if you are on **Secrets** in one project and
select another project, you land on **Secrets** in the new project.

## Organizations

### Creating an organization

Click **Add Organization** on the organizations list. The button only shows if you are allowed to
create workspaces in the `root` workspace.

The organization name must:

- be at most 63 characters long,
- contain only lowercase letters, digits and hyphens,
- start and end with a lowercase letter or digit,
- not be used by another organization yet.

After you click **Submit**, the dashboard creates a `Workspace` of type `kdp-organization` and
switches to it. While kcp initializes the workspace, the dashboard shows **Setting Up Your
Organization** and checks every few seconds. This usually takes a few seconds. If the organization
is still not ready after two minutes, the dashboard shows **Organization Setup Failed**. Contact
your platform administrator in that case.

The organizations list has a search box that matches organization names. Click **Advanced filters**
to filter by a label key and value.

### Deleting an organization

Open the row menu (**…**) of an organization and choose **Delete**. To confirm, type the
organization name. This option only shows if you are allowed to delete workspaces.

{{% notice warning %}}
Deleting an organization deletes its workspace and everything in it: projects, namespaces, service
objects, Secrets, members' access and enabled services.
{{% /notice %}}

## Projects

Use projects to split an organization into separate workspaces, for example per team, application
or environment. Each project has its own enabled services, members, service accounts and namespaces.

Open **Projects** in the sidebar to see the projects of the current organization or project. Click a
project row to expand it and show its sub-projects. Hover a row and click **Select** to switch into
that project.

Inside a nested project, the page shows the path from the organization to the current project.
Click a parent to go back up.

### Creating a project

Click **Create Project** to create a project in the current organization or project. To create a
project below a listed project, open that row's menu (**…**) and choose **Create Sub-Project**.

Project names follow the same rules as organization names. They must be unique among their sibling
projects.

The dashboard creates a `Workspace` of type `kdp-project` inside the parent workspace. You need
permission to create workspaces in the current organization or project. Without it, the create
actions are hidden.

You can also create projects from the command line. See
[kcp on the Command Line]({{< ref "/developer-platform/v1.2/references/kcp-command-line#workspaces" >}}).

### Deleting a project

Open the project's row menu (**…**), choose **Delete** and type the project name to confirm. You need
permission to delete workspaces in the current organization or project.

{{% notice warning %}}
Deleting a project permanently deletes all resources in it, including its sub-projects.
{{% /notice %}}

## Namespaces

Namespaces group objects inside an organization or project, as they do in Kubernetes. Each workspace
starts with the `default` namespace.

Open **Namespaces** in the sidebar to see all namespaces of the current workspace and their status
(`Active` or `Terminating`).

- To create one, click **Create Namespace**. Namespace names follow the same rules as organization
  names. You need permission to create namespaces.
- To delete one, open its row menu (**…**), choose **Delete** and type the namespace name. You need
  permission to delete namespaces. The `default` namespace and namespaces that are already
  terminating can't be deleted.

{{% notice warning %}}
Deleting a namespace deletes every object in it, including service objects and their Secrets.
{{% /notice %}}

The **Config Maps**, **Secrets** and service object pages each have a namespace selector at the top.
Your selection is stored in the page URL (`?namespace=<name>`), so you can bookmark or share a link
to a specific namespace. When you create a new service object from a service object list, the
namespace selected there is preselected.

## Related topics

- [Members and Roles]({{< ref "/developer-platform/v1.2/guides/platform-users/members-and-roles" >}})
- [Service Accounts]({{< ref "/developer-platform/v1.2/guides/platform-users/service-accounts" >}})
- [RBAC]({{< ref "/developer-platform/v1.2/introduction/concepts/rbac" >}})
