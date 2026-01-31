+++
title = "Metrics & Dashboards"
linkTitle = "Metrics & Dashboards"
weight = 10
+++

This section covers how to enable metrics scraping for KubeLB components and set up Grafana dashboards.

## Enabling Metrics Scraping

Both `kubelb-manager` and `kubelb-ccm` Helm charts support two methods for metrics scraping:

### Option 1: ServiceMonitor (recommended)

If you have the [Prometheus Operator](https://github.com/prometheus-operator/prometheus-operator) installed, enable the ServiceMonitor:

```yaml
# values.yaml
serviceMonitor:
  enabled: true
```

This creates a `ServiceMonitor` resource that configures Prometheus to scrape the KubeLB metrics endpoint via [kube-rbac-proxy](https://github.com/brancz/kube-rbac-proxy) over HTTPS on port `8443`.

{{% notice note %}}
Ensure your Prometheus instance is configured to discover ServiceMonitors across all namespaces. For kube-prometheus-stack, set `prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false`.
{{% /notice %}}

### Option 2: Pod Annotations (enabled by default)

When ServiceMonitor is disabled (default), standard Prometheus pod annotations are added automatically:

```yaml
prometheus.io/scrape: "true"
prometheus.io/port: "<metrics-port>"
prometheus.io/path: "/metrics"
```

## Metrics Port Configuration

The internal metrics port can be configured per chart:

| Chart | Value | Default |
|---|---|---|
| `kubelb-manager` | `metrics.port` | `9443` |
| `kubelb-ccm` | `metrics.port` | `9445` |

The external scrape port is always `8443` (kube-rbac-proxy).

## Grafana Dashboards

KubeLB provides pre-built Grafana dashboards that can be automatically provisioned via the [Grafana sidecar](https://github.com/grafana/helm-charts/tree/main/charts/grafana#sidecar-for-dashboards) or manually imported.

### Automatic Provisioning

Enable dashboard ConfigMaps in the Helm chart:

```yaml
# values.yaml
grafana:
  dashboards:
    enabled: true
```

This creates ConfigMaps with the `grafana_dashboard: "1"` label, which the Grafana sidecar picks up automatically.

{{% notice note %}}
If your Grafana instance runs in a different namespace than KubeLB, ensure the sidecar is configured to search all namespaces: `grafana.sidecar.dashboards.searchNamespace=ALL`.
{{% /notice %}}

### Manual Import

Dashboard JSON files are located in the `dashboards/` directory within each Helm chart:

- [kubelb-manager dashboards](https://github.com/kubermatic/kubelb/tree/release/v1.3/charts/kubelb-manager/dashboards)
- [kubelb-ccm dashboards](https://github.com/kubermatic/kubelb/tree/release/v1.3/charts/kubelb-ccm/dashboards)

Import these via the Grafana UI (**Dashboards > Import**) or API. All dashboards use a `datasource` template variable — select your Prometheus data source after import.

### Example: kube-prometheus-stack

A common setup using [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack):

```bash
helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring --create-namespace \
  --set grafana.sidecar.dashboards.enabled=true \
  --set grafana.sidecar.dashboards.searchNamespace=ALL \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false
```

Then enable monitoring in KubeLB:

```bash
helm upgrade kubelb kubelb-manager \
  --namespace kubelb \
  --set serviceMonitor.enabled=true \
  --set grafana.dashboards.enabled=true
```

## Available Dashboards

The following dashboard subpages provide detailed descriptions:

- [KubeLB Dashboards]({{< relref "./kubelb" >}}) — Overview, Manager, EnvoyCP, and CCM dashboards
- [Envoy Proxy Dashboard]({{< relref "./envoy-proxy" >}}) — Envoy proxy monitoring and metrics

For the full list of exposed Prometheus metrics, see the [Metric References]({{< relref "./references" >}}).
