+++
title = "Upgrading to KKP 2.28"
date = 2025-03-17T00:00:00+02:00
weight = 10
+++

{{% notice warning %}}
This is a draft document for an unreleased version of KKP. The information contained here is subject to change and should not be used for production upgrades.
{{% /notice %}}

{{% notice note %}}
Upgrading to KKP 2.28 is only supported from version 2.27. Do not attempt to upgrade from versions prior to that and apply the upgrade step by step over minor versions instead (e.g. from [2.26 to 2.27]({{< ref "../upgrade-from-2.26-to-2.27/" >}}) and then to 2.28). It is also strongly advised to be on the latest 2.27.x patch release before upgrading to 2.28.
{{% /notice %}}

This guide will walk you through upgrading Kubermatic Kubernetes Platform (KKP) to version 2.28. For the full list of changes in this release, please check out the [KKP changelog for v2.28](https://github.com/kubermatic/kubermatic/blob/main/docs/changelogs/CHANGELOG-2.28.md). Please read the full document before proceeding with the upgrade.

## Pre-Upgrade Considerations

{{% notice warning %}}
Please review [known issues]({{< ref "../../../architecture/known-issues/" >}}) before upgrading to understand if any issues might affect you.
{{% /notice %}}

### Node Exporter 1.9 (Seed MLA)

KKP 2.28 removes the custom Helm chart and instead now reuses the official [upstream chart](https://prometheus-community.github.io/helm-charts). Migration will be taken care, if you are using `kubermatic-installer` to install the `seed-mla` components including node-exporter.

Note: Action required only if you are installing it in GitOps way, before upgrading you must delete the existing Helm release:

```bash
helm --namespace monitoring delete node-exporter
```
Afterwards you can install the new release from the chart.
