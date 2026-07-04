+++
title = "Getting Started"
date = 2026-06-13T09:00:00+02:00
weight = 1
description = "Quickly deploy Kubermatic SecureGuard in a local or development environment and watch your first secret sync end-to-end."
+++

This guide will walk you through quickly deploying Kubermatic SecureGuard in a local or development environment. This deployment bundles OpenBao (in dev mode), the Dex OIDC provider, External Secrets Operator (ESO), and the SecureGuard dashboard UI.

{{% notice warning %}}
This guide is intended for development and local testing. Do not use `dev` mode secrets for production workloads. For production deployments, refer to the [Installation]({{< ref "../installation/" >}}) guide.
{{% /notice %}}

## What You'll Have at the End

A local SecureGuard you can log into, showing how a secret flows from the vault
to your apps:

```text
 OpenBao (vault)  ──ESO syncs──▶  Kubernetes Secret  ──▶  your app
        ▲                                  │
        └────  you watch it all from the SecureGuard dashboard  ────┘
```

If any of the terms below (ESO, OpenBao, SecretStore, OIDC, Dex) are new, keep
the [Glossary]({{< ref "../glossary/" >}}) handy — each is defined in one line.

## Prerequisites
Before you begin, ensure you have the following installed:
*   [Docker Engine](https://docs.docker.com/engine/install/) 24+
*   [Helm](https://helm.sh/docs/intro/install/)
*   A running Kubernetes cluster (e.g., [kind](https://kind.sigs.k8s.io/), [minikube](https://minikube.sigs.k8s.io/), or Docker Desktop Kubernetes)

## Quickstart Deployment

1. **Install the Helm Chart**
   Deploy the chart directly from the Kubermatic Quay.io registry into your cluster under the `secureguard` release name. The chart will automatically install all required Custom Resource Definitions (CRDs) for the External Secrets Operator.
   ```bash
   helm install secureguard oci://quay.io/kubermatic/helm-charts/secureguard \
     --namespace secureguard-system \
     --create-namespace \
     --set openbao.server.dev.enabled=true
   ```

   Omitting `--version` installs the latest published chart. To pin a specific
   release, add `--version <chart-version>` — see the
   [Upgrade Guides]({{< ref "../upgrade-guides/" >}}) before moving between versions.

2. **Verify the Deployment**
   Ensure all pods have started and are reporting `Running` status:
   ```bash
   kubectl get pods -n secureguard-system
   ```
   You should see pods for the backend proxy, the UI, OpenBao, Dex, and the ESO controllers.

## Navigating the Dashboard

Once the deployment is up, you need to access the SecureGuard dashboard.

1. **Port-Forward the Dashboard Service**
   *Note: In production, you would configure an Ingress. For local testing, port-forwarding is sufficient.*
   ```bash
   kubectl port-forward svc/secureguard-ui 8080:80 -n secureguard-system
   ```

2. **Access the UI**
   Open your browser and navigate to `http://localhost:8080`.

3. **Logging In via Dex**
   Authentication is mandatory, so you are redirected to the Dex OIDC login page. The Helm chart provisions a static admin user with the email `admin@secureguard.local` and an **auto-generated password**. Retrieve it from the `<release>-dex-admin` Secret:

   ```bash
   kubectl get secret secureguard-dex-admin \
     -n secureguard-system \
     -o jsonpath='{.data.password}' | base64 -d && echo
   ```

   The same command is printed in the Helm chart's post-install notes. For any non-local deployment, disable the static admin and connect a real identity provider instead — see [Static Admin User]({{< ref "../security-hardening/#static-admin-user" >}}).

   {{% notice note %}}
   Access is enforced per user: the proxy impersonates the logged-in user on every Kubernetes API request, so what you can see and do is governed by the RBAC bound to your user/groups. A user with no bindings can log in but sees `403` errors until granted access — see [User Authorization]({{< ref "../advanced-configuration/#user-authorization-rbac-via-impersonation" >}}).
   {{% /notice %}}

4. **Grant the Admin User Access**
   The chart intentionally ships **no RBAC bindings for dashboard users** — without one, even the static admin sees only `403` errors. For this local walkthrough, bind `cluster-admin` to the static admin user:

   ```bash
   kubectl create clusterrolebinding secureguard-local-admin \
     --clusterrole=cluster-admin \
     --user=admin@secureguard.local
   ```

   {{% notice warning %}}
   `cluster-admin` is acceptable only for a throwaway local cluster. For real deployments, create least-privilege Roles/ClusterRoles per team — see [User Authorization]({{< ref "../advanced-configuration/#user-authorization-rbac-via-impersonation" >}}).
   {{% /notice %}}

### Understanding the Security Model Basics

As you explore the dashboard, keep the following security principles in mind:

*   **Secrets are Masked by Default:** When viewing the status of an `ExternalSecret`, the actual secret values retrieved from OpenBao are masked (`••••••••`). The proxy redacts all secret values before they reach the browser — there is no mechanism to reveal them in the UI.
*   **No Direct API Exposure:** The browser UI never contacts the Kubernetes API server directly. All API calls pass through the SecureGuard Backend Proxy, which handles authentication and limits exposed endpoints.
*   **No Plaintext Storage:** Secret values are not stored in URL parameters, browser history, or caches to prevent leakage.

## Create Your First Secret Sync

Let's watch a secret flow end-to-end. To keep this beginner-friendly we'll use
ESO's built-in **`fake` provider**, which returns values baked into the manifest
— so you don't need OpenBao auth, a cloud account, or any credentials to see
syncing work. (In real life the provider would be OpenBao or a cloud vault.)

Remember: the dashboard is read-mostly, so we **create** the resources with
`kubectl` and then **watch** them in the UI — exactly how you'd work day-to-day.

1. **Save this manifest** as `first-secret.yaml`:

   ```yaml
   # A self-contained demo: a fake "vault" plus an ExternalSecret that reads it.
   apiVersion: external-secrets.io/v1
   kind: ClusterSecretStore
   metadata:
     name: demo-fake-store          # the "how to connect" config (here: fake data)
   spec:
     provider:
       fake:
         data:
           - key: /demo/db
             value: "hunter2"        # the pretend secret value
             version: v1
   ---
   apiVersion: external-secrets.io/v1
   kind: ExternalSecret
   metadata:
     name: demo-db-credentials
     namespace: default
   spec:
     refreshInterval: 1h
     secretStoreRef:
       name: demo-fake-store
       kind: ClusterSecretStore
     target:
       name: demo-db-credentials     # the Kubernetes Secret ESO will create
     data:
       - secretKey: password         # key inside the created Secret
         remoteRef:
           key: /demo/db             # which entry to read from the store
           version: v1
   ```

2. **Apply it:**

   ```bash
   kubectl apply -f first-secret.yaml
   ```

3. **Watch it in the dashboard:**
   - Open **External Secrets** — `demo-db-credentials` appears and turns
     **Synced** (green) within a few seconds.
   - Open **Secrets** — ESO has created a Kubernetes Secret named
     `demo-db-credentials`, tagged as ESO-managed. Its `password` key is shown
     as `••••••••` — the value never reaches your browser, even in this demo.
   - Click the ExternalSecret and try **Sync Now** to force an immediate refresh.

4. **Clean up** when you're done:

   ```bash
   kubectl delete -f first-secret.yaml
   ```

{{% notice tip %}}
**What just happened?** You defined *where to read from* (the `ClusterSecretStore`) and *what to fetch* (the `ExternalSecret`). ESO did the rest: it created and now keeps a normal Kubernetes `Secret` in sync. Swap the `fake` provider for an OpenBao `SecretStore` and the exact same flow works with real, encrypted secrets — see [ESO Basics]({{< ref "../eso-basics/" >}}).
{{% /notice %}}

## Next Steps
Now that you have a local instance running:
*   Tour the dashboard feature by feature in the [User Guide]({{< ref "../user-guide/" >}}).
*   Keep the [Glossary]({{< ref "../glossary/" >}}) handy for any unfamiliar term.
*   Learn how to deploy to a [Production Environment]({{< ref "../installation/" >}}).
*   Explore the [Architecture & Security Model]({{< ref "../architecture/" >}}) to understand how SecureGuard protects your secrets.
