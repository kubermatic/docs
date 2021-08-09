+++
linkTitle = "Admin Guide"
title = "Admin Guide of the User Cluster MLA Stack"
date = 2020-02-14T12:07:15+02:00
weight = 10
enableToc = true
+++

This page contains an administrator guide for the [User Cluster MLA Stack]({{< relref "../../../../architecture/monitoring_logging_alerting/user_cluster/" >}}).

## Installation

The User Cluster MLA stack components have to be manually installed into every KKP Seed cluster.

### Requirements

At the minimal scale (to process MLA data from several user clusters), the stack requires the following resources in the seed cluster:

- 2 vCPUs
- 14 GB of RAM

Apart from that,  it will claim the following storage from the `kubermatic-fast` storage class:

- 50 Gi volume for MinIO (object store for logs, metrics, and alertmanager configurations, etc.)
- 10 Gi volume for Grafana
- 10 Gi volume for each Ingester instance (3 Loki Ingesters + 3 Cortex Ingesters by default)
- 10 Gi volume for Loki Querier
- 4 x 2 Gi volume for other internal processing services (compactors, store gateways of Cortex and Loki)

### Installing MLA Stack in a Seed Cluster

#### Create MLA secrets

The [kubermatic/mla Github repository](https://github.com/kubermatic/mla) contains all the Helm charts of the User Cluster MLA stack and scripts to install them. Please make sure to clone it, so that we can deploy the MLA stack into a KKP Seed cluster.

Before deploying the MLA stack into the KKP Seed cluster, let’s create two Kubernetes Secrets that contain credentials for MinIO and Grafana, and which will be used by the MLA stack and KKP controllers. The MLA repo contains a Helm chart that will auto-generate the necessary Secrets - for creating them, simply run:

```bash
helm --namespace mla upgrade --atomic --create-namespace --install mla-secrets charts/mla-secrets --values config/mla-secrets/values.yaml
```

#### Deploy Seed Cluster Components

After the secrets are created, the MLA stack can be deployed by using the helper script:

```bash
./hack/deploy-seed.sh
```

This will deploy all MLA stack components with the default settings, which may be sufficient for smaller scale setups (several user clusters). If any customization is needed for any of the components, the steps in the helper script can be manually reproduced with tweaked Helm values. See the “Setup Customization” section for more information.

#### Expose Grafana & Alertmanager UI

After deploying MLA components into a KKP Seed cluster, Grafana and Alertmanager UI are exposed only via ClusterIP services by default. To expose them to users outside of the Seed cluster with proper authentication in place, we will use the [IAP Helm chart](https://github.com/kubermatic/kubermatic/tree/master/charts/iap) from the Kubermatic repository.

Let's start with preparing the values.yaml for the IAP Helm Chart. A starting point can be found in the `config/iap/values.example.yaml` file of the MLA repository:

- Modify the base domain under which your KKP installation is available (`kkp.example.com` in `iap.oidc_issuer_url` and `iap.deployments.grafana.ingress.host`).
- Set `iap.deployments.grafana.client_secret` + `iap.deployments.grafana.encryption_key` and `iap.deployments.alertmanager.client_secret` + `iap.deployments.alertmanager.encryption_key` to the newly generated key values (they can be generated e.g. with cat `/dev/urandom | tr -dc A-Za-z0-9 | head -c32`).
- Configure how the users should be authenticated in `iap.deployments.grafana.config` and `iap.deployments.alertmanager.config` (e.g. modify `YOUR_GITHUB_ORG` and `YOUR_GITHUB_TEAM` placeholders). Please check the [OAuth Provider Configuration](https://oauth2-proxy.github.io/oauth2-proxy/docs/configuration/oauth_provider/) for more details.

It is also necessary to set up your infrastructure accordingly:

- Configure your DNS with the DNS entry for the domain name that you used in `iap.deployments.grafana.ingress.host` and `iap.deployments.alertmanager.ingress.host` so that it points to the ingress-controller service of KKP.
- Configure the Dex in KKP with the proper configuration for Grafana and Alertmanager IAP, e.g. using the following snippet that can be placed into the KKP values.yaml. Make sure to modify the `RedirectURIs` with your domain name used in `iap.deployments.grafana.ingress.host` and `iap.deployments.alertmanager.ingress.host` and secret with your `iap.deployments.grafana.client_secret` and `iap.deployments.alertmanager.client_secret`:

```yaml
dex:
  clients:
  - RedirectURIs:
    - https://grafana.mla.kkp.example.com/oauth/callback
    id: mla-grafana
    name: mla-grafana
    secret: YOUR_CLIENT_SECRET
  - RedirectURIs:
    - https://alertmanager.mla.kkp.example.com/oauth/callback
    id: mla-alertmanager
    name: mla-alertmanager
    secret: YOUR_CLIENT_SECRET
```

At this point, we can install the IAP Helm chart into the mla namespace, e.g. as follows:

```bash
helm --namespace mla upgrade --atomic --create-namespace --install iap charts/iap --values config/iap/values.yaml
```

For more information about how to secure your services in KKP using IAP and Dex, please check [Securing System Services Documentation]({{< ref "../../../kkp_security/securing_system_services/">}}).

## Setup

Once the User Cluster MLA stack is installed in all necessary seed clusters, it needs to be configured as described in this section.

### Enabling MLA Feature in KKP Configuration

Since the User Cluster MLA feature is in alpha stage, it has to be explicitly enabled via a feature gate in the `KubermaticConfiguration`, e.g.:

```yaml
apiVersion: operator.kubermatic.io/v1alpha1
kind: KubermaticConfiguration
metadata:
  name: kubermatic
  namespace: kubermatic
spec:
  featureGates:
    UserClusterMLA:
      enabled: true
```

### Enabling MLA Stack in a Seed

Since the MLA stack has to be manually installed into every KKP Seed Cluster, it is necessary to explicitly enable it on the Seed Cluster level after it is installed. This can be done via `mla.user_cluster_mla_enabled` option of the `Seed` Custom Resource / API object, e.g.:

```yaml
apiVersion: kubermatic.k8s.io/v1
kind: Seed
metadata:
  name: europe-west3-c
  namespace: kubermatic
spec:
  mla:
    user_cluster_mla_enabled: true
```

### Admin Panel Configuration

There are several options in the KKP “Admin Panel” which are related to user cluster MLA, as shown on the picture below:

![MLA Admin Panel](/img/kubermatic/master/monitoring/user_cluster/admin_panel.png)

**User Cluster Logging:**

- **Enabled by Default**: If this checkbox is selected, User Cluster Logging will be enabled by default in the cluster creation page.
- **Enforce**: If this is selected, User Cluster Logging will be enabled by default, and users will not be able to change it.

**User Cluster Monitoring:**

- **Enabled by Default**: If this checkbox is selected, User Cluster Monitoring will be enabled by default in the cluster creation page.
- **Enforce**: If this is selected, User Cluster Monitoring will be enabled by default, and users will not be able to change it.

**User Cluster Alertmanager Domain:**

- This domain will be used to expose Alertmanager UI to users. It has to be the same domain that has been set up during the MLA stack installation in the Seed cluster. A link to Alertmanager UI will be visible in the tab “User Cluster Alertmanager”  in the cluster details view.

## Operation

### Setup Customization

The default settings of the MLA stack components are sufficient for smaller scale setups (several user clusters). Whenever a larger scale is needed these settings should be adapted accordingly. 

User Cluster MLA stack components setting can be adapted by modifying (using your own) their `value.yaml` files. Available Helm chart options can be reviewed in the MLA repo:

- [Cortex values](https://github.com/kubermatic/mla/tree/main/charts/cortex#values)
- [Loki values](https://github.com/kubermatic/mla/tree/main/charts/loki-distributed#values)
- [Grafana values](https://github.com/kubermatic/mla/tree/main/charts/grafana#configuration)

For larger scales, you will may start with tweaking the following:

- Size of the object store used to persist metrics data and logs (minio `values.yaml` - `persistence.size`) - default: 50Gi
- Storage & Data Retention Settings (see the next chapter)
- Cortex Ingester replicas (cortex values.yaml - `ingester.replicas`) - default 3
- Cortex Ingester volume sizes (cortex values.yaml - `ingester.persistentVolume.size`) - default 10Gi
- Loki Ingester replicas (loki values.yaml - `ingester.replicas`) - default 3
- Loki Ingester volume sizes (loki values.yaml - `ingester.persistentVolume.size`) - default 10Gi

For more details about configuring these components in an HA manner, you can review the following links:

**Cortex:**

- [Cortex Capacity Planning](https://cortexmetrics.io/docs/guides/capacity-planning/)
- [Cortex Block Storage Production Tips](https://cortexmetrics.io/docs/blocks-storage/production-tips/)

**Loki:**

- [Configuring Loki](https://grafana.com/docs/loki/latest/configuration/)
- [The essential config settings](https://grafana.com/blog/2021/02/16/the-essential-config-settings-you-should-use-so-you-wont-drop-logs-in-loki/)

**Grafana:**

- [Set up Grafana for high availability](https://grafana.com/docs/grafana/latest/administration/set-up-for-high-availability/)

### Storage & Data Retention Settings

By default, the MLA stack is configured to hold the logs and metrics in the object store for 7 days. This can be overridden for logs and metrics separately:

**For the metrics:**

- In the [cortex Helm chart values.yaml](https://github.com/kubermatic/mla/blob/main/config/cortex/values.yaml#L208), set `config.limits.max_query_lookback` to the desired value (default: `168h` = 7 days).
- In the [minio-lifecycle-mgr Helm chart values.yaml](https://github.com/kubermatic/mla/blob/main/config/minio-lifecycle-mgr/values.yaml#L18), set `lifecycleMgr.buckets[name=cortex].expirationDays` to the value used in the cortex Helm chart + 1 day (default: `8d`).

**For the logs:**

- In the [loki Helm chart values.yaml](https://github.com/kubermatic/mla/blob/main/config/loki/values.yaml#L52), set `loki.config.chunk_store_config.max_look_back_period` to the desired value (default: `168h` = 7 days).
- In the [minio-lifecycle-mgr Helm chart values.yaml](https://github.com/kubermatic/mla/blob/main/config/minio-lifecycle-mgr/values.yaml#L20), set `lifecycleMgr.buckets[name=loki].expirationDays` to the value used in the loki Helm chart + 1 day (default: `8d`).

### Manage Grafana Dashboards

In User Cluster MLA Grafana, we provide some predefined Grafana Dashboards that will be shared across all user clusters. It is also possible to add more Grafana Dashboards, and make them available for all user clusters.

There are three ways for managing Grafana Dashboards:

- Modify the pre-created configmap `grafana-dashboards-default` in the `mla` namespace. This configmap contains the Grafana Dashboards that we predefined, you can add and remove Dashboards by modifying this configmap.
- Create configmap with `grafana-dashboards` as the name prefix. You can add multiple such configmaps with your Dashboards json data. For example:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: grafana-dashboards-example
  namespace: mla
data:
  example-dashboard.json: <your-dashboard-json-data>
```

- Add dashboards to the User Cluster MLA Grafana Helm chart values. You can add more Dashboards directly in the [`dashboards` in the value.yaml file](https://github.com/kubermatic/mla/blob/main/config/grafana/values.yaml#L41).

After the new Dashboards are applied to the Seed Cluster, they will be available across all Grafana Organizations, and they can be found in the Grafana UI under Dashboards -> Manage.

## Debugging

This chapter describes some potential problems that you may face in a KKP installation and the steps you can take to resolve then.

**Prometheus / Loki datasource for an user cluster is not available in the Grafana UI:**

- Make sure you are switched to the proper Grafana Organization (see the “Switch between Grafana Organizations” section of this documentation)
- Make sure that user cluster Monitoring / Logging is enabled for the user cluster (In KKP UI, you should see green checkboxes on the Cluster Page):

![MLA UI - Cluster View](/img/kubermatic/master/monitoring/user_cluster/ui_cluster_view.png)

**Metrics / Logs are not available in Grafana UI for some user cluster:**

- Make sure that User Cluster Monitoring / Logging is enabled for the user cluster (In KKP UI, you should see green checkboxes on the Cluster Page):

![MLA UI - Cluster View](/img/kubermatic/master/monitoring/user_cluster/ui_cluster_view.png)

- Check that Prometheus / Promtail was deployed an is running in the user cluster:

```bash
kubectl get pods -n mla-system
NAME                          READY   STATUS    RESTARTS   AGE
prometheus-68f7485456-jj7v6   1/1     Running   0          11m
promtail-cm4qd                1/1     Running   0          6m11s
```

- Check the logs of Prometheus / Promtail pods
- Check that the MLA Gateway pod is running in the user cluster namespace in the Seed cluster:

```bash
kubectl get pods -n cluster-cxfmstjqkw | grep mla-gateway
mla-gateway-6dd8c68d67-knmq7                  1/1     Running   0          22m
```

- Check the logs of the MLA Gateway pods
- Check the status of the pods in the `mla` namespace in the seed cluster:

```bash
kubectl get pods -n mla
```

- If there are any pods crashing, review their logs for the root cause

## Uninstallation

{{% notice warning %}}

Before proceeding with any of the following steps, make sure that you backup all data that you may still need - metrics data / logs in the object store, alertmanager / rules configuration, Grafana dashboards.

{{% /notice %}}

In order to uninstall the User Cluster MLA stack from a seed cluster (and all user clusters serviced by that seed cluster), follow the 3 steps in this order:

- Disable the User Cluster MLA feature in Seed configuration
- Remove the User Cluster MLA components from Seed
- Remove the User Cluster MLA data from Seed

### Disabling the User Cluster MLA in Seed Configuration

In order to disable the User Cluster MLA feature for a Seed Cluster, set the `mla.user_cluster_mla_enabled` option of the `Seed` Custom Resource / API object to `false`, e.g.:

```yaml
apiVersion: kubermatic.k8s.io/v1
kind: Seed
metadata:
  name: europe-west3-c
  namespace: kubermatic
spec:
  mla:
    user_cluster_mla_enabled: false
```

### Removing the User Cluster MLA Components

In order to uninstall the user cluster MLA stack components from a Seed cluster, first disable it in the `Seed` Custom Resource / API object as described in the previous section. After that, you can safely remove the resources in the `mla` namespace of the Seed Cluster.

You can do that on per-component basis using Helm - see the list of the helm Charts in the `mla` namespace:

```bash
 helm ls -n mla
```

E.g. to uninstall Cortex, run:

```bash
helm delete cortex -n mla
```
