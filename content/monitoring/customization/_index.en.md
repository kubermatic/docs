+++
title = "Customization"
date = 2018-08-17T12:07:15+02:00
weight = 0
+++

When it comes to monitoring, no approach fits all usecases. It's exptected that you will want to adjust things to your
needs and this page describes the various places where customizations can be applied. In broad terms, there are four
main areas that are discussed:

* customer-cluster Prometheus
* seed-cluster Prometheus
* alertmanager rules
* Grafana dashboards

You will want to familiarize yourself with the [basic architecture](/monitoring/architecture/) before reading any
further.

## Customer-Cluster Prometheus

The basic source of metrics is the Prometheus inside each customer cluster namespace. It will track the customer
clusters control plane (**IMPORTANT:** it is NOT responsible for the components running in the customer clusters
themselves.)

This Prometheus is deployed as part of Kubermatic's cluster creation, which means you cannot directly affect its
deployment.

Therefore to still allow customization of rules, Kubermatic provides the possibility to specify rules as part of the
`values.yaml` which gets fed to the Kubermatic chart.

### Rules

Custom rules can be added beneath the `clusterNamespacePrometheus.rules` key:
```yaml
kubermatic:
  clusterNamespacePrometheus:
    disableDefaultRules: false
    rules:
      groups:
      - name: my-custom-group
        rules:
        - alert: MyCustomAlert
          annotations:
            message: Something happend in {{ $labels.namespace }}
          expr: |
            sum(rate(machine_controller_errors_total[5m])) by (namespace) > 0.01
          for: 10m
          labels:
            severity: warning
```

If you'd like to disable the default rules coming with Kubermatic itself, you can specify the `disableDefaultRules`
flag:
```yaml
kubermatic:
  clusterNamespacePrometheus:
    disableDefaultRules: false
```

### Scraping Configs

Custom scraping configs can be specified by adding the corresponding entries beneath the
`clusterNamespacePrometheus.scrapingConfigs` key in the `values.yaml`:

```yaml
clusterNamespacePrometheus:
  scrapingConfigs:
  - job_name: 'schnitzel'
    kubernetes_sd_configs:
    - role: pod
    relabel_configs:
    - source_labels: [__meta_kubernetes_pod_annotation_kubermatic_scrape]
      action: keep
      regex: true
```

Also, the default Kubermatic scraping configs can be disabled in the same way:
```yaml
clusterNamespacePrometheus:
  disableDefaultScrapingConfigs: true
```

## Seed-Cluster Prometheus

