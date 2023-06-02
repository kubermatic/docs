+++
title = "API Server Access Control"
date = 2020-02-14T12:07:15+02:00
weight = 120
+++

## API Server Network Policies
To ensure proper isolation of control plane components in Seed clusters, as of KKP version 2.18, KKP uses NetworkPolicies to constraint the egress traffic of the Kubernetes API Server.

The egress traffic of the API Server pods is restricted to the following set of control plane pods of the same user cluster:

- etcd
- dns-resolver
- openvpn-server
- machine-controller-webhook
- metrics-server

The NetworkPolicies are automatically applied to all newly created clusters. For previously existing clusters, the feature can be activated by adding the feature gate `apiserverNetworkPolicy` to the Cluster resource / API object (Cluster `spec.features`).

To ensure that NetworkPolicies are actually in place, make sure that the CNI plugin used for the Seed cluster supports the NetworkPolicies.

## Disabling API Server Network Policies
Under certain situations (e.g. for debugging purposes), it may be necessary to disable API Server Network Policies. This can be done either for an existing user cluster, or globally on seed cluster level.

### In a User Cluster
In an already existing user cluster, the API Server Network Policies can be disabled manually using these steps:

 - remove the feature gate `apiserverNetworkPolicy` in the Cluster resource / API object (Cluster `spec.features`),
 - manually delete all NetworkPolicy resources in the user cluster namespace of the seed cluster (see `kubectl get networkpolicy -n cluster-<cluster-id>`).

### In a Seed Cluster
The API Server Network Policies can be disabled for all newly created user clusters on the Seed cluster level using the [Defaulting Cluster Template]({{< ref "../../../tutorials-howtos/project-and-cluster-management/cluster-defaulting" >}}) feature.

In the defaulting cluster template, set the `apiserverNetworkPolicy` feature gate to `false`, e.g.:

```yaml
spec:
  features:
    apiserverNetworkPolicy: false
```

Please note that this procedure does not affect already running user clusters, for those the API Server Network Policies need to be disabled individually as described in the previous section.

## API Server Allowed Source IP Ranges

Since KKP v2.22, it is possible to restrict the access to the user cluster API server based on the source IP ranges. By default (when not configured), the access is not restricted and the API server is accessible from anywhere. To restrict the API server access, Cluster's `spec.apiServerAllowedIPRanges` needs to be configured with the list of allowed IP ranges (CIDR blocks). Access from IP addresses outside the configured ranges will be denied.

{{% notice info %}}

This feature is available only for user clusters with the `LoadBalancer` [Expose Strategy]({{< relref "../expose-strategies/" >}}). It also depends on cloud provider's support for service's `loadBalancerSourceRanges`, which may not be available on all platforms (e.g. does not work on AWS with ELB load balancer).

{{% /notice %}}

{{% notice warning %}}

When restricting access to the API server, it is important to allow IP ranges of the user cluster's worker nodes network (to allow kubelet to apiserver communication), IP ranges of the KKP main cluster's worker nodes (to allow access of the kubermatic-api for proper KKP dashboard operation) and KKP seed cluster's worker nodes too.

{{% /notice %}}

To restrict the access to the API server, set the `apiServerAllowedIPRanges` in the in the cluster spec, as shown in the example below:

```yaml
spec:
  exposeStrategy: LoadBalancer
  apiServerAllowedIPRanges:
    cidrBlocks:
    - 192.168.1.10/32
```

This can be also configured from the KKP UI, either during cluster creation, under the "Network Configuration" > "Advanced Network Configuration":

![Allowed IP Ranges - Cluster Creation](/img/kubermatic/main/tutorials/networking/network_config_allowed_ip_ranges.png?height=400px&classes=shadow,border "Allowed IP Ranges - Cluster Creation")

or in an existing cluster via the "Edit Cluster" dialog:

![Allowed IP Ranges - Edit Cluster](/img/kubermatic/main/tutorials/networking/cluster_details_allowed_ip_ranges.png?height=400px&classes=shadow,border "Allowed IP Ranges - Edit Cluster")