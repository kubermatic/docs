+++
title = "CLI Compatibility Matrix"
date = 2025-08-27T00:00:00+01:00
weight = 30
+++

KubeLB CLI uses the Kubernetes management cluster that has KubeLB installed as its source of truth for the load balancing configurations.

Introduced alongside KubeLB v1.2, the CLI requires the KubeLB management cluster to be at least v1.2.

{{% notice note %}}
KubeLB CLI is in beta and not yet ready for production use.
{{% /notice %}}

| KubeLB CLI | KubeLB Management Cluster |
|------------|---------------------------|
| v0.1.0     | v1.2+                     |

## Support Policy

See the [KubeLB Support Policy](../../support-policy/).
