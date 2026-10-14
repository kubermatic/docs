+++
title = "Editions"
date = 2026-10-14T09:00:00+02:00
weight = 14
description = "Choose Community, Enterprise, or Enterprise Advanced and configure the matching SecureGuard images and components."
+++

SecureGuard offers an Apache-2.0 Community edition and two commercial editions.
The Helm chart defaults to `edition: community`. Choose an edition before
enabling the SG Agent or federation broker.

| Capability | Community | Enterprise | Enterprise Advanced |
|---|---|---|---|
| Single-cluster dashboard, resource status, events, and visualization | Yes | Yes | Yes |
| ExternalSecret Sync Now and supported resource deletions | Yes | Yes | Yes |
| OIDC, user impersonation, Kubernetes RBAC, CSRF protection, and secret redaction | Yes | Yes | Yes |
| Cluster onboarding, cluster selector, and fleet-wide views | — | Yes | Yes |
| ESO lifecycle management through the SG Agent | — | Yes | Yes |
| Stale-secret detection, sync history, and remediation hints | — | Yes | Yes |
| Federation resource lists | Read-only | Yes | Yes |
| FederationServer / FederationAuthorization create, edit, and delete | — | Yes | Yes |
| Federation broker deployment | — | — | Yes |

Enterprise and Enterprise Advanced share the commercial dashboard and proxy
images. Federation resource management configures policy and references; it
does not deploy a broker or grant access to its images. Running the broker
requires Enterprise Advanced.

## Selecting an Edition

For a single-cluster deployment, use the default:

```yaml
edition: community
```

Community automatically connects to the cluster where its proxy runs. It does
not provide cluster onboarding or per-cluster proxy endpoints. In local
development with a kubeconfig, it uses the default context.

For fleet management and managed ESO installations:

```yaml
edition: enterprise
sgAgent:
  enabled: true
proxy:
  registerLocalCluster: true
```

`proxy.registerLocalCluster` includes the management cluster in the commercial
fleet view using the proxy's ServiceAccount. Enable it only if that cluster is
not already registered through a kubeconfig Secret, to avoid duplicate entries.

For federation, use the Enterprise Advanced edition and configure the broker:

```yaml
edition: enterprise-advanced
sgAgent:
  enabled: true
federation:
  enabled: true
  serverName: default
  tls:
    secretName: fed-server-tls
```

Create the TLS Secret and the `FederationServer` before starting the broker;
follow the [Federation guide]({{< ref "../federation/" >}}) for trust, authorization,
and consumer setup. The SG Agent and broker remain independently opt-in in
eligible editions. Helm rejects `sgAgent.enabled=true` in Community and
`federation.enabled=true` outside Enterprise Advanced.

## Images and Registry Access

| Component | Community image | Commercial image |
|---|---|---|
| Dashboard | `quay.io/kubermatic/secureguard` | `quay.io/kubermatic/secureguard-ee` |
| Proxy | `quay.io/kubermatic/secureguard-proxy` | `quay.io/kubermatic/secureguard-proxy-ee` |
| SG Agent | — | `quay.io/kubermatic/secureguard-agent` |
| Federation broker | — | `quay.io/kubermatic/secureguard-federation` or `secureguard-federation-eso` (Enterprise Advanced) |

For either commercial edition, the chart appends `-ee` to the dashboard and
proxy repository names unless they already end in `-ee`. Use matching names
when mirroring these images. Configure registry credentials using the
[installation pull-secret settings]({{< ref "../installation/#cluster--tooling" >}}).

SecureGuard has no runtime license key. Commercial entitlement and access to
licensed artifacts are handled through your Kubermatic agreement and registry
access. Changing the Helm value alone does not provide those artifacts.

When upgrading an existing fleet deployment, explicitly retain its edition in
your values file. See [edition-aware upgrades]({{< ref "../upgrade-guides/#edition-aware-upgrades" >}}).
