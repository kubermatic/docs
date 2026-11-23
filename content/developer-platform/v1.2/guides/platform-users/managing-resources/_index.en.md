+++
title = "Managing Resources"
weight = 5
aliases = ["/developer-platform/v1.2/platform-users/managing-resources/"]
+++

This document describes how to manage resources offered by Services.

## Background

A "service" in KDP defines a unique Kubernetes API Group and offers a number of resources (types) to
use. A service could offer certificate management, databases, cloud infrastructure or any other set
of Kubernetes resources.

Once a service is [enabled in a workspace]({{< ref "/developer-platform/v1.2/guides/platform-users/consuming-services#enabling-a-service" >}}),
new Kubernetes resource types (APIs) become available, similar to how CustomResourceDefinitions would
introduce new APIs.

## Creating Resources

Consult the service's documentation to learn more about what resources are available and how to use
them. The written documentation often contains valuable information that is not available from just
inspecting the Kubernetes API types.

### Dashboard

Navigate to your organisation or project and choose the service in the **Services** section of the
sidebar. The dashboard lists the existing objects of this service. Use the **Namespace** selector to
show only one namespace.

#### Viewing an object

Click an object's name to open its details. The page has these sections:

- **Overview**: name, namespace, kind and API version.
- **Labels** and **Annotations** (collapsed by default).
- **Spec**: the object's settings, labelled using the service's schema.
- **Status**: the object's conditions, followed by the other status fields.
- **Related Resources**: the [related resources](#related-resources) of the object. Click a row to
  view a related Secret, ConfigMap or other object without leaving the page.

If the service provider or your organisation has built a custom view with the
[UI Builder]({{< ref "/developer-platform/v1.2/guides/service-providers/ui-builder" >}}), the dashboard shows that view
instead.

The **...** menu on the details page and in the object list has these actions, depending on your
permissions:

- **Edit**: change the object (see below). Not available for objects that are being deleted, for
  deprecated services, or for services that aren't allowed in this kind of workspace (see below).
- **Status**: show the raw `status` of the object as JSON.
- **Secret: \<name\>**, **ConfigMap: \<name\>**, ...: open a related resource.
- **Delete**: delete the object.

#### Creating and editing objects

Click **Create** on the object list to create an object, or choose **Edit** in an object's **...**
menu. You can enter the object's `spec` on two tabs:

- **Form**: a form generated from the service's schema. If a custom form was built with the
  [UI Builder]({{< ref "/developer-platform/v1.2/guides/service-providers/ui-builder" >}}), the
  tab shows that form instead. Click **Use the generated form** or **Use the custom form** to
  switch between them.
- **YAML Editor**: the `spec` as YAML.

Some fields offer a list of values to choose from, filled in from other objects in your workspace.
For those, pick a namespace first if the form asks for one. To empty an optional field that refers
to another object, click **Clear selection** next to it.

You can also set the object's labels and annotations, both when creating and when editing.
Annotations used by KDP and Kubernetes themselves (such as `kcp.io/`, `syncagent.kcp.io/` and
`kubectl.kubernetes.io/` annotations) are hidden and kept as they are. The dashboard saves your
changes as a merge patch.

#### Services with restrictions

A service can be restricted in two ways. In both cases the object list shows a notice, and you
can view and delete existing objects but not create or edit them:

- **Deprecated services**: the provider has deprecated the service. Deprecated services are also
  hidden from the service catalogue.
- **Services not allowed in this kind of workspace**: the provider has limited the service to
  organisations or to projects. The notice says the service is not allowed in an organisation or
  a project. The service also doesn't appear in the catalogue or in **Add Services** there.

#### Opening the service's own dashboard

Some services have their own web interface. If the provider has linked it, an **Open** button with
the service's name appears on the object list and takes you there.

#### ConfigMaps and Secrets

Open **Config Maps** or **Secrets** in the sidebar to manage ConfigMaps and Secrets in your
workspace, for example to provide configuration or credentials that a service object refers to.
Without a namespace selected, the list shows all namespaces of the workspace.

- **Create Config Map** / **Create Secret**: enter a name, the namespace, optional labels and
  annotations, and the data as a YAML or JSON map of keys to values. For Secrets you can also set
  the **Type** (default `Opaque`). Enter Secret values as plain text. The dashboard base64-encodes
  them for you.
- **View Details**: shows the keys and values, labels and annotations. Secret values are hidden
  until you reveal them. Every value can be copied or downloaded as a file.
- **Edit**: change labels, annotations and data. The name, namespace and Secret type can't be
  changed.
- **Delete**: delete the ConfigMap or Secret after confirming.

Keep in mind:

- All values are saved as strings. Nested objects in the data map are not supported.
- The dashboard can't create or edit binary ConfigMap data (`binaryData`). Existing binary data is
  shown (without values) and kept when you edit the ConfigMap.
- ConfigMaps labelled `internal.kdp.k8c.io/visibility: hidden` are not shown. KDP uses this for
  internal ConfigMaps, such as UI Builder configurations.

#### Chatting with an LLM

If your platform offers a service for large language models with the `LLMAccess` kind (API group
`ai.kdp.k8c.io`), the dashboard can open a chat with the model an `LLMAccess` object gives you
access to. Choose **Chat** in the object's **...** menu.

The chat uses the endpoint, API key and models stored in the object's related Secret (keys
`endpoint`, `key`, and `models` or `model`). If the Secret lists several models, the chat has a
model selector. **Chat** is disabled until that Secret exists, and you need permission to read
Secrets in its namespace. If the credentials can't be loaded, the chat shows **Credentials
Unavailable**. The endpoint must offer an OpenAI-compatible chat completions API.

