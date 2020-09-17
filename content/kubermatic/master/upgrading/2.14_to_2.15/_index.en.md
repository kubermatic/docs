+++
title = "Upgrading from 2.14 to 2.15"
date = 2020-06-09T11:09:15+02:00
weight = 90

+++

## Helm 3 Support

KKP now supports Helm 3. Previous versions required some manual intervention to get all charts
installed. With the updated CRD handling (see below), we made the switch to recommending Helm 3
for new installations.

## [EE] Deprecation of `kubermatic` Helm Chart

After the Kubermatic Operator has been introduced as a beta in version 2.14, it is now the recommended way of
installing and managing KKP. This means that the `kubermatic` Helm chart is considered deprecated as of
version 2.15 and all users are encouraged to prepare the migration to the Operator.

The Kubermatic Operator does not support previously deprecated features like the `datacenters.yaml`
or the full feature set of the `kubermatic` chart's customization options. Instead, datacenters
have to be converted to `Seed` resources, while the chart configuration must be converted to a
`KubermaticConfiguration`. The Kubermatic Installer offers commands to perform these conversions
automatically.

### Migration Path

This section outlines a migration plan for the Kubermatic Operator, starting from having KKP installed
using the old `kubermatic` Helm chart using Helm 2.x.

{{% notice warning %}}
Before performing the migration, make sure to back up all Kubermatic resources!
{{% /notice %}}

Make sure that you also have recent etcd snapshots for all user clusters.

#### Overview

A parallel installation of both the old and the new `kubermatic-operator` chart is not possible,
regardless of the namespaces. Only one KKP setup can be live in a given cluster at any time.

Because of this, it is recommended to perform an uninstall of the old chart followed by installing
the new Operator chart. This will lead to some downtime, both in the dashboard as well as all
cluster reconciliation logic.

{{% notice warning %}}
**It is of critical importance that the Kubermatic CRDs are not deleted during the migration.**
This would in turn delete all affected resources, like clusters, users etc.
KKP never used Helm to manage its CRDs (Helm was only previously used for the cert-manager and
Velero CRDs), so it is safe to uninstall the chart.
{{% /notice %}}

Compared to the old installation method, were the `kubermatic` chart was installed both on the
master and all seed clusters (toggling the `isMaster` flag in the chart accordingly), with the
operator seeds are now managed automatically. The operator is only ever installed once in the
master cluster and manages the seed clusters from there. Still, care must be taken to not
accidentally have both Helm chart and operator-managed resources in seed clusters. For this
reasons, the reconciliation of seed clusters (installing the seed-controller-manager Deployment,
the Seed validation webhook etc.) can be disabled by setting the
`operator.kubermatic.io/skip-reconciling` annotation on Seed resources.

All in the all, a migration plan can look like this:

1. Perform a backup or all Kubermatic resources.
1. Ensure etcd snapshots for all user clusters are in place.
1. Convert Helm values / `datacenters.yaml` to KubermaticConfiguration, Seeds, Presets etc.
   using the Kubermatic Installer. Make sure to create Seeds that are *paused* (have the
   `operator.kubermatic.io/skip-reconciling` annotation set; this can be achieved by running
   the installer with the `--pause-seeds` flag).
1. Uninstall `kubermatic` Helm chart from the master cluster. **Leave the CRDs in place.**
1. Install the `kubermatic-operator` Helm chart using Helm 3.
1. Wait for the master cluster to become ready.
1. Start migrating Seeds:
   1. Pick a Seed
   1. Uninstall `kubermatic` Helm chart from the seed cluster.
   1. Update the `Seed` resource in the master and remove the `operator.kubermatic.io/skip-reconciling` annotation.
   1. Wait for the operator to reconcile the seed cluster.
   1. Continue with the next seed cluster.

{{% notice info %}}
This poses a good opportunity to also make the switch to Helm 3. All other charts for the KKP
stack (cert-manager, nginx-ingress-controller, etc.) can be migrated in-place from Helm 2 to 3.
{{% /notice %}}

The following sections describe the steps above in greater detail.

#### Backups

Backing up Kubermatic resources can be done in many ways, for example simply by using `kubectl`
and writing the YAML into local files:

