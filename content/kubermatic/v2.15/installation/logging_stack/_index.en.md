+++
title = "Logging Stack"
date = 2020-02-14T12:07:15+02:00
weight = 80

+++

This chapter describes how to setup the Kubermatic Kubernetes Platform (KKP) logging stack. It's highly recommended to install this
stack on the master and all seed clusters.

The logging stack consists of Promtail and [Grafana Loki](https://grafana.com/oss/loki/). Customers with more
elaborate requirements can also choose to install an ELK stack (either via Helm or using the Elastic Cloud on
Kubernetes operator).

### Requirements

The exact requirements for the stack depend highly on the expected cluster load; the following are the minimum
viable resources:

* 2 GB RAM
* 2 CPU cores
* 50 GB disk storage

This guide assumes the following tools are available:

* Helm 3.x
* kubectl 1.16+

It is also assumed that the [monitoring stack]({{< ref "../monitoring_stack" >}}) is installed, as its
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

```bash
helm upgrade --install --values values.yaml --namespace monitoring promtail charts/monitoring/promtail/
helm upgrade --install --values values.yaml --namespace monitoring loki charts/monitoring/loki/
```
