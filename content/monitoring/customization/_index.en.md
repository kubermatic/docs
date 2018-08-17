+++
title = "Customization"
date = 2018-08-17T12:07:15+02:00
weight = 0
+++

When it comes to monitoring, no approach fits all usecases. It's exptected that you will want to adjust things to your needs and this page describes the various places where customizations can be applied. In broad terms, there are four main areas that are discussed:

* customer-cluster Prometheus
* seed-cluster Prometheus
* alertmanager rules
* Grafana dashboards

You will want to familiarize yourself with the [basic architecture](/monitoring/architecture/) before reading any further.

## Customer-Cluster Prometheus

The basic source of metrics is the Prometheus inside each customer cluster namespace. By default it will only monitor the control plane of that cluster, but you can configure additional scraping rules to also look at the Kubernetes resources inside the actual customer cluster.

This Prometheus is deployed as part of Kubermatic's cluster creation, which means you cannot directly affect its deployment.

TBD

## Seed-Cluster Prometheus

This Prometheus is primarily used to collect metrics from the customer clusters and then provide those to Grafana. In contrast to the Prometheus mentioned above, this one is deployed via a [Helm](https://helm.sh) chart and you can use Helm's native customization options.

### Labels

To specify additional labels that are sent to the alertmanager whenever an alert occurs, you can add an `externalLabels` element to your `values.yaml` and list your desired labels there:

```yaml
prometheus:
  externalLabels:
    mycustomlabel: a value
    rack: rack17
    location: europe
```

### Rules

Rules include recording rules (for precomputing expensive queries) and alerts. You can add our own rules by adding them to the `values.yaml` like so:

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

## Alertmanager

TBD

## Grafana Dashboards

TBD
