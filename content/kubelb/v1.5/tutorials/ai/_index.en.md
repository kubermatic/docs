+++
title = "AI & MCP Gateway"
linkTitle = "AI & MCP Gateway"
date = 2026-07-23T10:00:00+02:00
description = "Run agentgateway as a KubeLB addon for LLM, MCP and Agent-to-Agent traffic."
weight = 35
aliases = ["/kubelb/v1.5/tutorials/aigateway/", "/kubelb/v1.5/tutorials/ai/gateway/"]
+++

KubeLB ships [agentgateway](https://agentgateway.dev) as an addon in the `kubelb-addons` chart. It is an Envoy-based proxy built for LLM traffic, Model Context Protocol (MCP) servers and Agent-to-Agent (A2A) connectivity. KubeLB installs and pins it; you author the gateway, backends and routes yourself with the upstream CRDs.

The addon is available in both editions.

## Prerequisites

- A KubeLB management cluster installed with the `kubelb-manager` chart and the bundled `kubelb-addons` chart.
- Gateway API CRDs in the cluster.

## Enabling

```yaml
kubelb-addons:
  enabled: true
  agentgateway-crds:
    enabled: true
  agentgateway:
    enabled: true
```

## A gateway of your own

Create a `Gateway` with the `agentgateway` GatewayClass. Everything below attaches to it:

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: ai
  namespace: kubelb
spec:
  gatewayClassName: agentgateway
  listeners:
    - name: http
      port: 80
      protocol: HTTP
```

## LLM provider backends

The provider API key lives in a Secret next to the backend. Rotating it is a one-Secret update.

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: openai-credentials
  namespace: kubelb
type: Opaque
stringData:
  Authorization: sk-proj-...    # key MUST be named "Authorization"
---
apiVersion: agentgateway.dev/v1alpha1
kind: AgentgatewayBackend
metadata:
  name: openai
  namespace: kubelb
spec:
  ai:
    provider:
      openai: {}                # model taken from the request when unset
  policies:
    auth:
      secretRef:
        name: openai-credentials
```

The `Authorization` data key is an agentgateway convention: the credential from that key is sent as `Authorization: Bearer <value>` to the provider.

Attach the backend with an `HTTPRoute`:

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: openai
  namespace: kubelb
spec:
  parentRefs:
    - name: ai
      namespace: kubelb
  rules:
    - backendRefs:
        - name: openai
          namespace: kubelb
          group: agentgateway.dev
          kind: AgentgatewayBackend
```

Failover between backends is driven by passive health checking, which only fires when `spec.backend.health` is set on the backend. See the [LLM provider guide](https://agentgateway.dev/docs/kubernetes/latest/llm/providers/).

{{% notice warning %}}
agentgateway merges policies field by field, but a singular field (`apiKeyAuthentication`, `rateLimit`, `jwtAuthentication`, `mcp`) set by two policies on the same target does not compose: one of the two is silently dropped, with no error and no log line, while both still report `Attached: True`. Keep one owner per singular field on any given target.
{{% /notice %}}

## MCP gateway

agentgateway federates one or more Model Context Protocol servers behind a single endpoint. The same `AgentgatewayBackend` CRD is used, with an `mcp` spec instead of `ai`:

```yaml
apiVersion: agentgateway.dev/v1alpha1
kind: AgentgatewayBackend
metadata:
  name: mcp-backend
  namespace: kubelb
spec:
  mcp:
    targets:
      - name: mcp-target
        backendRef:
          name: mcp-website-fetcher
        port: 80
        protocol: SSE
```

`backendRef.name` must resolve to a Kubernetes Service in the same namespace as the `AgentgatewayBackend`. Attach it with an `HTTPRoute` scoped to the `/mcp` path prefix so MCP traffic is kept apart from LLM backends:

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: mcp
  namespace: kubelb
spec:
  parentRefs:
    - name: ai
      namespace: kubelb
  rules:
    - matches:
        - path:
            type: PathPrefix
            value: /mcp
      backendRefs:
        - name: mcp-backend
          namespace: kubelb
          group: agentgateway.dev
          kind: AgentgatewayBackend
```

For static vs. dynamic targets, virtual MCP aggregation, tool-level access control, JWT auth and rate limiting, see the [MCP connectivity guide](https://agentgateway.dev/docs/kubernetes/latest/mcp/).

## Agent-to-Agent (A2A)

agentgateway also proxies A2A traffic for connecting AI agents through the gateway. See the [Agent connectivity guide](https://agentgateway.dev/docs/kubernetes/latest/agent/).

## Air-gapped environments

The agentgateway proxy and controller images are digest-pinned in the image lists shipped with each release, and the addon subcharts honour `global.imageRegistry`. See [Air-Gapped Installation]({{< relref "../../installation/air-gap" >}}).

## Further reading

- [agentgateway documentation](https://agentgateway.dev/docs/)
- [LLM providers](https://agentgateway.dev/docs/kubernetes/latest/llm/providers/)
- [MCP connectivity](https://agentgateway.dev/docs/kubernetes/latest/mcp/)
- [Agent connectivity](https://agentgateway.dev/docs/kubernetes/latest/agent/)
- [Observability](https://agentgateway.dev/docs/kubernetes/latest/observability/)