```bash
kubectl get addons -A -o yaml > addons.yaml
kubectl get addonconfigs -A -o yaml > addonconfigs.yaml
kubectl get admissionplugins -A -o yaml > admissionplugins.yaml
kubectl get clusters -A -o yaml > clusters.yaml
kubectl get kubermaticsettings -A -o yaml > kubermaticsettings.yaml
kubectl get presets -A -o yaml > presets.yaml
kubectl get projects -A -o yaml > projects.yaml
kubectl get seeds -A -o yaml > seeds.yaml
kubectl get users -A -o yaml > users.yaml
kubectl get userprojectbindings -A -o yaml > userprojectbindings.yaml
kubectl get usersshkeies -A -o yaml > usersshkeies.yaml
kubectl get verticalpodautoscalers -A -o yaml > verticalpodautoscalers.yaml
```

Administrators should also check each seed cluster's Minio to verify that etcd snapshots for
all user clusters are in place.

#### Convert `datacenters.yaml` / Helm Values

The Kubermatic Installer provides commands to automatically convert the old configuration files
into their new formats.

The `convert-helm-values` command takes a Helm values.yaml file and outputs (to stdout) a number
of YAML files, representing the generated KubermaticConfiguration, Seeds, Secrets, Presets etc.
Using this command is recommended, as it does all conversions in a single step, because the old
`values.yaml` contained all information in some form or another. Make sure to add `--pause-seeds`
to automatically add the `operator.kubermatic.io/skip-reconciling` annotation.

```bash
./kubermatic-installer convert-helm-values --pause-seeds myvalues.yaml
# apiVersion: operator.kubermatic.io/v1alpha1
# kind: KubermaticConfiguration
# metadata:
#   name: kubermatic
#   namespace: kubermatic
# ...
#
# ---
# apiVersion: kubermatic.k8s.io/v1
# kind: Seed
# ...
#
# ---
# ...
```

In case migrating the Helm values.yaml is not feasable, the installer also offers a dedicated
command to convert just the `datacenters.yaml` into Seeds/Secrets. By default, the `datacenters.yaml`
did not contain kubeconfigs, so you have to manually provide a kubeconfig with contexts for every
seed cluster in the `datacenters.yaml` (the installer will error out if contexts are missing).
If you do not provide a kubeconfig, Seeds will still be converted, but you are responsible
yourself to provide the appropriate kubeconfig Secrets and to reference them in the Seeds.

```bash
./kubermatic-installer convert-datacenters --pause-seeds --kubeconfig kubeconfig-with-all-seeds datacenters.yaml
# apiVersion: kubermatic.k8s.io/v1
# kind: Seed
# ...
#
# ---
# ...
```

Refer to the [KubermaticConfiguration]({{< ref "../../concepts/kubermaticconfiguration" >}}) and
[Seed]({{< ref "../../concepts/seeds" >}}) documentation for more information.

Once the conversion is completed, carefully check the new configuration files for mistakes. Do
note that the installer generally does not output default values, so if you configured for example
2 Apiserver replicas and this is the default for Kubermatic anyway, the generated `KubermaticConfiguration`
will skip the value alltogether, relying on the defaulting.

It is now recommended to setup Kubermatic in a test environment, using the newly converted files.

#### Upgrading the Master Cluster

It's now time to change the Helm charts. Begin by uninstalling the `kubermatic` chart. This will make
the dashboard unavailable and begin the downtime.

```bash
# This is written for Helm 2.x
helm --tiller-namespace kubermatic-installer delete --purge kubermatic
```

Once the Helm chart is gone, it's time to perform a clean installation of the new Kubermatic Operator.
The first step for that is to add new Kubermatic CRDs:

```bash
kubectl apply -f charts/kubematic/crd/
```

To prevent Kubermatic from rejecting existing clusters, make sure to apply the Seeds before installing
the Operator. We assume that `seeds-with-secrets.yaml` is part of the output of one of the conversion
commands described above.

```bash
kubectl apply -f seeds-with-secrets.yaml
```

Check that all seeds are in place now:

```bash
kubectl -n kubermatic get seeds
```

Now it's time to install the operator. Make sure to configure the `kubermatic-operator` chart properly,
taking care of setting the correct ImagePullSecret in the `values.yaml`. Once you're satisfied, install
the operator:

```bash
# This is written for Helm 3.x
helm -n kubermatic install --values myvalues.yaml kubermatic-operator charts/kubermatic-operator/
```

Finally, apply the KubermaticConfiguration. This will make the operator begin reconciling the master
cluster. Once again, we assume that this config file has been produced by the `convert-helm-values`
command:

