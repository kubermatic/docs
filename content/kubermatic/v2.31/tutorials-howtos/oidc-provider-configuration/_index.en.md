+++
title = "OIDC Provider Configuration"
date = 2018-06-21T14:07:15+02:00
weight = 14

+++

This manual explains how to configure a custom OIDC provider to use with Kubermatic Kubernetes Platform (KKP).

## Default Configuration

When nothing is configured, KKP uses `https://<domain>/dex` as the OIDC provider
URL, which by default points to Dex. The domain is taken from the
[KubermaticConfiguration]({{< ref "../../tutorials-howtos/kkp-configuration" >}}).

Login into the KKP dashboard uses the OAuth **Authorization Code flow with PKCE**. The flow is
driven by the KKP API, not by the browser: when the user clicks **Sign in** on the KKP login
page, the browser is sent to `https://<domain>/api/v2/auth/login`, which redirects to the OIDC
provider with the following parameters:

- `&response_type` is set to `code`
- `&client_id` is set to the value of `spec.auth.clientID` (defaults to `kubermatic`)
- `&redirect_uri` is set to `https://<domain>/api/v2/auth/callback`
- `&scope` is set to `openid email profile groups offline_access`
- `&state` is a randomly generated string to protect against CSRF
- `&nonce` is a randomly generated string to prevent replay attacks
- `&code_challenge` and `&code_challenge_method=S256` implement PKCE

The authorization code is exchanged for tokens by the KKP API in a server-to-server call. The
resulting tokens are stored in `HttpOnly` and `Secure` cookies and are never exposed to
JavaScript in the browser. A refresh token is used to renew the session silently before the ID
token expires.

{{% notice note %}}
The login client must be a **confidential** client (client authentication enabled) and must have
`https://<domain>/api/v2/auth/callback` registered as a valid redirect URI. Without the
`offline_access` scope no refresh token is issued and users are logged out as soon as the ID
token expires.
{{% /notice %}}

### OIDC Clients

KKP uses two OIDC clients at the OIDC provider:

| Client | Field | Default | Used for | Redirect URIs |
|---|---|---|---|---|
| Login client | `spec.auth.clientID` | `kubermatic` | Logging into the KKP dashboard | `https://<domain>/api/v2/auth/callback` |
| User Cluster client | `spec.auth.issuerClientID` | `kubermaticIssuer` | OIDC kubeconfig download, web terminal in OIDC mode, Kubernetes Dashboard | `https://<domain>/api/v1/kubeconfig`, `https://<domain>/api/v2/kubeconfig/secret`, `https://<domain>/api/v2/dashboard/login` |

Use two separate clients. This is the supported setup. Tokens issued to the User Cluster client
give access to User Clusters. With a separate login client, the KKP API rejects those tokens, so
a downloaded kubeconfig cannot be used to call the KKP API.

When a login token has several audiences, its `azp` claim must be set to the login client
(Dex and Keycloak do this by default), and none of the audiences may be a User Cluster client. Do not configure the OIDC provider to add a User Cluster client to login tokens,
for example with Dex trusted peers or a Keycloak audience mapper.

{{% notice warning %}}
Using a single client for both purposes, by setting `spec.auth.clientID` to the value of
`spec.auth.issuerClientID`, is deprecated and will not be supported in an upcoming KKP release.
In this setup the KKP API also accepts tokens issued for User Clusters and logs a warning at
startup. Installations that still use a single client should move to two separate clients.
{{% /notice %}}

## Custom Configuration

The default configuration can be changed as KKP supports other OIDC providers as well. This
involves updating the KKP dashboard and API using the `KubermaticConfiguration` CRD on the
master cluster. The used configuration can be retrieved using `kubectl`:

```bash
kubectl -n kubermatic get kubermaticconfigurations
#NAME         AGE
#kubermatic   2h

kubectl -n kubermatic get kubermaticconfiguration kubermatic -o yaml
#apiVersion: kubermatic.k8c.io/v1
#kind: KubermaticConfiguration
#metadata:
#  finalizers:
#  - operator.kubermatic.io/cleanup
#  name: kubermatic
#  namespace: kubermatic
#spec:
#  auth:
#    issuerClientSecret: abcd1234
#    issuerCookieKey: wxyz9876
#    serviceAccountKey: 2468mnop
#  ...
```

The following sections describe the parts that need to be updated.

### API Configuration

