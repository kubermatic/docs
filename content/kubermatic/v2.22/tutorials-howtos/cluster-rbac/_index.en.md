+++
title = "Cluster RBAC"
date = 2023-01-20T14:37:15+02:00
weight = 14

+++

This manual explains how to configure Role-Based Access Control (a.k.a RBAC) on user clusters.

## Concepts
You can grant permission to 3 types of subjects:
* `user`: end user identified by their email
* `group`: named collection of users
* `service account`: a Kubernetes service account that authenticates a process (e.g. Continuous integration)

You can either grant permission on the whole cluster or on specific namespaces by creating bindings.

The RBAC view is organized by subjects. You can choose the subject thanks to the dropbox selector and grant or remove
permission by adding or removing binding.
![list user rbac](/img/kubermatic/v2.22/ui/rbac_user_view.png?classes=shadow,border "list user rbac")
![list group rbac](/img/kubermatic/v2.22/ui/rbac_group_view.png?classes=shadow,border "list group rbac")
![list service account rbac](/img/kubermatic/v2.22/ui/rbac_sa_view.png?classes=shadow,border "list service account rbac")


## Role-Based Access Control Predefined Roles
KKP provides predefined roles and cluster roles to help implement granular permissions for specific resources
and simplify access control across the user cluster. All of the default roles and cluster roles are labeled
with `component=userClusterRole`.

###  Cluster Level

| Default ClusterRole | Description                                                                                                                                                                                                                          |
|---------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| cluster-admin       | Allows admin access. Allows read/write access to most resources in a namespace, including creating roles and role bindings within the namespace. This role does not allow write access to resource quota or to the namespace itself. |
| edit                | Allows read/write access to most objects in a namespace. This role does not allow viewing or modifying roles or role bindings. However, this role allows accessing secrets and running pods as any service account in the namespace  |
| view                | Allows read-only access to see most objects in a namespace. It does not allow viewing roles or role bindings.                                                                                                                        |
| list-namespaces     | Allows to list namespaces                                                                                                                                                                                                            |

### Namespace Level

| Default Role     | Description                                                                                                                                         |
|------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------|
| namespace-admin  | Allows admin access. Allows read/write access to most resources in a namespace.                                                                     |
| namespace-editor | Allows read/write access to most objects in a namespace. This role allows accessing secrets and running pods as any service account in the namespace|
| namespace-viewer | Allows read-only access to see most objects in a namespace.                                                                                         |



# Manage User Permissions
You can grant permissions to a group by clicking on `add Bindings`.
![Grant permission to a user](/img/kubermatic/v2.22/ui/rbac_user_binding.png?classes=shadow,border "Grant permission to a user")

{{% notice info %}}
The cluster owner is automatically connected to the `cluster-admin` cluster role.
{{% /notice %}}

## Manage Group Permissions
Group are named collection of users. You can grant permission to a group by clicking on `add Bindings`.
![Grant permission to a group](/img/kubermatic/v2.22/ui/rbac_group_binding.png?classes=shadow,border "Grant permission to a Group")

In this example, we grant the role `view` on the cluster to the OIDC group `security-audit`

{{% notice warning %}}
If you want to bind an OIDC group, you must prefix the group's name with `oidc:`  
The kubernetes API Server automatically adds this prefix to prevent conflicts with other authentication strategies
{{% /notice %}}


## Manage Service Account Permissions
Service accounts are designed to authenticate processes like Continuous integration (a.k.a CI).  
In this example, we will:
* create a Service account
* grant permission to 2 namespaces
* download the associated kubeconfig that can be used to deploy workload into these namespaces.

### Create a Service Account
Service accounts are namespaced objects. So you must choose in which namespace you will create it. The namespace where
the service account live is not related to the granted permissions.  
To create a service account, click on `Add Service Account`
![create service account in user cluster](/img/kubermatic/v2.22/ui/rbac_sa_creation.png?classes=shadow,border "Create service account in user cluster")

In this example, we create a service account named `ci` into `kube-system` namespace.

## Grant Permissions to Service Account
You can grant permission by clicking on `Add binding`
![Grant permission to service account](/img/kubermatic/v2.22/ui/rbac_sa_binding.png?classes=shadow,border "Grant permission to service account")

In this example, we grant the permission `namespace-admin` on the namespace `app-1` to service account `CI` of the namespace `kube-system`.

{{% notice info %}}
You can see and remove binding by unfolding the service account.
{{% /notice %}}


### Download Service Account kubeconfig
Finally, you can download the service account's kubeconfig by clicking on the download icon.
![download service account's kubeconfig](/img/kubermatic/v2.22/ui/rbac_sa_download_kc.png?classes=shadow,border "Download service account's kubeconfig")

{{% notice info %}}
You can edit service account's permissions at any time. There is no need to download the kubeconfig again.
{{% /notice %}}

### Delete a Service Account
You can delete a service account by clicking on the trash icon. Deleting a service account also deletes all associated binding.

## Debugging
The best way to debug authorizing problems is to enable [audit logging]({{< ref "../audit-logging/" >}})
and checks audit logs. For example, check the user belongs to the expected groups (see `.user.groups`)
