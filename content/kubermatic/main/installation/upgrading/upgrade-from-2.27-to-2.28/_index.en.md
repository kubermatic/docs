+++
title = "[DRAFT] Upgrading to KKP 2.28"
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

### Node Exporter Upgrade (Seed MLA)

KKP 2.28 removes the custom Helm chart for Node Exporter and instead now reuses the official [upstream Helm chart](https://prometheus-community.github.io/helm-charts).

#### Migration Procedure

The following actions are required for migration before performing the upgrade:
- Replace the top-level key `nodeExporter` with `node-exporter` in the `values.yaml`
- The key `nodeExporter.rbacProxy` has been removed.  Use `node-exporter.kubeRBACProxy` instead to configure kube-rbac-proxy.

Once the above adjustments have been made, you can do the seed-mla installation.

If you are using `kubermatic-installer` for the Seed MLA installation, then it will take care of removing the resources for the deprecated node-exporter helm-chart and installing the new upstream based helm-chart by itself.

```bash
./kubermatic-installer deploy seed-mla --helm-values values.yaml
```

If you are installing MLA using GitOps / Manual way using HelmCLI, before upgrading, you must delete the existing delete the existing Helm release before doing the upgrade.

```bash
helm --namespace monitoring delete node-exporter
```
Afterwards you can install the new release from the chart using Helm CLI or using your favourite GitOps tool.

### Alertmanager Upgrade (Seed MLA)

KKP 2.28 removes the custom Helm chart for Alertmanager and instead now reuses the official [upstream Helm chart](https://prometheus-community.github.io/helm-charts).

#### Migration Procedure

For new alertmanager chart to work, kkp admin should review and upgrade the `values.yaml` file to adjust the keys of values as per the upstream chart requirements.

Under `alertmanager` key in `values.yaml`, make following changes:

- `replicas` --> `replicaCount`
- `storageClass` --> `persistence.storageClass`
- `storageSize` --> `persistence.size`
- `resources.alertmanager` --> `resources`
- `resources.reloader` --> `configmapReload.resources`
- `affinity.podAntiAffinity` --> replaced by podAntiAffinity preset called `soft` (which is a default in new KKP alertmanager chart). So you can simply remove the podAntiAffinity block from your values.yaml if you are ok with `soft` podAntiAffinity.

As part of KKP upgrade of monitoring components, the installer will remove the statefulset and then run the helm chart upgrade command.

Once the above adjustments have been made, you can do the seed-mla installation.

If you are using `kubermatic-installer` for the Seed MLA installation, then it will take care of removing the resources for the deprecated Alertmanager helm-chart and installing the new upstream based helm-chart by itself.

```bash
./kubermatic-installer deploy seed-mla --helm-values values.yaml
```

If you are installing MLA using GitOps / Manual way using HelmCLI, before upgrading, you must delete the existing Alertmanager STS manually before doing the upgrade.

```bash
kubectl delete -n monitoring alertmanager
```
Afterwards you can install the new release from the chart using Helm CLI or using your favourite GitOps tool.


## Upgrade Procedure

Before starting the upgrade, make sure your KKP Master and Seed clusters are healthy with no failing or pending Pods. If any Pod is showing problems, investigate and fix the individual problems before applying the upgrade. This includes the control plane components for user clusters, unhealthy user clusters should not be submitted to an upgrade.

### KKP Master Upgrade

Download the latest 2.28.x release archive for the correct edition (`ce` for Community Edition, `ee` for Enterprise Edition) from [the release page](https://github.com/kubermatic/kubermatic/releases) and extract it locally on your computer. Make sure you have the `values.yaml` you used to deploy KKP 2.28 available and already adjusted for any 2.28 changes (also see [Pre-Upgrade Considerations](#pre-upgrade-considerations)), as you need to pass it to the installer. The `KubermaticConfiguration` is no longer necessary (unless you are adjusting it), as the KKP operator will use its in-cluster representation. From within the extracted directory, run the installer:

```sh
$ ./kubermatic-installer deploy kubermatic-master --helm-values path/to/values.yaml

# Placeholder for example output for a successful upgrade

```

Upgrading seed clusters is not necessary, unless you are running the `minio` Helm chart or User Cluster MLA as distributed by KKP on them. They will be automatically upgraded by KKP components.

You can follow the upgrade process by either supervising the Pods on master and seed clusters (by simply checking `kubectl get pods -n kubermatic` frequently) or checking status information for the `Seed` objects. A possible command to extract the current status by seed would be:

```sh
$ kubectl get seeds -A -o jsonpath="{range .items[*]}{.metadata.name} - {.status}{'\n'}{end}"

# Place holder for output
```

Of particular interest to the upgrade process is if the `ResourcesReconciled` condition succeeded and if the `versions.kubermatic` field is showing the target KKP version. If this is not the case yet, the upgrade is still in flight. If the upgrade is stuck, try `kubectl -n kubermatic describe seed <seed name>` to see what exactly is keeping the KKP Operator from updating the Seed cluster.

## Post-Upgrade Considerations

### Deprecations and Removals

<!--
Mention any deprecations and removals here.
-->

## Next Steps

<!--
Mention next steps here.
-->
