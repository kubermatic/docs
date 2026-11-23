+++
title = "Offering LLM Models (Alpha)"
weight = 7
+++

KDP can offer large language models (LLMs) as a service. Providers publish models from any
OpenAI-compatible inference server, such as vLLM, Ollama or OpenAI itself. Consumers request access
to one or more models and get an endpoint and API key, which they can use from their own code or
from the dashboard's chat.

{{% notice warning %}}
This feature is alpha. Its APIs are `v1alpha1` and may change, some of its Helm charts depend on
pre-release components, and it isn't enabled in a default KDP installation.
{{% /notice %}}

<!-- TODO(engineering): confirm the supported way to install and operate this stack for 1.2, and how
LLMBackend credentials reach the service cluster for workspace-synced backends (see "Backends"). -->

## How it works

The feature uses four resource kinds in the API group `ai.kdp.k8c.io/v1alpha1`:

| Kind | Created by | Purpose |
| ---- | ---------- | ------- |
| `LLMBackend` | Provider | Where an inference server is reached, and its credentials. |
| `LLMSystemPrompt` | Provider | A system prompt that is always sent before the consumer's messages. |
| `LLMModel` | Provider | A model offered to consumers, served by a backend, with optional system prompts. |
| `LLMAccess` | Consumer | A request for access to one or more models. KDP answers it with a Secret holding the endpoint and an API key. |

They are offered through two KDP services in a central "LLM management" organisation:
`llmmodels.ai.kdp.k8c.io` for providers and `llmaccesses.ai.kdp.k8c.io` for consumers.

A service cluster runs the rest:

