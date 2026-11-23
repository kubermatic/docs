+++
title = "Upgrading to 1.2"
weight = 2
aliases = ["/developer-platform/v1.2/setup/upgrade/"]
+++

This guide covers upgrading a KDP installation from **1.1** to **1.2.0**.

{{% notice note %}}
Upgrading from **1.0** or older? Work through the earlier guides in order first, starting with
the [1.1 upgrade](/developer-platform/v1.1/setup/upgrade/), then return here.
{{% /notice %}}

{{% notice warning %}}
Take a backup / snapshot of your kcp state and cluster before upgrading, and test the
upgrade in a non-production environment first.
{{% /notice %}}

## Version matrix

Only the KDP backend and dashboard charts change in 1.2.0. kcp, Dex and the api-syncagent stay
on the same versions as in 1.1. See [Compatibility]({{< ref "/developer-platform/v1.2/introduction/compatibility" >}})
for the full list.

## Upgrade order

1. Upgrade the **KDP backend** chart to `1.2.0`.
2. Upgrade the **KDP dashboard** chart to `1.2.0`.

Each step uses the same `helm upgrade --install ...` commands as in
[Get Started]({{< ref "/developer-platform/v1.2/get-started" >}}), with `--version=1.2.0` for the KDP charts.

## Verify

- The kcp front-proxy and KDP controller-manager pods are `Ready` in `kdp-system`.
- Existing workspaces, `APIBindings`, and service objects are still present and reconciling.
- You can log in to the dashboard and browse your organisation's services.
