+++
title = "Observability"
linkTitle = "Observability"
date = 2023-10-27T10:07:15+02:00
weight = 7
+++

KubeLB is a mission-critical component in the Kubernetes ecosystem, and its observability is crucial for ensuring the stability and reliability of the platform. This guide will walk you through the steps to enable and configure observability for KubeLB.

KubeLB in itself doesn't restrict the platform providers to certain observability tools. Since we are well aware that different customers will have different Monitoring, logging, alerting, and tracing etc. stacks deployed which are based on their  own requirements. Although it does offer Grafana dashboards that can be plugged into your existing monitoring stack.

## Grafana Dashboard

[Grafana Dashboard](https://github.com/kubermatic/kubelb-ee/tree/release/v1.1/docs/dashboards)

## Recommended Tools

Our suggested tools for observability are:

1. [Gateway Observability](https://gateway.envoyproxy.io/docs/tasks/observability/gateway-observability/): This is the default MLA stack provided by Envoy Gateway. Since it's designed specifically for Envoy Gateway and Gateway APIs, it offers a comprehensive set of observability features tailored to the needs of Envoy Gateway users.
2. [Hubble UI](https://docs.cilium.io/en/stable/gettingstarted/hubble_setup/): When using Cilium as the CNI, Hubble UI provides a user-friendly interface for visualizing and analyzing network traffic in your Kubernetes cluster.
3. [Kiali](https://kiali.io/docs/installation/installation-guide/): When using Istio as the service mesh, Kiali is a powerful tool for visualizing and analyzing the traffic flow within your Istio-based applications.
