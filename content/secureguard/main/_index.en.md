+++
title = "Kubermatic SecureGuard"
date = 2026-06-13T09:00:00+02:00
weight = 8
description = "Protect and manage secrets with open-source transparency — a Kubernetes-native secrets management platform built on OpenBao and the External Secrets Operator."
sitemapexclude = true
searchexclude = true
private = true
+++

{{% notice warning %}}
SecureGuard is currently under active development. This documentation is a preview and is not yet publicly announced. Content is subject to change.
{{% /notice %}}

**Protect and manage secrets with open-source transparency.**

Kubermatic SecureGuard is a self-hosted, open-source secrets management platform designed for modern, Kubernetes-native environments. It acts as a secure transport layer for secrets, bridging the gap between high-security cryptographic storage and dynamic application needs.

By merging the cryptographic hardening of **OpenBao** with the native orchestration of the **External Secrets Operator (ESO)**, SecureGuard provides a unified, production-grade secrets management solution. It eliminates fragmented secrets management, reduces vendor lock-in, and gives developers native access to credentials directly within Kubernetes.

## In Plain English

Every app needs **secrets** — passwords, API keys, database credentials, TLS certificates. The hard questions are: *where do you store them safely?* and *how do they get to the apps that need them without leaking?*

SecureGuard answers both by combining three open-source tools and putting a friendly, **read-only-by-default dashboard** on top:

- **OpenBao** is the **vault** — the one safe, encrypted place where secrets actually live.
- **ESO** (External Secrets Operator) is the **delivery service** — it copies secrets out of the vault into the standard Kubernetes `Secret` objects your apps already use, and keeps them up to date.
- **SecureGuard's dashboard** is the **control room** — it lets you see and manage all of this without memorizing `kubectl` commands, and **without ever exposing the secret values themselves** (the dashboard shows `••••••••`, never the real value).

{{% notice note %}}
**OpenBao is optional.** It's our **opinionated default** so teams without a vault get a complete, batteries-included stack out of the box. But SecureGuard is **provider-agnostic**: ESO supports many backends (AWS Secrets Manager, GCP Secret Manager, Azure Key Vault, HashiCorp Vault, and [more](https://external-secrets.io/latest/introduction/stability-support/)). If you already have a vault, point your `SecretStore`s at it and disable the bundled OpenBao (`--set openbao.enabled=false`). Everything else works the same.
{{% /notice %}}

> **Analogy:** Think of OpenBao as a bank vault, ESO as the armored truck that delivers cash to ATMs (your apps), and SecureGuard as the security desk with the camera monitors — you can watch and direct everything, but you can't reach into the vault and pull the cash out through the monitor.

## How It Works (The Big Picture)

```text
   1. STORE                 2. DELIVER                    3. USE
 ┌──────────┐   ESO pulls  ┌──────────────────┐  app reads  ┌──────────┐
 │ OpenBao  │ ───────────▶ │ Kubernetes Secret│ ──────────▶ │ Your App │
 │ (vault)  │   & syncs    │  (auto-created)  │  as env/file│          │
 └──────────┘              └──────────────────┘             └──────────┘
       ▲                            ▲
       │  you configure & watch all of this from
       └──────────  the SecureGuard dashboard  ──────────┘
                    (values stay masked: ••••••••)
```

1. **Store** a secret once in OpenBao (the vault).
2. ESO **delivers** it into a normal Kubernetes `Secret` and keeps it in sync — if you change it in the vault, ESO updates the copy automatically.
3. Your app **uses** that `Secret` like any other (no special SDK or code changes).

You manage steps 1–2 from the SecureGuard dashboard. New to the terms above? See the **[Glossary]({{< ref "/secureguard/main/glossary/" >}})**.

## Core Features
- **OpenBao Core:** Secure backend with encryption in transit and at rest, fine-grained access controls, and full audit logs.
- **ESO Integration:** Dispatches secrets directly into Kubernetes clusters or between multiple external secret stores.
- **Native Kubernetes Secrets Support:** Developers use standard `Secret` objects—no app rewrites or SDKs required.
- **Centralized Management:** Provides a single source of truth across all environments and clusters.
- **Multi-Cluster Support:** Manage ESO deployments across clusters via the SG Agent Controller and ESODeployment CRDs.
- **Federation (optional):** Serve secrets to remote clusters over mTLS without exposing the backend stores — via a standalone broker and the `fedclient` consumer.
- **ReloaderConfig:** Event-driven workload reloading when synced secrets change.
- **Developer First:** Built-in React dashboard for visualizing and managing the secret sync lifecycle.
- **Zero-Knowledge Security:** Secret values are redacted at the proxy layer — they never reach the browser.

## Target Audience
- **Security Architects**: Establish centralized governance, enforce least-privilege access, and maintain comprehensive audit trails.
- **DevOps & Platform Teams**: Automate the secrets lifecycle, eliminating manual ticketing and enabling "breakage-free" rotation.
- **Developers**: Get immediate, native access to credentials (including AI tokens and API keys) directly within Kubernetes.

## New Here? Where to Start

Not sure which doc to read first? Pick the path that matches you:

| If you are… | Start with… | Then read… |
|---|---|---|
| **Brand new to secrets in Kubernetes** | [OpenBao Basics]({{< ref "/secureguard/main/openbao-basics/" >}}) → [ESO Basics]({{< ref "/secureguard/main/eso-basics/" >}}) | [Glossary]({{< ref "/secureguard/main/glossary/" >}}), [Getting Started]({{< ref "/secureguard/main/getting-started/" >}}) |
| **Just want to try it locally** | [Getting Started]({{< ref "/secureguard/main/getting-started/" >}}) | [User Guide]({{< ref "/secureguard/main/user-guide/" >}}) |
| **A developer using the dashboard day-to-day** | [User Guide]({{< ref "/secureguard/main/user-guide/" >}}) | [Glossary]({{< ref "/secureguard/main/glossary/" >}}) |
| **An operator deploying to production** | [Installation]({{< ref "/secureguard/main/installation/" >}}) | [Security Hardening]({{< ref "/secureguard/main/security-hardening/" >}}), [Advanced Configuration]({{< ref "/secureguard/main/advanced-configuration/" >}}) |
| **Integrating or debugging the API** | [Architecture]({{< ref "/secureguard/main/architecture/" >}}) | [API Reference]({{< ref "/secureguard/main/api-reference/" >}}) |

{{% notice tip %}}
Keep the [Glossary]({{< ref "/secureguard/main/glossary/" >}}) open in a tab. Whenever a term like *ESO*, *SecretStore*, *CRD*, *OIDC*, or *unsealing* is unclear, it's defined there in one line.
{{% /notice %}}

## Documentation

{{% children depth=5 %}}
{{% /children %}}
