+++
title = "Upgrading from 2.13 to 2.14"
description = "Check out the best ways to upgrading KKP from 2.13 to 2.14. The document contains everything you need to know."
date = 2020-02-13T11:09:15+02:00
weight = 80

+++

## Helm Charts

### Elastic Stack

Kubermatic Kubernetes Platform (KKP) 2.14 deprecates the Elasticsearch-based logging stack, consisting of the `elasticsearch`, `kibana` and `fluentbit`
Helm charts. These components will only receive security fixes in future releases and will be removed entirely in version
2.16.

Log aggregation in KKP is now handled by [Grafana Loki](https://grafana.com/oss/loki/), offering a much simpler and
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

Previously, KKP used a shared Helm chart, `certs`, that contains all TLS certificates for both KKP and all
IAP Ingresses. This however made the configuration somewhat hard to understand and does not work well with the new
KKP Operator.

For these reasons the `certs` chart is now deprecated. Instead the `kubermatic` and `iap` charts will create their own
certificates and reference them explicitly in the Ingresses they also create. The `--default-ssl-certificate` CLI flag
for nginx is now not set anymore.

To upgrade, just upgrade the `kubermatic` and `iap` charts as normal. Make sure to have the current `cert-manager` installed
and configured to create a `letsencrypt-prod` ClusterIssuer (which it does by default). After upgrading the charts, it should
only take a minute for the new certificates to be acquired.

The `certs` chart can be removed entirely from the cluster. You might also want to manually remove the
`kubermatic/kubermatic-tls-certificates` Secret, as it will soon expire. If you used the `certs` chart to manage
non-KKP/IAP certificates, please migrate accordingly as the chart will soon not be published with KKP anymore.

## Addon Templating

KKP 2.14 introduced a stable interface for templating addon manifests. Previously, the exact variables that could be
used were not documented and could change in between releases.

Please refer to the [addon documentation]({{< ref "../../../guides/addons#manifest-templating" >}}) for more information about
the available fields. Compared to previous versions, the following are the most noticeable changes:

* `.Cluster` is now a dedicated structure and not the Cluster CRD anymore. The CRD was never meant as a stable interface.
* `.Kubeconfig` is now `.Cluster.Kubeconfig`.
* `.MajorMinorVersion` is now `.Cluster.MajorMinorVersion`. The exact version is now also available as `.Cluster.Version`.
* `.ClusterCIDR` is now `first .Cluster.Network.PodCIDRBlocks`.
* `.DNSResolverIP` is now `.Cluster.Network.DNSResolverIP`.
* `.DNSClusterIP` is now `.Cluster.Network.DNSClusterIP`.
* `.Addon` was removed as it did not contain any relevant information.

If you have custom addons, make sure to review their manifests to ensure they continue to work.
