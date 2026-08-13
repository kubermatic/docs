+++
title = "CLI Compatibility Matrix"
linkTitle = "Compatibility"
date = 2025-08-27T00:00:00+01:00
description = "Supported KubeLB CLI and management-cluster version combinations."
weight = 30
+++

KubeLB CLI uses the Kubernetes management cluster that has KubeLB installed as its source of truth for the load balancing configurations.

Introduced alongside KubeLB v1.2, the CLI requires the KubeLB management cluster to be at least v1.2.

Starting with KubeLB v1.5.0, the CLI is released together with KubeLB and shares its version number; standalone versioning ended with v0.2.0. Use the CLI version that matches your management cluster release.

{{% notice note %}}
**Feature stage: Beta / Technical Preview.** Use KubeLB CLI for non-business-critical workflows and validate compatibility before upgrading.
{{% /notice %}}

| KubeLB CLI | KubeLB management cluster |
|------------|---------------------------|
| v0.1.0     | v1.2+                     |
| v0.2.0     | v1.2+                     |
| v1.5.0+    | same version as the CLI   |

## Support Policy

See the [KubeLB Support Policy](../../support-policy/).
