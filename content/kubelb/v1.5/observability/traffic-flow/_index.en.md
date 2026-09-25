+++
title = "Traffic Flow Visibility"
linkTitle = "Traffic Flow"
date = 2026-07-29T00:00:00+02:00
description = "Use Hubble or Kiali to visualize traffic through KubeLB and its tenant backends."
weight = 20
aliases = ["/kubelb/v1.5/tutorials/observability/traffic-flow/"]
+++

For centralized visibility into traffic flow (source/destination tracking, service maps, and real-time request tracing), KubeLB integrates with existing service mesh and CNI observability tools.

## Hubble UI

[Hubble](https://docs.cilium.io/en/stable/gettingstarted/hubble_setup/) is the observability layer for [Cilium](https://cilium.io/). When Cilium is the CNI on the KubeLB management cluster, Hubble shows how traffic enters through KubeLB's Envoy Proxy and reaches tenant backends: a service map of service-to-service communication, live L3/L4 and L7 flow streams with source, destination, and verdict, and request-level HTTP/gRPC details.

Hubble UI runs as a deployment in the cluster and connects to Hubble Relay for aggregated flow data. For setup instructions, see the [Hubble Getting Started Guide](https://docs.cilium.io/en/stable/gettingstarted/hubble_setup/).

The following screenshots show a load balancer resource exposed via KubeLB.

{{< figure src="/img/kubelb/common/monitoring/hubble-overview.png" alt="Hubble UI Service Map" title="Hubble UI: Service Map showing KubeLB traffic flows" >}}

{{< figure src="/img/kubelb/common/monitoring/hubble-kubelb-service.png" alt="Hubble UI Flow Table" title="Hubble UI: Real-time flow table" >}}

## Kiali

[Kiali](https://kiali.io/) is the management console for the [Istio](https://istio.io/) service mesh. When Istio is deployed alongside or within KubeLB clusters, Kiali provides a real-time traffic graph with request rates, error rates, and latency for the services behind KubeLB, plus links to distributed traces.

For installation and configuration, see the [Kiali Installation Guide](https://kiali.io/docs/installation/installation-guide/).
