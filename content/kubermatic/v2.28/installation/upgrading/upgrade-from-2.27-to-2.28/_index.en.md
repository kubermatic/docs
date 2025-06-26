+++
title = "Upgrading to KKP 2.28"
date = 2025-03-17T00:00:00+02:00
weight = 10
+++

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
- The image specification is broken down from  `node-exporter.image.registry` and `node-exporter.image.repository` to configure the node-exporter image. Where `registry` is to specify the top level registry domain (i.e. quay.io) and `repository` specifies the image namespace and image name (i.e. prometheus/node-exporter).
- The key `nodeExporter.rbacProxy` has been removed.  Use `node-exporter.kubeRBACProxy` instead to configure kube-rbac-proxy.
- The image specification is broken down to `node-exporter.kubeRBACProxy.image.registry` and `node-exporter.kubeRBACProxy.image.repository` to configure the kube-rbac-proxy image. Where `registry` is to specify the top level registry domain (i.e. quay.io) and `repository` specifies the image namespace and image name (i.e. brancz/kube-rbac-proxy).

Once the above adjustments have been made, you can do the seed-mla installation.

If you are using `kubermatic-installer` for the Seed MLA installation, then it will take care of removing the resources for the deprecated node-exporter helm-chart and installing the new upstream based helm-chart by itself.

```bash
./kubermatic-installer deploy seed-mla --helm-values values.yaml
```

If you are installing MLA using GitOps / Manual way using Helm CLI, before upgrading, you must delete the existing Helm release before doing the upgrade.

```bash
helm --namespace monitoring delete node-exporter
```

Afterwards you can install the new release from the chart using Helm CLI or using your favourite GitOps tool.

### Blackbox Exporter Upgrade (Seed MLA)

