+++
title = "Upgrading to 1.1"
weight = 2
+++

This guide covers upgrading a KDP installation from **1.0** to **1.1.0**. 1.1 is a minor
release: the main change is a patch-level kcp control-plane bump, and **Blueprints** are now
a supported, enabled feature.

{{% notice note %}}
Upgrading from **0.9.0**? First follow the 0.9 → 1.0 upgrade in the
[1.0 documentation](../../../v1.0/setup/upgrade/), then this guide.
{{% /notice %}}

{{% notice warning %}}
Take a backup / snapshot of your kcp state and cluster before upgrading, and test the
upgrade in a non-production environment first.
{{% /notice %}}

## Version matrix

The three KDP components are released together. For KDP 1.1.0, use:

| Component | Chart / image version |
| --------- | --------------------- |
| KDP backend (`developer-platform`) | `1.1.0` |
| KDP dashboard (`developer-platform-dashboard`) | `1.1.0` |
| KDP AI Agent (`developer-platform-ai-agent`) | `1.1.0` |
| kcp Helm chart | `0.16.6` (was `0.16.0`; kcp appVersion 0.32.3) |
| Dex Helm chart | `0.23.0` (unchanged) |
| api-syncagent (service clusters) | `v0.7.0` (unchanged) |

## Changes and required actions

### 1. kcp control-plane upgrade (0.16.0 → 0.16.6)

KDP 1.1 is built against kcp 0.32.3. Upgrade the kcp Helm chart to `0.16.6` **before**
upgrading the KDP backend:

```bash
helm upgrade --install kcp kcp \
    --repo=https://kcp-dev.github.io/helm-charts \
    --version=0.16.6 \
    --namespace=kdp-system \
    --values=kcp.values.yaml
```

This is a patch-level bump; no values migration is expected, but re-check your
`kcp.values.yaml` against the 0.16.6 chart for any new keys.

### 2. Blueprints are now enabled

[Blueprints]({{< relref "../../service-providers/blueprints" >}}) — composing several
published services into one publishable kind — are supported and enabled in 1.1. No
migration is required; this is a new capability. See the author guide above and
[Consuming Blueprints]({{< relref "../../platform-users/consuming-blueprints" >}}) for the
platform-user side.

## Upgrade order

1. Upgrade **kcp** to `0.16.6` (see above) and confirm the control plane is healthy.
2. Upgrade the **KDP backend** chart to `1.1.0`.
3. Upgrade the **KDP dashboard** chart to `1.1.0`.
4. Upgrade the **KDP AI Agent** chart to `1.1.0`.

Each step uses the same `helm upgrade --install …` commands as the
[quickstart]({{< relref "../quickstart" >}}), with `--version=1.1.0` for the KDP charts.

## Verify

- The kcp front-proxy and KDP controller-manager pods are `Ready` in `kdp-system`.
- Existing workspaces, `APIBindings`, and service objects are still present and reconciling.
- You can log in to the dashboard, browse your organization's services, and see Blueprints
  in the catalog.
