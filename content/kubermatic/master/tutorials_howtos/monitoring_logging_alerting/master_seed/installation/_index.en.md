+++
linkTitle = "Installation"
title = "Installation of the Master / Seed MLA Stack"
date = 2020-02-14T12:07:15+02:00
weight = 10
+++

This chapter describes how to setup the [KKP Master / Seed MLA (Monitoring, Logging & Alerting) stack]({{< relref "../../../../architecture/monitoring_logging_alerting/master_seed/" >}}). It's highly recommended to install this stack on the master and all seed clusters.

### Requirements

The exact requirements for the stack depend highly on the expected cluster load; the following are the minimum
viable resources:

* 4 GB RAM
* 2 CPU cores
* 200 GB disk storage

This guide assumes the following tools are available:

* Helm 3.x
* kubectl 1.16+

## Monitoring & Alerting Components

This chapter describes how to setup the Kubermatic Kubernetes Platform (KKP) master / seed monitoring & alerting components. It's highly recommended to install this
stack on the master and all seed clusters.

It uses [Prometheus](https://prometheus.io) and its [Alertmanager](https://prometheus.io/docs/alerting/alertmanager/) for monitoring and alerting. Dashboarding is done with [Grafana](https://grafana.com). More information can be found in the [Architecture]({{< relref "../../../../architecture/monitoring_logging_alerting/master_seed/" >}}) document.

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
* `prometheus.blackboxExporter.enabled` is used to enable integration between Prometheus and Blackbox Exporter, used for monitoring of API endpoints of user clusters created on the seed. `prometheus.blackboxExporter.url` should be adjusted accordingly (default value would be `blackbox-exporter:9115`)
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
  # only load the KKP-master alerts, as this cluster is not a shared master/seed
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

**Helm 3**

```bash
helm --namespace monitoring upgrade --install --wait --values /path/to/your/helm-values.yaml prometheus charts/monitoring/prometheus/
helm --namespace monitoring upgrade --install --wait --values /path/to/your/helm-values.yaml alertmanager charts/monitoring/alertmanager/
helm --namespace monitoring upgrade --install --wait --values /path/to/your/helm-values.yaml node-exporter charts/monitoring/node-exporter/
helm --namespace monitoring upgrade --install --wait --values /path/to/your/helm-values.yaml kube-state-metrics charts/monitoring/kube-state-metrics/
helm --namespace monitoring upgrade --install --wait --values /path/to/your/helm-values.yaml grafana charts/monitoring/grafana/
helm --namespace monitoring upgrade --install --wait --values /path/to/your/helm-values.yaml karma charts/monitoring/karma/
helm --namespace monitoring upgrade --install --wait --values /path/to/your/helm-values.yaml blackbox-exporter charts/monitoring/blackbox-exporter/
```

### Going Further

The charts have a lot more options to tweak, like `alertmanager.config` or `karma.config` to control how and which
alerts are sent where.

Likewise, when your cluster grows, you most likely want to adjust the resource requirements in
`prometheus.containers.prometheus.resources` and others.

You can find more information on the [Monitoring, Logging & Alerting Customization]({{< relref "../customization" >}}) page.

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

## Logging Components

This chapter describes how to setup the Kubermatic Kubernetes Platform (KKP) master / seed logging components. It's highly recommended to install this
stack on the master and all seed clusters.

The logging stack consists of Promtail and [Grafana Loki](https://grafana.com/oss/loki/). More information can be found in the [Architecture]({{< relref "../../../../architecture/monitoring_logging_alerting/master_seed/" >}}) document.

### Requirements

The exact requirements for the stack depend highly on the expected cluster load; the following are the minimum
viable resources:

* 2 GB RAM
* 2 CPU cores
* 50 GB disk storage

This guide assumes the following tools are available:

* Helm 3.x
* kubectl 1.16+

It is also assumed that the monitoring stack is installed, as its
Grafana deployment is used to inspect the aggregated logs from Loki.

### Installation

As with KKP itself, it's recommended to use a single `values.yaml` to configure all Helm charts. There
are a few important options you might want to override for your setup:

* `loki.persistence.size` (default: `10Gi`) controls the volume size for the Loki pods.
* `promtail.scrapeConfigs` controls for which pods the logs are collected. The default configuration should
  be sufficient for most cases, but adjustment can be made.
* `promtail.tolerations` might need to be extended to deploy a Promtail pod on every node in the cluster.
  By default, master-node NoSchedule taints are ignored.

An example `values.yaml` could look like this if all options mentioned above are customized:

```yaml
loki:
  persistence:
    size: '100Gi'

promtail:
  scrapeConfigs:
  - ...
```

With this file prepared, we can now install all required charts:

**Helm 3**

```bash
helm dependency build charts/logging/promtail
helm --namespace logging upgrade --install --wait --values /path/to/your/helm-values.yaml promtail charts/logging/promtail/

helm dependency build charts/logging/loki/
helm --namespace logging upgrade --install --wait --values /path/to/your/helm-values.yaml loki charts/logging/loki/
```
