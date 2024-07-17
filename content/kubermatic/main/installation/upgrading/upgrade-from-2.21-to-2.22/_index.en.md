+++
title = "Upgrading to KKP 2.22"
date = 2023-02-13T00:00:00+01:00
weight = 10
+++

{{% notice note %}}
Upgrading to KKP 2.22 is only supported from version 2.21. Do not attempt to upgrade from versions prior to that and apply the upgrade step by step over minor versions instead (e.g. from [2.20 to 2.21]({{< ref "../upgrade-from-2.20-to-2.21/" >}}) and then to 2.22). It is also strongly advised to be on the latest 2.21.x patch release before upgrading to 2.22.
{{% /notice %}}

This guide will walk you through upgrading Kubermatic Kubernetes Platform (KKP) to version 2.22. For the full list of changes in this release, please check out the [KKP changelog for v2.22](https://github.com/kubermatic/kubermatic/blob/main/docs/changelogs/CHANGELOG-2.22.md). Please read the full document before proceeding with the upgrade.

## Pre-Upgrade Considerations

KKP 2.22 adjusts the list of supported Kubernetes versions and drops a couple of Kubernetes releases without upstream support. Support for Kubernetes 1.23 and below has been removed. As such, all user clusters should be upgraded to Kubernetes 1.24. Existing Kubernetes 1.23 user clusters with containerd will not block the upgrade procedure, but they will be upgraded to 1.24 automatically.

### Removal of Docker Support

Support for Docker as container runtime has been removed due to removal of `dockershim` in upstream Kubernetes. The only supported
container runtime in KKP 2.22 is therefore containerd. As such, the upgrade will fail if `kubermatic-installer` detects any user clusters
with Docker as container runtime.

It is necessary to migrate **existing clusters and cluster templates** to containerd before proceeding. This can be done either via the Kubermatic Dashboard
or with `kubectl`. On the Dashboard, just edit the cluster or cluster template, change the _Container Runtime_ field to `containerd` and save your changes.

![Change Container Runtime](@/images/installation/upgrade-container-runtime.png?classes=shadow,border&height=200 "Change Container Runtime")

If using `kubectl`, update the `containerRuntime` field that is part of the [`Cluster` spec]({{< ref "../../../references/crds/#clusterspec" >}})
and replace `docker` with `containerd`, e.g. by using `kubectl edit cluster <cluster name>` or by using `kubectl patch`:

```sh
kubectl patch cluster <cluster name> --type=merge -p '{"spec":{"containerRuntime":"containerd"}}'
```

As a last step, [existing Machines have to be rotated]({{< ref "../../../cheat-sheets/rollout-machinedeployment/" >}}) so they get re-deployed with containerd instead of Docker.

### etcd-launcher Enabled by Default

The [etcd-launcher feature]({{< ref "../../../cheat-sheets/etcd/etcd-launcher/" >}}) will be enabled by default starting with KKP 2.22. The feature is necessary to run the new backup and restore controllers, for example. Existing user clusters will be upgraded from the old etcd `StatefulSet` to `etcd-launcher`. This should be taken into consideration as it will happen upon the upgrade to 2.22.

To disable this, the feature gate for etcd-launcher can be explicitly disabled on the `KubermaticConfiguration` resource:

```yaml
apiVersion: kubermatic.k8c.io/v1
kind: KubermaticConfiguration
metadata:
  name: <<mykubermatic>>
  namespace: kubermatic
spec:
  featureGates:
    EtcdLauncher: false
[...]
```

However, be aware that the old etcd `StatefulSet` will be deprecated and removed in future releases. Disabling the feature gate should only be a temporary measure, e.g. to control the migration of individual clusters directly before enabling the feature globally.

### Kubermatic REST API Status

With this KKP release, admins and integrators are now advised to use the Kube API (i.e. KKP's [CRDs]({{< ref "../../../references/crds/" >}})) for integrating into the platform. The legacy REST API should be considered deprecated and all new integrations are recommended to use Kube API instead. One exception to this recommendation is when user context is required: all permission handling in KKP 2.x is implemented in the legacy API and does not rely on Kubernetes-native RBAC. Likewise giving end users access to every seed cluster is rarely desirable.

The legacy API has now been moved into the dashboard repository and while it is still installed as a regular part of a KKP setup, it should be considered private to the dashboard from now on.

## Upgrade Procedure

Before starting the upgrade, make sure your KKP Master and Seed clusters are healthy with no failing or pending Pods. If any Pod is showing problems, investigate and fix the individual problems before applying the upgrade. This includes the control plane components for user clusters, unhealthy user clusters should not be submitted to an upgrade.

### KKP Master Upgrade

Download the latest 2.22.x release archive for the correct edition (`ce` for Community Edition, `ee` for Enterprise Edition) from [the release page](https://github.com/kubermatic/kubermatic/releases) and extract it locally on your computer. Make sure you have the `values.yaml` you used to deploy KKP 2.21 available and already adjusted for any 2.22 changes (also see [Pre-Upgrade Considerations](#pre-upgrade-considerations)), as you need to pass it to the installer. The `KubermaticConfiguration` is no longer necessary (unless you are adjusting it), as the KKP operator will use its in-cluster representation. From within the extracted directory, run the installer:

```sh
$ ./kubermatic-installer deploy kubermatic-master --helm-values path/to/values.yaml

# example output for a successful upgrade
INFO[0000] 🚀 Initializing installer…                     edition="Enterprise Edition" version=v2.22.0
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
INFO[0002]       Updating release from 2.21.6 to 2.22.0…
INFO[0005]    ✅ Success.
INFO[0005]    📦 Deploying cert-manager…
INFO[0005]       Deploying Custom Resource Definitions…
INFO[0006]       Deploying Helm chart…
INFO[0007]       Updating release from 2.21.6 to 2.22.0…
INFO[0026]    ✅ Success.
INFO[0026]    📦 Deploying Dex…
INFO[0027]       Updating release from 2.21.6 to 2.22.0…
INFO[0030]    ✅ Success.
INFO[0030]    📦 Deploying Kubermatic Operator…
INFO[0030]       Deploying Custom Resource Definitions…
INFO[0034]       Deploying Helm chart…
INFO[0035]       Updating release from 2.21.6 to 2.22.0…
INFO[0064]    ✅ Success.
INFO[0064]    📦 Deploying Telemetry
INFO[0065]       Updating release from 2.21.6 to 2.22.0…
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

Upgrading seed clusters is no longer necessary in KKP 2.22, unless you are running the `minio` Helm chart or User Cluster MLA as distributed by KKP on them. They will be automatically upgraded by KKP components.

You can follow the upgrade process by either supervising the Pods on master and seed clusters (by simply checking `kubectl get pods -n kubermatic` frequently) or checking status information for the `Seed` objects. A possible command to extract the current status by seed would be:

```sh
$ kubectl get seeds -A -o jsonpath="{range .items[*]}{.metadata.name} - {.status}{'\n'}{end}"
kubermatic - {"clusters":5,"conditions":{"ClusterInitialized":{"lastHeartbeatTime":"2023-02-16T10:53:34Z","message":"All KKP CRDs have been installed successfully.","reason":"CRDsUpdated","status":"True"},"KubeconfigValid":{"lastHeartbeatTime":"2023-02-14T16:50:09Z","reason":"KubeconfigValid","status":"True"},"ResourcesReconciled":{"lastHeartbeatTime":"2023-02-14T16:50:14Z","reason":"ReconcilingSuccess","status":"True"}},"phase":"Healthy","versions":{"cluster":"v1.24.10","kubermatic":"v2.22.0"}}
```

Of particular interest to the upgrade process is if the `ResourcesReconciled` condition succeeded and if the `versions.kubermatic` field is showing the target KKP version. If this is not the case yet, the upgrade is still in flight. If the upgrade is stuck, try `kubectl -n kubermatic describe seed <seed name>` to see what exactly is keeping the KKP Operator from updating the Seed cluster.

After a Seed was successfully upgraded, user clusters on that Seed should start updating. Observe their control plane components in the respective cluster namespaces if you want to follow the upgrade process. This is the last step of the upgrade unless you are running User Cluster MLA (see below).

### User Cluster MLA Upgrade (if applicable)

{{% notice note %}}
This step can be skipped if User Cluster MLA was not installed previously.
{{% /notice %}}

Between KKP 2.21 and 2.22, the installation method for [User Cluster MLA]({{< ref "../../../architecture/monitoring-logging-alerting/user-cluster/" >}}) has changed and is now part of `kubermatic-installer`. Updated installation instructions can be found [here]({{< ref "../../../tutorials-howtos/monitoring-logging-alerting/user-cluster/admin-guide/" >}}).

User Cluster MLA should be upgraded after KKP has been upgraded to 2.22. This has to be done for each Seed that has User Cluster MLA installed.

#### Helm Values File

Providing a Helm values file for the User Cluster MLA installation is optional and depends on whether you have passed any non-standard configuration values to your MLA setup in earlier versions (e.g. to set the `StorageClass` for some components) or have set up IAP, you will need to merge all custom Helm values into a shared `mlavalues.yaml` file, similar to the `values.yaml` provided to `kubermatic-installer` for installing a KKP setup. For example, a file configuring IAP and custom Cortex storage would looks like this:

```yaml
# This is a example file, do not use it!
#
# Cortex configuration
cortex:
  compactor:
    persistentVolume:
      storageClass: kubermatic-slow
  store_gateway:
    persistentVolume:
      storageClass: kubermatic-slow
  ingester:
    persistentVolume:
      storageClass: kubermatic-slow
  alertmanager:
    persistentVolume:
      storageClass: kubermatic-slow

# IAP configuration
# this section is only needed if IAP was configured for MLA before
iap:
  oidc_issuer_url: <OIDC Issuer URL>
  deployments:
    grafana:
      <Grafana IAP configuration>
    alertmanager:
      <Alertmanager IAP configuration>
```

#### Running the Upgrade

{{% notice warning %}}
Upgrading User Cluster MLA is **briefly disruptive to Consul and Cortex availability**. Consider this when planning the
upgrade.
{{% /notice %}}

If a custom values file is required and is ready for use, `kubermatic-installer` can be used to upgrade User Cluster MLA. Ensure that you
uncomment the command flags that you need (e.g. `--helm-values` if you have a `mlavalues.yaml` to pass and `--mla-include-iap` if you are
using IAP for MLA; both flags are optional).

```sh
./kubermatic-installer deploy usercluster-mla \
  # uncomment if you are providing non-standard values
  # --helm-values mlavalues.yaml \
  # uncomment if you deployed MLA IAP before as well
  # --mla-include-iap \
  --config kubermatic.yaml
```

## Post-Upgrade Considerations


### KubeVirt Migration

KubeVirt cloud provider support graduates to GA in KKP 2.22 and has gained several new features. However, KubeVirt clusters need to be migrated after the KKP 2.22 upgrade. [Instructions are available in KubeVirt provider documentation]({{< ref "../../../architecture/supported-providers/kubevirt#migration-from-kkp-221" >}}).

### OSM Migration

The KKP upgrade migrates operating-system-manager (OSM) custom resources (`OperatingSystemProfiles`, `OperatingSystemConfigs`) to the user cluster to ensure that they do not conflict with OSM custom resources already installed on the Seed cluster. This process is automated and migrates existing, custom profiles accordingly. A new custom resource, `CustomOperatingSystemProfiles`, has been introduced on Seed clusters for providing custom profiles on that level.

You can find more information on this [in the documentation on how to use OSM in KKP]({{< ref "../../../tutorials-howtos/operating-system-manager/usage/#custom-operatingsystemprofiles" >}}). If you have been applying OSM custom resources through any means, you will need to adjust them accordingly.

### vSphere & OpenStack User Cluster Upgrades

KKP 2.22 introduces limitations to Kubernetes version upgrades for vSphere & OpenStack user clusters when the "in-tree" cloud providers are used. This has been added due to Kubernetes slowly removing provider-specific code from core Kubernetes, instead asking users to rely on external CCM (Cloud Controller Managers) and CSI drivers.

By default, new vSphere and OpenStack user clusters in KKP get created with external cloud provider support. However, some long running user clusters might still be using the in-tree implementations. KKP supports [CCM & CSI migration]({{< ref "../../../tutorials-howtos/ccm-migration/" >}}) for those user clusters. The Kubermatic Dashboard offers information about the current status via the "External CCM/CSI" check under "Misc" in the additional cluster information section.

The limitations in KKP 2.22 are as follows:

- **vSphere** user clusters **with Kubernetes 1.24** and in-tree cloud provider usage cannot be upgraded to 1.25 or higher.
- **OpenStack** user clusters **with Kubernetes 1.25** and in-tree cloud provider usage cannot be upgraded to 1.26 or higher.

For user clusters with the in-tree cloud provider, KKP will not offer those upgrade paths in the Dashboard. After clusters have been migrated to external CCM & CSI, upgrades to the next minor Kubernetes versions will be available.

## Next Steps

After finishing the upgrade, check out some of the new features that were added in KKP 2.22:

- [A web terminal has been added to interact with user clusters on a command line without leaving the Kubermatic Dashboard]({{< ref "../../../tutorials-howtos/project-and-cluster-management/web-terminal/" >}}).
- [Default resource quotas can be enforced for all projects to optimize resource consumption across an organization (EE only)]({{< ref "../../../architecture/concept/kkp-concepts/resource-quotas/#default-project-resource-quotas" >}}).
- Support for Kubernetes 1.25 and 1.26 has been added and can be used to create or upgrade user clusters.
- Various improvements to the look and feel of the Kubermatic Dashboard of your KKP instance.

Check out the [changelog](https://github.com/kubermatic/kubermatic/blob/main/docs/changelogs/CHANGELOG-2.22.md) for a full list of changes.
