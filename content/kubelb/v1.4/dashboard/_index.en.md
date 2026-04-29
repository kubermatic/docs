+++
title = "KubeLB Dashboard"
linkTitle = "Dashboard"
date = 2026-04-23T10:00:00+02:00
weight = 25
description = "Web UI for KubeLB — browse tenants, LoadBalancers, Routes, and WAF policies across your fleet."
+++

## Overview

KubeLB Dashboard is the web UI for KubeLB. A single chart and binary cover both
Community and Enterprise editions — the edition is detected internally at
runtime, so there is no separate EE build. Source code and upstream
documentation live at [kubermatic/kubelb-dashboard](https://github.com/kubermatic/kubelb-dashboard);
consult that repository for the current feature set.

## Screenshots

Cluster overview with resource counts and health:

![Dashboard overview](/img/kubelb/common/dashboard/overview.png?classes=shadow,border "KubeLB Dashboard overview")

Tenant detail showing enabled features, DNS, certificates, and tunnel configuration:

![Tenant detail](/img/kubelb/common/dashboard/tenants.png?classes=shadow,border "Tenant detail view")

Route detail with endpoints, source, DNS/certificate state, and route conditions:

![Route detail](/img/kubelb/common/dashboard/routes.png?classes=shadow,border "Route detail view")

WAF policies list (Enterprise Edition):

![WAF policies](/img/kubelb/common/dashboard/waf.png?classes=shadow,border "WAF policies list")

## Install

Install the dashboard from the Kubermatic OCI registry:

```bash
helm upgrade kubelb-dashboard \
  oci://quay.io/kubermatic/helm-charts/kubelb-dashboard \
  --version v1.0.0 \
  --namespace kubelb --create-namespace --install
```

The dashboard is deployed alongside the KubeLB Manager in the `kubelb`
namespace on the management cluster.

## Expose via HTTPRoute

Enable the chart's built-in HTTPRoute (Gateway API v1) with `--set` flags. It
is independent of `ingress.enabled` — both may be on simultaneously.

```bash
helm install kubelb-dashboard oci://quay.io/kubermatic/helm-charts/kubelb-dashboard \
  --set httpRoute.enabled=true \
  --set httpRoute.parentRefs[0].name=kubelb \
  --set httpRoute.parentRefs[0].namespace=kubelb \
  --set httpRoute.hostnames[0]=app.example.com
```

Equivalent `values.yaml`:

```yaml
httpRoute:
  enabled: true
  parentRefs:
    - name: kubelb
      namespace: kubelb
  hostnames:
    - app.example.com
```

`parentRefs` must point at an existing Gateway. Omitting `httpRoute.rules`
routes PathPrefix `/` to the dashboard Service on `service.port`; override
`rules` for custom matches or backends.

## Expose via Ingress

Enable the chart's built-in Ingress with `--set` flags:

```bash
helm install kubelb-dashboard oci://quay.io/kubermatic/helm-charts/kubelb-dashboard \
  --set ingress.enabled=true \
  --set ingress.className=nginx \
  --set ingress.hosts[0].host=app.example.com \
  --set ingress.hosts[0].paths[0].path=/ \
  --set ingress.hosts[0].paths[0].pathType=Prefix
```

Equivalent `values.yaml`:

```yaml
ingress:
  enabled: true
  className: nginx
  hosts:
    - host: app.example.com
      paths:
        - path: /
          pathType: Prefix
```

For TLS termination, pair the Ingress with
[cert-manager](https://cert-manager.io) and populate `ingress.tls` and
`ingress.annotations` accordingly.

## OIDC Authentication

OIDC is off by default. The underlying API reads the following environment variables:

| Variable             | Required | Default                                      | Description                                               |
| -------------------- | -------- | -------------------------------------------- | --------------------------------------------------------- |
| `OIDC_ISSUER`        | Yes      | —                                            | OIDC provider issuer URL (e.g. `https://dex.example.com`) |
| `OIDC_CLIENT_ID`     | Yes      | —                                            | OIDC client ID                                            |
| `OIDC_CLIENT_SECRET` | Yes      | —                                            | OIDC client secret                                        |
| `SESSION_SECRET`     | Yes      | —                                            | 32+ char secret for encrypting session cookies            |
| `OIDC_REDIRECT_URI`  | No       | `http://localhost:{PORT}/auth/callback`      | Callback URL registered with IdP                          |
| `OIDC_SCOPES`        | No       | `openid email profile groups offline_access` | Space-separated scopes                                    |
| `SESSION_MAX_AGE`    | No       | `86400` (24h)                                | Session cookie max age in seconds                         |

{{% notice note %}}
All four required variables must be set together. A partial configuration
exits with an error. If none are set, the dashboard runs without
authentication.
{{% /notice %}}

Enable OIDC via `values.yaml`:

```yaml
auth:
  enabled: true
  oidc:
    issuerUrl: https://dex.example.com
    clientId: kubelb-dashboard
  existingSecret: kubelb-dashboard-auth
```

In production, supply `clientSecret` and `sessionSecret` through
`auth.existingSecret` rather than inline values, so secret material stays out
of the values file.

## Kubeconfig (optional)

For out-of-cluster access to the KubeLB management API, mount a kubeconfig
through an existing Secret:

```yaml
kubeconfig:
  existingSecret: kubelb-dashboard-kubeconfig
  key: kubeconfig
```

`kubeconfig.key` is the key inside the Secret that holds the kubeconfig file
(default `kubeconfig`). Leave `kubeconfig.existingSecret` empty to use the
in-cluster service account.

## Further Reading

- [kubermatic/kubelb-dashboard](https://github.com/kubermatic/kubelb-dashboard) — dashboard repository and README
- [kubelb-dashboard Helm chart README](https://github.com/kubermatic/kubelb-dashboard/blob/main/charts/kubelb-dashboard/README.md) — full values reference
- [KubeLB Manager installation]({{< relref "../installation" >}}) — install the management cluster the dashboard connects to
