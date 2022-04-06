+++
title = "Comparing KubeOne with Kubermatic Kubernetes Platform (KKP)"
description = "Read on the document to understand the key differences between Kubermatic Kubernetes Platform and KubeOne and gain an understanding of which one is better suited for your particular use case."
date = 2019-11-28T14:18:30+01:00
weight = 5

+++

Feature/Capability | KubeOne | KKP
--- | --- | ---
Provision Kubernetes Cluster | Run one cluster | Built to operate 1000x of clusters
Support for HA (multi-node) control-planes | yes | yes
Manage Cluster Lifecycle (Update/Delete etc.) | One at a time | Many at once
CNCF conformant "vanilla" Kubernetes | yes, certified | yes, certified
Kubernetes Control Plane | VM based | Runs inside Master K8s cluster, Pod based (as Container)
Maintenance effort | medium, each cluster must be operated individually | very low, full automation
Self healing clusters | Mostly, but in case of an outage of a master node, manual work is required | yes, via running Kubernetes control plane inside of Kubernetes
User interface | CLI | Web UI, REST API
User management | - | yes, including multi-tenancy
Automatic Backups | - | yes, via Velero
Multi cluster Logging | - | yes, via EFK stack
Multi cluster Metrics Collection | - | yes, via Prometheus
Multi cluster Graphing | - | yes, via Grafana
Integration into identity providers | Individual per cluster | Central for all clusters: AD/LDAP, GitHub, SAML 2.0, GitLab, OpenID Connect, ... etc.
Deploy cluster addons | - | yes
Service Accounts for automation/integration | - | yes
Cluster blueprints and presets | - | yes
SSH Key management for worker node access | yes | yes
White labeling | - | yes
Built for Cloud/Service Provider | - | yes