The chat goes through the dashboard's API and sends your messages, with a short fixed system
prompt, to the model. It does not send the object or any other data from your workspace, and the
model can't change anything in KDP. Conversations are not saved: they are gone when you leave or
reload the page.

This feature is off by default. Your platform administrator can enable it in the dashboard's Helm
values:

```yaml
dashboard:
  config:
    features:
      featureFlags:
        kubermatic-ai-chat-enabled: true
```

<!-- TODO(screenshot): add screenshots for the service object detail page, the ConfigMap/Secret pages and the LLM chat with its model selector. -->

### kubectl

To see which API resources are available in your workspace, use the `api-resources` subcommand:

```bash
$ kubectl api-resources
NAME                SHORTNAMES   APIVERSION        NAMESPACED   KIND
bindings                         v1                true         Binding
componentstatuses   cs           v1                false        ComponentStatus
databases           db           example.corp/v1   true         Database
...
```

In the example above, we can see that the fictional RBDMS service enabled in this workspace provides
a new resource, `databases`, in the API group/version `example.corp/v1`.

You could now create a new database by first creating a YAML file like `prod1.yaml` as described in
the service's documentation:

```yaml
apiVersion: example.corp/v1
kind: Database
metadata:
  name: prod1
  namespace: example-app
spec:
  size: large
  performance: good
  backups: true
```

Now you could use `kubectl apply -f prod1.yaml` to create your database.

## Consuming Secrets

In most cases, creating a new resource alone is not enough to actually use it. Creating a database
like shown above is not useful without getting access to the database's address and credentials.
There are two ways this information can be provided by the service to the platform user.

### Status Subresource

Some service's might make use of the `status` subresource in their resources. Usually the user
specifies the `spec` part of a resource (the desired state) and the service would, while processing
the resource, fill in status information in the `status` subresource. In the imaginary database
example above, if you'd retrieve the current state of the `prod1` database, it might look like this:

```yaml
apiVersion: example.corp/v1
kind: Database
metadata:
  name: prod1
  namespace: example-app
  uid: 1234-5678
  resourceVersion: 1
spec:
  size: large
  performance: good
  backups: true
status:
  conditions:
    - name: online
      status: false
    - name: provisioning
      status: true
    - name: spec-valid
      status: true
  connectionDetails:
    username: prod1-23j42
    password: jhk542b3f9g28br2f
    url: sql+tls://dbms.databases.example.corp:28362
```

Platform users should not (need to) attempt to change the `status` of a resource, as the continuous
synchronisation process behind the scenes will revert such changes usually shortly thereafter. In
general, the `spec` flows from the user to the service provider, the `status` flows back up to the
user.

Consult the service's documentation to learn more about the available information and whether a
status subresource is being used at all.

### Related Resources

To keep sensitive data like credentials separate from the "public" part of a resource, dedicated
resources (often Secrets or ConfigMaps) can be used instead of a `status` subresource. For example
if you created a TLS certificate object in an imaginary PKI service, the actual x509 certificate and
private key might be provided to the user in the form of a Secret (often in the same namespace as
the original source object).

Consult the service's documentation on whether and how to specify where such related resources should
be stored. Some services decide it automatically, others require the desired name of the resulting
Secret as part of the `spec` of the original object. Related objects will, regardless of explicit
or automatic naming, always be in the same workspace as the original object.

Suppose the imaginary database service above didn't put the `connectionDetails` in the `status`, but
instead used a Secret. This would mean there 1 related resource and the service documents that it's
called `connection-details`.

For every related resource, there will be an annotation on the original object, named
`related-resources.kdp.k8c.io/<name>`, the value being a JSON document of this structure:

```json
{
  "name": "<name of the related object>",
  "namespace": "<namespace of the related object (field is omitted for Cluster-scoped objects)>",
  "apiVersion": "<Kubernetes API group and version, e.g. v1>",
  "kind": "<Kubernetes kind of the related object, e.g. Secret>"
}
```

The imaginary database from above might look like this:

```yaml
apiVersion: example.corp/v1
kind: Database
metadata:
  name: prod1
  namespace: example-app
  annotations:
    related-resources.kdp.k8c.io/connection-details: '{"name":"prod1-credentials","namespace":example-app","apiVersion":"v1","kind":"Secret"}'
  uid: 1234-5678
  resourceVersion: 1
spec:
  size: large
  performance: good
  backups: true
status:
  conditions:
    - name: online
      status: false
    - name: provisioning
      status: true
    - name: spec-valid
      status: true
```

The actual content of the related resources is described in the service's documentation.
