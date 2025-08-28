+++
title = "AI Gateway"
linkTitle = "AI Gateway"
date = 2023-10-27T10:07:15+02:00
weight = 7
+++

This tutorial will guide you through setting up an AI Gateway using KubeLB with KGateway to securely manage Large Language Model (LLM) requests.

## Overview

KubeLB leverages [KGateway](https://kgateway.dev/), a CNCF Sandbox project (accepted March 2025), to provide advanced AI Gateway capabilities. KGateway is built on Envoy and implements the Kubernetes Gateway API specification, offering:

- **AI Workload Protection**: Secure applications, models, and data from inappropriate access
- **LLM Traffic Management**: Intelligent routing to LLM providers with load balancing based on model metrics
- **Prompt Engineering**: System-level prompt enrichment and guards
- **Multi-Provider Support**: Works with OpenAI, Anthropic, Google Gemini, Mistral, and local models like Ollama
- **Model Context Protocol (MCP) Gateway**: Federates MCP tool servers into a single, secure endpoint
- **Advanced Security**: Authentication, authorization, rate limiting tailored for AI workloads

### Key Features

#### AI-Specific Capabilities

- **Prompt Guards**: Protect against prompt injection and data leakage
- **Model Failover**: Automatic failover between LLM providers
- **Function Calling**: Support for LLM function/tool calling
- **AI Observability**: Detailed metrics and tracing for AI requests
- **Semantic Caching**: Cache responses based on semantic similarity
- **Token-Based Rate Limiting**: Control costs with token consumption limits

#### Gateway API Inference Extension

KGateway supports the Gateway API Inference Extension which introduces:

- `InferenceModel` CRD: Define LLM models and their endpoints
- `InferencePool` CRD: Group models for load balancing and failover
- Intelligent endpoint picking based on model performance metrics

## Setup

### Step 1: Enable KGateway AI Extension

Update values.yaml for KubeLB manager chart to enable KGateway with AI capabilities:

```yaml
kubelb:
  enableGatewayAPI: true

kubelb-addons:
  enabled: true

  kgateway:
    enabled: true
    gateway:
      aiExtension:
        enabled: true
```

### Step 2: Create Gateway Specific Resources

1. Deploy a Gateway resource to handle AI traffic:

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: ai-gateway
  namespace: kubelb
  labels:
    app: ai-gateway
spec:
  gatewayClassName: kgateway
  infrastructure:
    parametersRef:
      name: ai-gateway
      group: gateway.kgateway.dev
      kind: GatewayParameters
  listeners:
  - protocol: HTTP
    port: 8080
    name: http
    allowedRoutes:
      namespaces:
        from: All
```

2. Deploy a GatewayParameters resource to enable the AI extension:

```yaml
apiVersion: gateway.kgateway.dev/v1alpha1
kind: GatewayParameters
metadata:
  name: ai-gateway
  namespace: kubelb
  labels:
    app: ai-gateway
spec:
  kube:
    aiExtension:
      enabled: true
      ports:
      - name: ai-monitoring
        containerPort: 9092
      image:
        registry: cr.kgateway.dev/kgateway-dev
        repository: kgateway-ai-extension
        tag: v2.1.0-main
    service:
      type: LoadBalancer
```

## OpenAI Integration Example

This example shows how to set up secure access to OpenAI through the AI Gateway.

### Step 1: Store OpenAI API Key

Create a Kubernetes secret with your OpenAI API key:

```bash
export OPENAI_API_KEY="sk-..."

kubectl create secret generic openai-secret \
  --from-literal=Authorization="Bearer ${OPENAI_API_KEY}" \
  --namespace kubelb
```

### Step 2: Create Backend Configuration

Define an AI Backend that uses the secret for authentication:

```yaml
apiVersion: gateway.kgateway.dev/v1alpha1
kind: Backend
metadata:
  name: openai
  namespace: kubelb
spec:
  type: AI
  ai:
    llm:
      provider:
        openai:
          authToken:
            kind: SecretRef
            secretRef:
              name: openai-secret
              namespace: kubelb
          model: "gpt-3.5-turbo"
```

### Step 3: Create HTTPRoute

Route traffic to the OpenAI backend:

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: openai-route
  namespace: kubelb
spec:
  parentRefs:
    - name: ai-gateway
      namespace: kubelb
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /openai
    filters:
    - type: URLRewrite
      urlRewrite:
        path:
          type: ReplaceFullPath
          replaceFullPath: /v1/chat/completions
    backendRefs:
    - name: openai
      namespace: kubelb
      group: gateway.kgateway.dev
      kind: Backend
```

### Step 4: Test the Configuration

Get the Gateway's external IP:

```bash
kubectl get gateway ai-gateway -n kubelb
export GATEWAY_IP=$(kubectl get svc -n kubelb ai-gateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
```

Send a test request:

```bash
curl -X POST "http://${GATEWAY_IP}/openai" \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [
      {"role": "user", "content": "Hello, how are you?"}
    ]
  }'
```

## Rate Limiting (Optional)

Add rate limiting to control costs and prevent abuse:

```yaml
apiVersion: gateway.kgateway.dev/v1alpha1
kind: RateLimitPolicy
metadata:
  name: openai-ratelimit
  namespace: kubelb
spec:
  targetRef:
    kind: HTTPRoute
    name: openai-route
    namespace: kubelb
  limits:
    - requests: 100
      unit: hour
```

## MCP Gateway

Similar to the AI Gateway, you can also use agentgateway to can connect to one or multiple MCP servers in any environment.

Please follow this guide to setup the MCP Gateway: [MCP Gateway](https://kgateway.dev/docs/agentgateway/mcp/)

## Further Reading

For advanced configurations and features:

- [KGateway AI Setup Documentation](https://kgateway.dev/docs/ai/setup/)
- [KGateway Authentication Guide](https://kgateway.dev/docs/ai/auth/)
- [Prompt Guards and Security](https://kgateway.dev/docs/ai/prompt-guards/)
- [Multiple LLM Providers](https://kgateway.dev/docs/ai/providers/)
