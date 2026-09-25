+++
title = "AI Tooling (Skills & MCP)"
weight = 5
+++

Most AI assistants can *describe* your infrastructure but can't *operate* it — it's
scattered across Terraform repos, tickets, consoles and half-deprecated CLIs, with no single
interface an agent can act on. KDP is different: it exposes **one Kubernetes-native API
surface**, and — as Kubermatic's
[Giving AI Hands](https://www.kubermatic.com/blog/giving-ai-hands-how-kdp-makes-infrastructure-agent-ready/)
article puts it — "anything you do in the UI, you can do through the API." That single API
surface is what makes KDP **agent-ready**: an AI assistant can discover it and act on it.

KDP ships a set of **agent skills** and a hosted **MCP server** that let you drive a KDP
environment from an AI coding assistant such as
[Claude Code](https://docs.anthropic.com/en/docs/claude-code) or
[OpenCode](https://opencode.ai) — browsing the service catalog, creating resources, checking
status, and authoring Blueprints, in plain language.

{{% notice note %}}
This is separate from the dashboard's own AI assistance, which generates resource specs and forms
inside the dashboard. The tooling here runs in your local AI assistant against your KDP workspace.
{{% /notice %}}

## What an agent can do

Because every KDP service is a real Kubernetes API, an assistant can drive the same workflows
a human would:

- **Discover** — browse the service catalog (databases, certificate management, app engines, …).
- **Provision** — create resources by declaring desired state (e.g. a PostgreSQL instance).
- **Check status & get credentials** — read a resource's status and its connection secrets.
- **Bind into apps** — mount credentials and other [related resources]({{< relref "../managing-resources#related-resources" >}}) into workloads.
- **Compose** — author and publish [Blueprints]({{< relref "../../service-providers/blueprints" >}}) that bundle several services into one kind.
- **Operate at scale** — manage whole workspaces with multiple services and their dependencies.

## Skills

The following KDP skills are available for AI assistants:

- **kdp** — for platform users who just want to get things done. Uses `kubectl` under the
  hood but hides the internal terminology and talks to you in plain language.
- **kdp-kubectl** — the same workflows for service providers and platform engineers who want
  to see the internals, using real kcp terminology (APIBindings, APIExports, …).
- **kdp-blueprints** — for [Blueprint]({{< relref "../../service-providers/blueprints" >}})
  authors: walks through composing services into a `BlueprintDefinition`, validating,
  publishing, and smoke-testing an instance.
- **kdp-mcp** — drives KDP through the MCP tools below instead of shell commands. This is the
  only skill that needs no kubeconfig; it requires the MCP endpoint instead.

The `kdp`, `kdp-kubectl` and `kdp-blueprints` skills each require `kubectl` pointing at a KDP
workspace (`kdp-blueprints` also needs the `blueprints.kdp.k8c.io` API and the services you
want to compose already bound).

## MCP server

KDP hosts the `mcp-kdp` MCP server behind a gateway on the platform's public API domain, so
there is **nothing to install and no kubeconfig to manage**. The gateway authenticates you
with your normal platform account through a browser login, and every call then acts as **you**,
with exactly your permissions.

Add it to Claude Code:

```bash
claude mcp add --transport http \
  --client-id kdp-mcp \
  --callback-port 19876 \
  kdp https://public.api.<your-kdp-domain>/mcp
```

Or commit it to a repository as `.mcp.json`, so everyone working on it shares the same server:

```json
{
  "mcpServers": {
    "kdp": {
      "type": "http",
      "url": "https://public.api.<your-kdp-domain>/mcp",
      "oauth": { "clientId": "kdp-mcp", "callbackPort": 19876 }
    }
  }
}
```

For OpenCode, use `opencode.json`:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "kdp": {
      "type": "remote",
      "url": "https://public.api.<your-kdp-domain>/mcp",
      "enabled": true,
      "oauth": { "clientId": "kdp-mcp" }
    }
  }
}
```

Then start the assistant and complete the browser login when prompted.

The dashboard generates these snippets pre-filled with your environment's URL under
**Connect an AI agent** in the user menu, which is the easiest way to get the endpoint right.

{{% notice warning %}}
Two settings must be left as generated. **Do not change the callback port** — the matching
redirect URI is pre-registered with the identity provider, which matches it exactly, so any
other port is rejected at login. **Do not pin OAuth scopes** — the gateway advertises the
scopes it needs, including a dynamic scope that makes kcp accept the token. Setting
`oauth.scopes` in Claude Code overrides that and breaks authorization (in OpenCode,
`oauth.scope` is ignored in favour of the gateway's).
{{% /notice %}}

### Tools

The server exposes twelve tools covering both the platform and the resource layer, so no
second Kubernetes MCP server is needed:

| Tool | Purpose |
|---|---|
| `listServiceCatalog` | Browse the services visible from a workspace. |
| `getServiceCatalogEntry` | Resource schemas, permission claims and status for one service. |
| `listWorkspaces` | Child workspaces of a given path, with type, phase and URL. |
| `getWorkspaceInfo` | A workspace's path and cluster host URL. |
| `getServiceKubeconfig` | A kubeconfig blob for a workspace's service endpoint. |
| `listAvailableApis` | Resource kinds usable in a workspace (internal platform APIs excluded). |
| `getApiSchema` | The OpenAPI schema for a kind — worth reading before creating anything. |
| `listResources` / `getResource` | Read resources, optionally filtered by namespace or labels. |
| `createResource` / `updateResource` | Apply a YAML or JSON manifest. |
| `deleteResource` | Remove a resource by kind and name. |

### Workspaces

The server is **stateless**: there is no "current workspace" and no way to switch into one.
Every tool takes an explicit `workspace` path such as `root:demo` or `root:org:team`, so tell
your assistant which workspace you mean. It can discover children of a path it already knows
with `listWorkspaces`.

### What the MCP tools cannot do

- **Enable or disable a service.** That creates an APIBinding, which these tools deliberately
  do not manage — use the dashboard or the `kdp-kubectl` skill. An agent can browse the
  catalog and work with services that are already enabled.
- **Author or publish Blueprints.** Use the `kdp-blueprints` skill.
- **Fetch logs, exec into containers, or describe.** `getResource` returns the full object
  including `status` and conditions, which covers most troubleshooting; beyond that you need
  `kubectl`.

## Skills or MCP — which to use

Both give an assistant the ability to act on KDP; they differ in what you have to set up and
how wide the surface is:

- **Skills** are Markdown instructions the assistant picks up from a folder. They need a
  kubeconfig pointing at your workspace, but through `kubectl` they can reach anything your
  user can — including enabling services and authoring Blueprints.
- **The MCP server** needs no local setup at all beyond one config entry and a browser login,
  and gives the assistant a fixed, schema-validated set of tools. That surface is narrower by
  design: reading the catalog, and managing resources.

Use the MCP server for day-to-day work with resources, and a `kubectl`-based skill when you
need the operations the tools deliberately leave out. The `kdp-mcp` skill combines the two by
teaching the assistant how to use the MCP tools well.

## Permissions and safety

An agent is not a new security surface. It uses the **same API and RBAC as a human user** —
there is no separate, more-privileged path:

- **Platform level** — [kcp workspace isolation and RBAC]({{< relref "../rbac" >}}) apply
  exactly as they do for people. If a developer can't delete production databases from their
  workspace, neither can their agent.
- **Identity** — the gateway validates your token and forwards it unchanged, so kcp sees
  *you*, and the audit trail names you. Nothing runs under a shared service identity.
- **Tool level** — the MCP server validates tool arguments against a JSON Schema, and skills
  are restricted to an allowed-tools list.

An agent handed a kubeconfig scoped to a workspace likewise inherits that workspace's
boundaries — nothing extra to configure.

## See also

- [MCP Gateway]({{< relref "../../setup/mcp-gateway" >}}) — how an operator enables the hosted
  endpoint.
- [Consuming Services]({{< relref "../consuming-services" >}}) — enabling a service so an agent
  can use it.
- [RBAC]({{< relref "../rbac" >}}) — the permission model an agent inherits.
