+++
title = "Cluster Network Configuration"
description = "The networking parameters provided by KKP API can be easily configured with the help of the KKP API endpoint for managing clusters. Go through our guide to know how!"
date = 2021-09-07T16:06:10+02:00
weight = 10
+++

KKP API provides several networking parameters that can be defined for each user cluster. These can be configured via KKP API endpoint for managing clusters:

`/api/v2/projects/{project_id}/clusters/{cluster_id}`

The networking parameters are configurable in `spec.clusterNetwork`. Some of them can be also configured via KKP UI on the Cluster configuration page, as shown below:

![KKP UI - Network Configuration](/img/kubermatic/v2.18/guides/networking/networking_ui.png)

When no explicit value for a setting is provided, the default value is applied. The following table summarizes the parameters configurable via `spec.clusterNetwork` in the cluster API with their default values:

| Parameter                  | Default Value                                       | Description
| -------------------------- | --------------------------------------------------- | ---------------------------------------------------------
| `pods.cidrBlocks`          | `[172.25.0.0/16]` (`[172.26.0.0/16]` for Kubevirt)  | The network ranges from which POD networks are allocated.
| `services.cidrBlocks`      | `[10.240.16.0/20]` (`[10.241.0.0/20]` for Kubevirt) | The network ranges from which service VIPs are allocated.
| `proxyMode`                | `ipvs`                                              | kube-proxy mode (`ipvs`/ `iptables`).
| `dnsDomain`                | `cluster.local`                                     | Domain name for k8s services.
| `ipvs.strictArp`           | `true` for `ipvs` proxyMode, `false` otherwise      | If enabled, configures `arp_ignore` and `arp_announce` kernel parameters to avoid answering ARP queries from `kube-ipvs0` interface.
| `nodeLocalDNSCacheEnabled` | `true`                                              | Enables NodeLocal DNS Cache feature.
| `konnectivityEnabled`      | `false`                                             | Enables [Konnectivity service](https://kubernetes.io/docs/concepts/architecture/control-plane-node-communication/#konnectivity-service) for control plane to node network communication. Requires `KonnectivityService` feature gate in the `KubermaticConfiguration` to be enabled.
