+++
title = "Observability"
linkTitle = "Observability"
date = 2023-10-27T10:07:15+02:00
weight = 9
+++

KubeLB is a mission-critical component in the Kubernetes ecosystem, and its observability is crucial for ensuring the stability and reliability of the platform. This guide will walk you through the steps to enable and configure observability for KubeLB.

KubeLB in itself doesn't restrict the platform providers to certain observability tools. Since we are well aware that different customers will have different Monitoring, logging, alerting, and tracing etc. stacks deployed which are based on their  own requirements. Although it does offer Grafana dashboards that can be plugged into your existing monitoring stack.

## Metrics

KubeLB exposes Prometheus metrics for monitoring the health and performance of the load balancers. See the [Metrics]({{< relref "./metrics" >}}) section for detailed documentation on available metrics for both Community Edition and Enterprise Edition.

### Enabling Metrics Scraping

Both `kubelb-manager` and `kubelb-ccm` Helm charts support two methods for metrics scraping:

**Option 1: ServiceMonitor (recommended)**

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

**Option 2: Pod Annotations (enabled by default)**

When ServiceMonitor is disabled (default), standard Prometheus pod annotations are added automatically:

```yaml
prometheus.io/scrape: "true"
prometheus.io/port: "<metrics-port>"
prometheus.io/path: "/metrics"
```

### Metrics Port Configuration

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

This creates ConfigMaps with the `grafana_dashboard: "1"` label, which the Grafana sidecar picks up automatically. The following dashboards are provisioned:

**kubelb-manager chart:**

- **KubeLB / Overview** — High-level system health, resource distribution, error tracking
- **KubeLB / Manager** — Resource inventory, reconciliation rates and latency
- **KubeLB / Envoy Control Plane** — xDS resources, gRPC connections, cache performance, snapshot management

**kubelb-ccm chart:**

- **KubeLB / CCM** — CCM resource counts, reconciliation performance, managed services/ingresses/routes

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

## Traffic Flow Visibility

For environments requiring centralized visibility into traffic flow (source/destination tracking), [Hubble UI](https://docs.cilium.io/en/stable/gettingstarted/hubble_setup/) is recommended when using Cilium as the CNI on the KubeLB cluster. Hubble provides a service map and real-time traffic flow visualization, making it easy to track callers and destinations across the cluster.

## Recommended Tools

Our suggested tools for observability are:

1. [Gateway Observability](https://gateway.envoyproxy.io/docs/tasks/observability/gateway-observability/): This is the default MLA stack provided by Envoy Gateway. Since it's designed specifically for Envoy Gateway and Gateway APIs, it offers a comprehensive set of observability features tailored to the needs of Envoy Gateway users.
2. [Hubble UI](https://docs.cilium.io/en/stable/gettingstarted/hubble_setup/): When using Cilium as the CNI, Hubble UI provides a user-friendly interface for visualizing and analyzing network traffic in your Kubernetes cluster.
3. [Kiali](https://kiali.io/docs/installation/installation-guide/): When using Istio as the service mesh, Kiali is a powerful tool for visualizing and analyzing the traffic flow within your Istio-based applications.
