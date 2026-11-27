+++
title = "Blueprints"
weight = 4
+++

A **Blueprint** composes several existing [services]({{< ref "/developer-platform/v1.2/introduction/concepts/services" >}})
into a single new one. Instead of asking platform users to create a `PostgresInstance`, a
`Repository` and an `App` separately and wire them together, a platform engineer authors one
Blueprint, for example a `WebappStack`, and publishes it to the service catalogue. Users then
create a single object, and KDP creates all the composed objects, called **children**, for them.

To users, a published Blueprint is just another service. The catalogue marks it with a
**Blueprint** badge.

{{% notice note %}}
Blueprints are in beta. The API and user experience may change before general availability.
{{% /notice %}}

## How a Blueprint is defined

A Blueprint is a `BlueprintDefinition` object (`blueprints.kdp.k8c.io/v1alpha1`, namespaced). Its
core is a [kro](https://kro.run) `ResourceGraphDefinition` in `spec.resourceGraph`, which
describes:

- a **schema**: the new kind's own `spec` and `status`, which users fill in, and
- a list of **resources**: the children to create, with
  [CEL](https://cel.dev) expressions such as `${schema.spec.size}` that pass values from the user's
  object to the children, and from one child to another.

The children must be services that are already published and enabled in the workspace where the
Blueprint is authored. Each child is still handled by its own service and service cluster; the
services don't know they are part of a Blueprint.

## Lifecycle

A `BlueprintDefinition` moves through these phases:

```
Draft -> Validating -> Valid | Invalid -> Published -> Deprecated
```

- **Validation** checks that every kind in the graph is a service enabled in the workspace (a kind
  that doesn't resolve almost always means the service isn't enabled), and that the CEL
  expressions and field references are correct and the graph has no cycles. Problems are listed in
  `status.validationErrors`.
- **Publishing** (`spec.published: true`, while `Valid`) creates an `APIResourceSchema`, an
  `APIExport` and a `Service` in the same workspace. The `Service` is the catalogue entry. The new
  kind is served under `<kind>.blueprints.kdp.k8c.io`.
- **Deprecating** (`spec.deprecated: true`) hides the Blueprint from the catalogue and stops the
  dashboard from creating or editing instances. The API doesn't enforce it, and existing instances
  keep working.

`spec.version` is part of the published kind's identity: raising it publishes a new version.
Setting `spec.published` back to `false` stops reconciling instances but doesn't remove what was
already published.

## Instances

When a user creates an object of a published Blueprint, KDP creates its children and keeps them in
line with the user's object. The object's `Ready` condition becomes true once all children are
ready; until then, its reason and `status.waitingOn` show what it is waiting for. Deleting the
object deletes its children.

## Related topics

- [Blueprints]({{< ref "/developer-platform/v1.2/guides/service-providers/blueprints" >}}):
  authoring and publishing a Blueprint.
- [Consuming Blueprints]({{< ref "/developer-platform/v1.2/guides/platform-users/consuming-blueprints" >}}):
  using one.
