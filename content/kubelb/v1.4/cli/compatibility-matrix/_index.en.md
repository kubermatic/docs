+++
title = "Compatibility Matrix"
date = 2025-08-27T00:00:00+01:00
weight = 30
+++

KubeLB CLI uses Kubernetes management cluster that has KubeLB installed as it's source of truth for the load balancing configurations.

Since it has been introduced alongside KubeLB v1.2, it has a hard dependency for the KubeLB management cluster to be at least v1.2.

{{% notice note %}}
KubeLB CLI is currently in beta feature stage and is not yet ready for production use. We are actively working on the feature set and taking feedback from the community and our customers to improve the CLI.
{{% /notice %}}

| KubeLB CLI | KubeLB Management Cluster |
|------------|---------------------------|
| v0.1.0     | v1.2+                     |

## Support Policy

For support policy, please refer to the [KubeLB Support Policy](../../support-policy/)
