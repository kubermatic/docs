+++
title = "Upgrading to KKP 2.26"
date = 2024-04-16T00:00:00+02:00
weight = 10
+++

{{% notice note %}}
Upgrading to KKP 2.26 is only supported from version 2.25. Do not attempt to upgrade from versions prior to that and apply the upgrade step by step over minor versions instead (e.g. from [2.24 to 2.25]({{< ref "../upgrade-from-2.24-to-2.25/" >}}) and then to 2.26). It is also strongly advised to be on the latest 2.25.x patch release before upgrading to 2.26.
{{% /notice %}}

This guide will walk you through upgrading Kubermatic Kubernetes Platform (KKP) to version 2.26. For the full list of changes in this release, please check out the [KKP changelog for v2.26](https://github.com/kubermatic/kubermatic/blob/release/v2.26/docs/changelogs/CHANGELOG-2.26.md). Please read the full document before proceeding with the upgrade.

## Pre-Upgrade Considerations

{{% notice warning %}}
Please review [known issues]({{< ref "../../../architecture/known-issues/" >}}) before upgrading to understand if any issues might affect you.
{{% /notice %}}

KKP 2.26 adjusts the list of supported Kubernetes versions and removes support for Kubernetes 1.27. Existing user clusters need to be migrated to 1.28 or later before the KKP upgrade can begin.

### Helm Chart Versioning

Beginning with KKP 2.26, Helm chart versions now use strict semvers without a leading "v" (i.e. `1.2.3` instead of `v1.2.3`). This change was made to improve compatibility with GitOps tooling that is very strict. The Git tags and container tags have not changed.

### Helm Chart Upgrades

KKP 2.26 ships a lot of major version upgrades for the Helm charts, most notably

* Loki & Promtail v2.5 to v2.9.x
* Grafana 9.x to 10.4.x

Some of these updates require manual intervention or at least checking whether a given KKP system is affected by upstream changes. Please read the following sections carefully before beginning the upgrade.

### Velero 1.14

Velero was updated from 1.10 to 1.14, which includes a number of significant improvements internally. In the same breath, KKP also replaced the custom Helm chart with the [official upstream Helm chart](https://github.com/vmware-tanzu/helm-charts/tree/main/charts/velero) for Velero.

Due to labelling changes, and in-place upgrade of Velero is not possible. It's recommended to delete the previous Helm release and install the chart fresh. Existing backups will not be affected by the switch, but Velero configuration created by Helm will be deleted and re-created (like `BackupStorageLocations`).

#### Configuration Changes

The switch to the upstream Helm chart requires adjusting the `values.yaml` used to install Velero. Most existing settings have a 1:1 representation in the new chart:

* `velero.podAnnotations` is now `velero.annotations`
* `velero.serverFlags` is now `velero.configuration.*` (each CLI flag is its own field in the YAML file, e.g. `serverFlags:["--log-format=json"]` would become `configuration.logFormat: "json"`)
* `velero.uploaderType` is now `velero.configuration.uploaderType`; note that the default has changed from restic to Kopia, see the next section below for more information.
* `velero.credentials` is now `velero.credentials.*`
* `velero.schedulesPath` is not available anymore, since putting additional files into a Helm chart before installing it is a rather unusual process. Instead, specify the desired schedules directly inside the `values.yaml` in `velero.schedules`
* `velero.backupStorageLocations` is now `velero.configuration.backupStorageLocation`
* `velero.volumeSnapshotLocations` is now `velero.configuration.volumeSnapshotLocation`
* `velero.defaultVolumeSnapshotLocations` is now `velero.configuration.defaultBackupStorageLocation`

{{< tabs name="Velero Helm Chart Upgrades" >}}
{{% tab name="old Velero Chart" %}}
```yaml
velero:
  podAnnotations:
    iam.amazonaws.com/role: arn:aws:iam::1234:role/velero

  backupStorageLocations:
    aws:
      provider: aws
      objectStorage:
        bucket: myclusterbackups
      config:
        region: eu-west-1

  # optionally define some of your volumeSnapshotLocations as the default;
  # each element in the list must be a string of the form "provider:location"
  defaultVolumeSnapshotLocations:
    - aws:aws

  # see https://velero.io/docs/v1.10/api-types/volumesnapshotlocation/
  volumeSnapshotLocations:
    aws:
      provider: aws
      config:
        region: eu-west-1

  uploaderType: restic

  serverFlags:
    - --log-format=json

  credentials:
    aws:
      accessKey: itsme
      secretKey: andthisismypassword

  schedulesPath: schedules/*
```
{{% /tab %}}

{{% tab name="new Velero Chart" %}}
```yaml
velero:
  annotations:
    iam.amazonaws.com/role: arn:aws:iam::1234:role/velero

  # schedules are no longer loaded from external files, but must be included inline
  schedules:
    hourly-cluster:
      schedule: 0 * * * *
      template:
        includeClusterResources: true
        includedNamespaces:
          - '*'
        snapshotVolumes: false
        ttl: 168h # 7 days

  configuration:
    uploaderType: restic
    logFormat: json

    backupStorageLocation:
      - name: aws
        provider: aws
        objectStorage:
          bucket: myclusterbackups
        config:
          region: eu-west-1

    volumeSnapshotLocation:
      - name: aws
        provider: aws
        config:
          region: eu-west-1

    defaultBackupStorageLocation: aws

  credentials:
    useSecret: true
    name: aws-credentials
    secretContents:
      cloud: |
        [default]
        aws_access_key_id=itsme
        aws_secret_access_key=andthisismypassword
```
{{% /tab %}}
{{< /tabs >}}

#### Kopia replaces restic

The default file backup solution in Velero is now [Kopia](https://kopia.io/), replacing the previous implementation using [restic](https://restic.net/). From a Velero user perspective this can be seen as an implementation detail and commands like `velero backup create` will continue to work as before. However, Kopia's data is stored in a new repository inside the backup storage location (for example if you used restic before and now switch to Kopia and use and S3 bucket for storage, you would end up with 3 directories in the bucket: `backups`, `restic` and `kopia`).

When migrating to Kopia, new backups will be made using it, but existing backups made using restic can still be restored. Once no old restic backups are required anymore, the `restic` directory in the backup storage can be deleted.

KKP's wrapper `velero` Helm chart is not configuring the backup tool, so it defaults to Kopia. If you wish to continue using restic, set `velero.uploaderType` to `restic` in your Helm `values.yaml` file. Note that restic support will eventually be removed from Velero, so a switch will be necessary at some point.

{{% notice note %}}
If you decide to switch to Kopia and do not need the restic repository anymore, consider rotating the repository password by updating the `velero-repo-credentials` Secret in the `velero` namespace. This should only be done before a new repository is created by Velero and changing it will also make all previously created repositories unavailable.
{{% /notice %}}

### cert-manager 1.14

The configuration syntax for cert-manager has changed slightly.

* Breaking: If you have `.featureGates` value set in `values.yaml`, the features defined there will no longer be passed to cert-manager webhook, only to cert-manager controller. Use the `webhook.featureGates` field instead to define features to be enabled on webhook.
* Potentially breaking: Webhook validation of CertificateRequest resources is stricter now: all `KeyUsages` and `ExtendedKeyUsages` must be defined directly in the CertificateRequest resource, the encoded CSR can never contain more usages that defined there.

### oauth2-proxy (IAP) 7.6

This upgrade includes one breaking change:

* A change to how auth routes are evaluated using the flags `skip-auth-route`/`skip-auth-regex`: the new behaviour uses the regex you specify to evaluate the full path including query parameters. For more details please read the [detailed PR description](https://github.com/oauth2-proxy/oauth2-proxy/issues/2271).
* The environment variable `OAUTH2_PROXY_GOOGLE_GROUP` has been deprecated in favor of `OAUTH2_PROXY_GOOGLE_GROUPS`. Next major release will remove this option.

### Loki & Promtail 2.9 (Seed MLA)

The Loki upgrade from 2.5 to 2.9 might be the most significant bump in this KKP release. Due to the amount of changes, it's necessary to delete the existing `loki` StatefulSet and letting Helm recreate it. Deleting the StatefulSet will not touch the PVCs and the new StatefulSet's pods will reuse the existing PVCs after the upgrade.

Before upgrading, review your `values.yaml` for Loki, as a number of syntax changes were made:

* Most importantly, `loki.config` is now a templated string that aggregates many other individual values specified in `loki`, for example `loki.tableManager` gets rendered into `loki.config.table_manager`, and `loki.loki.schemaConfig` gets rendered into `loki.config.schema_config`. To follow these changes, if you have `loki.config` in your `values.yaml`, rename it to `loki.loki`. Ideally you should not need to manually override the templating string in `loki.config` from the upstream chart anymore. Additionally, some values are moved out or renamed slightly:
  * `loki.config.schema_config` becomes `loki.loki.schemaConfig`
  * `loki.config.table_manager` becomes `loki.tableManager` (sic)
  * `loki.config.server` was removed, if you need to specify something, use `loki.loki.server`
* The base volume path for the Loki PVC was changed from `/data/loki` to `/var/loki`.
* Configuration for the default image has changed, there is no `loki.image.repository` field anymore, it's now `loki.image.registry` and `loki.image.repository`.
* `loki.affinity` is now a templated string and enabled by default; if you use multiple Loki replicas, your cluster needs to have multiple nodes to host these pods.
* All fields related to the Loki pod (`loki.tolerations`, `loki.resources`, `loki.nodeSelector` etc.) were moved below `loki.singleBinary`.
* Self-monitoring, Grafana Agent and selftests are disabled by default now, reducing the default resource requirements for the logging stack.
* `loki.singleBinary.persistence.enableStatefulSetAutoDeletePVC` is set to `false` to ensure that when the StatefulSet is deleted, the PVCs will not also be deleted. This allows for easier upgrades in the
future, but if you scale down Loki, you would have to manually deleted the leftover PVCs.

### Alertmanager 0.27 (Seed MLA)

This version removes the `v1` API which was deprecated since 2019. If you have custom integrations with Alertmanager, ensure none of them use the now removed API.

### blackbox-exporter 0.25 (Seed MLA)

This version changes the `proxy_connect_header` configuration structure to match Prometheus (see [PR](https://github.com/prometheus/blackbox_exporter/pull/1008)); update your `values.yaml` accordingly if you configured this option.

### helm-exporter 1.2.16 (Seed MLA)

KKP 2.26 removes the custom Helm chart and instead now reuses the official [upstream chart](https://shanestarcher.com/helm-charts/). Before upgrading you must delete the existing Helm release in your cluster:

```bash
$ helm --namespace monitoring delete helm-exporter
```

Afterwards you can install the new release from the chart.

### kube-state-metrics 2.12 (Seed MLA)

As is typical for kube-state-metrics, the upgrade simple, but the devil is in the details. There were many minor changes since v2.8, please review [the changelog](https://github.com/kubernetes/kube-state-metrics/releases) carefully if you built upon metrics provided by kube-state-metrics:

* The deprecated experimental VerticalPodAutoscaler metrics are no longer supported, and have been removed. It's recommend to use CustomResourceState metrics to gather metrics from custom resources like the Vertical Pod Autoscaler.
* Label names were regulated to adhere with OTel-Prometheus standards, so existing label names that do not follow the same may be replaced by the ones that do. Please refer to [the PR](https://github.com/kubernetes/kube-state-metrics/pull/2004) for more details.
* Label and annotation metrics aren't exposed by default anymore to reduce the memory usage of the default configuration of kube-state-metrics. Before this change, they used to only include the name and namespace of the objects which is not relevant to users not opting in these metrics.

### node-exporter 1.7 (Seed MLA)

This new version comes with a few minor backwards-incompatible changes:

* metrics of offline CPUs in CPU collector were removed
* bcache cache_readaheads_totals metrics were removed
* ntp collector was deprecated
* supervisord collector was deprecated

### Prometheus 2.51 (Seed MLA)

Prometheus had many improvements and some changes to the remote-write functionality that might affect you:

* Remote-write:
  * raise default samples per send to 2,000
  * respect `Retry-After` header on 5xx errors
  * error `storage.ErrTooOldSample` is now generating HTTP error 400 instead of HTTP error 500
* Scraping:
  * Do experimental timestamp alignment even if tolerance is bigger than 1% of scrape interval

### nginx-ingress-controller 1.10

nginx v1.10 brings quite a few potentially breaking changes:

* does not support chroot image (this will be fixed on a future minor patch release)
* dropped Opentracing and zipkin modules, just Opentelemetry is supported as of this release
* dropped support for PodSecurityPolicy
* dropped support for GeoIP (legacy), only GeoIP2 is supported
* The automatically generated `NetworkPolicy` from nginx 1.9.3 is now disabled by default, refer to https://github.com/kubernetes/ingress-nginx/pull/10238 for more information.

### Dex 2.40

The validation of username and password in the LDAP connector is much more strict now. Dex uses the [EscapeFilter](https://pkg.go.dev/gopkg.in/ldap.v1#EscapeFilter) function to check for special characters in credentials and prevent injections by denying such requests. Please ensure this is not an issue before upgrading.

Additionally, the custom `oauth` Helm chart in KKP has been deprecated and will be replaced with a new Helm chart, `dex`, which is based on the [official upstream chart](https://github.com/dexidp/helm-charts/tree/master/charts/dex), in KKP 2.27.

## Upgrade Procedure

Before starting the upgrade, make sure your KKP Master and Seed clusters are healthy with no failing or pending Pods. If any Pod is showing problems, investigate and fix the individual problems before applying the upgrade. This includes the control plane components for user clusters, unhealthy user clusters should not be submitted to an upgrade.

### KKP Master Upgrade

Download the latest 2.26.x release archive for the correct edition (`ce` for Community Edition, `ee` for Enterprise Edition) from [the release page](https://github.com/kubermatic/kubermatic/releases) and extract it locally on your computer. Make sure you have the `values.yaml` you used to deploy KKP 2.26 available and already adjusted for any 2.26 changes (also see [Pre-Upgrade Considerations](#pre-upgrade-considerations)), as you need to pass it to the installer. The `KubermaticConfiguration` is no longer necessary (unless you are adjusting it), as the KKP operator will use its in-cluster representation. From within the extracted directory, run the installer:

```sh
$ ./kubermatic-installer deploy kubermatic-master --helm-values path/to/values.yaml

# example output for a successful upgrade
INFO[0000] 🚀 Initializing installer…                     edition="Enterprise Edition" version=v2.26.0
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
INFO[0002]       Updating release from 2.25.3 to 2.26.0…
INFO[0005]    ✅ Success.
INFO[0005]    📦 Deploying cert-manager…
INFO[0005]       Deploying Custom Resource Definitions…
INFO[0006]       Deploying Helm chart…
INFO[0007]       Updating release from 2.25.3 to 2.26.0…
INFO[0026]    ✅ Success.
INFO[0026]    📦 Deploying Dex…
INFO[0027]       Updating release from 2.25.3 to 2.26.0…
INFO[0030]    ✅ Success.
INFO[0030]    📦 Deploying Kubermatic Operator…
INFO[0030]       Deploying Custom Resource Definitions…
INFO[0034]       Deploying Helm chart…
INFO[0035]       Updating release from 2.25.3 to 2.26.0…
INFO[0064]    ✅ Success.
INFO[0064]    📦 Deploying Telemetry
INFO[0065]       Updating release from 2.25.3 to 2.26.0…
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
kubermatic - {"clusters":5,"conditions":{"ClusterInitialized":{"lastHeartbeatTime":"2024-03-11T10:53:34Z","message":"All KKP CRDs have been installed successfully.","reason":"CRDsUpdated","status":"True"},"KubeconfigValid":{"lastHeartbeatTime":"2024-03-11T16:50:09Z","reason":"KubeconfigValid","status":"True"},"ResourcesReconciled":{"lastHeartbeatTime":"2024-03-11T16:50:14Z","reason":"ReconcilingSuccess","status":"True"}},"phase":"Healthy","versions":{"cluster":"v1.27.11","kubermatic":"v2.25.0"}}
```

Of particular interest to the upgrade process is if the `ResourcesReconciled` condition succeeded and if the `versions.kubermatic` field is showing the target KKP version. If this is not the case yet, the upgrade is still in flight. If the upgrade is stuck, try `kubectl -n kubermatic describe seed <seed name>` to see what exactly is keeping the KKP Operator from updating the Seed cluster.

## Post-Upgrade Considerations

### Deprecations and Removals

Some functionality of KKP has been deprecated or removed with KKP 2.26. You should review the full [changelog](https://github.com/kubermatic/kubermatic/blob/release/v2.26/docs/changelogs/CHANGELOG-2.26.md) and adjust any automation or scripts that might be using deprecated fields or features. Below is a list of changes that might affect you:

- TBD

## Next Steps

- Try out Kubernetes 1.31, the latest Kubernetes release shipping with this version of KKP.
- Try out [KubeLB 1.0](https://www.kubermatic.com/blog/introducing-kubelb/)'s [integration into KKP]({{< ref "../../../tutorials-howtos/kubelb/" >}}).
- EE only: Configure and use [integrated user cluster backups]({{< ref "../../../architecture/supported-providers/edge/" >}}).
