+++
title = "Access KKP Through Additional Hostnames"
date = 2026-11-18T12:00:00+02:00
weight = 90

+++

Users can open the KKP dashboard on other hostnames than the main one, for example through a reverse proxy
`https://kkp-proxy.example.com` in front of `https://kkp.example.com`. This page describes how to configure KKP, the
OIDC provider and the reverse proxy so that login, logout, kubeconfig download, cluster sharing, the web terminal and
the Kubernetes Dashboard work on those hostnames. It requires KKP 2.31.4 or later.

The main hostname is the host of `spec.auth.issuerRedirectURL`, by default `spec.ingress.domain`. It does not need any
of the steps below.

{{% notice warning %}}
Whoever operates a listed hostname, or any reverse proxy in front of KKP, can read the sign-in data and sessions of
every user who signs in through it. Only list hostnames that serve nothing but KKP and that you operate yourself.
{{% /notice %}}

## Step 1: List the Hostnames in the KubermaticConfiguration

Add every additional hostname to `spec.auth.additionalIssuerRedirectURLs`:

```yaml
spec:
  auth:
    additionalIssuerRedirectURLs:
      - https://kkp-proxy.example.com
      - https://kkp-internal.example.com:8443
```

Each entry is an origin, written exactly as the browser shows it in the address bar:

- Scheme `http` or `https`, the host and an optional port. Nothing else: no path, query, fragment or user info.
- Lower case, and without the default port. `https://KKP-Proxy.example.com:443` is refused with the expected spelling
  `https://kkp-proxy.example.com`.
- A non-default port is part of the origin. `https://kkp-proxy.example.com:8443` and `https://kkp-proxy.example.com`
  are different entries.
- `http://localhost:<port>`, for example for a `kubectl port-forward`, works only when it is listed.

`kubermatic-installer deploy` checks the entries before it changes the cluster. If you apply the
KubermaticConfiguration in another way, an invalid entry may not be rejected when you apply it. The KKP API then does
not start and logs `invalid -oidc-issuer-additional-redirect-uris entry`.

A hostname that is not listed still serves the dashboard, but logins and the other OIDC flows started there return to
the main hostname. The KKP API logs `ignoring origin, using the default redirect URI` with the rejected origin.

## Step 2: Register the Redirect URIs at the OIDC Provider

Register these redirect URIs for every listed hostname:

| OIDC client | Redirect URIs | Used by |
|---|---|---|
| Login client (`spec.auth.clientID`, default `kubermatic`) | `<hostname>/api/v2/auth/callback` | Dashboard login |
| User Cluster client (`spec.auth.issuerClientID`, default `kubermaticIssuer`) | `<hostname>/api/v1/kubeconfig`, `<hostname>/api/v2/kubeconfig/secret`, `<hostname>/api/v2/dashboard/login` | Kubeconfig download, cluster sharing, web terminal, Kubernetes Dashboard |

In the deprecated single-client setup, register all four URIs on that client.

If a Seed has its own OIDC provider in `spec.oidcProviderConfiguration`, register the three User Cluster redirect URIs
for every listed hostname at that provider too.

For the bundled Dex, extend the `values.yaml` of the `dex` Helm chart:

```yaml
dex:
  config:
    staticClients:
      - id: kubermatic
        # ...
        RedirectURIs:
          - https://kkp.example.com/api/v2/auth/callback
          - https://kkp-proxy.example.com/api/v2/auth/callback
      - id: kubermaticIssuer
        # ...
        RedirectURIs:
          - https://kkp.example.com/api/v1/kubeconfig
          - https://kkp.example.com/api/v2/kubeconfig/secret
          - https://kkp.example.com/api/v2/dashboard/login
          - https://kkp-proxy.example.com/api/v1/kubeconfig
          - https://kkp-proxy.example.com/api/v2/kubeconfig/secret
          - https://kkp-proxy.example.com/api/v2/dashboard/login
```

For Keycloak, add the URIs to **Valid Redirect URIs** of the matching client.

## Step 3: Configure the Reverse Proxy

The reverse proxy must:

1. Forward requests with the `Host` header and the TLS server name (SNI) set to `spec.ingress.domain`. With another
   `Host`, KKP answers 404 on every path. With another server name, the TLS handshake fails.
