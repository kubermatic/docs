+++
title = "Structured Authentication Configuration"
date = 2026-11-14T12:00:00+02:00
+++

Kubernetes lets you configure the kube-apiserver authenticators with a structured
[`AuthenticationConfiguration`][k8s-authn-config] file, passed to the API server with the `--authentication-config`
flag. Compared to the legacy `--oidc-*` flags, the structured configuration supports:

- multiple JWT issuers, each with its own audiences
- [CEL][k8s-cel] expressions for claim validation, claim mappings and user validation
- anonymous access limited to selected endpoints (for example, only `/healthz`, `/readyz` and `/livez`)
- reloading the configuration while the API server is running, with no restart

KubeOne exposes this through the `authenticationConfiguration` feature.

## KubeOne Support

KubeOne supports the structured authentication configuration as of v1.15. It supports the following operations:

- Enabling and disabling the structured authentication configuration
- Distributing the `AuthenticationConfiguration` file to all control plane nodes
- Rolling out changes to the configuration file with `kubeone apply`
- Validating the configuration file before it's rolled out to the cluster

{{% notice note %}}
The `authenticationConfiguration` feature can't be used together with the [`openidConnect` feature][oidc-tutorial]. The
`openidConnect` feature configures a single OIDC issuer with the legacy `--oidc-*` flags. Use
`authenticationConfiguration` if you need anything beyond a single issuer.
{{% /notice %}}

## Writing the Authentication Configuration

The authentication configuration is a standalone manifest of kind `AuthenticationConfiguration` from the
`apiserver.config.k8s.io` API group. KubeOne doesn't generate this file. You write it and KubeOne distributes it as-is.
See the [Kubernetes documentation][k8s-authn-config] for all available fields.

The following example configures two JWT issuers and allows anonymous access only to the health check endpoints:

```yaml
# authentication-config.yaml
apiVersion: apiserver.config.k8s.io/v1
kind: AuthenticationConfiguration
jwt:
  - issuer:
      url: https://dex.example.com
      audiences:
        - kubernetes
    claimMappings:
      username:
        claim: email
        prefix: "oidc:"
      groups:
        claim: groups
        prefix: "oidc:"
    claimValidationRules:
      - expression: "claims.email_verified == true"
        message: "email must be verified"
  - issuer:
      url: https://keycloak.example.com/realms/platform
      audiences:
        - kubernetes
        - platform-cli
      audienceMatchPolicy: MatchAny
    claimMappings:
      username:
        expression: '"keycloak:" + claims.preferred_username'
      groups:
        expression: 'claims.groups.map(g, "keycloak:" + g)'
    userValidationRules:
      - expression: "!user.username.startsWith('system:')"
        message: "username cannot use the reserved system: prefix"
anonymous:
  enabled: true
  conditions:
    - path: /livez
    - path: /readyz
    - path: /healthz
```

## Enabling the Authentication Configuration

To enable the feature, add the following section to the KubeOne configuration manifest:

```yaml
apiVersion: kubeone.k8c.io/v1beta2
kind: KubeOneCluster
name: example

versions:
  kubernetes: "1.34.1"

features:
  authenticationConfiguration:
    enable: true
    # Path to the AuthenticationConfiguration manifest. Relative paths are
    # resolved relative to the KubeOne configuration manifest.
    configFilePath: ./authentication-config.yaml
```

You can also generate an example manifest with the feature section included:

```shell
kubeone config print --full --enable-authentication-configuration
```

The `configFilePath` field is required when the feature is enabled.

### New Clusters

For a new cluster, run `kubeone apply` as usual. The kube-apiserver uses the structured authentication configuration
from the start:

```shell
kubeone apply --manifest kubeone.yaml -t tf.json
```

### Existing Clusters

Enabling the feature on an existing cluster changes the kube-apiserver flags, so you have to run `kubeone apply` with
the `--force-upgrade` flag. This reconfigures the control plane nodes one by one:

