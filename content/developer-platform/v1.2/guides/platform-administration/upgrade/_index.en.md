+++
title = "Upgrading to 1.2"
weight = 2
aliases = ["/developer-platform/v1.2/setup/upgrade/"]
+++

This guide covers upgrading a KDP installation from **1.1** to **1.2.1**.

{{% notice note %}}
Upgrading from **1.0** or older? Work through the earlier guides in order first, starting with
the [1.1 upgrade](/developer-platform/v1.1/setup/upgrade/), then return here.
{{% /notice %}}

{{% notice warning %}}
Take a backup or snapshot of your kcp state and cluster before upgrading, and test the
upgrade in a non-production environment first.
{{% /notice %}}

## What changes

kcp, Dex and the api-syncagent stay on the same versions as in 1.1. See
[Compatibility]({{< ref "/developer-platform/v1.2/introduction/compatibility" >}}). Only the KDP
backend and dashboard charts move to `1.2.1`. KDP 1.2 has no data migration, but both charts
gained new settings:

- **Storage server.** The KDP backend chart now deploys `kdp-storage-server`, which stores service
  and Blueprint logos. It is enabled by default and requests a 1Gi `ReadWriteOnce` volume from the
  default storage class (`kdp.storageServer.storage`). The kcp front-proxy must route
  `/services/storage/` to it, and the dashboard needs its URL.
- **Admission webhook.** The KDP controller manager now runs a webhook on port 9443 that enforces
  the `catalog.kdp.k8c.io/disallow-workspace-types` annotation on services.
- **MCP server and gateway.** New and disabled by default. See
  [MCP Gateway]({{< ref "/developer-platform/v1.2/guides/platform-administration/mcp-gateway" >}}).
- **AI Agent removed.** The dashboard chart no longer has the `features.aiAgent` settings. Remove
  them from your values.
- **Kubeconfig download is always on.** The dashboard's `features.kubeconfigDownload.enabled`
  setting was removed. Remove it from your values; the other `kubeconfigDownload` settings still
  apply.

## Upgrade steps

1. **Update kcp's front-proxy routes.** In `kcp.values.yaml`, make sure
   `kcpFrontProxy.additionalPathMappings` contains the same entries as in
   [Get Started]({{< ref "/developer-platform/v1.2/get-started" >}}). The `/services/storage/`
   entry is new in 1.2. If your installation followed the 1.1 quickstart, also add
   `/services/servicecatalog/` and `/services/uiconfiguration/`, which the dashboard uses for the
   service catalogue and the UI Builder. Then run the same `helm upgrade` command for kcp as
   before, with `--version=0.16.6`.
2. **Upgrade the KDP backend chart** to `1.2.1`:

   ```bash
   helm upgrade --install kdp \
       oci://quay.io/kubermatic/helm-charts/developer-platform \
       --version=1.2.1 \
       --namespace=kdp-system \
       --values=kdp.values.yaml
   ```

3. **Update the dashboard values.** Set `dashboard.config.storage.serverURL` to the storage path
   on your public API domain, for example `https://api.<DOMAIN>/services/storage`, and remove the
   settings listed above.
4. **Upgrade the KDP dashboard chart** to `1.2.1`:

   ```bash
   helm upgrade --install kdp-dashboard \
       oci://quay.io/kubermatic/helm-charts/developer-platform-dashboard \
       --version=1.2.1 \
       --namespace=kdp-system \
       --values=kdp-dashboard.values.yaml
   ```

## Verify

- All pods in `kdp-system` are `Running`, including `kdp-storage-server`, and its volume claim is
  `Bound`.
- Existing workspaces, `APIBindings` and service objects are still present and reconciling.
- You can log in to the dashboard, browse the service catalogue and see your organisation's
  services.
- Uploading a logo when creating or editing a service works. If it fails, check the
  `/services/storage/` route and `dashboard.config.storage.serverURL`.
