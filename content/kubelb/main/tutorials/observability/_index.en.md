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

## Grafana Dashboard

KubeLB provides pre-built Grafana dashboards for monitoring. These dashboards are located in the `dashboards` directory within the Helm charts and can be imported into your existing Grafana instance.

You can find the dashboards in the [kubelb Helm chart](https://github.com/kubermatic/kubelb/tree/release/v1.3/charts/kubelb-manager/dashboards).

## Traffic Flow Visibility

For environments requiring centralized visibility into traffic flow (source/destination tracking), [Hubble UI](https://docs.cilium.io/en/stable/gettingstarted/hubble_setup/) is recommended when using Cilium as the CNI on the KubeLB cluster. Hubble provides a service map and real-time traffic flow visualization, making it easy to track callers and destinations across the cluster.

## Recommended Tools

Our suggested tools for observability are:

1. [Gateway Observability](https://gateway.envoyproxy.io/docs/tasks/observability/gateway-observability/): This is the default MLA stack provided by Envoy Gateway. Since it's designed specifically for Envoy Gateway and Gateway APIs, it offers a comprehensive set of observability features tailored to the needs of Envoy Gateway users.
2. [Hubble UI](https://docs.cilium.io/en/stable/gettingstarted/hubble_setup/): When using Cilium as the CNI, Hubble UI provides a user-friendly interface for visualizing and analyzing network traffic in your Kubernetes cluster.
3. [Kiali](https://kiali.io/docs/installation/installation-guide/): When using Istio as the service mesh, Kiali is a powerful tool for visualizing and analyzing the traffic flow within your Istio-based applications.