```shell
kubeone apply --manifest kubeone.yaml -t tf.json --force-upgrade
```

### Migrating from the `openidConnect` Feature

You can't enable both features at the same time, so migrate in a single step:

1. Translate the `features.openidConnect.config` values into a `jwt` entry in the `AuthenticationConfiguration` file.
   For example:

   | `openidConnect.config` | `AuthenticationConfiguration` |
   | ---------------------- | ----------------------------- |
   | `issuerUrl`            | `jwt[].issuer.url`            |
   | `clientId`             | `jwt[].issuer.audiences`      |
   | `usernameClaim`        | `jwt[].claimMappings.username.claim` |
   | `usernamePrefix`       | `jwt[].claimMappings.username.prefix` |
   | `groupsClaim`          | `jwt[].claimMappings.groups.claim` |
   | `groupsPrefix`         | `jwt[].claimMappings.groups.prefix` |
   | `requiredClaim`        | `jwt[].claimValidationRules` |
   | `caFile`               | `jwt[].issuer.certificateAuthority` (PEM content, not a path) |

2. Set `features.openidConnect.enable` to `false` (or remove the section) and add the
   `features.authenticationConfiguration` section.
3. Run `kubeone apply --force-upgrade`.

## Updating the Authentication Configuration

Once the feature is enabled, edit the `AuthenticationConfiguration` file and run `kubeone apply`:

```shell
kubeone apply --manifest kubeone.yaml -t tf.json
```

KubeOne compares the SHA256 checksum of your local file with the file on each control plane node. If they differ,
KubeOne uploads the new file to all control plane nodes. The kube-apiserver watches the file and reloads it
automatically, so updates don't need `--force-upgrade` and don't restart the API server.

{{% notice note %}}
If the reloaded configuration is invalid, the kube-apiserver keeps using the last valid configuration. KubeOne validates
the file before uploading it (see [Validation](#validation)), which catches most errors early.
{{% /notice %}}

## Disabling the Authentication Configuration

To disable the feature, set `features.authenticationConfiguration.enable` to
`false` (or remove the section) and run:

```shell
kubeone apply --manifest kubeone.yaml -t tf.json --force-upgrade
```

## Validation

KubeOne validates the configuration before making any changes to the cluster. It fails if:

- `configFilePath` is empty or the file can't be read
- the file isn't a valid `AuthenticationConfiguration` manifest. KubeOne decodes it strictly, so unknown fields are
  rejected
- the configuration fails the kube-apiserver's own validation rules, including CEL expression compilation
- a JWT issuer URL is the same as the service account token issuer. By default that's
  `https://kubernetes.default.svc.<serviceDomainName>`, or the values of the `service-account-issuer` flag if you set it
  in `controlPlaneComponents.apiServer.flags`
- both `authenticationConfiguration` and `openidConnect` are enabled
- `controlPlaneComponents.apiServer.flags` sets `authentication-config` or any `oidc-*` flag
- the file has an `anonymous` section and `controlPlaneComponents.apiServer.flags` also sets `anonymous-auth`. The
  kube-apiserver refuses to start when anonymous authentication is configured both ways

## How It Works

When the feature is enabled, KubeOne:

1. Uploads the file to `/etc/kubernetes/authentication/config.yaml` on every control plane node, owned by `root:root`
   with mode `0600`.
2. Mounts `/etc/kubernetes/authentication` read-only into the kube-apiserver static pod.
3. Sets the kube-apiserver flag `--authentication-config=/etc/kubernetes/authentication/config.yaml`.

[k8s-authn-config]: https://kubernetes.io/docs/reference/access-authn-authz/authentication/#using-authentication-configuration
[k8s-cel]: https://kubernetes.io/docs/reference/using-api/cel/
[oidc-tutorial]: {{< ref "../../tutorials/creating-clusters-oidc" >}}
