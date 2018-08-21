+++
title = "Architecture"
date = 2018-08-17T12:07:15+02:00
weight = 0
+++

This page describes the various monitoring components in a Kubermatic stack and how they work together to provide metrics to manage the Kubernetes clusters.

## Overview

There is a single Prometheus service in each seed cluster's `monitoring` namespace, which is responsible for monitoring the cluster's components (like the Kubermatic controller manager) and serves as the main datasource for the accompanying Grafana service. Besides that there is a Prometheus inside each user cluster namespace, which in turn monitors the Kubernetes control plane (apiserver, controller manager, etcd cluster etc.) of that customer cluster. The seed-level Prometheus scrapes all customer-cluster Prometheus instances and combines their metrics for creating the dashboards in Grafana.

Along the seed-level Prometheus, there is a single alertmanager running in the seed, which _all_ Prometheus instances are using to relay their alerts (i.e. the Prometheus inside the customer clusters send their alerts to the seed cluster's alertmanager).

![Monitoring architecture diagram](/img/monitoring/architecture/architecture.png)

## Federation

The seed-level Prometheus uses Prometheus' native federation mechanism to scrape the customer Prometheus instances. To prevent excessive amountf of data in the seed, it will however only scrape a few selected metrics, namely

* `up`
* `machine_controller_*`
* all metrics labelled with `kubermatic=federate`

The last of these options is used for pre-aggregated metrics, which combine highly detailed time series (like from etcd) into smaller, easier to handle metrics that can be readily used inside Grafana.
