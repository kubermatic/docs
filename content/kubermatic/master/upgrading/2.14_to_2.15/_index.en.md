+++
title = "Upgrading from 2.14 to 2.15"
date = 2020-06-09T11:09:15+02:00
weight = 90

+++

## Helm Charts

### Promtail

The labelling for the Promtail DaemonSet has changed, requiring administrators to re-install the Helm chart. As a clean
upgrade is not possible, we advise to delete and re-install the chart.

```bash
helm --tiller-namespace kubermatic delete promtail
helm --tiller-namespace kubermatic upgrade --install --values YOUR_VALUES_YAML_HERE --namespace logging promtail charts/logging/promtail/
```

Promtail pods are stateless, so no data is lost during this migration.