```bash
kubectl apply -f kubermaticconfiguration.yaml
```

It will now take a few minutes for the new Kubermatic installation to become ready.

#### Migrate Seeds

Due to the `operator.kubermatic.io/skip-reconciling` annotation on Seeds, the operator will not provision them.
However Kubermatic is still seeing the Seed and wants to use it, so the migration of seeds should now be
completed relatively quickly.

To migrate a seed, first uninstall the `kubermatic` Helm chart from it. As with the master, **do not delete the CRDs.**

```bash
# This is written for Helm 2.x
helm --tiller-namespace kubermatic-installer delete --purge kubermatic
```

Like we did on the master, apply the updated CRDs now:

```bash
kubectl apply -f charts/kubematic/crd/
```

The seed cluster is now ready to be managed by the operator. On the master cluster, update the Seed resource
for the seed cluster and remove the `operator.kubermatic.io/skip-reconciling` annotation. Once the Seed is
updated, the operator will start to reconcile the seed cluster. It is recommended to follow the operator's
logs to spot any problems.

After all seed clusters have been migrated, the operator migration is finished and for health and safety reasons,
everyone involved should take a break.

## Deprecation of `nodeport-proxy` Helm Chart

In conjunction with the operator being promoted to the recommended installation method, we also deprecate the
old `nodeport-proxy` Helm chart. The proxy is still a required component of any Kubermatic setup, but is now
managed by the Kubermatic Operator (similar to how it manages seed clusters).

The migration to the operator-managed nodeport-proxy is relatively simple. The operator by default creates the
new nodeport-proxy inside the Kubermatic namespace (`kubermatic` by default), whereas the old proxy was
living in the `nodeport-proxy` namespace. Due to this, no naming conflicts can occur and in fact, both proxies
can co-exist in the same cluster.

The only important aspect is where the DNS record for the seed cluster is pointing. To migrate from the old
to new nodeport-proxy, all that needs to be done is switch the DNS record to the new LoadBalancer service. The
new services uses the same ports, so it does not matter what service a user is reaching.

To migrate, find the new LoadBalancer service's public endpoint:

```bash
kubectl -n kubermatic get svc
#NAME                   TYPE           CLUSTER-IP      EXTERNAL-IP     PORT(S)                                          AGE
#kubermatic-api         NodePort       10.47.248.61    <none>          80:32486/TCP,8085:32223/TCP                      216d
#kubermatic-dashboard   NodePort       10.47.247.32    <none>          80:32382/TCP                                     128d
#kubermatic-ui          NodePort       10.47.240.175   <none>          80:31585/TCP                                     216d
#nodeport-proxy         LoadBalancer   10.47.254.72    34.89.181.151   32180:32428/TCP,30168:30535/TCP,8002:30791/TCP   182d
#seed-webhook           ClusterIP      10.47.249.0     <none>          443/TCP                                          216d
```

Take the `nodeport-proxy`'s EXTERNAL IP, in this case `34.89.181.151`, and update your DNS record for
`*.<seedname>.kubermatic.example.com` to point to this new IP.

It will take some time for the DNS changes to propagate to every user, so it is recommended to leave the old
nodeport-proxy in place for a period of time (e.g. a week), before finally removing it:

```bash
# This is written for Helm 2.x
helm --tiller-namespace kubermatic-installer delete --purge nodeport-proxy
kubectl delete ns nodeport-proxy
```

These steps need to be performed on all seed clusters.

## Misc Helm Charts

### Prometheus

The Prometheus version included in Kubermatic Kubernetes Platform (KKP) 2.15 now enables WAL compression by default; our Helm chart follows this
recommendation. If the compression needs to stay disabled, the key `prometheus.tsdb.compressWAL` can be set to `false`
when upgrading the Helm chart.

### CRD Handling in cert-manager, Velero

In previous KKP releases, Helm was responsible for installing the CRDs for cert-manager and Velero. While this
made the deployment rather simple, it lead to problems in keeping the CRDs up-to-date (as Helm never updates or deletes
CRDs).

For this reason the CRD handling in KKP 2.15 was changed to require users to always manually install CRDs before
installing/updating a Helm chart. This provides much greater control over the CRD lifecycle and eases integration with
other deployment mechanisms.

