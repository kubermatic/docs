+++
title = "Enterprise Edition"
date = 2023-01-31T12:11:35+02:00
weight = 6

+++

## Why is there Enterprise Edition and Community Edition

Kubermatic Kubernetes Platform (KKP) is an open-source product, and both the Community Edition and the Enterprise Edition are available to download from GitHub. However, there are some extra features that are only available in the Enterprise Edition of Kubermatic Kubernetes Platform.

## Extra Features of Enterprise Edition

| Features                                    | Description                                                                                                                                                                                   |
| ------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Multiple seed clusters                      | Independent management zones for edge, cloud and on-premise sites.                                                                                                                            |
| OPA - Allowlist for Docker registries + API | Allows users to set which image registries are allowed, so only workloads from those registries can be deployed on user clusters.                                                             |
| Metering                                    | Scheduled consumption reports for KKP admins generated automatically by datacenters and projects.                                                                                             |
| Resource Quotas                             | KKP admins can define consumption caps for different projects.                                                                                                                                |
| Group Project bindings                      | Projects can be bound to user groups defined in your authentication provider.                                                                                                                 |
| Edge capabilities                           | Independent operation from the control plane and workload allocation among different clusters.                                                                                                |
| User Cluster Backup                         | Backups can be done in KKP (through Velero integration) for user clusters in order to transport full clusters, and be able to restore only specific namespaces of a chosen user cluster.      |

## How to use Enterprise Edition

If you are willing to use Enterprise Edition, you'll need to [insert a secret during the installation]({{< ref "../../installation/install-kkp-ee/" >}}). In order to own this secret, you will need to be our customer. If you are interested in being our customer, please [contact us](https://www.kubermatic.com/contact-us/) or check our AWS marketplace listing.
