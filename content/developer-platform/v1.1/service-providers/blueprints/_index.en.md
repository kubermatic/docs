+++
title = "Blueprints"
weight = 3
+++

A **Blueprint** composes several already-published KDP services into a single new,
publishable kind. Instead of asking platform users to create a `PostgresInstance`, a
`Repository` and an `App` separately and wire them together, a platform engineer authors one
Blueprint — for example a `WebappStack` or a pair of databases — publishes it to the service
catalog, and users then create a single object that fans out into all the composed children.

This guide is written for the **Blueprint author** (a platform engineer or service owner).
For consuming a published Blueprint, see
[Consuming Blueprints]({{< relref "../../platform-users/consuming-blueprints" >}}).

## Concepts

A Blueprint is authored as a `BlueprintDefinition` (`blueprints.kdp.k8c.io/v1alpha1`,
namespaced). Its core is a [kro](https://kro.run) `ResourceGraphDefinition` (RGD) stored in
`spec.resourceGraph`, which describes:

- a **schema** — the synthesized kind's own `spec`/`status` (what consumers fill in), and
- a list of **resources** — the child service objects to create, templated with CEL
  references such as `${schema.spec.size}` and cross-references between children.

The child kinds must be **services that are already published and bound** in the workspace
where the Blueprint is authored (each child follows its own
[api-syncagent]({{< relref "../api-syncagent" >}}) path to its service cluster — the
Blueprint layer is invisible to the underlying services).

### Lifecycle

A `BlueprintDefinition` moves through:

```
Draft → Validating → Valid | Invalid → Published → Deprecated
```

- **Validation** checks that every `(apiVersion, kind)` in the graph resolves to a service
  available in the workspace (a kind that does not resolve almost always means the service
  is not **bound**), and that the RGD's CEL expressions, field references and acyclicity are
  correct.
- **Publishing** (`spec.published: true`, while `Valid`) emits three artifacts into the same
  workspace: an `APIResourceSchema`, an `APIExport`, and a `Service` (the catalog entry). The
  synthesized consumer kind is served under `<kind>.blueprints.kdp.k8c.io`.
- **`spec.deprecated: true`** marks the Blueprint as deprecated. This is a hint surfaced by
  the KDP dashboard (which discourages creating new instances) — it is **not enforced by the
  backend**, so instances can still be created via the API. Existing instances keep working.

## Authoring a `BlueprintDefinition`

The example below defines **OrderApp Databases** — a Blueprint that provisions two
`PostgresInstance` databases (a `primary` and a `replica`) that share a common storage size.

```yaml
apiVersion: blueprints.kdp.k8c.io/v1alpha1
kind: BlueprintDefinition
metadata:
  name: database-orderapp
  namespace: default
spec:
  version: v0.1.0
  published: true
  deprecated: false
  # Mirrored onto the generated Service for the catalog / dashboard.
  catalogMetadata:
    title: OrderApp Databases
    category: Databases
    description: Provisions two PostgreSQL databases for the OrderApp, sharing a common storage size.
  # A kro ResourceGraphDefinition, stored verbatim.
  resourceGraph:
    apiVersion: kro.run/v1alpha1
    kind: ResourceGraphDefinition
    metadata:
      name: databaseorderapp
    spec:
      # The synthesized kind consumers will create.
      schema:
        apiVersion: v1alpha1
        kind: DatabaseOrderApp
        spec:
          name: string
          size: string
      # The composed child services.
      resources:
        - id: primary
          template:
            apiVersion: dbms.example.corp/v1alpha1
            kind: PostgresInstance
            metadata:
              name: ${schema.spec.name}-primary
            spec:
              parameters:
                storageSize: ${schema.spec.size}
              writeConnectionSecretToRef:
                name: ${schema.spec.name}-primary-conn
        - id: replica
          template:
            apiVersion: dbms.example.corp/v1alpha1
            kind: PostgresInstance
            metadata:
              name: ${schema.spec.name}-replica
            spec:
              parameters:
                storageSize: ${schema.spec.size}
              writeConnectionSecretToRef:
                name: ${schema.spec.name}-replica-conn
```

Apply it with `kubectl apply -f` in the workspace where the composed services are bound.
Once the object is `Valid` and `published`, the Blueprint appears in the service catalog and
consumers can bind it.

{{% notice note %}}
`spec.version` participates in the published schema's identity. Bumping it publishes a new
version of the synthesized kind; toggling `spec.published` back to `false` stops instance
reconciliation but does **not** remove already-published artifacts.
{{% /notice %}}

## Authoring in the dashboard

The dashboard provides a visual Blueprint builder: a resource-graph editor, an **AI
assistant** panel, and a **Fix with AI** action that repairs an invalid graph. Published
Blueprints get a detail page with an **Overview**, the **Description**, and a **Resource
Graph** you can inspect either as a diagram or as the underlying RGD YAML.

![Blueprint detail — resource graph](blueprint-detail-graph.png?classes=shadow,border "Blueprint detail page: overview and the resource graph diagram")

Switching the Resource Graph panel to **YAML** shows the kro `ResourceGraphDefinition`
backing the Blueprint:

![Blueprint detail — RGD YAML](blueprint-detail-yaml.png?classes=shadow,border "Blueprint detail page: the ResourceGraphDefinition YAML")

## Blueprint logos

A Blueprint can carry a logo for the catalog; the dashboard stores Blueprint logos in
ConfigMaps. Set it through the dashboard's Blueprint editor.

## Related topics

- [Consuming Blueprints]({{< relref "../../platform-users/consuming-blueprints" >}}) — the platform-user side.
- [Publishing Resources]({{< relref "../publish-resources" >}}) — how the composed services are published in the first place.
- [Consuming Services]({{< relref "../../platform-users/consuming-services" >}}) — binding services (a prerequisite for composing them).
