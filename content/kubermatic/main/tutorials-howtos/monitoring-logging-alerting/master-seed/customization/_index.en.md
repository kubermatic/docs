+++
linkTitle = "Customization"
title = "Customization of the Master / Seed MLA Stack"
date = 2018-08-17T12:07:15+02:00
weight = 20
+++

This chapter describes the customization of the KKP [Master / Seed Monitoring, Logging & Alerting Stack]({{< relref "../../../../architecture/monitoring-logging-alerting/master-seed/_index.en.md" >}}).

When it comes to monitoring, no approach fits all use cases. It's expected that you will want to adjust things to your needs, and this page describes the various places where customizations can be applied. In broad terms, four main areas are discussed:

- User-cluster Prometheus
- Seed-cluster Prometheus
- Alertmanager rules
- Grafana dashboards

You will want to familiarize yourself with the [Installation of the Master / Seed MLA Stack]({{< relref "../installation/" >}}) before reading any further.

## User Cluster Prometheus

Each user cluster is monitored by a dedicated Prometheus instance that runs within its namespace on the seed cluster.
This instance is responsible for collecting metrics from the user cluster's control plane. 
It's important to note that the scope of this Prometheus is limited to the control plane of the user cluster; hence it does not collect metrics from applications or workloads running inside the user cluster.

While the lifecycle of this Prometheus is managed automatically by KKP, you can still add custom rules.

To do so, specify your desired rules in the KubermaticConfiguration custom resource.

### Rules

KKP comes with the default rules; however, new custom rules can be added, or the default set can be disabled.

#### Custom rules

To add custom rules, they must be defined as a YAML-formatted string under the `spec.monitoring.customRules` field.

```yaml
apiVersion: kubermatic.k8c.io/v1
kind: KubermaticConfiguration
metadata:
  name: <<mykubermatic>>
  namespace: kubermatic
spec:
    # Monitoring can be used to fine-tune to in-cluster Prometheus.
    monitoring:
      # CustomRules can be used to inject custom recording and alerting rules. This field
      # must be a YAML-formatted string with a `group` element at its root, as documented
      # on https://prometheus.io/docs/prometheus/latest/configuration/alerting_rules/.
      # This value is treated as a Go template, which allows to inject dynamic values like
      # the internal cluster address or the cluster ID. Refer to pkg/resources/prometheus
      # and the documentation for more information on the available fields.
      customRules: |
        groups:
          - name: my-custom-group
            rules:
              - alert: MyCustomAlert
                annotations:
                  message: Something happened in {{ $labels.namespace }}
                expr: |
                  sum(rate(machine_controller_errors_total[5m])) by (namespace) > 0.01
                for: 10m
                labels:
                  severity: warning        
```

#### Disable the default rules

The default rules provided by KKP can be disabled by setting the `spec.monitoring.disableDefaultRules` flag to `true`.

```yaml
apiVersion: kubermatic.k8c.io/v1
kind: KubermaticConfiguration
metadata:
  name: <<mykubermatic>>
  namespace: kubermatic
spec:
    # Monitoring can be used to fine-tune to in-cluster Prometheus.
    monitoring:
      # DisableDefaultRules disables the recording and alerting rules.
      disableDefaultRules: true
```

### Scraping Configs

The scraping behavior of Prometheus can be customized. New scraping configurations can be added, and the default configurations can be disabled.

#### Add Custom Scraping Configurations

Custom scraping configurations can be specified by adding them under the `spec.monitoring.customScrapingConfigs` field.

```yaml
apiVersion: kubermatic.k8c.io/v1
kind: KubermaticConfiguration
metadata:
  name: <<mykubermatic>>
  namespace: kubermatic
spec:
    # Monitoring can be used to fine-tune to in-cluster Prometheus.
    monitoring:
      # CustomScrapingConfigs can be used to inject custom scraping rules. This must be a
      # YAML-formatted string containing an array of scrape configurations as documented
      # on https://prometheus.io/docs/prometheus/latest/configuration/configuration/#scrape_config.
      # This value is treated as a Go template, which allows to inject dynamic values like
      # the internal cluster address or the cluster ID. Refer to pkg/resources/prometheus
      # and the documentation for more information on the available fields.
      customScrapingConfigs: |
        - job_name: 'schnitzel'
          kubernetes_sd_configs:
            - role: pod
          relabel_configs:
            - source_labels: [__meta_kubernetes_pod_annotation_kubermatic_scrape]
              action: keep
              regex: true
```

