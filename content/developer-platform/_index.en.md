+++
title = "Kubermatic Developer Platform"
sitemapexclude = true
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
A component called [**servlet**]({{< relref "service-providers/servlet" >}}) is installed onto service
clusters which allows service providers (who own the service clusters) to publish APIs from their
service cluster onto KDP's central platform.

KDP is based on [kcp](https://kcp.io), a CNCF Sandbox project to run many lightweight "logical"
clusters. Each of them acts as an independent Kubernetes API server to platform users and is called
a "Workspace". Workspaces are organized in a tree hierarchy, so there is a `root` workspace that has
child workspaces, and those can have child workspaces, and so on. In KDP, platform users own a certain
part of the workspace hierarchy (maybe just a single workspace, maybe a whole sub tree) and
self-manage those parts of the hierarchy that they own. This includes assigning permissions to
delegate certain tasks and subscribing to service APIs. Platform users can therefore "mix and match"
what APIs they want to have available in their workspaces to only consume the right services.

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
