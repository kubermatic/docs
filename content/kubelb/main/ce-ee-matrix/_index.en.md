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
| Gateway API beta/alpha(TLS/TCP/UDP routes)                | ✔️                       | ❌                       |
| Multiple Gateways                  | ✔️                        | ❌                        |
| DNS automation                  | ✔️                        | ❌                       |
| Certificate Management                  | ✔️                        | ❌                       |
| Limits for LoadBalancers, Gateways                 | ✔️                        | ❌                       |
