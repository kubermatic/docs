+++
title = "Blueprints (Beta)"
weight = 4
aliases = ["/developer-platform/v1.2/service-providers/blueprints/"]
+++

A **Blueprint** composes several already-published KDP services into a single new service,
publishable kind. Instead of asking platform users to create a `PostgresInstance`, a
`Repository` and an `App` separately and wire them together, a platform engineer authors one
Blueprint (for example a `WebappStack` or a pair of databases), publishes it to the service
catalogue, and users then create a single object that fans out into all the composed children.

{{% notice note %}}
Blueprints are currently in beta. The API and user experience may change before general
availability.
{{% /notice %}}

This guide is written for the **Blueprint author** (a platform engineer or service owner).
For consuming a published Blueprint, see
[Consuming Blueprints]({{< ref "/developer-platform/v1.2/guides/platform-users/consuming-blueprints" >}}).

## Concepts

A Blueprint is authored as a `BlueprintDefinition` (`blueprints.kdp.k8c.io/v1alpha1`,
namespaced). Its core is a [kro](https://kro.run) `ResourceGraphDefinition` (RGD) stored in
`spec.resourceGraph`, which describes:

- a **schema**: the synthesised kind's own `spec`/`status` (what consumers fill in), and
- a list of **resources**: the child service objects to create, templated with CEL
  references such as `${schema.spec.size}` and cross-references between children.

The child kinds must be **services that are already published and bound** in the workspace
where the Blueprint is authored (each child follows its own
[api-syncagent]({{< ref "/developer-platform/v1.2/introduction/concepts/api-syncagent" >}}) path to its service cluster; the
Blueprint layer is invisible to the underlying services).

### Lifecycle

A `BlueprintDefinition` moves through:

```
Draft -> Validating -> Valid | Invalid -> Published -> Deprecated
```

- **Validation** checks that every `(apiVersion, kind)` in the graph resolves to a service
  available in the workspace (a kind that does not resolve almost always means the service
  is not **bound**), and that the RGD's CEL expressions, field references and acyclicity are
  correct.
- **Publishing** (`spec.published: true`, while `Valid`) emits three artifacts into the same
  workspace: an `APIResourceSchema`, an `APIExport`, and a `Service` (the catalogue entry). The
  synthesised consumer kind is served under `<kind>.blueprints.kdp.k8c.io`.
- **`spec.deprecated: true`** marks the Blueprint as deprecated. KDP copies the flag onto
  the generated `Service`, so the dashboard hides the Blueprint from the service catalogue and
  blocks creating or editing instances there. It is **not enforced by the API**, so instances can
  still be created with `kubectl`. Existing instances keep working.

## Authoring a `BlueprintDefinition`

The example below defines **OrderApp Databases**, a Blueprint that provisions two
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
Once the object is `Valid` and `published`, the Blueprint **appears in the service catalogue as
just another service**: the same entry, the same **Add to Organization** flow, the same
`APIBinding`. Consumers never have to know it is a composition: they enable it and create one
object, exactly as they would for a single service.

{{% notice note %}}
`spec.version` participates in the published schema's identity. Bumping it publishes a new
version of the synthesised kind; toggling `spec.published` back to `false` stops instance
reconciliation but does **not** remove already-published artifacts.
{{% /notice %}}

### Creating a variable number of children

To let consumers choose how many children an instance creates, use a kro collection: add
`forEach` to a resource and iterate over a list in the instance's spec. This version of the
example creates one database per name in `spec.databases`:

```yaml
      schema:
        apiVersion: v1alpha1
        kind: DatabaseSet
        spec:
          name: string
          databases: "[]string"
          size: string
      resources:
        - id: databases
          forEach:
            - db: ${schema.spec.databases}
          template:
            apiVersion: dbms.example.corp/v1alpha1
            kind: PostgresInstance
            metadata:
              name: ${schema.spec.name}-${db}
            spec:
              parameters:
                storageSize: ${schema.spec.size}
```

Each `forEach` entry is one dimension; with several, kro creates one child for every
combination. Every dimension's variable must appear in the child's `metadata.name`, so that each
child gets a unique name. KDP allows at most 64 children per collection resource and instance,
because the consumer, not the Blueprint author, decides the size of the list.

## Authoring in the dashboard

Open **Blueprints** in the sidebar. The entry is hidden unless your platform administrator has
turned on the `service-composition-enabled` feature flag in the dashboard's Helm values. If the
workspace doesn't use Blueprints yet, click **Enable Blueprints** first.

Click **Create Blueprint** and fill in the name, display name, version, description, category and
logo. You write the resource graph as **YAML**; the **Service** and **Resource Type** pickers insert
a snippet for one of your bound services. The **AI Assistant** button opens a drawer that drafts
and edits that YAML for you (see [Building Blueprints with AI](#building-blueprints-with-ai)
below). The editor has no graph view, and you can't build the graph by dragging nodes.

From the Blueprints list you can **Edit**, **Publish**, **Deprecate** and **Delete** a Blueprint.
Each Blueprint gets a detail page with an **Overview**, the **Description**, and a **Resource Graph**
you can inspect either as a read-only diagram or as the underlying RGD YAML. If validation
failed, the detail page lists the **Validation Errors** with a **Fix with AI** link.

![Blueprint detail: resource graph](blueprint-detail-graph.png?classes=shadow,border "Blueprint detail page: overview and the resource graph diagram")

Switching the Resource Graph panel to **YAML** shows the kro `ResourceGraphDefinition`
backing the Blueprint:

![Blueprint detail: RGD YAML](blueprint-detail-yaml.png?classes=shadow,border "Blueprint detail page: the ResourceGraphDefinition YAML")

### Building Blueprints with AI

Writing a kro `ResourceGraphDefinition` by hand means knowing the exact kind, `apiVersion`,
fields and CEL wiring of every service you compose, plus kro's `SimpleSchema` grammar for the
knobs you expose. The **AI assistant** in the dashboard's Blueprint editor lets you describe the
outcome in plain language and drafts that YAML for you.

<!-- TODO: screenshot: the AI Assistant drawer open next to the YAML resource graph field, with a prompt typed in -->
![Blueprint editor: AI assistant](blueprint-ai-assistant.png?classes=shadow,border "The AI assistant panel in the dashboard's Blueprint editor")

**What it's grounded in.** The assistant is given the services currently **bound in your
workspace** as its only building blocks, each with its real schema. It composes *only* those
kinds, and this is enforced: if a draft references a kind that isn't one of your bound services,
it is rejected rather than shown. This is the same constraint you would hit authoring by hand:
a Blueprint can only compose services that resolve in the workspace. Alongside the graph the
assistant also suggests a display name, description and category, which fill those form fields
if they are still empty.

The assistant works in three modes:

| Mode | When | What it does |
|------|------|--------------|
| **Create** | Empty editor | Drafts a new resource graph from your description. |
| **Edit** | Existing graph | Applies your request as a *minimal* change, preserving unrelated resources and fields. |
| **Fix with AI** | Validation failed | Takes the current graph plus the controller's validation errors and proposes a minimal repair, without redesigning the graph. |

**Example.** The prompt *"Two PostgreSQL databases, a primary and a replica, that share one
storage-size setting"*, run against a workspace where a `PostgresInstance` service is bound,
drafts a graph with a `size` knob on the Blueprint's own schema wired into both child
databases, much like the [OrderApp Databases](#authoring-a-blueprintdefinition) example above.

**Review before publishing.** The output is a **draft** loaded into the editor; nothing is
published automatically. It goes through exactly the same lifecycle as a hand-written graph
(`Draft -> Validating -> Valid`) before you set `spec.published: true`, and it is checked to be
structurally well-formed (valid kro spec, single-pipe `SimpleSchema` markers, resources limited
to your bound services) before it ever reaches the editor.

{{% notice warning %}}
The assistant can make mistakes. The structural checks and Blueprint validation catch malformed
or unresolvable graphs, but they do not know your *intent*. Read the draft and confirm it
composes the services you meant, with the field wiring and defaults you want, before publishing.
{{% /notice %}}

{{% notice note %}}
The AI assistant requires an OpenAI-compatible model configured by the operator on the dashboard
deployment. Setting `api.config.openaiKey` is enough; `api.config.openaiModel` is optional. The
panel and the **Fix with AI** button are unavailable when no key is set, or when the
`ai-blueprints-enabled` feature flag is off (it is on by default). You then author resource
graphs manually. The same backend powers
the [UI Builder]({{< ref "/developer-platform/v1.2/guides/service-providers/ui-builder" >}}).
{{% /notice %}}

## Blueprint logos

A Blueprint can carry a logo for the catalogue. In the dashboard's Blueprint editor, either
upload a file or enter a URL. Uploaded logos are stored on the KDP storage server, and the
logo's URL is copied to the generated `Service`.

## Service Catalogue

Publishing a Blueprint places it **in the service catalogue as a service**. The generated
`Service` object *is* the catalogue entry, and it sits next to the regular services: the same
card, the same search and sorting, the same **Add to organization** button. The only
visible difference is a **Blueprint** badge marking the entry as a composition. Everything
else a consumer does with it is ordinary service consumption.

The entry's title, category and description come from the `spec.catalogMetadata` you set on the
`BlueprintDefinition`; the badge and the logo are added by the dashboard.

<img src="blueprint-service-catalogue.png" alt="OrderApp Databases in the service catalogue" title="The OrderApp Databases Blueprint in the service catalogue, listed as a service and marked with a Blueprint badge" width="600" height="275">

For the consumer's side of this (enabling the entry and creating an instance), see
[Consuming Blueprints]({{< ref "/developer-platform/v1.2/guides/platform-users/consuming-blueprints" >}}).

## Related topics

- [Consuming Blueprints]({{< ref "/developer-platform/v1.2/guides/platform-users/consuming-blueprints" >}}): the platform-user side.
- [Publishing Resources]({{< ref "/developer-platform/v1.2/guides/service-providers/publish-resources" >}}): how the composed services are published in the first place.
- [Consuming Services]({{< ref "/developer-platform/v1.2/guides/platform-users/consuming-services" >}}): binding services (a prerequisite for composing them).
- [UI Builder]({{< ref "/developer-platform/v1.2/guides/service-providers/ui-builder" >}}): the other AI-assisted authoring feature.
