+++
title = "Consuming Blueprints"
weight = 4
+++

A **Blueprint** is a ready-made composition of several KDP services, published as a single
kind. From a platform user's point of view it behaves like any other service: you enable it
in your organization, then create one object — and KDP provisions all the underlying
resources the Blueprint composes.

If you want to *author* Blueprints rather than consume them, see
[Blueprints]({{< relref "../../service-providers/blueprints" >}}) in the service-provider
guide.

## Finding a Blueprint

Blueprints appear in the [service catalog]({{< relref "../consuming-services#browsing-services" >}})
alongside regular services, marked with a **Blueprint** badge. Each entry shows its title,
category and description — for example an "OrderApp Databases" Blueprint that provisions two
PostgreSQL databases at once.

<!-- TODO(screenshot): service catalog showing a Blueprint badge. -->

## Enabling a Blueprint

Enabling a Blueprint is the same flow as
[enabling a service]({{< relref "../consuming-services#enabling-a-service" >}}): click
**Add to Organization** in the catalog (or create the `APIBinding` manually). This binds the
Blueprint's synthesized kind — served under `<kind>.blueprints.kdp.k8c.io` — into your
workspace.

## Creating an instance

Once bound, create a single object of the synthesized kind. You only fill in the Blueprint's
own fields (its `schema`); KDP expands them into the composed children behind the scenes.

```yaml
apiVersion: database.orderapp.blueprints.kdp.k8c.io/v1alpha1
kind: DatabaseOrderApp
metadata:
  name: orders
  namespace: my-app
spec:
  name: orders
  size: 10Gi
```

Applying this one object causes KDP to create the two `PostgresInstance` children (a primary
and a replica) defined by the Blueprint — you do not create them yourself.

<!-- TODO(screenshot): dashboard create-instance form for a Blueprint. -->

## Checking status

The instance reports aggregate progress in its `status`:

- `status.ready` becomes `true` only once **all** composed children are ready — it is never
  vacuously `true` while the graph is still settling.
- `status.waitingOn` lists the child IDs that are still blocking, and is cleared once
  everything has settled.

```bash
kubectl get databaseorderapp orders -n my-app -o yaml
```

Deleting the instance removes the composed children automatically (they are owned by the
instance) — you do not need to clean them up individually.

## Related topics

- [Consuming Services]({{< relref "../consuming-services" >}}) — enabling and using regular services.
- [Managing Resources]({{< relref "../managing-resources" >}}) — creating and inspecting service objects.
- [Blueprints (authoring)]({{< relref "../../service-providers/blueprints" >}}) — how Blueprints are composed and published.
