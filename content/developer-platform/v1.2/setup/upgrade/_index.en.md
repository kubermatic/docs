+++
title = "Upgrading to 1.2"
weight = 2
+++

This guide covers upgrading a KDP installation from **1.1** to **1.2.0**.

{{% notice note %}}
Upgrading from **1.0** or older? Work through the earlier guides in order first, starting with
the [1.1 upgrade](../../../v1.1/setup/upgrade/), then return here.
{{% /notice %}}

{{% notice warning %}}
Take a backup / snapshot of your kcp state and cluster before upgrading, and test the
upgrade in a non-production environment first.
{{% /notice %}}

## Version matrix

The KDP components are released together. For KDP 1.2.0, use:

| Component | Chart / image version |
| --------- | --------------------- |
| KDP backend (`developer-platform`) | `1.2.0` |
| KDP dashboard (`developer-platform-dashboard`) | `1.2.0` |
| kcp Helm chart | `0.16.6` (unchanged) |
| Dex Helm chart | `0.23.0` (unchanged) |
| api-syncagent (service clusters) | `v0.7.0` (unchanged) |

## Upgrade order

1. Upgrade the **KDP backend** chart to `1.2.0`.
2. Upgrade the **KDP dashboard** chart to `1.2.0`.

Each step uses the same `helm upgrade --install ...` commands as the
[quickstart]({{< relref "../quickstart" >}}), with `--version=1.2.0` for the KDP charts.

## Verify

- The kcp front-proxy and KDP controller-manager pods are `Ready` in `kdp-system`.
- Existing workspaces, `APIBindings`, and service objects are still present and reconciling.
- You can log in to the dashboard and browse your organization's services.
