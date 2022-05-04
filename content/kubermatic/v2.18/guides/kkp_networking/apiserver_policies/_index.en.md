+++
title = "API Server Network Policies"
description = "KKP uses NetworkPolicies to constraint the egress traffic of the Kubernetes API Server. Read this section for more detail."
date = 2020-02-14T12:07:15+02:00
weight = 120
+++

To ensure proper isolation of control plane components in Seed clusters, as of KKP version 2.18, KKP uses NetworkPolicies to constraint the egress traffic of the Kubernetes API Server.

The egress traffic of the API Server pods is restricted to the following set of control plane pods of the same user cluster:

- etcd
- dns-resolver
- openvpn-server
- machine-controller-webhook
- metrics-server

The NetworkPolicies are automatically applied to all newly created clusters. For previously existing clusters, the feature can be activated by adding the feature gate `apiserverNetworkPolicy` to the Cluster resource / API object (Cluster `spec.features`). The same feature gate can be used to disable reconciliation of the NetworkPolicies, which can be manually deleted in case of need.

To ensure that NetworkPolicies are actually in place, make sure that the CNI plugin used for the Seed cluster supports the NetworkPolicies.
