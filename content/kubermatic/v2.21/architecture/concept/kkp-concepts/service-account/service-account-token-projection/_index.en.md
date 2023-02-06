+++
title = "Service Account Token Volume Projection"
date = 2021-01-21T13:05:00+02:00
weight = 140

+++

The [Service Account Token Volume Projection](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/#service-account-token-volume-projection)
feature of Kubernetes allows projection of time and audience-bound service account tokens into Pods. This feature
is used by some applications to enhance security when using service accounts
(e.g. [Istio uses it by default](https://istio.io/latest/docs/ops/best-practices/security/#configure-third-party-service-account-tokens) as of version v1.3).

As of KKP version v2.16, KKP supports Service Account Token Volume Projection as follows:
- in clusters with Kubernetes version v1.20+, it is enabled by default with the default configuration as described below,
- in clusters with Kubernetes below v1.20, it has to be explicitly enabled.

## Prerequisites
`TokenRequest` and `TokenRequestProjection` Kubernetes feature gates have to be enabled (enabled by default since
Kubernetes v1.11 and v1.12 respectively).

## Configuration
In KKP v2.16, the Service Account Token Volume Projection feature can be configured only via KKP API.

The `Cluster` API object provides the `serviceAccount` field of the `ServiceAccountSettings` type, with the following definition:

```json
   "ServiceAccountSettings": {
      "type": "object",
      "properties": {
        "tokenVolumeProjectionEnabled": {
          "type": "boolean",
          "x-go-name": "TokenVolumeProjectionEnabled"
        },
        "issuer": {
          "description": "Issuer is the identifier of the service account token issuer. If this is not specified, it will be set to the URL of apiserver by default",
          "type": "string",
          "x-go-name": "Issuer"
        },
        "apiAudiences": {
          "description": "APIAudiences are the Identifiers of the API. If this is not specified, it will be set to a single element list containing the issuer URL",
          "type": "array",
          "items": {
            "type": "string"
          },
          "x-go-name": "APIAudiences"
        }
      },
      "x-go-package": "k8c.io/kubermatic/v2/pkg/crd/kubermatic/v1"
    }
```

The following table summarizes the supported properties of the `ServiceAccountSettings` object:

| Property                       | Description | Default Value |
| ------------------------------ | ----------- | ------------- |
| `tokenVolumeProjectionEnabled` | Enables the Service Account Token Volume Projection feature. | `false` for clusters with Kubernetes version below v1.20, `true` for clusters with Kubernetes v1.20+. |
| `issuer`                       | Identifier of the service account token issuer. The issuer will assert this identifier in `iss` claim of issued tokens. | The URL of the apiserver, e.g., `https://<api-server-address:port>`. |
| `apiAudiences`                 | Identifiers of the API. The service account token authenticator will validate that tokens used against the API are bound to at least one of these audiences. Multiple audiences can be separated by comma (`,`). | Equal to `issuer`. |


### Example: Configuration using a request to KKP API
To configure the feature in an existing cluster, execute a `PATCH` request to URL:

`https://<your-kubermatic-domain>/api/v1/projects/<project-id>/dc/<datacenter-name>/clusters/<cluster-id>` 

with the following content:

```json
{
  "spec": {
    "serviceAccount": {
      "tokenVolumeProjectionEnabled": true
    }
  }
}
```

You can use the Swagger UI at `https://<your-kubermatic-domain>/rest-api` to construct and send the API request.


### Example: Configuration using Cluster CR
Alternatively, the feature can be also configured via the `Cluster` Custom Resource in the KKP seed cluster.
For example, to enable the feature in an existing cluster via kubectl, edit the `Cluster` CR with
`kubectl edit cluster <cluster-id>` and add the following configuration:

```yaml
spec:
  serviceAccount:
    tokenVolumeProjectionEnabled: true
```
