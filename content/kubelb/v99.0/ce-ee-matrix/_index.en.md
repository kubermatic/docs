+++
title = "Community vs Enterprise Edition"
date = 2024-03-15T00:00:00+01:00
weight = 10
+++

KubeLB is available in two editions:

- **Community Edition (CE)**: Free, open source version that is available to the public. The CE is stable, production ready software available at <https://github.com/kubermatic/kubelb>
- **Enterprise Edition (EE)**: Only available through an active subscription. In addition to the commercial support, SLAs for the product, the EE version contains a larger feature set in comparison to the CE version.

{{% notice note %}}
[Get in touch with Kubermatic](mailto:sales@kubermatic.com) to find out more about the KubeLB Enterprise offering.
{{% /notice %}}

## Feature Matrix

| Feature | Community Edition | Enterprise Edition |
|---------|:--:|:--:|
| **Load Balancing** |||
| TCP/UDP Load Balancing | ✔️ | ✔️ |
| Ingress | ✔️ | ✔️ |
| **Gateway API** |||
| HTTPRoute, GRPCRoute | ✔️ | ✔️ |
| TCPRoute, UDPRoute, TLSRoute | ❌ | ✔️ |
| Multiple Gateways per tenant | ❌ | ✔️ |
| Traffic Policies (Client/Backend) | ❌ | ✔️ |
| **Security** |||
| Web Application Firewall (Alpha) | ❌ | ✔️ |
| **Management** |||
| Ingress to Gateway API Migration (Beta) | ✔️ | ✔️ |
| Bring your own certificates | ✔️ | ✔️ |
| DNS automation | ❌ | ✔️ |
| Certificate management | ❌ | ✔️ |
| Gateway/LoadBalancer limits | ❌ | ✔️ |
| CLI tunneling | ❌ | ✔️ |
| **Observability** |||
| Prometheus metrics | ✔️ | ✔️ |
| Grafana dashboards | ✔️ | ✔️ |
| **Supply Chain Security** |||
| Artifact signing (Cosign) | ✔️ | ✔️ |
| SBOMs | ✔️ | ✔️ |
| Vulnerability scanning | ✔️ | ✔️ |

{{% notice note %}}
**Supported implementations:**

- **Ingress**: [ingress-nginx](https://kubernetes.github.io/ingress-nginx/)
- **Gateway API**: [Envoy Gateway](https://gateway.envoyproxy.io/)

While other products might work for Ingress and Gateway API resources, we are not testing them and can't guarantee the compatibility.
{{% /notice %}}

## Supported Gateway API Features

### Community Edition

- Gateway (Single Instance per tenant)
- HTTPRoute
- GRPCRoute

### Enterprise Edition

- Gateway (Multiple Instances per tenant with limit support)
- HTTPRoute
- GRPCRoute
- TCPRoute
- UDPRoute
- TLSRoute
- ClientTrafficPolicy (Envoy Gateway)
- BackendTrafficPolicy (Envoy Gateway)

## Support Policy

See [KubeLB Support Policy]({{< relref "../support-policy" >}}).
