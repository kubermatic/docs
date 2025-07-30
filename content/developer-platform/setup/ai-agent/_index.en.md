+++
title = "AI Agent"
weight = 3
+++

## Overview

The Kubermatic Developer Platform AI Agent is a specialized assistant that helps users generate Kubernetes resource YAML files through natural language within KDP workspaces. It converts requests in natural language into properly formatted Kubernetes manifests, eliminating the need to manually write lengthy YAML files from scratch.

## Prerequisites

Before installing the AI Agent, ensure you have:

- A running KDP installation on your kubernetes cluster
- OpenAI API key for the language model capabilities
- OIDC provider configured (same one used by KDP)

## Installation

The AI Agent is deployed using Helm. Follow these steps to install it:

### Step 1: Prepare the Configuration

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
    host: kdpd.example.com
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

Adjust the values according to your environment. Remember to use the same host as the dashboard to avoid CORS errors.

### Step 2: Install with Helm

### Step 3: Verify the Installation

**Note:** To use the AI Agent through the Dashboard UI you need to set up the environment variable `next_public_enable_generate_spec` to `true` in the dashboard values.yaml.

Once the pod is running, you can use it in the frontend.

