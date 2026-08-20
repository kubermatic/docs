+++
title = "Upgrading to KKP 2.24"
date = 2023-11-07T00:00:00+01:00
weight = 10
+++

{{% notice note %}}
Upgrading to KKP 2.24 is only supported from version 2.23. Do not attempt to upgrade from versions prior to that and apply the upgrade step by step over minor versions instead (e.g. from [2.22 to 2.23]({{< ref "../upgrade-from-2.22-to-2.23/" >}}) and then to 2.24). It is also strongly advised to be on the latest 2.23.x patch release before upgrading to 2.24.
{{% /notice %}}

This guide will walk you through upgrading Kubermatic Kubernetes Platform (KKP) to version 2.24. For the full list of changes in this release, please check out the [KKP changelog for v2.24](https://github.com/kubermatic/kubermatic/blob/main/docs/changelogs/CHANGELOG-2.24.md). Please read the full document before proceeding with the upgrade.

## Pre-Upgrade Considerations

{{% notice warning %}}
Please review [known issues]({{< ref "../../../architecture/known-issues/" >}}) before upgrading to understand if any issues might affect you. In specific, please review:

- [User Cluster API Servers Fail to Start on Seed with Cilium CNI]({{< ref "../../../architecture/known-issues/#user-cluster-api-servers-fail-to-start-on-seed-with-cilium-cni" >}})

This issue was fixed in KKP 2.24.2, but still is applicable to previous versions.
{{% /notice %}}

KKP 2.24 adjusts the list of supported Kubernetes versions and removes support for Kubernetes 1.24 and 1.25. Existing user clusters need to be migrated to 1.26+ or later before the KKP upgrade can begin.

### Removal of the Legacy Backup Controller

KKP ships with an advanced etcd backup/restore controller since version 2.17.0 (April 2021), which replaces the classic backup controller. Since 2.17 both controllers were part of KKP, but 2.24 now finally removes the long deprecated classic backup controller.

If your KKP setup is still using the legacy controller, you have to migrate your setup. Please refer to the [etcd backup/restore configuration]({{< ref "../../../tutorials-howtos/etcd-backups/" >}}) for more information on how to configure and enable the new controller.

### Multi-Network Support for vSphere

Beginning with this version, multiple networks can be configured for a single vSphere user cluster. To support this, the existing field `vmNetName` in both the `Cluster` and `Seed` CRDs has been deprecated. Instead the new fields `networks` should be used.

### OpenVPN Deprecation

This release deprecates support for using OpenVPN as the tunneling solution between the user cluster control planes (i.e. seed clusters) and the user cluster worker nodes. New clusters should use Konnectivity instead. Please refer to the [CNI documentation]({{< ref "../../../tutorials-howtos/networking/cni-cluster-network/" >}}) for more information on how to migrate existing clusters.

### Updated Metering Reports

The metering component (Enterprise Edition only) has been updated and the generated reports now contain different columns. The deprecated columns listed below are for the time being still part of the report, but consumers are advised to migrate to the new columns.

For the **cluster** report:

- The field `total-used-cpu-seconds` and has been deprecated, use `average-used-cpu-millicores` instead.
- The field `average-available-cpu-cores` and has been deprecated, use `average-available-cpu-millicores` instead.

For the **namespace** report:

- The field `total-used-cpu-seconds` and has been deprecated, use `average-used-cpu-millicores` instead.

Please refer to the [metering documentation]({{< ref "../../../tutorials-howtos/metering/" >}}) for more information.

## Upgrade Procedure

Before starting the upgrade, make sure your KKP Master and Seed clusters are healthy with no failing or pending Pods. If any Pod is showing problems, investigate and fix the individual problems before applying the upgrade. This includes the control plane components for user clusters, unhealthy user clusters should not be submitted to an upgrade.

### KKP Master Upgrade

Download the latest 2.24.x release archive for the correct edition (`ce` for Community Edition, `ee` for Enterprise Edition) from [the release page](https://github.com/kubermatic/kubermatic/releases) and extract it locally on your computer. Make sure you have the `values.yaml` you used to deploy KKP 2.23 available and already adjusted for any 2.24 changes (also see [Pre-Upgrade Considerations](#pre-upgrade-considerations)), as you need to pass it to the installer. The `KubermaticConfiguration` is no longer necessary (unless you are adjusting it), as the KKP operator will use its in-cluster representation. From within the extracted directory, run the installer:

```sh
$ ./kubermatic-installer deploy kubermatic-master --helm-values path/to/values.yaml

# example output for a successful upgrade
INFO[0000] 🚀 Initializing installer…                     edition="Enterprise Edition" version=v2.24.0
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
INFO[0002]       Updating release from 2.23.4 to 2.24.0…
INFO[0005]    ✅ Success.
INFO[0005]    📦 Deploying cert-manager…
INFO[0005]       Deploying Custom Resource Definitions…
INFO[0006]       Deploying Helm chart…
INFO[0007]       Updating release from 2.23.4 to 2.24.0…
INFO[0026]    ✅ Success.
INFO[0026]    📦 Deploying Dex…
INFO[0027]       Updating release from 2.23.4 to 2.24.0…
INFO[0030]    ✅ Success.
INFO[0030]    📦 Deploying Kubermatic Operator…
INFO[0030]       Deploying Custom Resource Definitions…
INFO[0034]       Deploying Helm chart…
INFO[0035]       Updating release from 2.23.4 to 2.24.0…
INFO[0064]    ✅ Success.
INFO[0064]    📦 Deploying Telemetry
INFO[0065]       Updating release from 2.23.4 to 2.24.0…
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

## Next Steps

- Try out Kubernetes 1.28, the latest Kubernetes release shipping with this version of KKP.