Upgrading existing Helm releases in a cluster is simple, as Helm does not delete CRDs. To update cert-manager, simply
install the CRDs and then run Helm as usual:

```bash
kubectl apply -f charts/cert-manager/crd/
helm --tiller-namespace kubermatic upgrade --install --values YOUR_VALUES_YAML_HERE --namespace cert-manager cert-manager charts/cert-manager/
```

{{% notice note %}}
Older versions of `kubectl` can potentially have issues applying the CRD manifests. If you encounter problems, please update
your `kubectl` to the latest stable version and refer to the
[cert-manager documentation](https://cert-manager.io/docs/installation/upgrading/upgrading-0.15-0.16/#issue-with-older-versions-of-kubectl)
for more information.
{{% /notice %}}

Note that on the first `kubectl apply` you will receive warnings because now "kubectl takes control over previously
Helm-owned resources", which can be safely ignored.

Perform the same steps for Velero:

```bash
kubectl apply -f charts/backup/velero/crd/
helm --tiller-namespace kubermatic upgrade --install --values YOUR_VALUES_YAML_HERE --namespace velero velero charts/backup/velero/
```

### Promtail

The labelling for the Promtail DaemonSet has changed, requiring administrators to re-install the Helm chart. As a clean
upgrade is not possible, we advise to delete and re-install the chart.

```bash
helm --tiller-namespace kubermatic delete promtail
helm --tiller-namespace kubermatic upgrade --install --values YOUR_VALUES_YAML_HERE --namespace logging promtail charts/logging/promtail/
```

Promtail pods are stateless, so no data is lost during this migration.

### Removed Default Credentials

To prevent insecure misconfigurations, the default credentials for Grafana and Minio have been removed. They must be
set explicitly when installing the charts. Additionally, the base64 encoding for Grafana credentials has been removed,
so the plaintext values are put into the Helm `values.yaml`.

When upgrading the charts, make sure your `values.yaml` contains at least these keys:

```yaml
grafana:
  # Remember to un-base64-encode the username if you have set a custom value.
  user: admin

  # generate random password, keep it plaintext as well
  password: ExamplePassword

minio:
  credentials:
    accessKey: # generate a random, alphanumeric 32 byte secret
    secretKey: # generate a random, alphanumeric 64 byte secret
```

### Identity-Aware Proxy (IAP)

Previous KKP versions used Keycloak-Proxy for securing access to cluster services like Prometheus or Grafana.
The project was then renamed to [Louketo](https://github.com/louketo/louketo-proxy) and then shortly thereafter
[deprecated](https://github.com/louketo/louketo-proxy/issues/683) and users are encouraged to move to
[OAuth2-Proxy](https://github.com/oauth2-proxy/oauth2-proxy).

KKP 2.15 therefore switches to OAuth2-Proxy, which covers most of Keycloak's functionality but with a slightly
different syntax. Please refer to the [official documentation](https://github.com/oauth2-proxy/oauth2-proxy/blob/master/docs/configuration/configuration.md)
for the available settings, in addition to these changes:

* `iap.disocvery_url` in Helm values was renamed to `iap.oidc_issuer_url`, pointing to the OIDC provider's base
  URL (i.e. if you had this configured as `https://example.com/dex/.well-known/openid-configuration` before, this must
  now be `https://example.com/dex`).
* The `passthrough` option for each IAP deployment has been removed. Instead paths that are **not** supposed to be
  secured by the proxy are now configured via `config.skip_auth_regex`.
* The `config.scopes` option for each IAP deployment is now `config.scope`, a single string that must (for Dex)
  be space-separated.
* The `config.resources` mechanism for granting access based on user groups/roles has been removed. Instead the
  required organisations/teams are now configured via explicit config variables like `config.github_org` and
  `config.github_team`.
* `email_domains` must be configured for each IAP deployment. In most cases it can be set to `["*"]`.

A few examples can be found in the relevant [code change in KKP](https://github.com/kubermatic/kubermatic/pull/5777/files).

To prevent issues with Helm re-using IAP deployment config values from a previous release, it can be helpful to purge and
reinstall the chart:

```bash
helm --tiller-namespace kubermatic delete --purge iap
helm --tiller-namespace kubermatic upgrade --install --values YOUR_VALUES_YAML_HERE --namespace iap iap charts/iap/
```

Be advised that during the re-installation the secured services (Prometheus, Grafana, ...) will not be accessible.
