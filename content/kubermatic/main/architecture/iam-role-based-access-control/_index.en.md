+++
title = "IAM and Role-Based Access Control"
linktitle = "IAM and RBAC"
date = 2020-04-02T12:07:15+02:00
weight = 5

+++

KKP components use OpenID Connect (OIDC) protocol for authentication and RBAC for authorization.
By default, KKP provides [Dex](#authentication-with-dex) as OIDC provider, but you can configure your own provider. For more information,
please refer to the [OIDC provider]({{< ref "../../tutorials-howtos/oidc-provider-configuration" >}}) chapter.

## Authentication with Dex
[Dex](https://dexidp.io/) is an identity service that uses OIDC to drive authentication for KKP components. It acts as a
portal to other identity providers through [connectors](https://dexidp.io/docs/connectors/). This lets Dex defer
authentication to these connectors. Multiple connectors may be configured at the same time. Most popular are:
* [GitHub](https://dexidp.io/docs/connectors/github/)
* [Google](https://dexidp.io/docs/connectors/google/)
* [LDAP](https://dexidp.io/docs/connectors/ldap/)
* [Microsoft](https://dexidp.io/docs/connectors/microsoft/)
* [OAuth 2.0](https://dexidp.io/docs/connectors/oauth/)
* [OpenID Connect](https://dexidp.io/docs/connectors/oidc/)
* [SAML2.0](https://dexidp.io/docs/connectors/saml/)

Check out the [Dex documentation](https://dexidp.io/docs/connectors/) for a list of available providers and how to setup their configuration.

To configure Dex connectors, edit `.dex.connectors` in the `values.yaml`

Example to update or set up Github connector:
```
dex:
    ingress:
    [...]
    connectors:
    - type: github
        id: github
        name: GitHub
        config:
        clientID: <client_id>
        clientSecret: <client_secret>
        redirectURI: https://<your-kkp.domain>/dex/callback
        orgs:
        - name: <your-github-org>
```

And apply the changes to the cluster:

```bash
./kubermatic-installer deploy --config kubermatic.yaml --helm-values values.yaml
```

## Authorization
Authorization is managed at multiple levels to ensure users only have access to authorized resources. KKP uses its own
authorization system to control access to various resources within the platform, including projects and clusters.
Administrators and project owners define and manage these policies and provide specific access control rules for users
and groups.


The Kubernetes Role-Based Access Control (RBAC) system is also used to control access to user cluster level resources,
such as namespaces, pods, and services. Please refer to [Cluster Access]({{< ref "../../tutorials-howtos/cluster-access" >}})
to configure RBAC.

### Kubermatic Kubernetes Platform (KKP) Users
There are two kinds of users in KKP: **admin** and **non-admin** users.

**Admin** users can manage settings that impact the whole Kubermatic installation and users. For example, they can set default
values for cluster creation, like the number of machine Deployment's replica or enforce some integrations, like
[Monitoring and logging stack]({{< ref "../monitoring-logging-alerting/user-cluster/" >}}) on user clusters. All these settings are explained in detail in the [Administration chapter]({{< ref "../../tutorials-howtos/administration" >}}).
Moreover, KKP admins have access to all projects.

On the other hand, **non-admin** users only have access to the projects they are granted. The KKP role they are associated with
determines their access level.

### KKP Roles

A project is an entity that logically groups various resources. All resources in a project can be accessed by users that have the correct role associated with them.
Affiliation of a user to one of the roles gives them certain powers they are allowed to use within a project.

There are three roles: owner, editor, and viewer. These roles are concentric; that is, the owner role includes the permissions
of the editor role, and the editor role includes the permissions of the viewer role.

- **viewer**: read-only access to see project resources
- **editor**: can see the project content that the viewer can view and additionally can create, edit and delete clusters in the project
- **owner**: can do everything that the editor can do and additionally manage permissions for the project

The following table summarizes the permissions

|                                   | Viewer                                                                                                                          | Editor                                                                                                                          | Owner                                                                                                                           |
|-----------------------------------|---------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------|
| cluster [^1]                      | RO                                                                                                                              | RW                                                                                                                              | RW                                                                                                                              |
| cluster nodes (machineDeployment) | RO                                                                                                                              | RW                                                                                                                              | RW                                                                                                                              |
| K8s Dashboard                     | permission relies on [Kubernetes cluster rbac]({{< ref "../../tutorials-howtos/cluster-access" >}})                             | permission relies on [Kubernetes cluster rbac]({{< ref "../../tutorials-howtos/cluster-access" >}})                             | permission relies on [Kubernetes cluster rbac]({{< ref "../../tutorials-howtos/cluster-access" >}})                             |
| Web terminal                      | X                                                                                                                               | permission relies on [Kubernetes cluster rbac]({{< ref "../../tutorials-howtos/cluster-access" >}})                             | permission relies on [Kubernetes cluster rbac]({{< ref "../../tutorials-howtos/cluster-access" >}})                             |
| events                            | RO                                                                                                                              | RO                                                                                                                              | RO                                                                                                                              |
| RBAC (cluster)                    | X                                                                                                                               | RO                                                                                                                              | RO                                                                                                                              |
| addons                            | List                                                                                                                            | RW                                                                                                                              | RW                                                                                                                              |
| applications                      | List                                                                                                                            | RW                                                                                                                              | RW                                                                                                                              |
| system applications               | List                                                                                                                            | RW                                                                                                                              | RW                                                                                                                              |
| OPA Default Constraints           | List                                                                                                                            | List                                                                                                                            | List                                                                                                                            |
| OPA Constraints                   | RO                                                                                                                              | RW                                                                                                                              | RW                                                                                                                              |
| OPA Gatekeeper config             | RO                                                                                                                              | RW                                                                                                                              | RW                                                                                                                              |
| MLA AlertManager config           | RO                                                                                                                              | RW                                                                                                                              | RW                                                                                                                              |
| MLA ruleGroup                     | RO                                                                                                                              | RW                                                                                                                              | RW                                                                                                                              |
| MLA Grafana  UI                   | [grafana organization viewer](https://grafana.com/docs/grafana/latest/administration/roles-and-permissions/#organization-roles) | [grafana organization editor](https://grafana.com/docs/grafana/latest/administration/roles-and-permissions/#organization-roles) | [grafana organization editor](https://grafana.com/docs/grafana/latest/administration/roles-and-permissions/#organization-roles) |
| MLA alertermanager UI             | RW                                                                                                                              | RW                                                                                                                              | RW                                                                                                                              |
| SSH Keys                          | RO                                                                                                                              | RW                                                                                                                              | RW                                                                                                                              |
| project's members                 | X                                                                                                                               | X                                                                                                                               | RW                                                                                                                              |
| project's groups                  | X                                                                                                                               | X                                                                                                                               | RW                                                                                                                              |
| project's service account         | X                                                                                                                               | X                                                                                                                               | RW                                                                                                                              |
| etcd automatic backup             | RO                                                                                                                              | RW                                                                                                                              | RW                                                                                                                              |
| etcd snapshot                     | RO                                                                                                                              | RW                                                                                                                              | RW                                                                                                                              |
| etcd  restore                     | RO                                                                                                                              | RW                                                                                                                              | RW                                                                                                                              |
| cluster Template                  | RO                                                                                                                              | RW                                                                                                                              | RW                                                                                                                              |

[^1]: even owner can not change the settings enforced for the whole KKP installation.

### KKP Service Accounts

A service account is a special type of user account that belongs to the KKP project, instead of to an individual
end-user. A service account is considered as project's resource. Only the owner of a project can create and update a
service account. There is no need to create new groups for service accounts. It’s assigned to one of the already defined
groups: `editors` or `viewers`.