This Prometheus is primarily used to collect metrics from the customer clusters and then provide those to Grafana. In
contrast to the Prometheus mentioned above, this one is deployed via a [Helm](https://helm.sh) chart and you can use
Helm's native customization options.

### Labels

To specify additional labels that are sent to the alertmanager whenever an alert occurs, you can add an `externalLabels`
element to your `values.yaml` and list your desired labels there:

```yaml
prometheus:
  externalLabels:
    mycustomlabel: a value
    rack: rack17
    location: europe
```

### Rules

Rules include recording rules (for precomputing expensive queries) and alerts. There are three different ways of
customizing them.

#### values.yaml

You can add our own rules by adding them to the `values.yaml` like so:

```yaml
prometheus:
  rules:
    groups:
      - name: myrules
        rules:
        - alert: DatacenterIsOnFire
          annotations:
            message: |
              The datacenter has gone up in flames, someone should quickly find an extinguisher.
              You can reach the local emergency services by calling 0118 999 881 999 119 7253.
          expr: temperature{server=~"kubernetes.+"} > 100
          for: 5m
          labels:
            severity: critical
```

This will lead to them being written to a dedicated `_customrules.yaml` and included in Prometheus. Use this approach if
you only have a few rules that you'd like to add.

#### Extending the Helm Chart

If you have more than a couple of rules, you can also place new YAML files inside the `rules/` directory before you
deploy the Helm chart. They will be included like you would expect. To prevent maintainence headaches further down the
road you should never change the existing files inside the chart. If you need to get rid of the predefined rules, see
the next section on how to achieve it.

#### Custom ConfigMaps/Secrets

For large deployments with many independently managed rules you can make use of custom volumes to mount your
configuration into Prometheus. For this to work you need to create your own ConfigMap or Secret inside the `monitoring`
namespace. Then configure the Prometheus chart using the `values.yaml` to mount those appropriately like so:

```yaml
prometheus:
  volumes:
  - name: initech-rules-volume
    mountPath: /initech/rules
    configMap: initech-rules
```

After mounting the files into the pod you need to make sure that Prometheus loads them by extending the `ruleFiles`
list:

```yaml
prometheus:
  ruleFiles:
  - '/etc/prometheus/rules/*.yaml'
  - '/initech/rules/*.yaml'
```

Managing the `ruleFiles` is also the way to disable the predefined rules by just removing the applicable item from the
list. You can also keep the list completely empty to disable any and all alerts.

## Alertmanager

TBD

## Grafana Dashboards

Customizing Grafana entails three different aspects:

* Datasources (like Prometheus, InfluxDB, ...)
* Dashboard providers (telling Grafana where to load dashboards from)
* Dashboards themselves

In all cases you have two general approaches: Either take the Grafana Helm chart and place additional files into the
existing directory structure or leave the Helm chart as-is and use the `values.yaml` and your own ConfigMaps/Secrets to
hold your customizations. This is very similar to how customizing the seed-level Prometheus works, so if you read that
chapter, you will feel right at home.

### Datasources

To create a new datasource, you can either put a new YAML file inside the `provisioning/datasources/` directory or
extend your `values.yaml` like so:

```yaml
grafana:
  provisioning:
    datasources:
      extra:
      # list your new datasources here
      - name: influxdb
        type: influxdb
        access: proxy
        org_id: 1
        url: http://influxdb.monitoring.svc.cluster.local:9090
        version: 1
        editable: false
```

You can also remove the default Prometheus datasource if you really want to by either deleting the `prometheus.yaml` or
pointing the `source` directive inside your `values.yaml` to a different, empty directory:

```yaml
grafana:
  provisioning:
    datasources:
      source: empty/
```

Note that by removing the default Prometheus datasource and not providing an alternative with the same name, the default
dashboards will not work anymore.

### Dashboard Providers

Configuring providers works much in the same way as configuring datasources: either place new files in the
`provisioning/dashboards/` directory or use the `values.yaml` accordingly:

```yaml
grafana:
  provisioning:
    dashboards:
      extra:
      # list your new datasources here
      - folder: "Initech Resources"
        name: "initech"
        options:
          path: /initech/dashboards
        org_id: 1
        type: file
```

Customizing the providers is especially important if you want to also add your own dashboards. You can point the
`options.path` path to a new mounted volume to load dashboards from (see below).

### Dashboards

Just like with datasources and providers, new dashboards can be placed in the existing `dashboards/` directory. Do note
though that if you create a new folder (like `dashboards/initech/`), you also must create a new dashboard provider to
tell Grafana about it. Your dashboards will be loaded and included in the default ConfigMap, but without the new
provider Grafana will not see them.

Following the example above, if you put your dashboards in `dashboards/initech/`, you need a dashboard provider with the
`options.path` set to `/grafana-dashboard-definitions/initech`, because the ConfigMap is mounted to
`/grafana-dashboard-definitions`.

You can also use your own ConfigMaps or Secrets and have the Grafana deployment mount them. This is useful for larger
customizations with lots of dashboards that you want to manage independently. To use an external ConfigMap, create it
like so:

```yaml
- apiVersion: v1
  kind: ConfigMap
  metadata:
    name: initech-dashboards
  data:
    dashboard1.json: |
      { ... Grafana dashboard JSON here ... }

    dashboard2.json: |
      { ... Grafana dashboard JSON here ... }
```

Make sure to create your ConfigMap in the `monitoring` namespace and then use the `volumes` directive in your
`values.yaml` to tell the Grafana Helm chart about your ConfigMap:

```yaml
grafana:
  volumes:
  - name: initech-dashboards-volume
    mountPath: /grafana-dashboard-definitions/initech
    configMap: initech-dashboards
```

Using a Secret instead of a ConfigMap works identically, just specify `secretName` instead of `configMap` in the
`volumes` section.

Remember that you still need a custom dashboard provider to make Grafana load your new dashboards.
