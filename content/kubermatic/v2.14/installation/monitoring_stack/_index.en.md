+++
title = "Monitoring Stack"
date = 2020-02-14T12:07:15+02:00
weight = 40

+++

This chapter describes how to setup the Kubermatic Kubernetes Platform(KKP) monitoring stack. It's highly recommended to install this
stack on the master and all seed clusters.

### Requirements

The exact requirements for the stack depend highly on the expected cluster load; the following are the minimum
viable resources:

* 4 GB RAM
* 2 CPU cores
* 200 GB disk storage

This guide assumes the following tools are available:

* Helm 3.x
* kubectl 1.16+

### Installation

As with KKP itself, it's recommended to use a single `values.yaml` to configure all Helm charts. There
are a few important options you might want to override for your setup:

* `prometheus.host` is used for the external URL in Prometheus, e.g. `prometheus.kubermatic.example.com`.
* `alertmanager.host` is used for the external URL in Alertmanager, e.g. `alertmanager.kubermatic.example.com`.
* `prometheus.storageSize` (default: `100Gi`) controls the volume size for each Prometheus replica; this should
  be large enough to hold all data as per your retention time (see next option). Long-term storage for Prometheus
  blocks is provided by Thanos, an optional extension to the Prometheus chart.
* `prometheus.tsdb.retentionTime` (default: `15d`) controls how long metrics are stored in Prometheus before they
  are deleted. Larger retention times require more disk space. Long-term storage is accomplished by Thanos, so the
  retention time for Prometheus itself should not be set to extremely large values (like multiple months).
* `prometheus.ruleFiles` is a list of Prometheus alerting rule files to load. Depending on whether or not the
  target cluster is a master or seed, the `/etc/prometheus/rules/kubermatic-master-*.yaml` entry should be removed
  in order to not trigger bogus alerts.
* `grafana.user` and `grafana.password` should be set with custom values if no identity-aware proxy is configured.
  In this case, `grafana.provisioning.configuration.disable_login_form` should be set to `false` so that a manual
  login is possible.

An example `values.yaml` could look like this if all options mentioned above are customized:

```yaml
prometheus:
  host: prometheus.kubermatic.example.com
  storageSize: '250Gi'
  tsdb:
    retentionTime: '30d'
  # only load the kubermatic-master alerts, as this cluster is not a shared master/seed
  ruleFiles:
  - /etc/prometheus/rules/general-*.yaml
  - /etc/prometheus/rules/kubermatic-master-*.yaml
  - /etc/prometheus/rules/managed-*.yaml

alertmanager:
  host: alertmanager.kubermatic.example.com

grafana:
  user: admin
  password: adm1n
  provisioning:
    configuration:
      disable_login_form: false
```

With this file prepared, we can now install all required charts:

```bash
helm upgrade --install --values values.yaml --namespace monitoring prometheus charts/monitoring/prometheus/
helm upgrade --install --values values.yaml --namespace monitoring alertmanager charts/monitoring/alertmanager/
helm upgrade --install --values values.yaml --namespace monitoring node-exporter charts/monitoring/node-exporter/
helm upgrade --install --values values.yaml --namespace monitoring kube-state-metrics charts/monitoring/kube-state-metrics/
helm upgrade --install --values values.yaml --namespace monitoring grafana charts/monitoring/grafana/
helm upgrade --install --values values.yaml --namespace monitoring karma charts/monitoring/karma/
```

### Going Further

The charts have a lot more options to tweak, like `alertmanager.config` or `karma.config` to control how and which
alerts are sent where.

Likewise, when your cluster grows, you most likely want to adjust the resource requirements in
`prometheus.containers.prometheus.resources` and others.

### Thanos (Beta)

[Thanos](https://thanos.io/) is a long-term storage solution for Prometheus metrics, backed by an S3 compatible
object store. KKP includes preliminary support for Thanos by setting `prometheus.thanos.enabled=true`. Note
that this requires considerably more resources to run:

* Thanos UI requires roughly 64MB memory and 50m CPU.
* Thanos Store requires 2GB memory and 500 mCPU per pod.
* Thanos Query requires 512MB memory and 100m CPU per pod.
* Thanos Compact requires lots of memory, depending on block sizes, up to 16GB, and 1 CPU core.

It's essential to configure the retention period for Thanos using `prometheus.thanos.compact.retention`, as well as to
configure the proper object store and create the required bucket. Refer to the `config/prometheus/values.yaml` for a
complete list of options.
