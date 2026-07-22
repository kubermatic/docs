+++
title = "AI-Generated Forms"
weight = 5
+++

By default the dashboard renders a resource's create form directly from its OpenAPI schema:
every field in schema order, nested objects as nested blocks. It is correct and always works,
but for a large or deeply nested schema it is a wall of inputs with no grouping or hierarchy.

The **UI Builder** lets a service provider design custom **Form**, **List** and **Detail** views
for a service's resources by describing them in plain language, and save them so everyone using
that service gets the tailored UI. It is generated from the service's own schema by the
platform's AI backend.

<!-- TODO: screenshot — the UI Builder page: chat panel on the left, live preview on the right -->
![The UI Builder](ui-builder.png?classes=shadow,border "The UI Builder: describe the UI in the chat panel, preview it live, then save")

{{% notice note %}}
This is presentation only. It changes how the dashboard *lays out* a resource's views, not the
resource's schema or its validation. Submitted resources are always validated server-side
against the real schema, and users can still switch to raw YAML at any time.
{{% /notice %}}

## Using the UI Builder

From a service, open the **UI Builder** and:

1. Pick the **resource type** (top-right) and the view you want to design — **Form**, **List**
   or **Detail**.
2. Describe what you want in the **chat** panel ("group the settings into collapsible sections",
   "highlight the required fields at the top"), or start from one of the example prompts.
3. Watch the result in the live **Preview**; inspect the underlying **JSON** or the **Data** it
   binds to.
4. Refine with follow-up messages until it looks right, then **Save**. The saved layout is what
   the dashboard renders for that resource from then on.

Be specific about the fields and their types — the more precise the prompt, the closer the first
result.

## Automatic first draft

Set `spec.generateUI: true` on the `Service` you publish and KDP generates an initial UI from
the schema, so the Builder opens with something to refine rather than a blank slate:

```yaml
apiVersion: core.kdp.k8c.io/v1alpha1
kind: Service
metadata:
  name: certificate-management
spec:
  apiGroup: certificates.example.corp
  generateUI: true
  catalogMetadata:
    title: Certificate Management
    description: Acquire certificates signed by Example Corp's internal CA.
```

Generation is asynchronous; its state is reported on the `Service` through the `UIGeneration`
condition (`Pending` → `Succeeded` or `Failed`). With `generateUI` unset (the default) the
dashboard uses the direct schema-rendered form until you build one.

## Keeping the UI in sync

A saved UI is tied to the schema it was built against. When a resource's schema changes, the
dashboard flags the saved UI as **outdated** and shows a banner linking back to the UI Builder,
where you can **regenerate** it against the new schema. Until then the resource keeps working on
its existing UI.

## Availability

The UI Builder requires the platform's AI backend to be configured by the operator. If it is
not, `generateUI` has no effect and services use the default schema-rendered form. The same
backend powers [AI-assisted Blueprint authoring]({{< relref "../blueprints#building-blueprints-with-ai" >}}).

## Related topics

- [Publishing Resources]({{< relref "../publish-resources" >}}) — where the `Service` is defined.
- [Blueprints]({{< relref "../blueprints" >}}) — composing services, including AI-assisted authoring.
- [Consuming Services]({{< relref "../../platform-users/consuming-services" >}}) — the platform-user side.
