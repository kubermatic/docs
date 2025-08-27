+++
title = "Community vs Enterprise Edition"
date = 2024-03-15T00:00:00+01:00
weight = 10
+++

KubeLB is available in two versions: Community and Enterprise.

- **Community Edition (CE)**: Free, open source version that is available to the public. The CE is stable, production ready software available at <https://github.com/kubermatic/kubelb>
- **Enterprise Edition (EE)**: Only available through an active subscription. In addition to the commercial support, SLAs for the product, the EE version contains a larger feature set in comparison to the CE version.

{{% notice note %}}
[Get in touch with Kubermatic](mailto:sales@kubermatic.com) to find out more about the KubeLB Enterprise offering.
{{% /notice %}}

## Feature Matrix

| Feature                       | EE (Enterprise Edition) | CE (Community Edition) |
|-------------------------------|--------------------------|-------------------------|
| Ingress                 | ✔️                        | ✔️                       |
| Gateway API v1                  | ✔️                        | ✔️                       |
| Bring your own secrets(certificates)                  | ✔️                        | ✔️                       |
| Tunneling support through CLI | ✔️ | ❌ |
| Gateway API beta/alpha(TLS/TCP/UDP routes)                | ✔️                       | ❌                       |
| Multiple Gateways                  | ✔️                        | ❌                        |
| DNS automation                  | ✔️                        | ❌                       |
| Certificate Management                  | ✔️                        | ❌                       |
| Limits for LoadBalancers, Gateways                 | ✔️                        | ❌                       |

{{% notice note %}}
KubeLB supports the following products for Ingress and Gateway API resources:

- [Ingress-nginx](https://kubernetes.github.io/ingress-nginx/) for **Ingress** resources.
- [Envoy Gateway](https://gateway.envoyproxy.io/) is supported for **Gateway API** resources.

While other products might work for Ingress and Gateway API resources, we are not testing them and can't guarantee the compatibility.
{{% /notice %}}

## Support Policy

For support policy, please refer to the [KubeLB Support Policy](../support-policy/).
