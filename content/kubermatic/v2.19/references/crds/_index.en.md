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



### AKS





_Appears in:_
- [PresetSpec](#presetspec)

| Field | Description |
| --- | --- |
| `ProviderPreset` _[ProviderPreset](#providerpreset)_ |  |
| `tenantID` _string_ |  |
| `subscriptionID` _string_ |  |
| `clientID` _string_ |  |
| `clientSecret` _string_ |  |


[Back to top](#top)



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
| `ProviderPreset` _[ProviderPreset](#providerpreset)_ |  |
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
| `nodePortsAllowedIPRange` _string_ |  |
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
| `ProviderPreset` _[ProviderPreset](#providerpreset)_ |  |
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
| `ProviderPreset` _[ProviderPreset](#providerpreset)_ |  |
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
| `ProviderPreset` _[ProviderPreset](#providerpreset)_ |  |
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
| `nodePortsAllowedIPRange` _string_ |  |
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
| `providerName` _string_ | ProviderName is the name of the cloud provider used for this cluster. This must match the given provider spec (e.g. if the providerName is "aws", then the AWSCloudSpec must be set) |
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
| `nutanix` _[NutanixCloudSpec](#nutanixcloudspec)_ |  |


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
| `debugLog` _boolean_ | DebugLog enables more verbose logging by KKP's usercluster-controller-manager. |
| `componentsOverride` _[ComponentSettings](#componentsettings)_ | Optional component specific overrides |
| `oidc` _[OIDCSettings](#oidcsettings)_ |  |
| `features` _object (keys:string, values:boolean)_ | Feature flags This unfortunately has to be a string map, because we use it in templating and that can not cope with string types |
| `updateWindow` _[UpdateWindow](#updatewindow)_ |  |
| `usePodSecurityPolicyAdmissionPlugin` _boolean_ |  |
| `usePodNodeSelectorAdmissionPlugin` _boolean_ |  |
| `useEventRateLimitAdmissionPlugin` _boolean_ |  |
| `enableUserSSHKeyAgent` _boolean_ | EnableUserSSHKeyAgent control whether the UserSSHKeyAgent will be deployed in the user cluster or not. If it was enabled, the agent will be deployed and used to sync the user ssh keys, that the user attach to the created cluster. If the agent was disabled, it won't be deployed in the user cluster, thus after the cluster creation any attached ssh keys won't be synced to the worker nodes. Once the agent is enabled/disabled it cannot be changed after the cluster is being created. |
| `enableOperatingSystemManager` _boolean_ | EnableOperatingSystemManager enables OSM which in-turn is responsible for creating and managing worker node configuration |
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
| `nodePortProxyEnvoy` _[NodeportProxyComponent](#nodeportproxycomponent)_ |  |


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
| `nutanix` _[DatacenterSpecNutanix](#datacenterspecnutanix)_ | Nutanix is experimental and unsupported |
| `requiredEmails` _string array_ | Optional: When defined, only users with an e-mail address on the given domains can make use of this datacenter. You can define multiple domains, e.g. "example.com", one of which must match the email domain exactly (i.e. "example.com" will not match "user@test.example.com"). |
| `enforceAuditLogging` _boolean_ | EnforceAuditLogging enforces audit logging on every cluster within the DC, ignoring cluster-specific settings. |
| `enforcePodSecurityPolicy` _boolean_ | EnforcePodSecurityPolicy enforces pod security policy plugin on every clusters within the DC, ignoring cluster-specific settings |
| `providerReconciliationInterval` _[Duration](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#duration-v1-meta)_ | ProviderReconciliationInterval is the time that must have passed since a Cluster's status.lastProviderReconciliation to make the cliuster controller perform an in-depth provider reconciliation, where for example missing security groups will be reconciled. Setting this too low can cause rate limits by the cloud provider, setting this too high means that *if* a resource at a cloud provider is removed/changed outside of KKP, it will take this long to fix it. |


[Back to top](#top)



### DatacenterSpecAWS



DatacenterSpecAWS describes an AWS datacenter

_Appears in:_
- [DatacenterSpec](#datacenterspec)

| Field | Description |
| --- | --- |
| `region` _string_ | The AWS region to use, e.g. "us-east-1". For a list of available regions, see https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html |
| `images` _object (keys:OperatingSystem, values:string)_ | List of AMIs to use for a given operating system. This gets defaulted by querying for the latest AMI for the given distribution when machines are created, so under normal circumstances it is not necessary to define the AMIs statically. |


[Back to top](#top)



### DatacenterSpecAlibaba



DatacenterSpecAlibaba describes a alibaba datacenter.

_Appears in:_
- [DatacenterSpec](#datacenterspec)

| Field | Description |
| --- | --- |
| `region` _string_ | Region to use, for a full list of regions see https://www.alibabacloud.com/help/doc-detail/40654.htm |


[Back to top](#top)



### DatacenterSpecAnexia



DatacenterSpecAnexia describes a anexia datacenter.

_Appears in:_
- [DatacenterSpec](#datacenterspec)

| Field | Description |
| --- | --- |
| `locationID` _string_ | LocationID the location of the region |


[Back to top](#top)



### DatacenterSpecAzure



DatacenterSpecAzure describes an Azure cloud datacenter

_Appears in:_
- [DatacenterSpec](#datacenterspec)

| Field | Description |
| --- | --- |
| `location` _string_ | Region to use, for example "westeurope". A list of available regions can be found at https://azure.microsoft.com/en-us/global-infrastructure/locations/ |


[Back to top](#top)



### DatacenterSpecBringYourOwn



DatacenterSpecBringYourOwn describes a datacenter our of bring your own nodes

_Appears in:_
- [DatacenterSpec](#datacenterspec)



### DatacenterSpecDigitalocean



DatacenterSpecDigitalocean describes a DigitalOcean datacenter

_Appears in:_
- [DatacenterSpec](#datacenterspec)

| Field | Description |
| --- | --- |
| `region` _string_ | Datacenter location, e.g. "ams3". A list of existing datacenters can be found at https://www.digitalocean.com/docs/platform/availability-matrix/ |


[Back to top](#top)



### DatacenterSpecGCP



DatacenterSpecGCP describes a GCP datacenter

_Appears in:_
- [DatacenterSpec](#datacenterspec)

| Field | Description |
| --- | --- |
| `region` _string_ | Region to use, for example "europe-west3", for a full list of regions see https://cloud.google.com/compute/docs/regions-zones/ |
| `zoneSuffixes` _string array_ | List of enabled zones, for example [a, c]. See the link above for the available zones in your chosen region. |
| `regional` _boolean_ | Optional: Regional clusters spread their resources across multiple availability zones. Refer to the official documentation for more details on this: https://cloud.google.com/kubernetes-engine/docs/concepts/regional-clusters |


[Back to top](#top)



### DatacenterSpecHetzner



DatacenterSpecHetzner describes a Hetzner cloud datacenter

_Appears in:_
- [DatacenterSpec](#datacenterspec)

| Field | Description |
| --- | --- |
| `datacenter` _string_ | Datacenter location, e.g. "nbg1-dc3". A list of existing datacenters can be found at https://wiki.hetzner.de/index.php/Rechenzentren_und_Anbindung/en |
| `network` _string_ | Network is the pre-existing Hetzner network in which the machines are running. While machines can be in multiple networks, a single one must be chosen for the HCloud CCM to work. |
| `location` _string_ | Optional: Detailed location of the datacenter, like "Hamburg" or "Datacenter 7". For informational purposes only. |


[Back to top](#top)



### DatacenterSpecKubevirt



DatacenterSpecKubevirt describes a kubevirt datacenter.

_Appears in:_
- [DatacenterSpec](#datacenterspec)

| Field | Description |
| --- | --- |
| `dnsPolicy` _string_ | DNSPolicy represents the dns policy for the pod. Valid values are 'ClusterFirstWithHostNet', 'ClusterFirst', 'Default' or 'None'. Defaults to "ClusterFirst". DNS parameters given in DNSConfig will be merged with the policy selected with DNSPolicy. |
| `dnsConfig` _[PodDNSConfig](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#poddnsconfig-v1-core)_ | DNSConfig represents the DNS parameters of a pod. Parameters specified here will be merged to the generated DNS configuration based on DNSPolicy. |


[Back to top](#top)



### DatacenterSpecNutanix



DatacenterSpecNutanix describes a Nutanix datacenter. NUTANIX IMPLEMENTATION IS EXPERIMENTAL AND UNSUPPORTED.

_Appears in:_
- [DatacenterSpec](#datacenterspec)

| Field | Description |
| --- | --- |
| `endpoint` _string_ | Endpoint to use for accessing Nutanix Prism Central. No protocol or port should be passed, for example "nutanix.example.com" or "10.0.0.1" |
| `port` _integer_ | Optional: Port to use when connecting to the Nutanix Prism Central endpoint (defaults to 9440) |
| `allowInsecure` _boolean_ | Optional: AllowInsecure allows to disable the TLS certificate check against the endpoint (defaults to false) |
| `images` _object (keys:OperatingSystem, values:string)_ | Images to use for each supported operating system |


[Back to top](#top)



### DatacenterSpecOpenstack



DatacenterSpecOpenstack describes an OpenStack datacenter

_Appears in:_
- [DatacenterSpec](#datacenterspec)

| Field | Description |
| --- | --- |
| `authURL` _string_ |  |
| `availabilityZone` _string_ |  |
| `region` _string_ |  |
| `ignoreVolumeAZ` _boolean_ | Optional |
| `enforceFloatingIP` _boolean_ | Optional |
| `dnsServers` _string array_ | Used for automatic network creation |
| `images` _object (keys:OperatingSystem, values:string)_ | Images to use for each supported operating system. |
| `manageSecurityGroups` _boolean_ | Optional: Gets mapped to the "manage-security-groups" setting in the cloud config. See https://kubernetes.io/docs/concepts/cluster-administration/cloud-providers/#load-balancer This setting defaults to true. |
| `useOctavia` _boolean_ | Optional: Gets mapped to the "use-octavia" setting in the cloud config. use-octavia is enabled by default in CCM since v1.17.0, and disabled by default with the in-tree cloud provider. |
| `trustDevicePath` _boolean_ | Optional: Gets mapped to the "trust-device-path" setting in the cloud config. See https://kubernetes.io/docs/concepts/cluster-administration/cloud-providers/#block-storage This setting defaults to false. |
| `nodeSizeRequirements` _[OpenstackNodeSizeRequirements](#openstacknodesizerequirements)_ |  |
| `enabledFlavors` _string array_ | Optional: List of enabled flavors for the given datacenter |


[Back to top](#top)



### DatacenterSpecPacket



DatacenterSpecPacket describes a Packet datacenter

_Appears in:_
- [DatacenterSpec](#datacenterspec)

| Field | Description |
| --- | --- |
| `facilities` _string array_ | The list of enabled facilities, for example "ams1", for a full list of available facilities see https://support.packet.com/kb/articles/data-centers |


[Back to top](#top)



### DatacenterSpecVSphere



DatacenterSpecVSphere describes a vSphere datacenter

_Appears in:_
- [DatacenterSpec](#datacenterspec)

| Field | Description |
| --- | --- |
| `endpoint` _string_ | Endpoint URL to use, including protocol, for example "https://vcenter.example.com". |
| `allowInsecure` _boolean_ | If set to true, disables the TLS certificate check against the endpoint. |
| `datastore` _string_ | The default Datastore to be used for provisioning volumes using storage classes/dynamic provisioning and for storing virtual machine files in case no `Datastore` or `DatastoreCluster` is provided at Cluster level. |
| `datacenter` _string_ | The name of the datacenter to use. |
| `cluster` _string_ | Optional: The name of the vSphere cluster to use. Cluster is deprecated and may be removed in future releases as it is currently ignored. The cluster hosting the VMs will be the same VM used as a template is located. |
| `storagePolicy` _string_ | The name of the storage policy to use for the storage class created in the user cluster. |
| `rootPath` _string_ | Optional: The root path for cluster specific VM folders. Each cluster gets its own folder below the root folder. Must be the FQDN (for example "/datacenter-1/vm/all-kubermatic-vms-in-here") and defaults to the root VM folder: "/datacenter-1/vm" |
| `templates` _object (keys:OperatingSystem, values:string)_ | A list of VM templates to use for a given operating system. You must define at least one template. See: https://github.com/kubermatic/machine-controller/blob/master/docs/vsphere.md#template-vms-preparation |
| `infraManagementUser` _[VSphereCredentials](#vspherecredentials)_ | Optional: Infra management user is the user that will be used for everything except the cloud provider functionality, which will still use the credentials passed in via the Kubermatic dashboard/API. |


[Back to top](#top)



### DeploymentSettings





_Appears in:_
- [APIServerSettings](#apiserversettings)
- [ControllerSettings](#controllersettings)

| Field | Description |
| --- | --- |
| `replicas` _integer_ |  |
| `resources` _[ResourceRequirements](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#resourcerequirements-v1-core)_ |  |
| `tolerations` _[Toleration](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#toleration-v1-core) array_ |  |


[Back to top](#top)



### Digitalocean





_Appears in:_
- [PresetSpec](#presetspec)

| Field | Description |
| --- | --- |
| `ProviderPreset` _[ProviderPreset](#providerpreset)_ |  |
| `token` _string_ | Token is used to authenticate with the DigitalOcean API. |


[Back to top](#top)



### DigitaloceanCloudSpec



DigitaloceanCloudSpec specifies access data to DigitalOcean.

_Appears in:_
- [CloudSpec](#cloudspec)

| Field | Description |
| --- | --- |
| `credentialsReference` _GlobalSecretKeySelector_ |  |
| `token` _string_ |  |


[Back to top](#top)



### EKS





_Appears in:_
- [PresetSpec](#presetspec)

| Field | Description |
| --- | --- |
| `ProviderPreset` _[ProviderPreset](#providerpreset)_ |  |
| `accessKeyID` _string_ |  |
| `secretAccessKey` _string_ |  |
| `region` _string_ |  |


[Back to top](#top)



### EtcdBackupConfig



EtcdBackupConfig specifies a add-on

_Appears in:_
- [EtcdBackupConfigList](#etcdbackupconfiglist)

| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `EtcdBackupConfig`
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[EtcdBackupConfigSpec](#etcdbackupconfigspec)_ |  |
| `status` _[EtcdBackupConfigStatus](#etcdbackupconfigstatus)_ |  |


[Back to top](#top)



### EtcdBackupConfigCondition





_Appears in:_
- [EtcdBackupConfigStatus](#etcdbackupconfigstatus)

| Field | Description |
| --- | --- |
| `type` _[EtcdBackupConfigConditionType](#etcdbackupconfigconditiontype)_ | Type of EtcdBackupConfig condition. |
| `status` _[ConditionStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#conditionstatus-v1-core)_ | Status of the condition, one of True, False, Unknown. |
| `lastHeartbeatTime` _[Time](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#time-v1-meta)_ | Last time we got an update on a given condition. |
| `lastTransitionTime` _[Time](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#time-v1-meta)_ | Last time the condition transit from one status to another. |
| `reason` _string_ | (brief) reason for the condition's last transition. |
| `message` _string_ | Human readable message indicating details about last transition. |


[Back to top](#top)



### EtcdBackupConfigConditionType

_Underlying type:_ `string`

EtcdBackupConfigConditionType is used to indicate the type of a EtcdBackupConfig condition. For all condition types, the `true` value must indicate success. All condition types must be registered within the `AllClusterConditionTypes` variable.

_Appears in:_
- [EtcdBackupConfigCondition](#etcdbackupconfigcondition)



### EtcdBackupConfigList



EtcdBackupConfigList is a list of etcd backup configs



| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `EtcdBackupConfigList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[EtcdBackupConfig](#etcdbackupconfig)_ |  |


[Back to top](#top)



### EtcdBackupConfigSpec



EtcdBackupConfigSpec specifies details of an etcd backup

_Appears in:_
- [EtcdBackupConfig](#etcdbackupconfig)

| Field | Description |
| --- | --- |
| `name` _string_ | Name defines the name of the backup The name of the backup file in S3 will be <cluster>-<backup name> If a schedule is set (see below), -<timestamp> will be appended. |
| `cluster` _[ObjectReference](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#objectreference-v1-core)_ | Cluster is the reference to the cluster whose etcd will be backed up |
| `schedule` _string_ | Schedule is a cron expression defining when to perform the backup. If not set, the backup is performed exactly once, immediately. |
| `keep` _integer_ | Keep is the number of backups to keep around before deleting the oldest one If not set, defaults to DefaultKeptBackupsCount. Only used if Schedule is set. |
| `destination` _string_ | Destination indicates where the backup will be stored. The destination name should correspond to a destination in the cluster's Seed.Spec.EtcdBackupRestore. If empty, it will use the legacy destination in Seed.Spec.BackupRestore |


[Back to top](#top)



### EtcdBackupConfigStatus





_Appears in:_
- [EtcdBackupConfig](#etcdbackupconfig)

| Field | Description |
| --- | --- |
| `currentBackups` _[BackupStatus](#backupstatus) array_ | CurrentBackups tracks the creation and deletion progress of all backups managed by the EtcdBackupConfig |
| `conditions` _[EtcdBackupConfigCondition](#etcdbackupconfigcondition) array_ | Conditions contains conditions of the EtcdBackupConfig |
| `cleanupRunning` _boolean_ | If the controller was configured with a cleanupContainer, CleanupRunning keeps track of the corresponding job |


[Back to top](#top)



### EtcdBackupRestore



EtcdBackupRestore holds the configuration of the automatic backup restores

_Appears in:_
- [SeedSpec](#seedspec)

| Field | Description |
| --- | --- |
| `destinations` _object (keys:string, values:[BackupDestination](#backupdestination))_ | Destinations stores all the possible destinations where the backups for the Seed can be stored. If not empty, it enables automatic backup and restore for the seed. |
| `defaultDestination` _string_ | DefaultDestination Optional setting which marks the default destination that will be used for the default etcd backup config which is created for every user cluster. If not set, the default etcd backup config won't be created (unless the legacy Seed.Spec.BackupRestore is used). Has to correspond to a destination in Destinations. If removed, it removes the related default etcd backup configs. |


[Back to top](#top)



### EtcdRestore



EtcdRestore specifies a add-on

_Appears in:_
- [EtcdRestoreList](#etcdrestorelist)

| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `EtcdRestore`
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[EtcdRestoreSpec](#etcdrestorespec)_ |  |
| `status` _[EtcdRestoreStatus](#etcdrestorestatus)_ |  |


[Back to top](#top)



### EtcdRestoreList



EtcdRestoreList is a list of etcd restores



| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `EtcdRestoreList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[EtcdRestore](#etcdrestore)_ |  |


[Back to top](#top)



### EtcdRestoreSpec



EtcdRestoreSpec specifies details of an etcd restore

_Appears in:_
- [EtcdRestore](#etcdrestore)

| Field | Description |
| --- | --- |
| `name` _string_ | Name defines the name of the restore The name of the restore file in S3 will be <cluster>-<restore name> If a schedule is set (see below), -<timestamp> will be appended. |
| `cluster` _[ObjectReference](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#objectreference-v1-core)_ | Cluster is the reference to the cluster whose etcd will be backed up |
| `backupName` _string_ | BackupName is the name of the backup to restore from |
| `backupDownloadCredentialsSecret` _string_ | BackupDownloadCredentialsSecret is the name of a secret in the cluster-xxx namespace containing credentials needed to download the backup |
| `destination` _string_ | Destination indicates where the backup was stored. The destination name should correspond to a destination in the cluster's Seed.Spec.EtcdBackupRestore. If empty, it will use the legacy destination configured in Seed.Spec.BackupRestore |


[Back to top](#top)



### EtcdRestoreStatus





_Appears in:_
- [EtcdRestore](#etcdrestore)

| Field | Description |
| --- | --- |
| `phase` _EtcdRestorePhase_ |  |
| `restoreTime` _[Time](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#time-v1-meta)_ |  |


[Back to top](#top)



### EtcdStatefulSetSettings





_Appears in:_
- [ComponentSettings](#componentsettings)

| Field | Description |
| --- | --- |
| `clusterSize` _integer_ |  |
| `storageClass` _string_ |  |
| `resources` _[ResourceRequirements](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#resourcerequirements-v1-core)_ |  |
| `tolerations` _[Toleration](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#toleration-v1-core)_ |  |


[Back to top](#top)



### EventRateLimitConfig





_Appears in:_
- [ClusterSpec](#clusterspec)

| Field | Description |
| --- | --- |
| `server` _[EventRateLimitConfigItem](#eventratelimitconfigitem)_ |  |
| `namespace` _[EventRateLimitConfigItem](#eventratelimitconfigitem)_ |  |
| `user` _[EventRateLimitConfigItem](#eventratelimitconfigitem)_ |  |
| `sourceAndObject` _[EventRateLimitConfigItem](#eventratelimitconfigitem)_ |  |


[Back to top](#top)



### EventRateLimitConfigItem





_Appears in:_
- [EventRateLimitConfig](#eventratelimitconfig)

| Field | Description |
| --- | --- |
| `qps` _integer_ |  |
| `burst` _integer_ |  |
| `cacheSize` _integer_ |  |


[Back to top](#top)





### ExposeStrategy

_Underlying type:_ `string`

ExposeStrategy is the strategy to expose the cluster with.

_Appears in:_
- [ClusterSpec](#clusterspec)
- [KubermaticConfigurationSpec](#kubermaticconfigurationspec)
- [SeedSpec](#seedspec)



### ExtendedClusterHealth



ExtendedClusterHealth stores health information of a cluster.

_Appears in:_
- [ClusterStatus](#clusterstatus)

| Field | Description |
| --- | --- |
| `apiserver` _[HealthStatus](#healthstatus)_ |  |
| `scheduler` _[HealthStatus](#healthstatus)_ |  |
| `controller` _[HealthStatus](#healthstatus)_ |  |
| `machineController` _[HealthStatus](#healthstatus)_ |  |
| `etcd` _[HealthStatus](#healthstatus)_ |  |
| `openvpn` _[HealthStatus](#healthstatus)_ |  |
| `cloudProviderInfrastructure` _[HealthStatus](#healthstatus)_ |  |
| `userClusterControllerManager` _[HealthStatus](#healthstatus)_ |  |
| `gatekeeperController` _[HealthStatus](#healthstatus)_ |  |
| `gatekeeperAudit` _[HealthStatus](#healthstatus)_ |  |
| `monitoring` _[HealthStatus](#healthstatus)_ |  |
| `logging` _[HealthStatus](#healthstatus)_ |  |
| `alertmanagerConfig` _[HealthStatus](#healthstatus)_ |  |
| `mlaGateway` _[HealthStatus](#healthstatus)_ |  |


[Back to top](#top)



### ExternalCluster



ExternalCluster is the object representing an external kubernetes cluster.

_Appears in:_
- [ExternalClusterList](#externalclusterlist)

| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `ExternalCluster`
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[ExternalClusterSpec](#externalclusterspec)_ |  |


[Back to top](#top)



### ExternalClusterAKSCloudSpec





_Appears in:_
- [ExternalClusterCloudSpec](#externalclustercloudspec)

| Field | Description |
| --- | --- |
| `name` _string_ |  |
| `tenantID` _string_ |  |
| `subscriptionID` _string_ |  |
| `clientID` _string_ |  |
| `clientSecret` _string_ |  |
| `resourceGroup` _string_ |  |
| `credentialsReference` _[GlobalSecretKeySelector](#globalsecretkeyselector)_ |  |


[Back to top](#top)



### ExternalClusterCloudSpec



ExternalClusterCloudSpec mutually stores access data to a cloud provider.

_Appears in:_
- [ExternalClusterSpec](#externalclusterspec)

| Field | Description |
| --- | --- |
| `gke` _[ExternalClusterGKECloudSpec](#externalclustergkecloudspec)_ |  |
| `eks` _[ExternalClusterEKSCloudSpec](#externalclusterekscloudspec)_ |  |
| `aks` _[ExternalClusterAKSCloudSpec](#externalclusterakscloudspec)_ |  |


[Back to top](#top)



### ExternalClusterEKSCloudSpec





_Appears in:_
- [ExternalClusterCloudSpec](#externalclustercloudspec)

| Field | Description |
| --- | --- |
| `name` _string_ |  |
| `accessKeyID` _string_ |  |
| `secretAccessKey` _string_ |  |
| `credentialsReference` _[GlobalSecretKeySelector](#globalsecretkeyselector)_ |  |
| `region` _string_ |  |


[Back to top](#top)



### ExternalClusterGKECloudSpec





_Appears in:_
- [ExternalClusterCloudSpec](#externalclustercloudspec)

| Field | Description |
| --- | --- |
| `name` _string_ |  |
| `serviceAccount` _string_ |  |
| `credentialsReference` _[GlobalSecretKeySelector](#globalsecretkeyselector)_ |  |
| `zone` _string_ |  |


[Back to top](#top)



### ExternalClusterList



ExternalClusterList specifies a list of external kubernetes clusters



| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `ExternalClusterList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[ExternalCluster](#externalcluster)_ |  |


[Back to top](#top)



### ExternalClusterSpec



ExternalClusterSpec specifies the data for a new external kubernetes cluster.

_Appears in:_
- [ExternalCluster](#externalcluster)

| Field | Description |
| --- | --- |
| `humanReadableName` _string_ | HumanReadableName is the cluster name provided by the user |
| `kubeconfigReference` _[GlobalSecretKeySelector](#globalsecretkeyselector)_ |  |
| `cloudSpec` _[ExternalClusterCloudSpec](#externalclustercloudspec)_ |  |


[Back to top](#top)



### FakeCloudSpec



FakeCloudSpec specifies access data for a fake cloud.

_Appears in:_
- [CloudSpec](#cloudspec)

| Field | Description |
| --- | --- |
| `token` _string_ |  |


[Back to top](#top)



### GCP





_Appears in:_
- [PresetSpec](#presetspec)

| Field | Description |
| --- | --- |
| `ProviderPreset` _[ProviderPreset](#providerpreset)_ |  |
| `serviceAccount` _string_ |  |
| `network` _string_ |  |
| `subnetwork` _string_ |  |


[Back to top](#top)



### GCPCloudSpec



GCPCloudSpec specifies access data to GCP.

_Appears in:_
- [CloudSpec](#cloudspec)

| Field | Description |
| --- | --- |
| `credentialsReference` _[GlobalSecretKeySelector](#globalsecretkeyselector)_ |  |
| `serviceAccount` _string_ |  |
| `network` _string_ |  |
| `subnetwork` _string_ |  |
| `nodePortsAllowedIPRange` _string_ |  |


[Back to top](#top)



### GKE





_Appears in:_
- [PresetSpec](#presetspec)

| Field | Description |
| --- | --- |
| `ProviderPreset` _[ProviderPreset](#providerpreset)_ |  |
| `serviceAccount` _string_ |  |


[Back to top](#top)



### GroupVersionKind



GroupVersionKind unambiguously identifies a kind.  It doesn't anonymously include GroupVersion to avoid automatic coercion.  It doesn't use a GroupVersion to avoid custom marshalling

_Appears in:_
- [AddonSpec](#addonspec)

| Field | Description |
| --- | --- |
| `group` _string_ |  |
| `version` _string_ |  |


[Back to top](#top)



### HealthStatus

_Underlying type:_ `string`



_Appears in:_
- [ExtendedClusterHealth](#extendedclusterhealth)



### Hetzner





_Appears in:_
- [PresetSpec](#presetspec)

| Field | Description |
| --- | --- |
| `ProviderPreset` _[ProviderPreset](#providerpreset)_ |  |
| `token` _string_ | Token is used to authenticate with the Hetzner API. |
| `network` _string_ | Network is the pre-existing Hetzner network in which the machines are running. While machines can be in multiple networks, a single one must be chosen for the HCloud CCM to work. If this is empty, the network configured on the datacenter will be used. |


[Back to top](#top)



### HetznerCloudSpec



HetznerCloudSpec specifies access data to hetzner cloud.

_Appears in:_
- [CloudSpec](#cloudspec)

| Field | Description |
| --- | --- |
| `credentialsReference` _[GlobalSecretKeySelector](#globalsecretkeyselector)_ |  |
| `token` _string_ | Token is used to authenticate with the Hetzner cloud API. |
| `network` _string_ | Network is the pre-existing Hetzner network in which the machines are running. While machines can be in multiple networks, a single one must be chosen for the HCloud CCM to work. If this is empty, the network configured on the datacenter will be used. |


[Back to top](#top)



### IPVSConfiguration



IPVSConfiguration contains ipvs-related configuration details for kube-proxy.

_Appears in:_
- [ClusterNetworkingConfig](#clusternetworkingconfig)

| Field | Description |
| --- | --- |
| `strictArp` _boolean_ | StrictArp configure arp_ignore and arp_announce to avoid answering ARP queries from kube-ipvs0 interface. defaults to true. |


[Back to top](#top)





### Incompatibility



Incompatibility represents a version incompatibility for a user cluster

_Appears in:_
- [KubermaticVersioningConfiguration](#kubermaticversioningconfiguration)

| Field | Description |
| --- | --- |
| `provider` _[ProviderType](#providertype)_ | Provider to which to apply the compatibility check |
| `version` _string_ | Version is the Kubernetes version that must be checked. Wildcards are allowed, e.g. "1.22.*". |
| `condition` _ConditionType_ | Condition is the cluster or datacenter condition that must be met to block a specific version |
| `operation` _OperationType_ | Operation is the operation triggering the compatibility check (CREATE or UPDATE) |


[Back to top](#top)



### KeyCert



KeyCert is a pair of key and cert.

_Appears in:_
- [ClusterStatus](#clusterstatus)

| Field | Description |
| --- | --- |
| `key` _integer array_ |  |
| `cert` _integer array_ |  |


[Back to top](#top)



### Kind



Kind specifies the resource Kind and APIGroup

_Appears in:_
- [Match](#match)

| Field | Description |
| --- | --- |
| `kinds` _string array_ | Kinds specifies the kinds of the resources |
| `apiGroups` _string array_ | APIGroups specifies the APIGroups of the resources |


[Back to top](#top)



### KubermaticAPIConfiguration



KubermaticAPIConfiguration configures the dashboard.

_Appears in:_
- [KubermaticConfigurationSpec](#kubermaticconfigurationspec)

| Field | Description |
| --- | --- |
| `dockerRepository` _string_ | DockerRepository is the repository containing the Kubermatic REST API image. |
| `accessibleAddons` _string array_ | AccessibleAddons is a list of addons that should be enabled in the API. |
| `pprofEndpoint` _string_ | PProfEndpoint controls the port the API should listen on to provide pprof data. This port is never exposed from the container and only available via port-forwardings. |
| `resources` _[ResourceRequirements](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#resourcerequirements-v1-core)_ | Resources describes the requested and maximum allowed CPU/memory usage. |
| `debugLog` _boolean_ | DebugLog enables more verbose logging. |
| `replicas` _integer_ | Replicas sets the number of pod replicas for the API deployment. |


[Back to top](#top)



### KubermaticAddonsConfiguration



KubermaticAddonConfiguration describes the addons for a given cluster runtime.

_Appears in:_
- [KubermaticUserClusterConfiguration](#kubermaticuserclusterconfiguration)

| Field | Description |
| --- | --- |
| `default` _string array_ | Default is the list of addons to be installed by default into each cluster. Mutually exclusive with "defaultManifests". |
| `defaultManifests` _string_ | DefaultManifests is a list of addon manifests to install into all clusters. Mutually exclusive with "default". |
| `dockerRepository` _string_ | DockerRepository is the repository containing the Docker image containing the possible addon manifests. |
| `dockerTagSuffix` _string_ | DockerTagSuffix is appended to the tag used for referring to the addons image. If left empty, the tag will be the KKP version (e.g. "v2.15.0"), with a suffix it becomes "v2.15.0-SUFFIX". |


[Back to top](#top)



### KubermaticAuthConfiguration



KubermaticAuthConfiguration defines keys and URLs for Dex.

_Appears in:_
- [KubermaticConfigurationSpec](#kubermaticconfigurationspec)

| Field | Description |
| --- | --- |
| `clientID` _string_ |  |
| `tokenIssuer` _string_ |  |
| `issuerRedirectURL` _string_ |  |
| `issuerClientID` _string_ |  |
| `issuerClientSecret` _string_ |  |
| `issuerCookieKey` _string_ |  |
| `serviceAccountKey` _string_ |  |
| `skipTokenIssuerTLSVerify` _boolean_ |  |


[Back to top](#top)



### KubermaticConfiguration



KubermaticConfiguration is the configuration required for running Kubermatic.

_Appears in:_
- [KubermaticConfigurationList](#kubermaticconfigurationlist)

| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `KubermaticConfiguration`
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[KubermaticConfigurationSpec](#kubermaticconfigurationspec)_ |  |


[Back to top](#top)



### KubermaticConfigurationList



KubermaticConfigurationList is a collection of KubermaticConfigurations.



| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `KubermaticConfigurationList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[KubermaticConfiguration](#kubermaticconfiguration)_ |  |


[Back to top](#top)



### KubermaticConfigurationSpec



KubermaticConfigurationSpec is the spec for a Kubermatic installation.

_Appears in:_
- [KubermaticConfiguration](#kubermaticconfiguration)

| Field | Description |
| --- | --- |
| `caBundle` _[TypedLocalObjectReference](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#typedlocalobjectreference-v1-core)_ | CABundle references a ConfigMap in the same namespace as the KubermaticConfiguration. This ConfigMap must contain a ca-bundle.pem with PEM-encoded certificates. This bundle automatically synchronized into each seed and each usercluster. APIGroup and Kind are currently ignored. |
| `imagePullSecret` _string_ | ImagePullSecret is used to authenticate against Docker registries. |
| `auth` _[KubermaticAuthConfiguration](#kubermaticauthconfiguration)_ | Auth defines keys and URLs for Dex. |
| `featureGates` _object (keys:string, values:boolean)_ | FeatureGates are used to optionally enable certain features. |
| `ui` _[KubermaticUIConfiguration](#kubermaticuiconfiguration)_ | UI configures the dashboard. |
| `api` _[KubermaticAPIConfiguration](#kubermaticapiconfiguration)_ | API configures the frontend REST API used by the dashboard. |
| `seedController` _[KubermaticSeedControllerConfiguration](#kubermaticseedcontrollerconfiguration)_ | SeedController configures the seed-controller-manager. |
| `masterController` _[KubermaticMasterControllerConfiguration](#kubermaticmastercontrollerconfiguration)_ | MasterController configures the master-controller-manager. |
| `userCluster` _[KubermaticUserClusterConfiguration](#kubermaticuserclusterconfiguration)_ | UserCluster configures various aspects of the user-created clusters. |
| `exposeStrategy` _[ExposeStrategy](#exposestrategy)_ | ExposeStrategy is the strategy to expose the cluster with. Note: The `seed_dns_overwrite` setting of a Seed's datacenter doesn't have any effect if this is set to LoadBalancerStrategy. |
| `ingress` _[KubermaticIngressConfiguration](#kubermaticingressconfiguration)_ | Ingress contains settings for making the API and UI accessible remotely. |
| `versions` _[KubermaticVersioningConfiguration](#kubermaticversioningconfiguration)_ | Versions configures the available and default Kubernetes versions and updates. |
| `verticalPodAutoscaler` _[KubermaticVPAConfiguration](#kubermaticvpaconfiguration)_ | VerticalPodAutoscaler configures the Kubernetes VPA integration. |
| `proxy` _[KubermaticProxyConfiguration](#kubermaticproxyconfiguration)_ | Proxy allows to configure Kubermatic to use proxies to talk to the world outside of its cluster. |


[Back to top](#top)



### KubermaticIngressConfiguration





_Appears in:_
- [KubermaticConfigurationSpec](#kubermaticconfigurationspec)

| Field | Description |
| --- | --- |
| `domain` _string_ | Domain is the base domain where the dashboard shall be available. Even with a disabled Ingress, this must always be a valid hostname. |
| `className` _string_ | ClassName is the Ingress resource's class name, used for selecting the appropriate ingress controller. |
| `disable` _boolean_ | Disable will prevent an Ingress from being created at all. This is mostly useful during testing. If the Ingress is disabled, the CertificateIssuer setting can also be left empty, as no Certificate resource will be created. |
| `certificateIssuer` _[TypedLocalObjectReference](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#typedlocalobjectreference-v1-core)_ | CertificateIssuer is the name of a cert-manager Issuer or ClusterIssuer (default) that will be used to acquire the certificate for the configured domain. To use a namespaced Issuer, set the Kind to "Issuer" and manually create the matching Issuer in Kubermatic's namespace. Setting an empty name disables the automatic creation of certificates and disables the TLS settings on the Kubermatic Ingress. |


[Back to top](#top)



### KubermaticMasterControllerConfiguration



KubermaticMasterControllerConfiguration configures the Kubermatic master controller-manager.

_Appears in:_
- [KubermaticConfigurationSpec](#kubermaticconfigurationspec)

| Field | Description |
| --- | --- |
| `dockerRepository` _string_ | DockerRepository is the repository containing the Kubermatic master-controller-manager image. |
| `projectsMigrator` _[KubermaticProjectsMigratorConfiguration](#kubermaticprojectsmigratorconfiguration)_ | ProjectsMigrator configures the migrator for user projects. |
| `pprofEndpoint` _string_ | PProfEndpoint controls the port the master-controller-manager should listen on to provide pprof data. This port is never exposed from the container and only available via port-forwardings. |
| `resources` _[ResourceRequirements](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#resourcerequirements-v1-core)_ | Resources describes the requested and maximum allowed CPU/memory usage. |
| `debugLog` _boolean_ | DebugLog enables more verbose logging. |
| `replicas` _integer_ | Replicas sets the number of pod replicas for the master-controller-manager. |


[Back to top](#top)



### KubermaticProjectsMigratorConfiguration



KubermaticProjectsMigratorConfiguration configures the Kubermatic master controller-manager.

_Appears in:_
- [KubermaticMasterControllerConfiguration](#kubermaticmastercontrollerconfiguration)

| Field | Description |
| --- | --- |
| `dryRun` _boolean_ | DryRun makes the migrator only log the actions it would take. |


[Back to top](#top)



### KubermaticProxyConfiguration



KubermaticProxyConfiguration can be used to control how the various Kubermatic components reach external services / the Internet. These settings are reflected as environment variables for the Kubermatic pods.

_Appears in:_
- [KubermaticConfigurationSpec](#kubermaticconfigurationspec)

| Field | Description |
| --- | --- |
| `http` _string_ | HTTP is the full URL to the proxy to use for plaintext HTTP connections, e.g. "http://internalproxy.example.com:8080". |
| `https` _string_ | HTTPS is the full URL to the proxy to use for encrypted HTTPS connections, e.g. "http://secureinternalproxy.example.com:8080". |
| `noProxy` _string_ | NoProxy is a comma-separated list of hostnames / network masks for which no proxy shall be used. If you make use of proxies, this list should contain all local and cluster-internal domains and networks, e.g. "10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,mydomain". The operator will always prepend the following elements to this list if proxying is configured (i.e. HTTP/HTTPS are not empty): "127.0.0.1/8", "localhost", ".local", ".local.", "kubernetes", ".default", ".svc" |


[Back to top](#top)



### KubermaticSeedControllerConfiguration



KubermaticSeedControllerConfiguration configures the Kubermatic seed controller-manager.

_Appears in:_
- [KubermaticConfigurationSpec](#kubermaticconfigurationspec)

| Field | Description |
| --- | --- |
| `dockerRepository` _string_ | DockerRepository is the repository containing the Kubermatic seed-controller-manager image. |
| `backupStoreContainer` _string_ | BackupStoreContainer is the container used for shipping etcd snapshots to a backup location. |
| `backupDeleteContainer` _string_ | BackupDeleteContainer is the container used for deleting etcd snapshots from a backup location. |
| `backupCleanupContainer` _string_ | BackupCleanupContainer is the container used for removing expired backups from the storage location. |
| `backupRestore` _[LegacyKubermaticBackupRestoreConfiguration](#legacykubermaticbackuprestoreconfiguration)_ | BackupRestore contains the setup of the new backup and restore controllers. Deprecated: Use Seed.Spec.EtcdBackupRestore. This is legacy field to support old configurations. |
| `maximumParallelReconciles` _integer_ | MaximumParallelReconciles limits the number of cluster reconciliations that are active at any given time. |
| `pprofEndpoint` _string_ | PProfEndpoint controls the port the seed-controller-manager should listen on to provide pprof data. This port is never exposed from the container and only available via port-forwardings. |
| `resources` _[ResourceRequirements](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#resourcerequirements-v1-core)_ | Resources describes the requested and maximum allowed CPU/memory usage. |
| `debugLog` _boolean_ | DebugLog enables more verbose logging. |
| `replicas` _integer_ | Replicas sets the number of pod replicas for the seed-controller-manager. |


[Back to top](#top)



### KubermaticSetting



KubermaticSetting is the type representing a KubermaticSetting

_Appears in:_
- [KubermaticSettingList](#kubermaticsettinglist)

| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `KubermaticSetting`
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[SettingSpec](#settingspec)_ |  |


[Back to top](#top)



### KubermaticSettingList



KubermaticSettingList is a list of settings



| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `KubermaticSettingList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[KubermaticSetting](#kubermaticsetting)_ |  |


[Back to top](#top)



### KubermaticUIConfiguration



KubermaticUIConfiguration configures the dashboard.

_Appears in:_
- [KubermaticConfigurationSpec](#kubermaticconfigurationspec)

| Field | Description |
| --- | --- |
| `dockerRepository` _string_ | DockerRepository is the repository containing the Kubermatic dashboard image. |
| `dockerTag` _string_ | DockerTag is used to overwrite the dashboard Docker image tag and is only for development purposes. This field must not be set in production environments. --- |
| `config` _string_ | Config sets flags for various dashboard features. |
| `resources` _[ResourceRequirements](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#resourcerequirements-v1-core)_ | Resources describes the requested and maximum allowed CPU/memory usage. |
| `replicas` _integer_ | Replicas sets the number of pod replicas for the UI deployment. |


[Back to top](#top)



### KubermaticUserClusterConfiguration



KubermaticUserClusterConfiguration controls various aspects of the user-created clusters.

_Appears in:_
- [KubermaticConfigurationSpec](#kubermaticconfigurationspec)

| Field | Description |
| --- | --- |
| `kubermaticDockerRepository` _string_ | KubermaticDockerRepository is the repository containing the Kubermatic user-cluster-controller-manager image. |
| `dnatControllerDockerRepository` _string_ | DNATControllerDockerRepository is the repository containing the dnat-controller image. |
| `etcdLauncherDockerRepository` _string_ | EtcdLauncherDockerRepository is the repository containing the Kubermatic etcd-launcher image. |
| `overwriteRegistry` _string_ | OverwriteRegistry specifies a custom Docker registry which will be used for all images used for user clusters (user cluster control plane + addons). This also applies to the KubermaticDockerRepository and DNATControllerDockerRepository fields. |
| `addons` _[KubermaticAddonsConfiguration](#kubermaticaddonsconfiguration)_ | Addons controls the optional additions installed into each user cluster. |
| `nodePortRange` _string_ | NodePortRange is the port range for customer clusters - this must match the NodePort range of the seed cluster. |
| `monitoring` _[KubermaticUserClusterMonitoringConfiguration](#kubermaticuserclustermonitoringconfiguration)_ | Monitoring can be used to fine-tune to in-cluster Prometheus. |
| `disableApiserverEndpointReconciling` _boolean_ | DisableAPIServerEndpointReconciling can be used to toggle the `--endpoint-reconciler-type` flag for the Kubernetes API server. |
| `etcdVolumeSize` _string_ | EtcdVolumeSize configures the volume size to use for each etcd pod inside user clusters. |
| `apiserverReplicas` _integer_ | APIServerReplicas configures the replica count for the API-Server deployment inside user clusters. |
| `machineController` _[MachineControllerConfiguration](#machinecontrollerconfiguration)_ | MachineController configures the Machine Controller |


[Back to top](#top)



### KubermaticUserClusterMonitoringConfiguration



KubermaticUserClusterMonitoringConfiguration can be used to fine-tune to in-cluster Prometheus.

_Appears in:_
- [KubermaticUserClusterConfiguration](#kubermaticuserclusterconfiguration)

| Field | Description |
| --- | --- |
| `disableDefaultRules` _boolean_ | DisableDefaultRules disables the recording and alerting rules. |
| `disableDefaultScrapingConfigs` _boolean_ | DisableDefaultScrapingConfigs disables the default scraping targets. |
| `customRules` _string_ | CustomRules can be used to inject custom recording and alerting rules. This field must be a YAML-formatted string with a `group` element at its root, as documented on https://prometheus.io/docs/prometheus/2.14/configuration/alerting_rules/. |
| `customScrapingConfigs` _string_ | CustomScrapingConfigs can be used to inject custom scraping rules. This must be a YAML-formatted string containing an array of scrape configurations as documented on https://prometheus.io/docs/prometheus/2.14/configuration/configuration/#scrape_config. |
| `scrapeAnnotationPrefix` _string_ | ScrapeAnnotationPrefix (if set) is used to make the in-cluster Prometheus scrape pods inside the user clusters. |


[Back to top](#top)



### KubermaticVPAComponent





_Appears in:_
- [KubermaticVPAConfiguration](#kubermaticvpaconfiguration)

| Field | Description |
| --- | --- |
| `dockerRepository` _string_ | DockerRepository is the repository containing the component's image. |
| `resources` _[ResourceRequirements](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#resourcerequirements-v1-core)_ | Resources describes the requested and maximum allowed CPU/memory usage. |


[Back to top](#top)



### KubermaticVPAConfiguration



KubermaticVPAConfiguration configures the Kubernetes VPA.

_Appears in:_
- [KubermaticConfigurationSpec](#kubermaticconfigurationspec)

| Field | Description |
| --- | --- |
| `recommender` _[KubermaticVPAComponent](#kubermaticvpacomponent)_ |  |
| `updater` _[KubermaticVPAComponent](#kubermaticvpacomponent)_ |  |
| `admissionController` _[KubermaticVPAComponent](#kubermaticvpacomponent)_ |  |


[Back to top](#top)



### KubermaticVersioningConfiguration



KubermaticVersioningConfiguration configures the available and default Kubernetes versions.

_Appears in:_
- [KubermaticConfigurationSpec](#kubermaticconfigurationspec)

| Field | Description |
| --- | --- |
| `versions` _Semver_ | Versions lists the available versions. |
| `default` _Semver_ | Default is the default version to offer users. |
| `updates` _[Update](#update) array_ | Updates is a list of available and automatic upgrades. All 'to' versions must be configured in the version list for this orchestrator. Each update may optionally be configured to be 'automatic: true', in which case the controlplane of all clusters whose version matches the 'from' directive will get updated to the 'to' version. If automatic is enabled, the 'to' version must be a version and not a version range. Also, updates may set 'automaticNodeUpdate: true', in which case Nodes will get updates as well. 'automaticNodeUpdate: true' implies 'automatic: true' as well, because Nodes may not have a newer version than the controlplane. |
| `providerIncompatibilities` _[Incompatibility](#incompatibility) array_ | ProviderIncompatibilities lists all the Kubernetes version incompatibilities |


[Back to top](#top)



### Kubevirt





_Appears in:_
- [PresetSpec](#presetspec)

| Field | Description |
| --- | --- |
| `ProviderPreset` _[ProviderPreset](#providerpreset)_ |  |
| `kubeconfig` _string_ |  |


[Back to top](#top)



### KubevirtCloudSpec



KubevirtCloudSpec specifies the access data to Kubevirt.

_Appears in:_
- [CloudSpec](#cloudspec)

| Field | Description |
| --- | --- |
| `credentialsReference` _[GlobalSecretKeySelector](#globalsecretkeyselector)_ |  |
| `kubeconfig` _string_ |  |


[Back to top](#top)



### LeaderElectionSettings





_Appears in:_
- [ControllerSettings](#controllersettings)

| Field | Description |
| --- | --- |
| `leaseDurationSeconds` _integer_ | LeaseDurationSeconds is the duration in seconds that non-leader candidates will wait to force acquire leadership. This is measured against time of last observed ack. |
| `renewDeadlineSeconds` _integer_ | RenewDeadlineSeconds is the duration in seconds that the acting controlplane will retry refreshing leadership before giving up. |
| `retryPeriodSeconds` _integer_ | RetryPeriodSeconds is the duration in seconds the LeaderElector clients should wait between tries of actions. |


[Back to top](#top)



### LegacyKubermaticBackupRestoreConfiguration



Deprecated: Use Seed.Spec.EtcdBackupRestore. LegacyKubermaticBackupRestoreConfiguration are s3 settings used for backups and restores of user cluster etcds.

_Appears in:_
- [KubermaticSeedControllerConfiguration](#kubermaticseedcontrollerconfiguration)

| Field | Description |
| --- | --- |
| `enabled` _boolean_ | Enabled enables the new etcd backup and restore controllers. |
| `s3Endpoint` _string_ | S3Endpoint is the S3 API endpoint to use for backup and restore. Defaults to s3.amazonaws.com. |
| `s3BucketName` _string_ | S3BucketName is the S3 bucket name to use for backup and restore. |


[Back to top](#top)



### LoggingRateLimitSettings



LoggingRateLimitSettings contains rate-limiting configuration for logging in the user cluster.

_Appears in:_
- [MLAAdminSettingSpec](#mlaadminsettingspec)

| Field | Description |
| --- | --- |
| `ingestionRate` _integer_ | IngestionRate represents ingestion rate limit in requests per second (nginx `rate` in `r/s`). |
| `ingestionBurstSize` _integer_ | IngestionBurstSize represents ingestion burst size in number of requests (nginx `burst`). |
| `queryRate` _integer_ | QueryRate represents query request rate limit per second (nginx `rate` in `r/s`). |
| `queryBurstSize` _integer_ | QueryBurstSize represents query burst size in number of requests (nginx `burst`). |


[Back to top](#top)



### MLAAdminSetting



MLAAdminSetting is the object representing cluster-specific administrator settings for KKP user cluster MLA (monitoring, logging & alerting) stack.

_Appears in:_
- [MLAAdminSettingList](#mlaadminsettinglist)

| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `MLAAdminSetting`
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[MLAAdminSettingSpec](#mlaadminsettingspec)_ |  |


[Back to top](#top)



### MLAAdminSettingList



MLAAdminSettingList specifies a list of administrtor settings for KKP user cluster MLA (monitoring, logging & alerting) stack



| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `MLAAdminSettingList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[MLAAdminSetting](#mlaadminsetting)_ |  |


[Back to top](#top)



### MLAAdminSettingSpec



MLAAdminSettingSpec specifies the cluster-specific administrator settings for KKP user cluster MLA (monitoring, logging & alerting) stack.

_Appears in:_
- [MLAAdminSetting](#mlaadminsetting)

| Field | Description |
| --- | --- |
| `clusterName` _string_ | ClusterName is the name of the user cluster whose MLA settings are defined in this object. |
| `monitoringRateLimits` _[MonitoringRateLimitSettings](#monitoringratelimitsettings)_ | MonitoringRateLimits contains rate-limiting configuration for monitoring in the user cluster. |
| `loggingRateLimits` _[LoggingRateLimitSettings](#loggingratelimitsettings)_ | LoggingRateLimits contains rate-limiting configuration logging in the user cluster. |


[Back to top](#top)



### MLASettings





_Appears in:_
- [ClusterSpec](#clusterspec)

| Field | Description |
| --- | --- |
| `monitoringEnabled` _boolean_ | MonitoringEnabled is the flag for enabling monitoring in user cluster. |
| `loggingEnabled` _boolean_ | LoggingEnabled is the flag for enabling logging in user cluster. |
| `monitoringResources` _[ResourceRequirements](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#resourcerequirements-v1-core)_ | MonitoringResources is the resource requirements for user cluster prometheus. |
| `loggingResources` _[ResourceRequirements](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#resourcerequirements-v1-core)_ | LoggingResources is the resource requirements for user cluster promtail. |
| `monitoringReplicas` _integer_ | MonitoringReplicas is the number of desired pods of user cluster prometheus deployment. |


[Back to top](#top)



### MachineControllerConfiguration



MachineControllerConfiguration configures Machine Controller

_Appears in:_
- [KubermaticUserClusterConfiguration](#kubermaticuserclusterconfiguration)

| Field | Description |
| --- | --- |
| `imageRepository` _string_ | ImageRepository is used to override the Machine Controller image repository. It is only for development, tests and PoC purposes. This field must not be set in production environments. |
| `imageTag` _string_ | ImageTag is used to override the Machine Controller image. It is only for development, tests and PoC purposes. This field must not be set in production environments. |


[Back to top](#top)



### MachineDeploymentVMResourceQuota





_Appears in:_
- [SettingSpec](#settingspec)

| Field | Description |
| --- | --- |
| `minCPU` _integer_ | Minimal number of vCPU |
| `maxCPU` _integer_ | Maximal number of vCPU |
| `minRAM` _integer_ | Minimal RAM size in GB |
| `maxRAM` _integer_ | Maximum RAM size in GB |
| `enableGPU` _boolean_ |  |


[Back to top](#top)



### MachineNetworkingConfig



MachineNetworkingConfig specifies the networking parameters used for IPAM.

_Appears in:_
- [ClusterSpec](#clusterspec)

| Field | Description |
| --- | --- |
| `cidr` _string_ |  |
| `gateway` _string_ |  |
| `dnsServers` _string array_ |  |


[Back to top](#top)



### Match



Match contains the constraint to resource matching data

_Appears in:_
- [ConstraintSpec](#constraintspec)

| Field | Description |
| --- | --- |
| `kinds` _[Kind](#kind) array_ | Kinds accepts a list of objects with apiGroups and kinds fields that list the groups/kinds of objects to which the constraint will apply. If multiple groups/kinds objects are specified, only one match is needed for the resource to be in scope |
| `scope` _string_ | Scope accepts *, Cluster, or Namespaced which determines if cluster-scoped and/or namesapced-scoped resources are selected. (defaults to *) |
| `namespaces` _string array_ | Namespaces is a list of namespace names. If defined, a constraint will only apply to resources in a listed namespace. |
| `excludedNamespaces` _string array_ | ExcludedNamespaces is a list of namespace names. If defined, a constraint will only apply to resources not in a listed namespace. |
| `labelSelector` _[LabelSelector](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#labelselector-v1-meta)_ | LabelSelector is a standard Kubernetes label selector. |
| `namespaceSelector` _[LabelSelector](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#labelselector-v1-meta)_ | NamespaceSelector  is a standard Kubernetes namespace selector. If defined, make sure to add Namespaces to your configs.config.gatekeeper.sh object to ensure namespaces are synced into OPA |


[Back to top](#top)



### MeteringConfiguration



MeteringConfiguration contains all the configuration for the metering tool.

_Appears in:_
- [SeedSpec](#seedspec)

| Field | Description |
| --- | --- |
| `enabled` _boolean_ |  |
| `storageClassName` _string_ | StorageClassName is the name of the storage class that the metering tool uses to save processed files before exporting it to s3 bucket. Default value is kubermatic-fast. |
| `storageSize` _string_ | StorageSize is the size of the storage class. Default value is 100Gi. |


[Back to top](#top)



### MlaOptions





_Appears in:_
- [SettingSpec](#settingspec)

| Field | Description |
| --- | --- |
| `loggingEnabled` _boolean_ |  |
| `loggingEnforced` _boolean_ |  |
| `monitoringEnabled` _boolean_ |  |
| `monitoringEnforced` _boolean_ |  |


[Back to top](#top)



### MonitoringRateLimitSettings



MonitoringRateLimitSettings contains rate-limiting configuration for monitoring in the user cluster.

_Appears in:_
- [MLAAdminSettingSpec](#mlaadminsettingspec)

| Field | Description |
| --- | --- |
| `ingestionRate` _integer_ | IngestionRate represents the ingestion rate limit in samples per second (Cortex `ingestion_rate`). |
| `ingestionBurstSize` _integer_ | IngestionBurstSize represents ingestion burst size in samples per second (Cortex `ingestion_burst_size`). |
| `maxSeriesPerMetric` _integer_ | MaxSeriesPerMetric represents maximum number of series per metric (Cortex `max_series_per_metric`). |
| `maxSeriesTotal` _integer_ | MaxSeriesTotal represents maximum number of series per this user cluster (Cortex `max_series_per_user`). |
| `queryRate` _integer_ | QueryRate represents  query request rate limit per second (nginx `rate` in `r/s`). |
| `queryBurstSize` _integer_ | QueryBurstSize represents query burst size in number of requests (nginx `burst`). |
| `maxSamplesPerQuery` _integer_ | MaxSamplesPerQuery represents maximum number of samples during a query (Cortex `max_samples_per_query`). |
| `maxSeriesPerQuery` _integer_ | MaxSeriesPerQuery represents maximum number of timeseries during a query (Cortex `max_series_per_query`). |


[Back to top](#top)



### NetworkRanges



NetworkRanges represents ranges of network addresses.

_Appears in:_
- [ClusterNetworkingConfig](#clusternetworkingconfig)

| Field | Description |
| --- | --- |
| `cidrBlocks` _string array_ |  |


[Back to top](#top)



### NodeSettings



NodeSettings are node specific flags which can be configured on datacenter level

_Appears in:_
- [Datacenter](#datacenter)

| Field | Description |
| --- | --- |
| `ProxySettings` _[ProxySettings](#proxysettings)_ | Optional: Proxy settings for the Nodes in this datacenter. Defaults to the Proxy settings of the seed. |
| `insecureRegistries` _string array_ | Optional: These image registries will be configured as insecure on the container runtime. |
| `registryMirrors` _string array_ | Optional: These image registries will be configured as registry mirrors on the container runtime. |
| `pauseImage` _string_ | Optional: Translates to --pod-infra-container-image on the kubelet. If not set, the kubelet will default it. |
| `hyperkubeImage` _string_ | Optional: The hyperkube image to use. Currently only Flatcar makes use of this option. |


[Back to top](#top)



### NodeportProxyComponent





_Appears in:_
- [ComponentSettings](#componentsettings)
- [NodeportProxyConfig](#nodeportproxyconfig)

| Field | Description |
| --- | --- |
| `dockerRepository` _string_ | DockerRepository is the repository containing the component's image. |
| `resources` _[ResourceRequirements](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#resourcerequirements-v1-core)_ | Resources describes the requested and maximum allowed CPU/memory usage. |


[Back to top](#top)



### NodeportProxyConfig





_Appears in:_
- [SeedSpec](#seedspec)

| Field | Description |
| --- | --- |
| `disable` _boolean_ | Disable will prevent the Kubermatic Operator from creating a nodeport-proxy setup on the seed cluster. This should only be used if a suitable replacement is installed (like the nodeport-proxy Helm chart). |
| `annotations` _object (keys:string, values:string)_ | Annotations are used to further tweak the LoadBalancer integration with the cloud provider where the seed cluster is running. |
| `envoy` _[NodeportProxyComponent](#nodeportproxycomponent)_ | Envoy configures the Envoy application itself. |
| `envoyManager` _[NodeportProxyComponent](#nodeportproxycomponent)_ | EnvoyManager configures the Kubermatic-internal Envoy manager. |
| `updater` _[NodeportProxyComponent](#nodeportproxycomponent)_ | Updater configures the component responsible for updating the LoadBalancer service. |


[Back to top](#top)



### Nutanix





_Appears in:_
- [PresetSpec](#presetspec)

| Field | Description |
| --- | --- |
| `ProviderPreset` _[ProviderPreset](#providerpreset)_ |  |
| `proxyURL` _string_ |  |
| `username` _string_ |  |
| `password` _string_ |  |
| `clusterName` _string_ |  |
| `projectName` _string_ |  |


[Back to top](#top)



### NutanixCloudSpec



NutanixCloudSpec specifies the access data to Nutanix. NUTANIX IMPLEMENTATION IS EXPERIMENTAL AND UNSUPPORTED.

_Appears in:_
- [CloudSpec](#cloudspec)

| Field | Description |
| --- | --- |
| `credentialsReference` _[GlobalSecretKeySelector](#globalsecretkeyselector)_ |  |
| `clusterName` _string_ | ClusterName is the Nutanix cluster that this user cluster will be deployed to. |
| `projectName` _string_ | ProjectName is the project that this cluster is deployed into. If none is given, no project will be used. |
| `proxyURL` _string_ |  |
| `username` _string_ |  |
| `password` _string_ |  |


[Back to top](#top)



### OIDCSettings





_Appears in:_
- [ClusterSpec](#clusterspec)

| Field | Description |
| --- | --- |
| `issuerURL` _string_ |  |
| `clientID` _string_ |  |
| `clientSecret` _string_ |  |
| `usernameClaim` _string_ |  |
| `groupsClaim` _string_ |  |
| `requiredClaim` _string_ |  |
| `extraScopes` _string_ |  |


[Back to top](#top)



### OPAIntegrationSettings





_Appears in:_
- [ClusterSpec](#clusterspec)

| Field | Description |
| --- | --- |
| `enabled` _boolean_ | Enabled is the flag for enabling OPA integration |
| `webhookTimeoutSeconds` _integer_ | WebhookTimeout is the timeout that is set for the gatekeeper validating webhook admission review calls. By default 10 seconds. |
| `experimentalEnableMutation` _boolean_ | Enable mutation |
| `controllerResources` _[ResourceRequirements](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#resourcerequirements-v1-core)_ | ControllerResources is the resource requirements for user cluster gatekeeper controller. |
| `auditResources` _[ResourceRequirements](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#resourcerequirements-v1-core)_ | AuditResources is the resource requirements for user cluster gatekeeper audit. |


[Back to top](#top)



### OpaOptions





_Appears in:_
- [SettingSpec](#settingspec)

| Field | Description |
| --- | --- |
| `enabled` _boolean_ |  |
| `enforced` _boolean_ |  |


[Back to top](#top)



### Openstack





_Appears in:_
- [PresetSpec](#presetspec)

| Field | Description |
| --- | --- |
| `ProviderPreset` _[ProviderPreset](#providerpreset)_ |  |
| `useToken` _boolean_ |  |
| `applicationCredentialID` _string_ |  |
| `applicationCredentialSecret` _string_ |  |
| `username` _string_ |  |
| `password` _string_ |  |
| `project` _string_ |  |
| `projectID` _string_ |  |
| `domain` _string_ |  |
| `network` _string_ |  |
| `securityGroups` _string_ |  |
| `floatingIPPool` _string_ |  |
| `routerID` _string_ |  |
| `subnetID` _string_ |  |


[Back to top](#top)



### OpenstackCloudSpec



OpenstackCloudSpec specifies access data to an OpenStack cloud.

_Appears in:_
- [CloudSpec](#cloudspec)

| Field | Description |
| --- | --- |
| `credentialsReference` _[GlobalSecretKeySelector](#globalsecretkeyselector)_ |  |
| `username` _string_ |  |
| `password` _string_ |  |
| `project` _string_ | project, formally known as tenant. Tenant is depreciated in Openstack |
| `projectID` _string_ | project id, formally known as tenantID. TenantID is depreciated in Openstack |
| `domain` _string_ |  |
| `applicationCredentialID` _string_ |  |
| `applicationCredentialSecret` _string_ |  |
| `useToken` _boolean_ |  |
| `token` _string_ | Used internally during cluster creation |
| `network` _string_ | Network holds the name of the internal network When specified, all worker nodes will be attached to this network. If not specified, a network, subnet & router will be created 
 Note that the network is internal if the "External" field is set to false |
| `securityGroups` _string_ |  |
| `nodePortsAllowedIPRange` _string_ |  |
| `floatingIPPool` _string_ | FloatingIPPool holds the name of the public network The public network is reachable from the outside world and should provide the pool of IP addresses to choose from. 
 When specified, all worker nodes will receive a public ip from this floating ip pool 
 Note that the network is external if the "External" field is set to true |
| `routerID` _string_ |  |
| `subnetID` _string_ |  |
| `useOctavia` _boolean_ | Whether or not to use Octavia for LoadBalancer type of Service implementation instead of using Neutron-LBaaS. Attention:Openstack CCM use Octavia as default load balancer implementation since v1.17.0 
 Takes precedence over the 'use_octavia' flag provided at datacenter level if both are specified. |


[Back to top](#top)



### OpenstackNodeSizeRequirements





_Appears in:_
- [DatacenterSpecOpenstack](#datacenterspecopenstack)

| Field | Description |
| --- | --- |
| `minimumVCPUs` _integer_ | VCPUs is the minimum required amount of (virtual) CPUs |
| `minimumMemory` _integer_ | MinimumMemory is the minimum required amount of memory, measured in MB |


[Back to top](#top)



### Packet





_Appears in:_
- [PresetSpec](#presetspec)

| Field | Description |
| --- | --- |
| `ProviderPreset` _[ProviderPreset](#providerpreset)_ |  |
| `apiKey` _string_ |  |
| `projectID` _string_ |  |
| `billingCycle` _string_ |  |


[Back to top](#top)



### PacketCloudSpec



PacketCloudSpec specifies access data to a Packet cloud.

_Appears in:_
- [CloudSpec](#cloudspec)

| Field | Description |
| --- | --- |
| `credentialsReference` _[GlobalSecretKeySelector](#globalsecretkeyselector)_ |  |
| `apiKey` _string_ |  |
| `projectID` _string_ |  |
| `billingCycle` _string_ |  |


[Back to top](#top)





### Preset



Preset is the type representing a Preset

_Appears in:_
- [PresetList](#presetlist)

| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `Preset`
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[PresetSpec](#presetspec)_ |  |


[Back to top](#top)



### PresetList



PresetList is the type representing a PresetList



| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `PresetList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[Preset](#preset) array_ | List of presets |


[Back to top](#top)



### PresetSpec



Presets specifies default presets for supported providers

_Appears in:_
- [Preset](#preset)

| Field | Description |
| --- | --- |
| `digitalocean` _[Digitalocean](#digitalocean)_ |  |
| `hetzner` _[Hetzner](#hetzner)_ |  |
| `azure` _[Azure](#azure)_ |  |
| `vsphere` _[VSphere](#vsphere)_ |  |
| `aws` _[AWS](#aws)_ |  |
| `openstack` _[Openstack](#openstack)_ |  |
| `packet` _[Packet](#packet)_ |  |
| `gcp` _[GCP](#gcp)_ |  |
| `kubevirt` _[Kubevirt](#kubevirt)_ |  |
| `alibaba` _[Alibaba](#alibaba)_ |  |
| `anexia` _[Anexia](#anexia)_ |  |
| `nutanix` _[Nutanix](#nutanix)_ |  |
| `gke` _[GKE](#gke)_ |  |
| `eks` _[EKS](#eks)_ |  |
| `aks` _[AKS](#aks)_ |  |
| `requiredEmails` _string array_ |  |
| `enabled` _boolean_ |  |


[Back to top](#top)



### Project



Project is the type describing a project.

_Appears in:_
- [ProjectList](#projectlist)

| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `Project`
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[ProjectSpec](#projectspec)_ |  |
| `status` _[ProjectStatus](#projectstatus)_ |  |


[Back to top](#top)





### ProjectList



ProjectList is a collection of projects.



| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `ProjectList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[Project](#project)_ |  |


[Back to top](#top)



### ProjectSpec



ProjectSpec is a specification of a project.

_Appears in:_
- [Project](#project)

| Field | Description |
| --- | --- |
| `name` _string_ |  |


[Back to top](#top)



### ProjectStatus



ProjectStatus represents the current status of a project.

_Appears in:_
- [Project](#project)

| Field | Description |
| --- | --- |
| `phase` _ProjectPhase_ |  |


[Back to top](#top)



### ProviderPreset





_Appears in:_
- [AKS](#aks)
- [AWS](#aws)
- [Alibaba](#alibaba)
- [Anexia](#anexia)
- [Azure](#azure)
- [Digitalocean](#digitalocean)
- [EKS](#eks)
- [GCP](#gcp)
- [GKE](#gke)
- [Hetzner](#hetzner)
- [Kubevirt](#kubevirt)
- [Nutanix](#nutanix)
- [Openstack](#openstack)
- [Packet](#packet)
- [VSphere](#vsphere)

| Field | Description |
| --- | --- |
| `enabled` _boolean_ |  |
| `datacenter` _string_ |  |


[Back to top](#top)



### ProviderType

_Underlying type:_ `string`



_Appears in:_
- [Incompatibility](#incompatibility)



### ProxySettings



ProxySettings allow configuring a HTTP proxy for the controlplanes and nodes

_Appears in:_
- [NodeSettings](#nodesettings)
- [SeedSpec](#seedspec)

| Field | Description |
| --- | --- |
| `httpProxy` _[ProxyValue](#proxyvalue)_ | Optional: If set, this proxy will be configured for both HTTP and HTTPS. |
| `noProxy` _[ProxyValue](#proxyvalue)_ | Optional: If set this will be set as NO_PROXY environment variable on the node; The value must be a comma-separated list of domains for which no proxy should be used, e.g. "*.example.com,internal.dev". Note that the in-cluster apiserver URL will be automatically prepended to this value. |


[Back to top](#top)



### ProxyValue

_Underlying type:_ `string`



_Appears in:_
- [ProxySettings](#proxysettings)



### RSAKeys



RSAKeys is a pair of private and public key where the key is not published to the API client.

_Appears in:_
- [ClusterStatus](#clusterstatus)

| Field | Description |
| --- | --- |
| `privateKey` _integer array_ |  |
| `publicKey` _integer array_ |  |


[Back to top](#top)



### RuleGroup





_Appears in:_
- [RuleGroupList](#rulegrouplist)

| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `RuleGroup`
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[RuleGroupSpec](#rulegroupspec)_ |  |


[Back to top](#top)



### RuleGroupList







| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `RuleGroupList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[RuleGroup](#rulegroup)_ |  |


[Back to top](#top)



### RuleGroupSpec





_Appears in:_
- [RuleGroup](#rulegroup)

| Field | Description |
| --- | --- |
| `ruleGroupType` _[RuleGroupType](#rulegrouptype)_ | RuleGroupType is the type of this ruleGroup applies to. It can be `Metrics` or `Logs`. |
| `cluster` _[ObjectReference](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#objectreference-v1-core)_ | Cluster is the reference to the cluster the ruleGroup should be created in. |
| `data` _integer array_ | Data contains the RuleGroup data. Ref: https://prometheus.io/docs/prometheus/latest/configuration/recording_rules/#rule_group |


[Back to top](#top)



### RuleGroupType

_Underlying type:_ `string`



_Appears in:_
- [RuleGroupSpec](#rulegroupspec)



### SSHKeySpec





_Appears in:_
- [UserSSHKey](#usersshkey)

| Field | Description |
| --- | --- |
| `owner` _string_ |  |
| `name` _string_ |  |
| `fingerprint` _string_ |  |
| `publicKey` _string_ |  |
| `clusters` _string array_ |  |


[Back to top](#top)



### Seed



Seed is the type representing a SeedDatacenter

_Appears in:_
- [SeedList](#seedlist)

| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `Seed`
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[SeedSpec](#seedspec)_ |  |


[Back to top](#top)



### SeedBackupRestoreConfiguration



SeedBackupRestoreConfiguration defines the bucket name and endpoint as a backup destination. Deprecated: use EtcdBackupRestore

_Appears in:_
- [SeedSpec](#seedspec)

| Field | Description |
| --- | --- |
| `s3Endpoint` _string_ | S3Endpoint is the S3 API endpoint to use for backup and restore. |
| `s3BucketName` _string_ | S3BucketName is the S3 bucket name to use for backup and restore. |


[Back to top](#top)



### SeedList



SeedDatacenterList is the type representing a SeedDatacenterList



| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `SeedList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[Seed](#seed) array_ | List of seeds |


[Back to top](#top)



### SeedMLASettings



SeedMLASettings allow configuring seed level MLA (Monitoring, Logging & Alerting) stack settings.

_Appears in:_
- [SeedSpec](#seedspec)

| Field | Description |
| --- | --- |
| `userClusterMLAEnabled` _boolean_ | Optional: UserClusterMLAEnabled controls whether the user cluster MLA (Monitoring, Logging & Alerting) stack is enabled in the seed. |


[Back to top](#top)



### SeedSpec



The spec for a seed data

_Appears in:_
- [Seed](#seed)

| Field | Description |
| --- | --- |
| `country` _string_ | Optional: Country of the seed as ISO-3166 two-letter code, e.g. DE or UK. For informational purposes in the Kubermatic dashboard only. |
| `location` _string_ | Optional: Detailed location of the cluster, like "Hamburg" or "Datacenter 7". For informational purposes in the Kubermatic dashboard only. |
| `kubeconfig` _[ObjectReference](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#objectreference-v1-core)_ | A reference to the Kubeconfig of this cluster. The Kubeconfig must have cluster-admin privileges. This field is mandatory for every seed, even if there are no datacenters defined yet. |
| `datacenters` _object (keys:string, values:[Datacenter](#datacenter))_ | Datacenters contains a map of the possible datacenters (DCs) in this seed. Each DC must have a globally unique identifier (i.e. names must be unique across all seeds). |
| `seedDNSOverwrite` _string_ | Optional: This can be used to override the DNS name used for this seed. By default the seed name is used. |
| `nodeportProxy` _[NodeportProxyConfig](#nodeportproxyconfig)_ | NodeportProxy can be used to configure the NodePort proxy service that is responsible for making user-cluster control planes accessible from the outside. |
| `proxySettings` _[ProxySettings](#proxysettings)_ | Optional: ProxySettings can be used to configure HTTP proxy settings on the worker nodes in user clusters. However, proxy settings on nodes take precedence. |
| `exposeStrategy` _[ExposeStrategy](#exposestrategy)_ | Optional: ExposeStrategy explicitly sets the expose strategy for this seed cluster, if not set, the default provided by the master is used. |
| `mla` _[SeedMLASettings](#seedmlasettings)_ | Optional: MLA allows configuring seed level MLA (Monitoring, Logging & Alerting) stack settings. |
| `defaultComponentSettings` _[ComponentSettings](#componentsettings)_ | DefaultComponentSettings are default values to set for newly created clusters. Deprecated: Use DefaultClusterTemplate instead. |
| `defaultClusterTemplate` _string_ | DefaultClusterTemplate is the name of a cluster template of scope "seed" that is used to default all new created clusters |
| `metering` _[MeteringConfiguration](#meteringconfiguration)_ | Metering configures the metering tool on user clusters across the seed. |
| `backupRestore` _[SeedBackupRestoreConfiguration](#seedbackuprestoreconfiguration)_ | BackupRestore when set, enables backup and restore controllers with given configuration. Deprecated: use EtcdBackupRestore instead which allows for multiple destinations. For now, it's still supported and will work if set. |
| `etcdBackupRestore` _[EtcdBackupRestore](#etcdbackuprestore)_ | EtcdBackupRestore holds the configuration of the automatic etcd backup restores for the Seed |


[Back to top](#top)



### ServiceAccountSettings





_Appears in:_
- [ClusterSpec](#clusterspec)

| Field | Description |
| --- | --- |
| `tokenVolumeProjectionEnabled` _boolean_ |  |
| `issuer` _string_ | Issuer is the identifier of the service account token issuer If this is not specified, it will be set to the URL of apiserver by default |
| `apiAudiences` _string array_ | APIAudiences are the Identifiers of the API If this is not specified, it will be set to a single element list containing the issuer URL |


[Back to top](#top)



### SettingSpec





_Appears in:_
- [KubermaticSetting](#kubermaticsetting)

| Field | Description |
| --- | --- |
| `customLinks` _[CustomLink](#customlink) array_ |  |
| `cleanupOptions` _[CleanupOptions](#cleanupoptions)_ |  |
| `defaultNodeCount` _integer_ |  |
| `displayDemoInfo` _boolean_ |  |
| `displayAPIDocs` _boolean_ |  |
| `displayTermsOfService` _boolean_ |  |
| `enableDashboard` _boolean_ |  |
| `enableOIDCKubeconfig` _boolean_ |  |
| `userProjectsLimit` _integer_ |  |
| `restrictProjectCreation` _boolean_ |  |
| `enableExternalClusterImport` _boolean_ |  |
| `opaOptions` _[OpaOptions](#opaoptions)_ |  |
| `mlaOptions` _[MlaOptions](#mlaoptions)_ |  |
| `mlaAlertmanagerPrefix` _string_ |  |
| `mlaGrafanaPrefix` _string_ |  |
| `machineDeploymentVMResourceQuota` _[MachineDeploymentVMResourceQuota](#machinedeploymentvmresourcequota)_ |  |


[Back to top](#top)



### StatefulSetSettings





_Appears in:_
- [ComponentSettings](#componentsettings)

| Field | Description |
| --- | --- |
| `resources` _[ResourceRequirements](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#resourcerequirements-v1-core)_ |  |


[Back to top](#top)



### Update



Update represents an update option for a user cluster.

_Appears in:_
- [KubermaticVersioningConfiguration](#kubermaticversioningconfiguration)

| Field | Description |
| --- | --- |
| `from` _string_ | From is the version from which an update is allowed. Wildcards are allowed, e.g. "1.18.*". |
| `to` _string_ | To is the version to which an update is allowed. Must be a valid version if `automatic` is set to true, e.g. "1.20.13". Can be a wildcard otherwise, e.g. "1.20.*". |
| `automatic` _boolean_ | Automatic controls whether this update is executed automatically for the control plane of all matching user clusters. --- |
| `automaticNodeUpdate` _boolean_ | Automatic controls whether this update is executed automatically for the worker nodes of all matching user clusters. --- |


[Back to top](#top)



### UpdateWindow





_Appears in:_
- [ClusterSpec](#clusterspec)

| Field | Description |
| --- | --- |
| `start` _string_ |  |
| `length` _string_ |  |


[Back to top](#top)



### User



User specifies a user

_Appears in:_
- [UserList](#userlist)

| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `User`
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[UserSpec](#userspec)_ |  |
| `status` _[UserStatus](#userstatus)_ |  |


[Back to top](#top)



### UserList



UserList is a list of users



| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `UserList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[User](#user)_ |  |


[Back to top](#top)



### UserProjectBinding



UserProjectBinding specifies a binding between a user and a project This resource is used by the user management to manipulate members of the given project

_Appears in:_
- [UserProjectBindingList](#userprojectbindinglist)

| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `UserProjectBinding`
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[UserProjectBindingSpec](#userprojectbindingspec)_ |  |


[Back to top](#top)



### UserProjectBindingList



UserProjectBindingList is a list of users



| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `UserProjectBindingList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[UserProjectBinding](#userprojectbinding)_ |  |


[Back to top](#top)



### UserProjectBindingSpec



UserProjectBindingSpec specifies a user

_Appears in:_
- [UserProjectBinding](#userprojectbinding)

| Field | Description |
| --- | --- |
| `userEmail` _string_ |  |
| `projectID` _string_ |  |
| `group` _string_ |  |


[Back to top](#top)



### UserSSHKey



UserSSHKey specifies a users UserSSHKey

_Appears in:_
- [UserSSHKeyList](#usersshkeylist)

| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `UserSSHKey`
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[SSHKeySpec](#sshkeyspec)_ |  |


[Back to top](#top)



### UserSSHKeyList



UserSSHKeyList specifies a users UserSSHKey



| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `UserSSHKeyList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[UserSSHKey](#usersshkey)_ |  |


[Back to top](#top)



### UserSettings



UserSettings represent an user settings

_Appears in:_
- [UserSpec](#userspec)

| Field | Description |
| --- | --- |
| `selectedTheme` _string_ |  |
| `itemsPerPage` _integer_ |  |
| `selectedProjectID` _string_ |  |
| `selectProjectTableView` _boolean_ |  |
| `collapseSidenav` _boolean_ |  |
| `displayAllProjectsForAdmin` _boolean_ |  |
| `lastSeenChangelogVersion` _string_ |  |


[Back to top](#top)



### UserSpec



UserSpec specifies a user

_Appears in:_
- [User](#user)

| Field | Description |
| --- | --- |
| `id` _string_ |  |
| `name` _string_ |  |
| `email` _string_ |  |
| `admin` _boolean_ |  |
| `settings` _[UserSettings](#usersettings)_ |  |
| `invalidTokensReference` _[GlobalSecretKeySelector](#globalsecretkeyselector)_ |  |
| `lastSeen` _[Time](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#time-v1-meta)_ |  |


[Back to top](#top)



### UserStatus



UserStatus stores status information about a user.

_Appears in:_
- [User](#user)

| Field | Description |
| --- | --- |
| `lastSeen` _[Time](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#time-v1-meta)_ |  |


[Back to top](#top)



### VSphere





_Appears in:_
- [PresetSpec](#presetspec)

| Field | Description |
| --- | --- |
| `ProviderPreset` _[ProviderPreset](#providerpreset)_ |  |
| `username` _string_ |  |
| `password` _string_ |  |
| `vmNetName` _string_ |  |
| `datastore` _string_ |  |
| `datastoreCluster` _string_ |  |
| `resourcePool` _string_ |  |


[Back to top](#top)



### VSphereCloudSpec



VSphereCloudSpec specifies access data to VSphere cloud.

_Appears in:_
- [CloudSpec](#cloudspec)

| Field | Description |
| --- | --- |
| `credentialsReference` _[GlobalSecretKeySelector](#globalsecretkeyselector)_ |  |
| `username` _string_ | Username is the vSphere user name. |
| `password` _string_ | Password is the vSphere user password. |
| `vmNetName` _string_ | VMNetName is the name of the vSphere network. |
| `folder` _string_ | Folder is the folder to be used to group the provisioned virtual machines. |
| `datastore` _string_ | Datastore to be used for storing virtual machines and as a default for dynamic volume provisioning, it is mutually exclusive with DatastoreCluster. |
| `datastoreCluster` _string_ | DatastoreCluster to be used for storing virtual machines, it is mutually exclusive with Datastore. |
| `storagePolicy` _string_ | StoragePolicy to be used for storage provisioning |
| `resourcePool` _string_ | ResourcePool is used to manage resources such as cpu and memory for vSphere virtual machines. The resource pool should be defined on vSphere cluster level. |
| `infraManagementUser` _[VSphereCredentials](#vspherecredentials)_ | This user will be used for everything except cloud provider functionality |


[Back to top](#top)



### VSphereCredentials



VSphereCredentials credentials represents a credential for accessing vSphere

_Appears in:_
- [DatacenterSpecVSphere](#datacenterspecvsphere)
- [VSphereCloudSpec](#vspherecloudspec)

| Field | Description |
| --- | --- |
| `username` _string_ |  |
| `password` _string_ |  |


[Back to top](#top)



