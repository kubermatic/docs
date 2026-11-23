+++
title = "Services"
weight = 2
+++

A **service** in KDP is a set of Kubernetes resource types, such as `Certificate` or
`PostgresInstance`, that a service provider offers to platform users. Users enable a service in
their workspace and then create objects of those types, much like custom resources in a normal
cluster. A KDP service is not a Kubernetes `Service`.

Every service has its own API group, such as `databases.example.com`, and offers some or all of
the resource types in it.

## Where the work happens

KDP itself only stores the objects. The work is done on the provider's **service cluster**:

1. A user creates an object, such as a `PostgresInstance`, in their workspace.
2. The provider's [api-syncagent]({{< ref "/developer-platform/v1.2/introduction/concepts/api-syncagent" >}})
   copies it to the service cluster.
3. Operators there, such as Crossplane, do the actual work, for example creating a database.
4. The api-syncagent copies the object's status back to the user's workspace. It also copies
   **related resources**, such as a Secret with the database's connection details.

The provider runs and scales the service cluster for everybody who uses the service.

## From provider to consumer

A service passes through these objects in kcp:

| Object | Where | Created by | Purpose |
| ------ | ----- | ---------- | ------- |
| `Service` (`core.kdp.k8c.io`) | Provider's organisation or project | Provider | Registers the service: its API group, catalogue details, and where KDP writes the api-syncagent's kubeconfig. |
| `APIExport` | Provider's workspace | KDP, from the `Service` | The kcp object that makes the API available to other workspaces. It has the same name as the `Service`. |
| `APIResourceSchema` | Provider's workspace | api-syncagent | One per published resource type, like a CRD. Created from the provider's `PublishedResource` objects. |
| Catalogue entry | Read-only view | KDP | What consumers see in the service catalogue: title, description, logo and permission claims, but not the `Service` itself. |
| `APIBinding` | Consumer's organisation or project | Consumer | Enabling the service. Makes its resource types available in that workspace. |

So publishing a service takes two steps on the provider's side: creating the `Service` (see
[Your First Service]({{< ref "/developer-platform/v1.2/guides/service-providers/your-first-service" >}}))
and publishing resource types into it with the api-syncagent (see
[Publishing Resources]({{< ref "/developer-platform/v1.2/guides/service-providers/publish-resources" >}})).
Until resource types are published, consumers can enable the service but have nothing to create.

## Permission claims

A service sometimes needs to work with objects in the consumer's workspace beyond its own types.
For example, it may need to create Secrets with connection details. It asks for this access with
**permission claims**, listed in the catalogue entry. The consumer decides which claims to accept
when enabling the service and can change them later. A service whose claims aren't accepted may
work only partly.

## Roles for a service

When a consumer enables a service with **Create default roles for resources managed by this
service**, KDP creates a developer and a viewer role for the service's resource types in that
workspace, and adds them to the general Developer and Member roles. See
[RBAC]({{< ref "/developer-platform/v1.2/introduction/concepts/rbac" >}}).

## Restrictions

Providers can limit how their service is used:

- **Deprecated** services disappear from the catalogue, and the dashboard stops creating and
  editing their objects.
- **Workspace type restrictions** keep a service out of organisations or out of projects. KDP
  rejects new objects there.

See [Configuring Services]({{< ref "/developer-platform/v1.2/guides/service-providers/configuring-services" >}}).

## Related topics

- [Consuming Services]({{< ref "/developer-platform/v1.2/guides/platform-users/consuming-services" >}})
- [Managing Resources]({{< ref "/developer-platform/v1.2/guides/platform-users/managing-resources" >}})
- [Blueprints]({{< ref "/developer-platform/v1.2/introduction/concepts/blueprints" >}}): services
  composed from other services.
