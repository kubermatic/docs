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
