+++
title = "AI Agent"
weight = 3
+++

## Overview

The Kubermatic Developer Platform AI Agent is a specialized assistant that helps users generate Kubernetes resource YAML files through natural language within KDP workspaces. It converts requests in natural language into properly formatted Kubernetes manifests, eliminating the need to manually write lengthy YAML files from scratch.

## Prerequisites

Before installing the AI Agent, ensure you have:

- A running KDP installation on your Kubernetes cluster
- OpenAI API key for the language model capabilities
- OIDC provider configured (same one used by KDP)

## Installation

The AI Agent is deployed using Helm. Follow these steps to install it:

### 1: Prepare the Configuration

Create a `values.yaml` file with your specific configuration:

```yaml
aiAgent:
  imagePullSecret: |
    {
      "quay.io": {}
    }

  image:
    repository: "quay.io/kubermatic/developer-platform-ai-agent"
    tag: "v1.0.0" # Use the latest version or a specific version

  config:
    oidc_client_id: kdp-kubelogin  # OIDC client ID for authentication
    oidc_client_secret: "your-client-secret"  # OIDC client secret
    oidc_issuer: "https://your-oidc-provider"  # URL of the OIDC provider
    kubernetes_api_url: "https://your-kdp-api"  # KDP API server URL
    openai_api_key: "your-openai-api-key"  # OpenAI API key for the language model

  ingress:
    create: false
    host: kdp.example.com # this should be main domain configured for KDP
    class: nginx
    scheme: https
    prefix: /ai-agent(/|$)(.*)

    # When scheme is set to "https", you either need to provide a TLS certificate
    # yourself, or you can use the settings below to use cert-manager.
    # certIssuer:
    #   # This needs to reference an _existing_ (Cluster)Issuer to provision
    #   # the TLS certificate for the protoboard.
    #   kind: ClusterIssuer
    #   name: letsencrypt-prod

  resources:
    requests:
      cpu: 100m
      memory: 128Mi
    limits:
      cpu: 500m
      memory: 256Mi

```

Adjust the values according to your environment.

### 2: Install with Helm

```
helm upgrade \
  --install \
  --namespace <namespace> \ # if you are using an Issuer (namespaced), remember to use the same namespace here
  --version <kdp_version> \
  --values <your_values_path> \
  --set-string "ai-agent.image.tag=v<kdp_version>" \
  <release_name> <chart_path>
```

### 4: Configure the Dashboard

To make the AI Agent accessible from the KDP Dashboard, you need to update the `values.yaml` file for your **dashboard deployment**. You'll need to set two environment variables within your dashboard's configuration.

First, enable the AI Agent feature in the UI by setting the environment variable `next_public_enable_generate_spec` to `"true"`.

Second, tell the frontend where the AI Agent backend is located by setting the environment variable `next_public_spec_generator_url` to your agent's URL (for example, `"https://kdp.example.com/ai-agent/"`).

**Important:** To avoid CORS errors, the URL for `next_public_spec_generator_url` must use the same host as your main KDP dashboard (and in general the main kdp domain). The path (`/ai-agent/` in this example) must also match the `ingress.prefix` you configured in the AI Agent's `values.yaml` in Step 1.

### 5: Verify the Installation

Once the pod is running, you can use it in the frontend.

A purple button should be visible in the form to create a new service object within a workspace.

![Button for AI Agent](ai-agent-button.png)

Then, once clicked, a text field will be visible were you can describe how you want your resource to be.

Here is an example after writing a prompt and clicking on `Generate`:

![Example prompt](ai-agent-prompt-example.png)

After a few seconds you should get the result:

![AI Agent response](ai-agent-example-response.png)

You can then edit and modify if you like. You also do not have to worry about getting a wrong schema since it is getting validated in the backend. You can be sure there are no hallucinated fields nor missing required fields.