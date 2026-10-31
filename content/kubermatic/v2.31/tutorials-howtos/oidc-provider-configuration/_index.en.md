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
- `&client_id` is set to the value of `spec.auth.issuerClientID` (defaults to `kubermaticIssuer`)
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
Your OIDC client must be a **confidential** client (client authentication enabled) and must have
`https://<domain>/api/v2/auth/callback` registered as a valid redirect URI. Without the
`offline_access` scope no refresh token is issued and users are logged out as soon as the ID
token expires.
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
    clientID: kubermaticIssuer
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

- `clientID` and `issuerClientID` must be the **same** client. The KKP API validates the `aud`
  claim of tokens that were issued to the issuer client, so a separate public client for the
  dashboard no longer works. Both fields default to `kubermaticIssuer`.
- `issuerClientSecret` and `issuerCookieKey` are **required for logging into the dashboard**.
  Previously they were only needed when the OIDC kubeconfig feature was enabled.
- `additionalIssuerRedirectURLs` lists extra hostnames the dashboard can be opened on, for
  example through a reverse proxy (available since v2.31.X). It is empty by default. See
  [Accessing KKP Through Additional Hostnames](#accessing-kkp-through-additional-hostnames-reverse-proxies).

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
`oidc_connector_id` options are no longer used and are ignored if present. The authorization
URL, including the scopes and the client ID, is now built by the KKP API from `spec.auth`.
{{% /notice %}}

{{% notice note %}}
  When the user token size exceeds the browser's cookie size limit (e.g., when the user is a member of many groups), the token is split across multiple cookies to ensure proper authentication.

  External tools outside of KKP (e.g., Kubernetes Dashboard, Grafana, Prometheus) are not supported with multi-cookie tokens.
{{% /notice %}}

### Dex Configuration

When using the bundled Dex, the client used for the dashboard login is configured in the
`values.yaml` of the `dex` Helm chart:

```yaml
dex:
  config:
    oauth2:
      responseTypes:
        - code            # required for the dashboard login
    staticClients:
      - id: kubermaticIssuer
        name: Kubermatic OIDC Issuer
        secret: <same value as spec.auth.issuerClientSecret>
        RedirectURIs:
          - https://kkp.example.com/api/v2/auth/callback     # KKP dashboard login
          - https://kkp.example.com/api/v1/kubeconfig       # user cluster kubeconfig
          - https://kkp.example.com/api/v2/kubeconfig/secret # webterminal kubeconfig secret
          - https://kkp.example.com/api/v2/dashboard/login   # k8s dashboard login
```

No Dex-specific PKCE setting is required; Dex supports the `S256` code challenge method for
confidential clients out of the box.

### Accessing KKP Through Additional Hostnames (Reverse Proxies)

By default, the KKP API builds the dashboard login `redirect_uri` from the host in
`spec.auth.issuerRedirectURL`. If users open the dashboard on a different hostname, for example
through an internal reverse proxy `https://kkp-proxy.example.com` in front of
`https://kkp.example.com`, the login fails at the callback with a missing state cookie: the
state cookie is set on the configured host, not on the host the user is on.

To support such hostnames, the dashboard sends its own origin to the KKP API when the user signs
in or out. The API uses that origin only if it is the `issuerRedirectURL` host or one of the
entries in `spec.auth.additionalIssuerRedirectURLs`. Any other origin is ignored and the API
falls back to `issuerRedirectURL`.

#### Step 1: Add the Hostnames to the KubermaticConfiguration

```yaml
spec:
  auth:
    issuerRedirectURL: https://kkp.example.com/api/v1/kubeconfig
    additionalIssuerRedirectURLs:
      - https://kkp-proxy.example.com
      - https://kkp-internal.example.com:8443
```

- Add one entry per extra hostname the dashboard is opened on. The `issuerRedirectURL` host is
  always allowed and doesn't need to be repeated.
- Only the scheme, host and port are used; any path is ignored. `https://kkp-proxy.example.com`
  and `https://kkp-proxy.example.com/api/v2/auth/callback` are equivalent.
- The scheme and a non-default port must match what the browser shows in the address bar.
  `https://kkp-proxy.example.com:8443` is a different origin from `https://kkp-proxy.example.com`.
- Entries must use `http` or `https` and contain a host. Entries with user info
  (`https://admin@kkp-proxy.example.com`), a query or a fragment are rejected.

#### Step 2: Register the Callback URLs in the OIDC Provider

For every entry, register `https://<additional-host>/api/v2/auth/callback` as a redirect URI of
the `spec.auth.issuerClientID` client (defaults to `kubermaticIssuer`). Otherwise the OIDC
provider rejects the login with `Unregistered redirect_uri` (Dex) or
`Invalid parameter: redirect_uri` (Keycloak).

For Dex, extend the `values.yaml` of the `dex` Helm chart:

```yaml
dex:
  config:
    staticClients:
      - id: kubermaticIssuer
        RedirectURIs:
          - https://kkp.example.com/api/v2/auth/callback
          - https://kkp-proxy.example.com/api/v2/auth/callback   # additional hostname
          - https://kkp-internal.example.com:8443/api/v2/auth/callback
          # ... existing kubeconfig, web terminal and Kubernetes Dashboard entries
```

For Keycloak, add `https://kkp-proxy.example.com/api/v2/auth/callback` to the
**Valid Redirect URIs** of the client.

#### Step 3: Allow the Post-Logout Redirect

This step is only needed if `oidc_logout_url` is set in `spec.ui.config`. Logging out on an
additional hostname then sends the user to the OIDC provider with a post-logout redirect to
`https://<additional-host>/`, which the provider has to accept.

For Keycloak, add `https://kkp-proxy.example.com/*` to **Valid post logout redirect URIs**. If
that list is empty or set to `+`, Keycloak falls back to **Valid Redirect URIs**, which usually
contains only callback URLs. Add the entry to either list.

Without `oidc_logout_url`, logging out returns the user to the dashboard root on the current
hostname and nothing has to be configured.

#### Step 4: Make the OIDC Provider Reachable

KKP only moves the dashboard callback to the additional hostname, not the OIDC provider. The
browser is still sent to the provider at its own URL (`spec.auth.tokenIssuer`, for example
`https://kkp.example.com/dex`). Users who access KKP through the reverse proxy must be able to
reach that URL, or the proxy has to handle the provider path, for example by rewriting the
`Location` header for `/dex`.

{{% notice note %}}
Only the dashboard login and logout support additional hostnames. The OIDC kubeconfig download,
the Kubernetes Dashboard login and the web terminal still use `issuerRedirectURL`.
{{% /notice %}}

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
A session can also end earlier than these values suggest. Because the dashboard shares an OIDC client with the kubeconfig and web terminal flows, using one of those invalidates the refresh token of the running dashboard session. See [OIDC refresh tokens are invalidated when the same user/client ID pair is authenticated multiple times]({{< ref "../../architecture/known-issues/#oidc-refresh-tokens-are-invalidated-when-the-same-userclient-id-pair-is-authenticated-multiple-times" >}}).
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

{{% notice note %}}
It is highly recommended to use the same domain in email scope both for Seed level and main OIDC providers. This is a prerequisite for web terminal feature and it saves some time on user cluster RBAC configuration.
{{% /notice %}}

## Applying Changes

Edit KubermaticConfiguration or Seed either directly via `kubectl edit` or apply them from YAML
files by using `kubectl apply`. The KKP Operator will pick up on the changes and
reconfigure the components accordingly. After a few seconds the new pods should be up and
running.

{{% notice note %}}
If you are using *Keycloak* as a custom OIDC provider, configure the `kubermaticIssuer` client as follows:

- **Standard Flow**: enabled. Implicit Flow is no longer used and can be turned off.
- **Client authentication**: on, so that the client is a confidential client.
- **Valid Redirect URIs**: add `https://<domain>/api/v2/auth/callback`.
- **PKCE Code Challenge Method**: `S256`.
- **Scopes**: `offline_access` has to be part of the default or optional client scopes, otherwise no refresh token is issued.
{{% /notice %}}
