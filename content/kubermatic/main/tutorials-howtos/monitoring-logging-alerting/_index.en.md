+++
title = "Monitoring, Logging & Alerting"
date = 2021-08-06T11:58:00+02:00
title_tag = "Monitoring, Logging & Alerting - Tutorial"
description = "Learn about the architectural impact of the KKP Monitoring, Logging and Alerting Stack"
weight = 4
+++
Kubermatic Monitoring, Logging & Alerting (MLA) consists of two stacks:

## [Master / Seed Cluster MLA Stack]({{< ref "./master-seed/">}})

Monitors KKP components running in the KKP master and seed clusters, including control plane components of the user clusters. Only KKP administrators can access this monitoring data.

## [User Cluster MLA Stack]({{< ref "./user-cluster/">}})

Monitors applications running in the user clusters as well as system components running in the user clusters. All KKP users can access monitoring data of the user clusters under projects they are members of.
