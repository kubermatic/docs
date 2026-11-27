+++
title = "Configuring Services"
weight = 6
+++

Once a service exists (see
[Your First Service]({{< ref "/developer-platform/v1.2/guides/service-providers/your-first-service" >}})),
you can change how it appears in the catalogue, where it can be used and how its forms behave.
This page covers managing a service in the dashboard and the annotations and schema markers that
control it.

## Managing a service in the dashboard

Open **Services** in the sidebar of the organisation that owns the service. The first tab lists
your own services; the **Subscriptions** tab lists services you consume from others. Each of your
services has a menu (**...**) with:

- **Edit**: change the title, short description, category, documentation URL, **Generate UI**,
  labels and annotations, logo and description. The name, API group and kubeconfig location can't
  be changed.
- **Update Permissions**: change which resources the service claims access to. Only shown once the
  service is active.
- **Kubeconfig**: show, copy or download the kubeconfig for the api-syncagent again, from the Secret
  you chose when you created the service.
- **UI Builder**: see [UI Builder]({{< ref "/developer-platform/v1.2/guides/service-providers/ui-builder" >}}).
- **Delete**: delete the service, its uploaded logo and, if your organisation uses the service
  itself, its own binding to it.

### Catalogue details

The create and edit forms set what consumers see in the service catalogue:

| Field | Shown as |
| ----- | -------- |
| **Title** | The service's name on its tile. |
| **Short Description** | The text on its tile. |
| **Category** | Used for sorting and search: Database, General, Infrastructure, Messaging, Monitoring, Security, Storage or Other. Defaults to General. |
| **Documentation URL** | A link in the service's details. |
| **Logo** | The image on its tile. Upload a PNG, JPG or SVG file of up to 1 MB, or enter a URL. Uploads are stored on the KDP storage server. |
| **Description** | The full description in the service's details. Markdown is supported. |

### Deprecating a service

To stop new use of a service without removing it, set `spec.catalogMetadata.deprecated: true` on
the `Service` object with `kubectl`; the dashboard's form has no field for it. The service then
disappears from the catalogue, and consumers can view and delete existing objects but not create or
edit them in the dashboard. The API doesn't enforce this, so objects can still be created with
`kubectl`.

## Linking to your own UI

If your service has its own web interface, add a link to it from the dashboard. Set the
`catalog.kdp.k8c.io/external-link-url` annotation on the `Service`:

```yaml
apiVersion: core.kdp.k8c.io/v1alpha1
kind: Service
metadata:
  name: databases.example.com
  annotations:
    catalog.kdp.k8c.io/external-link-url: "https://db-console.example.com/{{project}}"
```

Consumers then see an **Open** button with the service's title on its object list, which opens the
link in a new tab. The URL can contain two placeholders:

- `{{project}}`: the path of the consumer's organisation or project, such as `root:acme:team-a`.
  It is inserted as it is, without URL encoding.
- `{{connector}}`: the identity provider connector the user logged in through. This only works
  with Dex, and only if the dashboard requests the `federated:id` scope (see
  [Configuring the Dashboard]({{< ref "/developer-platform/v1.2/guides/platform-administration/dashboard-configuration#login" >}})).
  If the connector isn't known, the button isn't shown.

The URL must be an absolute `http` or `https` URL, or a path starting with `/` on the dashboard's
own domain. Anything else is ignored and no button is shown.

## Restricting where a service can be used

Some services only make sense in an organisation, or only in a project. Set the
`catalog.kdp.k8c.io/disallow-workspace-types` annotation on the `Service` to the kinds of workspace
where it must not be used: `organization`, `project`, or both, separated by a comma.

```yaml
metadata:
  annotations:
    catalog.kdp.k8c.io/disallow-workspace-types: organization
```

With this annotation:

- KDP rejects creating the service's objects in those workspaces with the error
  `<Kind> cannot be created in a <type> workspace`. Existing objects stay.
- The dashboard hides the service from the catalogue there and shows it as read-only.

KDP enforces this with an admission webhook that it sets up for the service. While the KDP
controller manager is unavailable, creating any object of the service fails; see
[Operating KDP]({{< ref "/developer-platform/v1.2/guides/platform-administration/operating-kdp#admission-webhook" >}}).
Unknown values are ignored.

## Labels and annotations in the catalogue

Consumers can't read your `Service` object, only its catalogue entry. KDP copies labels and
annotations whose key starts with exactly `catalog.kdp.k8c.io/` to the catalogue entry and leaves
out all others, including subdomains such as `team.catalog.kdp.k8c.io/`. Put anything consumers or
their tools should see under that prefix, and nothing you want to keep private.

## Offering choices in forms

The dashboard builds forms from your CRD's schema. To turn a text field into a list to choose
from, filled from objects in the workspace, add a `kdp:options` block to the field's description in
the CRD. With kubebuilder, put it in the Go doc comment of the field:

```go
// The ConfigMap with the application's settings.
// <!-- kdp:options
// ---
// apiVersion: options.kdp.k8c.io/v1
// kind: FieldSource
// source: local
// path: /api/v1/namespaces/${LOCAL_NAMESPACE}/configmaps
// value: "{.metadata.name}"
// -->
ConfigMapName string `json:"configMapName,omitempty"`
```

The dashboard hides the block from the field's help text. Its fields:

| Field | Meaning |
| ----- | ------- |
| `apiVersion`, `kind` | Always `options.kdp.k8c.io/v1` and `FieldSource`. |
| `source` | `local` lists objects in the consumer's workspace. `vwcatalog` lists objects through the service catalogue, across workspaces, with your service's permissions. Defaults to `local`. |
| `path` | The API path to list, starting with `/`. It can use `${LOCAL_WORKSPACE}`, `${APIEXPORT_WORKSPACE}` and `${LOCAL_NAMESPACE}`. |
| `value` | A JSONPath template for the value stored in the field, such as `"{.metadata.name}"`. |
| `label` | Optional JSONPath template for the text shown in the list. |

This works for `string`, `integer` and `number` fields, and for lists of them, which become
multi-selects. If the source returns nothing, the field becomes a normal input again. When an
object is edited, a stored value the source no longer offers is still shown, marked
**(current value)**.

## Related topics

- [Publishing Resources]({{< ref "/developer-platform/v1.2/guides/service-providers/publish-resources" >}})
- [UI Builder]({{< ref "/developer-platform/v1.2/guides/service-providers/ui-builder" >}})
- [Consuming Services]({{< ref "/developer-platform/v1.2/guides/platform-users/consuming-services" >}})
