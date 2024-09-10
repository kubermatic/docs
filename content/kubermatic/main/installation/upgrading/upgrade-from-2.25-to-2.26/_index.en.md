+++
title = "Upgrading to KKP 2.26"
date = 2024-04-16T00:00:00+02:00
weight = 10
+++

{{% notice note %}}
Upgrading to KKP 2.26 is only supported from version 2.25. Do not attempt to upgrade from versions prior to that and apply the upgrade step by step over minor versions instead (e.g. from [2.24 to 2.25]({{< ref "../upgrade-from-2.24-to-2.25/" >}}) and then to 2.26). It is also strongly advised to be on the latest 2.25.x patch release before upgrading to 2.26.
{{% /notice %}}

This guide will walk you through upgrading Kubermatic Kubernetes Platform (KKP) to version 2.26. For the full list of changes in this release, please check out the [KKP changelog for v2.26](https://github.com/kubermatic/kubermatic/blob/main/docs/changelogs/CHANGELOG-2.26.md). Please read the full document before proceeding with the upgrade.

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

#### Velero 1.13

Velero was updated from 1.10 to 1.13, which includes a number of significant improvements internally.

* The default file-level backup tool was changed from Restic to Kopia. To keep backwards-compatibility, the KKP `velero` chart now explicitly configures Restic, but we expect that switching to Kopia will be mandatory in the future. Please use the `restic.uploaderType` variable in the `values.yaml` to switch to Kopia when desired.

#### cert-manager 1.14

The configuration syntax for cert-manager has changed slightly.

* Breaking: If you have `.featureGates` value set in `values.yaml`, the features defined there will no longer be passed to cert-manager webhook, only to cert-manager controller. Use the `webhook.featureGates` field instead to define features to be enabled on webhook.
* Potentially breaking: Webhook validation of CertificateRequest resources is stricter now: all `KeyUsages` and `ExtendedKeyUsages` must be defined directly in the CertificateRequest resource, the encoded CSR can never contain more usages that defined there.

#### oauth2-proxy (IAP) 7.6

This upgrade includes one breaking change:

* A change to how auth routes are evaluated using the flags `skip-auth-route`/`skip-auth-regex`: the new behaviour uses the regex you specify to evaluate the full path including query parameters. For more details please read the [detailed PR description](https://github.com/oauth2-proxy/oauth2-proxy/issues/2271).
* The environment variable `OAUTH2_PROXY_GOOGLE_GROUP` has been deprecated in favor of `OAUTH2_PROXY_GOOGLE_GROUPS`. Next major release will remove this option.

#### Loki & Promtail 2.9 (Seed MLA)

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

#### Alertmanager 0.27 (Seed MLA)

This version removes the `v1` API which was deprecated since 2019. If you have custom integrations with Alertmanager, ensure none of them use the now removed API.

#### blackbox-exporter 0.25 (Seed MLA)

This version changes the `proxy_connect_header` configuration structure to match Prometheus (see [PR](https://github.com/prometheus/blackbox_exporter/pull/1008)); update your `values.yaml` accordingly if you configured this option.

#### helm-exporter 1.2.16 (Seed MLA)

KKP 2.26 removes the custom Helm chart and instead now reuses the official [upstream chart](https://shanestarcher.com/helm-charts/). Before upgrading you must delete the existing Helm release in your cluster:

```bash
$ helm --namespace monitoring delete helm-exporter
```

Afterwards you can install the new release from the chart.

#### kube-state-metrics 2.12 (Seed MLA)

As is typical for kube-state-metrics, the upgrade simple, but the devil is in the details. There were many minor changes since v2.8, please review [the changelog](https://github.com/kubernetes/kube-state-metrics/releases) carefully if you built upon metrics provided by kube-state-metrics:

* The deprecated experimental VerticalPodAutoscaler metrics are no longer supported, and have been removed. It's recommend to use CustomResourceState metrics to gather metrics from custom resources like the Vertical Pod Autoscaler.
* Label names were regulated to adhere with OTel-Prometheus standards, so existing label names that do not follow the same may be replaced by the ones that do. Please refer to [the PR](https://github.com/kubernetes/kube-state-metrics/pull/2004) for more details.
* Label and annotation metrics aren't exposed by default anymore to reduce the memory usage of the default configuration of kube-state-metrics. Before this change, they used to only include the name and namespace of the objects which is not relevant to users not opting in these metrics.

#### node-exporter 1.7 (Seed MLA)

This new version comes with a few minor backwards-incompatible changes:

* metrics of offline CPUs in CPU collector were removed
* bcache cache_readaheads_totals metrics were removed
* ntp collector was deprecated
* supervisord collector was deprecated

#### Prometheus 2.51 (Seed MLA)

Prometheus had many improvements and some changes to the remote-write functionality that might affect you:

* Remote-write:
  * raise default samples per send to 2,000
  * respect `Retry-After` header on 5xx errors
  * error `storage.ErrTooOldSample` is now generating HTTP error 400 instead of HTTP error 500
* Scraping:
  * Do experimental timestamp alignment even if tolerance is bigger than 1% of scrape interval

#### nginx-ingress-controller 1.10

nginx v1.10 brings quite a few potentially breaking changes:

* does not support chroot image (this will be fixed on a future minor patch release)
* dropped Opentracing and zipkin modules, just Opentelemetry is supported as of this release
* dropped support for PodSecurityPolicy
* dropped support for GeoIP (legacy), only GeoIP2 is supported
* The automatically generated `NetworkPolicy` from nginx 1.9.3 is now disabled by default, refer to https://github.com/kubernetes/ingress-nginx/pull/10238 for more information.

#### Dex 2.40

The validation of username and password in the LDAP connector is much more strict now. Dex uses the [EscapeFilter](https://pkg.go.dev/gopkg.in/ldap.v1#EscapeFilter) function to check for special characters in credentials and prevent injections by denying such requests. Please ensure this is not an issue before upgrading.

Additionally, the custom `oauth` Helm chart in KKP has been deprecated and will be replaced with a new Helm chart, `dex`, which is based on the [official upstream chart](https://github.com/dexidp/helm-charts/tree/master/charts/dex). Administrators are advised to begin migrating to the new chart as soon as possible.

##### Migration Procedure

Most importantly, with this change the Kubernetes namespace where Dex is installed is also changed. Previously we installed Dex into the `oauth` namespace, but the new chart is meant to be installed into the `dex` namespace. This is the default the KKP installer will choose; if you install KKP manually you could place Dex into any namespace.

Because the namespace changes, both old and new Dex can temporarily live side-by-side in your cluster. This allows administrators to verify their configuration changes before migration over to the new Dex instances.

To begin the migration, create a new `values.yaml` section for Dex (both old and new chart use `dex` as the top-level key in the YAML file) and migrate your existing configuration as follows:

* `dex.replicas` is now `dex.replicaCount`
* `dex.env` is now `dex.envVars`
* `dex.extraVolumes` is now `dex.volumes`
* `dex.extraVolumeMounts` is now `dex.volumeMounts`
* `dex.certIssuer` has been removed, admins must manually set the necessary annotations on the
  ingress to integrate with cert-manager.
* `dex.ingress` has changed internally:
  * `class` is now `className` (the value "non-existent" is not supported anymore, use the `dex.ingress.enabled` field instead)
  * `host` and `path` are gone, instead admins will have to manually define their Ingress configuration
  * `scheme` is likewise gone and admins have to configure the `tls` section in the Ingress configuration

{{< tabs name="CCM/CSI User Roles" >}}
{{% tab name="old oauth Chart" %}}
```yaml
dex:
  replicas: 2

  env: []
  extraVolumes: []
  extraVolumeMounts: []

  ingress:
    # this option is required
    host: "kkp.example.com"
    path: "/dex"
    # this option is only used for testing and should not be
    # changed to anything unencrypted in production setups
    scheme: "https"
    # if set to "non-existent", no Ingress resource will be created
    class: "nginx"
    # Map of ingress provider specific annotations for the dex ingress. Values passed through helm tpl engine.
    # annotations:
    #   nginx.ingress.kubernetes.io/enable-opentracing: "true"
    #   nginx.ingress.kubernetes.io/enable-access-log: "true"
    #   nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
    annotations: {}

  certIssuer:
    name: letsencrypt-prod
    kind: ClusterIssuer
```
{{% /tab %}}

{{% tab name="new dex Chart" %}}
```yaml
# Tell the KKP installer to install the new dex Chart into the
# "dex" namespace, instead of the old oauth Chart.
useNewDexChart: true

dex:
  replicaCount: 2

  envVars: []
  volumes: []
  volumeMounts: []

  ingress:
    enabled: true
    className: "nginx"

    annotations:
      cert-manager.io/cluster-issuer: letsencrypt-prod

    hosts:
      # Required: host must be set; usually this is the same
      # host as is used for the KKP Dashboard, but it can be
      # any other name.
      - host: "kkp.example.com"
        paths:
          - path: /dex
            pathType: ImplementationSpecific
    tls:
      - secretName: dex-tls
        hosts:
          # Required: must include at least the host chosen
          # above.
          - "kkp.example.com"
```
{{% /tab %}}
{{< /tabs >}}

Additionally, Dex's own configuration is now more clearly separated from how Dex's Kubernetes manifests are configured. The following changes are required:

* In general, Dex's configuration is everything under `dex.config`.
* `dex.config.issuer` has to be set explicitly (the old `oauth` Chart automatically set it), usually to `https://<dex host>/dex`, e.g. `https://kkp.example.com/dex`.
* `dex.connectors` is now `dex.config.connectors`
* `dex.expiry` is now `dex.config.expiry`
* `dex.frontend` is now `dex.config.frontend`
* `dex.grpc` is now `dex.config.grpc`
* `dex.clients` is now `dex.config.staticClients`
* `dex.staticPasswords` is now `dex.config.staticPasswords` (when using static passwords, you also have to set `dex.config.enablePasswordDB` to `true`)

Finally, theming support has changed. The old `oauth` Helm chart allowed to inline certain assets, like logos, as base64-encoded blobs into the Helm values. This mechanism is not available in the new `dex` Helm chart and admins have to manually provision the desired theme. KKP's Dex chart will setup a `dex-theme-kkp` ConfigMap, which is mounted into Dex and then overlays files over the default theme that ships with Dex. To customize, create your own ConfigMap/Secret and adjust `dex.volumes`, `dex.volumeMounts` and `dex.config.frontend.theme` / `dex.config.frontend.dir` accordingly.

Once you have prepared a new `values.yaml` with the updated configuration, remember to set `useNewDexChart` to `true` and then you're ready. The next time you run the KKP installer, it will install the `dex` Chart for you, but leave the `oauth` release untouched in your cluster. Note that you cannot have two Ingress objects with the same host names and paths, so if you install the new Dex in parallel to the old one, you will have to temporarily use a different hostname (e.g. `kkp.example.com/dex` for the old one and `kkp.example.com/dex2` for the new Dex installation).

Once you have verified that the new Dex installation is up and running, you can either

* point KKP to the new Dex installation (if its new URL is meant to be permanent) by changing the `tokenIssuer` in the `KubermaticConfiguration`, or
* delete the old `oauth` release (`helm -n oauth delete oauth`) and then re-deploy the new Dex release, but with the same host+path as the old `oauth` chart used, so that no further changes are necessary in downstream components like KKP. This will incur a short downtime, while no Ingress exists for the issuer URL configured in KKP.

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

Some functionality of KKP has been deprecated or removed with KKP 2.26. You should review the full [changelog](https://github.com/kubermatic/kubermatic/blob/main/docs/changelogs/CHANGELOG-2.26.md) and adjust any automation or scripts that might be using deprecated fields or features. Below is a list of changes that might affect you:

- TBD

## Next Steps

- Try out Kubernetes 1.31, the latest Kubernetes release shipping with this version of KKP.
- Try out [KubeLB 1.0](https://www.kubermatic.com/blog/introducing-kubelb/)'s [integration into KKP]({{< ref "../../../tutorials-howtos/kubelb/" >}}).
- EE only: Configure and use [integrated user cluster backups]({{< ref "../../../architecture/supported-providers/edge/" >}}).
