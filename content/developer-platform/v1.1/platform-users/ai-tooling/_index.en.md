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

KDP ships a set of **agent skills** and an **MCP server** that let you drive a KDP
environment from an AI coding assistant ([Claude Code](https://docs.anthropic.com/en/docs/claude-code)) —
browsing the service catalog, enabling services, creating resources, checking status, and
authoring Blueprints, in plain language.

{{% notice note %}}
This is separate from the dashboard's [AI Agent]({{< relref "../../setup/ai-agent" >}}), which
generates resource UI/forms inside the dashboard. The tooling here runs in your local AI
assistant against your KDP workspace.
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
- **kdp-mcp** — drives KDP through MCP tools instead of shell commands.

Each skill requires `kubectl` pointing at a KDP workspace (the `kdp-blueprints` skill also
needs the `blueprints.kdp.k8c.io` API and the services you want to compose already bound).

## MCP server

The **`mcp-kdp`** MCP server (`quay.io/kubermatic/mcp-kdp:latest`), used together with a
Kubernetes MCP server, lets the assistant call KDP tools directly — no shell commands
needed. It is the backend for the `kdp-mcp` skill.

## Skills or MCP — which to use

Both give an assistant the ability to act on KDP; they differ in how much you set up:

- **Skills** are Markdown instructions the assistant picks up from a folder — no server to
  run, simple to write and share, and constrained to their allowed tools. They are the best
  starting point for documented, repeatable workflows.
- **MCP (`mcp-kdp`)** is a stateful server the assistant calls directly. It handles richer,
  complex and authenticated operations, at the cost of deploying the server and adding it to
  your `.mcp.json`.

Start with the skills; add the MCP server when you need the richer, stateful tool surface.
The `kdp-mcp` skill combines the two.

## Permissions and safety

An agent is not a new security surface. It uses the **same API and RBAC as a human user** —
there is no separate, more-privileged path:

- **Platform level** — [kcp workspace isolation and RBAC]({{< relref "../rbac" >}}) apply
  exactly as they do for people. If a developer can't delete production databases from their
  workspace, neither can their agent.
- **Tool level** — the MCP server validates tool arguments against a JSON Schema, and skills
  are restricted to an allowed-tools list.

An agent handed a kubeconfig scoped to a workspace automatically inherits that workspace's
boundaries — nothing extra to configure.
