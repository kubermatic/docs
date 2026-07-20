+++
title = "Kubermatic Developer Platform"
+++

KDP (Kubermatic Developer Platform) is a new Kubermatic product in development that targets the IDP
(Internal Developer Platform) segment. This segment is part of a larger shift in the ecosystem to
"Platform Engineering", which champions the idea that DevOps in its effective form didn't quite work
out and that IT infrastructure needs new paradigms. The core idea of Platform Engineering is that
internal platforms provide higher-level services so that development teams no longer need to spend
time on operating components not core to their applications. These internal services are designed in
alignment with company policies and provide a customized framework for running applications and/or
their dependencies.

KDP offers a central control plane for IDPs by providing an API backbone that allows to register (as
service provider) and consume (as platform user) **services**. KDP itself does **not** host the
actual workloads providing such services (e.g. if a database service is offered, the underlying
PostgreSQL pods are not hosted in KDP) and instead delegates this to so-called **service clusters**.
A component called [**api-syncagent**]({{< relref "service-providers/api-syncagent" >}}) is installed
onto service clusters which allows service providers (who own the service clusters) to publish APIs
from their service cluster onto KDP's central platform.

KDP is based on [kcp](https://kcp.io), a CNCF Sandbox project to run many lightweight "logical"
clusters. Each of them acts as an independent Kubernetes API server to platform users and is called
a "Workspace". Workspaces are organized in a tree hierarchy, so there is a `root` workspace that has
child workspaces, and those can have child workspaces, and so on. In KDP, **organizations** own a
top-level workspace, and within an organization, users can create **projects** (nested workspaces)
to structure their resources. Projects can themselves contain sub-projects, enabling flexible
multi-tenancy. This includes assigning permissions to delegate certain tasks and subscribing to
service APIs. Platform users can therefore "mix and match" what APIs they want to have available in
their workspaces to only consume the right services.

KDP is an automation/DevOps/GitOps-friendly product and is "API-driven". Since it exposes
Kubernetes-style APIs it can be used with a lot of existing tooling (e.g. `kubectl` works to manage
resources). We have decided against an intermediate API (like we have in KKP) and the KDP Dashboard
directly interacts with the Kubernetes APIs exposed by kcp. As such everything available from the
Dashboard will be available from the API. A way for service providers to plug in custom dashboard
logic is planned, but not realized yet.

Service APIs are not pre-defined by KDP, and as such are subject to API design in the actual
installation. Crossplane on the service cluster can be used to provide abstraction APIs that are then
reconciled to more complex resource bundles. The level of abstraction in an API is up to service
providers and will vary from setup to setup.

## Why KDP: a platform, not a portal

Many "internal developer platforms" are really *portals* — a catalog UI that answers
*"what do we have?"*. They help developers discover services, but the moment someone
actually wants one, they fall back to a ticket, a Slack message or a hand-written GitOps
pull request. The catalog looks polished, but — as Kubermatic's
[Portal vs Platform](https://www.kubermatic.com/blog/portal-vs-platform/) article puts it —
"the developer experience ends at the catalog."

KDP is a *platform*: it answers *"what can I get right now?"*. Requesting a service creates a
real Kubernetes resource that is provisioned automatically — there is no manual last mile.
Concretely, this is what sets KDP apart:

- **Kubernetes-native APIs, not a proprietary framework.** Every service is a real API you
  drive with `kubectl`, CI, GitOps and your existing automation — there is no bespoke SDK,
  specification language or plugin system to learn or to keep running.
- **Provisioning, not just discovery.** Enabling a service and creating an object actually
  provisions it, in seconds, through the very same API the Dashboard uses.
- **True multi-tenancy.** kcp workspaces give each organization and project its own isolated,
  independent Kubernetes API — stronger and simpler than fragile namespace-plus-RBAC schemes.
- **Service-owner self-service.** Service providers publish their own offerings onto the
  platform, so the platform team is not a bottleneck for every new service. Higher-level
  offerings can be composed from existing services with
  [Blueprints]({{< relref "service-providers/blueprints" >}}).
- **AI- and agent-ready.** Because everything is a machine-readable Kubernetes API, AI
  assistants and agents can discover and provision resources too — see
  [AI Tooling]({{< relref "platform-users/ai-tooling" >}}).

## Architecture

![KDP Architecture](kdp-architecture.png?classes=shadow,border "KDP reference architecture showing the control plane, workspace hierarchy, and service clusters")

## Personas

KDP has several types of people that we identified as stakeholders in an Internal Developer Platform
based on KDP. Here is a brief overview:

- **Platform Users** are the end users (often application developers or "DevOps engineers") in an
  IDP. They consume services (e.g. they want a database or they have a container image that they want
  to be started), own workspaces and self-organize within those workspaces.
- **Service Providers** offer services to developers. They register APIs that they want to provide on
  the service "marketplace" and they operate service clusters and controllers/operators on those
  service clusters that actually provide the services in question.
- **Platform Owners** are responsible for keeping KDP itself available and assign top-level
  permissions so that developers and service providers can then utilize self-service capabilities.
