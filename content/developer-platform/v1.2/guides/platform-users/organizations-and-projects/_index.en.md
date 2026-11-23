+++
title = "Organisations, Projects and Namespaces"
weight = 1
aliases = ["/developer-platform/v1.2/platform-users/organizations-and-projects/"]
+++

This page shows how to find your way around the KDP dashboard, and how to create and delete
organisations, projects and namespaces.

Organisations and projects are kcp workspaces, and projects can be nested as deep as you need. Each
one has its own services, members, service accounts and namespaces. For how workspaces fit
together, see the [Overview]({{< ref "/developer-platform/v1.2" >}}). Everything in the rest of the
platform user docs works the same in an organisation and in a project.

## Navigating the dashboard

The dashboard shows the workspace path in the URL, with path segments joined by colons. For example,
`/organizations/acme:team-a:backend/...` is the project `backend`, inside project `team-a`, inside
organisation `acme`.

After you log in, the dashboard opens the **Service Catalog** of your default workspace. If you
haven't set one, it shows the list of organisations you can access. The list is a tree: expand an
organisation to see its projects, and click a name to open it.

Once you are inside an organisation or project, the dashboard has three navigation areas:

- **Header**: the **Service Catalog** button, the organisation/project selector, and the user menu.
  The user menu has:
  - **Download Kubeconfig**. The kubeconfig logs you in through your identity provider (it needs
    the `kubectl` `oidc-login` plugin), and its current context is the organisation or project you
    are in. If the dashboard can't add the server's CA certificate, it asks you to paste it. See
    [kcp on the Command Line]({{< ref "/developer-platform/v1.2/references/kcp-command-line" >}}).
  - **Connect AI agent**, if your administrator has enabled the MCP server. See
    [AI Tooling]({{< ref "/developer-platform/v1.2/guides/platform-users/ai-tooling" >}}).
  - **Default workspace**, to make the current organisation or project your default.
  - **Log out**.
- **Sidebar, Services section**: one entry for each service enabled in the current workspace. An entry
  opens the list of that service's objects (see [Managing Resources]({{< ref "/developer-platform/v1.2/guides/platform-users/managing-resources" >}})).
  Click **Customize services** in the section header to hide services from the sidebar, or
  **Reset to default** to show them all again. This setting is stored per workspace.
- **Sidebar, Manage section**: **Services**, **Blueprints**, **Projects**, **Members** (with
  **Roles** below it), **Service Accounts**, **RBAC**, **Namespaces**, **Config Maps** and
  **Secrets**. **Blueprints** only appears when the Blueprints feature is enabled.

You can collapse the sidebar to icons with the toggle button at its top, and drag its edge to make
it wider or narrower.

Sidebar entries are not filtered by your permissions. When a page needs a permission you don't
have, it shows **Access Denied**, or its create and delete actions are hidden.

### Switching organisations and projects

The selector in the header shows the current organisation or project. A spinning icon next to it
means the workspace is not ready yet. Open the selector to see the current workspace and its
child organisations or projects. Click a child to switch to it, or click its arrow to browse
inside it. The back button at the top takes you up a level.

Switching always takes you to the **Service Catalog** of the new organisation or project.

### Setting a default workspace

Your default workspace is where the dashboard opens after you log in. To set it, click the star
next to an organisation or project in the organisations list or the selector, or tick **Default
workspace** in the user menu. You can have one default; setting a new one replaces the old one.

The default is stored in your browser, so it doesn't follow you to another browser or computer. If
the workspace is deleted or you lose access to it, the dashboard tells you and clears the default.

## Organisations

### Creating an organisation

Click **Add Organization** on the organisations list. The button only shows if you are allowed to
create workspaces in the `root` workspace.

The organisation name must:

- be at most 63 characters long,
- contain only lowercase letters, digits and hyphens,
- start and end with a lowercase letter or digit,
- not be used by another organisation yet.

After you click **Submit**, the dashboard creates a `Workspace` of type `kdp-organization` and
switches to it. While kcp initialises the workspace, the dashboard shows **Setting Up Your
Organisation** and checks every few seconds. This usually takes a few seconds. If the organisation
is still not ready after two minutes, the dashboard shows **Organization Setup Failed**. Contact
your platform administrator in that case.

The organisations list has a search box that matches organisation names. Click **Advanced filters**
to filter by a label key and value.

### Deleting an organisation

Open the row menu (**...**) of an organisation and choose **Delete**. To confirm, type the
organisation name. This option only shows if you are allowed to delete workspaces.

{{% notice warning %}}
Deleting an organisation deletes its workspace and everything in it: projects, namespaces, service
objects, Secrets, members' access and enabled services.
{{% /notice %}}

## Projects

Use projects to split an organisation into separate workspaces, for example per team, application
or environment. Each project has its own enabled services, members, service accounts and namespaces.

Open **Projects** in the sidebar to see the projects of the current organisation or project. Click
the arrow next to a project to show its sub-projects, and click a project's name to open its
projects page.

A project that isn't ready yet shows a spinner and its status instead of a link. Wait until it is
ready before you open it.

Inside a nested project, the page shows the path from the organisation to the current project.
Click a parent to go back up.

### Creating a project

Click **Create Project** to create a project in the current organisation or project. To create a
project below a listed project, open that row's menu (**...**) and choose **Create Sub-Project**.

Project names follow the same rules as organisation names. They must be unique among their sibling
projects.

The dashboard creates a `Workspace` of type `kdp-project` inside the parent workspace. You need
permission to create workspaces in the current organisation or project. Without it, the create
actions are hidden.

You can also create projects from the command line. See
[kcp on the Command Line]({{< ref "/developer-platform/v1.2/references/kcp-command-line#workspaces" >}}).

### Deleting a project

Open the project's row menu (**...**), choose **Delete** and type the project name to confirm. You need
permission to delete workspaces in the current organisation or project.

{{% notice warning %}}
Deleting a project permanently deletes all resources in it, including its sub-projects.
{{% /notice %}}

## Namespaces

Namespaces group objects inside an organisation or project, as they do in Kubernetes. Each workspace
starts with the `default` namespace.

Open **Namespaces** in the sidebar to see all namespaces of the current workspace and their status
(`Active` or `Terminating`).

- To create one, click **Create Namespace**. Namespace names follow the same rules as organisation
  names. You need permission to create namespaces.
- To delete one, open its row menu (**...**), choose **Delete** and type the namespace name. You need
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
