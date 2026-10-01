+++
title = "Kubermatic Virtualization CRDs Reference"
date = 2026-07-02T00:00:00
weight = 40
searchExclude = true
+++
## v1alpha1

* [KubeVRole](#kubevrole)
* [KubeVRoleBinding](#kubevrolebinding)
* [KubeVRoleBindingList](#kubevrolebindinglist)
* [KubeVRoleBindingSpec](#kubevrolebindingspec)
* [KubeVRoleList](#kubevrolelist)
* [KubeVRoleSpec](#kubevrolespec)
* [PolicyRule](#policyrule)
* [User](#user)
* [UserList](#userlist)
* [UserSpec](#userspec)
* [UserStatus](#userstatus)
* [Image](#image)
* [ImageList](#imagelist)
* [ImageSourceGCS](#imagesourcegcs)
* [ImageSourceHTTP](#imagesourcehttp)
* [ImageSourcePVC](#imagesourcepvc)
* [ImageSourceRegistry](#imagesourceregistry)
* [ImageSourceS3](#imagesources3)
* [ImageSpec](#imagespec)
* [SSHKey](#sshkey)
* [SSHKeyList](#sshkeylist)
* [SSHKeySpec](#sshkeyspec)
* [SSHKeyStatus](#sshkeystatus)
* [DNATRule](#dnatrule)
* [ElasticIP](#elasticip)
* [ElasticIPList](#elasticiplist)
* [ElasticIPSpec](#elasticipspec)
* [ElasticIPStatus](#elasticipstatus)
* [NATGateway](#natgateway)
* [NATGatewayList](#natgatewaylist)
* [NATGatewaySpec](#natgatewayspec)
* [NATGatewayStatus](#natgatewaystatus)
* [SNATRule](#snatrule)
* [SecurityGroup](#securitygroup)
* [SecurityGroupList](#securitygrouplist)
* [SecurityGroupRule](#securitygrouprule)
* [SecurityGroupSpec](#securitygroupspec)
* [SecurityGroupStatus](#securitygroupstatus)
* [Subnet](#subnet)
* [SubnetList](#subnetlist)
* [SubnetSpec](#subnetspec)
* [SubnetStatus](#subnetstatus)
* [UnderlayCustomInterface](#underlaycustominterface)
* [UnderlaySubnet](#underlaysubnet)
* [UnderlaySubnetList](#underlaysubnetlist)
* [UnderlaySubnetSpec](#underlaysubnetspec)
* [UnderlaySubnetStatus](#underlaysubnetstatus)
* [VPC](#vpc)
* [VPCBFDPort](#vpcbfdport)
* [VPCBFDPortStatus](#vpcbfdportstatus)
* [VPCList](#vpclist)
* [VPCPeering](#vpcpeering)
* [VPCPolicyRoute](#vpcpolicyroute)
* [VPCSpec](#vpcspec)
* [VPCStaticRoute](#vpcstaticroute)
* [VPCStatus](#vpcstatus)
* [AZAcceptPrefix](#azacceptprefix)
* [AZBGPPeer](#azbgppeer)
* [AZEVPNPeer](#azevpnpeer)
* [AZEdgeRouter](#azedgerouter)
* [AZEdgeRouterList](#azedgerouterlist)
* [AZEdgeRouterRef](#azedgerouterref)
* [AZEdgeRouterSpec](#azedgerouterspec)
* [AZEdgeRouterStatus](#azedgerouterstatus)
* [AZExternalVLAN](#azexternalvlan)
* [AZInternalPeersSpec](#azinternalpeersspec)
* [AZInternalPeersVPCOverride](#azinternalpeersvpcoverride)
* [AZPerVRFTransitSpec](#azpervrftransitspec)
* [AZResolvedFabricPeer](#azresolvedfabricpeer)
* [AZTransitSubnetSpec](#aztransitsubnetspec)
* [AZVPCEdgeRouterRef](#azvpcedgerouterref)
* [AZVPCFabricPeer](#azvpcfabricpeer)
* [AZVPCRef](#azvpcref)
* [AZVPCVLANRef](#azvpcvlanref)
* [AZVPCsSpec](#azvpcsspec)
* [EVPNPeer](#evpnpeer)
* [EVPNPolicy](#evpnpolicy)
* [EVPNPolicyList](#evpnpolicylist)
* [EVPNPolicySpec](#evpnpolicyspec)
* [EVPNPolicyStatus](#evpnpolicystatus)
* [EVPNPolicyTarget](#evpnpolicytarget)
* [EVPNRRImage](#evpnrrimage)
* [EVPNRRResources](#evpnrrresources)
* [EVPNRouteReflector](#evpnroutereflector)
* [EVPNRouteReflectorList](#evpnroutereflectorlist)
* [EVPNRouteReflectorSpec](#evpnroutereflectorspec)
* [EVPNRouteReflectorStatus](#evpnroutereflectorstatus)
* [EdgeRouterImage](#edgerouterimage)
* [EdgeRouterResources](#edgerouterresources)
* [LearnedBGPRoute](#learnedbgproute)
* [PeerResolvedAZVPCs](#peerresolvedazvpcs)
* [ResolvedAZVPC](#resolvedazvpc)

### KubeVRole

KubeVRole defines what operations a subject may perform.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| metadata |  | [metav1.ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#objectmeta-v1-meta) | false |
| spec |  | [KubeVRoleSpec](#kubevrolespec) | true |

[Back to Group](#v1alpha1)

### KubeVRoleBinding

KubeVRoleBinding grants a KubeVRole to a user.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| metadata |  | [metav1.ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#objectmeta-v1-meta) | false |
| spec |  | [KubeVRoleBindingSpec](#kubevrolebindingspec) | true |

[Back to Group](#v1alpha1)

### KubeVRoleBindingList

KubeVRoleBindingList is the list type for KubeVRoleBinding.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| metadata |  | [metav1.ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#listmeta-v1-meta) | false |
| items |  | [][KubeVRoleBinding](#kubevrolebinding) | true |

[Back to Group](#v1alpha1)

### KubeVRoleBindingSpec

KubeVRoleBindingSpec defines who gets what role.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| subject | Subject is the name of the User being bound. | string | true |
| roleRef | RoleRef is the name of the KubeVRole to grant. | string | true |

[Back to Group](#v1alpha1)

### KubeVRoleList

KubeVRoleList is the list type for KubeVRole.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| metadata |  | [metav1.ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#listmeta-v1-meta) | false |
| items |  | [][KubeVRole](#kubevrole) | true |

[Back to Group](#v1alpha1)

### KubeVRoleSpec

KubeVRoleSpec defines the rules of a KubeVRole.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| displayName | DisplayName is a human-readable label shown in the UI. | string | false |
| description | Description explains what this role is intended for. | string | false |
| system | System marks the role as built-in. System roles cannot be deleted via the API. | bool | false |
| rules | Rules is the list of policy rules that define the permissions of this role. | [][PolicyRule](#policyrule) | true |

[Back to Group](#v1alpha1)

### PolicyRule

PolicyRule grants a set of verbs on a set of resources, optionally scoped to
one or more resource groups. Any field left empty (or set to [\"*\"]) is a
wildcard that matches everything.

Example — full compute access:

	{ resourceGroups: [\"compute\"], verbs: [\"*\"] }

Example — read-only access to a single resource type:

	{ resourceGroups: [\"networking\"], resources: [\"subnets\"], verbs: [\"view\"] }

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| resourceGroups | ResourceGroups scopes the rule to one or more IAM resource categories (e.g. \"compute\", \"networking\", \"storage\", \"iam\"). An empty list or [\"*\"] matches all groups. | []string | false |
| resources | Resources further narrows the rule to specific resource types within the group (e.g. \"virtualmachines\", \"subnets\"). An empty list or [\"*\"] matches all resources in the matched groups. | []string | false |
| verbs | Verbs is the list of operations this rule permits. Standard verbs are: create, delete, update, view, manage, start, stop, restart, console. The wildcard \"*\" permits all verbs. | []string | true |

[Back to Group](#v1alpha1)

### User

User represents a synced OIDC identity. The controller creates and updates
these from OIDC subject claims so that bindings can reference stable K8s
resource names instead of raw OIDC subjects.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| metadata |  | [metav1.ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#objectmeta-v1-meta) | false |
| spec |  | [UserSpec](#userspec) | false |
| status |  | [UserStatus](#userstatus) | false |

[Back to Group](#v1alpha1)

### UserList

UserList is the list type for User.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| metadata |  | [metav1.ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#listmeta-v1-meta) | false |
| items |  | [][User](#user) | true |

[Back to Group](#v1alpha1)

### UserSpec

UserSpec is the desired state of a User.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| sub | Sub is the stable OIDC subject identifier (never changes for a given user). | string | true |
| email | Email is the user's email address from the OIDC claims. | string | false |
| name | Name is the user's display name from the OIDC claims. | string | false |
| disabled | Disabled prevents the user from authenticating when true. | bool | false |

[Back to Group](#v1alpha1)

### UserStatus

UserStatus is the observed state of a User.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| lastSeen | LastSeen is the timestamp of the user's most recent authentication. | *metav1.Time | false |

[Back to Group](#v1alpha1)

### Image

Image is a catalog entry describing an OS image available for use as a
DataVolume source when creating VirtualMachines or VMPools.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| metadata |  | [metav1.ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#objectmeta-v1-meta) | false |
| spec |  | [ImageSpec](#imagespec) | false |

[Back to Group](#v1alpha1)

### ImageList

ImageList is the list type for Image.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| metadata |  | [metav1.ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#listmeta-v1-meta) | false |
| items |  | [][Image](#image) | true |

[Back to Group](#v1alpha1)

### ImageSourceGCS

ImageSourceGCS references an image stored in Google Cloud Storage.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| url | URL is the GCS URL of the image. | string | true |

[Back to Group](#v1alpha1)

### ImageSourceHTTP

ImageSourceHTTP references an image hosted at an HTTP/HTTPS URL.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| url | URL is the full HTTP/HTTPS URL of the image. | string | true |

[Back to Group](#v1alpha1)

### ImageSourcePVC

ImageSourcePVC references an image backed by an existing PersistentVolumeClaim.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| name | Name is the PVC name. | string | true |
| namespace | Namespace is the PVC namespace. Defaults to the Image's namespace when omitted. | string | false |

[Back to Group](#v1alpha1)

### ImageSourceRegistry

ImageSourceRegistry references an image stored in a container registry.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| url | URL is the full registry URL including tag or digest (e.g. docker.io/library/ubuntu:22.04). | string | true |

[Back to Group](#v1alpha1)

### ImageSourceS3

ImageSourceS3 references an image stored in an S3-compatible bucket.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| url | URL is the S3 URL of the image. | string | true |

[Back to Group](#v1alpha1)

### ImageSpec

ImageSpec defines the desired state of an Image.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| type | Type identifies the kind of source backing this image. | ImageSourceType | true |
| readableName | ReadableName is a human-friendly display name shown in the UI. | string | true |
| readableDescription | ReadableDescription is an optional human-friendly description. | string | false |
| credentials | Credentials is an optional reference to a Secret holding credentials required to access the image source. | string | false |
| http | HTTP describes an image hosted at an HTTP/HTTPS URL. | *[ImageSourceHTTP](#imagesourcehttp) | false |
| registry | Registry describes an image stored in a container registry. | *[ImageSourceRegistry](#imagesourceregistry) | false |
| s3 | S3 describes an image stored in an S3-compatible object store. | *[ImageSourceS3](#imagesources3) | false |
| gcs | GCS describes an image stored in Google Cloud Storage. | *[ImageSourceGCS](#imagesourcegcs) | false |
| pvc | PVC describes an image backed by an existing PersistentVolumeClaim. | *[ImageSourcePVC](#imagesourcepvc) | false |

[Back to Group](#v1alpha1)

### SSHKey

SSHKey stores an SSH public key in the workspace namespace. The controller
reconciles each SSHKey into an owned K8s Secret so that cloud-init can inject
the key into virtual machines at creation time.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| metadata |  | [metav1.ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#objectmeta-v1-meta) | false |
| spec |  | [SSHKeySpec](#sshkeyspec) | false |
| status |  | [SSHKeyStatus](#sshkeystatus) | false |

[Back to Group](#v1alpha1)

### SSHKeyList

SSHKeyList is the list type for SSHKey.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| metadata |  | [metav1.ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#listmeta-v1-meta) | false |
| items |  | [][SSHKey](#sshkey) | true |

[Back to Group](#v1alpha1)

### SSHKeySpec

SSHKeySpec defines the desired state of an SSHKey.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| publicKey | PublicKey is the SSH public key content (e.g. \"ssh-rsa AAAA... user@host\"). | string | true |

[Back to Group](#v1alpha1)

### SSHKeyStatus

SSHKeyStatus is the observed state of an SSHKey.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| phase | Phase is the current lifecycle phase. | SSHKeyPhase | false |
| secretRef | SecretRef is the name of the managed Secret in the same namespace. | string | false |
| message | Message contains a human-readable description of the current phase. | string | false |

[Back to Group](#v1alpha1)

### DNATRule

DNATRule maps an external port on an EIP to an internal address and port.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| externalPort | ExternalPort is the port on the EIP to forward. | string | true |
| internalIP | InternalIP is the internal VM IP to forward traffic to. | string | true |
| internalPort | InternalPort is the destination port on the internal VM. | string | true |
| protocol | Protocol is the transport protocol: tcp or udp. | string | false |
| eipRef | EIPRef is the name of the ElasticIP wrapper in the same namespace. | string | true |

[Back to Group](#v1alpha1)

### ElasticIP

ElasticIP is the namespace-scoped wrapper for a Kube-OVN IptablesEIP resource.
It represents a public IP address that can be associated with a NAT gateway.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| metadata |  | [metav1.ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#objectmeta-v1-meta) | false |
| spec |  | [ElasticIPSpec](#elasticipspec) | false |
| status |  | [ElasticIPStatus](#elasticipstatus) | false |

[Back to Group](#v1alpha1)

### ElasticIPList

ElasticIPList is the list type for ElasticIP.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| metadata |  | [metav1.ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#listmeta-v1-meta) | false |
| items |  | [][ElasticIP](#elasticip) | true |

[Back to Group](#v1alpha1)

### ElasticIPSpec

ElasticIPSpec defines the desired state of an ElasticIP.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| natGatewayRef | NATGatewayRef is the name of the NATGateway wrapper this EIP belongs to. | string | false |

[Back to Group](#v1alpha1)

### ElasticIPStatus

ElasticIPStatus is the observed state of the ElasticIP wrapper.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| phase | Phase is the current lifecycle phase. | Phase | false |
| realName | RealName is the actual Kube-OVN IptablesEIP object name. | string | false |
| ipAddress | IPAddress is the public IP address allocated to this EIP. | string | false |
| isUsed | IsUsed indicates whether this EIP is currently in use by a NAT rule. | bool | true |
| associatedNat | AssociatedNAT is the real Kube-OVN NAT gateway name this EIP is bound to. | string | false |

[Back to Group](#v1alpha1)

### NATGateway

NATGateway is the namespace-scoped wrapper for a Kube-OVN VpcNatGateway resource.
It bundles SNAT and DNAT rules that are individually provisioned as separate
Kube-OVN objects (IptablesSnatRule / IptablesDnatRule).

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| metadata |  | [metav1.ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#objectmeta-v1-meta) | false |
| spec |  | [NATGatewaySpec](#natgatewayspec) | false |
| status |  | [NATGatewayStatus](#natgatewaystatus) | false |

[Back to Group](#v1alpha1)

### NATGatewayList

NATGatewayList is the list type for NATGateway.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| metadata |  | [metav1.ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#listmeta-v1-meta) | false |
| items |  | [][NATGateway](#natgateway) | true |

[Back to Group](#v1alpha1)

### NATGatewaySpec

NATGatewaySpec defines the desired state of a NAT gateway.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| vpcRef | VPCRef is the name of the VPC wrapper in the same namespace. | string | true |
| subnetRef | SubnetRef is the name of the Subnet wrapper in the same namespace. | string | true |
| lanIP | LanIP is the LAN-side IP address of the NAT gateway. | string | false |
| snatRules | SNATRules define source NAT rules for outbound connectivity. | [][SNATRule](#snatrule) | false |
| dnatRules | DNATRules define destination NAT rules for inbound port-forwarding. | [][DNATRule](#dnatrule) | false |

[Back to Group](#v1alpha1)

### NATGatewayStatus

NATGatewayStatus is the observed state of the NATGateway wrapper.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| phase | Phase is the current lifecycle phase. | Phase | false |
| realName | RealName is the actual Kube-OVN VpcNatGateway object name. | string | false |

[Back to Group](#v1alpha1)

### SNATRule

SNATRule maps an internal CIDR to an EIP for outbound NAT.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| cidr | CIDR is the internal IP range to SNAT. | string | true |
| eipRef | EIPRef is the name of the ElasticIP wrapper in the same namespace. | string | true |

[Back to Group](#v1alpha1)

### SecurityGroup

SecurityGroup is the namespace-scoped wrapper for a Kube-OVN SecurityGroup resource.
It defines ACL-based firewall rules that can be applied to VMs.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| metadata |  | [metav1.ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#objectmeta-v1-meta) | false |
| spec |  | [SecurityGroupSpec](#securitygroupspec) | false |
| status |  | [SecurityGroupStatus](#securitygroupstatus) | false |

[Back to Group](#v1alpha1)

### SecurityGroupList

SecurityGroupList is the list type for SecurityGroup.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| metadata |  | [metav1.ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#listmeta-v1-meta) | false |
| items |  | [][SecurityGroup](#securitygroup) | true |

[Back to Group](#v1alpha1)

### SecurityGroupRule

SecurityGroupRule is a single ACL rule within a SecurityGroup.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| ipVersion | IPVersion specifies whether the rule applies to IPv4 or IPv6 traffic. | string | false |
| protocol | Protocol is the network protocol: tcp, udp, icmp, or all. | string | false |
| priority | Priority determines the rule evaluation order (lower values = higher priority). | int | false |
| remoteType | RemoteType is the type of the remote endpoint: address or securityGroup. | string | true |
| remoteAddress | RemoteAddress is the IP address or CIDR of the remote endpoint when RemoteType is address. | string | false |
| remoteSecurityGroup | RemoteSecurityGroup is the name of the remote security group when RemoteType is securityGroup. | string | false |
| portRangeMin | PortRangeMin is the inclusive minimum port number for this rule. | int | false |
| portRangeMax | PortRangeMax is the inclusive maximum port number for this rule. | int | false |
| policy | Policy is the rule action: allow or drop. | string | true |

[Back to Group](#v1alpha1)

### SecurityGroupSpec

SecurityGroupSpec defines the desired firewall rules.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| allowSameGroupTraffic | AllowSameGroupTraffic permits traffic between members of the same security group. | bool | false |
| ingressRules | IngressRules defines the inbound firewall rules. | [][SecurityGroupRule](#securitygrouprule) | false |
| egressRules | EgressRules defines the outbound firewall rules. | [][SecurityGroupRule](#securitygrouprule) | false |

[Back to Group](#v1alpha1)

### SecurityGroupStatus

SecurityGroupStatus is the observed state of the SecurityGroup wrapper.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| phase | Phase is the current lifecycle phase. | Phase | false |
| realName | RealName is the actual Kube-OVN SecurityGroup object name. | string | false |

[Back to Group](#v1alpha1)

### Subnet

Subnet is the namespace-scoped wrapper for a Kube-OVN Subnet resource.
It is always associated with a VPC wrapper in the same namespace.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| metadata |  | [metav1.ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#objectmeta-v1-meta) | false |
| spec |  | [SubnetSpec](#subnetspec) | false |
| status |  | [SubnetStatus](#subnetstatus) | false |

[Back to Group](#v1alpha1)

### SubnetList

SubnetList is the list type for Subnet.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| metadata |  | [metav1.ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#listmeta-v1-meta) | false |
| items |  | [][Subnet](#subnet) | true |

[Back to Group](#v1alpha1)

### SubnetSpec

SubnetSpec defines the desired state of a Subnet wrapper.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| vpcRef | VPCRef is the name of the VPC wrapper in the same namespace. | string | true |
| cidrBlock | CIDRBlock is the IP address range for this subnet. | string | true |
| gateway | Gateway is the gateway IP address for this subnet. | string | false |
| protocol | Protocol is the IP protocol family: IPv4, IPv6, or Dual. | string | false |
| excludeIPs | ExcludeIPs is a list of IP ranges to exclude from allocation. | []string | false |
| enableDHCP | EnableDHCP enables DHCP on this subnet. | bool | false |
| gatewayType | GatewayType controls the gateway mode: distributed or centralized. | string | false |
| natOutgoing | NatOutgoing enables NAT for traffic leaving this subnet. | bool | false |
| private | Private denies traffic from outside this subnet when true. | bool | false |
| provider | Provider is the kube-ovn provider name for this subnet, used to associate it with a NetworkAttachmentDefinition (NAD) via kube-ovn's provider matching. Required for multi-homed pods (e.g. AZ transit NICs). | string | false |

[Back to Group](#v1alpha1)

### SubnetStatus

SubnetStatus is the observed state of the Subnet wrapper.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| phase | Phase is the current lifecycle phase of this Subnet. | Phase | false |
| realName | RealName is the actual Kube-OVN Subnet object name. | string | false |
| vpcRealName | VPCRealName is the real Kube-OVN Vpc name this subnet belongs to. | string | false |
| availableIPs | AvailableIPs is the number of IP addresses currently available in this subnet. | int64 | true |
| usedIPs | UsedIPs is the number of IP addresses currently in use. | int64 | true |

[Back to Group](#v1alpha1)

### UnderlayCustomInterface

UnderlayCustomInterface overrides DefaultInterface on a specific set of nodes.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| interface | Interface is the physical NIC name to use on the listed nodes. It must be a valid Linux network interface name, which the kernel caps at 15 bytes. | string | true |
| nodes | Nodes is the list of node names that use Interface instead of the spec-level DefaultInterface. | []string | true |

[Back to Group](#v1alpha1)

### UnderlaySubnet

UnderlaySubnet is the namespace-scoped wrapper that bundles the three
Kube-OVN objects required to expose an underlay (L2) network: a cluster-
scoped ProviderNetwork (which physical NIC per node), a Vlan (the 802.1Q
tag), and a Subnet bound to that Vlan. The reconciler ensures the children
are created and torn down in dependency order.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| metadata |  | [metav1.ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#objectmeta-v1-meta) | false |
| spec |  | [UnderlaySubnetSpec](#underlaysubnetspec) | false |
| status |  | [UnderlaySubnetStatus](#underlaysubnetstatus) | false |

[Back to Group](#v1alpha1)

### UnderlaySubnetList

UnderlaySubnetList is the list type for UnderlaySubnet.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| metadata |  | [metav1.ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#listmeta-v1-meta) | false |
| items |  | [][UnderlaySubnet](#underlaysubnet) | true |

[Back to Group](#v1alpha1)

### UnderlaySubnetSpec

UnderlaySubnetSpec defines the desired state of an UnderlaySubnet wrapper.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| defaultInterface | DefaultInterface is the physical NIC name (e.g. \"eth1\") that the ProviderNetwork attaches to on every selected node. It must be a valid Linux network interface name, which the kernel caps at 15 bytes. | string | true |
| nodeSelector | NodeSelector restricts the ProviderNetwork to a subset of nodes via label selection. When empty, the ProviderNetwork applies to all nodes. | *[metav1.LabelSelector](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#labelselector-v1-meta) | false |
| customInterfaces | CustomInterfaces overrides DefaultInterface on specific nodes. | [][UnderlayCustomInterface](#underlaycustominterface) | false |
| vlanID | VlanID is the 802.1Q tag applied to traffic on this underlay. | int | true |
| cidrBlock | CIDRBlock is the IP address range allocated from this underlay subnet. | string | true |
| gateway | Gateway is the gateway IP address for this subnet. | string | false |
| gatewayNode | GatewayNode is the comma-separated list of node names that host the centralized gateway for this subnet. | string | false |
| protocol | Protocol is the IP protocol family: IPv4, IPv6, or Dual. | string | false |
| excludeIPs | ExcludeIPs is a list of IP addresses or ranges to exclude from allocation. | []string | false |

[Back to Group](#v1alpha1)

### UnderlaySubnetStatus

UnderlaySubnetStatus is the observed state of the UnderlaySubnet wrapper.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| phase | Phase is the current lifecycle phase of this UnderlaySubnet. | Phase | false |
| providerNetworkName | ProviderNetworkName is the name of the cluster-scoped Kube-OVN ProviderNetwork backing this underlay. | string | false |
| vlanName | VlanName is the name of the cluster-scoped Kube-OVN Vlan backing this underlay. | string | false |
| subnetName | SubnetName is the name of the cluster-scoped Kube-OVN Subnet backing this underlay. | string | false |
| availableIPs | AvailableIPs is the number of IP addresses currently available in this subnet. | int64 | true |
| usedIPs | UsedIPs is the number of IP addresses currently in use. | int64 | true |

[Back to Group](#v1alpha1)

### VPC

VPC is the namespace-scoped wrapper for a Kube-OVN Vpc resource.
Users create VPCs inside workspace namespaces; the operator reconciles them
into cluster-scoped Kube-OVN Vpc objects, prefixing their names with the
workspace namespace to prevent cross-tenant collisions.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| metadata |  | [metav1.ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#objectmeta-v1-meta) | false |
| spec |  | [VPCSpec](#vpcspec) | false |
| status |  | [VPCStatus](#vpcstatus) | false |

[Back to Group](#v1alpha1)

### VPCBFDPort

VPCBFDPort holds optional BFD logical router port configuration.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| enabled | Enabled activates the BFD port. | bool | true |
| ip | IP is the IP address assigned to the BFD port. | string | false |
| nodeSelector | NodeSelector restricts which nodes the BFD LRP is hosted on. If not set, Kube-OVN selects up to 3 nodes automatically. | *[metav1.LabelSelector](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#labelselector-v1-meta) | false |

[Back to Group](#v1alpha1)

### VPCBFDPortStatus

VPCBFDPortStatus is the observed state of the BFD logical router port.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| name |  | string | false |
| ip |  | string | false |
| nodes |  | []string | false |

[Back to Group](#v1alpha1)

### VPCList

VPCList is the list type for VPC.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| metadata |  | [metav1.ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#listmeta-v1-meta) | false |
| items |  | [][VPC](#vpc) | true |

[Back to Group](#v1alpha1)

### VPCPeering

VPCPeering configures a peering connection between two VPCs.
The RemoteVPCRef references the name of another VPC wrapper in the same namespace.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| remoteVpcRef | RemoteVPCRef is the name of the remote VPC wrapper in the same namespace. | string | true |
| localConnectIP | LocalConnectIP is the local IP used to establish the peering connection. | string | false |

[Back to Group](#v1alpha1)

### VPCPolicyRoute

VPCPolicyRoute is a policy-based routing rule for the VPC router.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| priority | Priority determines evaluation order; lower numbers are evaluated first. | int | false |
| match | Match is the OVN match expression that selects traffic for this rule. | string | true |
| action | Action is the rule action: allow, drop, or reroute. | string | true |
| nextHopIP | NextHopIP is required when Action is reroute. | string | false |

[Back to Group](#v1alpha1)

### VPCSpec

VPCSpec defines the desired state of a VPC wrapper.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| defaultSubnet | DefaultSubnet is the name of the default subnet wrapper in this namespace. | string | false |
| staticRoutes | StaticRoutes configures static routes for the VPC router. | [][VPCStaticRoute](#vpcstaticroute) | false |
| policyRoutes | PolicyRoutes configures policy-based routing rules for the VPC router. | [][VPCPolicyRoute](#vpcpolicyroute) | false |
| vpcPeerings | VPCPeerings configures peering connections to other VPCs in the same namespace. | [][VPCPeering](#vpcpeering) | false |
| enableExternal | EnableExternal controls whether the VPC has access to the external network. | bool | false |
| enableBfd | EnableBfd enables Bidirectional Forwarding Detection on the VPC router. | bool | false |
| bfdPort | BFDPort holds configuration for the BFD logical router port. Only effective when EnableBfd is true. | *[VPCBFDPort](#vpcbfdport) | false |

[Back to Group](#v1alpha1)

### VPCStaticRoute

VPCStaticRoute is a single static route entry for the VPC router.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| cidr | CIDR is the destination IP prefix for this route. | string | true |
| nextHopIP | NextHopIP is the IP address of the next-hop router. | string | true |
| policy | Policy is the routing policy direction: dst or src. | string | false |
| bfdID | BFDID is the UUID of the BFD session to associate with this route. When set, the underlying KubeOVN VPC will use BFD-monitored ECMP for this route. | string | false |
| ecmpMode | ECMPMode sets the ECMP mode for this route (e.g. \"ecmp\" or \"ecmp-symmetric\"). | string | false |

[Back to Group](#v1alpha1)

### VPCStatus

VPCStatus mirrors the Kube-OVN VpcStatus, surfacing the full operational
state of the underlying cluster-scoped Vpc object.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| phase | Phase is the lifecycle phase of this VPC wrapper. | Phase | false |
| realName | RealName is the cluster-scoped Kube-OVN Vpc object name (namespace-prefixed). Used internally by dependent controllers. | string | false |
| standby |  | bool | true |
| default |  | bool | true |
| defaultLogicalSwitch |  | string | true |
| router |  | string | true |
| tcpLoadBalancer |  | string | true |
| udpLoadBalancer |  | string | true |
| sctpLoadBalancer |  | string | true |
| tcpSessionLoadBalancer |  | string | true |
| udpSessionLoadBalancer |  | string | true |
| sctpSessionLoadBalancer |  | string | true |
| subnets | Subnets lists the user-facing names of subnets belonging to this VPC (namespace prefix stripped). | []string | true |
| vpcPeerings | VPCPeerings lists the real names of peered Kube-OVN Vpcs. | []string | true |
| enableExternal |  | bool | true |
| extraExternalSubnets | ExtraExternalSubnets lists additional external subnets attached to this VPC. | []string | true |
| enableBfd |  | bool | true |
| bfdPort |  | [VPCBFDPortStatus](#vpcbfdportstatus) | true |

[Back to Group](#v1alpha1)

### AZEdgeRouter

AZEdgeRouter is the Schema for regional/AZ-mode edge routers that serve
multiple VPCs via per-VPC transit subnets and VRF-based routing.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| metadata | Refer to Kubernetes API documentation for fields of `metadata`. | [ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.37/#objectmeta-v1-meta) |  |
| spec |  | [AZEdgeRouterSpec](#azedgerouterspec) |  |
| status |  | [AZEdgeRouterStatus](#azedgerouterstatus) |  |

[Back to Group](#v1alpha1)

### AZEdgeRouterSpec

AZEdgeRouterSpec defines the desired state of an AZ-mode EdgeRouter.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| replicaCount | ReplicaCount is the number of FRR pod replicas. | integer |  |
| image | Image specifies the container images used by the EdgeRouter. | [EdgeRouterImage](#edgerouterimage) |  |
| managementSubnet | ManagementSubnet is the name of the OVN Subnet in the management VPC that the FRR pods are attached to. The operator uses this to derive the management VPC name and gateway. | string |  |
| vlan | VLAN is a reference to the pre-existing NetworkAttachmentDefinition for the external VLAN interface (net1). The FRR pod is attached to this VLAN as a Multus secondary, giving it L2 reachability to the physical/underlay network. Used by the EVPN and anycast transit modes; leave empty for "bgp-per-vrf", which peers the external router over per-tenant VLANs (perVRFTransit) instead and has no inbound VLAN uplink. | [NADRef](#nadref) |  |
| vlanGateway | VLANGateway is the default gateway IP on the VLAN NAD subnet. The operator sets the Multus routes annotation to route 0.0.0.0/0 via this address, making the VLAN interface the pod's default route (same mechanism as the per-VPC EdgeRouter's external NAD). Only meaningful when VLAN is set. | string |  |
| serviceVlan | ServiceVLAN is a reference to a SEPARATE pre-existing NetworkAttachmentDefinition for the service-advertisement (anycast) VLAN, distinct from the region-transit VLAN (VLAN/net1). When set to a NAD that DIFFERS from VLAN, the operator attaches it as a second inbound VLAN NIC (net2, pushing per-VPC transit NICs to net3+) and pins the plain-BGP anycast session (BGPPeers) to it, so region transit (EVPN, on net1) and service advertisement (anycast, on net2) ride physically different VLANs. When empty or equal to VLAN, both planes share net1 as before (no extra NIC). Only meaningful in EVPN/anycast transit mode (requires VLAN and BGPPeers). | [NADRef](#nadref) |  |
| serviceVlanGateway | ServiceVLANGateway is the gateway IP on the ServiceVLAN subnet used to reach off-subnet anycast BGP peers (BGPPeers). When set, the operator installs a /32 static route to each anycast peer via this gateway over the service VLAN NIC. Leave empty when the anycast peers are directly connected on the ServiceVLAN subnet (the common case), in which case the connected route suffices. This is NOT a default route — the pod default route stays on the region-transit VLAN. Only meaningful when ServiceVLAN differs from VLAN. | string |  |
| apiServerViaInternalProxy | APIServerViaInternalProxy makes the FRR pods reach the Kubernetes API server through an in-VPC apiserver proxy (a dual-homed nginx + SwitchLBRule that publishes the standard kubernetes ClusterIP inside the management VPC) using the default in-cluster config, instead of the operator injecting a node-IP KUBERNETES_SERVICE_HOST override. Set this when the FRR pods live in a custom management VPC with no L2 path to the node/apiserver IP (the common case for AZ routers) — the node-IP override would otherwise point at an unreachable address. When true the operator skips the override regardless of VLAN. The proxy itself is deployed out-of-band (see the lab's az-apiserver-proxy.yaml). Mirrors the per-VPC EdgeRouter's spec.peers.apiServerViaInternalProxy. | boolean |  |
| dynamicTransitNICs | DynamicTransitNICs attaches the per-VPC transit NICs to the running router pods by Multus hot-plug instead of baking them into the StatefulSet pod template. With it on the pod template carries only the base NICs (eth0 + inbound VLAN + service VLAN), so adding or removing a VPC no longer changes the template hash and the StatefulSet does NOT roll — already-attached VPCs keep their BGP/BFD sessions instead of flapping during onboarding/off-boarding. The transit NICs are reconciled onto the live pods (EnsureAZTransitNICHotplug) and the multus-dynamic-networks-controller performs the CNI ADD/DEL. Requires that controller (thick-mode Multus). A rolled/recreated pod starts base-only and is gated NotReady by the transit-NIC readiness probe until its NICs are hot-plugged and enslaved, so RollingUpdate never runs two replicas transit-less at once. Falls back to template attachment when false (the default). | boolean |  |
| configWatcher | ConfigWatcher configures the configuration watcher sidecar. Defaulted ON, and it has to be defaulted by the API SERVER rather than in SetDefaults: Enabled is a plain bool, so an omitted block and an explicit `enabled: false` are indistinguishable in Go, and defaulting the zero value would override a deliberate opt-out. A schema default applies only when the field is absent, which is exactly the distinction needed. Off is very nearly non-functional and fails quietly: the init container writes frr.conf once and nothing re-renders it as VPCs resolve, the nftables rules (SNAT carve-outs, the BFD TTL fixup) are never applied, and BFD/learned-route status is never reported. The router reports Ready with its per-VRF sessions stuck in Connect, which reads as a fabric problem. | [ConfigWatcherSpec](#configwatcherspec) |  |
| bfd | BFD configures Bidirectional Forwarding Detection. When BFD.Internal.Enabled is set, the operator enables a BFD logical-router port on each tenant VPC and creates BFD sessions to every replica's transit IP, so OVN-monitored ECMP reroute policies automatically prune a dead replica's transit IP. The FRR pods run bfdd and answer the OVN gateway's BFD probes per VPC VRF. | [BFDSpec](#bfdspec) |  |
| netshoot | Netshoot configures the netshoot debug sidecar. | [NetshootSpec](#netshootspec) |  |
| resources | Resources defines the resource requirements for each container. | [EdgeRouterResources](#edgerouterresources) |  |
| nodeSelector | NodeSelector constrains the FRR pods to nodes matching these labels. | object (keys:string, values:string) |  |
| allowColocatedReplicas | AllowColocatedReplicas lets more than one replica run on the same node. By default the FRR pods carry a REQUIRED anti-affinity on kubernetes.io/hostname, so a router can never run more replicas than there are nodes matching NodeSelector. That is not a preference: each replica's transit IP becomes an ECMP nexthop on the tenant VPC router, monitored by its own BFD session, and the whole mechanism assumes a nexthop can fail on its own. Two replicas on one node give two nexthops that die together. Setting this relaxes the term to PREFERRED, so the scheduler still spreads the pods whenever it can and falls back to colocation instead of leaving a pod Pending. It is for labs and single-node-per-zone environments that need to exercise the multi-replica paths, NOT a way to claim redundancy on hardware that cannot provide it. What it costs, both of which are reported rather than hidden:   - the ReplicaRedundancy condition goes False (ReplicasColocated) whenever replicas     actually end up sharing a node, because ReplicasSchedulable will read True — they     schedule fine, they just share a failure domain   - the PodDisruptionBudget stays at maxUnavailable=1, so draining a node holding two     replicas cannot satisfy the budget and blocks. That is deliberate: loosening it would     also loosen it for the spread case, where it is the only thing stopping a drain from     taking every replica at once. Use `kubectl drain --disable-eviction`, or scale to one     replica first. | boolean |  |
| zone | Zone names the availability zone this router serves, e.g. "region-a". It exists because several AZEdgeRouters share the same tenant VPCs — one per zone, each advertising only the subnets its VPCs.SubnetLabelSelector pins to itself — and a shared VPC object therefore has to describe one external-VLAN attachment PER ZONE. The zones may share the VLAN and the fabric peer, but never the per-replica addresses on it. The per-VPC annotations are keyed by this value: 	az-edge-router.virtualization.k8c.io/<zone>.nad-name 	az-edge-router.virtualization.k8c.io/<zone>.local-ips 	az-edge-router.virtualization.k8c.io/<zone>.peer-ip 	az-edge-router.virtualization.k8c.io/<zone>.accept-prefixes The zone rather than the router's name: it is the identity the rest of the platform already uses (the same value in NodeSelector's topology.kubernetes.io/region and in the subnets' topology.kubernetes.io/zone label), so a VPC's annotations survive renaming or replacing the router object that serves a zone. Optional, and unset is a complete answer for a single-zone installation: the unsuffixed annotations then apply. What is NOT allowed is a router with no Zone reading a VPC that carries zone-scoped annotations — it cannot know which set is its own, and guessing would attach it to another zone's VLAN and claim that zone's addresses. That VPC is skipped with an error instead. | string |  |
| imagePullSecrets | ImagePullSecrets is a list of references to secrets for pulling images. | [LocalObjectReference](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.37/#localobjectreference-v1-core) array |  |
| transitSubnet | TransitSubnet configures the per-VPC /30 transit address pool. | [AZTransitSubnetSpec](#aztransitsubnetspec) |  |
| vpcs | VPCs configures how VPCs are discovered and attached. | [AZVPCsSpec](#azvpcsspec) |  |
| peerAZEdgeRouters | PeerAZEdgeRouters lists other AZEdgeRouter CRs (same namespace) whose resolved VPCs should also get transit NICs on this router's FRR pods. | string array |  |
| vpcEdgeRouters | VPCEdgeRouters lists per-VPC EdgeRouter CRs that this AZ router should peer with. Reserved for future use — enables injecting per-VPC routes into the AZ transit fabric. | [AZVPCEdgeRouterRef](#azvpcedgerouterref) array |  |
| asn | ASN is the BGP autonomous system number. Required when EVPNPeers, BGPPeers or InternalPeers are configured. EVPNPeers and BGPPeers may be used together: EVPNPeers carries EVPN Type 5 cross-zone routing while BGPPeers carries plain IPv4 unicast advertisement (aggregated anycast and/or OVN subnets) to an external router. | integer |  |
| evpnPeers | EVPNPeers lists the BGP peers for EVPN Type 5 route exchange. These are typically other AZEdgeRouter instances in remote regions/AZs. | [AZEVPNPeer](#azevpnpeer) array |  |
| evpnUnderlayPrefixes | EVPNUnderlayPrefixes is the list of CIDR blocks covering the VTEP underlay addresses of all AZ edge routers. When non-empty, static routes for these prefixes are installed via the VLAN gateway so that EVPN VTEP resolution works without relying on the default route. | string array |  |
| bgpPeers | BGPPeers lists the external upstream BGP peers reached over the VLAN (net1) for plain IPv4 unicast advertisement. These carry two independent planes:   - the anycast plane: static-anycast blocks learned from InternalPeers and     re-advertised with next-hop-self (3-party aggregation), and   - the OVN-subnet transit plane when OVNTransitMode is "bgp". May be used together with EVPNPeers. | [AZBGPPeer](#azbgppeer) array |  |
| ovnTransitMode | OVNTransitMode selects how OVN tenant subnets are advertised to the external router, preserving per-tenant VRF isolation:   - "evpn" (default): EVPN Type 5 via EVPNPeers (VXLAN dataplane).   - "bgp-per-vrf": one plain-BGP session per VPC, sourced from that VPC's VRF     over a per-tenant VLAN subinterface, landing the subnet in a matching VRF     on the external router. | string |  |
| internalPeers | InternalPeers enables per-VPC BGP peering with in-VPC speakers (e.g. FRR or MetalLB) that advertise static anycast blocks. Learned prefixes are re-advertised with next-hop-self (3-party aggregation), so the external router only ever routes to this AZ router's VLAN IP. Requires an external advertisement plane to re-advertise into: either BGPPeers (the default-VRF anycast plane) or OVNTransitMode "bgp-per-vrf" (where each VPC's own fabric session carries the anycast, since there is no default-VRF session to aggregate through). With neither, this is inert. | [AZInternalPeersSpec](#azinternalpeersspec) |  |
| perVRFTransit | PerVRFTransit configures the per-tenant underlay VLAN attachments used when OVNTransitMode is "bgp-per-vrf". kube-ovn presents the pod an access-style interface (no VLAN trunking), so each VPC VRF gets its OWN underlay VLAN NAD + subnet — a dedicated Multus interface bound to that VRF — over which a per-VRF BGP session peers the external router in a matching VRF. | [AZPerVRFTransitSpec](#azpervrftransitspec) |  |

[Back to Group](#v1alpha1)

### AZEdgeRouterStatus

AZEdgeRouterStatus defines the observed state of AZEdgeRouter.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| observedGeneration | ObservedGeneration is the metadata.generation this status was computed from. It is set on every completed reconcile, which is what makes the operator write status even when NOTHING else in it changed — in particular when zero VPCs are attached, where every other field stays at its zero value and the status update would otherwise be skipped as a no-op. It is the signal the FRR init container waits on: "the operator has processed this spec", which is distinguishable from "the operator has not run yet". Waiting for a non-empty ResolvedAZVPCs instead cannot tell those apart, so a router with no VPC attached never started. | integer |  |
| apiServerProxyVIP | APIServerProxyVIP is the in-VPC apiserver proxy address the operator resolved from its own --internal-apiserver-url, published here because the SIDECAR needs it to program the per-VPC route and masquerade for APIServerProxy VPCs, and reads only this CR. Empty unless spec.apiServerViaInternalProxy is set. | string |  |
| readyReplicas | ReadyReplicas is the number of ready FRR pod replicas. | integer |  |
| vpcCount | VPCCount is the number of VPCs currently attached. | integer |  |
| peerCount | PeerCount is the number of peer AZEdgeRouters resolved. | integer |  |
| conditions | Conditions is the list of status conditions. | [Condition](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.37/#condition-v1-meta) array |  |
| resolvedAZVPCs | ResolvedAZVPCs is the list of VPCs attached with their allocated transit IPs and routing table IDs. | [ResolvedAZVPC](#resolvedazvpc) array |  |
| peerResolvedAZVPCs | PeerResolvedAZVPCs contains VPCs resolved by peer AZEdgeRouters. | [PeerResolvedAZVPCs](#peerresolvedazvpcs) array |  |
| learnedBGPRoutes | LearnedBGPRoutes tracks the (prefix, nexthop) anycast routes learned from internal speakers and programmed as VPC static ECMP routes on the tenant VPCs. Recorded for ownership so stale routes are pruned when a speaker withdraws. | [LearnedBGPRoute](#learnedbgproute) array |  |
| resolvedEVPNPeers | ResolvedEVPNPeers is populated by the EVPNRouteReflector controller with the RR replica IPs (as EVPN-only neighbors). The frr-config-watcher sidecar merges these with spec.EVPNPeers so the AZ router peers an in-cluster, operator-managed route reflector without any static peer configuration. Mirrors EdgeRouter. | [EVPNPeer](#evpnpeer) array |  |

[Back to Group](#v1alpha1)

### AZVPCsSpec

AZVPCsSpec configures how VPCs are discovered and attached in AZ mode.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| autoDiscovery | AutoDiscovery enables automatic discovery of kube-ovn VPC objects via LabelSelector. When false, VPCs must be listed explicitly in List. | boolean |  |
| labelSelector | LabelSelector selects kube-ovn VPC objects to attach to this AZEdgeRouter. Only used when AutoDiscovery is true. | [LabelSelector](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.37/#labelselector-v1-meta) |  |
| subnetLabelSelector | SubnetLabelSelector filters which wrapper Subnet objects within each discovered/listed VPC are advertised by this AZEdgeRouter instance. This allows multiple AZEdgeRouters (one per region/zone) to share the same VPCs while each only handling the subnets pinned to its own zone. When empty, all subnets belonging to the VPC are included. | [LabelSelector](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.37/#labelselector-v1-meta) |  |
| list | List is the explicit set of VPCs to attach when AutoDiscovery is false. | [AZVPCRef](#azvpcref) array |  |

[Back to Group](#v1alpha1)

### AZVPCRef

AZVPCRef identifies a kube-ovn VPC to attach to the AZEdgeRouter.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| name | Name is the name of the kube-ovn VPC object. | string |  |
| egressToSource | EgressToSource is an optional fixed source IP to use when SNAT-ing traffic from this VPC. When set, the operator copies this value into ResolvedAZVPC.EgressToSource so the frr-config-watcher sidecar can program a static SNAT rule instead of MASQUERADE. Unlike EgressToSourceBySubnet, this single address is assigned identically to EVERY replica — it does not get the same replicaCount-many-addresses treatment, so it carries the same ECMP-reply-asymmetry exposure EgressToSourceBySubnet's per-replica requirement exists to avoid: this fabric's ECMP does not reliably keep a flow's outbound and return legs on the same replica, so un-SNAT-ing a reply that lands on a DIFFERENT replica than the one that SNAT'd the request depends on the interface actually owning that address on whichever replica the reply arrives at. With replicaCount > 1 that is not guaranteed by this field alone. Prefer EgressToSourceBySubnet when replicaCount > 1 and per-flow return-path correctness matters (e.g. the compliance/audit use case this pair of fields exists for). | string |  |
| egressToSourceBySubnet | EgressToSourceBySubnet overrides EgressToSource for specific subnets within this VPC, keyed by canonical IPv4 CIDR (net.ParseCIDR's masked form, matching the key as written — same rule ValidAcceptPrefixes applies to accept-lists, and for the same reason: these keys are interpolated into an nftables source-address match, not just compared). A subnet not listed here falls back to EgressToSource (or plain MASQUERADE if that is also unset). This is the compliance/allowlisting case: a tenant needs one specific subnet to present a distinct, stable external source IP, without every subnet in the VPC needing its own dedicated egress VLAN/NIC — all subnets still egress through the VPC's one shared external interface; only the SNAT source address differs per subnet. Each value is a list of IPs, ONE PER REPLICA (same convention as TransitIPPool), not a single shared address: this fabric's ECMP does not reliably keep a flow's outbound and return legs on the same router replica (see the anycast-carve-out incident documented on nftrules.azAddAnycastSrcCarveOut — ~75% of connections to a shared/anycast address failed, deterministically by flow hash). Un-SNAT-ing a reply is mandatory for egress traffic (unlike inbound VIP traffic, there is no "let it pass through unmodified" escape hatch), so a reply landing on a replica that never made the original connection cannot be recovered — each replica MUST present its own distinct source IP. A list shorter than spec.replicaCount is rejected at resolution (az_vpcs.go), the same way a malformed annotation is: this VPC's egress override does not apply, ExternalVLANError-style, rather than silently running some replicas without one. OPERATIONAL REQUIREMENT, not enforced by the operator: every IP used here MUST be added to spec.excludeIps on whichever kube-ovn Subnet manages the address range it is drawn from (typically the external/per-VRF transit subnet), or that subnet's own IPAM can hand the same address to an unrelated NIC — the same class of collision spec.excludeIps already exists to prevent for gateway/reserved addresses. The operator does not own that Subnet object for the kubeovn backend today (it is provisioned externally, same as the external VLAN subnets themselves), so this is on whoever provisions it, not automatic. | object (keys:string, values:string array) |  |

[Back to Group](#v1alpha1)

### AZVPCVLANRef

AZVPCVLANRef maps one VPC to its pre-provisioned external underlay VLAN. The VLAN
is referenced either as an UnderlaySubnet (the operator/platform provisions the
ProviderNetwork+Vlan+Subnet+NAD) or, for a VLAN whose NAD already exists (e.g. a
shared fabric NAD created directly), by NAD name. Exactly one of UnderlaySubnet or
NADName must be set.
AZVPCVLANRef binds one VPC to its external VLAN. The two VLAN sources are mutually exclusive but BOTH optional: naming neither is a
policy-only override (e.g. AdvertiseOVNSubnets for a VPC whose VLAN comes from its
az-edge-router.virtualization.k8c.io annotations), and EnsureAZExternalVLANs merges the VLAN
source in from those annotations rather than replacing the entry. Naming both is the case
nothing could resolve — hence the rule, which rejects it at admission instead of leaving the
operator to pick a winner silently.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| vpc | VPC is the kube-ovn VPC name; must match a VPC this router resolves. | string |  |
| underlaySubnet | UnderlaySubnet is the name of the pre-provisioned UnderlaySubnet (bundling the ProviderNetwork, the 802.1Q Vlan and the IP Subnet) that carries this VPC's external VLAN. The operator attaches its auto-created NAD and enslaves the interface to the VPC's VRF. Mutually exclusive with NADName. | string |  |
| nadName | NADName references a PRE-EXISTING NetworkAttachmentDefinition (in the router's namespace) backing this VPC's external VLAN, as an alternative to UnderlaySubnet. Use this to attach to a NAD provisioned outside the AZ operator — e.g. a shared fabric NAD also used by a per-VPC EdgeRouter. The provider is derived as "<NADName>.<namespace>.ovn", matching kube-ovn's NAD provider convention in both backends. Mutually exclusive with UnderlaySubnet. | string |  |
| vlanID | VLANID is the underlying 802.1Q VLAN tag NADName's NAD actually carries traffic on, declared here because the operator has no other way to learn it: for UnderlaySubnet it is read authoritatively off UnderlaySubnet.Spec.VlanID instead (this field is ignored in that case), but a raw NADName reference is opaque — its NAD's spec.config is CNI plugin config, not something safe to reverse-engineer a VLAN tag out of. This exists SOLELY so arbitrateAZExternalVLANOverlaps can tell "two VPCs on genuinely separate NADs that happen to ride the same physical VLAN wire" apart from "two VPCs that coincidentally used the same VLAN ID for unrelated fabrics" — grouping by VLANID instead of NADName when it is set. Two VPCs sharing a NAD but declaring DIFFERENT (or no) VLANID still group correctly by NADName, so leaving this unset preserves prior behavior exactly. Zero means "unknown" — never a real answer, since VLAN 0 is reserved/untagged — so a VPC that does not declare it simply falls back to the NADName-keyed grouping. | integer |  |
| localIPs | LocalIPs are the AZ router's per-replica IPs on this VLAN — one per replica, within the UnderlaySubnet's CIDR. The operator builds the external-VLAN NAD's ip_pool annotation from this list so each StatefulSet replica gets its own stable IP; the external router peers each as a BGP neighbor (ECMP). | string array |  |
| localASN | LocalASN overrides AZEdgeRouterSpec.ASN as the LOCAL autonomous system number for this VPC's own per-VRF BGP instance ("router bgp <ASN> vrf <vpc>"). Zero (the default) inherits the router-wide ASN, same sentinel convention AZEdgeRouterSpec.ASN itself uses. Set this when VPCs sharing one advertisement VLAN need to present distinct AS numbers to the fabric — e.g. so the external router can apply AS-path-based policy per VPC instead of relying solely on neighbor IP or prefix content. Does not affect the default (non-per-VRF) BGP instance or the REMOTE peer ASN (see AZVPCFabricPeer.ASN for that). NOT SUPPORTED together with EVPN on the same VPC (a non-zero ResolvedAZVPC.VNI, from the backend or an EVPNPolicy): the EVPN RD/RT are always derived from the router-wide ASN, independent of this override, so combining the two would silently put the VRF's BGP session under one ASN and its RD/RT under another. The operator rejects the combination (ExternalVLANError) rather than guessing which one should win. | integer |  |
| peerIP | PeerIP is the external router's IP on this VLAN — the shared BGP neighbor that every replica peers with. SUPERSEDED by Peers, which can carry more than one neighbor and say what each is sent. Still honoured and still the common shape: EffectivePeers folds it into Peers as a single peer that advertises everything and carries the VRF default route, which is exactly what it does today. Setting both is rejected unless the scalar restates one of the peers — a silent union would be two sessions where one was meant. Not yet marked Deprecated: the status field and the config builder still read it, so the marker would only fire on this operator's own code. It becomes a real deprecation once those consumers take Peers. Pattern-validated at admission for the same reason as AcceptPrefixes: this value renders verbatim into the FRR template ("neighbor \{\{ .IP \}\} ...", "ip route 0.0.0.0/0 \{\{ .IP \}\} ..."), so an embedded newline would inject extra config lines. EffectivePeers additionally rejects it at runtime for callers (e.g. the VPC annotation path) that build an AZVPCVLANRef outside admission. | string |  |
| peers | Peers are the external BGP neighbors on this VPC's VLAN, replacing PeerIP. More than one because the fabric may put the tenant's SERVICE plane and its WORKLOAD plane on different routers: one neighbor takes the VPC's OVN subnets, another takes only the anycast blocks learned from in-VPC speakers. Both sit on this VPC's single underlay VLAN and are told apart by what each is sent, not by which wire they are on — per-tenant L2 separation would need a second NAD per VPC and is deliberately not this field. | [AZVPCFabricPeer](#azvpcfabricpeer) array |  |
| advertiseOVNSubnets | AdvertiseOVNSubnets overrides AZPerVRFTransitSpec.AdvertiseOVNSubnets for THIS VPC only, so one tenant can run SNAT-only egress (its fabric VRF never learns tenant space) while the tenants beside it stay directly routed — or the inverse, carving one directly-routed tenant out of an otherwise SNAT-only router. Absent inherits the router-wide setting; the session itself, the VPC's static routes and its BFD /32 are unaffected either way. | boolean |  |
| acceptPrefixes | AcceptPrefixes overrides AZPerVRFTransitSpec.AcceptPrefixes for THIS VPC only — what its own external fabric peer(s) may inject into its VRF via BGP. Absent inherits the router-wide list (empty there means deny everything). See AZPerVRFTransitSpec.AcceptPrefixes for why this exists. | [AZAcceptPrefix](#azacceptprefix) array |  |

[Back to Group](#v1alpha1)

### AZVPCFabricPeer

AZVPCFabricPeer is one external BGP neighbor on a VPC's underlay VLAN, in the
"bgp-per-vrf" OVN transit mode. Every field except IP is an override of something inherited, so the zero value is
"behave like the single peerIP always did". The two Advertise* flags map onto the two
clauses of the per-VRF egress filter the router already builds — OVN subnets, and the
anycast blocks learned from in-VPC speakers — which is what lets one VLAN carry a
workload peer and a service peer at once.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| ip | IP is the neighbor's address on this VPC's underlay VLAN. Pattern-validated at admission for the same reason as AcceptPrefixes: this value renders verbatim into the FRR template ("neighbor \{\{ .IP \}\} ...", "ip route 0.0.0.0/0 \{\{ .IP \}\} ..."), so an embedded newline would inject extra config lines. EffectivePeers additionally rejects it at runtime for callers (e.g. the VPC annotation path) that build an AZVPCFabricPeer outside admission. | string |  |
| asn | ASN is the neighbor's autonomous system number. Zero inherits AZPerVRFTransitSpec.PeerASN, which is the common case; set it to face a transit AS and a service AS from the same VPC. Mirrors ExternalNeighbor.ASN on the per-VPC EdgeRouter. | integer |  |
| advertiseOVNSubnets | AdvertiseOVNSubnets sends this VPC's OVN tenant subnets to this neighbor. Absent inherits the per-VPC AdvertiseOVNSubnets, then the router-wide one, then true. This is an EXPORT policy and nothing else: it does not decide whether the neighbor carries the VRF's default route (see DefaultRoute) and does not touch the VPC's static routes or its BFD session. A peer with this false is SNAT-only egress, not an unrouted one. | boolean |  |
| advertiseAnycast | AdvertiseAnycast sends the anycast blocks learned from this VPC's in-VPC speakers (InternalPeers) to this neighbor — what makes a SERVICE peer. Absent inherits "the router has no default-VRF BGPPeers". That reproduces the older router-wide rule exactly: with a default-VRF service plane configured, anycast is advertised there and withheld from every per-VRF session. Defaulting it to true instead would start leaking tenant anycast to the fabric on upgrade. UNLESS another peer on this VPC sets it explicitly true. Declaring a dedicated service peer withdraws anycast from every peer that did not ask for it, so the split does not need the transit peer to be marked false as well — see resolveAnycast. Setting false here is still honoured, and is how a peer opts out when no service peer exists. Ignored for a VPC with no internal speakers, which has no anycast to send. | boolean |  |
| defaultRoute | DefaultRoute makes this neighbor a VRF default gateway ("ip route 0.0.0.0/0 <ip>" inside the VPC's VRF). Absent means CANDIDATE — EXCEPT for a peer with MultihopTTL > 1, which is never an implicit candidate: nothing installs a /32 to a multihop peer, so its default route could never resolve its own nexthop and would sit installed-but-inactive, leaving the VPC with silent no-egress. Set this true explicitly on a multihop peer only when it is reachable some other way (e.g. an IGP-learned route). Every OTHER candidate gets a route, so two fabric devices on this VLAN are ECMP rather than one being silently preferred; one peer stays one route, which is today's behaviour. Marking any peer true narrows the set to the marked ones — the way to keep a transit peer out of it, along with setting false here. Deliberately NOT derived from the Advertise* flags: a SNAT-only transit peer advertises nothing and is still the egress gateway, which makes it flag-identical to a service peer. The role has to be stated, and on the annotation surface the key name states it. | boolean |  |
| multihopTTL | MultihopTTL is the eBGP multihop TTL, for a neighbor that is not on this VLAN's subnet. Zero or 1 is single-hop. | integer |  |
| bfd | BFD enables BFD on this session. Absent inherits spec.bfd.external.enabled, which today turns every external neighbor on or off together; set it to face one fabric device that requires BFD beside one that does not. | boolean |  |

[Back to Group](#v1alpha1)

### AZVPCEdgeRouterRef

AZVPCEdgeRouterRef identifies a per-VPC EdgeRouter CR to peer with.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| name | Name is the name of the per-VPC EdgeRouter CR. | string |  |
| namespace | Namespace is the namespace. Defaults to the AZEdgeRouter's namespace. | string |  |

[Back to Group](#v1alpha1)

### AZAcceptPrefix

AZAcceptPrefix is one entry in a bgp-per-vrf fabric accept-list (PL-EXT-IN-<vrf>) — what an
external fabric peer may inject into a VPC's VRF via BGP. Distinct from the internal-speaker
accept-list (AZInternalPeersSpec.AcceptPrefixes, METALLB-IN), which bounds a different
direction and peer entirely.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| cidr | CIDR is the IPv4 network to accept from the fabric peer. | string |  |
| allowedPrefixLength | AllowedPrefixLength, when set, renders the prefix-list entry as "CIDR le N", admitting any more-specific prefix contained within CIDR (up to a /N mask) rather than only the exact CIDR — mirrors AdvertisedInternalSubnetInput.AllowedPrefixLength in pkg/network/frr/config.go, the existing pattern for this same per-entry opt-in elsewhere in this codebase. 0 (the default) accepts only the exact CIDR. Must be between the CIDR's own mask length and 32 when set; a value outside that range is dropped by ValidAZAcceptPrefixes the same way a malformed CIDR is. | integer |  |

[Back to Group](#v1alpha1)

### AZBGPPeer

AZBGPPeer defines an upstream BGP peer for plain IPv4 unicast route advertisement.
Used when BGPPeers is set and EVPNPeers is not — enables the AZEdgeRouter to
advertise per-VPC subnets to an external router without EVPN/VXLAN encapsulation.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| ip | IP is the peer's IP address. | string |  |
| asn | ASN is the peer's autonomous system number. | integer |  |
| multihopTTL | MultihopTTL is the eBGP multihop TTL. 0 or 1 means single-hop. | integer |  |

[Back to Group](#v1alpha1)

### AZEVPNPeer

AZEVPNPeer defines a BGP peer for EVPN Type 5 route exchange between AZEdgeRouters.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| ip | IP is the peer's IP address. | string |  |
| asn | ASN is the peer's autonomous system number. | integer |  |
| multihopTTL | MultihopTTL is the eBGP multihop TTL. 0 or 1 means single-hop. | integer |  |

[Back to Group](#v1alpha1)

### AZExternalVLAN

AZExternalVLAN holds the resolved per-VRF underlay VLAN attachment for one VPC in
"bgp-per-vrf" mode. The pod attaches an access-style interface (VLAN tagging is on
the upstream provider network), so no 802.1q VLAN ID is tracked here; that is only
needed once trunk-port attachment (ovs-cni) is introduced.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| nadName | NADName is the operator-created Multus NAD for this VPC's external VLAN. | string |  |
| vlanID | VLANID is the resolved 802.1Q VLAN tag this attachment rides — AZVPCVLANRef.VLANID for a raw NADName reference, or UnderlaySubnet.Spec.VlanID (authoritative) for an UnderlaySubnet reference. Zero means unknown; see AZVPCVLANRef.VLANID for why that falls back to grouping by NADName rather than being treated as a real VLAN. | integer |  |
| interfaceName | InterfaceName is the Multus-assigned NIC name inside the pod (e.g. "net4"). | string |  |
| localIPs | LocalIPs holds the AZ router's per-replica IPs (bare, no prefix) on the underlay VLAN — one entry per replica, e.g. ["172.30.0.2", "172.30.0.3"]. The external VLAN NAD's ip_pool annotation is built from this list so each StatefulSet replica gets its own stable IP, and the external router peers each replica as a BGP neighbor (ECMP across replicas). Mirrors ResolvedAZVPC.TransitIPPool. | string array |  |
| localASN | LocalASN is the RESOLVED local autonomous system number for this VPC's own per-VRF BGP instance ("router bgp <ASN> vrf <vpc>"): AZVPCVLANRef.LocalASN if set, else AZEdgeRouterSpec.ASN. Reported here, rather than only in spec, so status is the single source of truth for what ASN the FRR config builder actually rendered. | integer |  |
| peerIP | PeerIP is the external router's IP on the underlay VLAN (the shared BGP neighbor that every replica peers with). With several peers this reports the one carrying the VRF default route, or the first otherwise. Kept populated because it is what existing readers — the dashboard among them — already display; Peers is the complete answer. | string |  |
| peers | Peers are all the fabric neighbors on this VLAN with their defaults resolved, so what the router actually configured is readable without re-deriving the precedence rules from the spec. | [AZResolvedFabricPeer](#azresolvedfabricpeer) array |  |
| acceptPrefixes | AcceptPrefixes is the RESOLVED inbound accept-list for this VPC's external fabric peer(s), in precedence order: AZVPCVLANRef.AcceptPrefixes, else the VPC's fabric-accept-prefixes annotation, else the AZ-wide AZPerVRFTransitSpec.AcceptPrefixes. An empty list means the per-VRF ingress filter (PL-EXT-IN-<vrf>) denies every prefix from this VPC's fabric peer(s) — the safe default, since DefaultRoutePeers are static routes, not BGP-learned. | [AZAcceptPrefix](#azacceptprefix) array |  |

[Back to Group](#v1alpha1)

### AZInternalPeersSpec

AZInternalPeersSpec configures per-VPC peering with in-VPC BGP speakers that
advertise static anycast blocks for aggregation toward the external router.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| enabled | Enabled turns on the per-VPC internal peer-group. Requires an external advertisement plane — BGPPeers or OVNTransitMode "bgp-per-vrf". | boolean |  |
| asn | ASN is the internal speakers' autonomous system number. Zero means the session is configured as "remote-as external" (accept any peer ASN). | integer |  |
| acceptPrefixes | AcceptPrefixes bounds what the AZ router will learn from internal speakers (the METALLB-IN prefix-list), typically the anycast super-block(s). An empty list accepts nothing, so a misconfigured speaker cannot inject arbitrary routes toward the external router. This is the default applied to every VPC; PerVPC overrides it per VPC. Entries are IPv4 CIDRs and are interpolated verbatim into frr.conf's METALLB-IN prefix-lists, so the shape is validated at admission: a value containing a newline would render as extra configuration lines. The operator filters the annotation-sourced form the same way (v1alpha1.ValidAcceptPrefixes), since annotations get no schema. | string array |  |
| perVPC | PerVPC narrows AcceptPrefixes for individual VPCs. Each VPC's internal peer-group filters on its own accept-list, so a speaker in one tenant VPC cannot inject another tenant's anycast block — which a single AZ-wide list permits, since every VRF then shares one filter. A VPC with no entry here uses AcceptPrefixes unchanged. | [AZInternalPeersVPCOverride](#azinternalpeersvpcoverride) array |  |
| multihopTTL | MultihopTTL is the eBGP multihop TTL for the internal session; the speaker sits one or more hops away behind the tenant VPC logical router. | integer |  |
| bfd | BFD enables BFD on the internal session. | boolean |  |

[Back to Group](#v1alpha1)

### AZInternalPeersVPCOverride

AZInternalPeersVPCOverride narrows the internal-speaker accept-list for one VPC.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| vpc | VPC is the kube-ovn VPC name; must match a VPC this router resolves. An entry naming an unresolved VPC has no effect. | string |  |
| acceptPrefixes | AcceptPrefixes replaces AZInternalPeersSpec.AcceptPrefixes for this VPC. An explicitly empty list accepts nothing from this VPC's speakers — distinct from omitting the entry, which inherits the AZ-wide list. Entries are IPv4 CIDRs and are interpolated verbatim into frr.conf's METALLB-IN prefix-lists, so the shape is validated at admission: a value containing a newline would render as extra configuration lines. The operator filters the annotation-sourced form the same way (v1alpha1.ValidAcceptPrefixes), since annotations get no schema. | string array |  |

[Back to Group](#v1alpha1)

### AZPerVRFTransitSpec

AZPerVRFTransitSpec configures per-tenant underlay VLAN attachments for the
"bgp-per-vrf" OVN transit mode. The platform pre-provisions one UnderlaySubnet
(ProviderNetwork + Vlan + Subnet) per tenant VLAN; the operator maps each own VPC
to its UnderlaySubnet, attaches a NAD to it, allocates per-replica IPs, enslaves
the interface to the VPC's VRF, and peers the external router over it.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| peerASN | PeerASN is the external router's autonomous system number for the per-VRF eBGP sessions. | integer |  |
| vpcVLANs | VPCVLANs maps each own VPC to the pre-provisioned underlay VLAN subnet it uses for its external per-VRF attachment. | [AZVPCVLANRef](#azvpcvlanref) array |  |
| advertiseOVNSubnets | AdvertiseOVNSubnets controls whether each VPC's OVN tenant subnets (and its transit subnet) are advertised to that VPC's per-VRF fabric peer. Defaults to true, which suits a fabric that routes directly to tenant subnets. Set false for SNAT-only tenant egress, where the fabric must NOT learn tenant space: the tenant subnets are then reachable only via the router's egress addresses, and the per-VRF session carries just the anycast blocks learned from in-VPC speakers (see InternalPeers). Without this, the per-VRF session advertises every subnet in status.resolvedAZVPCs[].subnets unconditionally. This is the router-wide default; VPCVLANs[].AdvertiseOVNSubnets overrides it for an individual VPC. | boolean |  |
| acceptPrefixes | AcceptPrefixes bounds what a VPC's external per-VRF fabric peer(s) may inject INTO that VPC's VRF via BGP — the inbound counterpart to the outbound egress filter AdvertisedSubnets/AdvertiseOVNSubnets already builds. Without it, "no bgp ebgp-requires-policy" (required so the session can come up without EITHER direction configured) leaves the peer free to advertise ANY prefix — including another tenant's subnet on a shared advertisement VLAN — with nothing on this router checking it. Empty (the default) denies every inbound prefix: DefaultRoutePeers are rendered as STATIC routes, not learned via BGP, so no bgp-per-vrf deployment today depends on receiving anything from these sessions. Set this only for the rare case a fabric device needs to push something specific (e.g. a BGP-learned default instead of a static one). This is the router-wide default; VPCVLANs[].AcceptPrefixes overrides it for an individual VPC, and a VPC's own fabric-accept-prefixes annotation feeds the override the same way it does for NADName/PeerIP/LocalASN. | [AZAcceptPrefix](#azacceptprefix) array |  |

[Back to Group](#v1alpha1)

### AZResolvedFabricPeer

AZResolvedFabricPeer is one fabric neighbor as the router configured it.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| ip | IP is the neighbor's address on the underlay VLAN. | string |  |
| asn | ASN is the neighbor's ASN, after inheriting perVRFTransit.peerASN. | integer |  |
| advertiseOVNSubnets | AdvertiseOVNSubnets reports whether this neighbor is sent the VPC's OVN subnets. | boolean |  |
| advertiseAnycast | AdvertiseAnycast reports whether it is sent the anycast blocks learned in-VPC. | boolean |  |
| defaultRoute | DefaultRoute reports whether it carries the VRF's default route. Exactly one neighbor per VPC can, and none is allowed. | boolean |  |
| bfd | BFD reports whether the session runs BFD. | boolean |  |
| multihopTTL | MultihopTTL is the eBGP multihop TTL configured for the session; 0 is single-hop. | integer |  |

[Back to Group](#v1alpha1)

### AZTransitSubnetSpec

AZTransitSubnetSpec configures the transit address pool used to create
per-VPC /30 point-to-point subnets in the management VPC. Each tenant VPC
gets its own /30 Subnet CR named "<SubnetName>-<vpcName>", providing a
firewalling boundary between tenants with no implicit inter-VPC L2 path. For VPC at sorted index i with replicaCount R, a block of size S=nextPow2(R+3)
is allocated (minimum 4, i.e. /30 for R=1). The +3 reserves the network,
gateway and broadcast addresses, so a transit IP never lands on the broadcast
(which kube-ovn refuses to assign): 	base + S*i + 0        network
	base + S*i + 1        management VPC LR gateway  → GatewayIP
	base + S*i + 2 ..R+1  FRR pod transit IPs        → TransitIPPool[0..R-1]
	base + S*i + S-1      broadcast (always above the transit IPs) For R=1: S=4 → /30 (gw .1, transit .2, broadcast .3).
For R=2: S=8 → /29 (gw .1, transit .2/.3, broadcast .7).
For R=3–5: S=8 → /29.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| subnetName | SubnetName is the base name prefix for the operator-managed per-VPC transit Subnet CRs. Each VPC gets a Subnet named "<SubnetName>-<vpcName>". | string |  |
| cidr | CIDR is the address pool from which per-VPC /30 transit subnets are carved. Must not overlap kube-ovn's join subnet (100.64.0.0/16) or any provider VLAN range. | string |  |

[Back to Group](#v1alpha1)

### AZEdgeRouterRef

AZEdgeRouterRef references an AZEdgeRouter and one of the VPCs (VRFs) it serves.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| name | Name is the name of the AZEdgeRouter. | string |  |
| namespace | Namespace is the namespace of the AZEdgeRouter. | string |  |
| vpc | VPC is the kube-ovn VPC name (the VRF on the AZ router) this policy applies to. | string |  |

[Back to Group](#v1alpha1)

### ResolvedAZVPC

ResolvedAZVPC holds the resolved attachment state for a single VPC.
Populated by the operator; read by the frr-config-watcher sidecar
to configure per-VPC VRF devices and ip rules on the EdgeRouter pod.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| name | Name is the kube-ovn VPC name. | string |  |
| gatewayIP | GatewayIP is the management VPC logical router's IP on this VPC's dedicated /30 transit subnet (e.g. "172.31.128.1"). | string |  |
| transitIP | TransitIP is the IP/prefix allocated for replica 0 of this VPC's OVN Logical Router Port on its transit subnet (e.g. "172.31.128.2/30"). For single-replica deployments this is the only transit IP. | string |  |
| transitIPPool | TransitIPPool holds the bare transit IPs for all replicas (no prefix). When ReplicaCount > 1 there is one entry per replica, e.g. ["172.31.128.2", "172.31.128.3"] for two replicas. The kube-ovn ip_pool annotation is built from this list so each StatefulSet replica gets its own, stable transit IP. | string array |  |
| routingTable | RoutingTable is the Linux routing table ID assigned to this VPC's VRF. | integer |  |
| apiServerProxy | APIServerProxy reports that this VPC is allowed to reach the infra cluster's API server through the router's in-VPC apiserver proxy, resolved from the VPC's apiserver-proxy annotation. The sidecar reads it from here rather than from the VPC object, which it has no client for. | boolean |  |
| apiServerProxySubnets | APIServerProxySubnets narrows the source CIDRs allowed to use it. Empty means every subnet of this VPC. | string array |  |
| transitNICIndex | TransitNICIndex is the stable Multus NIC index (the N in "netN") for this VPC's transit NIC. Allocated once when the VPC is first resolved and preserved across reconciles, so onboarding/off-boarding another VPC never renumbers an already- attached VPC's NICs — required for dynamic-transit-NIC hot-plug (a running interface cannot be renumbered). 0 means not yet allocated. | integer |  |
| externalNICIndex | ExternalNICIndex is the stable Multus NIC index for this VPC's per-VRF external VLAN NIC ("bgp-per-vrf" transit mode only; 0 otherwise). Allocated once alongside TransitNICIndex from the same free pool so transit and external NICs never collide and never shift when the VPC set changes. AZExternalVLAN.InterfaceName is derived from it once the underlay VLAN is ready. | integer |  |
| vni | VNI is the VXLAN Network Identifier for this VPC's EVPN VRF. When non-zero, the AZ EdgeRouter configures EVPN Type 5 routes for this VPC. | integer |  |
| rd | RD overrides the auto-derived EVPN Route Distinguisher for this VPC's VRF. Set from a bound EVPNPolicy (see EVPNPolicyTarget.AZEdgeRouterRef); empty auto-derives "<ASN>:<VNI>". | string |  |
| importRTs | ImportRTs overrides the auto-derived import Route Targets for this VPC's VRF. Set from a bound EVPNPolicy; empty auto-derives the symmetric "<ASN>:<VNI>" target. Use this for cross-VRF route leaking / asymmetric import that the symmetric default cannot express. | string array |  |
| exportRTs | ExportRTs overrides the auto-derived export Route Targets for this VPC's VRF. Set from a bound EVPNPolicy; empty auto-derives the symmetric "<ASN>:<VNI>" target. | string array |  |
| subnets | Subnets is the list of CIDR blocks belonging to this VPC's wrapper Subnets. | string array |  |
| acceptPrefixes | AcceptPrefixes is the RESOLVED internal-speaker accept-list for this VPC, in precedence order: spec.internalPeers.perVPC[] override, else the VPC object's az-edge-router.virtualization.k8c.io/accept-prefixes annotation, else the AZ-wide spec.internalPeers.acceptPrefixes. Resolved here rather than in the FRR config builder because the builder is a pure function with no Kubernetes client and therefore cannot read a VPC annotation. This also makes status the single source of truth for what each VRF will accept, instead of two places re-deriving the same policy. An empty list means accept nothing from this VPC's speakers, matching the template's "deny any" branch. | string array |  |
| egressEnabled | EgressEnabled controls whether this VPC's traffic should be SNAT'd/masqueraded by the AZ EdgeRouter pod. Defaults to true when omitted. | boolean |  |
| egressToSource | EgressToSource specifies an optional static source IP to SNAT traffic from this VPC to. When empty, MASQUERADE is used on the transit interface. | string |  |
| egressToSourceBySubnet | EgressToSourceBySubnet is the resolved per-subnet override of EgressToSource, keyed by canonical IPv4 CIDR, one IP per replica. See AZVPCRef.EgressToSourceBySubnet for why this exists and why it is per-replica; this is simply that value copied onto status once resolved (spec/annotation precedence already applied), the same way EgressToSource itself is. | object (keys:string, values:string array) |  |
| externalVLAN | ExternalVLAN is the per-VRF underlay VLAN attachment allocated for this VPC in "bgp-per-vrf" OVN transit mode. Populated by the operator; read by the frr-config-watcher to enslave the interface to the VPC's VRF and by the config builder to peer the external router over it. | [AZExternalVLAN](#azexternalvlan) |  |
| externalVLANError | ExternalVLANError explains why this VPC has NO external VLAN attachment when its configuration asked for one — a malformed annotation, or a peer list that cannot be rendered. Recorded because the failure is otherwise invisible: the VPC is skipped so that one tenant's mistake cannot take down every other tenant's session, which means the only evidence was a line in the operator log. The symptom — a VPC that is attached and simply has no fabric session — looks identical to a fabric problem from the outside. Cleared as soon as the attachment resolves. | string |  |

[Back to Group](#v1alpha1)

### PeerResolvedAZVPCs

PeerResolvedAZVPCs groups the resolved VPCs from a single peer AZEdgeRouter.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| edgeRouterName | EdgeRouterName is the name of the peer AZEdgeRouter CR. | string |  |
| namespace | Namespace is the namespace of the peer AZEdgeRouter's transit NADs. | string |  |
| vpcs | VPCs is the list of resolved VPCs from the peer AZEdgeRouter. | [ResolvedAZVPC](#resolvedazvpc) array |  |

[Back to Group](#v1alpha1)

### LearnedBGPRoute

LearnedBGPRoute is a single (prefix, nexthop) pair learned from an internal BGP peer.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| cidr | CIDR is the destination IP prefix learned from the internal peer. | string |  |
| nextHopIP | NextHopIP is the IP address of the internal peer that advertised this prefix. | string |  |

[Back to Group](#v1alpha1)

### EdgeRouterImage

EdgeRouterImage holds the container image references shared by EdgeRouter
and AZEdgeRouter components.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| frr | FRR is the image for the FRouting container. | string |  |
| netshoot | Netshoot is the image for the netshoot debug container. | string |  |
| configWatcher | ConfigWatcher is the image for the frr-config-watcher sidecar container. Defaults to the operator image when empty. | string |  |

[Back to Group](#v1alpha1)

### EdgeRouterResources

EdgeRouterResources defines resource requirements for each EdgeRouter container.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| init | Init defines resource requirements for the init container. | [ResourceRequirements](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.37/#resourcerequirements-v1-core) |  |
| frr | FRR defines resource requirements for the FRouting container. | [ResourceRequirements](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.37/#resourcerequirements-v1-core) |  |
| netshoot | Netshoot defines resource requirements for the netshoot sidecar container. | [ResourceRequirements](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.37/#resourcerequirements-v1-core) |  |
| configWatcher | ConfigWatcher defines resource requirements for the config watcher sidecar container. | [ResourceRequirements](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.37/#resourcerequirements-v1-core) |  |

[Back to Group](#v1alpha1)
### AZEdgeRouterList

AZEdgeRouterList is the list type for AZEdgeRouter.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| metadata |  | [metav1.ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#listmeta-v1-meta) | false |
| items |  | [][AZEdgeRouter](#azedgerouter) | true |

[Back to Group](#v1alpha1)
### EVPNPeer

EVPNPeer describes a single BGP peer used exclusively for EVPN route exchange. Populated into an AZEdgeRouter's status by the EVPNRouteReflector controller.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| ip | IP is the IP address of the EVPN peer (RR replica NAD IP). | string |  |
| asn | ASN is the BGP Autonomous System Number of the EVPN peer. | integer |  |
| multihopTTL | MultihopTTL is the eBGP multihop TTL. Required when the peer is on a different VLAN reachable via L3 routing (typically 3). | integer |  |

[Back to Group](#v1alpha1)
### EVPNPolicy

EVPNPolicy is an admin-managed object that defines BGP EVPN Type 5 routing policy for one or more AZEdgeRouter VPCs (VRFs) — the VNI, Route Distinguisher, and import/export Route Targets that control cross-VPC reachability. The operator resolves the policy and writes the result into each target EdgeRouter's status (status.resolvedEVPNVRFs), where the frr-config-watcher sidecar reads it to generate per-VRF FRR configuration. Users deploying EdgeRouter objects do not need access to EVPNPolicy objects.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| metadata | Refer to Kubernetes API documentation for fields of `metadata`. | [ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.37/#objectmeta-v1-meta) |  |
| spec |  | [EVPNPolicySpec](#evpnpolicyspec) |  |
| status |  | [EVPNPolicyStatus](#evpnpolicystatus) |  |

[Back to Group](#v1alpha1)
### EVPNPolicyList

EVPNPolicyList contains a list of EVPNPolicy.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| metadata |  | [metav1.ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#listmeta-v1-meta) | false |
| items |  | [][EVPNPolicy](#evpnpolicy) | true |

[Back to Group](#v1alpha1)
### EVPNPolicySpec

EVPNPolicySpec defines the desired EVPN routing policy.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| vni | VNI is the VXLAN Network Identifier for this policy's VRF. | integer |  |
| rd | RD is the BGP Route Distinguisher (e.g. "65002:200"). | string |  |
| exportRTs | ExportRTs is the list of BGP Route Targets attached to prefixes advertised by this VRF. Peer VRFs that import a matching RT will install these routes. | string array |  |
| importRTs | ImportRTs is the list of BGP Route Targets this VRF accepts. Routes advertised with a matching export RT are installed into this VRF. | string array |  |
| targets | Targets lists the AZEdgeRouter VPCs (VRFs) this policy applies to. For each target the policy's RD/ImportRTs/ExportRTs override the AZ router's auto-derived symmetric "<ASN>:<VNI>" values on that VPC's EVPN VRF. | [EVPNPolicyTarget](#evpnpolicytarget) array |  |

[Back to Group](#v1alpha1)
### EVPNPolicyStatus

EVPNPolicyStatus reflects the observed state of the policy application.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| conditions | Conditions is the list of status conditions for this EVPNPolicy. | [Condition](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.37/#condition-v1-meta) array |  |

[Back to Group](#v1alpha1)
### EVPNPolicyTarget

EVPNPolicyTarget binds this policy to one VPC (VRF) served by an AZEdgeRouter.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| azEdgeRouterRef | AZEdgeRouterRef references the AZEdgeRouter and the VPC (VRF) this policy applies to. The policy's RD/ImportRTs/ExportRTs override the AZ router's auto-derived symmetric "<ASN>:<VNI>" values for that VPC's EVPN VRF (the VNI itself is taken from the VPC). | [AZEdgeRouterRef](#azedgerouterref) |  |

[Back to Group](#v1alpha1)
### EVPNRRImage

EVPNRRImage holds the container image references for the route reflector.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| frr | FRR is the image for the FRRouting container (e.g. quay.io/frrouting/frr:10.5.0). | string |  |
| configWatcher | ConfigWatcher is the image for the frr-config-watcher sidecar that detects ConfigMap changes and triggers in-place FRR reloads without pod restarts. (e.g. docker.io/soer3n/edge-router:v0.0.27-dev) | string |  |

[Back to Group](#v1alpha1)
### EVPNRRResources

EVPNRRResources defines resource requirements for the route reflector containers.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| frr | FRR defines resource requirements for the FRouting container. | [ResourceRequirements](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.37/#resourcerequirements-v1-core) |  |
| configWatcher | ConfigWatcher defines resource requirements for the config watcher sidecar container. | [ResourceRequirements](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.37/#resourcerequirements-v1-core) |  |

[Back to Group](#v1alpha1)
### EVPNRouteReflector

EVPNRouteReflector is an admin-managed object that deploys a dedicated FRR BGP route reflector for EVPN Type 5 routes. It discovers EdgeRouter objects matching the selector, establishes eBGP sessions with them using the l2vpn evpn address family only, and reflects EVPN routes between them with next-hop unchanged so that VXLAN data-plane traffic flows directly between edge router VTEPs. Each replica is assigned a pre-defined IP from spec.ips (by StatefulSet ordinal) on the dedicated NAD. The controller writes the RR peer info into each targeted EdgeRouter's status.resolvedEVPNPeers so the frr-config-watcher sidecar adds the RR as an EVPN-only neighbor without requiring any manual EdgeRouter configuration.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| metadata | Refer to Kubernetes API documentation for fields of `metadata`. | [ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.37/#objectmeta-v1-meta) |  |
| spec |  | [EVPNRouteReflectorSpec](#evpnroutereflectorspec) |  |
| status |  | [EVPNRouteReflectorStatus](#evpnroutereflectorstatus) |  |

[Back to Group](#v1alpha1)
### EVPNRouteReflectorList

EVPNRouteReflectorList contains a list of EVPNRouteReflector.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| metadata |  | [metav1.ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#listmeta-v1-meta) | false |
| items |  | [][EVPNRouteReflector](#evpnroutereflector) | true |

[Back to Group](#v1alpha1)
### EVPNRouteReflectorSpec

EVPNRouteReflectorSpec defines the desired state of the route reflector.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| asn | ASN is the BGP Autonomous System Number for this route reflector. | integer |  |
| replicaCount | ReplicaCount is the number of RR pod replicas. Must equal len(IPs). | integer |  |
| ips | IPs is the list of pre-defined IPs for the RR pods, one per replica by StatefulSet ordinal. These IPs are assigned on the NAD interface and are used as BGP router-IDs. len(IPs) must equal ReplicaCount. | string array |  |
| subnet | Subnet is the name of the OVN Subnet the RR pods attach to on their primary (eth0) interface, via the ovn.kubernetes.io/logical_switch annotation. This may be a plain overlay subnet — e.g. a subnet of a management VPC — in which case no dedicated VLAN/NAD is needed: the RR peers edge routers over the overlay and only reflects EVPN control-plane routes (VXLAN dataplane flows directly between edge router VTEPs, never through the RR). The pod IPs come from spec.ips via ip_pool. | string |  |
| nad | NAD is a legacy reference to a dedicated VLAN NetworkAttachmentDefinition. It is no longer consumed — the RR attaches to Subnet on eth0 — and is retained only for backward compatibility. Leave unset for overlay-attached route reflectors. | [NADRef](#nadref) |  |
| gateway | Gateway is a legacy default-gateway IP on the (VLAN) NAD subnet. No longer consumed; retained for backward compatibility. Leave unset for overlay RRs. | string |  |
| multihopTTL | MultihopTTL is the eBGP multihop TTL for sessions to edge routers and for the dynamic (listen-range) peer-group. Required when peers are on a different subnet reachable via L3 routing (typically 3). | integer |  |
| image | Image holds the container image references for the RR pod. | [EVPNRRImage](#evpnrrimage) |  |
| azEdgeRouterSelector | AZEdgeRouterSelector selects AZEdgeRouter objects to relay EVPN Type 5 routes for. Because AZ router pod IPs are IPAM-assigned (not static), they are peered dynamically via bgp listen ranges (see PeerListenRanges) rather than as explicit neighbors; the controller injects the RR IPs into each matching AZEdgeRouter's status.resolvedEVPNPeers so its sidecar adds the RR as an EVPN neighbor. A nil selector selects none (opt-in); an empty selector matches all AZEdgeRouters. | [LabelSelector](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.37/#labelselector-v1-meta) |  |
| peerListenRanges | PeerListenRanges is the list of CIDRs from which the RR accepts dynamic EVPN sessions via `bgp listen range`, i.e. the overlay/management subnets the selected AZEdgeRouters peer from. Required to relay AZ routers (their IPs are dynamic). | string array |  |
| nodeSelector | NodeSelector constrains the route reflector pods to nodes matching these labels. Use this to ensure the RR pods are scheduled on nodes that have the required ProviderNetwork interfaces (VLANs / bridges). | object (keys:string, values:string) |  |
| imagePullSecrets | ImagePullSecrets is a list of references to secrets used for pulling images. | [LocalObjectReference](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.37/#localobjectreference-v1-core) array |  |
| resources | Resources defines the resource requirements for each container in the RR pod. | [EVPNRRResources](#evpnrrresources) |  |

[Back to Group](#v1alpha1)
### EVPNRouteReflectorStatus

EVPNRouteReflectorStatus reflects the observed state of the route reflector.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| readyReplicas | ReadyReplicas is the number of ready RR pod replicas. | integer |  |
| conditions | Conditions is the list of status conditions for this EVPNRouteReflector. | [Condition](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.37/#condition-v1-meta) array |  |

[Back to Group](#v1alpha1)
