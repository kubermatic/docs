+++
title = "The KDP Servlet"
linkTitle = "The Servlet"
weight = 3
+++

The Servlet is the component in KDP responsible for integrating external Kubernetes clusters.
It runs on a cluster, is configured with KDP credentials and will then synchronize data out
of KDP (i.e. out of kcp workspaces) onto the local cluster, and vice versa.

The name Servlet is an obvious reference to the "kubelet" in a regular Kubernetes cluster.

## High-level Overview

The intended usecase follows roughly these steps:

1. A user in KDP with sufficient permissions creates a `Service` inside their organization
   workspace. This service (not to be confused with Kubernetes services) reserves an API group
   in the organization for itself, like `databases.example.corp` (two `Services` must not register
   the same API group).
2. After the `Service` is created, KDP will reconcile it and provide appropriate credentials
   for the Servlet (e.g. by creating a Kubernetes Secret with a preconfigured kubeconfig in it).
3. A service owner will now take these credentials and the configured API group and use them
   to setup the Servlet. It is assumed that the service owner (i.e. the cluster-admin in a
   service cluster) wants to make some resources (usually CRDs) available to use inside of KDP.
4. The service owner uses the Servlet Helm chart (or similar deployment technique) to install the
   Servlet in their cluster. This in itself won't do much besides registering the Servlet in the
   platform by setting a `status` on the Service object (there might also be a need to not just
   have the `Service` object, but also a Servlet object).
5. To actually make resources available in the platform, the service owner now has to create a
   set of `PublishedResource` objects. The configuration happens from their point of view, meaning
   they define how to publish a CRD in the platform, defining renaming rules and other projection
   settings.
6. Once a `PublishedResource` is created in the service cluster, the Servlet will pick it up,
   find the referenced CRD, convert/project this CRD into an `APIResourceSchema` (ARS) for kcp and
   then create the ARS in org workspace.
7. Finally the Servlet will take all `PublishedResources` and bundle them into a single `APIExport`
   in the org workspace. This APIExport can then be bound in the org workspace itself (or later
   any sub workspaces (depending on permissions)) and be used there. The `APIExport` has the same
   name as the KDP `Service` the Servlet is working with.
8. kcp automatically provides a virtual workspace for the `APIExport` and this is what the Servlet
   then uses to watch all objects for the relevant resources in the platform (i.e. in all workspaces).
9. The Servlet will now begin to synchronize objects back and forth between the service cluster
   and KDP.

## Details

### Data Flow Direction

It might be a bit confusing at first: The `PublishedResource` CRD describes the world from the
standpoint of a service owner, i.e. a person or team that owns a Kubernetes cluster and is tasked
with making their CRDs available in KDP (i.e. "publish" them).

However the actual data flow later will work in the opposite direction: users creating objects inside
their kcp workspaces serve as the source of truth. From there they are synced down to the service
cluster, which is doing the projection of the `PublishedResource` _in reverse_.

Of course additional, auxiliary (related) objects could originate on the service cluster. For example
if you create a Certificate object in a kcp workspace and it's synced down, cert-manager will then
acquire the certificate and create a Kubernetes `Secret`, which will have to be synced back up (into
a kcp workspace, where the certificate originated from). So the source of truth can also be, for
auxiliary resources, on the service cluster.

### Servlet Naming

Each Servlet must have a name, like "tom" or "mary". The FQ name for a Servlet is
`<servletname>.<service apigroup>`, so if the user in KDP had created a new `Service` named
`databases.examplecorp`, the name of the Servlet that serves this Service (sic) could be
`tom.databases.examplecorp`.

### Uniqueness

A single `Service` in KDP must only be processed by exactly 1 Servlet. There is currently no mechanism
planned to subdivide a `Service` into chunks, where multiple service clusters (and therefore multiple
Servlets) could process each chunk.

Later the Servlet might be extended with Label Selectors, alternatively they might also "claim" any
object by annotating it in the kcp workspace. These things are not yet worked out, so for now we have
this 1:1 restriction.

