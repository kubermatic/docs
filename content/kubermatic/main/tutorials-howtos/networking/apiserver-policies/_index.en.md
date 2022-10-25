+++
title = "API Server Access Control"
date = 2020-02-14T12:07:15+02:00
weight = 120
enableToc = true
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

## API Server Allowed Source IP ranges
Since KKP v2.22, it is possible to restrict the access to the user cluster API server based on the source IP ranges. To restrict the server access from the internet or to have a limited access,`apiServerAllowedIPRanges` need to be configured. It is also important to note that you allow IP range of the worker nodes too, otherwise worker nodes will not be able to connect to the api server.

In the cluster spec, set the `apiServerAllowedIPRanges` as shown in below example, 

```yaml
spec:
  exposeStrategy: LoadBalancer
  apiServerAllowedIPRanges:
    cidrBlocks:
    - 192.168.1.0/32
```