The KKP API validates the given token for authentication and therefore needs to be able to
find the new token issuer. The relevant fields are under `spec.auth` and the following snippet
demonstrates the default values:

```yaml
spec:
  auth:
    clientID: kubermatic
    clientSecret: ""
    issuerClientID: kubermaticIssuer
    issuerClientSecret: ""
    issuerCookieKey: ""
    issuerRedirectURL: https://<domain>/api/v1/kubeconfig
    serviceAccountKey: ""
    skipTokenIssuerTLSVerify: false
    tokenIssuer: https://<domain>/dex
```

The `tokenIssuer` needs to be updated, the rest can be left out if the default values are
used. This gives us:

```yaml
spec:
  auth:
    tokenIssuer: 'https://keycloak.kubermatic.test/auth/realms/test'
```

A few fields deserve attention:

- `clientSecret` is the secret of the login client. It is required when `clientID` differs from
  `issuerClientID`. `kubermatic-installer deploy` stops when it is missing, and the KKP API does
  not start without it. In the deprecated single-client setup, `clientSecret` is ignored and
  `issuerClientSecret` is used.
- `issuerClientSecret`, the secret of the User Cluster client, and `issuerCookieKey` must be set. The
  dashboard login uses `issuerCookieKey`.
- `additionalIssuerRedirectURLs` lists other hostnames users open the dashboard on, for example
  through a reverse proxy. It is empty by default. See [Additional Hostnames](#additional-hostnames).

### Additional Hostnames

If users open the KKP dashboard on hostnames other than `spec.ingress.domain`, for example through
a reverse proxy, list them in `spec.auth.additionalIssuerRedirectURLs`. This requires KKP 2.31.4
or later.

```yaml
spec:
  auth:
    additionalIssuerRedirectURLs:
      - https://kkp-proxy.example.com
```

Each entry is an origin as the browser shows it in the address bar: scheme `http` or `https`, the
host in lower case and an optional non-default port. Entries must not contain a path, query or
fragment.

For every listed hostname, register these redirect URIs at the OIDC provider:

- On the login client (`spec.auth.clientID`): `<hostname>/api/v2/auth/callback`
- On the User Cluster client (`spec.auth.issuerClientID`): `<hostname>/api/v1/kubeconfig`,
  `<hostname>/api/v2/kubeconfig/secret` and `<hostname>/api/v2/dashboard/login`

If a Seed has its own OIDC provider in `spec.oidcProviderConfiguration`, register the three User
Cluster redirect URIs at that provider too.

The reverse proxy must forward requests with the `Host` header and the TLS server name set to
`spec.ingress.domain`. For requests under `/api/v1/ws/` whose `Origin` header is the additional
hostname's own origin, it must set `Origin` to the origin of `spec.ingress.domain`.

### UI Configuration

Since the login URL is built by the KKP API, the only OIDC-related options left in the
`spec.ui.config` JSON field are the ones controlling **logout**:

- `oidc_provider` is the name of the OIDC provider. It determines how the logout URL is built.
  Currently, only `dex` and `keycloak` are supported.
- `oidc_logout_url` is the end-session endpoint of the OIDC provider. If it is not set, logging
  out only clears the KKP session cookies and returns the user to the dashboard root; the
  session at the provider stays open.

A configuration of a custom OIDC provider may look like this:

```yaml
spec:
  ui:
    config: |
      {
        "oidc_provider": "keycloak",
        "oidc_logout_url": "https://keycloak.kubermatic.test/auth/realms/test/protocol/openid-connect/logout"
      }
```

{{% notice note %}}
The `oidc_provider_url`, `oidc_provider_scope`, `oidc_provider_client_id` and
`oidc_connector_id` options are not used and are ignored if present. The KKP API builds the
authorization URL, including the scopes and the client ID, from `spec.auth`.
{{% /notice %}}

{{% notice note %}}
  When the user token size exceeds the browser's cookie size limit (e.g., when the user is a member of many groups), the token is split across multiple cookies to ensure proper authentication.

  External tools outside of KKP (e.g., Kubernetes Dashboard, Grafana, Prometheus) are not supported with multi-cookie tokens.
{{% /notice %}}

### Dex Configuration

When using the bundled Dex, both clients are configured in the `values.yaml` of the `dex` Helm
chart:

```yaml
dex:
  config:
    oauth2:
      responseTypes:
        - code            # required for the dashboard login
    staticClients:
      - id: kubermatic
        name: Kubermatic Dashboard
        # generate with: cat /dev/urandom | base64 | tr -dc 'A-Za-z0-9' | head -c32
        secret: <same value as spec.auth.clientSecret>
        RedirectURIs:
          - https://kkp.example.com/api/v2/auth/callback     # KKP dashboard login
      - id: kubermaticIssuer
        name: Kubermatic OIDC Issuer
        # a different random value
        secret: <same value as spec.auth.issuerClientSecret>
        RedirectURIs:
          - https://kkp.example.com/api/v1/kubeconfig       # user cluster kubeconfig
          - https://kkp.example.com/api/v2/kubeconfig/secret # webterminal kubeconfig secret
          - https://kkp.example.com/api/v2/dashboard/login   # k8s dashboard login
```

If you still use the deprecated single-client setup, keep
`https://kkp.example.com/api/v2/auth/callback` in the `kubermaticIssuer` redirect URIs. Without
it the login fails with "Unregistered redirect_uri".

No Dex-specific PKCE setting is required; Dex supports the `S256` code challenge method for
confidential clients out of the box.

### Session Length

Two settings control how long a user stays signed in:

- The **ID token lifetime**, configured in the OIDC provider (for Dex:
  `dex.config.expiry.idTokens`, which the KKP chart sets to `24h`). The dashboard refreshes the
  token silently shortly before it expires, so this value does not determine the session length.
- The **refresh token lifetime**, configured in the OIDC provider. Dex does not expire refresh
  tokens by default — see the [Dex documentation](https://dexidp.io/docs/configuration/tokens/)
  for how to configure token lifetimes.

Independently of the provider, the KKP `refresh_token` cookie has a lifetime of 30 days, so a
session ends after at most 30 days even if the provider would allow a longer one.

{{% notice note %}}
In the deprecated single-client setup, a session can end earlier than these values suggest. The dashboard then shares an OIDC client with the kubeconfig and the OIDC-mode web terminal flows, and using one of those invalidates the refresh token of the running dashboard session. A separate login client avoids this. See [OIDC refresh tokens are invalidated when the same user/client ID pair is authenticated multiple times]({{< ref "../../architecture/known-issues/#oidc-refresh-tokens-are-invalidated-when-the-same-userclient-id-pair-is-authenticated-multiple-times" >}}).
{{% /notice %}}

### Seed Configuration

In some cases a Seed may require an independent OIDC provider. For this reason a `Seed` CRD contains relevant fields under `spec.oidcProviderConfiguration`. Filling those fields results in overwriting a configuration from `KubermaticConfiguration` CRD. The following snippet presents an example of `Seed` CRD configuration:

```yaml
spec:
  oidcProviderConfiguration:
    issuerURL: https://example.kubermatic.io/dex
    issuerClientID: kubermaticIssuer
    issuerClientSecret: "SuperSecretIssuerClientSecret"
```

The `issuerClientID` of a Seed must differ from the login client (`spec.auth.clientID`). The same
applies to `spec.oidc.clientID` of a User Cluster that uses the KKP token issuer.

{{% notice note %}}
It is highly recommended to use the same domain in email scope both for Seed level and main OIDC providers. This is a prerequisite for web terminal feature and it saves some time on user cluster RBAC configuration.
{{% /notice %}}

## Applying Changes

Edit KubermaticConfiguration or Seed either directly via `kubectl edit` or apply them from YAML
files by using `kubectl apply`. The KKP Operator will pick up on the changes and
reconfigure the components accordingly. After a few seconds the new pods should be up and
running.

{{% notice note %}}
If you are using *Keycloak* as a custom OIDC provider, create both clients. Configure the login client (`kubermatic`) as follows:

- **Standard Flow**: enabled. Implicit Flow is not used and can be turned off.
- **Client authentication**: on, so that the client is a confidential client. Copy its secret to `spec.auth.clientSecret`.
- **Valid Redirect URIs**: add `https://<domain>/api/v2/auth/callback`.
- **PKCE Code Challenge Method**: `S256`.
- **Scopes**: `offline_access` has to be part of the default or optional client scopes, otherwise no refresh token is issued.

Register the three User Cluster redirect URIs from [OIDC Clients](#oidc-clients) on the `kubermaticIssuer` client. Do not add an audience mapper that puts `kubermaticIssuer` into the tokens of the login client.
{{% /notice %}}