Servlets make use of leader election, so it's perfectly fine to have multiple Servlet replicas, as
long as only one them is leader and actually doing work.

### kcp-awareness

controller-runtime can be used in a "kcp-aware" mode, where the cache, clients, mappers etc. are
aware of the workspace information. This however is neither well tested upstream and the code would
require shard-admin permissions to behave like this work regular kcp workspaces. The controller-runtime
fork's kcp-awareness is really more geared towards working in virtual workspaces.

Because of this the Servlet needs to get a kubeconfig to KDP that already points to the org's
workspace (i.e. the `server` already contains a `/clusters/root:myorg` path). The basic controllers
in the Servlet then treat this as a plain ol', regular Kubernetes cluster (no kcp-awareness).

To this end, the Servlet will, upon startup, try to access the `cluster` object in the target
workspace. This is to resolve the cluster name (e.g. `root:myorg`) into a logicalcluster name (e.g.
`gibd3r1sh`). The Servlet has to know which logicalcluster the target workspace represents in order
to query resources properly.

Only the controllers that are later responsible for interacting with the virtual workspace are
kcp-aware. They have to be in order to know what workspace a resource is living in.

### PublishedResources

A `PublishedResource` describes which CRD should be made available inside KDP. The CRD name can be
projected (i.e. renamed), so a `kubermatic.k8c.io/v1 Cluster` can become a
`cloud.examplecorp/v1 KubernetesCluster`.

In addition to projecting (mapping) the GVK, the `PublishedResource` also contains optional naming
rules, which influence how the local objects that the Servlet is creating are named.

As a single Servlet serves a single Service, the API group used in KDP is the same for all
`PublishedResources`. It's the API group configured in the KDP `Service` inside the platform (created
in step 1 in the overview above).

To prevent chaos, `PublishedResources` are immutable: handling the case that a PR first wants to
publish `kubermatic.k8c.io/v1 Cluster` and then suddenly `kubermatic.k8c.io/v1 User` resources would
mean to re-sync and cleanup everything in all affected kcp workspaces. The Servlet would need to be
able to delete and recreate objects to follow this GVK change, which is a level of complexity we
simply do not want to deal with at this point in time. Also, `APIResourceSchemas` are immutable
themselves.

More information is available in the [Publishing Resources]({{< relref "../publish-resources" >}})
guide.

### APIExports

An `APIExport` in kcp combines multiple `APIResourceSchemas` (ARS). Each ARS is created based on a
`PublishedResource` in the service cluster.

To prevent data loss, ARS are never removed from an `APIExport`. We simply do not have enough
experience to really know what happens when an ARS would suddenly become unavailable. To prevent
damage and confusion, the Servlet will only ever add new ARS to the one `APIExport` it manages.

## Controllers

### apiexport

This controller aggregates the `PublishedResources` and manages a single `APIExport` in KDP.

### apiresourceschema

This controller takes `PublishedResources`, projects and converts them and creates `APIResourceSchemas`
in KDP.

### register

This controller updates the status on the KDP `Service` object, to let the system know that a Servlet
has picked up the Service and is serving it. In the future this controller might also create/update
a `Servlet` object, akin to how the Kubernetes kubelet creates and maintains a `Node` object.

### syncmanager

This controller watches the `APIExport` and waits for the virtual workspace to become available. It
also watches all `PublishedResources` (PRs) and reconciles when any of them is changed (they are
immutable, but the controller is still reacting to any events on them).

The controller will then setup a controller-runtime `Cluster` abstraction for the virtual workspace
and then start many `sync` controllers (one for each `PublishedResource`). Whenever PRs change, the
syncmanager will make sure that the correct set of `sync` controller is running.

### sync

This is where the meat and potatoes happen. The sync controller is started for a single
`PublishedResource` and is responsible for synchronizing all objects for that resource between the
local service cluster and KDP.

The `sync` controller was written to handle a single `PublishedResource` so that it does not have to
deal with dynamically registering/stopping watches on its own. Instead the sync controller can be
written as more or less "normal" controller-runtime controller.
