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
* [BackupObject](#backupobject)
* [BackupStorageLocation](#backupstoragelocation)
* [BackupStorageLocationList](#backupstoragelocationlist)
* [BackupStorageLocationSpec](#backupstoragelocationspec)
* [BackupStorageLocationStatus](#backupstoragelocationstatus)
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
* [VMBackup](#vmbackup)
* [VMBackupList](#vmbackuplist)
* [VMBackupSpec](#vmbackupspec)
* [VMBackupStatus](#vmbackupstatus)
* [VMRestore](#vmrestore)
* [VMRestoreList](#vmrestorelist)
* [VMRestoreSpec](#vmrestorespec)
* [VMRestoreStatus](#vmrestorestatus)
* [VPC](#vpc)
* [VPCBFDPort](#vpcbfdport)
* [VPCBFDPortStatus](#vpcbfdportstatus)
* [VPCList](#vpclist)
* [VPCPeering](#vpcpeering)
* [VPCPolicyRoute](#vpcpolicyroute)
* [VPCSpec](#vpcspec)
* [VPCStaticRoute](#vpcstaticroute)
* [VPCStatus](#vpcstatus)
* [AZEdgeRouter](#azedgerouter)
* [AZEdgeRouterSpec](#azedgerouterspec)
* [AZEdgeRouterStatus](#azedgerouterstatus)
* [AZVPCsSpec](#azvpcsspec)
* [AZVPCRef](#azvpcref)
* [AZVPCVLANRef](#azvpcvlanref)
* [AZVPCFabricPeer](#azvpcfabricpeer)
* [EffectiveFabricPeer](#effectivefabricpeer)
* [FabricPeerDefaults](#fabricpeerdefaults)
* [ConfigWatcherSpec](#configwatcherspec)
* [AZVPCEdgeRouterRef](#azvpcedgerouterref)
* [AZAcceptPrefix](#azacceptprefix)
* [AZBGPPeer](#azbgppeer)
* [AZEVPNPeer](#azevpnpeer)
* [AZExternalVLAN](#azexternalvlan)
* [AZInternalPeersSpec](#azinternalpeersspec)
* [AZInternalPeersVPCOverride](#azinternalpeersvpcoverride)
* [AZPerVRFTransitSpec](#azpervrftransitspec)
* [AZResolvedFabricPeer](#azresolvedfabricpeer)
* [AZTransitSubnetSpec](#aztransitsubnetspec)
* [AZEdgeRouterRef](#azedgerouterref)
* [ResolvedAZVPC](#resolvedazvpc)
* [PeerResolvedAZVPCs](#peerresolvedazvpcs)
* [LearnedBGPRoute](#learnedbgproute)
* [NADRef](#nadref)
* [EdgeRouterImage](#edgerouterimage)
* [EdgeRouterResources](#edgerouterresources)
* [NetshootSpec](#netshootspec)
* [BFDSessionStatus](#bfdsessionstatus)
* [BFDSideSpec](#bfdsidespec)
* [BFDSpec](#bfdspec)
* [BGPSessionStatus](#bgpsessionstatus)
* [AZEdgeRouterList](#azedgerouterlist)
* [EVPNPeer](#evpnpeer)
* [ExternalNeighbor](#externalneighbor)
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

### KubeVRole

KubeVRole defines what operations a subject may perform.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| metadata | Refer to Kubernetes API documentation for fields of `metadata`. | [ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.37/#objectmeta-v1-meta) | false |
| spec |  | [KubeVRoleSpec](#kubevrolespec) | true |

[Back to Group](#v1alpha1)

### KubeVRoleBinding

KubeVRoleBinding grants a KubeVRole to a user.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| metadata | Refer to Kubernetes API documentation for fields of `metadata`. | [ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.37/#objectmeta-v1-meta) | false |
| spec |  | [KubeVRoleBindingSpec](#kubevrolebindingspec) | true |

[Back to Group](#v1alpha1)

### KubeVRoleBindingList

KubeVRoleBindingList is the list type for KubeVRoleBinding.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| metadata | Refer to Kubernetes API documentation for fields of `metadata`. | [ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.37/#listmeta-v1-meta) | false |
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
| metadata | Refer to Kubernetes API documentation for fields of `metadata`. | [ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.37/#listmeta-v1-meta) | false |
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
| metadata | Refer to Kubernetes API documentation for fields of `metadata`. | [ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.37/#objectmeta-v1-meta) | false |
| spec |  | [UserSpec](#userspec) | false |
| status |  | [UserStatus](#userstatus) | false |

[Back to Group](#v1alpha1)

### UserList

UserList is the list type for User.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| metadata | Refer to Kubernetes API documentation for fields of `metadata`. | [ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.37/#listmeta-v1-meta) | false |
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
| metadata | Refer to Kubernetes API documentation for fields of `metadata`. | [ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.37/#objectmeta-v1-meta) | false |
| spec |  | [ImageSpec](#imagespec) | false |

[Back to Group](#v1alpha1)

### ImageList

ImageList is the list type for Image.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| metadata | Refer to Kubernetes API documentation for fields of `metadata`. | [ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.37/#listmeta-v1-meta) | false |
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
| metadata | Refer to Kubernetes API documentation for fields of `metadata`. | [ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.37/#objectmeta-v1-meta) | false |
| spec |  | [SSHKeySpec](#sshkeyspec) | false |
| status |  | [SSHKeyStatus](#sshkeystatus) | false |

[Back to Group](#v1alpha1)

### SSHKeyList

SSHKeyList is the list type for SSHKey.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| metadata | Refer to Kubernetes API documentation for fields of `metadata`. | [ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.37/#listmeta-v1-meta) | false |
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

### BackupObject

BackupObject records a single disk image uploaded to the storage location.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| volumeName | VolumeName is the VirtualMachine volume this object was captured from. | string | true |
| dataVolumeName | DataVolumeName is the original CDI DataVolume name backing the volume. | string | false |
| objectKey | ObjectKey is the key of the uploaded image within the bucket. | string | true |
| sizeBytes | SizeBytes is the size of the uploaded image in bytes. | integer | false |
| format | Format is the image format that was uploaded, e.g. "gzip". | string | false |

[Back to Group](#v1alpha1)

### BackupStorageLocation

BackupStorageLocation is the namespace-scoped configuration for an S3-compatible
object storage target that VM backups are written to. An administrator creates
one or more locations per namespace; the dashboard lists them so a user can pick
a destination when creating a backup.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| metadata | Refer to Kubernetes API documentation for fields of `metadata`. | [ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.37/#objectmeta-v1-meta) | false |
| spec |  | [BackupStorageLocationSpec](#backupstoragelocationspec) | false |
| status |  | [BackupStorageLocationStatus](#backupstoragelocationstatus) | false |

[Back to Group](#v1alpha1)

### BackupStorageLocationList

BackupStorageLocationList is the list type for BackupStorageLocation.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| metadata | Refer to Kubernetes API documentation for fields of `metadata`. | [ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.37/#listmeta-v1-meta) | false |
| items |  | [BackupStorageLocation](#backupstoragelocation) array | true |

[Back to Group](#v1alpha1)

### BackupStorageLocationSpec

BackupStorageLocationSpec defines an object storage destination for backups.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| provider | Provider is the object storage backend. Only "s3" (S3-compatible) is supported. | string | true |
| bucket | Bucket is the name of the bucket that backup objects are written to. | string | true |
| endpoint | Endpoint is the S3 endpoint URL for non-AWS backends (e.g. MinIO or Ceph RGW), such as "https://minio.example.com:9000". Leave empty for AWS S3. | string | false |
| region | Region is the S3 region. Optional for endpoints that do not require it. | string | false |
| prefix | Prefix is an optional object key prefix applied to every backup written to this location, allowing several locations to share one bucket. | string | false |
| credentialsSecretRef | CredentialsSecretRef is the name of a Secret in the same namespace holding the S3 credentials. The Secret must use the keys "accessKeyId" and "secretKey" so it can be consumed directly by CDI on restore. | string | true |
| caBundleConfigMapRef | CABundleConfigMapRef is the name of a ConfigMap in the same namespace whose data provides a custom CA bundle for verifying the endpoint's TLS certificate. | string | false |
| insecureSkipTLSVerify | InsecureSkipTLSVerify disables TLS certificate verification for the endpoint. Intended for development backends with self-signed certificates. It applies only to the backup upload path; CDI cannot skip verification on restore, so a TLS endpoint that relies on this flag must also set CABundleConfigMapRef to be restorable. | boolean | false |

[Back to Group](#v1alpha1)

### BackupStorageLocationStatus

BackupStorageLocationStatus is the observed state of a BackupStorageLocation.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| phase | Phase is the current lifecycle phase of this location. It reaches Ready once the referenced credentials Secret exists with the required keys. This does not probe the endpoint; actual bucket reachability surfaces when a backup's upload Job runs. | Phase | false |
| message | Message is a human-readable explanation of the current phase, typically the reason a validation check failed. | string | false |
| lastValidated | LastValidated is the time the location was last successfully validated. | metav1.Time | false |

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
| metadata | Refer to Kubernetes API documentation for fields of `metadata`. | [ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.37/#objectmeta-v1-meta) | false |
| spec |  | [ElasticIPSpec](#elasticipspec) | false |
| status |  | [ElasticIPStatus](#elasticipstatus) | false |

[Back to Group](#v1alpha1)

### ElasticIPList

ElasticIPList is the list type for ElasticIP.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| metadata | Refer to Kubernetes API documentation for fields of `metadata`. | [ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.37/#listmeta-v1-meta) | false |
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
| metadata | Refer to Kubernetes API documentation for fields of `metadata`. | [ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.37/#objectmeta-v1-meta) | false |
| spec |  | [NATGatewaySpec](#natgatewayspec) | false |
| status |  | [NATGatewayStatus](#natgatewaystatus) | false |

[Back to Group](#v1alpha1)

### NATGatewayList

NATGatewayList is the list type for NATGateway.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| metadata | Refer to Kubernetes API documentation for fields of `metadata`. | [ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.37/#listmeta-v1-meta) | false |
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
| metadata | Refer to Kubernetes API documentation for fields of `metadata`. | [ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.37/#objectmeta-v1-meta) | false |
| spec |  | [SecurityGroupSpec](#securitygroupspec) | false |
| status |  | [SecurityGroupStatus](#securitygroupstatus) | false |

[Back to Group](#v1alpha1)

### SecurityGroupList

SecurityGroupList is the list type for SecurityGroup.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| metadata | Refer to Kubernetes API documentation for fields of `metadata`. | [ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.37/#listmeta-v1-meta) | false |
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
| metadata | Refer to Kubernetes API documentation for fields of `metadata`. | [ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.37/#objectmeta-v1-meta) | false |
| spec |  | [SubnetSpec](#subnetspec) | false |
| status |  | [SubnetStatus](#subnetstatus) | false |

[Back to Group](#v1alpha1)

### SubnetList

SubnetList is the list type for Subnet.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| metadata | Refer to Kubernetes API documentation for fields of `metadata`. | [ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.37/#listmeta-v1-meta) | false |
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
| metadata | Refer to Kubernetes API documentation for fields of `metadata`. | [ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.37/#objectmeta-v1-meta) | false |
| spec |  | [UnderlaySubnetSpec](#underlaysubnetspec) | false |
| status |  | [UnderlaySubnetStatus](#underlaysubnetstatus) | false |

[Back to Group](#v1alpha1)

### UnderlaySubnetList

UnderlaySubnetList is the list type for UnderlaySubnet.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| metadata | Refer to Kubernetes API documentation for fields of `metadata`. | [ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.37/#listmeta-v1-meta) | false |
| items |  | [][UnderlaySubnet](#underlaysubnet) | true |

[Back to Group](#v1alpha1)

### UnderlaySubnetSpec

UnderlaySubnetSpec defines the desired state of an UnderlaySubnet wrapper.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| defaultInterface | DefaultInterface is the physical NIC name (e.g. \"eth1\") that the ProviderNetwork attaches to on every selected node. It must be a valid Linux network interface name, which the kernel caps at 15 bytes. | string | true |
| nodeSelector | NodeSelector restricts the ProviderNetwork to a subset of nodes via label selection. When empty, the ProviderNetwork applies to all nodes. | *[metav1.LabelSelector](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.37/#labelselector-v1-meta) | false |
| customInterfaces | CustomInterfaces overrides DefaultInterface on specific nodes. | [][UnderlayCustomInterface](#underlaycustominterface) | false |
| vlanID | VlanID is the 802.1Q tag applied to traffic on this underlay. | int | true |
| cidrBlock | CIDRBlock is the IP address range allocated from this underlay subnet. | string | true |
| gateway | Gateway is the gateway IP address for this subnet. | string | false |
| gatewayNode | GatewayNode is the comma-separated list of node names that host the centralized gateway for this subnet. | string | false |
| protocol | Protocol is the IP protocol family: IPv4, IPv6, or Dual. | string | false |
| excludeIPs | ExcludeIPs is a list of IP addresses or ranges to exclude from allocation. | []string | false |
| namespaces | Namespaces binds this subnet as the DEFAULT (primary) subnet for the listed namespaces — pods there with no explicit network selection get their primary IP from it. Leave empty for a secondary/underlay network attached only via its NAD + ip_pool annotation: binding a namespace already owned by another VPC's subnet makes kube-ovn reject the subnet ("namespaces … overlap with vpc …") and never create its logical switch. | string array | false |

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

### VMBackup

VMBackup is the namespace-scoped wrapper that captures a point-in-time backup of
a VirtualMachine and uploads its disk images to a BackupStorageLocation. The
reconciler drives a VirtualMachineSnapshot, a VirtualMachineExport, and an upload
Job, then records where each disk landed in the bucket.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| metadata | Refer to Kubernetes API documentation for fields of `metadata`. | [ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.37/#objectmeta-v1-meta) | false |
| spec |  | [VMBackupSpec](#vmbackupspec) | false |
| status |  | [VMBackupStatus](#vmbackupstatus) | false |

[Back to Group](#v1alpha1)

### VMBackupList

VMBackupList is the list type for VMBackup.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| metadata | Refer to Kubernetes API documentation for fields of `metadata`. | [ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.37/#listmeta-v1-meta) | false |
| items |  | [VMBackup](#vmbackup) array | true |

[Back to Group](#v1alpha1)

### VMBackupSpec

VMBackupSpec defines the desired backup of a VirtualMachine.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| vmName | VMName is the name of the VirtualMachine to back up, in the same namespace. | string | true |
| storageLocation | StorageLocation is the name of the BackupStorageLocation in the same namespace that this backup is written to. | string | true |

[Back to Group](#v1alpha1)

### VMBackupStatus

VMBackupStatus is the observed state of a VMBackup.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| phase | Phase is the current lifecycle phase of this backup. | Phase | false |
| startTime | StartTime is when the backup began. | metav1.Time | false |
| completionTime | CompletionTime is when the backup finished successfully. | metav1.Time | false |
| snapshotName | SnapshotName is the name of the VirtualMachineSnapshot created for this backup. | string | false |
| exportName | ExportName is the name of the VirtualMachineExport created for this backup. | string | false |
| objects | Objects lists the disk images that were uploaded to the storage location. | [BackupObject](#backupobject) array | false |
| vmManifestKey | VMManifestKey is the object key of the VM manifest snapshot retained in object storage as an out-of-band disaster-recovery artifact. Restore rebuilds the VM from the in-cluster manifest ConfigMap, not from this object. | string | false |
| message | Message is a human-readable explanation of the current phase, typically the reason the backup failed. | string | false |

[Back to Group](#v1alpha1)

### VMRestore

VMRestore is the namespace-scoped wrapper that restores a VMBackup into a new
VirtualMachine. The reconciler imports each backed-up disk image from the storage
location into a CDI DataVolume (via source.s3) and recreates the VirtualMachine
from the stored manifest under a new name. The original VM is never modified.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| metadata | Refer to Kubernetes API documentation for fields of `metadata`. | [ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.37/#objectmeta-v1-meta) | false |
| spec |  | [VMRestoreSpec](#vmrestorespec) | false |
| status |  | [VMRestoreStatus](#vmrestorestatus) | false |

[Back to Group](#v1alpha1)

### VMRestoreList

VMRestoreList is the list type for VMRestore.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| metadata | Refer to Kubernetes API documentation for fields of `metadata`. | [ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.37/#listmeta-v1-meta) | false |
| items |  | [VMRestore](#vmrestore) array | true |

[Back to Group](#v1alpha1)

### VMRestoreSpec

VMRestoreSpec defines the desired restore of a VMBackup.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| backupName | BackupName is the name of the VMBackup in the same namespace to restore from. | string | true |
| targetVMName | TargetVMName is the name of the new VirtualMachine to create. It must differ from any existing VirtualMachine in the namespace. | string | true |
| storageClassName | StorageClassName is the storage class for the restored DataVolumes. When empty, the cluster default storage class is used. | string | false |

[Back to Group](#v1alpha1)

### VMRestoreStatus

VMRestoreStatus is the observed state of a VMRestore.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| phase | Phase is the current lifecycle phase of this restore. | Phase | false |
| startTime | StartTime is when the restore began. | metav1.Time | false |
| completionTime | CompletionTime is when the restore finished successfully. | metav1.Time | false |
| dataVolumes | DataVolumes lists the names of the CDI DataVolumes created for this restore. | string array | false |
| restoredVMName | RestoredVMName is the name of the VirtualMachine that was created. | string | false |
| vmManifest | VMManifest is set for a restore synced from a KDP workspace only: the restored VirtualMachine as JSON, to be created in that workspace. A VM created on the host would never reach the workspace, so the restore waits for this one to be synced down instead. It is cleared once the VM exists. | string | false |
| vmManifestPublishedTime | VMManifestPublishedTime is when VMManifest was published. The restore fails if its VirtualMachine is not created within a day of it. | metav1.Time | false |
| message | Message is a human-readable explanation of the current phase, typically the reason the restore failed. | string | false |

[Back to Group](#v1alpha1)

### VPC

VPC is the namespace-scoped wrapper for a Kube-OVN Vpc resource.
Users create VPCs inside workspace namespaces; the operator reconciles them
into cluster-scoped Kube-OVN Vpc objects, prefixing their names with the
workspace namespace to prevent cross-tenant collisions.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| metadata | Refer to Kubernetes API documentation for fields of `metadata`. | [ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.37/#objectmeta-v1-meta) | false |
| spec |  | [VPCSpec](#vpcspec) | false |
| status |  | [VPCStatus](#vpcstatus) | false |

[Back to Group](#v1alpha1)

### VPCBFDPort

VPCBFDPort holds optional BFD logical router port configuration.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| enabled | Enabled activates the BFD port. | bool | true |
| ip | IP is the IP address assigned to the BFD port. | string | false |
| nodeSelector | NodeSelector restricts which nodes the BFD LRP is hosted on. If not set, Kube-OVN selects up to 3 nodes automatically. | *[metav1.LabelSelector](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.37/#labelselector-v1-meta) | false |

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
| metadata | Refer to Kubernetes API documentation for fields of `metadata`. | [ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.37/#listmeta-v1-meta) | false |
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
| vlan | VLAN is a reference to the pre-existing NetworkAttachmentDefinition for the router's inbound VLAN interface (net1). The router pods attach to it as a Multus secondary interface, giving them L2 reachability to the physical network. It carries EVPN peering and the plain BGP sessions in `bgpPeers`. In `bgp-per-vrf` mode, tenant traffic uses the per-VPC VLANs in `perVRFTransit` instead, and this field is only needed for a router-wide service VLAN. | [NADRef](#nadref) |  |
| vlanGateway | VLANGateway is the default gateway IP on the VLAN NAD subnet. The operator sets the Multus routes annotation to route 0.0.0.0/0 via this address, making the VLAN interface the pod's default route (same mechanism as the per-VPC EdgeRouter's external NAD). Only meaningful when VLAN is set. | string |  |
| serviceVlan | ServiceVLAN is a reference to a separate pre-existing NetworkAttachmentDefinition for the service-advertisement (anycast) VLAN, distinct from `vlan`. When it differs from `vlan`, the router attaches it as a second inbound VLAN interface (net2) and pins the `bgpPeers` session to it, so region transit and service advertisement use different VLANs. When empty or equal to `vlan`, both share net1. Requires `vlan` and `bgpPeers`. | [NADRef](#nadref) |  |
| serviceVlanGateway | ServiceVLANGateway is the gateway IP on the ServiceVLAN subnet used to reach off-subnet anycast BGP peers (BGPPeers). When set, the operator installs a /32 static route to each anycast peer via this gateway over the service VLAN NIC. Leave empty when the anycast peers are directly connected on the ServiceVLAN subnet (the common case), in which case the connected route suffices. This is NOT a default route — the pod default route stays on the region-transit VLAN. Only meaningful when ServiceVLAN differs from VLAN. | string |  |
| apiServerViaInternalProxy | APIServerViaInternalProxy makes the router pods reach the Kubernetes API server through an in-VPC API server proxy instead of a node IP. Set it when the router pods live in a management VPC that has no L2 path to the node or API server address, which is the usual case for AZ routers. The proxy must be deployed separately. | boolean |  |
| dynamicTransitNICs | DynamicTransitNICs attaches the per-VPC transit NICs to the running router pods by Multus hot-plug instead of adding them to the StatefulSet pod template. Adding or removing a VPC then does not restart the router pods, so BGP and BFD sessions of VPCs that are already attached stay up. Requires thick-mode Multus with the multus-dynamic-networks-controller. Defaults to false, which attaches the NICs through the pod template. | boolean |  |
| configWatcher | ConfigWatcher configures the configuration watcher sidecar. It is enabled by default. Do not disable it: without it the router never re-renders its FRR configuration as VPCs resolve and never applies its nftables rules, and sessions stay stuck in Connect. | [ConfigWatcherSpec](#configwatcherspec) |  |
| bfd | BFD configures Bidirectional Forwarding Detection. When BFD.Internal.Enabled is set, the operator enables a BFD logical-router port on each tenant VPC and creates BFD sessions to every replica's transit IP, so OVN-monitored ECMP reroute policies automatically prune a dead replica's transit IP. The FRR pods run bfdd and answer the OVN gateway's BFD probes per VPC VRF. | [BFDSpec](#bfdspec) |  |
| netshoot | Netshoot configures the netshoot debug sidecar. | [NetshootSpec](#netshootspec) |  |
| resources | Resources defines the resource requirements for each container. | [EdgeRouterResources](#edgerouterresources) |  |
| nodeSelector | NodeSelector constrains the FRR pods to nodes matching these labels. | object (keys:string, values:string) |  |
| allowColocatedReplicas | AllowColocatedReplicas lets more than one replica run on the same node. By default the router pods require anti-affinity on `kubernetes.io/hostname`, so the replica count cannot exceed the number of nodes matching `nodeSelector`. Setting this relaxes the rule to a preference, which is only useful for test setups with few nodes, because replicas on one node fail together. When replicas share a node, the `ReplicaRedundancy` condition turns False and draining that node is blocked by the PodDisruptionBudget. | boolean |  |
| zone | Zone names the availability zone this router serves, for example `region-a`. Set it when several AZEdgeRouters share the same tenant VPCs, one per zone. The per-VPC annotations are then keyed by it: `az-edge-router.virtualization.k8c.io/<zone>.nad-name`, `.local-ips`, `.peer-ip` and `.accept-prefixes`. Use the same value as the `topology.kubernetes.io/region` node label and the subnets' `topology.kubernetes.io/zone` label. Leave it empty for a single-zone installation, which uses the unsuffixed annotations. A router without a zone skips VPCs that carry zone-scoped annotations. | string |  |
| imagePullSecrets | ImagePullSecrets is a list of references to secrets for pulling images. | [LocalObjectReference](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.37/#localobjectreference-v1-core) array |  |
| transitSubnet | TransitSubnet configures the per-VPC /30 transit address pool. | [AZTransitSubnetSpec](#aztransitsubnetspec) |  |
| vpcs | VPCs configures how VPCs are discovered and attached. | [AZVPCsSpec](#azvpcsspec) |  |
| peerAZEdgeRouters | PeerAZEdgeRouters lists other AZEdgeRouter CRs (same namespace) whose resolved VPCs should also get transit NICs on this router's FRR pods. | string array |  |
| vpcEdgeRouters | VPCEdgeRouters lists per-VPC EdgeRouter objects that this AZ router should peer with. Not used yet. | [AZVPCEdgeRouterRef](#azvpcedgerouterref) array |  |
| asn | ASN is the BGP autonomous system number. Required when EVPNPeers, BGPPeers or InternalPeers are configured. EVPNPeers and BGPPeers may be used together: EVPNPeers carries EVPN Type 5 cross-zone routing while BGPPeers carries plain IPv4 unicast advertisement (aggregated anycast and/or OVN subnets) to an external router. | integer |  |
| evpnPeers | EVPNPeers lists the BGP peers for EVPN Type 5 route exchange. These are typically other AZEdgeRouter instances in remote regions/AZs. | [AZEVPNPeer](#azevpnpeer) array |  |
| evpnUnderlayPrefixes | EVPNUnderlayPrefixes is the list of CIDR blocks covering the VTEP underlay addresses of all AZ edge routers. When non-empty, static routes for these prefixes are installed via the VLAN gateway so that EVPN VTEP resolution works without relying on the default route. | string array |  |
| bgpPeers | BGPPeers lists the external upstream BGP peers reached over the VLAN (net1) for plain IPv4 unicast advertisement. They carry the anycast blocks learned from `internalPeers`, re-advertised with next-hop-self, and the OVN subnets when `ovnTransitMode` is `bgp-per-vrf`. May be used together with `evpnPeers`. | [AZBGPPeer](#azbgppeer) array |  |
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
| bgpSessions | BGPSessions lists the live BGP neighbours of every replica, published by the frr-config-watcher sidecars. Sorted by replica, VRF, neighbour and address family so an unchanged set never rewrites the status. | [BGPSessionStatus](#bgpsessionstatus) array |  |
| resolvedEVPNPeers | ResolvedEVPNPeers is populated by the EVPNRouteReflector controller with the RR replica IPs (as EVPN-only neighbors). The frr-config-watcher sidecar merges these with spec.EVPNPeers so the AZ router peers an in-cluster, operator-managed route reflector without any static peer configuration. Mirrors EdgeRouter. | [EVPNPeer](#evpnpeer) array |  |

[Back to Group](#v1alpha1)

### AZVPCsSpec

AZVPCsSpec configures how VPCs are discovered and attached in AZ mode.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| autoDiscovery | AutoDiscovery enables automatic discovery of kube-ovn VPC objects via LabelSelector. When false, VPCs must be listed explicitly in List. | boolean |  |
| labelSelector | LabelSelector selects kube-ovn VPC objects to attach to this AZEdgeRouter. Only used when AutoDiscovery is true. | [LabelSelector](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.37/#labelselector-v1-meta) |  |
| namespaces | Namespaces bounds which namespaces auto-discovery looks in for wrapper VPCs, which are namespaced. Empty means only the router's own namespace. `*` means every namespace, so one platform router can carry the VPCs of every tenant. A VPC is attached only if its namespace is allowed and it carries the labels in `labelSelector`; an empty `labelSelector` matches every VPC, so set one to discover VPCs in other namespaces. Entries in `list` name their namespace themselves and are not bounded by this field, but a listed VPC of another namespace is attached only if its owner labelled it `virtualization.k8c.io/edge-router-attach=true`. The per-VPC routing annotations and labels (NAD, peers, ASNs, accepted prefixes, API server proxy, egress source, EVPN VNI) are not read from a VPC of another namespace, so set them in this spec; only the egress-enabled annotation is honoured. On this router, a VPC of another namespace is identified as `<name>--<digest of the namespace>`, while a VPC of the router's own namespace keeps its plain name. Ignored for native kube-ovn VPCs, which are cluster-scoped. | string array |  |
| subnetLabelSelector | SubnetLabelSelector filters which wrapper Subnet objects within each discovered/listed VPC are advertised by this AZEdgeRouter instance. This allows multiple AZEdgeRouters (one per region/zone) to share the same VPCs while each only handling the subnets pinned to its own zone. When empty, all subnets belonging to the VPC are included. | [LabelSelector](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.37/#labelselector-v1-meta) |  |
| list | List is the explicit set of VPCs to attach when `autoDiscovery` is false. Use `namespace` on an entry for a VPC outside the router's namespace. | [AZVPCRef](#azvpcref) array |  |

[Back to Group](#v1alpha1)

### AZVPCRef

AZVPCRef identifies a kube-ovn VPC to attach to the AZEdgeRouter.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| name | Name is the name of the kube-ovn VPC object. | string |  |
| namespace | Namespace is the namespace of the VPC, for wrapper VPCs outside the router's own namespace. Empty means the router's own namespace. Ignored for native kube-ovn VPCs, which are cluster-scoped. | string |  |
| egressToSource | EgressToSource is an optional fixed source IP for SNAT of traffic from this VPC, instead of masquerade. The same address is used on every replica, so with `replicaCount` greater than 1 a reply may arrive at a replica that does not own it. Prefer `egressToSourceBySubnet`, which takes one IP per replica, when you run more than one replica. | string |  |
| egressToSourceBySubnet | EgressToSourceBySubnet overrides `egressToSource` for specific subnets of this VPC, keyed by IPv4 CIDR in canonical form (for example `10.0.0.0/24`, not `10.0.0.5/24`). Subnets not listed fall back to `egressToSource`, or to plain masquerade if that is unset. Use it when a subnet must present a distinct, stable external source IP. Each value lists one IP per replica, because return traffic may reach a different replica than the one that sent the request. A list shorter than `spec.replicaCount` is rejected and the override does not apply. Every IP used here must also be added to `spec.excludeIps` of the Subnet it is drawn from, otherwise that Subnet may assign it to another NIC. The operator does not do this for you. | object (keys:string, values:string array) |  |

[Back to Group](#v1alpha1)

### AZVPCVLANRef

AZVPCVLANRef maps one VPC to its pre-provisioned external underlay VLAN. The VLAN
is referenced either as an UnderlaySubnet (the operator/platform provisions the
ProviderNetwork+Vlan+Subnet+NAD) or, for a VLAN whose NAD already exists (e.g. a
shared fabric NAD created directly), by NAD name. The two sources are mutually
exclusive, and both are optional: naming neither is a policy-only override (for example
`advertiseOVNSubnets` for a VPC whose VLAN comes from its `az-edge-router.virtualization.k8c.io`
annotations). Naming both is rejected.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| vpc | VPC is the kube-ovn VPC name; must match a VPC this router resolves. A VPC of another namespace is written `<namespace>/<name>`; a bare name means the router's own namespace. | string |  |
| underlaySubnet | UnderlaySubnet is the name of the pre-provisioned UnderlaySubnet (bundling the ProviderNetwork, the 802.1Q Vlan and the IP Subnet) that carries this VPC's external VLAN. The operator attaches its auto-created NAD and enslaves the interface to the VPC's VRF. Mutually exclusive with NADName. | string |  |
| nadName | NADName references a PRE-EXISTING NetworkAttachmentDefinition (in the router's namespace) backing this VPC's external VLAN, as an alternative to UnderlaySubnet. Use this to attach to a NAD provisioned outside the AZ operator — e.g. a shared fabric NAD also used by a per-VPC EdgeRouter. The provider is derived as "<NADName>.<namespace>.ovn", matching kube-ovn's NAD provider convention in both backends. Mutually exclusive with UnderlaySubnet. | string |  |
| vlanID | VLANID is the 802.1Q VLAN tag that the NAD named in `nadName` carries traffic on. Set it when you reference a raw NAD, so that VPCs sharing the same physical VLAN can be told apart from VPCs that happen to use the same ID for unrelated networks. It is ignored when `underlaySubnet` is used, because the tag is then read from the UnderlaySubnet. Zero means unknown. | integer |  |
| localIPs | LocalIPs are the AZ router's per-replica IPs on this VLAN — one per replica, within the UnderlaySubnet's CIDR. The operator builds the external-VLAN NAD's ip_pool annotation from this list so each StatefulSet replica gets its own stable IP; the external router peers each as a BGP neighbor (ECMP). | string array |  |
| localASN | LocalASN overrides AZEdgeRouterSpec.ASN as the LOCAL autonomous system number for this VPC's own per-VRF BGP instance ("router bgp <ASN> vrf <vpc>"). Zero (the default) inherits the router-wide ASN, same sentinel convention AZEdgeRouterSpec.ASN itself uses. Set this when VPCs sharing one advertisement VLAN need to present distinct AS numbers to the fabric — e.g. so the external router can apply AS-path-based policy per VPC instead of relying solely on neighbor IP or prefix content. Does not affect the default (non-per-VRF) BGP instance or the REMOTE peer ASN (see AZVPCFabricPeer.ASN for that). NOT SUPPORTED together with EVPN on the same VPC (a non-zero ResolvedAZVPC.VNI, from the backend or an EVPNPolicy): the EVPN RD/RT are always derived from the router-wide ASN, independent of this override, so combining the two would silently put the VRF's BGP session under one ASN and its RD/RT under another. The operator rejects the combination (ExternalVLANError) rather than guessing which one should win. | integer |  |
| peerIP | PeerIP is the external router's IP on this VLAN, the BGP neighbor that every replica peers with. Superseded by `peers`, which can carry more than one neighbor. It is still honoured: it is treated as a single peer that is sent everything and carries the VRF default route. Setting both is rejected unless `peerIP` repeats one of the peers. The value must be a plain IP address. | string |  |
| peers | Peers are the external BGP neighbors on this VPC's VLAN, replacing PeerIP. More than one because the fabric may put the tenant's SERVICE plane and its WORKLOAD plane on different routers: one neighbor takes the VPC's OVN subnets, another takes only the anycast blocks learned from in-VPC speakers. Both sit on this VPC's single underlay VLAN and are told apart by what each is sent, not by which wire they are on — per-tenant L2 separation would need a second NAD per VPC and is deliberately not this field. | [AZVPCFabricPeer](#azvpcfabricpeer) array |  |
| advertiseOVNSubnets | AdvertiseOVNSubnets overrides AZPerVRFTransitSpec.AdvertiseOVNSubnets for THIS VPC only, so one tenant can run SNAT-only egress (its fabric VRF never learns tenant space) while the tenants beside it stay directly routed — or the inverse, carving one directly-routed tenant out of an otherwise SNAT-only router. Absent inherits the router-wide setting; the session itself, the VPC's static routes and its BFD /32 are unaffected either way. | boolean |  |
| acceptPrefixes | AcceptPrefixes overrides AZPerVRFTransitSpec.AcceptPrefixes for THIS VPC only — what its own external fabric peer(s) may inject into its VRF via BGP. Absent inherits the router-wide list (empty there means deny everything). See AZPerVRFTransitSpec.AcceptPrefixes for why this exists. | [AZAcceptPrefix](#azacceptprefix) array |  |

[Back to Group](#v1alpha1)

### AZVPCFabricPeer

AZVPCFabricPeer is one external BGP neighbor on a VPC's underlay VLAN, in the
\"bgp-per-vrf\" OVN transit mode.

Every field except IP is an override of something inherited, so the zero value is
\"behave like the single peerIP always did\". The two Advertise* flags map onto the two
clauses of the per-VRF egress filter the router already builds — OVN subnets, and the
anycast blocks learned from in-VPC speakers — which is what lets one VLAN carry a
workload peer and a service peer at once.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| ip | IP is the neighbor's address on this VPC's underlay VLAN. Pattern-validated at admission for the same reason as AcceptPrefixes: this value renders verbatim into the FRR template ("neighbor \{\{ .IP \}\} ...", "ip route 0.0.0.0/0 \{\{ .IP \}\} ..."), so an embedded newline would inject extra config lines. EffectivePeers additionally rejects it at runtime for callers (e.g. the VPC annotation path) that build an AZVPCFabricPeer outside admission. | string |  |
| asn | ASN is the neighbor's autonomous system number. Zero inherits AZPerVRFTransitSpec.PeerASN, which is the common case; set it to face a transit AS and a service AS from the same VPC. Mirrors ExternalNeighbor.ASN on the per-VPC EdgeRouter. | integer |  |
| advertiseOVNSubnets | AdvertiseOVNSubnets sends this VPC's OVN tenant subnets to this neighbor. Absent inherits the per-VPC AdvertiseOVNSubnets, then the router-wide one, then true. This is an EXPORT policy and nothing else: it does not decide whether the neighbor carries the VRF's default route (see DefaultRoute) and does not touch the VPC's static routes or its BFD session. A peer with this false is SNAT-only egress, not an unrouted one. | boolean |  |
| advertiseAnycast | AdvertiseAnycast sends the anycast blocks learned from this VPC's in-VPC speakers (`internalPeers`) to this neighbor, which makes it a service peer. When unset, anycast is advertised on the router's default-VRF `bgpPeers` if any exist, and not to per-VRF sessions. If another peer of the same VPC sets it to true, anycast is withdrawn from all peers that did not ask for it. Setting false opts a peer out. Ignored for a VPC with no internal speakers. | boolean |  |
| defaultRoute | DefaultRoute makes this neighbor a VRF default gateway ("ip route 0.0.0.0/0 <ip>" inside the VPC's VRF). Absent means CANDIDATE — EXCEPT for a peer with MultihopTTL > 1, which is never an implicit candidate: nothing installs a /32 to a multihop peer, so its default route could never resolve its own nexthop and would sit installed-but-inactive, leaving the VPC with silent no-egress. Set this true explicitly on a multihop peer only when it is reachable some other way (e.g. an IGP-learned route). Every OTHER candidate gets a route, so two fabric devices on this VLAN are ECMP rather than one being silently preferred; one peer stays one route, which is today's behaviour. Marking any peer true narrows the set to the marked ones — the way to keep a transit peer out of it, along with setting false here. Deliberately NOT derived from the Advertise* flags: a SNAT-only transit peer advertises nothing and is still the egress gateway, which makes it flag-identical to a service peer. The role has to be stated, and on the annotation surface the key name states it. | boolean |  |
| multihopTTL | MultihopTTL is the eBGP multihop TTL, for a neighbor that is not on this VLAN's subnet. Zero or 1 is single-hop. | integer |  |
| bfd | BFD enables BFD on this session. Absent inherits spec.bfd.external.enabled, which today turns every external neighbor on or off together; set it to face one fabric device that requires BFD beside one that does not. | boolean |  |

[Back to Group](#v1alpha1)

### EffectiveFabricPeer

EffectiveFabricPeer is one fabric peer with every inherited default already applied,
so nothing downstream repeats the precedence rules or handles a nil.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| IP |  | string |  |
| ASN |  | integer |  |
| AdvertiseOVNSubnets |  | boolean |  |
| AdvertiseAnycast |  | boolean |  |
| DefaultRoute |  | boolean |  |
| MultihopTTL |  | integer |  |
| BFD |  | boolean |  |

[Back to Group](#v1alpha1)

### FabricPeerDefaults

FabricPeerDefaults carries the facts a peer inherits from outside itself. Passed in
rather than read from the CR so that peers arriving from a VPC's annotations resolve
through exactly the same code as peers written in the spec — and so the planned VPC
wrapper API becomes a third caller rather than a second implementation.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| PeerASN | PeerASN is AZPerVRFTransitSpec.PeerASN. | integer |  |
| AdvertiseOVNSubnets | AdvertiseOVNSubnets is the already-resolved per-VPC default, i.e. what AZPerVRFTransitSpec.AdvertiseOVNSubnetsForVPC reports for this VPC. | boolean |  |
| AdvertiseAnycast | AdvertiseAnycast is "the router has no default-VRF BGP plane" — see AZVPCFabricPeer.AdvertiseAnycast. | boolean |  |
| BFD | BFD is spec.bfd.external.enabled. | boolean |  |

[Back to Group](#v1alpha1)

### ConfigWatcherSpec

ConfigWatcherSpec configures the configuration watcher sidecar.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| enabled | Enabled indicates whether the config watcher sidecar is enabled. | boolean |  |
| interval | Interval is the polling interval in seconds for the config watcher. | integer |  |

[Back to Group](#v1alpha1)

### AZVPCEdgeRouterRef

AZVPCEdgeRouterRef identifies a per-VPC EdgeRouter CR to peer with.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| name | Name is the name of the per-VPC EdgeRouter CR. | string |  |
| namespace | Namespace is the namespace. Defaults to the AZEdgeRouter's namespace. | string |  |

[Back to Group](#v1alpha1)

### AZAcceptPrefix

AZAcceptPrefix is one entry in a bgp-per-vrf fabric accept-list: what an external fabric
peer may inject into a VPC's VRF via BGP. Distinct from the internal-speaker accept-list
(`internalPeers.acceptPrefixes`), which bounds a different direction and peer. For debugging, the
fabric accept-list is rendered as the prefix-list `PL-EXT-IN-<vrf>` in the router's FRR
configuration.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| cidr | CIDR is the IPv4 network to accept from the fabric peer. | string |  |
| allowedPrefixLength | AllowedPrefixLength, when set, also accepts any more-specific prefix of `cidr` up to a /N mask, instead of only the exact CIDR. 0 (the default) accepts only the exact CIDR. Must be between the CIDR's own mask length and 32; an entry outside that range is dropped. | integer |  |

[Back to Group](#v1alpha1)

### AZBGPPeer

AZBGPPeer defines an upstream BGP peer for plain IPv4 unicast route advertisement.
Used by BGPPeers, alone or together with EVPNPeers — enables the AZEdgeRouter to
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
\"bgp-per-vrf\" mode. The pod attaches an access-style interface (VLAN tagging is on
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
| acceptPrefixes | AcceptPrefixes is the resolved inbound accept-list for this VPC's external fabric peers, in precedence order: the VLAN reference's `acceptPrefixes`, then the VPC's `fabric-accept-prefixes` annotation, then the AZ-wide `perVRFTransit.acceptPrefixes`. An empty list denies every prefix from the fabric peers, which is the safe default. For debugging, this renders as the prefix-list `PL-EXT-IN-<vrf>` in the router's FRR configuration. | [AZAcceptPrefix](#azacceptprefix) array |  |

[Back to Group](#v1alpha1)

### AZInternalPeersSpec

AZInternalPeersSpec configures per-VPC peering with in-VPC BGP speakers that
advertise static anycast blocks for aggregation toward the external router.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| enabled | Enabled turns on the per-VPC internal peer-group. Requires an external advertisement plane — BGPPeers or OVNTransitMode "bgp-per-vrf". | boolean |  |
| asn | ASN is the internal speakers' autonomous system number. Zero means the session is configured as "remote-as external" (accept any peer ASN). | integer |  |
| acceptPrefixes | AcceptPrefixes bounds what the AZ router learns from internal speakers, typically the anycast super-block(s). An empty list accepts nothing, so a misconfigured speaker cannot inject arbitrary routes toward the external router. It is the default for every VPC; `perVPC` overrides it. Entries are IPv4 CIDRs. For debugging, this renders as the prefix-list `METALLB-IN` in the router's FRR configuration. | string array |  |
| perVPC | PerVPC narrows AcceptPrefixes for individual VPCs. Each VPC's internal peer-group filters on its own accept-list, so a speaker in one tenant VPC cannot inject another tenant's anycast block — which a single AZ-wide list permits, since every VRF then shares one filter. A VPC with no entry here uses AcceptPrefixes unchanged. | [AZInternalPeersVPCOverride](#azinternalpeersvpcoverride) array |  |
| multihopTTL | MultihopTTL is the eBGP multihop TTL for the internal session; the speaker sits one or more hops away behind the tenant VPC logical router. | integer |  |
| bfd | BFD enables BFD on the internal session. | boolean |  |

[Back to Group](#v1alpha1)

### AZInternalPeersVPCOverride

AZInternalPeersVPCOverride narrows the internal-speaker accept-list for one VPC.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| vpc | VPC is the kube-ovn VPC name; must match a VPC this router resolves. An entry naming an unresolved VPC has no effect. A VPC of another namespace is written `<namespace>/<name>`; a bare name means the router's own namespace. | string |  |
| acceptPrefixes | AcceptPrefixes replaces the AZ-wide `internalPeers.acceptPrefixes` for this VPC. An explicitly empty list accepts nothing from this VPC's speakers, while omitting the field inherits the AZ-wide list. Entries are IPv4 CIDRs. | string array |  |

[Back to Group](#v1alpha1)

### AZPerVRFTransitSpec

AZPerVRFTransitSpec configures per-tenant underlay VLAN attachments for the
\"bgp-per-vrf\" OVN transit mode. The platform pre-provisions one UnderlaySubnet
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
gets its own /30 Subnet CR named \"<SubnetName>-<vpcName>\", providing a
firewalling boundary between tenants with no implicit inter-VPC L2 path.

For VPC at sorted index i with replicaCount R, a block of size S=nextPow2(R+3)
is allocated (minimum 4, i.e. /30 for R=1). The +3 reserves the network,
gateway and broadcast addresses, so a transit IP never lands on the broadcast
(which kube-ovn refuses to assign):

	base + S*i + 0        network
	base + S*i + 1        management VPC LR gateway  → GatewayIP
	base + S*i + 2 ..R+1  FRR pod transit IPs        → TransitIPPool[0..R-1]
	base + S*i + S-1      broadcast (always above the transit IPs)

For R=1: S=4 → /30 (gw .1, transit .2, broadcast .3).
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
| name | Name is the router-local key of the VPC: its own name when it is in the router's namespace, `<name>--<digest of the namespace>` when it is in another. Per-VPC resources of the router are derived from it. | string |  |
| namespace | Namespace is the namespace of the VPC when it is not the router's own. Empty for a VPC of the router's namespace and for cluster-scoped VPCs. | string |  |
| vpcName | VPCName is the name of the VPC object when it differs from `name`, that is, for a VPC of another namespace. | string |  |
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
| acceptPrefixes | AcceptPrefixes is the resolved inbound accept-list for this VPC's external fabric peers, in precedence order: the VLAN reference's `acceptPrefixes`, then the VPC's `fabric-accept-prefixes` annotation, then the AZ-wide `perVRFTransit.acceptPrefixes`. An empty list denies every prefix from the fabric peers, which is the safe default. For debugging, this renders as the prefix-list `PL-EXT-IN-<vrf>` in the router's FRR configuration. | [AZAcceptPrefix](#azacceptprefix) array |  |
| egressEnabled | EgressEnabled controls whether this VPC's traffic should be SNAT'd/masqueraded by the AZ EdgeRouter pod. The operator always resolves it: true unless the VPC carries the egress-enabled=false annotation. Being a bool with omitempty, false is left out on the wire, so read an absent value as off. | boolean |  |
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

### NADRef

NADRef is a reference to a NetworkAttachmentDefinition resource.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| name | Name is the name of the NetworkAttachmentDefinition. | string |  |
| namespace | Namespace is the namespace of the NetworkAttachmentDefinition. | string |  |

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

### NetshootSpec

NetshootSpec configures the netshoot debug sidecar.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| enabled | Enabled indicates whether the netshoot sidecar is enabled. | boolean |  |

[Back to Group](#v1alpha1)

### BFDSessionStatus

BFDSessionStatus describes the status of a single BFD session.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| peerIP | PeerIP is the IP address of the BFD peer. | string |  |
| podName | PodName is the name of the FRR pod that owns this session. Set only for external BFD sessions (one entry per pod per peer). | string |  |
| status | Status is the current state of the BFD session (e.g., "up", "down", "admin_down", "unknown"). | string |  |
| lastCheckTime | LastCheckTime is the timestamp of the most recent status query for this peer. | metav1.Time |  |

[Back to Group](#v1alpha1)

### BFDSideSpec

BFDSideSpec configures BFD for one side (internal or external) of a BGP session.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| enabled | Enabled indicates whether BFD is enabled for this side. | boolean |  |
| ip | IP is the local IP address used for BFD sessions on this side. | string |  |

[Back to Group](#v1alpha1)

### BFDSpec

BFDSpec defines the Bidirectional Forwarding Detection configuration.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| minTx | MinTx is the minimum BFD transmission interval in milliseconds. | integer |  |
| minRx | MinRx is the minimum BFD receive interval in milliseconds. | integer |  |
| multi | Multi is the BFD detection multiplier. | integer |  |
| internal | Internal configures BFD for the internal peering side. | [BFDSideSpec](#bfdsidespec) |  |
| external | External configures BFD for the external peering side. | [BFDSideSpec](#bfdsidespec) |  |

[Back to Group](#v1alpha1)

### BGPSessionStatus

BGPSessionStatus is one BGP neighbour of one router replica, as FRR reports it
(`show bgp vrf all summary json`). It covers every session the replica has — the
external fabric peers as well as the in-VPC speakers that connect to a listen range —
which is otherwise only visible by running vtysh inside the pod.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| replica | Replica is the router pod the session belongs to (each replica peers on its own). | string |  |
| vrf | VRF is the VRF the session lives in ("default" for the global table). | string |  |
| neighbor | Neighbor is the peer address. For a dynamic peer it is the address the peer connected from, which is how an in-VPC MetalLB speaker shows up. | string |  |
| addressFamily | AddressFamily is "ipv4", "ipv6" or "evpn": the address family the session carries. A neighbour that negotiates several appears once per family. | string |  |
| remoteASN | RemoteASN is the peer's autonomous system number. | integer |  |
| hostname | Hostname is the hostname the peer announced (BGP hostname capability), e.g. the node a MetalLB speaker runs on. | string |  |
| state | State is FRR's session state: Established, Active, Connect, OpenSent, ... | string |  |
| dynamic | Dynamic is true when the peer was accepted through a `bgp listen range` (an in-VPC speaker) rather than configured explicitly (an external fabric peer). | boolean |  |
| prefixesReceived | PrefixesReceived is the number of prefixes the peer advertised to this replica. | integer |  |
| prefixesSent | PrefixesSent is the number of prefixes this replica advertised to the peer. | integer |  |
| establishedAt | EstablishedAt is when the current session came up. It is an absolute timestamp rather than an uptime so it stays constant while the session lasts and does not rewrite the status on every read. Unset unless the session is Established. | metav1.Time |  |

[Back to Group](#v1alpha1)

### AZEdgeRouterList

AZEdgeRouterList contains a list of AZEdgeRouter.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| metadata | Refer to Kubernetes API documentation for fields of `metadata`. | [ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.37/#listmeta-v1-meta) | false |
| items |  | [][AZEdgeRouter](#azedgerouter) | true |

[Back to Group](#v1alpha1)

### EVPNPeer

EVPNPeer describes a single BGP peer used exclusively for EVPN route exchange.
Populated into an AZEdgeRouter's status by the EVPNRouteReflector controller.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| ip | IP is the IP address of the EVPN peer (RR replica NAD IP). | string |  |
| asn | ASN is the BGP Autonomous System Number of the EVPN peer. | integer |  |
| multihopTTL | MultihopTTL is the eBGP multihop TTL. Required when the peer is on a different VLAN reachable via L3 routing (typically 3). | integer |  |

[Back to Group](#v1alpha1)

### ExternalNeighbor

ExternalNeighbor represents a single external BGP neighbor.

| Field | Description | Scheme | Required |
| ----- | ----------- | ------ | -------- |
| ip | IP is the IP address of the external neighbor. | string |  |
| asn | ASN is the remote Autonomous System Number for this neighbor. When 0 (unset) the peer-wide external ASN is used. Set it to peer multiple upstreams in different ASNs from a single router — e.g. a per-region external router and a shared global transit router in distinct ASNs. | integer |  |
| passwordSecret | PasswordSecret is an optional reference to a secret containing the BGP session password. Using a pointer ensures omitempty suppresses the field when not set. | corev1.SecretKeySelector |  |
| advertiseInternalRoutes | AdvertiseInternalRoutes controls whether routes learned from internal peers (e.g. MetalLB speakers) are included in the outbound prefix list for this neighbor. | boolean |  |
| advertisedCIDRs | AdvertisedCIDRs is an explicit allowlist of CIDR prefixes to advertise to this neighbor. When set, it replaces the peer-wide advertised subnets for this neighbor. | string array |  |
| subnetLabelSelector | SubnetLabelSelector, when set, discovers subnets matching these labels and advertises their CIDRs to this neighbor, overriding the peer-wide advertisement. | [LabelSelector](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.37/#labelselector-v1-meta) |  |
| multihopTTL | MultihopTTL is the eBGP multihop TTL for this neighbor. Required when the peer is not on the external NAD's subnet (reachable only via L3 through the VLAN gateway). Renders as "neighbor <ip> ebgp-multihop <ttl>". Zero/unset leaves the eBGP default. | integer |  |

[Back to Group](#v1alpha1)

### EVPNPolicy

EVPNPolicy is an admin-managed object that defines BGP EVPN Type 5 routing policy
for one or more EdgeRouter instances. It specifies the VNI, Route Distinguisher,
and import/export Route Targets that control cross-VPC reachability.

The operator resolves the policy and writes the result into each target
EdgeRouter's status (status.resolvedEVPNVRFs), where the frr-config-watcher
sidecar reads it to generate per-VRF FRR configuration. Users deploying
EdgeRouter objects do not need access to EVPNPolicy objects.

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
| metadata | Refer to Kubernetes API documentation for fields of `metadata`. | [ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.37/#listmeta-v1-meta) | false |
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

EVPNRouteReflector is an admin-managed object that deploys a dedicated FRR BGP route reflector for EVPN Type 5 routes. It discovers EdgeRouter objects matching the selector, establishes iBGP sessions with them (same AS as the edge routers) using the l2vpn evpn address family only, and reflects EVPN routes between them with next-hop unchanged so that VXLAN data-plane traffic flows directly between edge router VTEPs. Each replica is assigned a pre-defined IP from spec.ips (by StatefulSet ordinal) on the dedicated NAD. The controller writes the RR peer info into each targeted EdgeRouter's status.resolvedEVPNPeers so the frr-config-watcher sidecar adds the RR as an EVPN-only neighbor without requiring any manual EdgeRouter configuration.

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
| metadata | Refer to Kubernetes API documentation for fields of `metadata`. | [ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.37/#listmeta-v1-meta) | false |
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
| multihopTTL | MultihopTTL is the BGP multihop TTL for sessions to edge routers on a different subnet, reachable via L3 routing (typically 3). The dynamic (listen-range) iBGP sessions do not use it. | integer |  |
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
