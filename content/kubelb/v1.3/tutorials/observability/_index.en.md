+++
title = "Observability"
linkTitle = "Observability"
date = 2023-10-27T10:07:15+02:00
weight = 9
+++

KubeLB is a mission-critical component in the Kubernetes ecosystem, and its observability is crucial for ensuring the stability and reliability of the platform. This guide covers metrics collection, Grafana dashboards, and traffic flow visibility for KubeLB.

KubeLB does not restrict platform providers to specific observability tools. Different environments will have their own monitoring, logging, alerting, and tracing stacks. KubeLB integrates with Prometheus for metrics and provides pre-built Grafana dashboards that plug into your existing monitoring stack.

{{% children depth=5 %}}
{{% /children %}}
