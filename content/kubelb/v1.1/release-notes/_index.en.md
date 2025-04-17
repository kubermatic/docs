+++
title = "Release Notes"
date = 2024-03-15T00:00:00+01:00
weight = 70
+++

## Kubermatic KubeLB v1.1

- [v1.1.0](#v110)
  - [Community Edition](#community-edition)
  - [Enterprise Edition](#enterprise-edition)
- [v1.1.1](#v111)
- [v1.1.2](#v112)
- [v1.1.3](#v113)
- [v1.1.4](#v114)

## v1.1.4

**GitHub release: [v1.1.4](https://github.com/kubermatic/kubelb/releases/tag/v1.1.4)**

### Features

- KubeLB will now automatically add `tenant-` prefix to cluster/tenant name if it was not provided by the user. ([#75](https://github.com/kubermatic/kubelb/pull/75))

### Bug or Regression

- Fix an issue with KubeLB not respecting the already allocated NodePort in the management cluster for load balancers with large amount of open Nodeports. ([#91](https://github.com/kubermatic/kubelb/pull/91))
- Before removing RBAC for tenant, ensure that all routes, load balancers, and syncsecrets are cleaned up. ([#92](https://github.com/kubermatic/kubelb/pull/92))
- Don't modify IngressClassName if it's not set in the configuration. ([#88](https://github.com/kubermatic/kubelb/pull/88))

### Other (Cleanup, Flake, or Chore)

- Sort IPs in `addresses` Endpoint to reduce updates. ([#93](https://github.com/kubermatic/kubelb/pull/93))

**Full Changelog**: <https://github.com/kubermatic/kubelb/compare/v1.1.3...v1.1.4>

## v1.1.3

**GitHub release: [v1.1.3](https://github.com/kubermatic/kubelb/releases/tag/v1.1.3)**

### Bug or Regression

- Fix a bug where service annotations were not being propagated. ([#82](https://github.com/kubermatic/kubelb/pull/82))

**Full Changelog**: <https://github.com/kubermatic/kubelb/compare/v1.1.2...v1.1.3>

## v1.1.2

**GitHub release: [v1.1.2](https://github.com/kubermatic/kubelb/releases/tag/v1.1.2)**

### Bug or Regression

- Annotation configuration for tenant has a higher precedence than the global annotation configuration. ([#66](https://github.com/kubermatic/kubelb/pull/66))

#### Other (Cleanup, Flake, or Chore)

- Use `quay.io/brancz/kube-rbac-proxy` to fetch kube-rbac-proxy. ([#65](https://github.com/kubermatic/kubelb/pull/65))

**Full Changelog**: <https://github.com/kubermatic/kubelb/compare/v1.1.1...v1.1.2>

## v1.1.1

**GitHub release: [v1.1.1](https://github.com/kubermatic/kubelb/releases/tag/v1.1.1)**

### Bug or Regression

- Fix a bug that prevented multiple load balancers from a single tenant to be routed correctly.([#62](https://github.com/kubermatic/kubelb/pull/62))

**Full Changelog**: <https://github.com/kubermatic/kubelb/compare/v1.1.0...v1.1.1>

## v1.1.0

**GitHub release: [v1.1.0](https://github.com/kubermatic/kubelb/releases/tag/v1.1.0)**

### Highlights

#### Community Edition(CE)

- Support for Layer 7 Load Balancing has been introduced. KubeLB now supports Ingress and Gateway API resources and can act as an ingress and gateway API controller for it's distributed agents/consumers. Ingress, Gateway, HTTPRoute, and GRPCRoute are the supported resources.
- Tenants can now limit KubeLB to manage LB services based on LoadBalancerClass `kubelb`.

#### Enterprise Edition(EE)

- Fine-grain control over allowed API resources, limits for 3rd party resources, and more.
- Manage DNS and certificates for customers in an automated yet controlled manner.
- Support for Alpha/Beta features from Gateway API.
- Support for configuring multiple, can be limited, gateways per tenant.

### Community Edition

#### Urgent Upgrade Notes

- Tenant registration has now been automated. The `Namespace` resource with `kubelb.k8c.io/managed-by: kubelb` is no longer used for tenant registration. Instead, the `Tenant` resource should be used. Automated migration are in place which would convert the `Namespace` resources to `Tenant` resources and no manual actions are required by the admins. ([#36](https://github.com/kubermatic/kubelb/pull/36)) ([#32](https://github.com/kubermatic/kubelb/pull/32))
- Dedicated topology for Envoy Proxy has been deprecated and would default to Shared, if used. ([#37](https://github.com/kubermatic/kubelb/pull/37))

#### Deprecation

- Dedicated topology for Envoy Proxy has been deprecated and would default to Shared, if used. ([#37](https://github.com/kubermatic/kubelb/pull/37))

#### API Changes

- Add new API for Routes; routes are used to define layer 7 that is application load balancing configurations ([#16](https://github.com/kubermatic/kubelb/pull/16))
- Add new API for Tenants; tenant represent a consumer in the management cluster ([#32](https://github.com/kubermatic/kubelb/pull/32))
- Add new API for SyncSecrets; syncsecret resource has been introduced that can be used to synchronize a secret from tenant to LB cluster ([#42](https://github.com/kubermatic/kubelb/pull/42))

#### Features

- Support to limit KubeLB to manage LB services based on LoadBalancerClass ([#18](https://github.com/kubermatic/kubelb/pull/18))
- Upgrade envoy proxy to v1.30.1 ([#19](https://github.com/kubermatic/kubelb/pull/19))
- Support for Layer 7 Load Balancing of ingress resources. KubeLB now supports Ingress resources and can act as an ingress controller for it's distributed agents/consumers ([#22](https://github.com/kubermatic/kubelb/pull/22))
- Support for Layer 7 Load Balancing of Gateway API resources. KubeLB now supports Gateway API resources and can act as a gateway API controller for it's distributed agents/consumers. Gateway, HTTPRoute, and GRPCRoute are the supported resources. ([#28](https://github.com/kubermatic/kubelb/pull/28))
- Tenants can now be registered using the `Tenant` CRD. This would create all the necessary resources such as namespace, RBAC, etc. and additionally `kubelb-ccm-kubeconfig` secret that contains the tenant scoped kubeconfig, to be used by the kubeLB CCM. ([#32](https://github.com/kubermatic/kubelb/pull/32))
- Flags to enable/disable controllers for the CCM. This can be used to ignore resources like Ingress, GRPCRoute, HTTPRoute, Gateway in the CCM. ([#37](https://github.com/kubermatic/kubelb/pull/37))
- Upgrade to Envoy Proxy v1.31.0. ([#37](https://github.com/kubermatic/kubelb/pull/37))
- Add additional printer columns for loadbalancer and routes. ([#37](https://github.com/kubermatic/kubelb/pull/37))
- Add option to disable Gateway API. ([#37](https://github.com/kubermatic/kubelb/pull/37))
- Feature: fine-grained control over tenant and global configurations for components such as Ingress, Gateway API, LoadBalancer. ([#41](https://github.com/kubermatic/kubelb/pull/41))
- Secret synchronizer controller can be enabled by the flag `enable-secret-synchronizer` for CCM. Enable automatically converting Secrets labeled with `kubelb.k8c.io/managed-by: kubelb` to SyncSecrets.  This controller requires elevated access to secrets in the tenant cluster to perform CRUD operations. ([#42](https://github.com/kubermatic/kubelb/pull/42))
- Upgrade to Go 1.22.6. ([#48](https://github.com/kubermatic/kubelb/pull/48))
- Tenant registration has now been automated. The `Namespace` resource with `kubelb.k8c.io/managed-by: kubelb` is no longer used for tenant registration. Instead, the `Tenant` resource should be used. Automated migration are in place which would convert the `Namespace` resources to `Tenant` resources and no manual actions are required by the admins. ([#36](https://github.com/kubermatic/kubelb/pull/36)) ([#32](https://github.com/kubermatic/kubelb/pull/32))
- Upgrade to Go 1.23.0 ([#51](https://github.com/kubermatic/kubelb/pull/51))

#### Design

- Restructure repository and introduce internal package ([#8](https://github.com/kubermatic/kubelb/pull/8))

#### Bug or Regression

- Enable production configuration for logger ([#5](https://github.com/kubermatic/kubelb/pull/5))
- Remove un-required validation for LB port protocol ([#14](https://github.com/kubermatic/kubelb/pull/14))
- Fix status propagation and global topology ([#54](https://github.com/kubermatic/kubelb/pull/54))

#### Other (Cleanup, Flake, or Chore)

- Upgrade to controller-runtime v0.18 ([#17](https://github.com/kubermatic/kubelb/pull/17))
- Fix RBAC in helm charts for new APIs. ([#37](https://github.com/kubermatic/kubelb/pull/37))
- Script to generate RBAC for tenant has been removed as the process has now been automated. ([#39](https://github.com/kubermatic/kubelb/pull/39))
- Remove enovy-proxy finalizer from load balancers. ([#46](https://github.com/kubermatic/kubelb/pull/46))
- Scope down Gateway to routes from the same namespace. ([#45](https://github.com/kubermatic/kubelb/pull/45))
- Gateway API is disabled by default for CCM and manager. ([#55](https://github.com/kubermatic/kubelb/pull/55))

**Full Changelog**: <https://github.com/kubermatic/kubelb/compare/v1.0.0...v1.1.0>

### Enterprise Edition

**Enterprise Edition includes everything from Community Edition and more. The release notes below are for changes specific to just the Enterprise Edition.**

#### EE Features

- Support for limiting the number of LoadBalancers per tenant and globally for the management cluster.
- Support for limiting the number of Gateways per tenant and globally for the management cluster.
- KubeLB EE supports Gateway API alpha/beta features such as TLSRoute, TCPRoute, and UDPRoute.
- Tenants can have multiple gateways instead of just one in the CE edition.
- Automation for DNS has been added. Admins can configure allowed domains per tenant and KubeLB would automatically create DNS records for the tenant.
- Automation for Certificates has been added. Admins can configure allowed domains per tenant and KubeLB would automatically create DNS records for the tenant. Default Cluster Issuer can also be configured at tenant or Global level, which will be used by KubeLB if the tenant resrources does not have a custom issuer configured.
- Introduce `kubelb.k8c.io/manage-certificates` and `kubelb.k8c.io/manage-dns` annotations that can be used to automate certificate and DNS management for resources.
- Fine grain control over the API resources that will be managed for the tenants. For example, Ingress, Gateways, GRPCRoute, HTTPRoute, TLSRoute, TCPRoute, UDPRoute, etc. can all be individually disabled/enabled per tenant or Globally for the management cluster.
