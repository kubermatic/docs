+++
title = "Release Notes"
date = 2024-03-15T00:00:00+01:00
weight = 60
+++

## Kubermatic KubeLB v1.2

- [v1.2.0](#v120)
  - [Community Edition](#community-edition)
  - [Enterprise Edition](#enterprise-edition)

**Full Changelog**: <https://github.com/kubermatic/kubelb/compare/v1.1.0...v1.2.0>

## v1.2.0

**GitHub release: [v1.2.0](https://github.com/kubermatic/kubelb/releases/tag/v1.2.0)**

### Highlights

#### Community Edition(CE)

- Support for Load Balancer Hostname has been introduced. This allows users to specify a hostname for the load balancer.
- Default Annotations can now be configured for services, Ingress, and Gateway API resources in the management cluster.
- KubeLB Addons chart has been introduced to simplify the installation of the required components for the management cluster.
  - Tools such as ingress-nginx, external-dns, cert-manager, etc. can be installed through a single KubeLB management chart through this change.
  - KubeLB Addons chart will ship versions of components that we are actively testing and supporting.
- TenantState API has been introduced to share tenant status with the KubeLB consumers i.e. through CCM or CLI. This simplifies sharing details such as load balancer limit, allowed domains, wildcard domain, etc. with the consumers.
- KubeLB CCM can now install Gateway API CRDs by itself. Hence, removing the need to install them manually.
- KubeLB now maintains the required RBAC attached to the kubeconfig for KKP integration. `kkpintegration.rbac: true` can be used to manage the RBAC using KubeLB helm chart.

#### Enterprise Edition(EE)

- Tunneling support has been introduced in the Management Cluster. The server side and control plane components for tunneling are shipped with Enterprise Edition of KubeLB.
- AI and MCP Gateway Integration has been introduced. As running your AI, MCP, and Agent2Agent toolings alongisde your data plane is a common use case, we are now leveraging [kgateway](https://kgateway.dev/) to solidify the integration with AI, MCP, and Agent2Agent toolings.

### Community Edition

#### API Changes

- Enterprise Edition APIs for KubeLB are now available at k8c.io/kubelb/api/ee/kubelb.k8c.io/v1alpha1 ([#101](https://github.com/kubermatic/kubelb/pull/101))

#### Features

- Support for adding default annotations to the load balancing resources ([#78](https://github.com/kubermatic/kubelb/pull/78))
- KubeLB now maintains the required RBAC attached to the kubeconfig for KKP integration. `kkpintegration.rbac: true` can be used to manage the RBAC using KubeLB helm chart ([#79](https://github.com/kubermatic/kubelb/pull/79))
- Envoy: no_traffic_interval for upstream endpoints health check has been reduced to 5s from the default of 60s. Envoy will start sending health checks to a new cluster after 5s now ([#106](https://github.com/kubermatic/kubelb/pull/106))
- KubeLB CCM will now automatically install Kubernetes Gateway API CRDs using the following flags:
  - --install-gateway-api-crds: That installs and manages the Gateway API CRDs using gateway crd controller.
  - --gateway-api-crds-channel: That specifies the channel for Gateway API CRDs, with possible values of 'standard' or 'experimental'. ([#110](https://github.com/kubermatic/kubelb/pull/110))
- Improve validations for cluster-name in CCM ([#111](https://github.com/kubermatic/kubelb/pull/111))
- Gracefully handle nodes that don't have an IP address assigned while computing Addresses ([#111](https://github.com/kubermatic/kubelb/pull/111))
- LoadBalancer resources can now be directly assigned a hostname/URL ([#113](https://github.com/kubermatic/kubelb/pull/113))
- TenantState API has been introduced to share tenant status with the KubeLB consumers i.e. through CCM or CLI ([#117](https://github.com/kubermatic/kubelb/pull/117))
- Dedicated addons chart has been introduced for KubeLB at `oci://quay.io/kubermatic/helm-charts/kubelb-addons`. ([#122](https://github.com/kubermatic/kubelb/pull/122))
- KubeLB is now built using Go 1.25 ([#126](https://github.com/kubermatic/kubelb/pull/126))
- Update kube-rbac-proxy to v0.19.1 ([#128](https://github.com/kubermatic/kubelb/pull/128))
- Add metallb to kubelb-addons ([#130](https://github.com/kubermatic/kubelb/pull/130))

#### Design

- Restructure repository and make Enterprise Edition APIs available at k8c.io/kubelb/api/ee/kubelb.k8c.io/v1alpha1 ([#101](https://github.com/kubermatic/kubelb/pull/101))

#### Bug or Regression

- Fix annotation handling for services ([#82](https://github.com/kubermatic/kubelb/pull/82))
- Don't modify IngressClassName if it's not set in the configuration ([#88](https://github.com/kubermatic/kubelb/pull/88))
- Fix an issue with KubeLB not respecting the already allocated NodePort in the management cluster for load balancers with large amount of open Nodeports ([#91](https://github.com/kubermatic/kubelb/pull/91))
- Before removing RBAC for tenant, ensure that all routes, load balancers, and syncsecrets are cleaned up ([#92](https://github.com/kubermatic/kubelb/pull/92))
- Update health checks for envoy upstream endpoint:
  - UDP health checking has been removed due to limited supported from Envoy
  - TCP health checking has been updated to perform a connect-only health check ([#103](https://github.com/kubermatic/kubelb/pull/103))
- Use arbitrary ports as target port for load balancer services ([#119](https://github.com/kubermatic/kubelb/pull/119))

#### Other (Cleanup, Flake, or Chore)

- Upgrade to Go 1.24.1 ([#87](https://github.com/kubermatic/kubelb/pull/87))
- Upgrade to EnvoyProxy v1.33.1 ([#87](https://github.com/kubermatic/kubelb/pull/87))
- Sort IPs in `addresses` Endpoint to reduce updates ([#93](https://github.com/kubermatic/kubelb/pull/93))
- KubeLB is now built using Go 1.24.6 ([#118](https://github.com/kubermatic/kubelb/pull/118))
- Add additional columns for TenantState and Tunnel CRDs ([#124](https://github.com/kubermatic/kubelb/pull/124))

**Full Changelog**: <https://github.com/kubermatic/kubelb/compare/v1.1.0...v1.2.0>

### Enterprise Edition

**Enterprise Edition includes everything from Community Edition and more. The release notes below are for changes specific to just the Enterprise Edition.**

#### EE Features

- Default annotations support for Alpha/Beta Gateway API resources like TLSRoute, TCPRoute, and UDPRoute.
- More fine-grained load balancer hostname support.
- Tunneling support has been introduced in the Management Cluster. With the newly introduced KubeLB CLI, users can now expose workloads/applications running in their local workstations or VMs in closed networks to the outside world. Since all the traffic is routed through the KubeLB management cluster, security, observability, and other features are available and applied by default based on your configuration.
- AI and MCP Gateway Integration has been introduced. As running your AI, MCP, and Agent2Agent toolings alongisde your data plane is a common use case, we are now leveraging [kgateway](https://kgateway.dev/) to solidify the integration with AI, MCP, and Agent2Agent toolings.
