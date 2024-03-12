+++
title = "Upgrading to KKP 2.25"
date = 2024-03-11T00:00:00+01:00
weight = 10
+++

{{% notice note %}}
Upgrading to KKP 2.25 is only supported from version 2.24. Do not attempt to upgrade from versions prior to that and apply the upgrade step by step over minor versions instead (e.g. from [2.23 to 2.24]({{< ref "../upgrade-from-2.23-to-2.24/" >}}) and then to 2.25). It is also strongly advised to be on the latest 2.24.x patch release before upgrading to 2.25.
{{% /notice %}}

This guide will walk you through upgrading Kubermatic Kubernetes Platform (KKP) to version 2.25. For the full list of changes in this release, please check out the [KKP changelog for v2.24](https://github.com/kubermatic/kubermatic/blob/main/docs/changelogs/CHANGELOG-2.25.md). Please read the full document before proceeding with the upgrade.

## Pre-Upgrade Considerations

{{% notice warning %}}
Please review [known issues]({{< ref "../../../architecture/known-issues/" >}}) before upgrading to understand if any issues might affect you.
{{% /notice %}}

KKP 2.25 adjusts the list of supported Kubernetes versions and removes support for Kubernetes 1.26. Existing user clusters need to be migrated to 1.27 or later before the KKP upgrade can begin.

### Bundled Velero Helm Chart

If the `velero` chart shipped with KKP is installed, its `values.yaml` file might require updating before running the KKP upgrade. In specific, the `restic` DaemonSet has been renamed to `node-agent`. Its configuration has changed the following ways:

- `velero.restic.deploy` has been replaced by `velero.deployNodeAgent`
- `velero.restic.resources` has been replaced by `velero.nodeAgent.resources`
- `velero.restic.nodeSelector` has been replaced by `velero.nodeAgent.nodeSelector`
- `velero.restic.affinity` has been replaced by `velero.nodeAgent.affinity`
- `velero.restic.tolerations` has been replaced by `velero.nodeAgent.tolerations`

### MLA Chart Upgrades

For KKP 2.25 several charts for user cluster MLA (`loki-distributed` and `cortex`, among others) have been upgraded to follow upstream charts. This will bring in updated versions with performance and stability improvements, but means that the previous `values.yaml` are no longer valid. `kubermatic-installer` will attempt to validate passed `values.yaml` for outdated configuration and fail validation if one is identified.

The default values shipped with KKP have been updated accordingly:

- [`values.yaml` for `loki-distributed`](https://github.com/kubermatic/kubermatic/blob/v2.25.0/charts/mla/loki-distributed/values.yaml) 
- [`values.yaml` for `cortex`](https://github.com/kubermatic/kubermatic/blob/v2.25.0/charts/mla/cortex/values.yaml)

If the `values.yaml` shipped by default in KKP have been copied / modified to be used for passing configuration, the modifications need to be migrated to the new structure before upgrading the user cluster MLA stack. Full upstream values are linked from each default values shipped by KKP.

In addition, the various `memcached-*` Helm charts are now sub-charts of `cortex`, which means that any modification to the default values need to be configured as sub-items of the `cortex` block in its `values.yaml` file.

## Upgrade Procedure

Before starting the upgrade, make sure your KKP Master and Seed clusters are healthy with no failing or pending Pods. If any Pod is showing problems, investigate and fix the individual problems before applying the upgrade. This includes the control plane components for user clusters, unhealthy user clusters should not be submitted to an upgrade.

### KKP Master Upgrade

Download the latest 2.25.x release archive for the correct edition (`ce` for Community Edition, `ee` for Enterprise Edition) from [the release page](https://github.com/kubermatic/kubermatic/releases) and extract it locally on your computer. Make sure you have the `values.yaml` you used to deploy KKP 2.24 available and already adjusted for any 2.25 changes (also see [Pre-Upgrade Considerations](#pre-upgrade-considerations)), as you need to pass it to the installer. The `KubermaticConfiguration` is no longer necessary (unless you are adjusting it), as the KKP operator will use its in-cluster representation. From within the extracted directory, run the installer:

```sh
$ ./kubermatic-installer deploy kubermatic-master --helm-values path/to/values.yaml

# example output for a successful upgrade
INFO[0000] 🚀 Initializing installer…                     edition="Enterprise Edition" version=v2.25.0
INFO[0000] 🚦 Validating the provided configuration…
WARN[0000]    Helm values: kubermaticOperator.imagePullSecret is empty, setting to spec.imagePullSecret from KubermaticConfiguration
INFO[0000] ✅ Provided configuration is valid.
INFO[0000] 🚦 Validating existing installation…
INFO[0001]    Checking seed cluster…                     seed=kubermatic
INFO[0001] ✅ Existing installation is valid.
INFO[0001] 🛫 Deploying KKP master stack…
INFO[0001]    💾 Deploying kubermatic-fast StorageClass…
INFO[0001]    ✅ StorageClass exists, nothing to do.
INFO[0001]    📦 Deploying nginx-ingress-controller…
INFO[0001]       Deploying Helm chart…
INFO[0002]       Updating release from 2.24.4 to 2.25.0…
INFO[0005]    ✅ Success.
INFO[0005]    📦 Deploying cert-manager…
INFO[0005]       Deploying Custom Resource Definitions…
INFO[0006]       Deploying Helm chart…
INFO[0007]       Updating release from 2.24.4 to 2.25.0…
INFO[0026]    ✅ Success.
INFO[0026]    📦 Deploying Dex…
INFO[0027]       Updating release from 2.24.4 to 2.25.0…
INFO[0030]    ✅ Success.
INFO[0030]    📦 Deploying Kubermatic Operator…
INFO[0030]       Deploying Custom Resource Definitions…
INFO[0034]       Deploying Helm chart…
INFO[0035]       Updating release from 2.24.4 to 2.25.0…
INFO[0064]    ✅ Success.
INFO[0064]    📦 Deploying Telemetry
INFO[0065]       Updating release from 2.24.4 to 2.25.0…
INFO[0066]    ✅ Success.
INFO[0066]    📡 Determining DNS settings…
INFO[0066]       The main LoadBalancer is ready.
INFO[0066]
INFO[0066]         Service             : nginx-ingress-controller / nginx-ingress-controller
INFO[0066]         Ingress via hostname: <Load Balancer>.eu-central-1.elb.amazonaws.com
INFO[0066]
INFO[0066]       Please ensure your DNS settings for "<KKP FQDN>" include the following records:
INFO[0066]
INFO[0066]          <KKP FQDN>.    IN  CNAME  <Load Balancer>.eu-central-1.elb.amazonaws.com.
INFO[0066]          *.<KKP FQDN>.  IN  CNAME  <Load Balancer>.eu-central-1.elb.amazonaws.com.
INFO[0066]
INFO[0066] 🛬 Installation completed successfully. ✌
```

Upgrading seed clusters is not necessary, unless you are running the `minio` Helm chart or User Cluster MLA as distributed by KKP on them. They will be automatically upgraded by KKP components.

You can follow the upgrade process by either supervising the Pods on master and seed clusters (by simply checking `kubectl get pods -n kubermatic` frequently) or checking status information for the `Seed` objects. A possible command to extract the current status by seed would be:

```sh
$ kubectl get seeds -A -o jsonpath="{range .items[*]}{.metadata.name} - {.status}{'\n'}{end}"
kubermatic - {"clusters":5,"conditions":{"ClusterInitialized":{"lastHeartbeatTime":"2023-02-16T10:53:34Z","message":"All KKP CRDs have been installed successfully.","reason":"CRDsUpdated","status":"True"},"KubeconfigValid":{"lastHeartbeatTime":"2023-02-14T16:50:09Z","reason":"KubeconfigValid","status":"True"},"ResourcesReconciled":{"lastHeartbeatTime":"2023-02-14T16:50:14Z","reason":"ReconcilingSuccess","status":"True"}},"phase":"Healthy","versions":{"cluster":"v1.24.10","kubermatic":"v2.24.0"}}
```

Of particular interest to the upgrade process is if the `ResourcesReconciled` condition succeeded and if the `versions.kubermatic` field is showing the target KKP version. If this is not the case yet, the upgrade is still in flight. If the upgrade is stuck, try `kubectl -n kubermatic describe seed <seed name>` to see what exactly is keeping the KKP Operator from updating the Seed cluster.

## Post-Upgrade Considerations

### Deprecations and Removals

Some functionality of KKP has been deprecated or removed with KKP 2.25. You should review the full [changelog](https://github.com/kubermatic/kubermatic/blob/main/docs/changelogs/CHANGELOG-2.25.md) and adjust any automation or scripts that might be using deprecated fields or features. Below is a list of changes that might affect you:

- The field `ovdcNetwork` in `cluster` and `preset` CRDs is considered deprecated for VMware Cloud Director and `ovdcNetworks` should be used instead ([#12996](https://github.com/kubermatic/kubermatic/pull/12996))
- Some of high cardinality metrics were dropped from the User Cluster MLA prometheus. If your KKP installation was using some of those metrics for the custom Grafana dashboards for the user clusters, your dashboards might stop showing some of the charts ([#12756](https://github.com/kubermatic/kubermatic/pull/12756))
- Deprecate v1.11 and v1.12 Cilium and Hubble KKP Addons, as Cilium CNI is managed by Applications from version 1.13 ([#12848](https://github.com/kubermatic/kubermatic/pull/12848))

## Next Steps

- Try out Kubernetes 1.29, the latest Kubernetes release shipping with this version of KKP.
- [Migrate]({{< ref "../../../tutorials-howtos/ccm-migration/" >}}) existing GCP clusters to use the external cloud controller manager (CCM).
- EE only: Configure and use [integrated user cluster backups]().
