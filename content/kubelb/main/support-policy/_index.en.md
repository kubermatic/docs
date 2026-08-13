+++
title = "Support Policy"
date = 2024-03-15T00:00:00+01:00
description = "What Enterprise Edition support covers, what it does not, and how community support works."
weight = 45
+++

KubeLB Community Edition is free to use and licensed under the [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0).

Enterprise Edition requires an active [KubeLB subscription](https://www.kubermatic.com/products/kubelb/), which includes SLA-backed support from the Kubermatic engineering team.

## Enterprise Edition Support

By default, support covers:

- Debugging for issues related to KubeLB
- Enhancing documentation
- Fixing bugs that block the usage of the platform

What is not covered:

- Issues related to the underlying Kubernetes cluster and infrastructure.
- Custom configurations for the underlying product suite including ingress-nginx, Envoy Gateway, external-dns, and cert-manager. KubeLB provides default configurations and an integration for those products.
- Issues related to misconfigured Ingress or Gateway API resources by the KubeLB users (tenant clusters). For example, misconfigured TLS certificates or missing hostnames in the Ingress or HTTPRoute resources.

{{% notice info %}}
For support offerings beyond the defaults above, [contact the Kubermatic sales team](mailto:sales@kubermatic.com).
{{% /notice %}}
