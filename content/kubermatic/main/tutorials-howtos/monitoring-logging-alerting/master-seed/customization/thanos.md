+++
linkTitle = "Thanos"
title = "Thanos integration with prometheus"
date = 2023-07-20T09:44:15+05:30
weight = 20
+++

This page explains how we can integrate [Thanos](https://thanos.io/) long term storage of metrics with KKP seed Prometheus

## Pre-requsites
1. Helm is installed.
1. KKP v2.22.4+ is installed in the cluster.
1. KKP Prometheus chart has been deployed in each seed where you want to store long term metrics

## Integration steps
Below page outlines
1. Installation of Thanos components in your Kubernetes cluster via Helm chart
1. Customization of KKP Prometheus chart to augment Prometheus pod with Thanos sidecar
1. Customization of KKP Prometheus chart values to monitor and get alerts for Thanos components

## Install thanos chart

You can install the Thanos Helm chart from Bitnami chart repository
```shell
HELM_EXPERIMENTAL_OCI=1 helm upgrade --install thanos \
  --namespace monitoring --create-namespace\
   --version 12.8.6 \
  -f thanos-values.yaml \
  oci://registry-1.docker.io/bitnamicharts/thanos
```

### Basic Thanos Customization file
You can configure Thanos to store the metrics in any s3 compatible storage as well as many other popular cloud storage solutions.

Below yaml snippet uses Azure Blob storage configuration. You can refer to all [supported object storage configurations](https://thanos.io/tip/thanos/storage.md/#supported-clients).

```yaml
# thanos-values.yaml
# Refer https://artifacthub.io/packages/helm/bitnami/thanos for more configuration options
objstoreConfig: |-
  type: AZURE
  config:
    storage_account: "<AZ_STORAGE_ACCT>"
    storage_account_key: "<AZ_STORAGE_ACCT_KEY>"
    container: "<AZ blob container name>"
    max_retries: 0
compactor:
  enabled: true
  persistence:
    enabled: true
    # size: 80Gi
  retentionResolutionRaw: 2d
  retentionResolution5m: 2w
  retentionResolution1h: 60d
metrics:
  enabled: true
storegateway:
  enabled: true
```


## Augment prometheus to use Thanos sidecar

In order to receive metrics from Prometheus into Thanos, Thanos provides two mechanisms.
1. [Thanos Sidecar](https://thanos.io/tip/components/sidecar.md/)
1. [Thanos Receiver](https://thanos.io/tip/components/receive.md/)

Thanos sidecar is a much simpler and less resource heavy approach. You can learn more about Thanos components [here](https://thanos.io/tip/thanos/quick-tutorial.md/#components). Due to simplicity, we have outlined how to integrate the Thanos sidecar in the existing Prometheus chart configuration.

Use below changes in `prometheus` block in `values.yaml` to add Thanos sidecar into existing Prometheus pods.

```yaml
prometheus:
  externalLabels:
    # .... existing external labels, if any
    replica: ${POD_NAME}
  env:
    # ... existing env vars, if any
    - name: POD_NAME
      valueFrom:
        fieldRef:
          fieldPath: metadata.name
  podLabels:
    # ... existing pod labels, if any
    thanos.io/store-api: 'true'
  extraArgs:
    # .... existing extra args, if any
    storage.tsdb.min-block-duration: 2h
    storage.tsdb.max-block-duration: 2h
    enable-feature: expand-external-labels
  volumes:
    # .... existing volumes already configured, if any
    - name: thanos
      mountPath: /etc/thanos
      secretName: prometheus-thanos

  # Add thanos sidecar to prometheus pods
  sidecarContainers:
    thanos:
      args:
      - sidecar
      - --tsdb.path=/prometheus
      - --prometheus.url=http://localhost:9090
      - --objstore.config-file=/etc/thanos/objstore.yaml
      # Do not turn on thanos reloader since default prometheus already includes configmap-reloader
      # - --reloader.config-file=/etc/prometheus/config/prometheus.yaml
      # - --reloader.config-envsubst-file=/etc/prometheus-shared/prometheus.yaml
      env:
      - name: POD_NAME
        valueFrom:
          fieldRef:
            fieldPath: metadata.name
      image: quay.io/thanos/thanos:v0.31.0
      livenessProbe:
        httpGet:
          path: /-/healthy
          port: http-sidecar
      ports:
      - name: http-sidecar
        containerPort: 10902
      - name: grpc
        containerPort: 10901
      readinessProbe:
        httpGet:
          path: /-/ready
          port: http-sidecar
      resources:
        limits:
          cpu: 300m
          memory: 2Gi
        requests:
          cpu: 100m
          memory: 32Mi
      volumeMounts:
      - name: db
        mountPath: /prometheus
        readOnly: false
        subPath: prometheus-db
      - name: config
        mountPath: /etc/prometheus/config
      - name: thanos
        mountPath: /etc/thanos
```


## Add scraping and alerting rules to monitor thanos itself

To monitor Thanos effectively, we must scrape the Thanos components and define some Prometheus alerting rules to get notified when Thanos is not working correctly. Below sections outline changes in `prometheus` section of `values.yaml` to enable such scraping and alerting for Thanos components.

### Scraping config
Add below `scraping` configuration to scrape the Thanos sidecar as well as various Thanos components deployed via helm chart.

```yaml
prometheus:
  scraping:
    configs:
    # Existing scrap configs
    - job_name: thanos-sidecar
      kubernetes_sd_configs:
      - role: pod
      relabel_configs:
      # drop node-exporters, as they need HTTPS scraping with credentials
      - source_labels: [__meta_kubernetes_namespace, __meta_kubernetes_pod_label_app_kubernetes_io_name, __meta_kubernetes_pod_label_app_kubernetes_io_instance, __meta_kubernetes_pod_container_name, __meta_kubernetes_pod_container_port_name]
        regex: '{{ .Release.Namespace }};prometheus;{{ template "name" . }};thanos;http-sidecar'
        action: keep
      # - source_labels: [__address__]
      #   action: replace
      #   regex: (.*)
      #   replacement: $1:10902
      #   target_label: __address__
      - action: labelmap
        regex: __meta_kubernetes_pod_label_(.+)
      - source_labels: [__meta_kubernetes_namespace]
        regex: (.*)
        target_label: namespace
        replacement: $1
        action: replace
      - source_labels: [__meta_kubernetes_pod_name]
        regex: (.*)
        target_label: pod
        replacement: $1
        action: replace
```

### Alerting Rules
Add Below configmap and then refer this configMap in KKP Prometheus chart's `values.yaml` customization

```yaml
# values.yaml customization
prometheus:
  ruleFiles:
    - /etc/prometheus/rules/thanos/thanos-*.yaml
  volumes:
    - name: thanos-alerting-rules
      mountPath: /etc/prometheus/rules/thanos
      configMap: thanos-alerting-rules-configmap
````

The configmap
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: thanos-alerting-rules-configmap
  namespace: monitoring
data:
  thanos-rules.yml: |
    groups:
      - name: thanos
        rules:
          - alert: ThanosSidecarDown
            annotations:
              message: The Thanos sidecar in `{{ $labels.namespace }}/{{ $labels.pod }}` is down.
              runbook_url: https://docs.kubermatic.com/kubermatic/master/cheat-sheets/alerting-runbook/#alert-thanossidecardown
            expr: thanos_sidecar_prometheus_up != 1
            for: 5m
            labels:
              severity: warning
              resource: "{{ $labels.namespace }}/{{ $labels.pod }}"
              service: thanos

          - alert: ThanosSidecarNoHeartbeat
            annotations:
              message: The Thanos sidecar in `{{ $labels.namespace }}/{{ $labels.pod }}` didn't send a heartbeat in {{ $value }} seconds.
              runbook_url: https://docs.kubermatic.com/kubermatic/master/cheat-sheets/alerting-runbook/#alert-thanossidecardown
            expr: time() - thanos_sidecar_last_heartbeat_success_time_seconds > 60
            for: 3m
            labels:
              severity: warning
              resource: "{{ $labels.namespace }}/{{ $labels.pod }}"
              service: thanos

          - alert: ThanosCompactorManyRetries
            annotations:
              message: The Thanos compactor in `{{ $labels.namespace }}` is experiencing a high retry rate.
              runbook_url: https://docs.kubermatic.com/kubermatic/master/cheat-sheets/alerting-runbook/#alert-thanoscompactormanyretries
            expr: sum(rate(thanos_compact_retries_total[5m])) > 0.01
            for: 10m
            labels:
              severity: warning
              resource: "{{ $labels.namespace }}/{{ $labels.pod }}"
              service: thanos
            runbook:
              steps:
                - Check the `thanos-compact` pod's logs.

          - alert: ThanosShipperManyDirSyncFailures
            annotations:
              message: The Thanos shipper in `{{ $labels.namespace }}/{{ $labels.pod }}` is experiencing a high dir-sync failure rate.
              runbook_url: https://docs.kubermatic.com/kubermatic/master/cheat-sheets/alerting-runbook/#alert-thanosshippermanydirsyncfailures
            expr: sum(rate(thanos_shipper_dir_sync_failures_total[5m])) > 0.01
            for: 10m
            labels:
              severity: warning
              resource: "{{ $labels.namespace }}/{{ $labels.pod }}"
              service: thanos
            runbook:
              steps:
                - Check the `thanos` containers's logs inside the Prometheus pod.

          - alert: ThanosManyPanicRecoveries
            annotations:
              message: The Thanos component in `{{ $labels.namespace }}/{{ $labels.pod }}` is experiencing a panic recovery rate.
              runbook_url: https://docs.kubermatic.com/kubermatic/master/cheat-sheets/alerting-runbook/#alert-thanosmanypanicrecoveries
            expr: sum(rate(thanos_grpc_req_panics_recovered_total[5m])) > 0.01
            for: 10m
            labels:
              severity: warning
              resource: "{{ $labels.namespace }}/{{ $labels.pod }}"
              service: thanos

          - alert: ThanosManyBlockLoadFailures
            annotations:
              message: The Thanos store in `{{ $labels.namespace }}/{{ $labels.pod }}` is experiencing a many failed block loads.
              runbook_url: https://docs.kubermatic.com/kubermatic/master/cheat-sheets/alerting-runbook/#alert-thanosmanyblockloadfailures
            expr: sum(rate(thanos_bucket_store_block_load_failures_total[5m])) > 0.01
            for: 10m
            labels:
              severity: warning
              resource: "{{ $labels.namespace }}/{{ $labels.pod }}"
              service: thanos

          - alert: ThanosManyBlockDropFailures
            annotations:
              message: The Thanos store in `{{ $labels.namespace }}/{{ $labels.pod }}` is experiencing a many failed block drops.
              runbook_url: https://docs.kubermatic.com/kubermatic/master/cheat-sheets/alerting-runbook/#alert-thanosmanyblockdropfailures
            expr: sum(rate(thanos_bucket_store_block_drop_failures_total[5m])) > 0.01
            for: 10m
            labels:
              severity: warning
              resource: "{{ $labels.namespace }}/{{ $labels.pod }}"
              service: thanos
          - alert: ThanosCompactHalted
            annotations:
              message: 'Thanos Compactor has halted for more than 1 minute. This will create problems for long term metric data storage.
                Review compactor logs and delete the offending storage block!'
            expr: thanos_compact_halted{} != 0
            for: 1m
            labels:
              severity: warning

```
