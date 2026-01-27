+++
title = "Metrics"
linkTitle = "Metrics"
weight = 10
+++

KubeLB exposes Prometheus metrics for monitoring the health and performance of the load balancers. These metrics can be scraped by Prometheus and visualized using Grafana or other monitoring tools.

## Envoy Proxy Metrics

In addition to the KubeLB component metrics listed below, the Envoy proxies managed by KubeLB expose their own Prometheus metrics on port `19001` at `/stats/prometheus`. These pods are pre-configured with Prometheus scraping annotations and provide detailed insight into upstream/downstream connections, HTTP request statistics, and cluster health. For a full reference of available Envoy metrics, see the [Envoy Statistics Overview](https://www.envoyproxy.io/docs/envoy/latest/operations/stats_overview).

{{% children depth=5 %}}
{{% /children %}}
