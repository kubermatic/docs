+++
title = "Access Control"
date = 2026-10-12T00:00:00+00:00
weight = 3
+++

With KDP, access to KubeV is managed entirely in KDP. KubeV has no users, roles or role
bindings of its own, and in KDP mode its dashboard has no **Users**, **Roles** or
**Role Bindings** pages: a link to one says *Managed in KDP*. This page explains who can do
what, and which KDP roles to give your users.

## How a request is authorized

The KubeV API server holds no credentials for KDP. It sends each request to kcp with the
signed-in user's own token, so kcp checks every request against the user's roles in the
project. Where KubeV has to act on its own cluster, for example to open a VM console, it asks
kcp first, as the user.

kcp applies a role change in KDP at once. Three things follow it with a delay:

- an open VM console closes within five minutes of the user losing access;
- the shared objects in [What every project member can see](#what-every-project-member-can-see)
  follow within a minute;
- the KubeV dashboard shows new or removed actions after the user reloads the page.

## Platform administrators

In same-layer mode, the platform administrators are the users named in the installer
configuration: the `kdp.admin` user, or the members of the `kdp.adminGroup` OIDC group. When
both are set, only the group counts. Platform administrators can:

- create organizations and projects in KDP, and list and delete every organization;
- manage the provider workspace, `root:kubev` by default, which holds the KubeV service.

Being a platform administrator doesn't make you a member of the organizations other people
created. An organization's owner adds you there like any other user.

The tasks that affect the whole platform, such as edge routers, quotas and network policies,
are done with `kubectl` on the KubeV cluster. See
[Operating the Platform]({{< ref "../operations" >}}).

In external mode, KubeV adds no platform administrators: whoever administers your KDP manages
KubeV's service there.

## Who sees KubeV in KDP

KDP lists a service in its catalog, and shows its **Open KubeV Virtualization** button, to users
who may bind the service's API, and in projects where the service is already enabled. In
same-layer mode the installer lets every signed-in user bind KubeV's API, so every user sees
KubeV. In external mode you decide who may; see
[Let users see KubeV]({{< ref "../external-kdp#step-6-let-users-see-kubev" >}}).

Seeing KubeV in the catalog doesn't let a user do anything in a project. Inside a project, the
user's roles there decide everything.

## Roles in a project

Members and their roles are managed on the project's **Members** page in KDP. Give users a role
in each project they work in.

When KubeV is enabled in a project, KDP adds a Developer and a Viewer role for the KubeV service,
such as **virtualization.k8c.io Developer**, and includes them in its own **Developer** and
**Member** roles. These are the roles that matter for KubeV:

| KDP role | What it allows in KubeV |
| --- | --- |
| **Owner** | Everything in the project: all KubeV resources and every project page of the KubeV dashboard, plus the project's members and services. |
| **Developer** | Create, change and delete KubeV resources: virtual machines and pools, disks and images, VPCs, subnets, underlay subnets, security groups, NAT gateways and elastic IPs, SSH keys, backups, restores and migration objects. Start, stop and restart VMs, and open their consoles. Manage the project's namespaces. |
| **Access Manager** | What Developer allows, plus managing the project's members and their roles. |
| **Member** | View KubeV resources. Members can't open VM consoles. |
| **Service Manager** | Enable and disable services in the project, KubeV included. It gives no access to KubeV's own resources, but it can read every Secret in the project, including the credentials of backup targets and migration providers. |

{{% notice warning %}}
**Disabling KubeV in a project deletes its resources.** When a service is disabled, kcp deletes
every object of that service in the project, and KubeV then removes them from its cluster: VMs,
their disks and networks included. Only disable KubeV in a project that should lose them.
{{% /notice %}}

### What Developer and Member don't cover

KDP's Developer and Member roles cover the resources KubeV adds to the project. Some KubeV pages
also use standard Kubernetes resources in the project, which those roles don't include:

| Kubernetes resource | Used by |
| --- | --- |
| Secrets | Adding a backup target (its credentials), adding a migration source provider (its vCenter login). |
| Events | The **Events** page, and the events shown on each object. |
| Pods | The serial log on a VM's **Monitoring** tab. |
| Services | **Load Balancers**. |
| NetworkPolicies | **Firewalls**. |
| HorizontalPodAutoscalers | **Auto Scaling**. |
| PersistentVolumeClaims | The volumes behind disks, including the disks of migrated VMs. |

Give users who need these pages the **Owner** role, or create a role that adds them. KDP offers
any ClusterRole labelled for its dashboard on the **Members** page; see
[RBAC](/developer-platform/v1.2/platform-users/rbac/) in the KDP documentation. For example,
created in the project with `kubectl` by one of its owners:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: kubev-workloads
  labels:
    rbac.kdp.k8c.io/display: "true"
  annotations:
    rbac.kdp.k8c.io/display-name: "KubeV Workloads"
    rbac.kdp.k8c.io/description: "Secrets, events, pods, volumes, load balancers, firewalls and autoscalers used by KubeV"
rules:
  - apiGroups: [""]
    resources: ["secrets", "services", "persistentvolumeclaims"]
    verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
  - apiGroups: [""]
    resources: ["events", "pods", "pods/log"]
    verbs: ["get", "list"]
  - apiGroups: ["networking.k8s.io"]
    resources: ["networkpolicies"]
    verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
  - apiGroups: ["autoscaling"]
    resources: ["horizontalpodautoscalers"]
    verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
```

Assign it together with **Developer**, which gives access to the project itself. To include it in
**Developer** for everyone instead, add the label `rbac.kdp.k8c.io/aggregate-to-developer: "true"`.
The role applies only in the project where it is created: repeat it in each project that needs it.

{{% notice warning %}}
**Reading Secrets means reading credentials.** In a KDP project, the vCenter login of a migration
provider and the credentials of a backup target are Secrets in the project. Anyone who may read
Secrets in that namespace can read them, Service Managers included. Grant Secret access with that
in mind.
{{% /notice %}}

## What every project member can see

The KubeV dashboard's forms need a few objects that the whole platform shares, so any role in a
project, Member included, lets a user read them:

- nodes, with their names, labels, addresses, capacity and conditions;
- storage classes, priority classes and CDI storage profiles;
- cluster instance types and preferences;
- the custom resource definitions and the KubeVirt configuration.

They are read-only. Platform administrators can read them too.

## Signing in

Users sign in to KubeV through the same OIDC provider as KDP. When they open KubeV from KDP, the
KubeV dashboard signs them in automatically. With Dex, whether they see a prompt depends on how
they log in, because Dex doesn't remember a sign-in from one application to the next:

| Login | Opening KubeV from KDP |
| --- | --- |
| Google, or another upstream provider that keeps its own session | No password prompt. |
| GitHub | Authorize the application once, then no prompt. |
| Dex local users, LDAP | A password prompt in each new KubeV session. |

If Dex offers more than one login method, users first pick theirs on Dex's page. Dex also asks
them to approve KubeV each time, unless its client has `skipApprovalScreen` set: the installer
sets it on the Dex it deploys, and you set it on a Dex you run yourself.

The button's link carries no credential. Without completing the sign-in, a user gets nothing
from KubeV.
