+++
title = "Monitoring, Logging & Alerting"
date = 2021-08-04T11:58:00+02:00
title_tag = "Monitoring, Logging & Alerting - Architecture Impact"
description = "Learn about the Kubermatic Kubernetes Platform MLA stack for the Master/Seed and User clusters"
weight = 7
+++

Kubermatic Monitoring, Logging & Alerting (MLA) consists of two stacks:

## Master / Seed Cluster MLA Stack

[Master / Seed Cluster MLA Stack]({{< ref "./master-seed/">}}) monitors KKP components running in the KKP master and seed clusters, including control plane components of the user clusters. Only KKP administrators can access this monitoring data.

## User Cluster MLA Stack

[User Cluster MLA Stack]({{< ref "./user-cluster/">}}) monitors applications running in the user clusters as well as system components running in the user clusters. All KKP users can access monitoring data of the user clusters under projects they are members of.

![KKP MLA Architecture](/img/kubermatic/v2.23/architecture/kkp-mla-architecture.png?classes=shadow,border "KKP MLA Architecture")
