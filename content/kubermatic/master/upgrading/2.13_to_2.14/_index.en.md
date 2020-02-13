+++
title = "Upgrading from 2.13 to 2.14"
date = 2020-02-13T11:09:15+02:00
weight = 80
pre = "<b></b>"
+++

## Helm Charts

### Elastic Stack

Kubermatic 2.14 deprecates the Elasticsearch-based logging stack, consisting of the `elasticsearch`, `kibana` and `fluentbit`
Helm charts. These components will only receive security fixes in future releases and will be removed entirely in version
2.16.

Log aggregation in Kubermatic is now handled by [Grafana Loki](https://grafana.com/oss/loki/), offering a much simpler and
less resource intensive setup. As existing data cannot be migrated into Loki, it's recommended to install Loki in parallel
to an existing ELK stack and ship logs only to it going forward. Once all logs in Elasticsearch have expired, the Elastic
Stack can be deleted.

Loki can be setup by installing two Helm charts:

```bash
helm upgrade --tiller-namespace kubermatic --install --values YOUR_VALUES_YAML_HERE --namespace logging loki charts/logging/loki/
helm upgrade --tiller-namespace kubermatic --install --values YOUR_VALUES_YAML_HERE --namespace logging promtail charts/logging/promtail/
```

An alternative to Loki is the [Elastic Cloud on Kubernetes (ECK)](https://www.elastic.co/elastic-cloud-kubernetes) stack,
which greatly simplifies managing Elasticsearch clusters on Kubernetes. Like with Loki, there is no migration planned and
customers are advised to install an ECK stack in parallel to slowly phase out the old, Helm-based stack.