KKP 2.28 removes the custom Helm chart for Blackbox Exporter and instead now reuses the official [upstream Helm chart](https://prometheus-community.github.io/helm-charts).

#### Migration Procedure

The following actions are required for migration before performing the upgrade:

- Replace the top-level key `blackboxExporter` with `blackbox-exporter` in the `values.yaml`
- Any custom modules should be moved from `blackboxExporter.modules` to `blackbox-exporter.config.modules`.
- The image specification is broken down from `blackboxExporter.image.repository` to `blackbox-exporter.image.registry` and `blackbox-exporter.image.repository`. Where `registry` is to specify the top level registry domain (i.e. quay.io) and `repository` specifies the image namespace and image name (i.e. prometheus/blackbox-exporter)

Once the above adjustments have been made, you can do the seed-mla installation.

If you are using `kubermatic-installer` for the Seed MLA installation, then it will take care of removing the resources for the deprecated node-exporter helm-chart and installing the new upstream based helm-chart by itself.

```bash
./kubermatic-installer deploy seed-mla --helm-values values.yaml
```

If you are installing MLA using GitOps / Manual way using Helm CLI, before upgrading, you must delete the existing Helm release before doing the upgrade.

```bash
helm --namespace monitoring delete blackbox-exporter
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
- `host` --> `baseURL`
- `configReloaderImage.repository` --> `configmapReload.image.repository`

As part of KKP upgrade of monitoring components, the installer will remove the statefulset and then run the helm chart upgrade command.

Once the above adjustments have been made, you can do the seed-mla installation.

If you are using `kubermatic-installer` for the Seed MLA installation, then it will take care of removing the resources for the deprecated Alertmanager helm-chart and installing the new upstream based helm-chart by itself.

```bash
./kubermatic-installer deploy seed-mla --helm-values values.yaml
```

If you are installing MLA using GitOps / Manual way using HelmCLI, before upgrading, you must delete the existing Alertmanager STS manually before doing the upgrade.

```bash
kubectl -n monitoring delete statefulset alertmanager
```

Afterwards you can install the new release from the chart using Helm CLI or using your favourite GitOps tool.

Finally, cleanup the leftover PVC resources from old helm chart installation.
```bash
kubectl delete pvc -n monitoring -l app=alertmanager
```

### Kube State Metrics Upgrade (Seed MLA)

KKP 2.28 removes the custom Helm chart for Kube State Metrics and instead now reuses the official [upstream Helm chart](https://prometheus-community.github.io/helm-charts).

#### Migration Procedure

The following actions are required for migration before performing the upgrade:

- Replace the top-level key `kubeStateMetrics` with `kube-state-metrics` in the `values.yaml`
- The image specification is broken down from  `kube-state-metrics.image.registry` and `kube-state-metrics.image.repository` to configure the kube-state-metrics image. Where `registry` is to specify the top level registry domain (i.e. registry.k8s.io) and `repository` specifies the image namespace and image name (i.e. kube-state-metrics/kube-state-metrics).
- `resizer` has been removed.

Once the above adjustments have been made, you can do the seed-mla installation.

If you are using `kubermatic-installer` for the Seed MLA installation, then it will take care of removing the resources for the deprecated kube-state-metrics helm-chart and installing the new upstream based helm-chart by itself.

```bash
./kubermatic-installer deploy seed-mla --helm-values values.yaml
```

If you are installing MLA using GitOps / Manual way using Helm CLI, before upgrading, you must delete the existing Helm release before doing the upgrade.

```bash
helm --namespace monitoring delete kube-state-metrics
```

### Dex Migration

The custom `oauth` Helm chart in KKP was deprecated in 2.27 and has been removed in 2.28. `dex`, which is based on the [official upstream chart](https://github.com/dexidp/helm-charts/tree/master/charts/dex) has replaced it.

Administrators are advised to begin migrating to the new chart as soon as possible.

#### Migration Procedure

{{% notice warning %}}
After migrating to Dex, users may encounter login issues due to invalid tokens. To resolve, clear browser cookies for the application domain and log in again.
{{% /notice %}}

With 2.28, the KKP installer will install the new `dex` Helm chart into the `dex` namespace, instead of the old `oauth` namespace. This ensures that the old `oauth` chart remains intact and is not removed by KKP, which could result in downtimes.

This is the default namespace that the KKP installer will choose. If you install KKP manually you could place Dex into any namespace.

To begin the migration, create a new `values.yaml` section for Dex (both old and new chart use `dex` as the top-level key in the YAML file) and migrate your existing configuration as follows:

- `dex.replicas` is now `dex.replicaCount`
- `dex.env` is now `dex.envVars`
- `dex.extraVolumes` is now `dex.volumes`
- `dex.extraVolumeMounts` is now `dex.volumeMounts`
- `dex.certIssuer` has been removed, admins must manually set the necessary annotations on the
  ingress to integrate with cert-manager.
- `dex.ingress` has changed internally:
  - `class` is now `className` (the value "non-existent" is not supported anymore, use the `dex.ingress.enabled` field instead)
  - `host` and `path` are gone, instead admins will have to manually define their Ingress configuration
  - `scheme` is likewise gone and admins have to configure the `tls` section in the Ingress configuration

{{< tabs name="Dex Helm Chart values" >}}
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

- In general, Dex's configuration is everything under `dex.config`.
- `dex.config.issuer` has to be set explicitly (the old `oauth` Chart automatically set it), usually to `https://<dex host>/dex`, e.g. `https://kkp.example.com/dex`.
- `dex.connectors` is now `dex.config.connectors`
- `dex.expiry` is now `dex.config.expiry`
- `dex.frontend` is now `dex.config.frontend`
- `dex.grpc` is now `dex.config.grpc`
- `dex.clients` is now `dex.config.staticClients`
- `dex.staticPasswords` is now `dex.config.staticPasswords` (when using static passwords, you also have to set `dex.config.enablePasswordDB` to `true`)

Finally, theming support has changed. The old `oauth` Helm chart allowed to inline certain assets, like logos, as base64-encoded blobs into the Helm values. This mechanism is not available in the new `dex` Helm chart and admins have to manually provision the desired theme. KKP's Dex chart will setup a `dex-theme-kkp` ConfigMap, which is mounted into Dex and then overlays files over the default theme that ships with Dex. To customize, create your own ConfigMap/Secret and adjust `dex.volumes`, `dex.volumeMounts` and `dex.config.frontend.theme` / `dex.config.frontend.dir` accordingly.

**Note that you cannot have two Ingress objects with the same host names and paths. So if you install the new Dex in parallel to the old one, you will have to temporarily use a different hostname (e.g. `kkp.example.com/dex` for the old one and `kkp.example.com/dex2` for the new Dex installation).**

**Restarting Kubermatic API After Dex Migration**:
If you choose to delete the `oauth` chart and immediately switch to the new `dex` chart without using a different hostname, it is recommended to restart the `kubermatic-api` to ensure proper functionality. You can do this by running the following command:

```bash
kubectl rollout restart deploy kubermatic-api -n kubermatic
```

#### Important: Update OIDC Provider URL for Hostname Changes

Before configuring the UI to use the new URL, ensure that the new Dex installation is healthy by checking that the pods are running and the logs show no suspicious errors.

```bash
# To check the pods.
kubectl get pods -n dex
# To check the logs
kubectl get logs -n dex deploy/dex
```

Next, verify the OpenID configuration by running:

```bash
curl -v https://kkp.example.com/dex2/.well-known/openid-configuration
```

You should see a response similar to:

```json
{
  "issuer": "https://kkp.example.com/dex2",
  "authorization_endpoint": "https://kkp.example.com/dex2/auth",
  "token_endpoint": "https://kkp.example.com/dex2/token",
  "jwks_uri": "https://kkp.example.com/dex2/keys",
  "userinfo_endpoint": "https://kkp.example.com/dex2/userinfo",
  ...
}
```

Whether you need to temporarily use a different hostname (e.g., `kkp.example.com/dex2`) or permanently update the URL, you must configure the UI to use the new URL as the new OIDC Provider URL.

**For Operator-based installations:**
If you are installing KKP using the operator (`kubermatic configuration`) modify the configuration file to include:

```yaml
spec:
  # Ensure the URL (e.g. kkp.example.com/dex2) includes /auth path.
  ui:
    config: |
      {
        "oidc_provider_url": "https://kkp.example.com/dex2/auth"
      }
```

Once you have verified that the new Dex installation is up and running, you can either

- point KKP to the new Dex installation (if its new URL is meant to be permanent) by changing the `tokenIssuer` in the `KubermaticConfiguration`, or
- delete the old `oauth` release (`helm -n oauth delete oauth`) and then re-deploy the new Dex release, but with the same host+path as the old `oauth` chart used, so that no further changes are necessary in downstream components like KKP. This will incur a short downtime, while no Ingress exists for the issuer URL configured in KKP.

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

#### Azure Basic Load Balancer Deprecation and Upgrade Guidance

On **September 30, 2025**, Azure will deprecate the Basic Load Balancer. After this date, Basic Load Balancers will no longer be supported, and their functionality may be impacted, potentially leading to service disruptions.

This retirement affects all customers using the Azure Basic Load Balancer SKU, with one key exception: **Azure Cloud Services (extended support) deployments**.
If you have Basic Load Balancers deployed within Azure Cloud Services (extended support), these deployments will not be affected by this retirement, and no action is required for these specific instances.

For more details about this deprecation, please refer to the official Azure announcement:
[https://azure.microsoft.com/en-us/updates?id=azure-basic-load-balancer-will-be-retired-on-30-september-2025-upgrade-to-standard-load-balancer](https://azure.microsoft.com/en-us/updates?id=azure-basic-load-balancer-will-be-retired-on-30-september-2025-upgrade-to-standard-load-balancer)

The Azure team has created an upgrade guideline, including required scripts to automate the migration process.
Please refer to the official documentation for detailed upgrade instructions: [https://learn.microsoft.com/en-us/azure/load-balancer/load-balancer-basic-upgrade-guidance#upgrade-using-automated-scripts-recommended](https://learn.microsoft.com/en-us/azure/load-balancer/load-balancer-basic-upgrade-guidance#upgrade-using-automated-scripts-recommended)

## Next Steps

<!--
Mention next steps here.
-->
