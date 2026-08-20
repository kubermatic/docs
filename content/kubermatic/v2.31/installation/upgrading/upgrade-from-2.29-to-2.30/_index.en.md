+++
title = "Upgrading to KKP 2.30"
date = 2026-03-09T16:00:00+01:00
weight = 10
+++

{{% notice note %}}
Upgrading to KKP 2.30 is only supported from version 2.29. Do not attempt to upgrade from versions prior to that and apply the upgrade step by step over minor versions instead (e.g. from [2.28 to 2.29]({{< ref "../upgrade-from-2.28-to-2.29/" >}}) and then to 2.30). It is also strongly advised to be on the latest 2.29.x patch release before upgrading to 2.30.
{{% /notice %}}

This guide will walk you through upgrading Kubermatic Kubernetes Platform (KKP) to version 2.30. For the full list of changes in this release, please check out the [KKP changelog for v2.30](https://github.com/kubermatic/kubermatic/blob/main/docs/changelogs/CHANGELOG-2.30.md). Please read the full document before proceeding with the upgrade.

## Pre-Upgrade Considerations

{{% notice warning %}}
Please review [known issues]({{< ref "../../../architecture/known-issues/" >}}) before upgrading to understand if any issues might affect you.
{{% /notice %}}

KKP 2.30 adjusts the list of supported Kubernetes versions and removes support for Kubernetes 1.31. Existing user clusters need to be migrated to 1.32 or later before the KKP upgrade can begin.

### oauth2-proxy (IAP) v7.14.2

KKP 2.30 updates oauth2-proxy and includes configuration changes that can affect Seed MLA, User Cluster MLA, or other IAP deployments using custom oauth2-proxy configuration.

Review your configuration before upgrading if you use any of the following:

- `skip_auth_routes` patterns that rely on matching query parameters. These patterns must now match paths only. For detailed information, migration guidance, and security implications, see the upstream [security advisory](https://github.com/oauth2-proxy/oauth2-proxy/security/advisories/GHSA-7rh7-c77v-6434).
- Custom Alpha Config YAML for oauth2-proxy. Review it carefully before upgrading, as parsing behavior changed in preparation for the next major oauth2-proxy release. Please review the [v7.14.0 release notes](https://github.com/oauth2-proxy/oauth2-proxy/releases/tag/v7.14.0) for more details.

### User Cluster MLA Cortex and Consul Upgrade

KKP 2.30 upgrades the User Cluster MLA Cortex and Consul charts.

If you use custom `mlavalues.yaml`, review it before upgrading. In particular, if you configured a startup probe for the Cortex compactor, remove that configuration before running the `usercluster-mla` upgrade. The latest Cortex compactor version no longer includes that startup probe.

## Upgrade Procedure

Before starting the upgrade, make sure your KKP Master and Seed clusters are healthy with no failing or pending Pods. If any Pod is showing problems, investigate and fix the individual problems before applying the upgrade. This includes the control plane components for user clusters, unhealthy user clusters should not be submitted to an upgrade.

### KKP Master Upgrade

Download the latest 2.30.x release archive for the correct edition (`ce` for Community Edition, `ee` for Enterprise Edition) from [the release page](https://github.com/kubermatic/kubermatic/releases) and extract it locally on your computer. Make sure you have the `values.yaml` you used to deploy KKP 2.29 available and already adjusted for any 2.30 changes (also see [Pre-Upgrade Considerations](#pre-upgrade-considerations)), as you need to pass it to the installer. The `KubermaticConfiguration` is no longer necessary (unless you are adjusting it), as the KKP operator will use its in-cluster representation. From within the extracted directory, run the installer:

```sh
$ ./kubermatic-installer deploy kubermatic-master --helm-values path/to/values.yaml

# example output for a successful upgrade
INFO[0000] 🚀 Initializing installer…                     edition="Enterprise Edition" version=v2.30.0
INFO[0000] 🚦 Validating the provided configuration…
INFO[0000] ✅ Provided configuration is valid.
INFO[0000] 🚦 Validating existing installation…
INFO[0002]    Checking seed cluster…                     seed=kubermatic
INFO[0005] ✅ Existing installation is valid.
INFO[0005] 🛫 Deploying KKP master stack…
INFO[0005]    💾 Deploying kubermatic-fast StorageClass…
INFO[0005]    ✅ StorageClass exists, nothing to do.
INFO[0005]    📦 Deploying nginx-ingress-controller…
INFO[0008]       Deploying Helm chart…
INFO[0016]    ✅ Success.
INFO[0016]    📦 Deploying cert-manager…
INFO[0017]       Deploying Custom Resource Definitions…
INFO[0028]       Deploying Helm chart…
INFO[0035]    ✅ Success.
INFO[0035]    📦 Deploying Dex…
INFO[0037]       Updating release from 2.29.5 to 2.30.0…
INFO[0090]    ✅ Success.
INFO[0090]    📦 Deploying Kubermatic Operator…
INFO[0090]       Deploying Custom Resource Definitions…
INFO[0118]       Deploying Helm chart…
INFO[0121]       Updating release from 2.29.5 to 2.30.0…
INFO[0211]    ✅ Success.
INFO[0211]    📝 Applying Kubermatic Configuration…
INFO[0211]    ✅ Success.
INFO[0211]    📦 Deploying Telemetry…
INFO[0212]       Updating release from 2.29.5 to 2.30.0…
INFO[0219]    ✅ Success.
INFO[0219]    Deploying default Policy Template catalog
INFO[0219]    📡 Determining DNS settings…
INFO[0219]    The main Ingress is ready.
INFO[0220]         Service             : nginx-ingress-controller / nginx-ingress-controller
INFO[0220]         Ingress via hostname: <Load Balancer>.eu-central-1.elb.amazonaws.com
INFO[0220]
INFO[0220]       Please ensure your DNS settings for "<KKP FQDN>" include the following records:
INFO[0220]
INFO[0220]          <KKP FQDN>.    IN  CNAME  <Load Balancer>.eu-central-1.elb.amazonaws.com.
INFO[0220]          *.<KKP FQDN>.  IN  CNAME  <Load Balancer>.eu-central-1.elb.amazonaws.com.
INFO[0220]
INFO[0220] 🛬 Installation completed successfully. ✌
```

Upgrading seed clusters is not necessary, unless you are running the `minio` Helm chart or User Cluster MLA as distributed by KKP on them. They will be automatically upgraded by KKP components.

If you have migrated to [Gateway API]({{< ref "../../../tutorials-howtos/networking/gateway-api-migration/" >}}) and are running Seed MLA or User Cluster MLA with IAP, you must rerun `seed-mla` and `usercluster-mla` with Gateway API settings to migrate their Ingress resources to HTTPRoute. The `kubermatic-master` migration only covers the main KKP and Dex entrypoints. Additionally:

- If you use cert-manager, enable Gateway API support in your cert-manager configuration by setting `enableGatewayAPI: true`.
- Add the `HTTPRouteGatewaySync: true` feature gate to your `KubermaticConfiguration` so the shared Gateway receives the additional HTTPS listeners needed for MLA/IAP hostnames.
- If you use `external-dns` with `Service` objects as a source, move the hostname annotations from the nginx `LoadBalancer` service to the Envoy `LoadBalancer` service, or update DNS manually.
- `nginx-ingress-controller` is not uninstalled automatically during the migration. Only the old KKP and Dex `Ingress` resources are removed during cleanup. Make sure to clean up remaining Seed MLA and User Cluster MLA `Ingress` resources after verifying that the new HTTPRoute resources are working correctly.

You can follow the upgrade process by either supervising the Pods on master and seed clusters (by simply checking `kubectl get pods -n kubermatic` frequently) or checking status information for the `Seed` objects. A possible command to extract the current status by seed would be:

```bash
$ kubectl get seeds -A -o jsonpath="{range .items[*]}{.metadata.name} - {.status}{'\n'}{end}"

kubermatic - {"clusters":0,"conditions":{"ClusterInitialized":{"lastHeartbeatTime":"2026-03-09T16:00:00Z","message":"All KKP CRDs have been installed successfully.","reason":"CRDsUpdated","status":"True"},"KubeconfigValid":{"lastHeartbeatTime":"2026-03-09T16:00:00Z","reason":"KubeconfigValid","status":"True"},"ResourcesReconciled":{"lastHeartbeatTime":"2026-03-09T16:00:00Z","reason":"ReconcilingSuccess","status":"True"}},"phase":"Healthy","versions":{"cluster":"v1.35.2","kubermatic":"v2.30.0"}}
```

Of particular interest to the upgrade process is if the `ResourcesReconciled` condition succeeded and if the `versions.kubermatic` field is showing the target KKP version. If this is not the case yet, the upgrade is still in flight. If the upgrade is stuck, try `kubectl -n kubermatic describe seed <seed name>` to see what exactly is keeping the KKP Operator from updating the Seed cluster.

## Post-Upgrade Considerations

### Deprecations and Removals

Some functionality of KKP has been deprecated or removed with KKP 2.30. You should review the full [changelog](https://github.com/kubermatic/kubermatic/blob/main/docs/changelogs/CHANGELOG-2.30.md) and adjust any automation or scripts that might be using deprecated fields or features. Below is a list of changes that might affect you:

- The cluster-autoscaler addon has been removed. If you were using the addon, you must migrate to the cluster-autoscaler application from the default catalog. If you are already using the application, reinstall it after upgrading to KKP 2.30 so that the `ApplicationInstallation` is recreated with the updated default values ([#15311](https://github.com/kubermatic/kubermatic/pull/15311), [#15152](https://github.com/kubermatic/kubermatic/pull/15152)).
- The Anexia cloud provider is now deprecated. A warning is shown in the dashboard to inform users ([#7767](https://github.com/kubermatic/dashboard/pull/7767)).
- The Kubernetes Dashboard feature is deprecated, as the upstream project is no longer actively maintained ([#7810](https://github.com/kubermatic/dashboard/pull/7810)).

## Next Steps

- Try out Kubernetes 1.35, the latest Kubernetes release shipping with this version of KKP.
- Try out the new [Gateway API]({{< ref "../../../tutorials-howtos/networking/gateway-api-migration/" >}}) support as an alternative to NGINX Ingress for external traffic routing.