#### Disable Default Scraping Configurations

The default scraping configurations provided by KKP can be disabled. This is accomplished by setting the `spec.monitoring.disableDefaultScrapingConfigs` flag to `true`.

```yaml
apiVersion: kubermatic.k8c.io/v1
kind: KubermaticConfiguration
metadata:
  name: <<mykubermatic>>
  namespace: kubermatic
spec:
    # Monitoring can be used to fine-tune to in-cluster Prometheus.
    monitoring:
      # DisableDefaultScrapingConfigs disables the default scraping targets.
      disableDefaultScrapingConfigs: true
```

## Seed Cluster Prometheus

This Prometheus is primarily used to collect metrics from the user clusters and then provide those to Grafana. In contrast to the Prometheus mentioned above, this one is deployed via a [Helm](https://helm.sh) chart, and you can use Helm's native customization options.

### Labels

To specify additional labels that are sent to the Alertmanager whenever an alert occurs, you can add an `externalLabels` element to your `values.yaml` and list your desired labels there:

```yaml
prometheus:
  externalLabels:
    mycustomlabel: a value
    rack: rack17
    location: europe
```

### Rules

Rules include recording rules (for precomputing expensive queries) and alerts. There are three different ways of customizing them.

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

This will lead to them being written to a dedicated `_customrules.yaml` and included in Prometheus. Use this approach if you only have a few rules that you'd like to add.

#### Extending the Helm Chart

If you have more than a couple of rules, you can also place new YAML files inside the `rules/` directory before you deploy the Helm chart. They will be included as you would expect. To prevent maintenance headaches further down the road, you should never change the existing files inside the chart. If you need to get rid of the predefined rules, see the next section on how to achieve it.

#### Custom ConfigMaps/Secrets

For large deployments with many independently managed rules, you can make use of custom volumes to mount your configuration into Prometheus. For this, to work, you need to create your own ConfigMap or Secret inside the `monitoring` namespace. Then configure the Prometheus chart using the `values.yaml` to mount those appropriately like so:

```yaml
prometheus:
  volumes:
  - name: example-rules-volume
    mountPath: /example/rules
    configMap: example-rules
```

After mounting the files into the pod, you need to make sure that Prometheus loads them by extending the `ruleFiles` list:

```yaml
prometheus:
  ruleFiles:
  - '/etc/prometheus/rules/*.yaml'
  - '/example/rules/*.yaml'
```

Managing the `ruleFiles` is also the way to disable the predefined rules by just removing the applicable item from the list. You can also keep the list completely empty to disable any and all alerts.

### Long-term metrics storage

By default, the seed Prometheus is configured to store 1 day's worth of metrics.
It can be customized via overriding the `prometheus.tsdb.retentionTime` field in `values.yaml` used for chart installation.

If you would like to store the metrics for the long term, typically other solutions like Thanos are used. Thanos integration is a more involved process. Please read more about [Thanos integration]({{< relref "./thanos.md" >}}).

## Alertmanager

Alertmanager configuration can be tweaked via `values.yaml` like so:

```yaml
alertmanager:
  config:
    global:
      slack_api_url: https://hooks.slack.com/services/YOUR_KEYS_HERE
    route:
      receiver: default
      repeat_interval: 1h
      routes:
        - receiver: blackhole
          match:
            severity: none
    receivers:
      - name: blackhole
      - name: default
        slack_configs:
          - channel: '#alerting'
            send_resolved: true
```

Please review the [Alertmanager Configuration Guide](https://prometheus.io/docs/alerting/latest/configuration/) for detailed configuration syntax.

You can review the [Alerting Runbook]({{< relref "../../../../cheat-sheets/alerting-runbook" >}}) for a reference of alerts that Kubermatic Kubernetes Platform (KKP) monitoring setup can fire, alongside a short description and steps to debug.

## Grafana Dashboards

Customizing Grafana entails three different aspects:

- Datasources (like Prometheus, InfluxDB, ...)
- Dashboard providers (telling Grafana where to load dashboards from)
- Dashboards themselves

In all cases, you have two general approaches: Either take the Grafana Helm chart and place additional files into the existing directory structure or leave the Helm chart as-is and use the `values.yaml` and your own ConfigMaps/Secrets to hold your customizations. This is very similar to how customizing the seed-level Prometheus works, so if you read that chapter, you will feel right at home.

### Datasources

To create a new datasource, you can either put a new YAML file inside the `provisioning/datasources/` directory or extend your `values.yaml` like so:

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

You can also remove the default Prometheus datasource if you really want to by either deleting the `prometheus.yaml` or pointing the `source` directive inside your `values.yaml` to a different, empty directory:

```yaml
grafana:
  provisioning:
    datasources:
      source: empty/
```

Note that by removing the default Prometheus datasource and not providing an alternative with the same name, the default dashboards will not work anymore.

### Dashboard Providers

Configuring providers works much in the same way as configuring datasources: either place new files in the `provisioning/dashboards/` directory or use the `values.yaml` accordingly:

```yaml
grafana:
  provisioning:
    dashboards:
      extra:
      # list your new datasources here
      - folder: "Example Resources"
        name: "example"
        options:
          path: /example/dashboards
        org_id: 1
        type: file
```

Customizing the providers is especially important if you also want to add your own dashboards. You can point the `options.path` path to a newly mounted volume to load dashboards from (see below).

### Dashboards

Just like with datasources and providers, new dashboards can be placed in the existing `dashboards/` directory. Do note though that if you create a new folder (like `dashboards/example/`), you also must create a new dashboard provider to tell Grafana about it. Your dashboards will be loaded and included in the default ConfigMap, but without the new provider, Grafana will not see them.

Following the example above, if you put your dashboards in `dashboards/example/`, you need a dashboard provider with the `options.path` set to `/grafana-dashboard-definitions/example`, because the ConfigMap is mounted to `/grafana-dashboard-definitions`.

You can also use your own ConfigMaps or Secrets and have the Grafana deployment mount them. This is useful for larger customizations with lots of dashboards that you want to manage independently. To use an external ConfigMap, create it like so:

```yaml
- apiVersion: v1
  kind: ConfigMap
  metadata:
    name: example-dashboards
  data:
    dashboard1.json: |
      { ... Grafana dashboard JSON here ... }

    dashboard2.json: |
      { ... Grafana dashboard JSON here ... }
```

Make sure to create your ConfigMap in the `monitoring` namespace and then use the `volumes` directive in your `values.yaml` to tell the Grafana Helm chart about your ConfigMap:

```yaml
grafana:
  volumes:
  - name: example-dashboards-volume
    mountPath: /grafana-dashboard-definitions/example
    configMap: example-dashboards
```

Using a Secret instead of a ConfigMap works identically, just specify `secretName` instead of `configMap` in the `volumes` section.

Remember that you still need a custom dashboard provider to make Grafana load your new dashboards.

## Custom Resource State Metrics

kube-state-metrics helm chart deployed on a seed/master cluster can be extended to get state metrics of [custom resources](https://github.com/kubernetes/kube-state-metrics/blob/main/docs/metrics/extend/customresourcestate-metrics.md) as well. For this, we need to enable `customResourceState` & pass the configuration for custom state metrics.

```yaml
kubeStateMetrics:
  customResourceState:
    enabled: true
    config:
      spec:
        resources:
          - groupVersionKind:
              group: helm.toolkit.fluxcd.io
              version: "v2beta2"
              kind: HelmRelease
            metricNamePrefix: gotk
            metrics:
              - name: "resource_info"
                help: "The current state of a GitOps Toolkit resource."
                each:
                  type: Info
                  info:
                    labelsFromPath:
                      name: [metadata, name]
                labelsFromPath:
                  exported_namespace: [metadata, namespace]
                  suspended: [spec, suspend]
                  ready: [status, conditions, "[type=Ready]", status]
```

Along with this, the RBAC rules also need to be updated to allow kube-state-metrics to perform the necessary operations on the custom resource(s).

```yaml
kubeStateMetrics:
  rbac:
    extraRules:
      - apiGroups:
          - helm.toolkit.fluxcd.io
        resources:
          - helmreleases
        verbs: [ "list", "watch" ]
```

For configuring more custom resources, refer to the [example kube-state-metrics-config.yaml](https://github.com/fluxcd/flux2-monitoring-example/blob/main/monitoring/controllers/kube-prometheus-stack/kube-state-metrics-config.yaml).
