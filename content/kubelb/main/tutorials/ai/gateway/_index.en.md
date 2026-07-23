+++
title = "AI & MCP Gateway"
linkTitle = "AI & MCP Gateway"
date = 2026-07-23T10:00:00+02:00
weight = 1
aliases = ["/kubelb/main/tutorials/aigateway/"]
description = "Set up the multi-tenant AI gateway: one OpenAI-compatible endpoint, provider credentials that never leave the management cluster, and a data plane that also speaks MCP and A2A."
+++

Every team in your organization wants to call an LLM. As the platform operator, you have two options: hand each team a raw provider key and lose track of it forever, or put a gateway you control between them and the provider. This page sets up the second option.

With the AI gateway enabled, tenants call one OpenAI-compatible endpoint using keys they issue themselves. The real provider credentials (OpenAI, Anthropic, Azure, Bedrock, ...) exist only in the management cluster. Budgets, metering, and attribution come with it; those are covered in [Budgets & Virtual Keys]({{% relref "../budgets-and-virtual-keys/" %}}).

{{% notice info %}}
The multi-tenant layer (virtual keys, budgets, metering) is an Enterprise Edition feature. The agentgateway addon itself and the [direct data-plane usage](#direct-data-plane-usage-mcp-and-a2a) below work in both editions.
{{% /notice %}}

The data plane is [agentgateway](https://agentgateway.dev), an Envoy-based proxy built for LLM traffic, Model Context Protocol (MCP) servers, and Agent-to-Agent (A2A) connectivity. It ships as an addon in the `kubelb-addons` chart; KubeLB configures it, but you can also drive it directly.

## Enabling

Turn on the addons and the manager feature in the `kubelb-manager` chart values:

```yaml
kubelb:
  enableGatewayAPI: true
  enableAIGateway: true

kubelb-addons:
  enabled: true
  agentgateway-crds:
    enabled: true
  agentgateway:
    enabled: true
  # Required for inline Day-window budget enforcement:
  valkey:
    enabled: true
  ratelimit:
    enabled: true
```

Nothing happens yet. The manager reconciles only once `spec.ai.enabled` is set on the `Config`, so an upgrade with the flag on changes nothing until you opt in:

```yaml
apiVersion: kubelb.k8c.io/v1alpha1
kind: Config
metadata:
  name: default
  namespace: kubelb
spec:
  ai:
    enabled: true
    defaultBudgets:
      - tokens: 50000000
        window: Month
        onExceed: Block
        alertThresholdPercent: 80
    rateLimitService:
      name: kubelb-ratelimit
      namespace: kubelb
      port: 8081
    virtualKeys:
      limit: 20                # max keys per tenant
      maxTTL: 720h             # default and ceiling for key expiry
```

Individual tenants can be opted out, given different budgets, or given a different key quota on their `Tenant` resource. The budget and key settings are explained in [Budgets & Virtual Keys]({{% relref "../budgets-and-virtual-keys/" %}}).

## Provider backends and credential custody

You author provider backends yourself as `AgentgatewayBackend` resources in the `kubelb` namespace. KubeLB deliberately does not render these: which providers exist, and under which commercial account, is your call.

The provider API key lives in a management-cluster Secret. Tenants never see it. They authenticate with their own virtual keys, and the gateway swaps in the real credential on the way out. Rotating a provider key is a one-Secret update, with no tenant involvement.

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

Attach the backend to the managed `kubelb-ai` Gateway with an `HTTPRoute`:

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: openai
  namespace: kubelb
spec:
  parentRefs:
    - name: kubelb-ai
      namespace: kubelb
  rules:
    - backendRefs:
        - name: openai
          namespace: kubelb
          group: agentgateway.dev
          kind: AgentgatewayBackend
```

KubeLB applies a passive-health policy to every backend automatically: responses with status >= 500 or 429 count as failures, and an endpoint is evicted after 3 consecutive failures. Failover between providers works without any per-backend configuration.

## What the manager renders, and what you must not touch

With `spec.ai.enabled`, the manager renders and solely owns these objects in the `kubelb` namespace:

| Resource | Name | Purpose |
| --- | --- | --- |
| Gateway | `kubelb-ai` | Shared entry point, class `agentgateway` |
| AgentgatewayPolicy | `kubelb-ai` | Key auth, metric + access-log attribution, global rate limit |
| AgentgatewayPolicy | `kubelb-ai-backend-health` | Passive health for all backends |
| Secret | `ai-keys-<tenant>` | Per-tenant virtual keys |
| ConfigMap | `ratelimit-config` | Day-window descriptors for the rate-limit service |

Do not hand-edit them; the manager reverts your changes on the next reconcile.

{{% notice warning %}}
agentgateway merges policies field by field, but a singular field (`apiKeyAuthentication`, `rateLimit`, `jwtAuthentication`, `mcp`) set by two policies on the same target does not compose: one of the two is silently dropped, while both still report `Attached: True`. There is no error and no log line. Do not attach your own `AgentgatewayPolicy` that sets one of those fields to the `kubelb-ai` Gateway. Policies that set different fields, such as `authorization` rules or `jwtAuthentication` on your own routes, merge with the managed policy and are safe.
{{% /notice %}}

Key Secrets survive a disable: turning AI off for a tenant or globally preserves the `ai-keys-*` Secrets, so re-enabling does not re-issue anyone's keys. They are removed only when the `Tenant` resource itself is deleted.

To switch the feature off, set `Config.spec.ai.enabled: false` first and let the manager clean up. Only then, optionally, remove `enableAIGateway` from the chart values. Removing the flag first strands the rendered resources with nothing left to clean them up.

## Direct data-plane usage, MCP and A2A

The addon is a full gateway in its own right. You can create your own Gateway with the `agentgateway` GatewayClass and author backends and routes against it, with no multi-tenant layer involved. Today that is how MCP and A2A traffic is exposed.

### MCP gateway

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
    - name: kubelb-ai
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

For static vs. dynamic targets, virtual MCP aggregation, tool-level access control, JWT auth, and rate limiting, see the [MCP connectivity guide](https://agentgateway.dev/docs/kubernetes/latest/mcp/).

### Agent-to-Agent (A2A)

agentgateway also proxies A2A traffic for connecting AI agents through the gateway. See the [Agent connectivity guide](https://agentgateway.dev/docs/kubernetes/latest/agent/).

## Air-gapped environments

All AI gateway images (agentgateway proxy and controller, rate-limit service, valkey) are digest-pinned in the image lists shipped with each release, and the addon subcharts honour `global.imageRegistry`. See [Air-Gapped Installation]({{< relref "../../airgap-installation" >}}).

## Further reading

- [agentgateway documentation](https://agentgateway.dev/docs/)
- [LLM providers](https://agentgateway.dev/docs/kubernetes/latest/llm/providers/)
- [MCP connectivity](https://agentgateway.dev/docs/kubernetes/latest/mcp/)
- [Agent connectivity](https://agentgateway.dev/docs/kubernetes/latest/agent/)
- [Observability](https://agentgateway.dev/docs/kubernetes/latest/observability/)
