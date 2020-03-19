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

### Certificates

Previously, Kubermatic used a shared Helm chart, `certs`, that contains all TLS certificates for both Kubermatic and all
IAP Ingresses. This however made the configuration somewhat hard to understand and does not work well with the new
Kubermatic Operator.

For these reasons the `certs` chart is now deprecated. Instead the `kubermatic` and `iap` charts will create their own
certificates and reference them explicitly in the Ingresses they also create. The `--default-ssl-certificate` CLI flag
for nginx is now not set anymore.

To upgrade, just upgrade the `kubermatic` and `iap` charts as normal. Make sure to have the current `cert-manager` installed
and configured to create a `letsencrypt-prod` ClusterIssuer (which it does by default). After upgrading the charts, it should
only take a minute for the new certificates to be acquired.

The `certs` chart can be removed entirely from the cluster. You might also want to manually remove the
`kubermatic/kubermatic-tls-certificates` Secret, as it will soon expire. If you used the `certs` chart to manage
non-Kubermatic/IAP certificates, please migrate accordingly as the chart will soon not be published with Kubermatic anymore.
