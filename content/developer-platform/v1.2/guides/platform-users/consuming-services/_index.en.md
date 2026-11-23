+++
title = "Consuming Services"
weight = 4
aliases = ["/developer-platform/v1.2/platform-users/consuming-services/"]
+++

This document describes how to use (consume) Services offered in KDP.

## Background

A "service" in KDP defines a unique Kubernetes API Group and offers a number of resources (types) to
use. A service could offer certificate management, databases, cloud infrastructure or any other set
of Kubernetes resources.

Services are provided by service owners, who run their own Kubernetes clusters and take care of the
maintenance and scaling tasks for the workload provisioned by all users of the service(s) they
offer.

A KDP Service should not be confused with a Kubernetes Service. Internally, a KDP Service is
ultimately translated into a kcp `APIExport` with a number of `APIResourceSchemas` (~ CRDs).

## Browsing Services

Log in to the KDP dashboard and open an organisation or project. Click **Service Catalog** in the
header to see the services you can add. Each tile shows:

- the service's title (the human-readable name, like "Certificate Management"),
- a short description,
- its category,
- the workspace that provides it.

Search matches the name, title, description and category, and **Sort by:** orders the tiles. Turn
on **Hide added services** to show only services you haven't added yet. You can switch between a
grid and a table. Click a tile to see its details, including its internal name: the name of the
`Service` object, which you need to enable the service with `kubectl`.

Deprecated services, and services that aren't allowed in the current kind of workspace, are not
shown.

<!-- TODO(screenshot): capture the Service Catalogue page with search, "Hide added services" and the grid/table switch. -->
![Service Catalogue](service-catalog.jpg?classes=shadow,border&height=200 "Service Catalogue page showing the available services")

To see the services already added here, open **Services** in the sidebar and select the
**Subscriptions** tab. The tab previously labelled "External Services" is now called
**Subscriptions**. Its **Add Services** button lists the services you can still add, without
leaving the page.

Check out [Your First Service]({{< ref "/developer-platform/v1.2/guides/service-providers/your-first-service" >}}) if you want to publish services by yourself.

## Enabling a Service

Click **Add to organization** (or **Add to project**) on a service in the catalogue. A dialog with
the same title opens to confirm adding the service:

<!-- TODO(screenshot): re-capture the add-service dialog; its title is now "Add to organization" / "Add to project". -->
![Add Service Wizard](add-service-wizard.png?classes=shadow,border&height=200 "Dialog for adding a service to the workspace, showing options for creating default roles and resource claims")

Several options are offered when adding a service:

- **Create default roles for resources managed by this service** creates a "Developer" and a
  "Viewer" role for this service in the workspace, so you can give people different levels of
  access to it. This is optional, but without it you have to create roles yourself.
- The **Resources** section lists the resources the service asks access to (its permission
  claims), for example to read or write Secrets that belong to its objects. They come from the
  service catalogue and are all selected by default. Service owners should handle a refused claim
  gracefully, but the service will probably work less well. To change your choice later, choose
  **Update Permissions** in the service's menu on the **Services** page.

### Manually

Alternatively, create the `APIBinding` object yourself. This section assumes that you are familiar
with [kcp on the Command Line]({{< ref "/developer-platform/v1.2/references/kcp-command-line" >}}) and have the kcp kubectl plugin installed.

First you need to get the kubeconfig for accessing your kcp workspaces. Once you have set your
kubeconfig up, make sure you're in the correct namespace by using
`kubectl ws <path to your workspace>`. Use `kubectl ws .` if you're unsure where you're at.

To enable a Service, use `kcp bind apiexport` and specify the path to and name of the `APIExport`.

```bash
# kubectl kcp bind apiexport <path to KDP Service>:<API Group of the Service>
kubectl kcp bind apiexport root:my-org:my.fancy.api
```

Without the plugin, you can create an `APIBinding` manually, simply `kubectl apply` this:

```yaml
apiVersion: apis.kcp.io/v1alpha1
kind: APIBinding
metadata:
  name: my.fancy.api
spec:
  reference:
    export:
      name: my.fancy.api
      path: root:my-org
```

Shortly after, the new API will be available in the workspace. Check via `kubectl api-resources`.
You can now create objects for types in that API group to your liking and they will be synced and
processed behind the scenes.

Note that a Service often has related resources, often Secrets and ConfigMaps. You must explicitly
allow the Service to access these in your workspace and this means editing/patching the `APIBinding`
object (the kcp kubectl plugin currently has no support for managing permission claims). For each of
the claimed resources, you have to accept or reject them:

```yaml
spec:
  permissionClaims:
    # Nearly all Services in KDP require access to namespaces, rejecting this will
    # most likely break the Service, even more than rejecting any other claim.
    - all: true
      resources: namespaces
      state: Accepted
    - all: true
      resources: secrets
      state: Accepted # or Rejected
```

Rejecting a claim will severely impact a Service, if not even break it. Consult with the Service's
documentation or the service owner if rejecting a claim is supported.

When you *change into* (`kubctl ws ...`) a different workspace, kubectl will inform you if there are
outstanding permission claims that you need to accept or reject.
