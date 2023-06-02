+++
title = "Multi-Cluster IP Address Management (IPAM)"
date = 2022-07-26T14:45:00+02:00
weight = 170
+++

Multi-Cluster IPAM is a feature responsible for automating the allocation of IP address ranges/subnets per user-cluster, based on a predefined configuration ([IPAMPool](#input-resource-ipampool)) per datacenter that defines the pool subnet and the allocation size. The user cluster allocated ranges are available in the [KKP Addon](#kkp-addon-template-integration) `TemplateData`, so it can be used by various Addons running in the user cluster.

## Motivation and Background
Networking applications deployed in KKP user clusters need automated IP Address Management (IPAM) for IP ranges that they use, in a way that prevents address overlaps between multiple user clusters. An example for such an application is MetalLB load-balancer, for which a unique IP range from a larger CIDR range needs to be configured in each user cluster in the same datacenter.

The goal is to provide a simple solution that is automated and less prone to human errors.

## Allocation Types
Each IPAM pool in a datacenter should define an allocation type: "range" or "prefix".

### Range
Results in a set of IPs based on an input size.

E.g. the first allocation for a range of size **8** in a pool subnet `192.168.1.0/26` would be
```txt
192.168.1.0-192.168.1.7
```

*Note*: There is a minimal allowed pool subnet mask based on the IP version (**20** for IPv4 and **116** for IPv6). So, if you need a large range of IPs, it's recommended to use the "prefix" type.

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

## Input Resource (IPAMPool)
KKP exposes a global-scoped Custom Resource Definition (CRD) `IPAMPool` in the seed cluster. The administrators are able to define the `IPAMPool` CR with a specific name with multiple pool CIDRs with predefined allocation ranges tied to specific datacenters. The administrators can also manage the IPAM pools via [API endpoints]({{< relref "../../../references/rest-api-reference/#/ipampool" >}}) (`/api/v2/seeds/{seed_name}/ipampools`).

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

### Exclusions

Optionally, you can configure range/prefix exclusions in IPAMPools, in order to exclude particular IPs/subnets of IPAMPool (e.g. dedicated for special services) from IPAM allocations.

For that, you need to extend the IPAM Pool datacenter spec to include a list of subnets CIDR to exclude (`excludePrefixes` for prefix allocation type) or a list of particular IPs or IP ranges to exclude (`excludeRanges` for range allocation type).

E.g. from previous example, containing both allocation types exclusions:
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
      excludeRanges:
      - "192.168.1.1"
      - "192.168.1.5-192.168.1.7"
    aws-eu-central-1a:
      type: prefix
      poolCidr: "192.168.1.0/26"
      allocationPrefix: 30
      excludePrefixes:
      - "192.168.1.0/30"
      - "192.168.1.8/30"
```

### Restrictions
Required `IPAMPool` spec fields:
- `datacenters` list cannot be empty.
- `type` for a datacenter is mandatory.
- `poolCidr` for a datacenter is mandatory.
- `allocationRange` for a datacenter with "range" allocation type is mandatory.
- `allocationPrefix` for a datacenter with "prefix" allocation type is mandatory.

For the "range" allocation type:
- `allocationRange` should be a positive integer and cannot be greater than the pool subnet possible number of IP addresses.
- IPv4 `poolCIDR` should have a prefix (i.e. mask) equal or greater than **20**.
- IPv6 `poolCIDR` should have a prefix (i.e. mask) equal or greater than **116**.

For the "prefix" allocation type:
- `allocationPrefix` should be between **1** and **32** for IPv4 pool, and between **1** and **128** for IPv6 pool.
- `allocationPrefix` should be equal or greater than the pool subnet mask size.

### Modifications
In general, modifications of the `IPAMPool` are not allowed, with the following exceptions:

- It is possible to add a new datacenter into the `IPAMPool`.
- It is possible to delete a datacenter from the `IPAMPool`, if there is no persisted allocation (`IPAMAllocation`) in any user cluster for it.

If you need to change an already applied `IPAMPool`, you should first delete it and then apply it with the changes.
Note that by `IPAMPool` deletion, all user clusters allocations (`IPAMAllocation`) will be deleted as well.


## Generated Resource (IPAMAllocation)
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
The reason for that is to allow for some `IPAMPool` modifications (i.e. increase of the allocation range) in the future.

### Allocations Cleanup
The allocations (i.e. `IPAMAllocation` CRs) for a user cluster are deleted in two occasions:
- Related pool (i.e. `IPAMPool` CR with same name) is deleted.
- User cluster itself is deleted.

## KKP Addon Template Integration
The user cluster allocated ranges (i.e. `IPAMAllocation` CRs values) are available in the [Addon template data]({{< relref "../../../architecture/concept/kkp-concepts/addons/" >}}#manifest-templating) (attribute `.Cluster.Network.IPAMAllocations`) to be rendered in the Addons manifests.
That allows consumption of the user cluster's IPAM allocations in any KKP [Addon]({{< relref "../../../architecture/concept/kkp-concepts/addons/" >}}).

For example, looping over all user cluster IPAM pools allocations in an addon template can be done as follows:
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

## MetalLB Addon Integration
KKP provides a [MetalLB](https://metallb.universe.tf/) [accessible addon]({{< relref "../../../architecture/concept/kkp-concepts/addons/#accessible-addons" >}}) integrated with the Multi-Cluster IPAM feature.

The addon deploys standard MetalLB manifests into the user cluster. On top of that, if an IPAM allocation from an IPAM pool with a specific name is available for the user-cluster, the addon
automatically installs the equivalent MetalLB IP address pool in the user cluster (in the `IPAddressPool` custom resource from the `metallb.io/v1beta1` API).

The KKP `IPAMPool` from which the allocations are made need to have the following name:
 - `metallb` if a single-stack (either IPv4 or IPv6) IP address pool needs to be created in the user cluster.
 - `metallb-ipv4` and `metallb-ipv6` if a dual-stack (both IPv4 and IPv6) IP address pool needs to be created in the user cluster.
In this case, allocations from both address pools need to exist.

The created [`IPAddressPool`](https://metallb.universe.tf/configuration/#defining-the-ips-to-assign-to-the-load-balancer-services)
custom resource (from the `metallb.io/v1beta1` API) will have the following name:
 - `kkp-managed-pool` in case of a single-stack address pool,
 - `kkp-managed-pool-dualstack` in case of a dual-stack address pool.

Both address pools (single-stack and dual-stack) can co-exist in the same cluster.

For the reference, the Addon manifests can be found in the [addons/metallb/](https://github.com/kubermatic/kubermatic/blob/main/addons/metallb/) folder of the KKP source code.
