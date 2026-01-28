+++
title = "Traffic Flow Visibility"
linkTitle = "Traffic Flow"
weight = 20
+++

For environments requiring centralized visibility into traffic flow — source/destination tracking, service maps, and real-time request tracing — KubeLB integrates with existing service mesh and CNI observability tools.

## Hubble UI

[Hubble](https://docs.cilium.io/en/stable/gettingstarted/hubble_setup/) is the observability layer for [Cilium](https://cilium.io/). When Cilium is the CNI on the KubeLB management cluster, Hubble provides:

- **Service map** — automatic topology visualization of service-to-service communication
- **Real-time traffic flows** — live stream of L3/L4 and L7 network events with source, destination, verdict, and protocol details
- **DNS visibility** — DNS query and response tracking across the cluster
- **HTTP/gRPC flow inspection** — request-level details including method, path, status code, and latency
- **Network policy verdicts** — see which policies allowed or denied traffic

Hubble UI runs as a deployment in the cluster and connects to Hubble Relay for aggregated flow data. For setup instructions, see the [Hubble Getting Started Guide](https://docs.cilium.io/en/stable/gettingstarted/hubble_setup/).

Following are the screenshots of a load balancer resource exposed via KubeLB.

{{< figure src="/img/kubelb/common/monitoring/hubble-overview.png" alt="Hubble UI Service Map" title="Hubble UI — Service Map showing KubeLB traffic flows" >}}

{{< figure src="/img/kubelb/common/monitoring/hubble-kubelb-service.png" alt="Hubble UI Flow Table" title="Hubble UI — Real-time flow table" >}}

## Kiali

[Kiali](https://kiali.io/) is the management console for [Istio](https://istio.io/) service mesh. When Istio is deployed alongside or within KubeLB clusters, Kiali provides:

- **Traffic graph** — real-time visualization of service-to-service traffic with request rates, error rates, and latency
- **Health monitoring** — per-service and per-workload health status derived from Istio telemetry
- **Configuration validation** — detect misconfigurations in VirtualServices, DestinationRules, and other Istio resources
- **Distributed tracing integration** — link to Jaeger/Zipkin traces from the service graph

For installation and configuration, see the [Kiali Installation Guide](https://kiali.io/docs/installation/installation-guide/).
