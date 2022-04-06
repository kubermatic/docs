+++
title = "Monitoring, Logging & Alerting"
description = "Kubermatic Kubernetes Platform's Monitoring, Logging & Alerting (MLA) consists of two stacks: the master cluster stack and the user cluster stack."
date = 2021-08-04T11:58:00+02:00
weight = 20
+++

Kubermatic Monitoring, Logging & Alerting (MLA) consists of two stacks:

## [Master / Seed Cluster MLA Stack]({{< ref "./master_seed/">}})

Monitors KKP components running in the KKP master and seed clusters, including control plane components of the user clusters. Only KKP administrators can access this monitoring data.

## [User Cluster MLA Stack]({{< ref "./user_cluster/">}})

Monitors applications running in the user clusters as well as system components running in the user clusters. All KKP users can access monitoring data of the user clusters under projects they are members of.
