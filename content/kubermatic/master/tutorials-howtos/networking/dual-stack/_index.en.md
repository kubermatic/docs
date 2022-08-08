+++
linkTitle = "Dual-Stack Networking"
title = "Dual-Stack (IPv4 + IPv6) Networking"
date = 2022-08-01T15:06:10+02:00
weight = 20
enableToc = true
+++

## Feature Overview

Since Kubernetes 1.20, Kubernetes clusters can run in dual-stack mode, which allows simultaneous usage of both
IPv4 and IPv6 addresses in the cluster. In dual-stack clusters, Kubernetes nodes and pods have both IPv4 and IPv6 addresses,
and Kubernetes services can use IPv4, IPv6, or both address families, which  can be indicated in service's `spec.ipFamilies`.

While upstream Kubernetes now supports dual-stack networking as a GA or stable feature,
each provider’s support of dual-stack Kubernetes may vary.

KKP supports dual-stack networking for KKP-managed user clusters for the following providers:

 - AWS
 - Azure
 - BYO / kubeadm
 - DigitalOcean
 - Equinix Metal
 - GCP
 - Hetzner
 - OpenStack
 - VMware vSphere

Dual-stack [specifics & limitations of individual cloud-providers](#cloud-provider-specifics-and-limitations) are listed below.


## Enabling Dual-Stack Networking for a User Cluster
Dual-stack networking can be enabled for each user-cluster across one of the supported cloud providers. Please
refer to [provider-specific documentation](#cloud-provider-specifics-and-limitations) below to see if it is supported globally,
or it needs to be enabled on the datacenter level.

Dual-stack can be enabled for each supported CNI (both Canal and Cilium).

### Enabling Dual-Stack Networking from KKP UI
If dual-stack networking is available for the given provider and datacenter, an option for choosing between
`IPv4` and `IPv4 and IPv6 (Dual Stack)` becomes automatically available on the cluster details page in the cluster
creation wizard:

![Cluster Settings - Network Configuration - IPv4 vs. Dual-Stack](/img/kubermatic/master/tutorials/networking/ui_cluster_ip_family.png?classes=shadow,border "Cluster Settings - Network Configuration - IPv4 vs. Dual-Stack")

After clicking on the `ADVANCED NETWORKING CONFIGURATION` button, more detailed networking configuration can be provided.
In case of a dual-stack cluster, the pods & services CIDRs, the node CIDR mask size and the allowed IP range for nodePorts
can be configured separately for each address family:

![Cluster Settings - Network Configuration - Advanced Dual-Stack Configuration](/img/kubermatic/master/tutorials/networking/ui_cluster_advanced_nw_config.png?classes=shadow,border "Cluster Settings - Network Configuration - Advanced Dual-Stack Configuration")

The rest of the cluster creation process remains the same as for single-stack user clusters.

### Enabling Dual-Stack Networking from KKP API

Dual-Stack networking can be enabled in two ways from the KKP API:

1. The easy way relies on defaulting of the pods & services CIDRs. To enable dual-stack networking for a user cluster
without specifying pod / services CIDRs for individual address families, just set the cluster's
`spec.clusterNetwork.ipFamily` to `IPv4+IPv6` and leave `spec.clusterNetwork.pods` and `spec.clusterNetwork.services` empty.
They will be defaulted as described on the [CNI & Cluster Network Configuration page]({{< relref "../cni-cluster-network/" >}}#cluster-cluster-network-configuration-in-kkp-api).

2. The other option is to specify both IPv4 and IPv6 CIDRs in `spec.clusterNetwork.pods` and `spec.clusterNetwork.services`.
For example, a valid `clusterNetwork` configuration excerpt may look like:

```yaml
spec:
  clusterNetwork:
    pods:
      cidrBlocks:
      - 172.25.0.0/16
      - fd01::/48
    services:
      cidrBlocks:
      - 10.240.16.0/20
      - fd02::/120
    nodeCidrMaskSizeIPv4: 24
    nodeCidrMaskSizeIPv6: 64
```

Please note that the order of address families in the `cidrBlocks` is important and KKP right now only supports
IPv4 as the primary IP family (meaning that IPv4 address must always be the first in the `cidrBlocks` list).


## Verifying Dual-Stack Networking in a User Cluster
in order to verify the connectivity in a dual-stack enabled user cluster, please refer to the
[Validate IPv4/IPv6 dual-stack](https://kubernetes.io/docs/tasks/network/validate-dual-stack/) page in the
Kubernetes documentation. Please note the [cloud-provider specifics & limitations](#cloud-provider-specifics-and-limitations)
section below, as some features may not be supported on the given cloud-provider.

## Cloud-Provider Specifics and Limitations

### AWS
Dual-stack feature is available automatically for all new user clusters in AWS. Please note however,
that the VPC and subnets used to host the worker nodes need to be dual-stack enabled - i.e. must have both IPv4 and IPv6 CIDR assigned.

Limitations:
- Worker nodes do not have their IPv6 IP addresses published in k8s API (`kubectl describe nodes`), but have them physically
applied on their network interfaces (can be seen after SSH-ing to the node). Because of this, pods in the host network namespace do not have IPv6 address assigned.
- Dual-Stack services of type `LoadBalancer` are not yet supported by AWS cloud-controller-manager. Only `NodePort` services can be used
to expose services outside the cluster via IPv6.

Related issues:
 - https://github.com/kubermatic/kubermatic/issues/9899
 - https://github.com/kubernetes/cloud-provider-aws/issues/79

Docs:
 - [AWS: Subnets for your VPC](https://docs.aws.amazon.com/vpc/latest/userguide/configure-subnets.html)

### Azure
Dual-stack feature is available automatically for all new user clusters in Azure. Please note however that the VNet
used to host the worker nodes needs to be dual-stack enabled - i.e. must have both IPv4 and IPv6 CIDR assigned. In case
that you are not using a pre-created VNet, but leave the VNet creation on KKP, it will automatically create a dual-stack
VNet for your dual-stack user clusters.

Limitations:
- Dual-Stack services of type `LoadBalancer` are not yet supported by Azure cloud-controller-manager. Only `NodePort` services can be used
to expose services outside the cluster via IPv6.

Related issues:
 - https://github.com/kubernetes-sigs/cloud-provider-azure/issues/814
 - https://github.com/kubernetes-sigs/cloud-provider-azure/issues/1831

Docs:
 - [Overview of IPv6 for Azure Virtual Network](https://docs.microsoft.com/en-us/azure/virtual-network/ip-services/ipv6-overview)

### BYO / kubeadm
Dual-stack feature is available automatically for all new Bring-Your-Own (kubeadm) user clusters.

Before joining a KKP user cluster, the worker node needs to have both IPv4 and IPv6 address assigned.
Before joining, we need to make sure that both the IPv4 and the IPv6 address needs to be passed into the `node-ip`
flag of the kubelet. This can be done as follows:

- As instructed by KKP UI, run the `kubeadm token --kubeconfig <your-kubeconfig> create --print-join-command`
command and use its output in the next step.
- Create a yaml file with kubeadm `JoinConfiguration`, e.g. `kubeadm-join-config.yaml` with the content similar to this:
```yaml
apiVersion: kubeadm.k8s.io/v1beta3
kind: JoinConfiguration
discovery:
  bootstrapToken:
    # change info below to match the actual api server endpoint, token and CA certificate hash of your cluster
    apiServerEndpoint: fghk7gd5tx.kubermatic.your-domain.io:30038
    token: "9xwn14.ktdfg3s3fqyj0dr9"
    caCertHashes:
    - "sha256:b36ebfbcf51e019e6c763dd95bbc307ee4e96e9534d3133a65cf185c0dd74551"
nodeRegistration:
  kubeletExtraArgs:
    # change the node-ip below to match your desired IPv4 and IPv6 addresses of the node
    node-ip: 10.0.6.114,2a05:d014:937:4500:a324:767b:38da:2bff
```
- Join the node with the provided config file, e.g.: `kubeadm join --config kubeadm-join-config.yaml`.

Limitations:
- Services of type `LoadBalancer` don't work out of the box in BYO/kubeadm clusters. You can use additional addon software,
such as [MetalLB](https://metallb.universe.tf/) to make them work in your custom kubeadm setup.

Docs:
 - [Dual-stack support with kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/dual-stack-support/)

### DigitalOcean
Dual-stack feature is available automatically for all new user clusters in DigitalOcean.

Limitations:
- Services of type `LoadBalancer` are not yet supported in KKP on DigitalOcean (not even for IPv4-only clusters).

Related issues:
- https://github.com/kubermatic/kubermatic/issues/8847

### Equinix Metal
Dual-stack feature is available automatically for all new user clusters in Equinix Metal.

Limitations:
- Services of type `LoadBalancer` are not yet supported in KKP on Equinix Metal (not even for IPv4-only clusters).

Related issues:
- https://github.com/kubermatic/kubermatic/issues/10648

### GCP
Dual-stack feature is available automatically for all new user clusters in GCP. Please note however,
that the subnet used to host the worker nodes need to be dual-stack enabled - i.e. must have both IPv4 and IPv6 CIDR assigned.

Limitations:
- Worker nodes do not have their IPv6 IP addresses published in k8s API (`kubectl describe nodes`), but have them physically
  applied on their network interfaces (can be seen after SSH-ing to the node). Because of this, pods in the host network namespace do not have IPv6 address assigned.
- Dual-Stack services of type `LoadBalancer` are not yet supported by GCP cloud-controller-manager. Only `NodePort` services can be used
  to expose services outside the cluster via IPv6.

Related issues:
- https://github.com/kubermatic/kubermatic/issues/9899
- https://github.com/kubernetes/cloud-provider-gcp/issues/324

Docs:
 - [GCP: Create and modify VPC Networks](https://cloud.google.com/vpc/docs/create-modify-vpc-networks)

### Hetzner
Dual-stack feature is available automatically for all new user clusters in Hetzner.

Please note that all services of type `LoadBalancer` in Hetzner need to have a
[network zone / location](https://docs.hetzner.com/cloud/general/locations/) specified via an annotation,
for example `load-balancer.hetzner.cloud/network-zone: "eu-central"` or `load-balancer.hetzner.cloud/location: "fsn1"`.
Without one of these annotations, the load-balancer will be stuck in the Pending state.

Limitations:
- Due to the [issue with node ExternalIP ordering](https://github.com/hetznercloud/hcloud-cloud-controller-manager/issues/305),
we recommend using dual-stack clusters on Hetzner only with [Konnectivity]({{< relref "../cni-cluster-network/#konnectivity" >}})
enabled, otherwise errors can be seen when issuing `kubectl logs` / `kubectl exec` / `kubectl cp` commands on the cluster.

Related Issues:
- https://github.com/hetznercloud/hcloud-cloud-controller-manager/issues/305

### OpenStack
As IPv6 support in OpenStack highly depends on the datacenter setup, dual-stack feature in KKP is available only in
those OpenStack datacenters where it is explicitly enabled in the datacenter config of the KKP
(datacenter's `spec.openstack.ipv6Enabled` config flag is set to `true`).

Worker nodes of dual-stack clusters in OpenStack require networks with one IPv4 and one IPv6 subnet.
These can be either pre-created and passed into the cluster's `spec.cloud.openstack.subnetID` and `spec.cloud.openstack.ipv6SubnetID`,
or unspecified, in which case KKP will automatically create them. If KKP is creating a new IPv6 subnet, it can bind it
to an IPv6 subnet pool, if `spec.cloud.openstack.ipv6SubnetPool` is specified. If the IPv6 subnet pool is not specified,
but a default IPv6 subnet pool exists in the datacenter, the default one will be used. If no IPv6 subnet pool has been
specified and the default IPv6 subnet pool does not exist, the IPv6 subnet will be created with the CIDR `fd00::/64`.

Limitations:
- Dual-Stack services of type `LoadBalancer` are not yet supported by the OpenStack cloud-controller-manager. The initial work has been
finished as part of https://github.com/kubernetes/cloud-provider-openstack/pull/1901 and should be released as of
Kubernetes version 1.25.

Related Issues:
- https://github.com/kubernetes/cloud-provider-openstack/issues/1937

Docs:
- [IPv6 in OpenStack](https://docs.openstack.org/neutron/yoga/admin/config-ipv6.html)
- [Subnet pools](https://docs.openstack.org/neutron/yoga/admin/config-subnet-pools.html)

### VMware vSphere
As IPv6 support in VMware vSphere highly depends on the datacenter setup, dual-stack feature in KKP is available only in
those vSphere datacenters where it is explicitly enabled in the datacenter config of the KKP
(datacenter's `spec.vsphere.ipv6Enabled` config flag is set to `true`).

Limitations:
- Services of type `LoadBalancer` don't work out of the box in vSphere clusters, as they are not implemented
by the vSphere cloud-controller-manager. You can use additional addon software, such as [MetalLB](https://metallb.universe.tf/)
to make them work in your environment.