- **[agentgateway](https://agentgateway.dev)**, a gateway that receives all model requests on one
  HTTPS endpoint, checks the API key and routes each request to the right backend.
- **`kdp-llm-controller-manager`**, which turns `LLMModel` and `LLMAccess` objects into gateway
  configuration and API keys.
- **Two api-syncagents**, which copy the providers' and consumers' objects from KDP to the service
  cluster, and the consumers' credentials Secrets back.

All models share one endpoint. A request picks its model with the `model` field in the request
body, set to the model's reference `<cluster>/<namespace>/<name>`.

## Installing

Platform administrators install the stack on a service cluster with the `kdp-llm-management` Helm
chart, which bundles agentgateway, the controller manager and the api-syncagents.

You need:

- the Gateway API standard CRDs (v1.5.1),
- a TLS certificate Secret for the gateway's HTTPS listener,
- a hostname for the gateway that both consumers and the dashboard's pods can reach.

1. In the LLM management organisation in KDP, create the two `Service` objects
   `llmmodels.ai.kdp.k8c.io` and `llmaccesses.ai.kdp.k8c.io`, each with a kubeconfig Secret (see
   [Your First Service]({{< ref "/developer-platform/v1.2/guides/service-providers/your-first-service" >}})).
2. Copy both kubeconfig Secrets into the `kdp-llm-system` namespace of the service cluster.
3. Install the chart. Set at least the gateway hostname
   (`kdp-llm.controllerManager.gateway.host`), the listener's `tls.certificateRefs`, the
   controller manager's image tag (`kdp-llm.image.tag`) and the names of the two kubeconfig
   Secrets.
4. Create the gateway's DNS record.

Helm doesn't upgrade CRDs. On every upgrade, apply the chart's CRDs again before running
`helm upgrade`.

To use the dashboard's chat, also set the `kubermatic-ai-chat-enabled` feature flag and keep the
dashboard API enabled; see
[Configuring the Dashboard]({{< ref "/developer-platform/v1.2/guides/platform-administration/dashboard-configuration#feature-flags" >}}).
The chat calls the gateway from the dashboard's API pods, so the gateway hostname must resolve
there, and a private CA must be trusted with `NODE_EXTRA_CA_CERTS` in `api.extraEnv`. The
inference server must support streaming responses.

## Offering a model

As a provider, work in your own organisation or project:

1. **Enable the LLM Models service** and accept all the permissions it asks for.
2. **Create an `LLMBackend`** that points at your inference server.
3. Optionally, **create `LLMSystemPrompt` objects**.
4. **Create an `LLMModel`** and wait until it is `Ready`.
5. **Let consumers see it.** Grant them `catalog` and `get` on `llmmodels` and `access` on the
   non-resource URL `/` in your workspace, so they can pick your model in the dashboard.

### Backends

An `LLMBackend` sets exactly one of:

- **`routeRef`**: selects an `HTTPRoute` on the service cluster that leads to your inference
  server, by the label `ai.kdp.k8c.io/secret-provider-route-key`. Use a long random value of at
  least 24 characters; the selector must match exactly one route. `pathPrefix` defaults to `/v1`.
- **`baseURL`**: the server's URL directly. Only allowed for backends created on the service
  cluster itself. A backend created in a KDP workspace with `baseURL` reports
  `RemoteBaseURLNotAllowed`.

```yaml
apiVersion: ai.kdp.k8c.io/v1alpha1
kind: LLMBackend
metadata:
  name: vllm
spec:
  routeRef:
    kind: HTTPRoute
    selector:
      matchLabels:
        ai.kdp.k8c.io/secret-provider-route-key: 6f1c0e2a9b8d4c7e5a3f1b0c
    pathPrefix: /v1
  # Optional: a Secret with an "Authorization" key, sent as a Bearer token.
  # credentialsRef:
  #   name: vllm-credentials
```

### System prompts

```yaml
apiVersion: ai.kdp.k8c.io/v1alpha1
kind: LLMSystemPrompt
metadata:
  name: house-style
spec:
  description: Answers in British English.
  content: Answer in British English and keep answers short.
```

`content` can be up to 4096 characters. Consumers only see the `description`, never the content.

### Models

```yaml
apiVersion: ai.kdp.k8c.io/v1alpha1
kind: LLMModel
metadata:
  name: llama-3-8b
spec:
  model: meta-llama/Meta-Llama-3-8B-Instruct   # the model ID on the inference server
  description: Llama 3, 8B parameters, instruction tuned.
  backendRef:
    name: vllm
  systemPromptRefs:
    - name: house-style
```

A model can use up to 8 system prompts, which are sent in order. Once the model is `Ready`, its
`status.workspacePath` shows where it comes from.

## Using a model

As a consumer:

1. **Enable the LLM Access service** in your organisation or project.
2. **Create an `LLMAccess`** listing the models you want. A model's ID is
   `<cluster>/<namespace>/<name>`, where `<cluster>` is the provider workspace's cluster ID.

   ```yaml
   apiVersion: ai.kdp.k8c.io/v1alpha1
   kind: LLMAccess
   metadata:
     name: my-app
   spec:
     llmModels:
       - id: 2x8k4q7zr1m3n5p0/default/llama-3-8b
   ```

3. **Wait until it is `Ready`**, then read the Secret named in `status.secretRef.name`. It contains
   `endpoint`, `key`, `models` (the model IDs, comma-separated) and a ready-made `opencode.json`.
4. **Call the model** with any OpenAI-compatible client:

   ```bash
   curl "$ENDPOINT/v1/chat/completions" \
     -H "Authorization: Bearer $KEY" \
     -H "Content-Type: application/json" \
     -d '{"model": "2x8k4q7zr1m3n5p0/default/llama-3-8b", "messages": [{"role": "user", "content": "Hello"}]}'
   ```

In the dashboard, the form for an `LLMAccess` lists the models you can pick, and the object's
**Chat** action opens a chat with them; see
[Managing Resources]({{< ref "/developer-platform/v1.2/guides/platform-users/managing-resources#chatting-with-an-llm" >}}).

Deleting the `LLMAccess` revokes its API key.

## Troubleshooting

Each object reports a `Ready` condition. Its reason says what is wrong:

| Object | Reason | Meaning |
| ------ | ------ | ------- |
| `LLMBackend` | `MutuallyExclusive`, `NoBackendTarget` | Set exactly one of `routeRef` and `baseURL`. |
| `LLMBackend` | `RouteNotFound`, `AmbiguousRoute`, `RouteKeyTooShort` | The route selector matches no route, several routes, or the key is under 24 characters. |
| `LLMBackend` | `RemoteBaseURLNotAllowed` | Backends created in a KDP workspace must use `routeRef`. |
| `LLMBackend` | `CredentialsNotFound`, `CredentialsKeyMissing` | The `credentialsRef` Secret or its `Authorization` key is missing. |
| `LLMModel` | `BackendNotFound`, `BackendNotReady` | Check the backend's own condition. |
| `LLMModel` | `SystemPromptNotFound`, `SystemPromptNotReady` | A referenced system prompt is missing or empty. |
| `LLMAccess` | `InvalidReference`, `ModelNotFound` | A model ID is malformed or doesn't exist. |
| `LLMAccess` | `ModelNotReady`, `AwaitingEndpoint` | The model isn't ready yet; this resolves on its own once it is. |

If deleting an `LLMAccess` hangs, check that `kdp-llm-controller-manager` is running on the
service cluster; it removes the object's finalizer after revoking its key.

## Limitations

- Only `HTTPRoute` is supported for `routeRef`.
- The gateway endpoint must use HTTPS.
- Upgrading the `kdp-llm-management` chart from an older version rotates all consumers' API keys.
