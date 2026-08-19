+++
title = "Upgrading to KKP 2.31"
date = 2026-07-29T10:00:00+02:00
weight = 10
+++

{{% notice note %}}
Upgrading to KKP 2.31 is only supported from version 2.30. Do not attempt to upgrade from versions prior to that and apply the upgrade step by step over minor versions instead (e.g. from [2.29 to 2.30]({{< ref "../upgrade-from-2.29-to-2.30/" >}}) and then to 2.31). It is also strongly advised to be on the latest 2.30.x patch release before upgrading to 2.31.
{{% /notice %}}

This guide will walk you through upgrading Kubermatic Kubernetes Platform (KKP) to version 2.31. For the full list of changes in this release, please check out the [KKP changelog for v2.31](https://github.com/kubermatic/kubermatic/blob/main/docs/changelogs/CHANGELOG-2.31.md). Please read the full document before proceeding with the upgrade.

## Pre-Upgrade Considerations

{{% notice warning %}}
Please review [known issues]({{< ref "../../../architecture/known-issues/" >}}) before upgrading to understand if any issues might affect you.
{{% /notice %}}

### Dashboard Login Uses the OAuth Authorization Code Flow

The KKP dashboard now signs users in using the OAuth Authorization Code flow with PKCE instead of the Implicit flow. Tokens are exchanged by the KKP API and stored in `HttpOnly` cookies, and sessions are refreshed silently using a refresh token.

This requires changes to your OIDC provider and `KubermaticConfiguration` **before** upgrading. If you use the bundled Dex and the example configuration files shipped with the release, the necessary changes are already included. Adjust your configuration if you maintain it yourself or use a custom OIDC provider:

1. Register `https://<domain>/api/v2/auth/callback` as a valid redirect URI on your OIDC client. For Dex, add it to `.dex.config.staticClients[name=="kubermaticIssuer"].RedirectURIs` in `values.yaml`.
2. Set `.spec.auth.clientID` to the same value as `.spec.auth.issuerClientID` (both default to `kubermaticIssuer`). The dashboard no longer uses a separate public `kubermatic` client, which can be removed from your Dex configuration.
3. Make sure `.spec.auth.issuerClientSecret` and `.spec.auth.issuerCookieKey` are set. They were previously only needed for the OIDC kubeconfig feature and are now required for the dashboard login.
4. Make sure the client is a confidential client and can issue refresh tokens. KKP requests the `offline_access` scope on every login; Dex only returns a refresh token when that scope is granted, and without a refresh token users are signed back to the login page as soon as the ID token expires.
5. For Keycloak, enable Standard Flow, turn on client authentication and set the PKCE code challenge method to `S256`. `Implicit Flow Enabled` is no longer required.
6. Remove `oidc_provider_url`, `oidc_provider_scope`, `oidc_provider_client_id` and `oidc_connector_id` from `.spec.ui.config`. They are ignored now. `oidc_provider` and `oidc_logout_url` are still used to build the logout URL.

See [OIDC Provider Configuration]({{< ref "../../../tutorials-howtos/oidc-provider-configuration/" >}}) for the full configuration reference.

{{% notice warning %}}
Because the dashboard now uses the same OIDC client as the kubeconfig and web terminal flows, it is affected by the existing Dex limitation of one refresh token per user/client pair. Downloading a kubeconfig or opening a web terminal ends the running dashboard session once its ID token expires. See [OIDC refresh tokens are invalidated when the same user/client ID pair is authenticated multiple times]({{< ref "../../../architecture/known-issues/#oidc-refresh-tokens-are-invalidated-when-the-same-userclient-id-pair-is-authenticated-multiple-times" >}}).
{{% /notice %}}

### Gateway API Replaces nginx-ingress-controller

KKP 2.31 enforces the Gateway API with Envoy Gateway as the only way to route external traffic to the dashboard, API, Dex and the monitoring UIs. The nginx-ingress-controller path has been removed. The `migrateGatewayAPI` Helm value and the `--migrate-gateway-api` installer and `--enable-gateway-api` operator flags are accepted but ignored.

If you already migrated to Gateway API on KKP 2.30, there is nothing to do. Otherwise, prepare your `values.yaml` **before** upgrading:

1. Add the top-level `httpRoute` block and set `httpRoute.domain` to your `spec.ingress.domain`. Nothing defaults it, and with an empty value the Dex chart fails Gateway API validation at the API server, which aborts the dex Helm upgrade in the middle of the installer run.

```yaml
httpRoute:
  gatewayName: kubermatic
  gatewayNamespace: kubermatic
  domain: "kkp.example.com"  # replace with your domain
  timeout: 3600s
```

2. If you use cert-manager with the HTTP01 challenge, migrate your ClusterIssuer solver from `ingress.class: nginx` to `gatewayHTTPRoute` with `parentRefs` pointing at the Gateway `kubermatic` in the namespace `kubermatic`.
3. If you use external-dns, switch its sources from `ingress` to `gateway-httproute` before the legacy Ingress resources are deleted. With the default `sync` policy, external-dns removes records it created from Ingresses that no longer exist.

During the upgrade, the installer deploys the `envoy-gateway-controller` chart, waits up to 10 minutes for the Gateway and the Kubermatic and Dex HTTPRoutes to become ready, and then deletes the legacy Ingress resources. DNS must be flipped from the nginx LoadBalancer to the Envoy Gateway address; until then, requests still reaching nginx get a 404 because its Ingress resources are gone. The installer uninstalls the nginx-ingress-controller Helm release only when run with `--clean-nginx-lb`. For a staged DNS cutover, `--skip-ingress-cleanup` keeps the legacy Ingresses alive during a first pass; the two flags cannot be combined.

{{% notice note %}}
Separate seed clusters are not cleaned up automatically. If nginx-ingress-controller was deployed on separate seeds, remove it there manually.
{{% /notice %}}

See the [Gateway API Migration Guide]({{< ref "../../../tutorials-howtos/networking/gateway-api-migration/" >}}) for the complete procedure, including the staged cutover and the user-managed (BYO) Gateway option.

## Upgrade Procedure

Before starting the upgrade, make sure your KKP Master and Seed clusters are healthy with no failing or pending Pods. If any Pod is showing problems, investigate and fix the individual problems before applying the upgrade. This includes the control plane components for user clusters, unhealthy user clusters should not be submitted to an upgrade.

### KKP Master Upgrade

Download the latest 2.31.x release archive for the correct edition (`ce` for Community Edition, `ee` for Enterprise Edition) from [the release page](https://github.com/kubermatic/kubermatic/releases) and extract it locally on your computer. Make sure you have the `values.yaml` you used to deploy KKP 2.30 available and already adjusted for any 2.31 changes (also see [Pre-Upgrade Considerations](#pre-upgrade-considerations)), as you need to pass it to the installer. The `KubermaticConfiguration` is no longer necessary (unless you are adjusting it), as the KKP operator will use its in-cluster representation. From within the extracted directory, run the installer:

```sh
$ ./kubermatic-installer deploy kubermatic-master --helm-values path/to/values.yaml
```

Upgrading seed clusters is not necessary, unless you are running the `minio` Helm chart or User Cluster MLA as distributed by KKP on them. They will be automatically upgraded by KKP components.

You can follow the upgrade process by either supervising the Pods on master and seed clusters (by simply checking `kubectl get pods -n kubermatic` frequently) or checking status information for the `Seed` objects. A possible command to extract the current status by seed would be:

```bash
$ kubectl get seeds -A -o jsonpath="{range .items[*]}{.metadata.name} - {.status}{'\n'}{end}"
```

Of particular interest to the upgrade process is if the `ResourcesReconciled` condition succeeded and if the `versions.kubermatic` field is showing the target KKP version. If this is not the case yet, the upgrade is still in flight. If the upgrade is stuck, try `kubectl -n kubermatic describe seed <seed name>` to see what exactly is keeping the KKP Operator from updating the Seed cluster.

## Post-Upgrade Considerations

### Deprecations and Removals

Some functionality of KKP has been deprecated or removed with KKP 2.31. You should review the full [changelog](https://github.com/kubermatic/kubermatic/blob/main/docs/changelogs/CHANGELOG-2.31.md) and adjust any automation or scripts that might be using deprecated fields or features.
