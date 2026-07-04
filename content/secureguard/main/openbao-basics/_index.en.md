+++
title = "OpenBao Basics"
date = 2026-06-13T09:00:00+02:00
weight = 5
description = "Understand OpenBao — the open-source, production-grade secrets vault bundled with Kubermatic SecureGuard — including secret engines, auth methods, and unsealing."
sitemapexclude = true
searchexclude = true
private = true
+++

[OpenBao](https://openbao.org/) is the open-source, production-grade secrets management backend at the heart of Kubermatic SecureGuard. It was forked from HashiCorp Vault to provide a completely open, community-driven cryptographic engine.

{{% notice tip %}}
**In plain English:** OpenBao is a high-security vault for your secrets — like a bank vault, but for passwords, API keys, and certificates. Instead of scattering credentials across config files and `.env` files, you store them in one encrypted, audited place and hand out access carefully. Apps don't open the vault themselves; ESO fetches what they need on their behalf (see [ESO Basics]({{< ref "../eso-basics/" >}})).

Unfamiliar with a term below (KV engine, auth method, unsealing)? The [Glossary]({{< ref "../glossary/" >}}) defines each in one line.
{{% /notice %}}

{{% notice note %}}
**OpenBao is optional — it's an opinionated default, not a requirement.** SecureGuard bundles OpenBao so teams **without** an existing vault get a complete stack out of the box. If you already run a secrets backend, you don't need OpenBao at all: SecureGuard manages **ESO**, and ESO works with many providers — AWS Secrets Manager, GCP Secret Manager, Azure Key Vault, HashiCorp Vault, and [others](https://external-secrets.io/latest/introduction/stability-support/). Just point your `SecretStore`/`ClusterSecretStore` resources at your provider and disable the bundled OpenBao (`--set openbao.enabled=false`). The rest of this page applies only if you choose to use OpenBao as your backend.
{{% /notice %}}

## What is OpenBao?

OpenBao provides a centralized, highly secure vault for managing sensitive data tightly. It effectively removes secrets from application source code, configuration files, and basic Kubernetes secrets until they are explicitly needed.

## Key Concepts

To effectively operate OpenBao within SecureGuard, you must understand three core concepts:

### 1. Secret Engines
Secret Engines are the components inside OpenBao where data is either stored, generated, or encrypted.
*   **Key/Value (KV)**: This is the most common engine used with SecureGuard. It stores static secrets, structured as JSON objects, at specific hierarchical paths (e.g., `secret/data/database/postgres/password`).
*   **Dynamic Secrets**: OpenBao can dynamically generate credentials for databases (e.g., MySQL, PostgreSQL), cloud providers (AWS, GCP), or message queues (RabbitMQ) on-the-fly when requested, ensuring credentials have a naturally limited Time-To-Live (TTL).
*   **Transit Engine**: Offers "encryption as a service," allowing applications to encrypt or decrypt data without actually storing it in OpenBao.

### 2. Auth Methods
Auth methods represent how users or machines prove their identity to OpenBao.
*   **OIDC (OpenID Connect)**: Dashboard authentication and OpenBao authentication are separate flows. Dashboard users authenticate via Dex (OIDC) to access the UI. Independently, ESO authenticates to OpenBao using Kubernetes Service Account tokens via the `kubernetes` auth method — dashboard users do not authenticate to OpenBao directly.
*   **Kubernetes Auth**: Used by the External Secrets Operator (ESO). ESO running in your cluster presents a Kubernetes Service Account token to OpenBao. OpenBao verifies the token's validity with the Kubernetes API server before granting access.

### 3. Audit Devices
Every request to OpenBao, whether it is a read from ESO or a write from a developer, is securely logged. These Audit Devices output JSON-formatted logs directly to stdout, syslog, or a file, which can then be ingested by tools like Elasticsearch or Splunk for compliance and anomaly detection.

## The Role of OpenBao in SecureGuard

Within the SecureGuard ecosystem, OpenBao acts purely as the **Central Vault**.
It handles:
1.  **Encryption**: Ensuring all secrets are encrypted both in transit and at rest using industry-standard encryption (AES-256-GCM for storage, TLS 1.2+ for transit).
2.  **RBAC (Role-Based Access Control)**: Enforcing strict least-privilege policies. You define *who* (which OIDC group or which Kubernetes Service Account) can read *what* paths.
3.  **Multi-Tenancy**: Through its namespace features, OpenBao allows large organizations to isolate teams. "Team A" vault paths are completely invisible to "Team B".

## Understanding Unsealing & High Availability

By default, an OpenBao server starts in a **Sealed** state. It knows where to find the encrypted data, but it does not know how to decrypt it because it lacks the master key.

*   **Manual Unsealing**: Requires multiple operators to independently enter shards of the master key. This is secure but impractical for cloud-native orchestration (e.g., if a pod simply restarts).
*   **Auto-Unseal**: In production SecureGuard setups, OpenBao is configured with an Auto-Unseal mechanism (like AWS KMS or Azure Key Vault). When the pod starts, it automatically reaches out to the KMS to retrieve the key and decrypts itself, enabling seamless cluster scaling and recovery.

When clustered for **High Availability (HA)** using Integrated Raft Storage, only one OpenBao node is the "Active" node processing writes, while the others serve as "Standbys". If the active node fails, another node instantly takes over, guaranteeing virtually zero downtime for your secret synchronization.
