+++
title = "AI & MCP Gateway"
linkTitle = "AI & MCP Gateway"
date = 2023-10-27T10:07:15+02:00
weight = 6
+++

This tutorial walks through setting up an AI, MCP, and Agent-to-Agent (A2A) Gateway with KubeLB using [agentgateway](https://agentgateway.dev).

## Overview

agentgateway is an Envoy-based data plane that implements the Kubernetes Gateway API and adds first-class support for LLM traffic, Model Context Protocol (MCP) servers, and Agent-to-Agent (A2A) connectivity. Enabled as an addon in the `kubelb-addons` chart, it lets the management cluster terminate AI/agent traffic.

Refer to the upstream [agentgateway documentation](https://agentgateway.dev/docs/) for the complete feature set (provider list, prompt guards, inference routing, rate limiting, observability, etc.). This page only covers enabling the addon and a minimal end-to-end example.

## Prerequisites

- A management cluster with KubeLB manager installed. See [Setup Management Cluster]({{< relref "../../installation/management-cluster" >}}).
- Gateway API CRDs installed (`kubelb.enableGatewayAPI: true` in the manager values).

## Setup

Enable the addon in `values.yaml` for the KubeLB manager chart:

```yaml
kubelb:
  enableGatewayAPI: true

kubelb-addons:
  enabled: true
  agentgateway:
    enabled: true
```

Apply the chart. The addon installs the agentgateway control plane and the `AgentgatewayBackend` CRD (API group `agentgateway.dev/v1alpha1`).

{{% notice note %}}
Enabling the addon installs the `AgentgatewayBackend` CRD and registers the `agentgateway` GatewayClass that subsequent examples reference.
{{% /notice %}}

### Create the Gateway

Provision a Gateway that uses the `agentgateway` GatewayClass. The proxy Deployment and Service are created automatically from this resource.

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: agentgateway-proxy
  namespace: kubelb
spec:
  gatewayClassName: agentgateway
  listeners:
    - name: http
      protocol: HTTP
      port: 8080
      allowedRoutes:
        namespaces:
          from: All
```

## OpenAI Example

This example routes requests to OpenAI through agentgateway using the `AgentgatewayBackend` CRD.

### Store the API Key

```bash
export OPENAI_API_KEY="sk-..."

kubectl create secret generic openai-secret \
  --namespace kubelb \
  --from-literal=Authorization="${OPENAI_API_KEY}"
```

The literal key must be `Authorization` with the raw API key as its value; agentgateway prepends the `Bearer ` prefix when forwarding requests to OpenAI.

### Define the Backend

```yaml
apiVersion: agentgateway.dev/v1alpha1
kind: AgentgatewayBackend
metadata:
  name: openai
  namespace: kubelb
spec:
  ai:
    provider:
      openai:
        model: gpt-3.5-turbo
  policies:
    auth:
      secretRef:
        name: openai-secret
```

### Route Traffic to the Backend

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: openai
  namespace: kubelb
spec:
  parentRefs:
    - name: agentgateway-proxy
      namespace: kubelb
  rules:
    - backendRefs:
        - name: openai
          namespace: kubelb
          group: agentgateway.dev
          kind: AgentgatewayBackend
```

agentgateway automatically rewrites incoming requests to OpenAI's `/v1/chat/completions` endpoint.

### Test the Route

Get the Gateway address, then send a chat-completion request:

```bash
export GATEWAY_IP=$(kubectl get gateway agentgateway-proxy -n kubelb \
  -o jsonpath='{.status.addresses[0].value}')

curl "http://${GATEWAY_IP}:8080/v1/chat/completions" \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [
      {"role": "system", "content": "You are helpful."},
      {"role": "user", "content": "Hello"}
    ]
  }'
```

For additional providers (Anthropic, Gemini, Mistral, Ollama, etc.), failover, prompt guards, and token-based rate limiting, see the [LLM consumption guide](https://agentgateway.dev/docs/kubernetes/latest/llm/).

## MCP Gateway

agentgateway can federate one or more Model Context Protocol (MCP) servers behind a single endpoint. The same `AgentgatewayBackend` CRD is used, with an `mcp` spec instead of `ai`:

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

`backendRef.name` must resolve to a Kubernetes Service in the same namespace as the `AgentgatewayBackend`. Attach the backend to the Gateway with an `HTTPRoute` scoped to the `/mcp` path prefix so MCP traffic is not routed to an LLM or other backend:

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: mcp
  namespace: kubelb
spec:
  parentRefs:
    - name: agentgateway-proxy
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

## Agent-to-Agent (A2A)

agentgateway also proxies Agent-to-Agent (A2A) traffic for connecting AI agents through the gateway. See the [Agent connectivity guide](https://agentgateway.dev/docs/kubernetes/latest/agent/) for configuration.

## Further Reading

- [agentgateway documentation](https://agentgateway.dev/docs/)
- [Gateway setup](https://agentgateway.dev/docs/kubernetes/latest/setup/)
- [LLM providers](https://agentgateway.dev/docs/kubernetes/latest/llm/providers/)
- [MCP connectivity](https://agentgateway.dev/docs/kubernetes/latest/mcp/)
- [Agent connectivity](https://agentgateway.dev/docs/kubernetes/latest/agent/)
- [Security](https://agentgateway.dev/docs/kubernetes/latest/security/)
- [Observability](https://agentgateway.dev/docs/kubernetes/latest/observability/)
