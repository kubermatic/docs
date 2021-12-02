+++
title = "Kubermatic CRDs reference"
date = 2021-12-02T00:00:00
weight = 40
+++

## Packages
- [kubermatic.k8c.io/v1](#kubermatick8ciov1)


## kubermatic.k8c.io/v1


### Resource Types
- [Addon](#addon)
- [AddonConfig](#addonconfig)
- [AddonConfigList](#addonconfiglist)
- [AddonList](#addonlist)
- [AdmissionPlugin](#admissionplugin)
- [AdmissionPluginList](#admissionpluginlist)
- [Alertmanager](#alertmanager)
- [AlertmanagerList](#alertmanagerlist)
- [AllowedRegistry](#allowedregistry)
- [AllowedRegistryList](#allowedregistrylist)
- [Cluster](#cluster)
- [ClusterList](#clusterlist)
- [ClusterTemplate](#clustertemplate)
- [ClusterTemplateInstance](#clustertemplateinstance)
- [ClusterTemplateInstanceList](#clustertemplateinstancelist)
- [ClusterTemplateList](#clustertemplatelist)
- [Constraint](#constraint)
- [ConstraintList](#constraintlist)
- [ConstraintTemplate](#constrainttemplate)
- [ConstraintTemplateList](#constrainttemplatelist)
- [EtcdBackupConfig](#etcdbackupconfig)
- [EtcdBackupConfigList](#etcdbackupconfiglist)
- [EtcdRestore](#etcdrestore)
- [EtcdRestoreList](#etcdrestorelist)
- [ExternalCluster](#externalcluster)
- [ExternalClusterList](#externalclusterlist)
- [KubermaticConfiguration](#kubermaticconfiguration)
- [KubermaticConfigurationList](#kubermaticconfigurationlist)
- [KubermaticSetting](#kubermaticsetting)
- [KubermaticSettingList](#kubermaticsettinglist)
- [MLAAdminSetting](#mlaadminsetting)
- [MLAAdminSettingList](#mlaadminsettinglist)
- [Preset](#preset)
- [PresetList](#presetlist)
- [Project](#project)
- [ProjectList](#projectlist)
- [RuleGroup](#rulegroup)
- [RuleGroupList](#rulegrouplist)
- [Seed](#seed)
- [SeedList](#seedlist)
- [User](#user)
- [UserList](#userlist)
- [UserProjectBinding](#userprojectbinding)
- [UserProjectBindingList](#userprojectbindinglist)
- [UserSSHKey](#usersshkey)
- [UserSSHKeyList](#usersshkeylist)



### APIServerSettings





_Appears in:_
- [ComponentSettings](#componentsettings)

| Field | Description |
| --- | --- |
| `DeploymentSettings` _[DeploymentSettings](#deploymentsettings)_ |  |
| `endpointReconcilingDisabled` _boolean_ |  |
| `nodePortRange` _string_ |  |


[Back to top](#top)



### AWS





_Appears in:_
- [PresetSpec](#presetspec)

| Field | Description |
| --- | --- |
| `PresetProvider` _[PresetProvider](#presetprovider)_ |  |
| `accessKeyID` _string_ |  |
| `secretAccessKey` _string_ |  |
| `assumeRoleARN` _string_ |  |
| `assumeRoleExternalID` _string_ |  |
| `vpcID` _string_ |  |
| `routeTableID` _string_ |  |
| `instanceProfileName` _string_ |  |
| `securityGroupID` _string_ |  |
| `roleARN` _string_ |  |


[Back to top](#top)



### AWSCloudSpec



AWSCloudSpec specifies access data to Amazon Web Services.

_Appears in:_
- [CloudSpec](#cloudspec)

| Field | Description |
| --- | --- |
| `credentialsReference` _[GlobalSecretKeySelector](#globalsecretkeyselector)_ |  |
| `accessKeyID` _string_ |  |
| `secretAccessKey` _string_ |  |
| `assumeRoleARN` _string_ |  |
| `assumeRoleExternalID` _string_ |  |
| `vpcID` _string_ |  |
| `roleARN` _string_ | The IAM role, the control plane will use. The control plane will perform an assume-role |
| `routeTableID` _string_ |  |
| `instanceProfileName` _string_ |  |
| `securityGroupID` _string_ |  |
| `roleName` _string_ | DEPRECATED. Don't care for the role name. We only require the ControlPlaneRoleARN to be set so the control plane can perform the assume-role. We keep it for backwards compatibility (We use this name for cleanup purpose). |


[Back to top](#top)



### Addon



Addon specifies a add-on

_Appears in:_
- [AddonList](#addonlist)

| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `Addon`
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[AddonSpec](#addonspec)_ |  |
| `status` _[AddonStatus](#addonstatus)_ |  |


[Back to top](#top)



### AddonCondition





_Appears in:_
- [AddonStatus](#addonstatus)

| Field | Description |
| --- | --- |
| `type` _[AddonConditionType](#addonconditiontype)_ | Type of addon condition. |
| `status` _[ConditionStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#conditionstatus-v1-core)_ | Status of the condition, one of True, False, Unknown. |
| `lastHeartbeatTime` _[Time](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#time-v1-meta)_ | Last time we got an update on a given condition. |
| `lastTransitionTime` _[Time](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#time-v1-meta)_ | Last time the condition transit from one status to another. |


[Back to top](#top)



### AddonConditionType

_Underlying type:_ `string`



_Appears in:_
- [AddonCondition](#addoncondition)



### AddonConfig



AddonConfig specifies addon configuration

_Appears in:_
- [AddonConfigList](#addonconfiglist)

| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `AddonConfig`
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[AddonConfigSpec](#addonconfigspec)_ |  |


[Back to top](#top)



### AddonConfigList



AddonConfigList is a list of addon configs



| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `AddonConfigList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[AddonConfig](#addonconfig)_ |  |


[Back to top](#top)



### AddonConfigSpec



AddonConfigSpec specifies configuration of addon

_Appears in:_
- [AddonConfig](#addonconfig)

| Field | Description |
| --- | --- |
| `shortDescription` _string_ | ShortDescription of the configured addon that contains more detailed information about the addon, it will be displayed in the addon details view in the UI |
| `description` _string_ | Description of the configured addon, it will be displayed in the addon overview in the UI |
| `logo` _string_ | Logo of the configured addon, encoded in base64 |
| `logoFormat` _string_ | LogoFormat contains logo format of the configured addon, i.e. svg+xml |
| `formSpec` _[AddonFormControl](#addonformcontrol) array_ | Controls that can be set for configured addon |


[Back to top](#top)



### AddonFormControl



AddonFormControl specifies addon form control

_Appears in:_
- [AddonConfigSpec](#addonconfigspec)

| Field | Description |
| --- | --- |
| `displayName` _string_ | DisplayName is visible in the UI |
| `internalName` _string_ | InternalName is used internally to save in the addon object |
| `helpText` _string_ | HelpText is visible in the UI next to the control |
| `required` _boolean_ | Required indicates if the control has to be set |
| `type` _string_ | Type of displayed control |


[Back to top](#top)



### AddonList



AddonList is a list of addons



| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `AddonList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[Addon](#addon)_ |  |


[Back to top](#top)



### AddonSpec



AddonSpec specifies details of an addon

_Appears in:_
- [Addon](#addon)

| Field | Description |
| --- | --- |
| `name` _string_ | Name defines the name of the addon to install |
| `cluster` _[ObjectReference](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#objectreference-v1-core)_ | Cluster is the reference to the cluster the addon should be installed in |
| `variables` _[RawExtension](#rawextension)_ | Variables is free form data to use for parsing the manifest templates |
| `requiredResourceTypes` _[GroupVersionKind](#groupversionkind) array_ | RequiredResourceTypes allows to indicate that this addon needs some resource type before it can be installed. This can be used to indicate that a specific CRD and/or extension apiserver must be installed before this addon can be installed. The addon will not be installed until that resource is served. |
| `isDefault` _boolean_ | IsDefault indicates whether the addon is default |


[Back to top](#top)



### AddonStatus





_Appears in:_
- [Addon](#addon)

| Field | Description |
| --- | --- |
| `conditions` _[AddonCondition](#addoncondition) array_ |  |


[Back to top](#top)



### AdmissionPlugin



AdmissionPlugin is the type representing a AdmissionPlugin

_Appears in:_
- [AdmissionPluginList](#admissionpluginlist)

| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `AdmissionPlugin`
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[AdmissionPluginSpec](#admissionpluginspec)_ |  |


[Back to top](#top)



### AdmissionPluginList



AdmissionPluginList is the type representing a AdmissionPluginList



| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `AdmissionPluginList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[AdmissionPlugin](#admissionplugin) array_ | List of Admission Plugins |


[Back to top](#top)



### AdmissionPluginSpec



AdmissionPluginSpec specifies admission plugin name and from which k8s version is supported.

_Appears in:_
- [AdmissionPlugin](#admissionplugin)

| Field | Description |
| --- | --- |
| `pluginName` _string_ |  |
| `fromVersion` _Semver_ | FromVersion flag can be empty. It means the plugin fit to all k8s versions |


[Back to top](#top)



### Alertmanager





_Appears in:_
- [AlertmanagerList](#alertmanagerlist)

| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `Alertmanager`
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[AlertmanagerSpec](#alertmanagerspec)_ |  |
| `status` _[AlertmanagerStatus](#alertmanagerstatus)_ |  |


[Back to top](#top)



### AlertmanagerConfigurationStatus



AlertmanagerConfigurationStatus stores status information about the AlertManager configuration

_Appears in:_
- [AlertmanagerStatus](#alertmanagerstatus)

| Field | Description |
| --- | --- |
| `lastUpdated` _[Time](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#time-v1-meta)_ | LastUpdated stores the last successful time when the configuration was successfully applied |
| `status` _[ConditionStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#conditionstatus-v1-core)_ | Status of whether the configuration was applied, one of True, False |
| `errorMessage` _string_ | ErrorMessage contains a default error message in case the configuration could not be applied. Will be reset if the error was resolved and condition becomes True |


[Back to top](#top)



### AlertmanagerList







| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `AlertmanagerList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[Alertmanager](#alertmanager)_ |  |


[Back to top](#top)



### AlertmanagerSpec





_Appears in:_
- [Alertmanager](#alertmanager)

| Field | Description |
| --- | --- |
| `configSecret` _[LocalObjectReference](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#localobjectreference-v1-core)_ | ConfigSecret refers to the Secret in the same namespace as the Alertmanager object, which contains configuration for this Alertmanager. |


[Back to top](#top)



### AlertmanagerStatus



AlertmanagerStatus stores status information about the AlertManager

_Appears in:_
- [Alertmanager](#alertmanager)

| Field | Description |
| --- | --- |
| `configStatus` _[AlertmanagerConfigurationStatus](#alertmanagerconfigurationstatus)_ |  |


[Back to top](#top)



### Alibaba





_Appears in:_
- [PresetSpec](#presetspec)

| Field | Description |
| --- | --- |
| `PresetProvider` _[PresetProvider](#presetprovider)_ |  |
| `accessKeyID` _string_ |  |
| `accessKeySecret` _string_ |  |


[Back to top](#top)



### AlibabaCloudSpec



AlibabaCloudSpec specifies the access data to Alibaba.

_Appears in:_
- [CloudSpec](#cloudspec)

| Field | Description |
| --- | --- |
| `credentialsReference` _[GlobalSecretKeySelector](#globalsecretkeyselector)_ |  |
| `accessKeyID` _string_ |  |
| `accessKeySecret` _string_ |  |


[Back to top](#top)



### AllowedRegistry



AllowedRegistry is the object representing an allowed registry.

_Appears in:_
- [AllowedRegistryList](#allowedregistrylist)

| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `AllowedRegistry`
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[AllowedRegistrySpec](#allowedregistryspec)_ |  |


[Back to top](#top)



### AllowedRegistryList



AllowedRegistryList specifies a list of allowed registries



| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `AllowedRegistryList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[AllowedRegistry](#allowedregistry)_ |  |


[Back to top](#top)



### AllowedRegistrySpec



AllowedRegistrySpec specifies the data for allowed registry spec.

_Appears in:_
- [AllowedRegistry](#allowedregistry)

| Field | Description |
| --- | --- |
| `registryPrefix` _string_ | RegistryPrefix contains the prefix of the registry which will be allowed. User clusters will be able to deploy only images which are prefixed with one of the allowed image registry prefixes. |


[Back to top](#top)



### Anexia





_Appears in:_
- [PresetSpec](#presetspec)

| Field | Description |
| --- | --- |
| `PresetProvider` _[PresetProvider](#presetprovider)_ |  |
| `token` _string_ | Token is used to authenticate with the Anexia API. |


[Back to top](#top)



### AnexiaCloudSpec



AnexiaCloudSpec specifies the access data to Anexia.

_Appears in:_
- [CloudSpec](#cloudspec)

| Field | Description |
| --- | --- |
| `credentialsReference` _[GlobalSecretKeySelector](#globalsecretkeyselector)_ |  |
| `token` _string_ |  |


[Back to top](#top)



### AuditLoggingSettings





_Appears in:_
- [ClusterSpec](#clusterspec)

| Field | Description |
| --- | --- |
| `enabled` _boolean_ |  |
| `policyPreset` _[AuditPolicyPreset](#auditpolicypreset)_ |  |


[Back to top](#top)



### AuditPolicyPreset

_Underlying type:_ `string`



_Appears in:_
- [AuditLoggingSettings](#auditloggingsettings)



### Azure





_Appears in:_
- [PresetSpec](#presetspec)

| Field | Description |
| --- | --- |
| `PresetProvider` _[PresetProvider](#presetprovider)_ |  |
| `tenantID` _string_ |  |
| `subscriptionID` _string_ |  |
| `clientID` _string_ |  |
| `clientSecret` _string_ |  |
| `resourceGroup` _string_ |  |
| `vnetResourceGroup` _string_ |  |
| `vnet` _string_ |  |
| `subnet` _string_ |  |
| `routeTable` _string_ |  |
| `securityGroup` _string_ |  |
| `loadBalancerSKU` _LBSKU_ | LoadBalancerSKU sets the LB type that will be used for the Azure cluster, possible values are "basic" and "standard", if empty, "basic" will be used |


[Back to top](#top)



### AzureCloudSpec



AzureCloudSpec specifies access credentials to Azure cloud.

_Appears in:_
- [CloudSpec](#cloudspec)

| Field | Description |
| --- | --- |
| `credentialsReference` _[GlobalSecretKeySelector](#globalsecretkeyselector)_ |  |
| `tenantID` _string_ |  |
| `subscriptionID` _string_ |  |
| `clientID` _string_ |  |
| `clientSecret` _string_ |  |
| `resourceGroup` _string_ |  |
| `vnetResourceGroup` _string_ |  |
| `vnet` _string_ |  |
| `subnet` _string_ |  |
| `routeTable` _string_ |  |
| `securityGroup` _string_ |  |
| `assignAvailabilitySet` _boolean_ |  |
| `availabilitySet` _string_ |  |
| `loadBalancerSKU` _LBSKU_ | LoadBalancerSKU sets the LB type that will be used for the Azure cluster, possible values are "basic" and "standard", if empty, "basic" will be used |


[Back to top](#top)



### BackupDestination



BackupDestination defines the bucket name and endpoint as a backup destination, and holds reference to the credentials secret.

_Appears in:_
- [EtcdBackupRestore](#etcdbackuprestore)

| Field | Description |
| --- | --- |
| `endpoint` _string_ | Endpoint is the API endpoint to use for backup and restore. |
| `bucketName` _string_ | BucketName is the bucket name to use for backup and restore. |
| `credentials` _[SecretReference](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#secretreference-v1-core)_ | Credentials hold the ref to the secret with backup credentials |


[Back to top](#top)



### BackupStatus





_Appears in:_
- [EtcdBackupConfigStatus](#etcdbackupconfigstatus)

| Field | Description |
| --- | --- |
| `scheduledTime` _[Time](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#time-v1-meta)_ | ScheduledTime will always be set when the BackupStatus is created, so it'll never be nil |
| `backupName` _string_ |  |
| `jobName` _string_ |  |
| `backupStartTime` _[Time](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#time-v1-meta)_ |  |
| `backupFinishedTime` _[Time](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#time-v1-meta)_ |  |
| `backupPhase` _[BackupStatusPhase](#backupstatusphase)_ |  |
| `backupMessage` _string_ |  |
| `deleteJobName` _string_ |  |
| `deleteStartTime` _[Time](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#time-v1-meta)_ |  |
| `deleteFinishedTime` _[Time](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#time-v1-meta)_ |  |
| `deletePhase` _[BackupStatusPhase](#backupstatusphase)_ |  |
| `deleteMessage` _string_ |  |


[Back to top](#top)



### BackupStatusPhase

_Underlying type:_ `string`



_Appears in:_
- [BackupStatus](#backupstatus)



### BringYourOwnCloudSpec



BringYourOwnCloudSpec specifies access data for a bring your own cluster.

_Appears in:_
- [CloudSpec](#cloudspec)





### CNIPluginSettings



CNIPluginSettings contains the spec of the CNI plugin used by the Cluster.

_Appears in:_
- [ClusterSpec](#clusterspec)

| Field | Description |
| --- | --- |
| `type` _[CNIPluginType](#cniplugintype)_ |  |
| `version` _string_ |  |


[Back to top](#top)



### CNIPluginType

_Underlying type:_ `string`

CNIPluginType define the type of CNI plugin installed. e.g. Canal

_Appears in:_
- [CNIPluginSettings](#cnipluginsettings)



### CleanupOptions





_Appears in:_
- [SettingSpec](#settingspec)

| Field | Description |
| --- | --- |
| `enabled` _boolean_ |  |
| `enforced` _boolean_ |  |


[Back to top](#top)



### CloudSpec



CloudSpec mutually stores access data to a cloud provider.

_Appears in:_
- [ClusterSpec](#clusterspec)

| Field | Description |
| --- | --- |
| `dc` _string_ | DatacenterName where the users 'cloud' lives in. |
| `fake` _[FakeCloudSpec](#fakecloudspec)_ |  |
| `digitalocean` _[DigitaloceanCloudSpec](#digitaloceancloudspec)_ |  |
| `bringyourown` _[BringYourOwnCloudSpec](#bringyourowncloudspec)_ |  |
| `aws` _[AWSCloudSpec](#awscloudspec)_ |  |
| `azure` _[AzureCloudSpec](#azurecloudspec)_ |  |
| `openstack` _[OpenstackCloudSpec](#openstackcloudspec)_ |  |
| `packet` _[PacketCloudSpec](#packetcloudspec)_ |  |
| `hetzner` _[HetznerCloudSpec](#hetznercloudspec)_ |  |
| `vsphere` _[VSphereCloudSpec](#vspherecloudspec)_ |  |
| `gcp` _[GCPCloudSpec](#gcpcloudspec)_ |  |
| `kubevirt` _[KubevirtCloudSpec](#kubevirtcloudspec)_ |  |
| `alibaba` _[AlibabaCloudSpec](#alibabacloudspec)_ |  |
| `anexia` _[AnexiaCloudSpec](#anexiacloudspec)_ |  |


[Back to top](#top)



### Cluster



Cluster is the object representing a cluster.

_Appears in:_
- [ClusterList](#clusterlist)

| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `Cluster`
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[ClusterSpec](#clusterspec)_ |  |
| `address` _[ClusterAddress](#clusteraddress)_ |  |
| `status` _[ClusterStatus](#clusterstatus)_ |  |


[Back to top](#top)



### ClusterAddress



ClusterAddress stores access and address information of a cluster.

_Appears in:_
- [Cluster](#cluster)

| Field | Description |
| --- | --- |
| `url` _string_ | URL under which the Apiserver is available |
| `port` _integer_ | Port is the port the API server listens on |
| `externalName` _string_ | ExternalName is the DNS name for this cluster |
| `internalURL` _string_ | InternalName is the seed cluster internal absolute DNS name to the API server |
| `adminToken` _string_ | AdminToken is the token for the kubeconfig, the user can download |
| `ip` _string_ | IP is the external IP under which the apiserver is available |


[Back to top](#top)



### ClusterCondition





_Appears in:_
- [ClusterStatus](#clusterstatus)

| Field | Description |
| --- | --- |
| `type` _[ClusterConditionType](#clusterconditiontype)_ | Type of cluster condition. |
| `status` _[ConditionStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#conditionstatus-v1-core)_ | Status of the condition, one of True, False, Unknown. |
| `kubermaticVersion` _string_ | KubermaticVersion current kubermatic version. |
| `lastHeartbeatTime` _[Time](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#time-v1-meta)_ | Last time we got an update on a given condition. |
| `lastTransitionTime` _[Time](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#time-v1-meta)_ | Last time the condition transit from one status to another. |
| `reason` _string_ | (brief) reason for the condition's last transition. |
| `message` _string_ | Human readable message indicating details about last transition. |


[Back to top](#top)



### ClusterConditionType

_Underlying type:_ `string`

ClusterConditionType is used to indicate the type of a cluster condition. For all condition types, the `true` value must indicate success. All condition types must be registered within the `AllClusterConditionTypes` variable.

_Appears in:_
- [ClusterCondition](#clustercondition)



### ClusterList



ClusterList specifies a list of clusters



| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `ClusterList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[Cluster](#cluster)_ |  |


[Back to top](#top)



### ClusterNetworkingConfig



ClusterNetworkingConfig specifies the different networking parameters for a cluster.

_Appears in:_
- [ClusterSpec](#clusterspec)

| Field | Description |
| --- | --- |
| `services` _[NetworkRanges](#networkranges)_ | The network ranges from which service VIPs are allocated. |
| `pods` _[NetworkRanges](#networkranges)_ | The network ranges from which POD networks are allocated. |
| `dnsDomain` _string_ | Domain name for services. |
| `proxyMode` _string_ | ProxyMode defines the kube-proxy mode ("ipvs" / "iptables" / "ebpf"). Defaults to "ipvs". "ebpf" disables kube-proxy and requires CNI support. |
| `ipvs` _[IPVSConfiguration](#ipvsconfiguration)_ | IPVS defines kube-proxy ipvs configuration options |
| `nodeLocalDNSCacheEnabled` _boolean_ | NodeLocalDNSCacheEnabled controls whether the NodeLocal DNS Cache feature is enabled. Defaults to true. |
| `konnectivityEnabled` _boolean_ | KonnectivityEnabled enables konnectivity for controlplane to node network communication. |


[Back to top](#top)



### ClusterSpec



ClusterSpec specifies the data for a new cluster.

_Appears in:_
- [Cluster](#cluster)
- [ClusterTemplate](#clustertemplate)

| Field | Description |
| --- | --- |
| `cloud` _[CloudSpec](#cloudspec)_ |  |
| `clusterNetwork` _[ClusterNetworkingConfig](#clusternetworkingconfig)_ |  |
| `machineNetworks` _[MachineNetworkingConfig](#machinenetworkingconfig) array_ |  |
| `version` _Semver_ | Version defines the wanted version of the control plane |
| `masterVersion` _string_ | MasterVersion is Deprecated |
| `humanReadableName` _string_ | HumanReadableName is the cluster name provided by the user |
| `exposeStrategy` _[ExposeStrategy](#exposestrategy)_ | ExposeStrategy is the approach we use to expose this cluster, either via NodePort or via a dedicated LoadBalancer |
| `pause` _boolean_ | Pause tells that this cluster is currently not managed by the controller. It indicates that the user needs to do some action to resolve the pause. |
| `pauseReason` _string_ | PauseReason is the reason why the cluster is no being managed. |
| `componentsOverride` _[ComponentSettings](#componentsettings)_ | Optional component specific overrides |
| `oidc` _[OIDCSettings](#oidcsettings)_ |  |
| `features` _object (keys:string, values:boolean)_ | Feature flags This unfortunately has to be a string map, because we use it in templating and that can not cope with string types |
| `updateWindow` _[UpdateWindow](#updatewindow)_ |  |
| `usePodSecurityPolicyAdmissionPlugin` _boolean_ |  |
| `usePodNodeSelectorAdmissionPlugin` _boolean_ |  |
| `useEventRateLimitAdmissionPlugin` _boolean_ |  |
| `enableUserSSHKeyAgent` _boolean_ | EnableUserSSHKeyAgent control whether the UserSSHKeyAgent will be deployed in the user cluster or not. If it was enabled, the agent will be deployed and used to sync the user ssh keys, that the user attach to the created cluster. If the agent was disabled, it won't be deployed in the user cluster, thus after the cluster creation any attached ssh keys won't be synced to the worker nodes. Once the agent is enabled/disabled it cannot be changed after the cluster is being created. |
| `podNodeSelectorAdmissionPluginConfig` _object (keys:string, values:string)_ | PodNodeSelectorAdmissionPluginConfig provides the configuration for the PodNodeSelector. It's used by the backend to create a configuration file for this plugin. The key:value from the map is converted to the namespace:<node-selectors-labels> in the file. The format in a file: podNodeSelectorPluginConfig:  clusterDefaultNodeSelector: <node-selectors-labels>  namespace1: <node-selectors-labels>  namespace2: <node-selectors-labels> |
| `eventRateLimitConfig` _[EventRateLimitConfig](#eventratelimitconfig)_ | EventRateLimitConfig allows configuring the EventRateLimit admission plugin (if enabled via useEventRateLimitAdmissionPlugin) to create limits on Kubernetes event generation. The EventRateLimit plugin is capable of comparing incoming Events to several configured buckets based on the type of event rate limit. |
| `admissionPlugins` _string array_ | AdmissionPlugins provides the ability to pass arbitrary names of admission plugins to kube-apiserver |
| `auditLogging` _[AuditLoggingSettings](#auditloggingsettings)_ |  |
| `opaIntegration` _[OPAIntegrationSettings](#opaintegrationsettings)_ | OPAIntegration is a preview feature that enables OPA integration with Kubermatic for the cluster. Enabling it causes gatekeeper and its resources to be deployed on the user cluster. By default it is disabled. |
| `serviceAccount` _[ServiceAccountSettings](#serviceaccountsettings)_ | ServiceAccount contains service account related settings for the kube-apiserver of user cluster. |
| `mla` _[MLASettings](#mlasettings)_ | MLA contains monitoring, logging and alerting related settings for the user cluster. |
| `containerRuntime` _string_ | ContainerRuntime to use, i.e. Docker or containerd. By default containerd will be used. |
| `cniPlugin` _[CNIPluginSettings](#cnipluginsettings)_ | CNIPlugin contains the spec of the CNI plugin to be installed in the cluster. |


[Back to top](#top)



### ClusterStatus



ClusterStatus stores status information about a cluster.

_Appears in:_
- [Cluster](#cluster)

| Field | Description |
| --- | --- |
| `lastUpdated` _[Time](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#time-v1-meta)_ |  |
| `extendedHealth` _[ExtendedClusterHealth](#extendedclusterhealth)_ | ExtendedHealth exposes information about the current health state. Extends standard health status for new states. |
| `lastProviderReconciliation` _[Time](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#time-v1-meta)_ | LastProviderReconciliation is the time when the cloud provider resources were last fully reconciled (during normal cluster reconciliation, KKP does not re-check things like security groups, networks etc.). |
| `kubermaticVersion` _string_ | KubermaticVersion is the current kubermatic version in a cluster. |
| `rootCA` _[KeyCert](#keycert)_ | Deprecated |
| `apiserverCert` _[KeyCert](#keycert)_ | Deprecated |
| `kubeletCert` _[KeyCert](#keycert)_ | Deprecated |
| `apiserverSSHKey` _[RSAKeys](#rsakeys)_ | Deprecated |
| `serviceAccountKey` _integer array_ | Deprecated |
| `namespaceName` _string_ | NamespaceName defines the namespace the control plane of this cluster is deployed in |
| `userName` _string_ | UserName contains the name of the owner of this cluster |
| `userEmail` _string_ | UserEmail contains the email of the owner of this cluster |
| `errorReason` _[ClusterStatusError](#clusterstatuserror)_ | ErrorReason contains a error reason in case the controller encountered an error. Will be reset if the error was resolved |
| `errorMessage` _string_ | ErrorMessage contains a default error message in case the controller encountered an error. Will be reset if the error was resolved |
| `conditions` _[ClusterCondition](#clustercondition) array_ | Conditions contains conditions the cluster is in, its primary use case is status signaling between controllers or between controllers and the API |
| `cloudMigrationRevision` _integer_ | CloudMigrationRevision describes the latest version of the migration that has been done It is used to avoid redundant and potentially costly migrations |
| `inheritedLabels` _object (keys:string, values:string)_ | InheritedLabels are labels the cluster inherited from the project. They are read-only for users. |


[Back to top](#top)



### ClusterStatusError

_Underlying type:_ `string`



_Appears in:_
- [ClusterStatus](#clusterstatus)



### ClusterTemplate



ClusterTemplate is the object representing a cluster template.

_Appears in:_
- [ClusterTemplateList](#clustertemplatelist)

| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `ClusterTemplate`
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `clusterLabels` _object (keys:string, values:string)_ |  |
| `inheritedClusterLabels` _object (keys:string, values:string)_ |  |
| `credential` _string_ |  |
| `userSSHKeys` _[ClusterTemplateSSHKey](#clustertemplatesshkey) array_ |  |
| `spec` _[ClusterSpec](#clusterspec)_ |  |


[Back to top](#top)



### ClusterTemplateInstance



ClusterTemplateInstance is the object representing a cluster template instance.

_Appears in:_
- [ClusterTemplateInstanceList](#clustertemplateinstancelist)

| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `ClusterTemplateInstance`
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[ClusterTemplateInstanceSpec](#clustertemplateinstancespec)_ |  |


[Back to top](#top)



### ClusterTemplateInstanceList



ClusterTemplateInstanceList specifies a list of cluster template instances



| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `ClusterTemplateInstanceList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[ClusterTemplateInstance](#clustertemplateinstance)_ |  |


[Back to top](#top)



### ClusterTemplateInstanceSpec



ClusterTemplateInstanceSpec specifies the data for cluster instances.

_Appears in:_
- [ClusterTemplateInstance](#clustertemplateinstance)

| Field | Description |
| --- | --- |
| `projectID` _string_ |  |
| `clusterTemplateID` _string_ |  |
| `clusterTemplateName` _string_ |  |
| `replicas` _integer_ |  |


[Back to top](#top)



### ClusterTemplateList



ClusterTemplateList specifies a list of cluster templates



| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `ClusterTemplateList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[ClusterTemplate](#clustertemplate)_ |  |


[Back to top](#top)



### ClusterTemplateSSHKey



ClusterTemplateSSHKey is the object for holding SSH key

_Appears in:_
- [ClusterTemplate](#clustertemplate)

| Field | Description |
| --- | --- |
| `name` _string_ |  |
| `id` _string_ |  |


[Back to top](#top)



### ComponentSettings





_Appears in:_
- [ClusterSpec](#clusterspec)
- [SeedSpec](#seedspec)

| Field | Description |
| --- | --- |
| `apiserver` _[APIServerSettings](#apiserversettings)_ |  |
| `controllerManager` _[ControllerSettings](#controllersettings)_ |  |
| `scheduler` _[ControllerSettings](#controllersettings)_ |  |
| `etcd` _[EtcdStatefulSetSettings](#etcdstatefulsetsettings)_ |  |
| `prometheus` _[StatefulSetSettings](#statefulsetsettings)_ |  |


[Back to top](#top)



### Constraint



Constraint specifies a kubermatic wrapper for the gatekeeper constraints.

_Appears in:_
- [ConstraintList](#constraintlist)

| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `Constraint`
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[ConstraintSpec](#constraintspec)_ |  |


[Back to top](#top)



### ConstraintList



ConstraintList specifies a list of constraints



| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `ConstraintList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[Constraint](#constraint)_ |  |


[Back to top](#top)



### ConstraintSelector



ConstraintSelector is the object holding the cluster selection filters

_Appears in:_
- [ConstraintSpec](#constraintspec)

| Field | Description |
| --- | --- |
| `providers` _string array_ | Providers is a list of cloud providers to which the Constraint applies to. Empty means all providers are selected. |
| `labelSelector` _[LabelSelector](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#labelselector-v1-meta)_ | LabelSelector selects the Clusters to which the Constraint applies based on their labels |


[Back to top](#top)



### ConstraintSpec



ConstraintSpec specifies the data for the constraint.

_Appears in:_
- [Constraint](#constraint)

| Field | Description |
| --- | --- |
| `constraintType` _string_ | ConstraintType specifies the type of gatekeeper constraint that the constraint applies to |
| `disabled` _boolean_ | Disabled  is the flag for disabling OPA constraints |
| `match` _[Match](#match)_ | Match contains the constraint to resource matching data |
| `parameters` _object (keys:string, values:integer array)_ | Parameters specifies the parameters used by the constraint template REGO. It supports both the legacy rawJSON parameters, in which all the parameters are set in a JSON string, and regular parameters like in Gatekeeper Constraints. If rawJSON is set, during constraint syncing to the user cluster, the other parameters are ignored Example with rawJSON parameters: 
 parameters:   rawJSON: '{"labels":["gatekeeper"]}' 
 And with regular parameters: 
 parameters:   labels: ["gatekeeper"] |
| `selector` _[ConstraintSelector](#constraintselector)_ | Selector specifies the cluster selection filters |


[Back to top](#top)



### ConstraintTemplate



ConstraintTemplate is the object representing a kubermatic wrapper for a gatekeeper constraint template.

_Appears in:_
- [ConstraintTemplateList](#constrainttemplatelist)

| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `ConstraintTemplate`
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[ConstraintTemplateSpec](#constrainttemplatespec)_ |  |


[Back to top](#top)



### ConstraintTemplateList



ConstraintTemplateList specifies a list of constraint templates



| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `ConstraintTemplateList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[ConstraintTemplate](#constrainttemplate)_ |  |


[Back to top](#top)



### ConstraintTemplateSelector



ConstraintTemplateSelector is the object holding the cluster selection filters

_Appears in:_
- [ConstraintTemplateSpec](#constrainttemplatespec)

| Field | Description |
| --- | --- |
| `providers` _string array_ | Providers is a list of cloud providers to which the Constraint Template applies to. Empty means all providers are selected. |
| `labelSelector` _[LabelSelector](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#labelselector-v1-meta)_ | LabelSelector selects the Clusters to which the Constraint Template applies based on their labels |


[Back to top](#top)



### ConstraintTemplateSpec



ConstraintTemplateSpec is the object representing the gatekeeper constraint template spec and kubermatic related spec

_Appears in:_
- [ConstraintTemplate](#constrainttemplate)

| Field | Description |
| --- | --- |
| `crd` _[CRD](#crd)_ |  |
| `targets` _[Target](#target) array_ |  |
| `selector` _[ConstraintTemplateSelector](#constrainttemplateselector)_ |  |


[Back to top](#top)



### ControllerSettings





_Appears in:_
- [ComponentSettings](#componentsettings)

| Field | Description |
| --- | --- |
| `DeploymentSettings` _[DeploymentSettings](#deploymentsettings)_ |  |
| `leaderElection` _[LeaderElectionSettings](#leaderelectionsettings)_ |  |


[Back to top](#top)



### CustomLink





_Appears in:_
- [SettingSpec](#settingspec)

| Field | Description |
| --- | --- |
| `label` _string_ |  |
| `url` _string_ |  |
| `icon` _string_ |  |
| `location` _string_ |  |


[Back to top](#top)





### Datacenter





_Appears in:_
- [SeedSpec](#seedspec)

| Field | Description |
| --- | --- |
| `country` _string_ | Optional: Country of the seed as ISO-3166 two-letter code, e.g. DE or UK. For informational purposes in the Kubermatic dashboard only. |
| `location` _string_ | Optional: Detailed location of the cluster, like "Hamburg" or "Datacenter 7". For informational purposes in the Kubermatic dashboard only. |
| `node` _[NodeSettings](#nodesettings)_ | Node holds node-specific settings, like e.g. HTTP proxy, Docker registries and the like. Proxy settings are inherited from the seed if not specified here. |
| `spec` _[DatacenterSpec](#datacenterspec)_ | Spec describes the cloud provider settings used to manage resources in this datacenter. Exactly one cloud provider must be defined. |


[Back to top](#top)



### DatacenterSpec



DatacenterSpec mutually points to provider datacenter spec

_Appears in:_
- [Datacenter](#datacenter)

| Field | Description |
| --- | --- |
| `digitalocean` _[DatacenterSpecDigitalocean](#datacenterspecdigitalocean)_ |  |
| `bringyourown` _[DatacenterSpecBringYourOwn](#datacenterspecbringyourown)_ | BringYourOwn contains settings for clusters using manually created nodes via kubeadm. |
| `aws` _[DatacenterSpecAWS](#datacenterspecaws)_ |  |
| `azure` _[DatacenterSpecAzure](#datacenterspecazure)_ |  |
| `openstack` _[DatacenterSpecOpenstack](#datacenterspecopenstack)_ |  |
| `packet` _[DatacenterSpecPacket](#datacenterspecpacket)_ |  |
| `hetzner` _[DatacenterSpecHetzner](#datacenterspechetzner)_ |  |
| `vsphere` _[DatacenterSpecVSphere](#datacenterspecvsphere)_ |  |
| `gcp` _[DatacenterSpecGCP](#datacenterspecgcp)_ |  |
| `kubevirt` _[DatacenterSpecKubevirt](#datacenterspeckubevirt)_ |  |
| `alibaba` _[DatacenterSpecAlibaba](#datacenterspecalibaba)_ |  |
| `anexia` _[DatacenterSpecAnexia](#datacenterspecanexia)_ |  |
| `fake` _[DatacenterSpecFake](#datacenterspecfake)_ |  |
| `requiredEmails` _