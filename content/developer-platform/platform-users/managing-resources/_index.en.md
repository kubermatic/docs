+++
title = "Managing Resources"
weight = 2
+++

This document describes how to manage resources offered by Services.

## Background

A "service" in KDP defines a unique Kubernetes API Group and offers a number of resources (types) to
use. A service could offer certificate management, databases, cloud infrastructure or any other set
of Kubernetes resources.

Once a service is [enabled in a workspace]({{< ref "../consuming-services#enabling-a-service" >}}),
new Kubernetes resource types (APIs) become available, similar to how CustomResourceDefinitions would
introduce new APIs.

## Creating Resources

Consult the service's documentation to learn more about what resources are available and how to use
them. The written documentation often contains valuable information that is not available from just
inspecting the Kubernetes API types.

### Dashboard

Navigate to your organization and then choose the desired service in the sidebar. The dashboard will
present a list of existing resources that are part of this service, plus it offers a simple editor
to create and update them.

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
synchronization process behind the scenes will revert such changes usually shortly thereafter. In
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
`servlet.kdp.k8c.io/related/<name>`, the value being a JSON document of this structure:

```json
{
  "name": "<name of the related object>",
  "namespace": "<namespace of the related object (field is omitted for Cluster-scoped objects)>",
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
    servlet.kdp.k8c.io/related/connection-details: '{"name":"prod1-credentials","namespace":example-app","kind":"Secret"}'
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
