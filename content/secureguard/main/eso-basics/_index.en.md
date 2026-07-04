+++
title = "External Secrets Operator (ESO) Basics"
date = 2026-06-13T09:00:00+02:00
weight = 5
description = "How the External Secrets Operator synchronizes secrets from OpenBao (and other providers) into native Kubernetes Secrets within SecureGuard."
+++

The [External Secrets Operator](https://external-secrets.io/) (ESO) is the second pillar of Kubermatic SecureGuard. While OpenBao acts as the secure storage vault, ESO acts as the intelligent delivery mechanism.

{{% notice tip %}}
**In plain English:** ESO is a delivery service. You keep your secrets locked in a vault (OpenBao). Your apps, however, only know how to read ordinary Kubernetes `Secret` objects. ESO is the courier that fetches a secret from the vault, drops a copy into a Kubernetes `Secret` where your app can pick it up, and keeps re-checking the vault so the copy never goes stale. Your app never has to know the vault exists.

New to the terms below (CRD, SecretStore, namespace)? See the [Glossary]({{< ref "../glossary/" >}}).
{{% /notice %}}

{{% notice note %}}
**A note on providers:** These docs use **OpenBao** as the running example because it's SecureGuard's bundled default, but ESO is **provider-agnostic**. The same `SecretStore` → `ExternalSecret` flow works with AWS Secrets Manager, GCP Secret Manager, Azure Key Vault, HashiCorp Vault, and [many others](https://external-secrets.io/latest/introduction/stability-support/) — only the `SecretStore`'s `provider` block changes. Wherever you read "OpenBao" below, you can substitute your provider of choice.
{{% /notice %}}

## What is ESO?

ESO is an open-source Kubernetes operator designed to integrate external secret management systems directly into Kubernetes. Its primary job is to securely pull data out of OpenBao and inject it cleanly into the native Kubernetes namespaces where your applications actually run.

## Role in SecureGuard

Historically, developers had to write custom SDK logic into their apps or deploy complex sidecar containers to retrieve secrets from systems like OpenBao.

With ESO deployed as part of SecureGuard, applications remain completely oblivious to OpenBao's existence. Apps simply mount standard Kubernetes `Secret` objects (as volumes or environment variables). ESO continuously runs in the background, ensuring those standard `Secret` objects remain synchronized with the authoritative source (OpenBao).

## Core Custom Resources (CRDs)

ESO's workflow is governed by four primary Custom Resource Definitions. SecureGuard provides the visual UI to manage these objects.

### 1. SecretStore
A `SecretStore` is a namespaced configuration that tells ESO **how** to connect to OpenBao.
It defines:
*   The OpenBao server URL.
*   The exact OpenBao Namespace or KV Engine version (v1 vs v2).
*   The credentials ESO should use to authenticate (usually pointing to a specific Kubernetes Service Account).

### 2. ClusterSecretStore
Functionally identical to a `SecretStore`, but scoped globally. A `ClusterSecretStore` allows an administrator to define a single connection to OpenBao that developers in *any* Kubernetes namespace can utilize.

### 3. ExternalSecret
The `ExternalSecret` is the core object managed by developers. It defines **what** to fetch.
It specifies:
*   Which `SecretStore` or `ClusterSecretStore` to use to reach the vault.
*   The precise path in OpenBao where the secret resides (e.g., `kv/data/db/postgres`).
*   The exact key inside that OpenBao document to extract.
*   The name and format of the Kubernetes `Secret` that ESO should generate.

### 4. PushSecret
The reverse flow. Often, components *inside* Kubernetes generate credentials (e.g., a database operator generates a root password). A `PushSecret` allows you to take an existing Kubernetes `Secret` and automatically push it upstream into OpenBao for safe, centralized storage and auditing.

## SecureGuard & Companion Custom Resources

In addition to the four upstream ESO CRDs, the SecureGuard stack works with these resources:

### ReloaderConfig
A cluster-scoped resource (`reloader.external-secrets.io/v1alpha1`, kind `Config`) that makes secret delivery **event-driven** instead of poll-based. Each config wires one or more **notification sources** to one or more **trigger destinations**:

- **Notification sources** — a Kubernetes `Secret` or `ConfigMap` change, a cloud event (GCP Pub/Sub, AWS SQS, Azure Event Grid), a HashiCorp Vault audit-log event, a generic webhook, or a TCP socket.
- **Trigger destinations** — roll out a **Deployment**, or make an **ExternalSecret** / **PushSecret** reconcile immediately, or a **WorkflowRunTemplate**.

Typical uses: restart a Deployment the moment its Secret rotates, or trigger ESO to re-fetch on a cloud event or webhook rather than waiting for the next `refreshInterval`. Reloader is an [External Secrets companion project](https://external-secrets.github.io/reloader/) that SecureGuard bundles as an optional Helm sub-chart (`reloader.enabled`) and can also deploy to target clusters via an `ESODeployment`'s `reloader` block.

### ESODeployment
A namespaced SecureGuard resource (`deploy.secureguard.io/v1alpha1`) managed by the SG Agent Controller. It defines the desired ESO installation state for a target cluster, including version, namespace, component configuration, and replica counts.

### SGAgent
A cluster-scoped SecureGuard resource (`agent.secureguard.io/v1alpha1`) representing an agent registered with the central SecureGuard dashboard. SGAgents maintain heartbeat health status for connected clusters.

## Synchronization & Rotation

When evaluating an `ExternalSecret`, ESO uses a Reconciliation Loop.

*   **Refresh Interval**: You define how often ESO checks OpenBao for updates (e.g., `refreshInterval: 1h`).
*   **Automated Updates**: If a Security Admin updates a password inside OpenBao, ESO will detect the change upon its next polling cycle. It will instantly update the corresponding Kubernetes `Secret`.
*   **Zero Downtime**: Consequently, if your applications are built to watch for filesystem changes (like many modern cloud-native apps), the credentials rotate underneath the application without requiring a pod restart or human intervention.

## The Complete Workflow

To summarize how OpenBao and ESO collaborate in SecureGuard:

1.  **Storage**: A credential is created securely in OpenBao.
2.  **Connection**: A DevOps engineer creates a `SecretStore` in Kubernetes configuring the connection to OpenBao using a Kubernetes Service Account.
3.  **Definition**: A Developer defines an `ExternalSecret` referencing the `SecretStore` and the path to the credential.
4.  **Delivery**: The ESO Controller authenticates with OpenBao, retrieves the secret value via the API, generates a Kubernetes `Secret`, and continuously watches for any future updates.