2. Leave the `redirect_uri` query parameter unchanged. KKP stores the redirect URI of a login in a cookie and checks it
   at the callback, so a rewritten `redirect_uri` makes the login fail.
3. Rewrite the `Origin` header of live connections. The KKP API accepts a WebSocket under `/api/v1/ws/` only when its
   `Origin` matches the `Host`. For requests under `/api/v1/ws/` whose `Origin` is the additional hostname's own
   origin, set `Origin` to the main hostname's origin. Leave every other `Origin` value unchanged, so that KKP still
   refuses connections from foreign origins.

An nginx example for `kkp-proxy.example.com` in front of `kkp.example.com`:

```nginx
map $http_upgrade $connection_upgrade { default upgrade; '' close; }

server {
  listen 443 ssl;
  server_name kkp-proxy.example.com;
  # ssl_certificate and ssl_certificate_key for kkp-proxy.example.com

  location /api/v1/ws/ {
    set $ws_origin $http_origin;
    if ($http_origin = "https://kkp-proxy.example.com") { set $ws_origin "https://kkp.example.com"; }
    proxy_set_header Origin $ws_origin;

    proxy_pass https://kkp.example.com;
    proxy_ssl_server_name on;
    proxy_ssl_name kkp.example.com;
    proxy_set_header Host kkp.example.com;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection $connection_upgrade;
    proxy_read_timeout 3600s;
  }

  location / {
    proxy_pass https://kkp.example.com;
    proxy_ssl_server_name on;
    proxy_ssl_name kkp.example.com;
    proxy_set_header Host kkp.example.com;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection $connection_upgrade;
    proxy_read_timeout 3600s;
  }
}
```

KKP does not move the OIDC provider to the additional hostname. The browser is still sent to `spec.auth.tokenIssuer`,
for example `https://kkp.example.com/dex`. Users on the additional hostname must be able to reach that URL, or the
proxy must serve the provider path and rewrite the `Location` header of its responses. Login works with and without
`Location` rewriting.

## Step 4: Allow the Logout Redirect

This step is only needed when `oidc_logout_url` is set in `spec.ui.config`. Logging out on an additional hostname then
sends the user to the OIDC provider with a redirect back to `https://<hostname>/`, which the provider must accept. For
Keycloak, add `https://kkp-proxy.example.com/*` to **Valid post logout redirect URIs** of the login client.

Without `oidc_logout_url`, logging out returns the user to the dashboard on the same hostname, and nothing has to be
configured.

## Step 5: Set the Domain for MLA Links

The dashboard builds the links to the User Cluster Grafana and Alertmanager as
`https://<prefix>.<seed>.<domain>`. By default, `<domain>` is the hostname in the browser. If your reverse proxies do
not serve the Grafana and Alertmanager hosts, set `mla_links_domain` in `spec.ui.config` to `spec.ingress.domain`:

```yaml
spec:
  ui:
    config: |
      {
        "mla_links_domain": "kkp.example.com"
      }
```

See [Expose Grafana & Alertmanager UI]({{< ref "../../monitoring-logging-alerting/user-cluster/admin-guide/#expose-grafana--alertmanager-ui" >}}).

## Sessions

Sessions are per hostname. Signing in or out on one hostname does not sign the user in or out on another one.

## Troubleshooting

| Symptom | Cause |
|---|---|
| Dex shows `Unregistered redirect_uri`, Keycloak shows `Invalid parameter: redirect_uri` | The redirect URI of that hostname is missing on the client from [Step 2](#step-2-register-the-redirect-uris-at-the-oidc-provider). |
| Login returns to the main hostname | The hostname is not listed in `spec.auth.additionalIssuerRedirectURLs`, or its spelling differs from the browser origin. |
| Login fails at the callback with a missing `_oauth_state` cookie | The reverse proxy rewrites `redirect_uri`, or the hostname is not listed. |
| The web terminal or other live views fail with HTTP 403 | The reverse proxy does not rewrite `Origin` for `/api/v1/ws/`. |
| Every path returns 404 | The reverse proxy does not forward `Host` as `spec.ingress.domain`. |
