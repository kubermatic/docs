+++
title = "Configuring the Dashboard"
weight = 3
+++

The KDP dashboard is configured through the values of its Helm chart,
`developer-platform-dashboard`. [Get Started]({{< ref "/developer-platform/v1.2/get-started" >}})
sets the minimum. This page covers the rest: login, feature flags, exposure and scaling.

After changing values, run the same `helm upgrade` command as in Get Started.

## Login

The dashboard logs users in with OIDC:

| Value | Purpose |
| ----- | ------- |
| `dashboard.config.app.baseURL` | The dashboard's public URL. |
| `dashboard.config.authentication.encryptionKey` | Key for the session cookies. Generate one with `openssl rand -base64 32`. |
| `dashboard.config.authentication.oidc.issuerURL`, `clientID`, `clientSecret` | The OIDC client the dashboard uses. |
| `dashboard.config.authentication.oidc.additionalScopes` | Scopes to request on top of `openid`, `email`, `profile` and `groups`. Default: none. |

Only set `additionalScopes` to `['federated:id']`, and only when your identity provider is Dex.
That scope tells the dashboard which Dex connector a user logged in through, which services can use
in their [external links]({{< ref "/developer-platform/v1.2/guides/service-providers/configuring-services#linking-to-your-own-ui" >}}).

{{% notice warning %}}
Don't set `additionalScopes` for other identity providers. Keycloak, Okta and Entra ID reject a
login request with a scope they don't know, so nobody can log in.
{{% /notice %}}

A login session lasts 24 hours. If login fails for any reason, the login page shows the same
generic error; check the dashboard's logs and your identity provider for the cause.

To keep the configuration out of your values file, set `dashboard.config.create: false` and point
`dashboard.config.secretRef.name` and `key` to an existing Secret that holds the same settings as
environment variables.

## Connections to KDP

| Value | Purpose |
| ----- | ------- |
| `dashboard.config.backend.frontProxyURL` | Public URL of the kcp front-proxy. The dashboard talks to KDP only through it. |
| `dashboard.config.storage.serverURL` | URL of the KDP storage server, usually `<frontProxyURL>/services/storage`. Needed for logo uploads. |
| `dashboard.config.features.kubeconfigDownload.serverURL` | API server URL in kubeconfigs users download. Defaults to `frontProxyURL`. |
| `dashboard.config.features.kubeconfigDownload.serverCA` | Path to a CA certificate to embed in downloaded kubeconfigs. Mount it with `dashboard.extraVolumeMounts`. |
| `dashboard.config.features.kubeconfigDownload.auth.oidc.*` | OIDC client for downloaded kubeconfigs. Defaults to the dashboard's own client. |

## Feature flags

Feature flags turn dashboard features on and off. Set them under
`dashboard.config.features.featureFlags`:

| Flag | Default | What it controls |
| ---- | ------- | ---------------- |
| `ui-builder-enabled` | `true` | The [UI Builder]({{< ref "/developer-platform/v1.2/guides/service-providers/ui-builder" >}}). |
| `service-composition-enabled` | `false` | The **Blueprints** entry in the sidebar. See [Blueprints]({{< ref "/developer-platform/v1.2/guides/service-providers/blueprints" >}}). |
| `ai-blueprints-enabled` | `true` | The AI assistant and **Fix with AI** in the Blueprint editor. |

{{% notice note %}}
`service-composition-enabled` only hides the sidebar entry. The Blueprints pages still open when
users go to their URL directly, and the Blueprint AI features are on by default.
{{% /notice %}}

To change flags without redeploying, run a [flagd](https://flagd.dev) server and set
`dashboard.config.features.flagd.enabled: true` with its `host`, `port` and `tls`. Flags set in the
Helm values then act as overrides on top of flagd.

## AI features

The UI Builder and the Blueprint AI assistant use an OpenAI-compatible model through the dashboard's
API component (`api.enabled`, on by default):

| Value | Purpose |
| ----- | ------- |
| `api.config.openaiKey` | API key. Without it, the AI features are unavailable and the rest of the dashboard works as normal. |
| `api.config.openaiModel` | Model to use. Optional. |
| `dashboard.config.features.uiBuilder.authToken` | Token between the dashboard and its API. Generated automatically and kept across upgrades if empty. |

The **Connect AI agent** dialog is set up under `dashboard.config.features.mcp`. See
[MCP Gateway]({{< ref "/developer-platform/v1.2/guides/platform-administration/mcp-gateway" >}}).

## Exposing the dashboard

Use either an Ingress or a Gateway API `HTTPRoute`:

- **Ingress:** `dashboard.ingress.create: true`, with `host`, `class` and, for TLS through
  cert-manager, `certIssuer`. Extra `annotations` are merged with the chart's own.
- **HTTPRoute:** `dashboard.httpRoute.create: true`, with `host` and the `parentRef` of your Gateway.

## Scaling and resources

The dashboard and its API both scale automatically between 2 and 5 replicas at 80% CPU or memory.
Change this under `dashboard.autoscaling` and `api.autoscaling`, and the requests and limits under
`dashboard.resources` and `api.resources`.

To add environment variables or volumes, use `dashboard.extraEnv`, `dashboard.extraVolumes` and
`dashboard.extraVolumeMounts` (and the same keys under `api`).
