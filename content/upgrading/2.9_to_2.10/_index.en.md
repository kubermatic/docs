+++
title = "Upgrading from 2.9 to 2.10"
date = 2018-10-23T12:07:15+02:00
publishDate = 2019-03-30T00:00:00+00:00
weight = 40
pre = "<b></b>"
+++

## Backup Secret Cleanup

Due to a bug, the secrets created for the backup cronjobs to access user cluster etcds didn't get cleaned
up on cluster deletion. You can delete all of them by issuing the following command once for each of your seed
clusters. The ones for the still-existing clusters will get re-created by our controller:

```bash
kubectl get secret -n kube-system | grep etcd-client-certificate | awk '{print $1}' | xargs -n 15 kubectl delete secret -n kube-system
```

## The config option `Values.kubermatic.rbac` was moved to `Values.kubermatic.masterController`

## `values.yaml` structure for addons

The structure for configuring the addons has changed and now contains a subkey `kubernetes`.
Before it was like this:

```yaml
    addons:
      image:
        repository: "quay.io/kubermatic/addons"
        tag: "v0.1.18"
        pullPolicy: "IfNotPresent"
      # list of Addons to install into every user-cluster. All need to exist in the addons image
      defaultAddons:
      - canal
      - dashboard
      - dns
      - kube-proxy
      - openvpn
      - rbac
      - kubelet-configmap
      - default-storage-class
```

Now there is a subkey `kubernetes` below `addons`:

```yaml
    addons:
      kubernetes:
        defaultAddons:
        - canal
        - dashboard
        - dns
        - kube-proxy
        - openvpn
        - rbac
        - kubelet-configmap
        - default-storage-class
        image:
          repository: "quay.io/kubermatic/addons"
          tag: "v0.1.18"
          pullPolicy: "IfNotPresent"
```

## Heptio Velero replaces Ark

As Ark was [renamed to Velero](https://github.com/heptio/velero/releases/tag/v0.11.0), the Helm chart in
`backup/ark` was replaced with a `backup/velero` chart. At the same time, the configuration for Velero
(previously kept in a dedicated `ark-config` chart) was merged into the main chart, making use of Helm's
pre-install hooks to install the CRDs before setting up the backup schedules.

When upgrading Kubermatic, make sure to manually remove the `ark` and `ark-config` charts:

```bash
helm --tiller-namespace kubermatic delete --purge ark-config
helm --tiller-namespace kubermatic delete --purge ark
```

If you have annotated pods with Ark-specific annotations, update them to their new name, e.g.
`pre.hook.backup.ark.heptio.com` to `pre.hook.backup.velero.io`.

## Node Affinities, Selectors and Tolerations

In order to improve cluster stability, all Helm charts now allow to configure node affinities, node selectors
and taint tolerations. To accomodate this change, the `values.yaml` structure for some charts has changed
slightly to make more sense. Please see the "Explicit resource requests/limits" section below for more details
about the structural changes.

The nginx-ingress-controller chart had its `ignoreMasterTaint` flag deprecated. If you want to schedule its
pods on master nodes, please make use of the new `tolerations` option and manually add the two tolerations:

```yaml
  tolerations:
  # this is a default toleration
  - key: only_critical
    operator: Equal
    value: "true"
    effect: NoSchedule

  # these two allow scheduling on master nodes
  - key: dedicated
    operator: Equal
    value: master
    effect: NoSchedule
  - key: node-role.kubernetes.io/master
    effect: NoSchedule
```

If your cluster is running on ephemaral nodes (for example, preemtible nodes on GCE/GKE), it's highly
advised to also provision a few stable nodes for long-running workloads like backup jobs. The new Velero
chart tries to schedule the Velero server on nodes with a `kubermatic.io/type: stable` label.

## Prometheus alerting rules

The alerting rules for master and seed cluster have been split up into distinct files. If you previously
configured the chart to load `/etc/prometheus/rules/kubermatic-*.yaml`, you will load both files. If you
run multiple (seed-only) clusters, you can now include (via `prometheus.ruleFiles`) either

* `/etc/prometheus/rules/kubermatic-seed-*.yaml`
* `/etc/prometheus/rules/kubermatic-master-*.yaml`

to only load alerts fitting to your deployment.

## Grafana login form

In case the identity aware proxy or Dex is down, access to Grafana was previously not possible. A new
option has been added to the chart to enable the login form:

```yaml
grafana:
  provisioning:
    configuration:
      disable_login_form: false
```

After setting this, you will be able to port-forward to Grafana's port (3000) and then login using the
static credentials configured in the chart.

## Explicit resource requests/limits

Similar to the node affinities/selectors mentioned above, all Helm charts now explicitly define resource
requests and limits in order to improve cluster stability. The following changes have been made:

* cert-manager
  * `certManager.image` was turned into `certManager.controller.image`.
  * `certManager.webhookImage` was turned into `certManager.webhook.image`.
  * `certManager.caSyncImage` was removed because it was superseded by the `certManager.cainjector.image`.
* elasticsearch
  * `elasticsearch.dataReplicas` was renamed to `elasticsearch.data.replicas`.
  * `elasticsearch.masterReplicas` was renamed to `elasticsearch.master.replicas`.
  * `elasticsearch.storageSize` was renamed to `elasticsearch.data.storageSize`.
  * `elasticsearch.cluster.env` has been added `elasticsearch.cluster.env.MINIMUM_MASTER_NODES` should
    be carefully set to avoid split-brain situations when master pods get rescheduled. Please consult
    the chart's documentation for more information.
* minio
  * `minio.backups` was turned in `minio.backup.enabled` to accomodate further backup-related settings.
* prometheus
  * `prometheus.backups` was turned in `prometheus.backup.enabled` to accomodate further backup-related settings.
* nginx-ingress-controller
  * The `nginx.prometheus` settings have been removed.
  * `nginx.ignoreMasterTaint` has been deprecated. Use the new `nginx.tolerations` options to manually
    set your required tolerations.

The `migrate-values` command of the Kubermatic installer can help to automate these changes in your
`values.yaml` file(s).

## Node-Exporter addon

A new addon for the node-exporter has been created and is now one of the default addons for Kubernetes-based
clusters. This will allow monitoring the user cluster's resource usage in the future.
