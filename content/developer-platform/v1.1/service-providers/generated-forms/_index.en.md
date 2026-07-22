+++
title = "AI-Generated Forms"
weight = 5
+++

When a platform user creates a resource in the dashboard, KDP renders a form from the
resource's OpenAPI schema. By default this is a **direct, flat rendering**: every field in
schema order, nested objects as nested blocks. It is correct and always works, but for a large
or deeply nested service schema it is a wall of inputs with no grouping or hierarchy.

**AI-Generated Forms** let KDP produce a friendlier create form for a service — fields organised
into meaningful groups with widget types chosen to suit them, generated from the service's own
schema by the platform's AI backend. It is an **opt-in, per-service** feature enabled by the
service provider when [publishing a resource]({{< relref "../publish-resources" >}}).

<!-- TODO: screenshot — before/after: the default flat form vs the grouped AI-generated form for the same service -->
![AI-generated form vs default form](generated-form-comparison.png?classes=shadow,border "Default schema-rendered form (left) and the AI-generated grouped form (right)")

{{% notice note %}}
This is presentation only. It changes how the dashboard *lays out* the create form, not the
resource's schema or its validation. Submitted resources are always validated server-side
against the real schema, and users can still switch to raw YAML at any time.
{{% /notice %}}

## Enabling it

Set `spec.generateUI: true` on the `Service` you publish:

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

With `generateUI` unset (the default), the dashboard uses the direct schema-rendered form.

## How it works

For a `Service` with `generateUI: true`, a KDP controller:

1. Reads each resource schema the service publishes (its `APIResourceSchema`).
2. Sends the schema, plus the resource's group/version/kind, to the platform's AI backend, which
   returns a form layout (a grouped UI structure over the schema's fields).
3. Stores that layout in a `ConfigMap` next to the service, labelled
   `internal.kdp.k8c.io/visibility: hidden` so it does not show up as a normal resource. The
   dashboard reads this ConfigMap when it renders the create form.

The layout is **regenerated automatically when the schema changes.** KDP records a hash of each
processed schema (annotated on the ConfigMap and tracked in the service status), so a new schema
version triggers a fresh layout while an unchanged schema is left untouched. Only the **create
form** is generated this way today.

## Checking status

Generation is asynchronous. Its state is reported on the `Service` through the `UIGeneration`
condition:

```bash
kubectl get service.core.kdp.k8c.io certificate-management \
  -o jsonpath='{.status.conditions[?(@.type=="UIGeneration")]}'
```

The condition reason moves `Pending` → `Succeeded` (or `Failed`), and
`status.lastAppliedUIHashes` lists the schemas already processed. If generation fails the
service keeps working — the dashboard simply falls back to the default schema-rendered form.

## Availability

This feature requires the platform's AI backend to be configured by the operator. If it is not,
`generateUI` has no effect and services use the default form. The same backend powers
[AI-assisted Blueprint authoring]({{< relref "../blueprints#building-blueprints-with-ai" >}}).

## Related topics

- [Publishing Resources]({{< relref "../publish-resources" >}}) — where the `Service` is defined.
- [Blueprints]({{< relref "../blueprints" >}}) — composing services, including AI-assisted authoring.
- [Consuming Services]({{< relref "../../platform-users/consuming-services" >}}) — the platform-user side.
