+++
title = "Multi-Cluster IP Address Management (IPAM)"
date = 2022-07-26T14:45:00+02:00
+++

Feature responsible for automating the allocation of IP address ranges per user-cluster, based on a predefined configuration ([IPAMPool](#input-resource-ipampool)) per datacenter that defines the pool subnet and the allocation size. The user cluster allocated ranges are available in the [KKP Addon](#kkp-addon-template-integration) `TemplateData`, so it can be used by various Addons running in the user cluster.

{{< table_of_contents >}}

## Motivation and Background
Networking applications deployed in KKP user clusters need automated IP Address Management (IPAM) for IP ranges that they use, in a way that prevents address overlaps between multiple user clusters. An example for such an application is MetalLB load-balancer, for which a unique IP range from a larger CIDR range needs to be configured in each user cluster in the same datacenter.

The goal is to provide a simple solution that is automated and less prone to human errors.

## Allocation types
Each IPAM pool in a datacenter should define an allocation type: "range" or "prefix".

### Range
Results in a set of IPs based on an input size.

E.g. the first allocation for a range of size **8** in a pool subnet `192.168.1.0/26` would be
```txt
192.168.1.0-192.168.1.7
```

*Note*: There is a minimum allowed pool subnet mask based on the IP version (**20** for IPv4 and **116** for IPv6). So, if you need a large range of IPs, it's recommended to use the "prefix" type.

### Prefix
Results in a subnet of the pool subnet based on an input subnet prefix. Recommended when a large range of IPs is necessary.

E.g. the first allocation for a prefix **30** in a pool subnet `192.168.1.0/26` would be
```txt
192.168.1.0/30
```
and the second would be
```txt
192.168.1.4/30
```

## Input resource (IPAMPool)
KKP exposes a global-scoped Custom Resource Definition (CRD) `IPAMPool` in the seed cluster. The administrators are able to define the `IPAMPool` CR with a specific name with multiple pool CIDRs with predefined allocation ranges tied to specific datacenters. The administrators can also manage the IPAM pools via [API endpoints]({{< relref "../../../references/rest_api_reference/#/ipampool" >}}) (`/api/v2/seeds/{seed_name}/ipampools`).

E.g. containing both allocation types for different datacenters:
```yaml
apiVersion: kubermatic.k8c.io/v1
kind: IPAMPool
metadata:
  name: metallb
spec:
  datacenters:
    azure-westeurope:
      type: range
      poolCidr: "192.168.1.0/26"
      allocationRange: 8
    aws-eu-central-1a:
      type: prefix
      poolCidr: "192.168.1.0/26"
      allocationPrefix: 30
```

Note that `poolCIDR` can be the same in different datacenters.

### Validations
Required spec fields:
- `datacenters`
- `type` for a datacenter
- `poolCidr` for a datacenter
- `allocationRange` for a datacenter with "range" allocation type
- `allocationPrefix` for a datacenter with "prefix" allocation type

For the "range" allocation type:
- `allocationRange` should be a positive integer and cannot be greater than the pool subnet possible number of IP addresses.
- IPv4 `poolCIDR` should have a prefix (i.e. mask) equal or greater than **20**.
- IPv6 `poolCIDR` should have a prefix (i.e. mask) equal or greater than **116**.

For the "prefix" allocation type:
- `allocationPrefix` should be between **1** and **32** for IPv4 pool, and between **1** and **128** for IPv6 pool.
- `allocationPrefix` should be equal or greater than the pool subnet mask size.

### Modifications
In general, modifications are not allowed. If you need to change an already applied `IPAMPool`, you should first delete it (note that all user clusters allocations `IPAMAllocation` will be deleted, in that case) and then apply it with the changes.

The only allowed modification in a `IPAMPool` CR is the deletion of a datacenter configuration if there is no persisted allocation `IPAMAllocation` in any user cluster for it.

## Generated resource (IPAMAllocation)
The IPAM controller in the seed-controller-manager is in charge of the allocation of IP ranges from the defined pools for user clusters. For each user cluster which runs in a datacenter for which an `IPAMPool` is defined, it will automatically allocate a free IP range from the available pool.

The persisted allocation is an `IPAMAllocation` CR that will be installed in the seed cluster in the user cluster's namespace.

E.g. for "prefix" type:
```yaml
apiVersion: kubermatic.k8c.io/v1
kind: IPAMAllocation
metadata:
  name: metallb
  namespace: cluster-kd8jnt7gjj
spec:
  cidr: "192.168.1.0/30"
  dc: aws-eu-central-1a
  type: prefix
```

E.g. for "range" type:
```yaml
apiVersion: kubermatic.k8c.io/v1
kind: IPAMAllocation
metadata:
  name: metallb
  namespace: cluster-sd87xtqpnm
spec:
  addresses:
  - "192.168.1.0-192.168.1.7"
  dc: azure-westeurope
  type: range
```

Note that the ranges of addresses may be disjoint for the "range" type, e.g.:
```yaml
spec:
  addresses:
  - "192.168.1.0-192.168.1.7"
  - "192.168.1.16-192.168.1.23"
```
That's because, in the future, we could start allowing the modification (i.e. increase) of the allocation range.

### Allocations cleanup
The allocations (i.e. `IPAMAllocation` CRs) for a user cluster are deleted in two occasions:
- Related pool (i.e. `IPAMPool` CR with same name) is deleted.
- User cluster itself is deleted.

## KKP Addon template integration
The user cluster allocated ranges (i.e. `IPAMAllocation` CRs values) are available in the Addon template data (attribute `.Cluster.Network.IPAMAllocations`) to be rendered in the Addons manifests.

E.g. looping all user cluster IPAM pools allocations:
```yaml
...

{{- range $ipamPool, $allocation := .Cluster.Network.IPAMAllocations }}
{{ $ipamPool }}:
  {{- if eq $allocation.Type "prefix" }}
  CIDR: {{ $allocation.CIDR }}
  {{- end }}
  {{- if eq $allocation.Type "range" }}
  Addresses:
    {{- range $allocation.Addresses }}
    - {{ . }}
    {{- end }}
  {{- end }}
{{- end }}
```

## MetalLB Addon
We implemented a KKP Addon for [MetalLB](https://metallb.universe.tf/), so its manifests will be rendered with the persisted IPAM allocations in the user cluster.

It means that, if the KKP user installs it, it will generate [`IPAddressPool`](https://metallb.universe.tf/configuration/#defining-the-ips-to-assign-to-the-load-balancer-services) CRs (from `metallb.io/v1beta1`) for each user cluster IPAM pool allocation, along with all other MetalLB manifests.

The Addon manifests can be found [here](https://github.com/kubermatic/kubermatic/blob/master/addons/metallb/).
