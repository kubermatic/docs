+++
title = "Upgrading to KKP 2.27"
date = 2025-02-20T00:00:00+02:00
weight = 10
+++

{{% notice note %}}
Upgrading to KKP 2.27 is only supported from version 2.26. Do not attempt to upgrade from versions prior to that and apply the upgrade step by step over minor versions instead (e.g. from [2.25 to 2.26]({{< ref "../upgrade-from-2.25-to-2.26/" >}}) and then to 2.27). It is also strongly advised to be on the latest 2.26.x patch release before upgrading to 2.27.
{{% /notice %}}

This guide will walk you through upgrading Kubermatic Kubernetes Platform (KKP) to version 2.27. For the full list of changes in this release, please check out the [KKP changelog for v2.27](https://github.com/kubermatic/kubermatic/blob/main/docs/changelogs/CHANGELOG-2.27.md). Please read the full document before proceeding with the upgrade.

## Pre-Upgrade Considerations

{{% notice warning %}}
Please review [known issues]({{< ref "../../../architecture/known-issues/" >}}) before upgrading to understand if any issues might affect you.
{{% /notice %}}

KKP 2.27 adjusts the list of supported Kubernetes versions and removes support for Kubernetes 1.28. Existing user clusters need to be migrated to 1.29 or later before the KKP upgrade can begin.

### Removal of CentOS Support

CentOS has reached its End of Life (EOL), and as a result, KKP 2.27 has removed support for CentOS operating systems. Ensure that all user clusters are migrated to a supported operating system before proceeding with the upgrade.

### VSphere Credentials Handling

In KKP 2.27, VSphere credentials are now handled properly. For existing user clusters, this change affects the credentials in `machine-controller` and `Operating System Manager (OSM)`. Specifically, the credentials will switch to using `infraManagementUser` and `infraManagementPassword` instead of the previous `username` and `password` when specified. Ensure that your configurations are updated accordingly to prevent any disruptions.

### OpenStack Floating IP Pool Fix

A regression in KKP v2.26.0 caused the floatingIPPool field in OpenStack clusters to be overridden with the default external network.

If your OpenStack clusters use a floating IP pool other than the default, you may need to manually update Cluster objects after upgrading to v2.27.

* Action Required:
  *  After the upgrade, check your OpenStack clusters and manually reset the correct floating IP pool if needed.
  *  Example command to check the floating IP pool
  ```sh
  kubectl get clusters -o jsonpath="{.items[*].spec.cloud.openstack.floatingIPPool}"
  ```
  * If incorrect, manually edit the Cluster object:
  ```sh
  kubectl edit cluster <cluster-name> 
  ```
  
### Velero Configuration Changes

By default, Velero backups and snapshots are turned off. If you were using Velero for etcd backups and/or volume backups, you must explicitly enable them in your values.yaml file.

```yaml
velero:
  backupsEnabled: true
  snapshotsEnabled: true
```

Additionally, the node-agent daemonset is now disabled by default. If you were using volume backups (velero.snapshotsEnabled: true), you also need to enable it. This ensures volume backups function as expected.

```yaml
velero:
  deployNodeAgent: true
```

### K8sgpt-operator

K8sgpt-operator has been introduced to replace the now deprecated `k8sgpt(non-operator)` application. The k8sgpt application will be removed in the future releases.

### Environment Variable Change for Equinix Metal

KKP now uses `METAL_` environment variables instead of `PACKET_` for machine-controller and KubeOne. Ensure any configurations referencing PACKET_ variables are updated accordingly.

In general this should not require any actions on the administrator part.

### Dex v2.42

The custom `oauth` Helm chart in KKP has been deprecated and will be replaced with a new Helm chart, `dex`, which is based on the [official upstream chart](https://github.com/dexidp/helm-charts/tree/master/charts/dex).

Administrators are advised to begin migrating to the new chart as soon as possible.

#### Migration Procedure

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

Finally, theming support has changed. The old `oauth` Helm chart allowed to inline certain assets, like logos, as base64-encoded blobs into the Helm values. This mechanism is not available in the new `dex` Helm chart and admins have to manually provision the desired theme. KKP's Dex chart will setup a `dex-theme-kkp` Secret, which is mounted into Dex and then overlays files over the default theme that ships with Dex. To customize, create your own Secret and adjust `dex.volumes`, `dex.volumeMounts` and `dex.config.frontend.theme` / `dex.config.frontend.dir` accordingly.

Once you have prepared a new `values.yaml` with the updated configuration, remember to set `useNewDexChart` to `true` and then you're ready. The next time you run the KKP installer, it will install the `dex` Chart for you, but leave the `oauth` release untouched in your cluster. Note that you cannot have two Ingress objects with the same host names and paths, so if you install the new Dex in parallel to the old one, you will have to temporarily use a different hostname (e.g. `kkp.example.com/dex` for the old one and `kkp.example.com/dex2` for the new Dex installation).

{{% notice warning %}}
#### Important: Update OIDC Provider URL for Hostname Changes
Whether you need to temporarily use a different hostname (e.g., `kkp.example.com/dex2`) or permanently update the URL, you must configure the UI to use the new URL as the new OIDC Provider URL.

**For Operator-based installations:**
If you are installing KKP using the operator (`kubermatic configuration`) modify the configuration file to include:

```yaml
spec:
  # Ensure the URL (e.g. kkp.example.com/dex2) includes /auth path.
  config: |
    {
      "oidc_provider_url": "https://kkp.example.com/dex2/auth" 
    }
```

**For Manual installations:**
For manual installations, simply update the `config.json` file with the new OIDC provider URL:

```json
{
  "oidc_provider_url": "https://kkp.example.com/dex2/auth "
}
```
{{% /notice %}}

Once you have verified that the new Dex installation is up and running, you can either

* point KKP to the new Dex installation (if its new URL is meant to be permanent) by changing the `tokenIssuer` in the `KubermaticConfiguration`, or
* delete the old `oauth` release (`helm -n oauth delete oauth`) and then re-deploy the new Dex release, but with the same host+path as the old `oauth` chart used, so that no further changes are necessary in downstream components like KKP. This will incur a short downtime, while no Ingress exists for the issuer URL configured in KKP.

### API Changes

* New Prometheus Overrides
  * Added `spec.componentsOverride.prometheus` to allow overriding Prometheus replicas and tolerations.

* Container Image Tagging 
  * Tagged KKP releases will no longer tag KKP images twice (with the Git tag and the Git hash), but only once with the Git tag. This ensures that existing hash-based container images do not suddenly change when a Git tag is set and the release job is run. Users of tagged KKP releases are not affected by this change.

## Upgrade Procedure

Before starting the upgrade, make sure your KKP Master and Seed clusters are healthy with no failing or pending Pods. If any Pod is showing problems, investigate and fix the individual problems before applying the upgrade. This includes the control plane components for user clusters, unhealthy user clusters should not be submitted to an upgrade.

### KKP Master Upgrade

Download the latest 2.27.x release archive for the correct edition (`ce` for Community Edition, `ee` for Enterprise Edition) from [the release page](https://github.com/kubermatic/kubermatic/releases) and extract it locally on your computer. Make sure you have the `values.yaml` you used to deploy KKP 2.27 available and already adjusted for any 2.27 changes (also see [Pre-Upgrade Considerations](#pre-upgrade-considerations)), as you need to pass it to the installer. The `KubermaticConfiguration` is no longer necessary (unless you are adjusting it), as the KKP operator will use its in-cluster representation. From within the extracted directory, run the installer:

```sh
$ ./kubermatic-installer deploy kubermatic-master --helm-values path/to/values.yaml

# example output for a successful upgrade
INFO[0000] 🚀 Initializing installer…                     edition="Enterprise Edition" version=v2.27.0
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
INFO[0002]       Updating release from 2.26.4 to 2.27.0…
INFO[0005]    ✅ Success.
INFO[0005]    📦 Deploying cert-manager…
INFO[0005]       Deploying Custom Resource Definitions…
INFO[0006]       Deploying Helm chart…
INFO[0007]       Updating release from 2.26.4 to 2.27.0…
INFO[0026]    ✅ Success.
INFO[0026]    📦 Deploying Dex…
INFO[0027]       Updating release from 2.26.4 to 2.27.0…
INFO[0030]    ✅ Success.
INFO[0030]    📦 Deploying Kubermatic Operator…
INFO[0030]       Deploying Custom Resource Definitions…
INFO[0034]       Deploying Helm chart…
INFO[0035]       Updating release from 2.26.4 to 2.27.0…
INFO[0064]    ✅ Success.
INFO[0064]    📦 Deploying Telemetry
INFO[0065]       Updating release from 2.26.4 to 2.27.0…
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
kubermatic - {"clusters":5,"conditions":{"ClusterInitialized":{"lastHeartbeatTime":"2025-02-20T10:53:34Z","message":"All KKP CRDs have been installed successfully.","reason":"CRDsUpdated","status":"True"},"KubeconfigValid":{"lastHeartbeatTime":"2025-02-20T16:50:09Z","reason":"KubeconfigValid","status":"True"},"ResourcesReconciled":{"lastHeartbeatTime":"2025-02-20T16:50:14Z","reason":"ReconcilingSuccess","status":"True"}},"phase":"Healthy","versions":{"cluster":"v1.29.13","kubermatic":"v2.27.0"}}
```

Of particular interest to the upgrade process is if the `ResourcesReconciled` condition succeeded and if the `versions.kubermatic` field is showing the target KKP version. If this is not the case yet, the upgrade is still in flight. If the upgrade is stuck, try `kubectl -n kubermatic describe seed <seed name>` to see what exactly is keeping the KKP Operator from updating the Seed cluster.

## Post-Upgrade Considerations

### Deprecations and Removals

Some functionality of KKP has been deprecated or removed with KKP 2.27. You should review the full [changelog](https://github.com/kubermatic/kubermatic/blob/main/docs/changelogs/CHANGELOG-2.27.md) and adjust any automation or scripts that might be using deprecated fields or features. Below is a list of changes that might affect you:

* The custom `oauth` Helm chart in KKP has been deprecated and will be replaced with a new Helm chart, `dex`, which is based on the [official upstream chart](https://github.com/dexidp/helm-charts/tree/master/charts/dex), in KKP 2.27.

* Canal v3.19 and v3.20 addons have been removed.

* kubermatic-installer `--docker-binary` flag has been removed from the kubermatic-installer `mirror-images` subcommand.

* The `K8sgpt` non-operator application has been deprecated and replaced by the `K8sgpt-operator`. The old application will be removed in future releases.

## Next Steps

- Try out Kubernetes 1.32, the latest Kubernetes release shipping with this version of KKP.
- Try out the new [admin announcement feature]({{< ref "../../../tutorials-howtos/administration/admin-panel/admin-announcements/" >}}) to seamlessly communicate across the platform.
- Try out the new [AI Kit]({{< ref "../../../architecture/concept/kkp-concepts/applications/default-applications-catalog/aikit/" >}}) in KKP, Deploying AI, GenAI, and LLM Workloads at Scale.
- EE only: Try out enhanced cluster backup feature, restore to another kkp cluster.
