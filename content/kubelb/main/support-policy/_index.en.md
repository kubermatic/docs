+++
title = "Support Policy"
date = 2024-03-15T00:00:00+01:00
weight = 40
+++

KubeLB has an open-source community edition and an enterprise edition. The community edition is free to use and is licensed under the [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0).

The enterprise edition requires an active [KubeLB subscription](https://www.kubermatic.com/products/kubelb/), which includes SLA-backed support from the Kubermatic engineering team.

## Enterprise Edition Support

As a default, our support covers the following:

- Debugging for issues related to KubeLB
- Enhancing documentation
- Fixing bugs that block the usage of the platform

What is not covered:

- Issues related to the underlying Kubernetes cluster and infrastructure.
- Custom configurations for the underlying product suite including ingress-nginx, Envoy Gateway, External DNS, and Cert Manager. KubeLB only provides you with sane default configurations and an integration for those products.
- Issues related to misconfigured Ingress or Gateway API resources by the KubeLB users(tenant clusters). For example, misconfigured TLS certificates or missing hostnames in the Ingress or HTTPRoute resources.

{{% notice info %}}
For support offerings beyond the defaults above, [contact the Kubermatic sales team](mailto:sales@kubermatic.com).
{{% /notice %}}
