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

If you upgrade from KKP 2.31.0, 2.31.1, 2.31.2 or 2.31.3, follow [Upgrading from KKP 2.31.0, 2.31.1, 2.31.2 or 2.31.3](#upgrading-from-kkp-2310-2311-2312-or-2313) and skip the list below.

The dashboard login uses its own OIDC client, `kubermatic` (`.spec.auth.clientID`). The User Cluster flows (kubeconfig download, web terminal in OIDC mode, Kubernetes Dashboard) keep using `kubermaticIssuer` (`.spec.auth.issuerClientID`). This requires changes to your OIDC provider and `KubermaticConfiguration` **before** upgrading. If you use the bundled Dex and the example configuration files shipped with the release, the necessary changes are already included. Adjust your configuration if you maintain it yourself or use a custom OIDC provider:

1. Keep the `kubermatic` client and register `https://<domain>/api/v2/auth/callback` as a valid redirect URI on it. For Dex, add it to `.dex.config.staticClients[id=="kubermatic"].RedirectURIs` in `values.yaml`. Do not add this URI to the `kubermaticIssuer` client. Remove `https://<domain>/projects` and `https://<domain>` from the redirect URIs of the `kubermatic` client. The Implicit flow of KKP 2.30 used them, and KKP 2.31 does not.
2. Set `.spec.auth.clientSecret` to the secret of the `kubermatic` client. If the client has no secret yet, generate one, for example with `cat /dev/urandom | base64 | tr -dc 'A-Za-z0-9' | head -c32`, and set the same value in the OIDC provider. `kubermatic-installer deploy` stops when `.spec.auth.clientSecret` is missing, and the KKP API does not start without it.
3. Make sure `.spec.auth.issuerClientSecret` and `.spec.auth.issuerCookieKey` are set. The dashboard login uses `.spec.auth.issuerCookieKey`, and the User Cluster flows use `.spec.auth.issuerClientSecret`.
4. Make sure the `kubermatic` client is a confidential client and can issue refresh tokens. KKP requests the `offline_access` scope on every login; Dex only returns a refresh token when that scope is granted, and without a refresh token users are signed back to the login page as soon as the ID token expires.
5. For Keycloak, enable Standard Flow on the `kubermatic` client, turn on client authentication and set the PKCE code challenge method to `S256`. `Implicit Flow Enabled` is no longer required.
6. Make sure the OIDC provider does not add `kubermaticIssuer` to the audience of tokens issued for `kubermatic`, for example through Dex trusted peers or a Keycloak audience mapper. When a login token has several audiences, its `azp` claim must be `kubermatic`. Dex and Keycloak set it by default.
7. Remove `oidc_provider_url`, `oidc_provider_scope`, `oidc_provider_client_id` and `oidc_connector_id` from `.spec.ui.config`. They are ignored now. `oidc_provider` and `oidc_logout_url` are still used to build the logout URL.
8. If `.spec.ui.config` sets `oidc_logout_url`, the OIDC provider sends users back to `https://<domain>/` after they log out. Register this exact URI, with the trailing slash, as a post-logout redirect URI on the `kubermatic` client, and `<hostname>/` for every additional hostname. For Keycloak, add them to Valid post logout redirect URIs. They replace `https://<domain>/projects`, which KKP 2.30 used after logout.

KKP 2.31 uses these redirect URIs. For every additional hostname, register the same URIs with `<hostname>` in place of `https://<domain>`.

| Client | Redirect URI | Used for | Required |
|---|---|---|---|
| `kubermatic` | `https://<domain>/api/v2/auth/callback` | Dashboard login | Yes |
| `kubermatic` | `https://<domain>/` | Return to the dashboard after logout at the OIDC provider | Only when `oidc_logout_url` is set |
| `kubermaticIssuer` | `https://<domain>/api/v1/kubeconfig` | OIDC kubeconfig download | Yes |
| `kubermaticIssuer` | `https://<domain>/api/v2/kubeconfig/secret` | Web terminal in OIDC mode | Yes |
| `kubermaticIssuer` | `https://<domain>/api/v2/dashboard/login` | Kubernetes Dashboard | Yes |

`https://<domain>/projects` and `https://<domain>` are not used anymore. Remove them from the `kubermatic` client.

See [OIDC Provider Configuration]({{< ref "../../../tutorials-howtos/oidc-provider-configuration/" >}}) for the full configuration reference.

After the upgrade, users see the login page once. OIDC kubeconfigs downloaded before the upgrade, the web terminal and the Kubernetes Dashboard keep working, because the `kubermaticIssuer` client does not change.

{{% notice warning %}}
We recommend two separate clients: `kubermatic` for the dashboard login and `kubermaticIssuer` for User Cluster access. Using a single client for both purposes, by setting `.spec.auth.clientID` to the value of `.spec.auth.issuerClientID`, is deprecated and will not be supported in an upcoming KKP release.
{{% /notice %}}

#### Upgrading from KKP 2.31.0, 2.31.1, 2.31.2 or 2.31.3

Starting with KKP 2.31.4, `.spec.auth.clientID` defaults to `kubermatic`, a separate client for the dashboard login. What happens on the upgrade depends on your configuration:

- If `.spec.auth.clientID` is not set, the dashboard login switches to the `kubermatic` client, and `.spec.auth.clientSecret` becomes required. Complete the steps below **before** upgrading.
- If `.spec.auth.clientID` is set to `kubermaticIssuer`, the installation keeps using a single client. This setup is deprecated. Move to two clients with the steps below.

To move to two clients:

1. Create the `kubermatic` client in your OIDC provider if it does not exist, as a confidential client with a secret. For the bundled Dex, add it to `.dex.config.staticClients` in `values.yaml`:

   ```yaml
   dex:
     config:
       staticClients:
         - id: kubermatic
           name: Kubermatic Dashboard
           secret: <a-random-key>
           RedirectURIs:
             - https://<domain>/api/v2/auth/callback
   ```

   If users also sign in on additional hostnames (`.spec.auth.additionalIssuerRedirectURLs`), add `<hostname>/api/v2/auth/callback` for each of them.

   If `.spec.ui.config` sets `oidc_logout_url`, also register `https://<domain>/` as a post-logout redirect URI on the `kubermatic` client, and `<hostname>/` for every additional hostname. For Keycloak, add them to Valid post logout redirect URIs.

   If the `kubermatic` client still exists from KKP 2.30, remove `https://<domain>/projects` and `https://<domain>` from its redirect URIs. KKP 2.31 does not use them.

2. Set `.spec.auth.clientSecret` to the secret of the `kubermatic` client. If you set `.spec.auth.clientID` to `kubermaticIssuer` before, remove it or set it to `kubermatic`.
3. Upgrade with `kubermatic-installer deploy` as described in [KKP Master Upgrade](#kkp-master-upgrade). The installer stops before it changes the cluster if `.spec.auth.clientSecret` is missing.
4. After the dashboard login works with the `kubermatic` client, remove the `/api/v2/auth/callback` URIs of the main hostname and of every additional hostname from the `kubermaticIssuer` client. If you registered post-logout redirect URIs on the `kubermaticIssuer` client, remove them too.

If you upgrade without the installer, for example with GitOps, the KubermaticConfiguration is usually not validated when you apply it. In that case the new KKP API Pods do not start and log `-oidc-authenticator-client-secret is required when -oidc-authenticator-client-id differs from -oidc-issuer-client-id` until `.spec.auth.clientSecret` is set.

If users reach KKP through reverse proxies on other hostnames, configure them as described in [Additional Hostnames]({{< ref "../../../tutorials-howtos/oidc-provider-configuration/#additional-hostnames" >}}) in the same maintenance window as the upgrade.

### Web Terminal ServiceAccount Mode

Starting with KKP 2.31.4, the web terminal can run in ServiceAccount mode. For every user who opens a terminal, KKP creates a ServiceAccount in the user cluster that acts as that user. The terminal then does not use the user's OIDC login, and users do not have to log in a second time. We recommend enabling ServiceAccount mode after the upgrade.

To enable it, set the `WebTerminalServiceAccount` and `OpenIDAuthPlugin` feature gates to `true`, in addition to the `OIDCKubeCfgEndpoint` feature gate that the web terminal already needs:

```yaml
apiVersion: kubermatic.k8c.io/v1
kind: KubermaticConfiguration
metadata:
  name: kubermatic
  namespace: kubermatic
spec:
  featureGates:
    OIDCKubeCfgEndpoint: true
    OpenIDAuthPlugin: true
    WebTerminalServiceAccount: true
```

ServiceAccount mode works only for user clusters that use the default KKP authentication. It is not available when the user cluster, its Seed or its datacenter has its own authentication configuration, when the user cluster sets its own OIDC issuer, or when the Seed uses its own OIDC provider. Users need a verified email address. Changing the `WebTerminalServiceAccount` feature gate restarts the KKP API, the KKP controller managers, the KKP webhook and the user cluster controller manager of every user cluster once.

See [ServiceAccount Mode]({{< ref "../../../tutorials-howtos/project-and-cluster-management/web-terminal/#serviceaccount-mode" >}}) for details.

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

### KKP Now Applies KubeLB Tenant Defaults to Existing Tenants

KKP now reconciles `Project.spec.defaultTenantSpec` against new and existing KubeLB Tenants using Server-Side Apply. Changing the defaults updates the Tenants of all KubeLB-enabled clusters in the project. Removing a field from the defaults also removes it from the Tenants, but only if KKP set the field. KKP preserves fields set by other components and reports conflicts as errors without interrupting KubeLB CCM maintenance.

KKP adopts fields set by the previous KKP version only while they are present in the project defaults. Other fields keep their current value; KKP does not prune them later.

Custom management-cluster credentials must now allow the `patch` verb on `tenants.kubelb.k8c.io`. Check the kubeconfig you use for the KubeLB management cluster and add the permission before upgrading. For details, see [KubeLB]({{< ref "../../../tutorials-howtos/kubelb/" >}}).

## Upgrade Procedure

Before starting the upgrade, make sure your KKP Master and Seed clusters are healthy with no failing or pending Pods. If any Pod is showing problems, investigate and fix the individual problems before applying the upgrade. This includes the control plane components for user clusters, unhealthy user clusters should not be submitted to an upgrade.

### KKP Master Upgrade

Download the latest 2.31.x release archive for the correct edition (`ce` for Community Edition, `ee` for Enterprise Edition) from [the release page](https://github.com/kubermatic/kubermatic/releases) and extract it locally on your computer. Make sure you have the `values.yaml` you used to deploy KKP 2.30 available and already adjusted for any 2.31 changes (also see [Pre-Upgrade Considerations](#pre-upgrade-considerations)), as you need to pass it to the installer. The `KubermaticConfiguration` is no longer necessary (unless you are adjusting it), as the KKP operator will use its in-cluster representation. From within the extracted directory, run the installer:

```sh
$ ./kubermatic-installer deploy kubermatic-master --helm-values path/to/values.yaml
```

Existing Seed resources managed by KKP controllers are reconciled automatically after the Master upgrade. Installer-managed Helm releases are not. If you use any of the following charts distributed with KKP, upgrade them explicitly with the 2.31 installer and the same Helm values and options used for the 2.30 deployment, adjusted for any 2.31 configuration changes.

- Upgrade the KKP-distributed Seed MinIO and S3 exporter with the `kubermatic-seed` stack:

  ```sh
  $ ./kubermatic-installer deploy kubermatic-seed --helm-values path/to/seed-values.yaml [other options]
  ```

- Upgrade Seed MLA with the `seed-mla` stack:

  ```sh
  $ ./kubermatic-installer deploy seed-mla --helm-values path/to/seed-mla-values.yaml [other options]
  ```

- Upgrade User Cluster MLA with the `usercluster-mla` stack:

  ```sh
  $ ./kubermatic-installer deploy usercluster-mla --helm-values path/to/usercluster-mla-values.yaml [other options]
  ```

When IAP is installed with an MLA stack, include `--mla-include-iap`, as in the 2.30 deployment. For a separate Seed cluster, run the applicable commands against that Seed's kubeconfig and include `--separate-seed`. Repeat the commands for every Seed where these installer-managed charts are installed. Complete these upgrades and verify their Pods, Helm releases, and HTTPRoutes before removing the legacy nginx LoadBalancer with `--clean-nginx-lb`.

You can follow the upgrade process by either supervising the Pods on master and seed clusters (by simply checking `kubectl get pods -n kubermatic` frequently) or checking status information for the `Seed` objects. A possible command to extract the current status by seed would be:

```bash
$ kubectl get seeds -A -o jsonpath="{range .items[*]}{.metadata.name} - {.status}{'\n'}{end}"
```

Of particular interest to the upgrade process is if the `ResourcesReconciled` condition succeeded and if the `versions.kubermatic` field is showing the target KKP version. If this is not the case yet, the upgrade is still in flight. If the upgrade is stuck, try `kubectl -n kubermatic describe seed <seed name>` to see what exactly is keeping the KKP Operator from updating the Seed cluster.

## Post-Upgrade Considerations

### Deprecations and Removals

Some functionality of KKP has been deprecated or removed with KKP 2.31. You should review the full [changelog](https://github.com/kubermatic/kubermatic/blob/main/docs/changelogs/CHANGELOG-2.31.md) and adjust any automation or scripts that might be using deprecated fields or features.
