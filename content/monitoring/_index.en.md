+++
title = "Monitoring"
date = 2018-04-28T12:07:15+02:00
weight = 23
chapter = true
pre = "<b>5. </b>"
+++

### Chapter 5

# Monitoring

Kubermatic uses [Prometheus](https://prometheus.io) and its [Alertmanager](https://prometheus.io/docs/alerting/alertmanager/) for monitoring and alerting. Dashboarding is done with [Grafana](https://grafana.com).

Out of the box Prometheus starts monitoring all Kubernetes components of [seed](/concepts/seed_cluster/) and [customer](/concepts/customer_cluster/) clusters.

# Grafana

In a default Kubermatic installation we ship Grafana as _readonly_ metrics dashboard.
When working with Grafana please keep in mind, that __ALL CHANGES__ done using the Grafana UI (like adding datasources, etc.) __WILL NOT BE PERSISTED__. Dashboards, graphs, datasources, etc. will be defined using the Helm chart.