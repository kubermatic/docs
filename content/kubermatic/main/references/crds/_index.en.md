+++
title = "Kubermatic CRDs Reference"
date = 2021-12-02T00:00:00
weight = 40
searchExclude = true
+++

## Packages
- [apps.kubermatic.k8c.io/v1](#appskubermatick8ciov1)
- [kubermatic.k8c.io/v1](#kubermatick8ciov1)


## apps.kubermatic.k8c.io/v1


### Resource Types
- [ApplicationDefinition](#applicationdefinition)
- [ApplicationDefinitionList](#applicationdefinitionlist)
- [ApplicationInstallation](#applicationinstallation)
- [ApplicationInstallationList](#applicationinstallationlist)



### AppNamespaceSpec



AppNamespaceSpec describe the desired state of the namespace where application will be created.

_Appears in:_
- [ApplicationInstallationSpec](#applicationinstallationspec)

| Field | Description |
| --- | --- |
| `name` _string_ | Name is the namespace to deploy the Application into.
Should be a valid lowercase RFC1123 domain name |
| `create` _boolean_ | Create defines whether the namespace should be created if it does not exist. Defaults to true |
| `labels` _object (keys:string, values:string)_ | Labels of the namespace
More info: http://kubernetes.io/docs/user-guide/labels |
| `annotations` _object (keys:string, values:string)_ | Annotations of the namespace
More info: http://kubernetes.io/docs/user-guide/annotations |


[Back to top](#top)



### ApplicationDefinition



ApplicationDefinition is the Schema for the applicationdefinitions API.

_Appears in:_
- [ApplicationDefinitionList](#applicationdefinitionlist)

| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `apps.kubermatic.k8c.io/v1`
| `kind` _string_ | `ApplicationDefinition`
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[ApplicationDefinitionSpec](#applicationdefinitionspec)_ |  |


[Back to top](#top)



### ApplicationDefinitionList



ApplicationDefinitionList contains a list of ApplicationDefinition.



| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `apps.kubermatic.k8c.io/v1`
| `kind` _string_ | `ApplicationDefinitionList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[ApplicationDefinition](#applicationdefinition) array_ |  |


[Back to top](#top)



### ApplicationDefinitionSpec



ApplicationDefinitionSpec defines the desired state of ApplicationDefinition.

_Appears in:_
- [ApplicationDefinition](#applicationdefinition)

| Field | Description |
| --- | --- |
| `description` _string_ | Description of the application. what is its purpose |
| `method` _[TemplateMethod](#templatemethod)_ | Method used to install the application |
| `defaultValues` _[RawExtension](#rawextension)_ | DefaultValues specify default values for the UI which are passed to helm templating when creating an application. Comments are not preserved.
Deprecated: use DefaultValuesBlock instead |
| `defaultValuesBlock` _string_ | DefaultValuesBlock specifies default values for the UI which are passed to helm templating when creating an application. Comments are preserved. |
| `defaultDeployOptions` _[DeployOptions](#deployoptions)_ | DefaultDeployOptions holds the settings specific to the templating method used to deploy the application.
These settings can be overridden in applicationInstallation. |
| `documentationURL` _string_ | DocumentationURL holds a link to official documentation of the Application
Alternatively this can be a link to the Readme of a chart in a git repository |
| `sourceURL` _string_ | SourceURL holds a link to the official source code mirror or git repository of the application |
| `logo` _string_ | Logo of the Application as a base64 encoded svg |
| `logoFormat` _string_ | LogoFormat contains logo format of the configured Application. Options are "svg+xml" and "png" |
| `versions` _[ApplicationVersion](#applicationversion) array_ | Available version for this application |


[Back to top](#top)



### ApplicationInstallation



ApplicationInstallation describes a single installation of an Application.

_Appears in:_
- [ApplicationInstallationList](#applicationinstallationlist)

| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `apps.kubermatic.k8c.io/v1`
| `kind` _string_ | `ApplicationInstallation`
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[ApplicationInstallationSpec](#applicationinstallationspec)_ |  |
| `status` _[ApplicationInstallationStatus](#applicationinstallationstatus)_ |  |


[Back to top](#top)



### ApplicationInstallationCondition





_Appears in:_
- [ApplicationInstallationStatus](#applicationinstallationstatus)

| Field | Description |
| --- | --- |
| `status` _[ConditionStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#conditionstatus-v1-core)_ | Status of the condition, one of True, False, Unknown. |
| `lastHeartbeatTime` _[Time](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#time-v1-meta)_ | Last time we got an update on a given condition. |
| `lastTransitionTime` _[Time](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#time-v1-meta)_ | Last time the condition transit from one status to another. |
| `reason` _string_ | (brief) reason for the condition's last transition. |
| `message` _string_ | Human readable message indicating details about last transition. |
| `observedGeneration` _integer_ | observedGeneration represents the .metadata.generation that the condition was set based upon.
For instance, if .metadata.generation is currently 12, but the .status.conditions[x].observedGeneration is 9, the condition is out of date
with respect to the current state of the instance. |


[Back to top](#top)



### ApplicationInstallationConditionType

_Underlying type:_ `string`

swagger:enum ApplicationInstallationConditionType
All condition types must be registered within the `AllApplicationInstallationConditionTypes` variable.

_Appears in:_
- [ApplicationInstallationStatus](#applicationinstallationstatus)



### ApplicationInstallationList



ApplicationInstallationList is a list of ApplicationInstallations.



| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `apps.kubermatic.k8c.io/v1`
| `kind` _string_ | `ApplicationInstallationList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[ApplicationInstallation](#applicationinstallation) array_ |  |


[Back to top](#top)



### ApplicationInstallationSpec





_Appears in:_
- [ApplicationInstallation](#applicationinstallation)

| Field | Description |
| --- | --- |
| `namespace` _[AppNamespaceSpec](#appnamespacespec)_ | Namespace describe the desired state of the namespace where application will be created. |
| `applicationRef` _[ApplicationRef](#applicationref)_ | ApplicationRef is a reference to identify which Application should be deployed |
| `values` _[RawExtension](#rawextension)_ | Values specify values overrides that are passed to helm templating. Comments are not preserved.
Deprecated: Use ValuesBlock instead. |
| `valuesBlock` _string_ | ValuesBlock specifies values overrides that are passed to helm templating. Comments are preserved. |
| `reconciliationInterval` _[Duration](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#duration-v1-meta)_ | ReconciliationInterval is the interval at which to force the reconciliation of the application. By default, Applications are only reconciled
on changes on spec, annotations, or the parent application definition. Meaning that if the user manually deletes the workload
deployed by the application, nothing will happen until the application CR change.


Setting a value greater than zero force reconciliation even if no changes occurred on application CR.
Setting a value equal to 0 disables the force reconciliation of the application (default behavior).
Setting this too low can cause a heavy load and may disrupt your application workload depending on the template method. |
| `deployOptions` _[DeployOptions](#deployoptions)_ | DeployOptions holds the settings specific to the templating method used to deploy the application. |


[Back to top](#top)



### ApplicationInstallationStatus



ApplicationInstallationStatus denotes status information about an ApplicationInstallation.

_Appears in:_
- [ApplicationInstallation](#applicationinstallation)

| Field | Description |
| --- | --- |
| `conditions` _object (keys:[ApplicationInstallationConditionType](#applicationinstallationconditiontype), values:[ApplicationInstallationCondition](#applicationinstallationcondition))_ | Conditions contains conditions an installation is in, its primary use case is status signaling between controllers or between controllers and the API |
| `applicationVersion` _[ApplicationVersion](#applicationversion)_ | ApplicationVersion contains information installing / removing application |
| `method` _[TemplateMethod](#templatemethod)_ | Method used to install the application |
| `helmRelease` _[HelmRelease](#helmrelease)_ | HelmRelease holds the information about the helm release installed by this application. This field is only filled if template method is 'helm'. |
| `failures` _integer_ | Failures counts the number of failed installation or updagrade. it is reset on successful reconciliation. |


[Back to top](#top)



### ApplicationRef



ApplicationRef describes a KKP-wide, unique reference to an Application.

_Appears in:_
- [ApplicationInstallationSpec](#applicationinstallationspec)

| Field | Description |
| --- | --- |
| `name` _string_ | Name of the Application.
Should be a valid lowercase RFC1123 domain name |
| `version` _string_ | Version of the Application. Must be a valid SemVer version |


[Back to top](#top)



### ApplicationSource





_Appears in:_
- [ApplicationTemplate](#applicationtemplate)

| Field | Description |
| --- | --- |
| `helm` _[HelmSource](#helmsource)_ | Install Application from a Helm repository |
| `git` _[GitSource](#gitsource)_ | Install application from a Git repository |


[Back to top](#top)



### ApplicationTemplate





_Appears in:_
- [ApplicationVersion](#applicationversion)

| Field | Description |
| --- | --- |
| `source` _[ApplicationSource](#applicationsource)_ | Defined how the source of the application (e.g Helm chart) is retrieved.
Exactly one type of source must be defined. |
| `templateCredentials` _[DependencyCredentials](#dependencycredentials)_ | DependencyCredentials holds the credentials that may be needed for templating the application. |


[Back to top](#top)



### ApplicationVersion





_Appears in:_
- [ApplicationDefinitionSpec](#applicationdefinitionspec)
- [ApplicationInstallationStatus](#applicationinstallationstatus)

| Field | Description |
| --- | --- |
| `version` _string_ | Version of the application (e.g. v1.2.3) |
| `template` _[ApplicationTemplate](#applicationtemplate)_ | Template defines how application is installed (source provenance, Method...) |


[Back to top](#top)



### DependencyCredentials





_Appears in:_
- [ApplicationTemplate](#applicationtemplate)

| Field | Description |
| --- | --- |
| `helmCredentials` _[HelmCredentials](#helmcredentials)_ | HelmCredentials holds the ref to the secret with helm credentials needed to build helm dependencies.
It is not required when using helm as a source, as dependencies are already prepackaged in this case.
It's either username / password or a registryConfigFile can be defined. |


[Back to top](#top)



### DeployOptions



DeployOptions holds the settings specific to the templating method used to deploy the application.

_Appears in:_
- [ApplicationDefinitionSpec](#applicationdefinitionspec)
- [ApplicationInstallationSpec](#applicationinstallationspec)

| Field | Description |
| --- | --- |
| `helm` _[HelmDeployOptions](#helmdeployoptions)_ |  |


[Back to top](#top)



### GitAuthMethod

_Underlying type:_ `string`



_Appears in:_
- [GitCredentials](#gitcredentials)



### GitCredentials





_Appears in:_
- [GitSource](#gitsource)

| Field | Description |
| --- | --- |
| `method` _[GitAuthMethod](#gitauthmethod)_ | Authentication method. Either password or token or ssh-key.
if method is password then username and password must be defined.
if method is token then token must be defined.
if method is ssh-key then ssh-key must be defined. |
| `username` _[SecretKeySelector](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#secretkeyselector-v1-core)_ | Username holds the ref and key in the secret for the username credential.
The Secret must exist in the namespace where KKP is installed (default is "kubermatic").
The Secret must be annotated with `apps.kubermatic.k8c.io/secret-type:` set to helm or git |
| `password` _[SecretKeySelector](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#secretkeyselector-v1-core)_ | Password holds the ref and key in the secret for the Password credential.
The Secret must exist in the namespace where KKP is installed (default is "kubermatic").
The Secret must be annotated with `apps.kubermatic.k8c.io/secret-type:` set to helm or git |
| `token` _[SecretKeySelector](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#secretkeyselector-v1-core)_ | Token holds the ref and key in the secret for the token credential.
The Secret must exist in the namespace where KKP is installed (default is "kubermatic").
The Secret must be annotated with `apps.kubermatic.k8c.io/secret-type:` set to helm or git |
| `sshKey` _[SecretKeySelector](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#secretkeyselector-v1-core)_ | SSHKey holds the ref and key in the secret for the SshKey credential.
The Secret must exist in the namespace where KKP is installed (default is "kubermatic").
The Secret must be annotated with `apps.kubermatic.k8c.io/secret-type:` set to helm or git |


[Back to top](#top)



### GitReference





_Appears in:_
- [GitSource](#gitsource)

| Field | Description |
| --- | --- |
| `branch` _string_ | Branch to checkout. Only the last commit of the branch will be checkout in order to reduce the amount of data to download. |
| `commit` _string_ | Commit SHA in a Branch to checkout.


It must be used in conjunction with branch field. |
| `tag` _string_ | Tag to check out.
It can not be used in conjunction with commit or branch. |


[Back to top](#top)



### GitSource





_Appears in:_
- [ApplicationSource](#applicationsource)

| Field | Description |
| --- | --- |
| `remote` _string_ | URL to the repository. Can be HTTP(s) (e.g. https://example.com/myrepo) or SSH (e.g. git://example.com[:port]/path/to/repo.git/) |
| `ref` _[GitReference](#gitreference)_ | Git reference to checkout.
For large repositories, we recommend to either use Tag, Branch or Branch+Commit. This allows a shallow clone, which dramatically speeds up performance |
| `path` _string_ | Path of the "source" in the repository. default is repository root |
| `credentials` _[GitCredentials](#gitcredentials)_ | Credentials are optional and holds the git credentials |


[Back to top](#top)



### HelmCredentials





_Appears in:_
- [DependencyCredentials](#dependencycredentials)
- [HelmSource](#helmsource)

| Field | Description |
| --- | --- |
| `username` _[SecretKeySelector](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#secretkeyselector-v1-core)_ | Username holds the ref and key in the secret for the username credential.
The Secret must exist in the namespace where KKP is installed (default is "kubermatic").
The Secret must be annotated with `apps.kubermatic.k8c.io/secret-type:` set to helm or git |
| `password` _[SecretKeySelector](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#secretkeyselector-v1-core)_ | Password holds the ref and key in the secret for the Password credential.
The Secret must exist in the namespace where KKP is installed (default is "kubermatic").
The Secret must be annotated with `apps.kubermatic.k8c.io/secret-type:` set to helm or git |
| `registryConfigFile` _[SecretKeySelector](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#secretkeyselector-v1-core)_ | RegistryConfigFile holds the ref and key in the secret for the registry credential file. The value is dockercfg
file that follows the same format rules as ~/.docker/config.json
The The Secret must exist in the namespace where KKP is installed (default is "kubermatic").
The Secret must be annotated with `apps.kubermatic.k8c.io/secret-type:` set to helm or git |


[Back to top](#top)



### HelmDeployOptions



HelmDeployOptions holds the deployment settings when templating method is Helm.

_Appears in:_
- [DeployOptions](#deployoptions)

| Field | Description |
| --- | --- |
| `wait` _boolean_ | Wait corresponds to the --wait flag on Helm cli.
if set, will wait until all Pods, PVCs, Services, and minimum number of Pods of a Deployment, StatefulSet, or ReplicaSet are in a ready state before marking the release as successful. It will wait for as long as timeout |
| `timeout` _[Duration](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#duration-v1-meta)_ | Timeout corresponds to the --timeout flag on Helm cli.
time to wait for any individual Kubernetes operation. |
| `atomic` _boolean_ | Atomic corresponds to the --atomic flag on Helm cli.
if set, the installation process deletes the installation on failure; the upgrade process rolls back changes made in case of failed upgrade. |
| `enableDNS` _boolean_ | EnableDNS  corresponds to the --enable-dns flag on Helm cli.
enable DNS lookups when rendering templates.
if you enable this flag, you have to verify that helm template function 'getHostByName' is not being used in a chart to disclose any information you do not want to be passed to DNS servers.(c.f. CVE-2023-25165) |


[Back to top](#top)



### HelmRelease





_Appears in:_
- [ApplicationInstallationStatus](#applicationinstallationstatus)

| Field | Description |
| --- | --- |
| `name` _string_ | Name is the name of the release. |
| `version` _integer_ | Version is an int which represents the revision of the release. |
| `info` _[HelmReleaseInfo](#helmreleaseinfo)_ | Info provides information about a release. |


[Back to top](#top)



### HelmReleaseInfo



HelmReleaseInfo describes release information.
tech note: we can not use release.Info from Helm because the underlying type used for time has no json tag.

_Appears in:_
- [HelmRelease](#helmrelease)

| Field | Description |
| --- | --- |
| `firstDeployed` _[Time](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#time-v1-meta)_ | FirstDeployed is when the release was first deployed. |
| `lastDeployed` _[Time](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#time-v1-meta)_ | LastDeployed is when the release was last deployed. |
| `deleted` _[Time](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#time-v1-meta)_ | Deleted tracks when this object was deleted. |
| `description` _string_ | Description is human-friendly "log entry" about this release. |
| `status` _[Status](#status)_ | Status is the current state of the release. |
| `notes` _string_ | Notes is  the rendered templates/NOTES.txt if available. |


[Back to top](#top)



### HelmSource





_Appears in:_
- [ApplicationSource](#applicationsource)

| Field | Description |
| --- | --- |
| `url` _string_ | URl of the helm repository.
It can be an HTTP(s) repository (e.g. https://localhost/myrepo) or on OCI repository (e.g. oci://localhost:5000/myrepo). |
| `chartName` _string_ | Name of the Chart. |
| `chartVersion` _string_ | Version of the Chart. |
| `credentials` _[HelmCredentials](#helmcredentials)_ | Credentials are optional and hold the ref to the secret with helm credentials.
Either username / Password or registryConfigFile can be defined. |


[Back to top](#top)



### TemplateMethod

_Underlying type:_ `string`



_Appears in:_
- [ApplicationDefinitionSpec](#applicationdefinitionspec)
- [ApplicationInstallationStatus](#applicationinstallationstatus)




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
- [ClusterBackupStorageLocation](#clusterbackupstoragelocation)
- [ClusterBackupStorageLocationList](#clusterbackupstoragelocationlist)
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
- [GroupProjectBinding](#groupprojectbinding)
- [GroupProjectBindingList](#groupprojectbindinglist)
- [IPAMAllocation](#ipamallocation)
- [IPAMAllocationList](#ipamallocationlist)
- [IPAMPool](#ipampool)
- [IPAMPoolList](#ipampoollist)
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
- [ResourceQuota](#resourcequota)
- [ResourceQuotaList](#resourcequotalist)
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
| `enabled` _boolean_ | Only enabled presets will be available in the KKP dashboard. |
| `datacenter` _string_ | If datacenter is set, this preset is only applicable to the
configured datacenter. |
| `tenantID` _string_ | The Azure Active Directory Tenant used for the user cluster. |
| `subscriptionID` _string_ | The Azure Subscription used for the user cluster. |
| `clientID` _string_ | The service principal used to access Azure. |
| `clientSecret` _string_ | The client secret corresponding to the given service principal. |


[Back to top](#top)



### APIServerSettings





_Appears in:_
- [ComponentSettings](#componentsettings)

| Field | Description |
| --- | --- |
| `replicas` _integer_ |  |
| `resources` _[ResourceRequirements](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#resourcerequirements-v1-core)_ |  |
| `tolerations` _[Toleration](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#toleration-v1-core) array_ |  |
| `endpointReconcilingDisabled` _boolean_ |  |
| `nodePortRange` _string_ |  |


[Back to top](#top)



### AWS





_Appears in:_
- [PresetSpec](#presetspec)

| Field | Description |
| --- | --- |
| `enabled` _boolean_ | Only enabled presets will be available in the KKP dashboard. |
| `datacenter` _string_ | If datacenter is set, this preset is only applicable to the
configured datacenter. |
| `accessKeyID` _string_ | The Access key ID used to authenticate against AWS. |
| `secretAccessKey` _string_ | The Secret Access Key used to authenticate against AWS. |
| `assumeRoleARN` _string_ | Defines the ARN for an IAM role that should be assumed when handling resources on AWS. It will be used
to acquire temporary security credentials using an STS AssumeRole API operation whenever creating an AWS session. |
| `assumeRoleExternalID` _string_ | An arbitrary string that may be needed when calling the STS AssumeRole API operation.
Using an external ID can help to prevent the "confused deputy problem". |
| `vpcID` _string_ | AWS VPC to use. Must be configured. |
| `routeTableID` _string_ | Route table to use. This can be configured, but if left empty will be
automatically filled in during reconciliation. |
| `instanceProfileName` _string_ | Instance profile to use. This can be configured, but if left empty will be
automatically filled in during reconciliation. |
| `securityGroupID` _string_ | Security group to use. This can be configured, but if left empty will be
automatically filled in during reconciliation. |
| `roleARN` _string_ | ARN to use. This can be configured, but if left empty will be
automatically filled in during reconciliation. |


[Back to top](#top)



### AWSCloudSpec



AWSCloudSpec specifies access data to Amazon Web Services.

_Appears in:_
- [CloudSpec](#cloudspec)

| Field | Description |
| --- | --- |
| `credentialsReference` _[GlobalSecretKeySelector](#globalsecretkeyselector)_ |  |
| `accessKeyID` _string_ | The Access key ID used to authenticate against AWS. |
| `secretAccessKey` _string_ | The Secret Access Key used to authenticate against AWS. |
| `assumeRoleARN` _string_ | Defines the ARN for an IAM role that should be assumed when handling resources on AWS. It will be used
to acquire temporary security credentials using an STS AssumeRole API operation whenever creating an AWS session. |
| `assumeRoleExternalID` _string_ | An arbitrary string that may be needed when calling the STS AssumeRole API operation.
Using an external ID can help to prevent the "confused deputy problem". |
| `vpcID` _string_ |  |
| `roleARN` _string_ | The IAM role, the control plane will use. The control plane will perform an assume-role |
| `routeTableID` _string_ |  |
| `instanceProfileName` _string_ |  |
| `securityGroupID` _string_ |  |
| `nodePortsAllowedIPRange` _string_ | A CIDR range that will be used to allow access to the node port range in the security group to. Only applies if
the security group is generated by KKP and not preexisting.
If NodePortsAllowedIPRange nor NodePortsAllowedIPRanges is set, the node port range can be accessed from anywhere. |
| `nodePortsAllowedIPRanges` _[NetworkRanges](#networkranges)_ | Optional: CIDR ranges that will be used to allow access to the node port range in the security group to. Only applies if
the security group is generated by KKP and not preexisting.
If NodePortsAllowedIPRange nor NodePortsAllowedIPRanges is set,  the node port range can be accessed from anywhere. |
| `disableIAMReconciling` _boolean_ | DisableIAMReconciling is used to disable reconciliation for IAM related configuration. This is useful in air-gapped
setups where access to IAM service is not possible. |


[Back to top](#top)



### Addon



Addon specifies a cluster addon. Addons can be installed into user clusters
to provide additional manifests for CNIs, CSIs or other applications, which makes
addons a necessary component to create functioning user clusters.
Addon objects must be created inside cluster namespaces.

_Appears in:_
- [AddonList](#addonlist)

| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `Addon`
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[AddonSpec](#addonspec)_ | Spec describes the desired addon state. |
| `status` _[AddonStatus](#addonstatus)_ | Status contains information about the reconciliation status. |


[Back to top](#top)



### AddonCondition





_Appears in:_
- [AddonStatus](#addonstatus)

| Field | Description |
| --- | --- |
| `status` _[ConditionStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#conditionstatus-v1-core)_ | Status of the condition, one of True, False, Unknown. |
| `lastHeartbeatTime` _[Time](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#time-v1-meta)_ | Last time we got an update on a given condition. |
| `lastTransitionTime` _[Time](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#time-v1-meta)_ | Last time the condition transitioned from one status to another. |


[Back to top](#top)



### AddonConditionType

_Underlying type:_ `string`



_Appears in:_
- [AddonStatus](#addonstatus)



### AddonConfig



AddonConfig specifies addon configuration. Addons can be installed without
a matching AddonConfig, but they will be missing a logo, description and
the potentially necessary form fields in the KKP dashboard to make the
addon comfortable to use.

_Appears in:_
- [AddonConfigList](#addonconfiglist)

| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `AddonConfig`
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[AddonConfigSpec](#addonconfigspec)_ | Spec describes the configuration of an addon. |


[Back to top](#top)



### AddonConfigList



AddonConfigList is a list of addon configs.



| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `AddonConfigList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[AddonConfig](#addonconfig) array_ | Items refers to the list of AddonConfig objects. |


[Back to top](#top)



### AddonConfigSpec



AddonConfigSpec specifies configuration of addon.

_Appears in:_
- [AddonConfig](#addonconfig)

| Field | Description |
| --- | --- |
| `shortDescription` _string_ | ShortDescription of the configured addon that contains more detailed information about the addon,
it will be displayed in the addon details view in the UI |
| `description` _string_ | Description of the configured addon, it will be displayed in the addon overview in the UI |
| `logo` _string_ | Logo of the configured addon, encoded in base64 |
| `logoFormat` _string_ | LogoFormat contains logo format of the configured addon, i.e. svg+xml |
| `formSpec` _[AddonFormControl](#addonformcontrol) array_ | Controls that can be set for configured addon |


[Back to top](#top)



### AddonFormControl



AddonFormControl specifies addon form control.

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



AddonList is a list of addons.



| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `AddonList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[Addon](#addon) array_ | Items refers to the list of the cluster addons. |


[Back to top](#top)



### AddonPhase

_Underlying type:_ `string`



_Appears in:_
- [AddonStatus](#addonstatus)



### AddonSpec



AddonSpec specifies details of an addon.

_Appears in:_
- [Addon](#addon)

| Field | Description |
| --- | --- |
| `name` _string_ | Name defines the name of the addon to install |
| `cluster` _[ObjectReference](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#objectreference-v1-core)_ | Cluster is the reference to the cluster the addon should be installed in |
| `variables` _[RawExtension](#rawextension)_ | Variables is free form data to use for parsing the manifest templates |
| `requiredResourceTypes` _[GroupVersionKind](#groupversionkind) array_ | RequiredResourceTypes allows to indicate that this addon needs some resource type before it
can be installed. This can be used to indicate that a specific CRD and/or extension
apiserver must be installed before this addon can be installed. The addon will not
be installed until that resource is served. |
| `isDefault` _boolean_ | IsDefault indicates whether the addon is installed because it was configured in
the default addon section in the KubermaticConfiguration. User-installed addons
must not set this field to true, as extra default Addon objects (that are not in
the KubermaticConfiguration) will be garbage-collected. |


[Back to top](#top)



### AddonStatus



AddonStatus contains information about the reconciliation status.

_Appears in:_
- [Addon](#addon)

| Field | Description |
| --- | --- |
| `phase` _[AddonPhase](#addonphase)_ | Phase is a description of the current addon status, summarizing the various conditions.
This field is for informational purpose only and no logic should be tied to the phase. |
| `conditions` _object (keys:[AddonConditionType](#addonconditiontype), values:[AddonCondition](#addoncondition))_ |  |


[Back to top](#top)



### AdmissionPlugin



AdmissionPlugin is the type representing a AdmissionPlugin.

_Appears in:_
- [AdmissionPluginList](#admissionpluginlist)

| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `AdmissionPlugin`
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[AdmissionPluginSpec](#admissionpluginspec)_ | Spec describes an admission plugin name and in which k8s version it is supported. |


[Back to top](#top)



### AdmissionPluginList



AdmissionPluginList is the type representing a AdmissionPluginList.



| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `AdmissionPluginList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[AdmissionPlugin](#admissionplugin) array_ | Items refers to the list of Admission Plugins |


[Back to top](#top)



### AdmissionPluginSpec



AdmissionPluginSpec specifies admission plugin name and from which k8s version is supported.

_Appears in:_
- [AdmissionPlugin](#admissionplugin)

| Field | Description |
| --- | --- |
| `pluginName` _string_ |  |
| `fromVersion` _[Semver](#semver)_ | FromVersion flag can be empty. It means the plugin fit to all k8s versions |


[Back to top](#top)



### Alertmanager





_Appears in:_
- [AlertmanagerList](#alertmanagerlist)

| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `Alertmanager`
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[AlertmanagerSpec](#alertmanagerspec)_ | Spec describes the configuration of the Alertmanager. |
| `status` _[AlertmanagerStatus](#alertmanagerstatus)_ | Status stores status information about the Alertmanager. |


[Back to top](#top)



### AlertmanagerConfigurationStatus



AlertmanagerConfigurationStatus stores status information about the AlertManager configuration.

_Appears in:_
- [AlertmanagerStatus](#alertmanagerstatus)

| Field | Description |
| --- | --- |
| `lastUpdated` _[Time](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#time-v1-meta)_ | LastUpdated stores the last successful time when the configuration was successfully applied |
| `status` _[ConditionStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#conditionstatus-v1-core)_ | Status of whether the configuration was applied, one of True, False |
| `errorMessage` _string_ | ErrorMessage contains a default error message in case the configuration could not be applied.
Will be reset if the error was resolved and condition becomes True |


[Back to top](#top)



### AlertmanagerList







| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `AlertmanagerList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[Alertmanager](#alertmanager) array_ | Items refers to the list of Alertmanager objects. |


[Back to top](#top)



### AlertmanagerSpec



AlertmanagerSpec describes the configuration of the Alertmanager.

_Appears in:_
- [Alertmanager](#alertmanager)

| Field | Description |
| --- | --- |
| `configSecret` _[LocalObjectReference](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#localobjectreference-v1-core)_ | ConfigSecret refers to the Secret in the same namespace as the Alertmanager object,
which contains configuration for this Alertmanager. |


[Back to top](#top)



### AlertmanagerStatus



AlertmanagerStatus stores status information about the AlertManager.

_Appears in:_
- [Alertmanager](#alertmanager)

| Field | Description |
| --- | --- |
| `configStatus` _[AlertmanagerConfigurationStatus](#alertmanagerconfigurationstatus)_ | ConfigStatus stores status information about the AlertManager configuration. |


[Back to top](#top)



### Alibaba





_Appears in:_
- [PresetSpec](#presetspec)

| Field | Description |
| --- | --- |
| `enabled` _boolean_ | Only enabled presets will be available in the KKP dashboard. |
| `datacenter` _string_ | If datacenter is set, this preset is only applicable to the
configured datacenter. |
| `accessKeyID` _string_ | The Access Key ID used to authenticate against Alibaba. |
| `accessKeySecret` _string_ | The Access Key Secret used to authenticate against Alibaba. |


[Back to top](#top)



### AlibabaCloudSpec



AlibabaCloudSpec specifies the access data to Alibaba.

_Appears in:_
- [CloudSpec](#cloudspec)

| Field | Description |
| --- | --- |
| `credentialsReference` _[GlobalSecretKeySelector](#globalsecretkeyselector)_ |  |
| `accessKeyID` _string_ | The Access Key ID used to authenticate against Alibaba. |
| `accessKeySecret` _string_ | The Access Key Secret used to authenticate against Alibaba. |


[Back to top](#top)



### AllowedRegistry



AllowedRegistry is the object representing an allowed registry.

_Appears in:_
- [AllowedRegistryList](#allowedregistrylist)

| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `AllowedRegistry`
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[AllowedRegistrySpec](#allowedregistryspec)_ | Spec describes the desired state for an allowed registry. |


[Back to top](#top)



### AllowedRegistryList



AllowedRegistryList specifies a list of allowed registries.



| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `AllowedRegistryList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[AllowedRegistry](#allowedregistry) array_ | Items refers to the list of the allowed registries. |


[Back to top](#top)



### AllowedRegistrySpec



AllowedRegistrySpec specifies the data for allowed registry spec.

_Appears in:_
- [AllowedRegistry](#allowedregistry)

| Field | Description |
| --- | --- |
| `registryPrefix` _string_ | RegistryPrefix contains the prefix of the registry which will be allowed. User clusters will be able to deploy
only images which are prefixed with one of the allowed image registry prefixes. |


[Back to top](#top)



### Anexia





_Appears in:_
- [PresetSpec](#presetspec)

| Field | Description |
| --- | --- |
| `enabled` _boolean_ | Only enabled presets will be available in the KKP dashboard. |
| `datacenter` _string_ | If datacenter is set, this preset is only applicable to the
configured datacenter. |
| `token` _string_ | Token is used to authenticate with the Anexia API. |


[Back to top](#top)



### AnexiaCloudSpec



AnexiaCloudSpec specifies the access data to Anexia.

_Appears in:_
- [CloudSpec](#cloudspec)

| Field | Description |
| --- | --- |
| `credentialsReference` _[GlobalSecretKeySelector](#globalsecretkeyselector)_ |  |
| `token` _string_ | Token is used to authenticate with the Anexia API. |


[Back to top](#top)



### AntiAffinityType

_Underlying type:_ `string`

AntiAffinityType is the type of anti-affinity that should be used. Can be "preferred"
or "required".

_Appears in:_
- [EtcdStatefulSetSettings](#etcdstatefulsetsettings)



### ApplicationSettings





_Appears in:_
- [ClusterSpec](#clusterspec)



### AuditLoggingSettings



AuditLoggingSettings configures audit logging functionality.

_Appears in:_
- [ClusterSpec](#clusterspec)

| Field | Description |
| --- | --- |
| `enabled` _boolean_ | Enabled will enable or disable audit logging. |
| `policyPreset` _[AuditPolicyPreset](#auditpolicypreset)_ | Optional: PolicyPreset can be set to utilize a pre-defined set of audit policy rules. |
| `sidecar` _[AuditSidecarSettings](#auditsidecarsettings)_ | Optional: Configures the fluent-bit sidecar deployed alongside kube-apiserver. |


[Back to top](#top)



### AuditPolicyPreset

_Underlying type:_ `string`

AuditPolicyPreset refers to a pre-defined set of audit policy rules. Supported values
are `metadata`, `recommended` and `minimal`. See KKP documentation for what each policy preset includes.

_Appears in:_
- [AuditLoggingSettings](#auditloggingsettings)



### AuditSidecarConfiguration



AuditSidecarConfiguration defines custom configuration for the fluent-bit sidecar deployed with a kube-apiserver.
Also see https://docs.fluentbit.io/manual/v/1.8/administration/configuring-fluent-bit/configuration-file.

_Appears in:_
- [AuditSidecarSettings](#auditsidecarsettings)

| Field | Description |
| --- | --- |
| `service` _object (keys:string, values:string)_ |  |
| `filters` _object array_ |  |
| `outputs` _object array_ |  |


[Back to top](#top)



### AuditSidecarSettings





_Appears in:_
- [AuditLoggingSettings](#auditloggingsettings)

| Field | Description |
| --- | --- |
| `resources` _[ResourceRequirements](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#resourcerequirements-v1-core)_ |  |
| `config` _[AuditSidecarConfiguration](#auditsidecarconfiguration)_ |  |


[Back to top](#top)



### Azure





_Appears in:_
- [PresetSpec](#presetspec)

| Field | Description |
| --- | --- |
| `enabled` _boolean_ | Only enabled presets will be available in the KKP dashboard. |
| `datacenter` _string_ | If datacenter is set, this preset is only applicable to the
configured datacenter. |
| `tenantID` _string_ | The Azure Active Directory Tenant used for the user cluster. |
| `subscriptionID` _string_ | The Azure Subscription used for the user cluster. |
| `clientID` _string_ | The service principal used to access Azure. |
| `clientSecret` _string_ | The client secret corresponding to the given service principal. |
| `resourceGroup` _string_ | The resource group that will be used to look up and create resources for the cluster in.
If set to empty string at cluster creation, a new resource group will be created and this field will be updated to
the generated resource group's name. |
| `vnetResourceGroup` _string_ | Optional: Defines a second resource group that will be used for VNet related resources instead.
If left empty, NO additional resource group will be created and all VNet related resources use the resource group defined by `resourceGroup`. |
| `vnet` _string_ | The name of the VNet resource used for setting up networking in.
If set to empty string at cluster creation, a new VNet will be created and this field will be updated to
the generated VNet's name. |
| `subnet` _string_ | The name of a subnet in the VNet referenced by `vnet`.
If set to empty string at cluster creation, a new subnet will be created and this field will be updated to
the generated subnet's name. If no VNet is defined at cluster creation, this field should be empty as well. |
| `routeTable` _string_ | The name of a route table associated with the subnet referenced by `subnet`.
If set to empty string at cluster creation, a new route table will be created and this field will be updated to
the generated route table's name. If no subnet is defined at cluster creation, this field should be empty as well. |
| `securityGroup` _string_ | The name of a security group associated with the subnet referenced by `subnet`.
If set to empty string at cluster creation, a new security group will be created and this field will be updated to
the generated security group's name. If no subnet is defined at cluster creation, this field should be empty as well. |
| `loadBalancerSKU` _[LBSKU](#lbsku)_ | LoadBalancerSKU sets the LB type that will be used for the Azure cluster, possible values are "basic" and "standard", if empty, "basic" will be used |


[Back to top](#top)



### AzureCloudSpec



AzureCloudSpec defines cloud resource references for Microsoft Azure.

_Appears in:_
- [CloudSpec](#cloudspec)

| Field | Description |
| --- | --- |
| `credentialsReference` _[GlobalSecretKeySelector](#globalsecretkeyselector)_ | CredentialsReference allows referencing a `Secret` resource instead of passing secret data in this spec. |
| `tenantID` _string_ | The Azure Active Directory Tenant used for this cluster.
Can be read from `credentialsReference` instead. |
| `subscriptionID` _string_ | The Azure Subscription used for this cluster.
Can be read from `credentialsReference` instead. |
| `clientID` _string_ | The service principal used to access Azure.
Can be read from `credentialsReference` instead. |
| `clientSecret` _string_ | The client secret corresponding to the given service principal.
Can be read from `credentialsReference` instead. |
| `resourceGroup` _string_ | The resource group that will be used to look up and create resources for the cluster in.
If set to empty string at cluster creation, a new resource group will be created and this field will be updated to
the generated resource group's name. |
| `vnetResourceGroup` _string_ | Optional: Defines a second resource group that will be used for VNet related resources instead.
If left empty, NO additional resource group will be created and all VNet related resources use the resource group defined by `resourceGroup`. |
| `vnet` _string_ | The name of the VNet resource used for setting up networking in.
If set to empty string at cluster creation, a new VNet will be created and this field will be updated to
the generated VNet's name. |
| `subnet` _string_ | The name of a subnet in the VNet referenced by `vnet`.
If set to empty string at cluster creation, a new subnet will be created and this field will be updated to
the generated subnet's name. If no VNet is defined at cluster creation, this field should be empty as well. |
| `routeTable` _string_ | The name of a route table associated with the subnet referenced by `subnet`.
If set to empty string at cluster creation, a new route table will be created and this field will be updated to
the generated route table's name. If no subnet is defined at cluster creation, this field should be empty as well. |
| `securityGroup` _string_ | The name of a security group associated with the subnet referenced by `subnet`.
If set to empty string at cluster creation, a new security group will be created and this field will be updated to
the generated security group's name. If no subnet is defined at cluster creation, this field should be empty as well. |
| `nodePortsAllowedIPRange` _string_ | A CIDR range that will be used to allow access to the node port range in the security group to. Only applies if
the security group is generated by KKP and not preexisting.
If NodePortsAllowedIPRange nor NodePortsAllowedIPRanges is set, the node port range can be accessed from anywhere. |
| `nodePortsAllowedIPRanges` _[NetworkRanges](#networkranges)_ | Optional: CIDR ranges that will be used to allow access to the node port range in the security group to. Only applies if
the security group is generated by KKP and not preexisting.
If NodePortsAllowedIPRange nor NodePortsAllowedIPRanges is set,  the node port range can be accessed from anywhere. |
| `assignAvailabilitySet` _boolean_ | Optional: AssignAvailabilitySet determines whether KKP creates and assigns an AvailabilitySet to machines.
Defaults to `true` internally if not set. |
| `availabilitySet` _string_ | An availability set that will be associated with nodes created for this cluster. If this field is set to empty string
at cluster creation and `AssignAvailabilitySet` is set to `true`, a new availability set will be created and this field
will be updated to the generated availability set's name. |
| `loadBalancerSKU` _[LBSKU](#lbsku)_ | LoadBalancerSKU sets the LB type that will be used for the Azure cluster, possible values are "basic" and "standard", if empty, "basic" will be used. |


[Back to top](#top)



### BackupConfig





_Appears in:_
- [ClusterSpec](#clusterspec)

| Field | Description |
| --- | --- |
| `backupStorageLocation` _[LocalObjectReference](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#localobjectreference-v1-core)_ |  |


[Back to top](#top)



### BackupDestination



BackupDestination defines the bucket name and endpoint as a backup destination, and holds reference to the credentials secret.

_Appears in:_
- [EtcdBackupRestore](#etcdbackuprestore)

| Field | Description |
| --- | --- |
| `endpoint` _string_ | Endpoint is the API endpoint to use for backup and restore. |
| `bucketName` _string_ | BucketName is the bucket name to use for backup and restore. |
| `credentials` _[SecretReference](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#secretreference-v1-core)_ | Credentials hold the ref to the secret with backup credentials |


[Back to top](#top)



### BackupStatus





_Appears in:_
- [EtcdBackupConfigStatus](#etcdbackupconfigstatus)

| Field | Description |
| --- | --- |
| `scheduledTime` _[Time](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#time-v1-meta)_ | ScheduledTime will always be set when the BackupStatus is created, so it'll never be nil |
| `backupName` _string_ |  |
| `jobName` _string_ |  |
| `backupStartTime` _[Time](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#time-v1-meta)_ |  |
| `backupFinishedTime` _[Time](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#time-v1-meta)_ |  |
| `backupPhase` _[BackupStatusPhase](#backupstatusphase)_ |  |
| `backupMessage` _string_ |  |
| `deleteJobName` _string_ |  |
| `deleteStartTime` _[Time](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#time-v1-meta)_ |  |
| `deleteFinishedTime` _[Time](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#time-v1-meta)_ |  |
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





### CIDR

_Underlying type:_ `string`



_Appears in:_
- [EnvoyLoadBalancerService](#envoyloadbalancerservice)



### CNIPluginSettings



CNIPluginSettings contains the spec of the CNI plugin used by the Cluster.

_Appears in:_
- [ClusterSpec](#clusterspec)

| Field | Description |
| --- | --- |
| `type` _[CNIPluginType](#cniplugintype)_ | Type is the CNI plugin type to be used. |
| `version` _string_ | Version defines the CNI plugin version to be used. This varies by chosen CNI plugin type. |


[Back to top](#top)



### CNIPluginType

_Underlying type:_ `string`

CNIPluginType defines the type of CNI plugin installed.
Possible values are `canal`, `cilium` or `none`.

_Appears in:_
- [CNIPluginSettings](#cnipluginsettings)



### CleanupOptions





_Appears in:_
- [SettingSpec](#settingspec)

| Field | Description |
| --- | --- |
| `enabled` _boolean_ | Enable checkboxes that allow the user to ask for LoadBalancers and PVCs
to be deleted in order to not leave potentially expensive resources behind. |
| `enforced` _boolean_ | If enforced is set to true, the cleanup of LoadBalancers and PVCs is
enforced. |


[Back to top](#top)



### CloudSpec



CloudSpec stores configuration options for a given cloud provider. Provider specs are mutually exclusive.

_Appears in:_
- [ClusterSpec](#clusterspec)

| Field | Description |
| --- | --- |
| `dc` _string_ | DatacenterName states the name of a cloud provider "datacenter" (defined in `Seed` resources)
this cluster should be deployed into. |
| `providerName` _string_ | ProviderName is the name of the cloud provider used for this cluster.
This must match the given provider spec (e.g. if the providerName is
"aws", then the `aws` field must be set). |
| `digitalocean` _[DigitaloceanCloudSpec](#digitaloceancloudspec)_ | Digitalocean defines the configuration data of the DigitalOcean cloud provider. |
| `bringyourown` _[BringYourOwnCloudSpec](#bringyourowncloudspec)_ | BringYourOwn defines the configuration data for a Bring Your Own cluster. |
| `edge` _[EdgeCloudSpec](#edgecloudspec)_ | Edge defines the configuration data for an edge cluster. |
| `aws` _[AWSCloudSpec](#awscloudspec)_ | AWS defines the configuration data of the Amazon Web Services(AWS) cloud provider. |
| `azure` _[AzureCloudSpec](#azurecloudspec)_ | Azure defines the configuration data of the Microsoft Azure cloud. |
| `openstack` _[OpenstackCloudSpec](#openstackcloudspec)_ | Openstack defines the configuration data of an OpenStack cloud. |
| `packet` _[PacketCloudSpec](#packetcloudspec)_ | Packet defines the configuration data of a Packet cloud. |
| `hetzner` _[HetznerCloudSpec](#hetznercloudspec)_ | Hetzner defines the configuration data of the Hetzner cloud. |
| `vsphere` _[VSphereCloudSpec](#vspherecloudspec)_ | VSphere defines the configuration data of the vSphere. |
| `gcp` _[GCPCloudSpec](#gcpcloudspec)_ | GCP defines the configuration data of the Google Cloud Platform(GCP). |
| `kubevirt` _[KubevirtCloudSpec](#kubevirtcloudspec)_ | Kubevirt defines the configuration data of the KubeVirt. |
| `alibaba` _[AlibabaCloudSpec](#alibabacloudspec)_ | Alibaba defines the configuration data of the Alibaba. |
| `anexia` _[AnexiaCloudSpec](#anexiacloudspec)_ | Anexia defines the configuration data of the Anexia. |
| `nutanix` _[NutanixCloudSpec](#nutanixcloudspec)_ | Nutanix defines the configuration data of the Nutanix. |
| `vmwareclouddirector` _[VMwareCloudDirectorCloudSpec](#vmwareclouddirectorcloudspec)_ | VMwareCloudDirector defines the configuration data of the VMware Cloud Director. |


[Back to top](#top)



### Cluster



Cluster represents a Kubermatic Kubernetes Platform user cluster.
Cluster objects exist on Seed clusters and each user cluster consists
of a namespace containing the Kubernetes control plane and additional
pods (like Prometheus or the machine-controller).

_Appears in:_
- [ClusterList](#clusterlist)

| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `Cluster`
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[ClusterSpec](#clusterspec)_ | Spec describes the desired cluster state. |
| `status` _[ClusterStatus](#clusterstatus)_ | Status contains reconciliation information for the cluster. |


[Back to top](#top)



### ClusterAddress



ClusterAddress stores access and address information of a cluster.

_Appears in:_
- [ClusterStatus](#clusterstatus)

| Field | Description |
| --- | --- |
| `url` _string_ | URL under which the Apiserver is available |
| `port` _integer_ | Port is the port the API server listens on |
| `externalName` _string_ | ExternalName is the DNS name for this cluster |
| `internalURL` _string_ | InternalName is the seed cluster internal absolute DNS name to the API server |
| `adminToken` _string_ | AdminToken is the token for the kubeconfig, the user can download |
| `ip` _string_ | IP is the external IP under which the apiserver is available |


[Back to top](#top)



### ClusterBackupStorageLocation



ClusterBackupStorageLocation is a KKP wrapper around Velero BSL spec.

_Appears in:_
- [ClusterBackupStorageLocationList](#clusterbackupstoragelocationlist)

| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `ClusterBackupStorageLocation`
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[BackupStorageLocationSpec](#backupstoragelocationspec)_ | Spec is a Velero BSL spec |
| `status` _[BackupStorageLocationStatus](#backupstoragelocationstatus)_ |  |


[Back to top](#top)



### ClusterBackupStorageLocationList



ClusterBackupStorageLocationList is a list of ClusterBackupStorageLocations.



| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `ClusterBackupStorageLocationList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[ClusterBackupStorageLocation](#clusterbackupstoragelocation) array_ | Items is a list of EtcdBackupConfig objects. |


[Back to top](#top)



### ClusterCondition





_Appears in:_
- [ClusterStatus](#clusterstatus)

| Field | Description |
| --- | --- |
| `status` _[ConditionStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#conditionstatus-v1-core)_ | Status of the condition, one of True, False, Unknown. |
| `kubermaticVersion` _string_ | KubermaticVersion current kubermatic version. |
| `lastHeartbeatTime` _[Time](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#time-v1-meta)_ | Last time we got an update on a given condition. |
| `lastTransitionTime` _[Time](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#time-v1-meta)_ | Last time the condition transit from one status to another. |
| `reason` _string_ | (brief) reason for the condition's last transition. |
| `message` _string_ | Human readable message indicating details about last transition. |


[Back to top](#top)



### ClusterConditionType

_Underlying type:_ `string`

ClusterConditionType is used to indicate the type of a cluster condition. For all condition
types, the `true` value must indicate success. All condition types must be registered within
the `AllClusterConditionTypes` variable.

_Appears in:_
- [ClusterStatus](#clusterstatus)



### ClusterEncryptionPhase

_Underlying type:_ `string`



_Appears in:_
- [ClusterEncryptionStatus](#clusterencryptionstatus)



### ClusterEncryptionStatus



ClusterEncryptionStatus holds status information about the encryption-at-rest feature on the user cluster.

_Appears in:_
- [ClusterStatus](#clusterstatus)

| Field | Description |
| --- | --- |
| `activeKey` _string_ | The current "primary" key used to encrypt data written to etcd. Secondary keys that can be used for decryption
(but not encryption) might be configured in the ClusterSpec. |
| `encryptedResources` _string array_ | List of resources currently encrypted. |
| `phase` _[ClusterEncryptionPhase](#clusterencryptionphase)_ | The current phase of the encryption process. Can be one of `Pending`, `Failed`, `Active` or `EncryptionNeeded`.
The `encryption_controller` logic will process the cluster based on the current phase and issue necessary changes
to make sure encryption on the cluster is active and updated with what the ClusterSpec defines. |


[Back to top](#top)



### ClusterList



ClusterList specifies a list of user clusters.



| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `ClusterList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[Cluster](#cluster) array_ |  |


[Back to top](#top)



### ClusterNetworkingConfig



ClusterNetworkingConfig specifies the different networking
parameters for a cluster.

_Appears in:_
- [ClusterSpec](#clusterspec)

| Field | Description |
| --- | --- |
| `ipFamily` _[IPFamily](#ipfamily)_ | Optional: IP family used for cluster networking. Supported values are "", "IPv4" or "IPv4+IPv6".
Can be omitted / empty if pods and services network ranges are specified.
In that case it defaults according to the IP families of the provided network ranges.
If neither ipFamily nor pods & services network ranges are specified, defaults to "IPv4". |
| `services` _[NetworkRanges](#networkranges)_ | The network ranges from which service VIPs are allocated.
It can contain one IPv4 and/or one IPv6 CIDR.
If both address families are specified, the first one defines the primary address family. |
| `pods` _[NetworkRanges](#networkranges)_ | The network ranges from which POD networks are allocated.
It can contain one IPv4 and/or one IPv6 CIDR.
If both address families are specified, the first one defines the primary address family. |
| `nodeCidrMaskSizeIPv4` _integer_ | NodeCIDRMaskSizeIPv4 is the mask size used to address the nodes within provided IPv4 Pods CIDR.
It has to be larger than the provided IPv4 Pods CIDR. Defaults to 24. |
| `nodeCidrMaskSizeIPv6` _integer_ | NodeCIDRMaskSizeIPv6 is the mask size used to address the nodes within provided IPv6 Pods CIDR.
It has to be larger than the provided IPv6 Pods CIDR. Defaults to 64. |
| `dnsDomain` _string_ | Domain name for services. |
| `proxyMode` _string_ | ProxyMode defines the kube-proxy mode ("ipvs" / "iptables" / "ebpf").
Defaults to "ipvs". "ebpf" disables kube-proxy and requires CNI support. |
| `ipvs` _[IPVSConfiguration](#ipvsconfiguration)_ | IPVS defines kube-proxy ipvs configuration options |
| `nodeLocalDNSCacheEnabled` _boolean_ | NodeLocalDNSCacheEnabled controls whether the NodeLocal DNS Cache feature is enabled.
Defaults to true. |
| `coreDNSReplicas` _integer_ | CoreDNSReplicas is the number of desired pods of user cluster coredns deployment. |
| `konnectivityEnabled` _boolean_ | Deprecated: KonnectivityEnabled enables konnectivity for controlplane to node network communication.
As OpenVPN will be removed in the future KKP versions, clusters with konnectivity disabled will not be supported.
All existing clusters with OpenVPN should migrate to the Konnectivity. |
| `tunnelingAgentIP` _string_ | TunnelingAgentIP is the address used by the tunneling agents |


[Back to top](#top)



### ClusterPhase

_Underlying type:_ `string`



_Appears in:_
- [ClusterStatus](#clusterstatus)



### ClusterSpec



ClusterSpec describes the desired state of a user cluster.

_Appears in:_
- [Cluster](#cluster)
- [ClusterTemplate](#clustertemplate)

| Field | Description |
| --- | --- |
| `humanReadableName` _string_ | HumanReadableName is the cluster name provided by the user. |
| `version` _[Semver](#semver)_ | Version defines the wanted version of the control plane. |
| `cloud` _[CloudSpec](#cloudspec)_ | Cloud contains information regarding the cloud provider that
is responsible for hosting the cluster's workload. |
| `containerRuntime` _string_ | ContainerRuntime to use, i.e. `docker` or `containerd`. By default `containerd` will be used. |
| `imagePullSecret` _[SecretReference](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#secretreference-v1-core)_ | Optional: ImagePullSecret references a secret with container registry credentials. This is passed to the machine-controller which sets the registry credentials on node level. |
| `cniPlugin` _[CNIPluginSettings](#cnipluginsettings)_ | Optional: CNIPlugin refers to the spec of the CNI plugin used by the Cluster. |
| `clusterNetwork` _[ClusterNetworkingConfig](#clusternetworkingconfig)_ | Optional: ClusterNetwork specifies the different networking parameters for a cluster. |
| `machineNetworks` _[MachineNetworkingConfig](#machinenetworkingconfig) array_ | Optional: MachineNetworks is the list of the networking parameters used for IPAM. |
| `exposeStrategy` _[ExposeStrategy](#exposestrategy)_ | ExposeStrategy is the strategy used to expose a cluster control plane. |
| `apiServerAllowedIPRanges` _[NetworkRanges](#networkranges)_ | Optional: APIServerAllowedIPRanges is a list of IP ranges allowed to access the API server.
Applicable only if the expose strategy of the cluster is LoadBalancer.
If not configured, access to the API server is unrestricted. |
| `componentsOverride` _[ComponentSettings](#componentsettings)_ | Optional: Component specific overrides that allow customization of control plane components. |
| `oidc` _[OIDCSettings](#oidcsettings)_ | Optional: OIDC specifies the OIDC configuration parameters for enabling authentication mechanism for the cluster. |
| `features` _object (keys:string, values:boolean)_ | A map of optional or early-stage features that can be enabled for the user cluster.
Some feature gates cannot be disabled after being enabled.
The available feature gates vary based on KKP version, Kubernetes version and Seed configuration.
Please consult the KKP documentation for specific feature gates. |
| `updateWindow` _[UpdateWindow](#updatewindow)_ | Optional: UpdateWindow configures automatic update systems to respect a maintenance window for
applying OS updates to nodes. This is only respected on Flatcar nodes currently. |
| `usePodSecurityPolicyAdmissionPlugin` _boolean_ | Enables the admission plugin `PodSecurityPolicy`. This plugin is deprecated by Kubernetes. |
| `usePodNodeSelectorAdmissionPlugin` _boolean_ | Enables the admission plugin `PodNodeSelector`. Needs additional configuration via the `podNodeSelectorAdmissionPluginConfig` field. |
| `useEventRateLimitAdmissionPlugin` _boolean_ | Enables the admission plugin `EventRateLimit`. Needs additional configuration via the `eventRateLimitConfig` field.
This plugin is considered "alpha" by Kubernetes. |
| `admissionPlugins` _string array_ | A list of arbitrary admission plugin names that are passed to kube-apiserver. Must not include admission plugins
that can be enabled via a separate setting. |
| `podNodeSelectorAdmissionPluginConfig` _object (keys:string, values:string)_ | Optional: Provides configuration for the PodNodeSelector admission plugin (needs plugin enabled
via `usePodNodeSelectorAdmissionPlugin`). It's used by the backend to create a configuration file for this plugin.
The key:value from this map is converted to <namespace>:<node-selectors-labels> in the file. Use `clusterDefaultNodeSelector`
as key to configure a default node selector. |
| `eventRateLimitConfig` _[EventRateLimitConfig](#eventratelimitconfig)_ | Optional: Configures the EventRateLimit admission plugin (if enabled via `useEventRateLimitAdmissionPlugin`)
to create limits on Kubernetes event generation. The EventRateLimit plugin is capable of comparing and rate limiting incoming
`Events` based on several configured buckets. |
| `enableUserSSHKeyAgent` _boolean_ | Optional: Deploys the UserSSHKeyAgent to the user cluster. This field is immutable.
If enabled, the agent will be deployed and used to sync user ssh keys attached by users to the cluster.
No SSH keys will be synced after node creation if this is disabled. |
| `enableOperatingSystemManager` _boolean_ | Optional: Enables operating-system-manager (OSM), which is responsible for creating and managing worker node configuration.
This field is enabled(true) by default. |
| `kubelb` _[KubeLB](#kubelb)_ | KubeLB holds the configuration for the kubeLB component.
Only available in Enterprise Edition. |
| `kubernetesDashboard` _[KubernetesDashboard](#kubernetesdashboard)_ | KubernetesDashboard holds the configuration for the kubernetes-dashboard component. |
| `auditLogging` _[AuditLoggingSettings](#auditloggingsettings)_ | Optional: AuditLogging configures Kubernetes API audit logging (https://kubernetes.io/docs/tasks/debug-application-cluster/audit/)
for the user cluster. |
| `opaIntegration` _[OPAIntegrationSettings](#opaintegrationsettings)_ | Optional: OPAIntegration is a preview feature that enables OPA integration for the cluster.
Enabling it causes OPA Gatekeeper and its resources to be deployed on the user cluster.
By default it is disabled. |
| `serviceAccount` _[ServiceAccountSettings](#serviceaccountsettings)_ | Optional: ServiceAccount contains service account related settings for the user cluster's kube-apiserver. |
| `mla` _[MLASettings](#mlasettings)_ | Optional: MLA contains monitoring, logging and alerting related settings for the user cluster. |
| `applicationSettings` _[ApplicationSettings](#applicationsettings)_ | Optional: ApplicationSettings contains the settings relative to the application feature. |
| `encryptionConfiguration` _[EncryptionConfiguration](#encryptionconfiguration)_ | Optional: Configures encryption-at-rest for Kubernetes API data. This needs the `encryptionAtRest` feature gate. |
| `pause` _boolean_ | If this is set to true, the cluster will not be reconciled by KKP.
This indicates that the user needs to do some action to resolve the pause. |
| `pauseReason` _string_ | PauseReason is the reason why the cluster is not being managed. This field is for informational
purpose only and can be set by a user or a controller to communicate the reason for pausing the cluster. |
| `debugLog` _boolean_ | Enables more verbose logging in KKP's user-cluster-controller-manager. |
| `disableCsiDriver` _boolean_ | Optional: DisableCSIDriver disables the installation of CSI driver on the cluster
If this is true at the data center then it can't be over-written in the cluster configuration |
| `backupConfig` _[BackupConfig](#backupconfig)_ | Optional: BackupConfig contains the configuration options for managing the Cluster Backup Velero integration feature. |


[Back to top](#top)



### ClusterStatus



ClusterStatus stores status information about a cluster.

_Appears in:_
- [Cluster](#cluster)

| Field | Description |
| --- | --- |
| `address` _[ClusterAddress](#clusteraddress)_ | Address contains the IPs/URLs to access the cluster control plane. |
| `lastUpdated` _[Time](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#time-v1-meta)_ | Deprecated: LastUpdated contains the timestamp at which the cluster was last modified.
It is kept only for KKP 2.20 release to not break the backwards-compatibility and not being set for KKP higher releases. |
| `extendedHealth` _[ExtendedClusterHealth](#extendedclusterhealth)_ | ExtendedHealth exposes information about the current health state.
Extends standard health status for new states. |
| `lastProviderReconciliation` _[Time](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#time-v1-meta)_ | LastProviderReconciliation is the time when the cloud provider resources
were last fully reconciled (during normal cluster reconciliation, KKP does
not re-check things like security groups, networks etc.). |
| `namespaceName` _string_ | NamespaceName defines the namespace the control plane of this cluster is deployed in. |
| `versions` _[ClusterVersionsStatus](#clusterversionsstatus)_ | Versions contains information regarding the current and desired versions
of the cluster control plane and worker nodes. |
| `userName` _string_ | Deprecated: UserName contains the name of the owner of this cluster.
This field is not actively used and will be removed in the future. |
| `userEmail` _string_ | UserEmail contains the email of the owner of this cluster.
During cluster creation only, this field will be used to bind the `cluster-admin` `ClusterRole` to a cluster owner. |
| `errorReason` _[ClusterStatusError](#clusterstatuserror)_ | ErrorReason contains a error reason in case the controller encountered an error. Will be reset if the error was resolved. |
| `errorMessage` _string_ | ErrorMessage contains a default error message in case the controller encountered an error. Will be reset if the error was resolved. |
| `conditions` _object (keys:[ClusterConditionType](#clusterconditiontype), values:[ClusterCondition](#clustercondition))_ | Conditions contains conditions the cluster is in, its primary use case is status signaling between controllers or between
controllers and the API. |
| `phase` _[ClusterPhase](#clusterphase)_ | Phase is a description of the current cluster status, summarizing the various conditions,
possible active updates etc. This field is for informational purpose only and no logic
should be tied to the phase. |
| `inheritedLabels` _object (keys:string, values:string)_ | InheritedLabels are labels the cluster inherited from the project. They are read-only for users. |
| `encryption` _[ClusterEncryptionStatus](#clusterencryptionstatus)_ | Encryption describes the status of the encryption-at-rest feature for encrypted data in etcd. |
| `resourceUsage` _[ResourceDetails](#resourcedetails)_ | ResourceUsage shows the current usage of resources for the cluster. |


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
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `clusterLabels` _object (keys:string, values:string)_ |  |
| `inheritedClusterLabels` _object (keys:string, values:string)_ |  |
| `credential` _string_ |  |
| `userSSHKeys` _[ClusterTemplateSSHKey](#clustertemplatesshkey) array_ | UserSSHKeys is the list of SSH public keys that should be assigned to all nodes in the cluster. |
| `spec` _[ClusterSpec](#clusterspec)_ | Spec describes the desired state of a user cluster. |


[Back to top](#top)



### ClusterTemplateInstance



ClusterTemplateInstance is the object representing a cluster template instance.

_Appears in:_
- [ClusterTemplateInstanceList](#clustertemplateinstancelist)

| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `ClusterTemplateInstance`
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[ClusterTemplateInstanceSpec](#clustertemplateinstancespec)_ | Spec specifies the data for cluster instances. |


[Back to top](#top)



### ClusterTemplateInstanceList



ClusterTemplateInstanceList specifies a list of cluster template instances.



| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `ClusterTemplateInstanceList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[ClusterTemplateInstance](#clustertemplateinstance) array_ | Items refers to the list of ClusterTemplateInstance objects. |


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



ClusterTemplateList specifies a list of cluster templates.



| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `ClusterTemplateList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[ClusterTemplate](#clustertemplate) array_ | Items refers to the list of the ClusterTemplate objects. |


[Back to top](#top)



### ClusterTemplateSSHKey



ClusterTemplateSSHKey is the object for holding SSH key.

_Appears in:_
- [ClusterTemplate](#clustertemplate)

| Field | Description |
| --- | --- |
| `id` _string_ | ID is the name of the UserSSHKey object that is supposed to be assigned
to any ClusterTemplateInstance created based on this template. |
| `name` _string_ | Name is the human readable SSH key name. |


[Back to top](#top)



### ClusterVersionsStatus



ClusterVersionsStatus contains information regarding the current and desired versions
of the cluster control plane and worker nodes.

_Appears in:_
- [ClusterStatus](#clusterstatus)

| Field | Description |
| --- | --- |
| `controlPlane` _[Semver](#semver)_ | ControlPlane is the currently active cluster version. This can lag behind the apiserver
version if an update is currently rolling out. |
| `apiserver` _[Semver](#semver)_ | Apiserver is the currently desired version of the kube-apiserver. During
upgrades across multiple minor versions (e.g. from 1.20 to 1.23), this will gradually
be increased by the update-controller until the desired cluster version (spec.version)
is reached. |
| `controllerManager` _[Semver](#semver)_ | ControllerManager is the currently desired version of the kube-controller-manager. This
field behaves the same as the apiserver field. |
| `scheduler` _[Semver](#semver)_ | Scheduler is the currently desired version of the kube-scheduler. This field behaves the
same as the apiserver field. |
| `oldestNodeVersion` _[Semver](#semver)_ | OldestNodeVersion is the oldest node version currently in use inside the cluster. This can be
nil if there are no nodes. This field is primarily for speeding up reconciling, so that
the controller doesn't have to re-fetch to the usercluster and query its node on every
reconciliation. |


[Back to top](#top)



### ComponentSettings





_Appears in:_
- [ClusterSpec](#clusterspec)
- [SeedSpec](#seedspec)

| Field | Description |
| --- | --- |
| `apiserver` _[APIServerSettings](#apiserversettings)_ | Apiserver configures kube-apiserver settings. |
| `controllerManager` _[ControllerSettings](#controllersettings)_ | ControllerManager configures kube-controller-manager settings. |
| `scheduler` _[ControllerSettings](#controllersettings)_ | Scheduler configures kube-scheduler settings. |
| `etcd` _[EtcdStatefulSetSettings](#etcdstatefulsetsettings)_ | Etcd configures the etcd ring used to store Kubernetes data. |
| `prometheus` _[StatefulSetSettings](#statefulsetsettings)_ | Prometheus configures the Prometheus instance deployed into the cluster control plane. |
| `nodePortProxyEnvoy` _[NodeportProxyComponent](#nodeportproxycomponent)_ | NodePortProxyEnvoy configures the per-cluster nodeport-proxy-envoy that is deployed if
the `LoadBalancer` expose strategy is used. This is not effective if a different expose
strategy is configured. |
| `konnectivityProxy` _[KonnectivityProxySettings](#konnectivityproxysettings)_ | KonnectivityProxy configures konnectivity-server and konnectivity-agent components. |
| `userClusterController` _[ControllerSettings](#controllersettings)_ | UserClusterController configures the KKP usercluster-controller deployed as part of the cluster control plane. |
| `operatingSystemManager` _[ControllerSettings](#controllersettings)_ | OperatingSystemManager configures operating-system-manager (the component generating node bootstrap scripts for machine-controller). |


[Back to top](#top)



### ConditionType

_Underlying type:_ `string`

ConditionType is the type defining the cluster or datacenter condition that must be met to block a specific version.

_Appears in:_
- [Incompatibility](#incompatibility)



### Constraint



Constraint specifies a kubermatic wrapper for the gatekeeper constraints.

_Appears in:_
- [ConstraintList](#constraintlist)

| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `Constraint`
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[ConstraintSpec](#constraintspec)_ | Spec describes the desired state for the constraint. |


[Back to top](#top)



### ConstraintList



ConstraintList specifies a list of constraints.



| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `ConstraintList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[Constraint](#constraint) array_ | Items is a list of Gatekeeper Constraints |


[Back to top](#top)



### ConstraintSelector



ConstraintSelector is the object holding the cluster selection filters.

_Appears in:_
- [ConstraintSpec](#constraintspec)

| Field | Description |
| --- | --- |
| `providers` _string array_ | Providers is a list of cloud providers to which the Constraint applies to. Empty means all providers are selected. |
| `labelSelector` _[LabelSelector](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#labelselector-v1-meta)_ | LabelSelector selects the Clusters to which the Constraint applies based on their labels |


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
| `parameters` _[Parameters](#parameters)_ | Parameters specifies the parameters used by the constraint template REGO.
It supports both the legacy rawJSON parameters, in which all the parameters are set in a JSON string, and regular
parameters like in Gatekeeper Constraints.
If rawJSON is set, during constraint syncing to the user cluster, the other parameters are ignored
Example with rawJSON parameters:


parameters:
  rawJSON: '{"labels":["gatekeeper"]}'


And with regular parameters:


parameters:
  labels: ["gatekeeper"] |
| `selector` _[ConstraintSelector](#constraintselector)_ | Selector specifies the cluster selection filters |
| `enforcementAction` _string_ | EnforcementAction defines the action to take in response to a constraint being violated.
By default, EnforcementAction is set to deny as the default behavior is to deny admission requests with any violation. |


[Back to top](#top)



### ConstraintTemplate



ConstraintTemplate is the object representing a kubermatic wrapper for a gatekeeper constraint template.

_Appears in:_
- [ConstraintTemplateList](#constrainttemplatelist)

| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `ConstraintTemplate`
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[ConstraintTemplateSpec](#constrainttemplatespec)_ | Spec specifies the gatekeeper constraint template and KKP related spec. |


[Back to top](#top)



### ConstraintTemplateList



ConstraintTemplateList specifies a list of constraint templates.



| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `ConstraintTemplateList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[ConstraintTemplate](#constrainttemplate) array_ | Items refers to the list of ConstraintTemplate objects. |


[Back to top](#top)



### ConstraintTemplateSelector



ConstraintTemplateSelector is the object holding the cluster selection filters.

_Appears in:_
- [ConstraintTemplateSpec](#constrainttemplatespec)

| Field | Description |
| --- | --- |
| `providers` _string array_ | Providers is a list of cloud providers to which the Constraint Template applies to. Empty means all providers are selected. |
| `labelSelector` _[LabelSelector](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#labelselector-v1-meta)_ | LabelSelector selects the Clusters to which the Constraint Template applies based on their labels |


[Back to top](#top)



### ConstraintTemplateSpec



ConstraintTemplateSpec is the object representing the gatekeeper constraint template spec and kubermatic related spec.

_Appears in:_
- [ConstraintTemplate](#constrainttemplate)

| Field | Description |
| --- | --- |
| `crd` _[CRD](#crd)_ |  |
| `targets` _Target array_ |  |
| `selector` _[ConstraintTemplateSelector](#constrainttemplateselector)_ | Selector configures which clusters this constraint template is applied to. |


[Back to top](#top)



### ContainerRuntimeContainerd



ContainerRuntimeContainerd defines containerd container runtime registries configs.

_Appears in:_
- [NodeSettings](#nodesettings)

| Field | Description |
| --- | --- |
| `registries` _object (keys:string, values:[ContainerdRegistry](#containerdregistry))_ | A map of registries to use to render configs and mirrors for containerd registries |


[Back to top](#top)





### ControllerSettings





_Appears in:_
- [ComponentSettings](#componentsettings)

| Field | Description |
| --- | --- |
| `replicas` _integer_ |  |
| `resources` _[ResourceRequirements](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#resourcerequirements-v1-core)_ |  |
| `tolerations` _[Toleration](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#toleration-v1-core) array_ |  |
| `leaderElection` _[LeaderElectionSettings](#leaderelectionsettings)_ |  |


[Back to top](#top)



### CustomLink





_Appears in:_
- [CustomLinks](#customlinks)

| Field | Description |
| --- | --- |
| `label` _string_ |  |
| `url` _string_ |  |
| `icon` _string_ |  |
| `location` _string_ |  |


[Back to top](#top)



### CustomLinks

_Underlying type:_ `[CustomLink](#customlink)`



_Appears in:_
- [SettingSpec](#settingspec)

| Field | Description |
| --- | --- |
| `label` _string_ |  |
| `url` _string_ |  |
| `icon` _string_ |  |
| `location` _string_ |  |


[Back to top](#top)



### CustomNetworkPolicy

_Underlying type:_ `[struct{Name string "json:\"name\""; Spec k8s.io/api/networking/v1.NetworkPolicySpec "json:\"spec\""}](#struct{name-string-"json:\"name\"";-spec-k8sioapinetworkingv1networkpolicyspec-"json:\"spec\""})`

CustomNetworkPolicy contains a name and the Spec of a NetworkPolicy.

_Appears in:_
- [DatacenterSpecKubevirt](#datacenterspeckubevirt)



### Datacenter





_Appears in:_
- [SeedSpec](#seedspec)

| Field | Description |
| --- | --- |
| `country` _string_ | Optional: Country of the seed as ISO-3166 two-letter code, e.g. DE or UK.
For informational purposes in the Kubermatic dashboard only. |
| `location` _string_ | Optional: Detailed location of the cluster, like "Hamburg" or "Datacenter 7".
For informational purposes in the Kubermatic dashboard only. |
| `node` _[NodeSettings](#nodesettings)_ | Node holds node-specific settings, like e.g. HTTP proxy, Docker
registries and the like. Proxy settings are inherited from the seed if
not specified here. |
| `spec` _[DatacenterSpec](#datacenterspec)_ | Spec describes the cloud provider settings used to manage resources
in this datacenter. Exactly one cloud provider must be defined. |


[Back to top](#top)



### DatacenterSpec



DatacenterSpec configures a KKP datacenter. Provider configuration is mutually exclusive,
and as such only a single provider can be configured per datacenter.

_Appears in:_
- [Datacenter](#datacenter)

| Field | Description |
| --- | --- |
| `digitalocean` _[DatacenterSpecDigitalocean](#datacenterspecdigitalocean)_ | Digitalocean configures a Digitalocean datacenter. |
| `bringyourown` _[DatacenterSpecBringYourOwn](#datacenterspecbringyourown)_ | BringYourOwn contains settings for clusters using manually created
nodes via kubeadm. |
| `edge` _[DatacenterSpecEdge](#datacenterspecedge)_ | Edge contains settings for clusters using manually created
nodes in edge envs. |
| `aws` _[DatacenterSpecAWS](#datacenterspecaws)_ | AWS configures an Amazon Web Services (AWS) datacenter. |
| `azure` _[DatacenterSpecAzure](#datacenterspecazure)_ | Azure configures an Azure datacenter. |
| `openstack` _[DatacenterSpecOpenstack](#datacenterspecopenstack)_ | Openstack configures an Openstack datacenter. |
| `packet` _[DatacenterSpecPacket](#datacenterspecpacket)_ | Packet configures an Equinix Metal datacenter. |
| `hetzner` _[DatacenterSpecHetzner](#datacenterspechetzner)_ | Hetzner configures a Hetzner datacenter. |
| `vsphere` _[DatacenterSpecVSphere](#datacenterspecvsphere)_ | VSphere configures a VMware vSphere datacenter. |
| `vmwareclouddirector` _[DatacenterSpecVMwareCloudDirector](#datacenterspecvmwareclouddirector)_ | VMwareCloudDirector configures a VMware Cloud Director datacenter. |
| `gcp` _[DatacenterSpecGCP](#datacenterspecgcp)_ | GCP configures a Google Cloud Platform (GCP) datacenter. |
| `kubevirt` _[DatacenterSpecKubevirt](#datacenterspeckubevirt)_ | Kubevirt configures a KubeVirt datacenter. |
| `alibaba` _[DatacenterSpecAlibaba](#datacenterspecalibaba)_ | Alibaba configures an Alibaba Cloud datacenter. |
| `anexia` _[DatacenterSpecAnexia](#datacenterspecanexia)_ | Anexia configures an Anexia datacenter. |
| `nutanix` _[DatacenterSpecNutanix](#datacenterspecnutanix)_ | Nutanix configures a Nutanix HCI datacenter. |
| `requiredEmails` _string array_ | Optional: When defined, only users with an e-mail address on the
given domains can make use of this datacenter. You can define multiple
domains, e.g. "example.com", one of which must match the email domain
exactly (i.e. "example.com" will not match "user@test.example.com"). |
| `enforceAuditLogging` _boolean_ | Optional: EnforceAuditLogging enforces audit logging on every cluster within the DC,
ignoring cluster-specific settings. |
| `enforcePodSecurityPolicy` _boolean_ | Optional: EnforcePodSecurityPolicy enforces pod security policy plugin on every clusters within the DC,
ignoring cluster-specific settings. |
| `providerReconciliationInterval` _[Duration](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#duration-v1-meta)_ | Optional: ProviderReconciliationInterval is the time that must have passed since a
Cluster's status.lastProviderReconciliation to make the cliuster controller
perform an in-depth provider reconciliation, where for example missing security
groups will be reconciled.
Setting this too low can cause rate limits by the cloud provider, setting this
too high means that *if* a resource at a cloud provider is removed/changed outside
of KKP, it will take this long to fix it. |
| `operatingSystemProfiles` _[OperatingSystemProfileList](#operatingsystemprofilelist)_ | Optional: DefaultOperatingSystemProfiles specifies the OperatingSystemProfiles to use for each supported operating system. |
| `machineFlavorFilter` _[MachineFlavorFilter](#machineflavorfilter)_ | Optional: MachineFlavorFilter is used to filter out allowed machine flavors based on the specified resource limits like CPU, Memory, and GPU etc. |
| `disableCsiDriver` _boolean_ | Optional: DisableCSIDriver disables the installation of CSI driver on every clusters within the DC
If true it can't be over-written in the cluster configuration |
| `kubelb` _[KubeLBDatacenterSettings](#kubelbdatacentersettings)_ | Optional: KubeLB holds the configuration for the kubeLB at the data center level.
Only available in Enterprise Edition. |


[Back to top](#top)



### DatacenterSpecAWS



DatacenterSpecAWS describes an AWS datacenter.

_Appears in:_
- [DatacenterSpec](#datacenterspec)

| Field | Description |
| --- | --- |
| `region` _string_ | The AWS region to use, e.g. "us-east-1". For a list of available regions, see
https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html |
| `images` _[ImageList](#imagelist)_ | List of AMIs to use for a given operating system.
This gets defaulted by querying for the latest AMI for the given distribution
when machines are created, so under normal circumstances it is not necessary
to define the AMIs statically. |


[Back to top](#top)



### DatacenterSpecAlibaba



DatacenterSpecAlibaba describes a alibaba datacenter.

_Appears in:_
- [DatacenterSpec](#datacenterspec)

| Field | Description |
| --- | --- |
| `region` _string_ | Region to use, for a full list of regions see
https://www.alibabacloud.com/help/doc-detail/40654.htm |


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



DatacenterSpecAzure describes an Azure cloud datacenter.

_Appears in:_
- [DatacenterSpec](#datacenterspec)

| Field | Description |
| --- | --- |
| `location` _string_ | Region to use, for example "westeurope". A list of available regions can be
found at https://azure.microsoft.com/en-us/global-infrastructure/locations/ |


[Back to top](#top)



### DatacenterSpecBringYourOwn



DatacenterSpecBringYourOwn describes a datacenter our of bring your own nodes.

_Appears in:_
- [DatacenterSpec](#datacenterspec)



### DatacenterSpecDigitalocean



DatacenterSpecDigitalocean describes a DigitalOcean datacenter.

_Appears in:_
- [DatacenterSpec](#datacenterspec)

| Field | Description |
| --- | --- |
| `region` _string_ | Datacenter location, e.g. "ams3". A list of existing datacenters can be found
at https://www.digitalocean.com/docs/platform/availability-matrix/ |


[Back to top](#top)



### DatacenterSpecEdge



DatacenterSpecEdge describes a datacenter of edge nodes.

_Appears in:_
- [DatacenterSpec](#datacenterspec)



### DatacenterSpecGCP



DatacenterSpecGCP describes a GCP datacenter.

_Appears in:_
- [DatacenterSpec](#datacenterspec)

| Field | Description |
| --- | --- |
| `region` _string_ | Region to use, for example "europe-west3", for a full list of regions see
https://cloud.google.com/compute/docs/regions-zones/ |
| `zoneSuffixes` _string array_ | List of enabled zones, for example [a, c]. See the link above for the available
zones in your chosen region. |
| `regional` _boolean_ | Optional: Regional clusters spread their resources across multiple availability zones.
Refer to the official documentation for more details on this:
https://cloud.google.com/kubernetes-engine/docs/concepts/regional-clusters |


[Back to top](#top)



### DatacenterSpecHetzner



DatacenterSpecHetzner describes a Hetzner cloud datacenter.

_Appears in:_
- [DatacenterSpec](#datacenterspec)

| Field | Description |
| --- | --- |
| `datacenter` _string_ | Datacenter location, e.g. "nbg1-dc3". A list of existing datacenters can be found
at https://docs.hetzner.com/general/others/data-centers-and-connection/ |
| `network` _string_ | Network is the pre-existing Hetzner network in which the machines are running.
While machines can be in multiple networks, a single one must be chosen for the
HCloud CCM to work. |
| `location` _string_ | Optional: Detailed location of the datacenter, like "Hamburg" or "Datacenter 7".
For informational purposes only. |


[Back to top](#top)



### DatacenterSpecKubevirt



DatacenterSpecKubevirt describes a kubevirt datacenter.

_Appears in:_
- [DatacenterSpec](#datacenterspec)

| Field | Description |
| --- | --- |
| `dnsPolicy` _string_ | DNSPolicy represents the dns policy for the pod. Valid values are 'ClusterFirstWithHostNet', 'ClusterFirst',
'Default' or 'None'. Defaults to "ClusterFirst". DNS parameters given in DNSConfig will be merged with the
policy selected with DNSPolicy. |
| `dnsConfig` _[PodDNSConfig](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#poddnsconfig-v1-core)_ | DNSConfig represents the DNS parameters of a pod. Parameters specified here will be merged to the generated DNS
configuration based on DNSPolicy. |
| `enableDefaultNetworkPolicies` _boolean_ | Optional: EnableDefaultNetworkPolicies enables deployment of default network policies like cluster isolation.
Defaults to true. |
| `customNetworkPolicies` _[CustomNetworkPolicy](#customnetworkpolicy) array_ | Optional: CustomNetworkPolicies allows to add some extra custom NetworkPolicies, that are deployed
in the dedicated infra KubeVirt cluster. They are added to the defaults. |
| `images` _[KubeVirtImageSources](#kubevirtimagesources)_ | Images represents standard VM Image sources. |
| `infraStorageClasses` _[KubeVirtInfraStorageClass](#kubevirtinfrastorageclass) array_ | Optional: InfraStorageClasses contains a list of KubeVirt infra cluster StorageClasses names
that will be used to initialise StorageClasses in the tenant cluster.
In the tenant cluster, the created StorageClass name will have as name:
kubevirt-<infra-storageClass-name> |


[Back to top](#top)



### DatacenterSpecNutanix



DatacenterSpecNutanix describes a Nutanix datacenter.

_Appears in:_
- [DatacenterSpec](#datacenterspec)

| Field | Description |
| --- | --- |
| `endpoint` _string_ | Endpoint to use for accessing Nutanix Prism Central. No protocol or port should be passed,
for example "nutanix.example.com" or "10.0.0.1" |
| `port` _integer_ | Optional: Port to use when connecting to the Nutanix Prism Central endpoint (defaults to 9440) |
| `allowInsecure` _boolean_ | Optional: AllowInsecure allows to disable the TLS certificate check against the endpoint (defaults to false) |
| `images` _[ImageList](#imagelist)_ | Images to use for each supported operating system |


[Back to top](#top)



### DatacenterSpecOpenstack



DatacenterSpecOpenstack describes an OpenStack datacenter.

_Appears in:_
- [DatacenterSpec](#datacenterspec)

| Field | Description |
| --- | --- |
| `authURL` _string_ | Authentication URL |
| `availabilityZone` _string_ | Used to configure availability zone. |
| `region` _string_ | Authentication region name |
| `ignoreVolumeAZ` _boolean_ | Optional |
| `enforceFloatingIP` _boolean_ | Optional |
| `dnsServers` _string array_ | Used for automatic network creation |
| `images` _[ImageList](#imagelist)_ | Images to use for each supported operating system. |
| `manageSecurityGroups` _boolean_ | Optional: Gets mapped to the "manage-security-groups" setting in the cloud config.
This setting defaults to true. |
| `useOctavia` _boolean_ | Optional: Gets mapped to the "use-octavia" setting in the cloud config.
use-octavia is enabled by default in CCM since v1.17.0, and disabled by
default with the in-tree cloud provider. |
| `trustDevicePath` _boolean_ | Optional: Gets mapped to the "trust-device-path" setting in the cloud config.
This setting defaults to false. |
| `nodeSizeRequirements` _[OpenstackNodeSizeRequirements](#openstacknodesizerequirements)_ | Optional: Restrict the allowed VM configurations that can be chosen in
the KKP dashboard. This setting does not affect the validation webhook for
MachineDeployments. |
| `enabledFlavors` _string array_ | Optional: List of enabled flavors for the given datacenter |
| `ipv6Enabled` _boolean_ | Optional: defines if the IPv6 is enabled for the datacenter |
| `csiCinderTopologyEnabled` _boolean_ | Optional: configures enablement of topology support for the Cinder CSI Plugin.
This requires Nova and Cinder to have matching availability zones configured. |


[Back to top](#top)



### DatacenterSpecPacket



DatacenterSpecPacket describes a Packet datacenter.

_Appears in:_
- [DatacenterSpec](#datacenterspec)

| Field | Description |
| --- | --- |
| `facilities` _string array_ | The list of enabled facilities, for example "ams1", for a full list of available
facilities see https://metal.equinix.com/developers/docs/locations/facilities/ |
| `metro` _string_ | Metros are facilities that are grouped together geographically and share capacity
and networking features, see https://metal.equinix.com/developers/docs/locations/metros/ |


[Back to top](#top)



### DatacenterSpecVMwareCloudDirector





_Appears in:_
- [DatacenterSpec](#datacenterspec)

| Field | Description |
| --- | --- |
| `url` _string_ | Endpoint URL to use, including protocol, for example "https://vclouddirector.example.com". |
| `allowInsecure` _boolean_ | If set to true, disables the TLS certificate check against the endpoint. |
| `catalog` _string_ | The default catalog which contains the VM templates. |
| `storageProfile` _string_ | The name of the storage profile to use for disks attached to the VMs. |
| `templates` _[ImageList](#imagelist)_ | A list of VM templates to use for a given operating system. You must
define at least one template. |


[Back to top](#top)



### DatacenterSpecVSphere



DatacenterSpecVSphere describes a vSphere datacenter.

_Appears in:_
- [DatacenterSpec](#datacenterspec)

| Field | Description |
| --- | --- |
| `endpoint` _string_ | Endpoint URL to use, including protocol, for example "https://vcenter.example.com". |
| `allowInsecure` _boolean_ | If set to true, disables the TLS certificate check against the endpoint. |
| `datastore` _string_ | The default Datastore to be used for provisioning volumes using storage
classes/dynamic provisioning and for storing virtual machine files in
case no `Datastore` or `DatastoreCluster` is provided at Cluster level. |
| `datacenter` _string_ | The name of the datacenter to use. |
| `cluster` _string_ | The name of the vSphere cluster to use. Used for out-of-tree CSI Driver. |
| `storagePolicy` _string_ | The name of the storage policy to use for the storage class created in the user cluster. |
| `rootPath` _string_ | Optional: The root path for cluster specific VM folders. Each cluster gets its own
folder below the root folder. Must be the FQDN (for example
"/datacenter-1/vm/all-kubermatic-vms-in-here") and defaults to the root VM
folder: "/datacenter-1/vm" |
| `templates` _[ImageList](#imagelist)_ | A list of VM templates to use for a given operating system. You must
define at least one template.
See: https://github.com/kubermatic/machine-controller/blob/master/docs/vsphere.md#template-vms-preparation |
| `infraManagementUser` _[VSphereCredentials](#vspherecredentials)_ | Optional: Infra management user is the user that will be used for everything
except the cloud provider functionality, which will still use the credentials
passed in via the Kubermatic dashboard/API. |
| `ipv6Enabled` _boolean_ | Optional: defines if the IPv6 is enabled for the datacenter |
| `defaultTagCategoryID` _string_ | DefaultTagCategoryID is the tag category id that will be used as default, if users don't specify it on a cluster level,
and they don't wish KKP to create default generated tag category, upon cluster creation. |


[Back to top](#top)



### DefaultProjectResourceQuota



DefaultProjectResourceQuota contains the default resource quota which will be set for all
projects that do not have a custom quota already set.

_Appears in:_
- [SettingSpec](#settingspec)

| Field | Description |
| --- | --- |
| `quota` _[ResourceDetails](#resourcedetails)_ | Quota specifies the default CPU, Memory and Storage quantities for all the projects. |


[Back to top](#top)



### DeploymentSettings





_Appears in:_
- [APIServerSettings](#apiserversettings)
- [ControllerSettings](#controllersettings)

| Field | Description |
| --- | --- |
| `replicas` _integer_ |  |
| `resources` _[ResourceRequirements](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#resourcerequirements-v1-core)_ |  |
| `tolerations` _[Toleration](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#toleration-v1-core) array_ |  |


[Back to top](#top)



### Digitalocean





_Appears in:_
- [PresetSpec](#presetspec)

| Field | Description |
| --- | --- |
| `enabled` _boolean_ | Only enabled presets will be available in the KKP dashboard. |
| `datacenter` _string_ | If datacenter is set, this preset is only applicable to the
configured datacenter. |
| `token` _string_ | Token is used to authenticate with the DigitalOcean API. |


[Back to top](#top)



### DigitaloceanCloudSpec



DigitaloceanCloudSpec specifies access data to DigitalOcean.

_Appears in:_
- [CloudSpec](#cloudspec)

| Field | Description |
| --- | --- |
| `credentialsReference` _[GlobalSecretKeySelector](#globalsecretkeyselector)_ |  |
| `token` _string_ | Token is used to authenticate with the DigitalOcean API. |


[Back to top](#top)



### EKS





_Appears in:_
- [PresetSpec](#presetspec)

| Field | Description |
| --- | --- |
| `enabled` _boolean_ | Only enabled presets will be available in the KKP dashboard. |
| `datacenter` _string_ | If datacenter is set, this preset is only applicable to the
configured datacenter. |
| `accessKeyID` _string_ | The Access key ID used to authenticate against AWS. |
| `secretAccessKey` _string_ | The Secret Access Key used to authenticate against AWS. |
| `assumeRoleARN` _string_ | Defines the ARN for an IAM role that should be assumed when handling resources on AWS. It will be used
to acquire temporary security credentials using an STS AssumeRole API operation whenever creating an AWS session.
required: false |
| `assumeRoleExternalID` _string_ | An arbitrary string that may be needed when calling the STS AssumeRole API operation.
Using an external ID can help to prevent the "confused deputy problem".
required: false |


[Back to top](#top)



### EdgeCloudSpec



EdgeCloudSpec specifies access data for an edge cluster.

_Appears in:_
- [CloudSpec](#cloudspec)



### EncryptionConfiguration



EncryptionConfiguration configures encryption-at-rest for Kubernetes API data.

_Appears in:_
- [ClusterSpec](#clusterspec)

| Field | Description |
| --- | --- |
| `enabled` _boolean_ | Enables encryption-at-rest on this cluster. |
| `resources` _string array_ | List of resources that will be stored encrypted in etcd. |
| `secretbox` _[SecretboxEncryptionConfiguration](#secretboxencryptionconfiguration)_ | Configuration for the `secretbox` static key encryption scheme as supported by Kubernetes.
More info: https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/#providers |


[Back to top](#top)



### EnvoyLoadBalancerService





_Appears in:_
- [NodePortProxyComponentEnvoy](#nodeportproxycomponentenvoy)

| Field | Description |
| --- | --- |
| `annotations` _object (keys:string, values:string)_ | Annotations are used to further tweak the LoadBalancer integration with the
cloud provider. |
| `sourceRanges` _[CIDR](#cidr) array_ | SourceRanges will restrict loadbalancer service to IP ranges specified using CIDR notation like 172.25.0.0/16.
This field will be ignored if the cloud-provider does not support the feature.
More info: https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/ |


[Back to top](#top)



### EtcdBackupConfig



EtcdBackupConfig describes how snapshots of user cluster etcds should be performed. Each user cluster
automatically gets a default EtcdBackupConfig in its cluster namespace.

_Appears in:_
- [EtcdBackupConfigList](#etcdbackupconfiglist)

| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `EtcdBackupConfig`
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[EtcdBackupConfigSpec](#etcdbackupconfigspec)_ | Spec describes details of an Etcd backup. |
| `status` _[EtcdBackupConfigStatus](#etcdbackupconfigstatus)_ |  |


[Back to top](#top)



### EtcdBackupConfigCondition





_Appears in:_
- [EtcdBackupConfigStatus](#etcdbackupconfigstatus)

| Field | Description |
| --- | --- |
| `status` _[ConditionStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#conditionstatus-v1-core)_ | Status of the condition, one of True, False, Unknown. |
| `lastHeartbeatTime` _[Time](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#time-v1-meta)_ | Last time we got an update on a given condition. |
| `lastTransitionTime` _[Time](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#time-v1-meta)_ | Last time the condition transit from one status to another. |
| `reason` _string_ | (brief) reason for the condition's last transition. |
| `message` _string_ | Human readable message indicating details about last transition. |


[Back to top](#top)



### EtcdBackupConfigConditionType

_Underlying type:_ `string`

EtcdBackupConfigConditionType is used to indicate the type of a EtcdBackupConfig condition. For all condition
types, the `true` value must indicate success. All condition types must be registered within
the `AllClusterConditionTypes` variable.

_Appears in:_
- [EtcdBackupConfigStatus](#etcdbackupconfigstatus)



### EtcdBackupConfigList



EtcdBackupConfigList is a list of etcd backup configs.



| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `EtcdBackupConfigList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[EtcdBackupConfig](#etcdbackupconfig) array_ | Items is a list of EtcdBackupConfig objects. |


[Back to top](#top)



### EtcdBackupConfigSpec



EtcdBackupConfigSpec specifies details of an etcd backup.

_Appears in:_
- [EtcdBackupConfig](#etcdbackupconfig)

| Field | Description |
| --- | --- |
| `name` _string_ | Name defines the name of the backup
The name of the backup file in S3 will be <cluster>-<backup name>
If a schedule is set (see below), -<timestamp> will be appended. |
| `cluster` _[ObjectReference](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#objectreference-v1-core)_ | Cluster is the reference to the cluster whose etcd will be backed up |
| `schedule` _string_ | Schedule is a cron expression defining when to perform
the backup. If not set, the backup is performed exactly
once, immediately. |
| `keep` _integer_ | Keep is the number of backups to keep around before deleting the oldest one
If not set, defaults to DefaultKeptBackupsCount. Only used if Schedule is set. |
| `destination` _string_ | Destination indicates where the backup will be stored. The destination name must correspond to a destination in
the cluster's Seed.Spec.EtcdBackupRestore. |


[Back to top](#top)



### EtcdBackupConfigStatus





_Appears in:_
- [EtcdBackupConfig](#etcdbackupconfig)

| Field | Description |
| --- | --- |
| `currentBackups` _[BackupStatus](#backupstatus) array_ | CurrentBackups tracks the creation and deletion progress of all backups managed by the EtcdBackupConfig |
| `conditions` _object (keys:[EtcdBackupConfigConditionType](#etcdbackupconfigconditiontype), values:[EtcdBackupConfigCondition](#etcdbackupconfigcondition))_ | Conditions contains conditions of the EtcdBackupConfig |
| `cleanupRunning` _boolean_ | If the controller was configured with a cleanupContainer, CleanupRunning keeps track of the corresponding job |


[Back to top](#top)



### EtcdBackupRestore



EtcdBackupRestore holds the configuration of the automatic backup and restores.

_Appears in:_
- [SeedSpec](#seedspec)

| Field | Description |
| --- | --- |
| `destinations` _object (keys:string, values:[BackupDestination](#backupdestination))_ | Destinations stores all the possible destinations where the backups for the Seed can be stored. If not empty,
it enables automatic backup and restore for the seed. |
| `defaultDestination` _string_ | DefaultDestination marks the default destination that will be used for the default etcd backup config which is
created for every user cluster. Has to correspond to a destination in Destinations.
If removed, it removes the related default etcd backup configs. |


[Back to top](#top)



### EtcdRestore



EtcdRestore specifies an add-on.

_Appears in:_
- [EtcdRestoreList](#etcdrestorelist)

| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `EtcdRestore`
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[EtcdRestoreSpec](#etcdrestorespec)_ | Spec describes details of an etcd restore. |
| `status` _[EtcdRestoreStatus](#etcdrestorestatus)_ |  |


[Back to top](#top)



### EtcdRestoreList



EtcdRestoreList is a list of etcd restores.



| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `EtcdRestoreList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[EtcdRestore](#etcdrestore) array_ | Items is the list of the Etcd restores. |


[Back to top](#top)



### EtcdRestorePhase

_Underlying type:_ `string`

EtcdRestorePhase represents the lifecycle phase of an EtcdRestore.

_Appears in:_
- [EtcdRestoreStatus](#etcdrestorestatus)



### EtcdRestoreSpec



EtcdRestoreSpec specifies details of an etcd restore.

_Appears in:_
- [EtcdRestore](#etcdrestore)

| Field | Description |
| --- | --- |
| `name` _string_ | Name defines the name of the restore
The name of the restore file in S3 will be <cluster>-<restore name>
If a schedule is set (see below), -<timestamp> will be appended. |
| `cluster` _[ObjectReference](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#objectreference-v1-core)_ | Cluster is the reference to the cluster whose etcd will be backed up |
| `backupName` _string_ | BackupName is the name of the backup to restore from |
| `backupDownloadCredentialsSecret` _string_ | BackupDownloadCredentialsSecret is the name of a secret in the cluster-xxx namespace containing
credentials needed to download the backup |
| `destination` _string_ | Destination indicates where the backup was stored. The destination name should correspond to a destination in
the cluster's Seed.Spec.EtcdBackupRestore. If empty, it will use the legacy destination configured in Seed.Spec.BackupRestore |


[Back to top](#top)



### EtcdRestoreStatus





_Appears in:_
- [EtcdRestore](#etcdrestore)

| Field | Description |
| --- | --- |
| `phase` _[EtcdRestorePhase](#etcdrestorephase)_ |  |
| `restoreTime` _[Time](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#time-v1-meta)_ |  |


[Back to top](#top)



### EtcdStatefulSetSettings





_Appears in:_
- [ComponentSettings](#componentsettings)

| Field | Description |
| --- | --- |
| `clusterSize` _integer_ | ClusterSize is the number of replicas created for etcd. This should be an
odd number to guarantee consensus, e.g. 3, 5 or 7. |
| `storageClass` _string_ | StorageClass is the Kubernetes StorageClass used for persistent storage
which stores the etcd WAL and other data persisted across restarts. Defaults to
`kubermatic-fast` (the global default). |
| `resources` _[ResourceRequirements](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#resourcerequirements-v1-core)_ | Resources allows to override the resource requirements for etcd Pods. |
| `tolerations` _[Toleration](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#toleration-v1-core) array_ | Tolerations allows to override the scheduling tolerations for etcd Pods. |
| `hostAntiAffinity` _[AntiAffinityType](#antiaffinitytype)_ | HostAntiAffinity allows to enforce a certain type of host anti-affinity on etcd
pods. Options are "preferred" (default) and "required". Please note that
enforcing anti-affinity via "required" can mean that pods are never scheduled. |
| `zoneAntiAffinity` _[AntiAffinityType](#antiaffinitytype)_ | ZoneAntiAffinity allows to enforce a certain type of availability zone anti-affinity on etcd
pods. Options are "preferred" (default) and "required". Please note that
enforcing anti-affinity via "required" can mean that pods are never scheduled. |
| `nodeSelector` _object (keys:string, values:string)_ | NodeSelector is a selector which restricts the set of nodes where etcd Pods can run. |


[Back to top](#top)



### EventRateLimitConfig



EventRateLimitConfig configures the `EventRateLimit` admission plugin.
More info: https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#eventratelimit

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

ExposeStrategy is the strategy used to expose a cluster control plane.
Possible values are `NodePort`, `LoadBalancer` or `Tunneling` (requires a feature gate).

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
| `openvpn` _[HealthStatus](#healthstatus)_ |  Deprecated: OpenVPN will be removed entirely in the future. |
| `konnectivity` _[HealthStatus](#healthstatus)_ |  |
| `cloudProviderInfrastructure` _[HealthStatus](#healthstatus)_ |  |
| `userClusterControllerManager` _[HealthStatus](#healthstatus)_ |  |
| `applicationController` _[HealthStatus](#healthstatus)_ |  |
| `gatekeeperController` _[HealthStatus](#healthstatus)_ |  |
| `gatekeeperAudit` _[HealthStatus](#healthstatus)_ |  |
| `monitoring` _[HealthStatus](#healthstatus)_ |  |
| `logging` _[HealthStatus](#healthstatus)_ |  |
| `alertmanagerConfig` _[HealthStatus](#healthstatus)_ |  |
| `mlaGateway` _[HealthStatus](#healthstatus)_ |  |
| `operatingSystemManager` _[HealthStatus](#healthstatus)_ |  |
| `kubernetesDashboard` _[HealthStatus](#healthstatus)_ |  |
| `kubelb` _[HealthStatus](#healthstatus)_ |  |


[Back to top](#top)



### ExternalCluster



ExternalCluster is the object representing an external kubernetes cluster.

_Appears in:_
- [ExternalClusterList](#externalclusterlist)

| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `ExternalCluster`
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[ExternalClusterSpec](#externalclusterspec)_ | Spec describes the desired cluster state. |
| `status` _[ExternalClusterStatus](#externalclusterstatus)_ | Status contains reconciliation information for the cluster. |


[Back to top](#top)



### ExternalClusterAKSCloudSpec





_Appears in:_
- [ExternalClusterCloudSpec](#externalclustercloudspec)

| Field | Description |
| --- | --- |
| `credentialsReference` _[GlobalSecretKeySelector](#globalsecretkeyselector)_ | CredentialsReference allows referencing a `Secret` resource instead of passing secret data in this spec. |
| `name` _string_ |  |
| `tenantID` _string_ | The Azure Active Directory Tenant used for this cluster.
Can be read from `credentialsReference` instead. |
| `subscriptionID` _string_ | The Azure Subscription used for this cluster.
Can be read from `credentialsReference` instead. |
| `clientID` _string_ | The service principal used to access Azure.
Can be read from `credentialsReference` instead. |
| `clientSecret` _string_ | The client secret corresponding to the given service principal.
Can be read from `credentialsReference` instead. |
| `location` _string_ | The geo-location where the resource lives |
| `resourceGroup` _string_ | The resource group that will be used to look up and create resources for the cluster in.
If set to empty string at cluster creation, a new resource group will be created and this field will be updated to
the generated resource group's name. |


[Back to top](#top)



### ExternalClusterBringYourOwnCloudSpec





_Appears in:_
- [ExternalClusterCloudSpec](#externalclustercloudspec)



### ExternalClusterCloudSpec



ExternalClusterCloudSpec mutually stores access data to a cloud provider.

_Appears in:_
- [ExternalClusterSpec](#externalclusterspec)

| Field | Description |
| --- | --- |
| `providerName` _[ExternalClusterProvider](#externalclusterprovider)_ |  |
| `gke` _[ExternalClusterGKECloudSpec](#externalclustergkecloudspec)_ |  |
| `eks` _[ExternalClusterEKSCloudSpec](#externalclusterekscloudspec)_ |  |
| `aks` _[ExternalClusterAKSCloudSpec](#externalclusterakscloudspec)_ |  |
| `kubeone` _[ExternalClusterKubeOneCloudSpec](#externalclusterkubeonecloudspec)_ |  |
| `bringyourown` _[ExternalClusterBringYourOwnCloudSpec](#externalclusterbringyourowncloudspec)_ |  |


[Back to top](#top)



### ExternalClusterCondition





_Appears in:_
- [ExternalClusterStatus](#externalclusterstatus)

| Field | Description |
| --- | --- |
| `phase` _[ExternalClusterPhase](#externalclusterphase)_ |  |
| `message` _string_ | Human readable message indicating details about last transition. |


[Back to top](#top)



### ExternalClusterEKSCloudSpec





_Appears in:_
- [ExternalClusterCloudSpec](#externalclustercloudspec)

| Field | Description |
| --- | --- |
| `credentialsReference` _[GlobalSecretKeySelector](#globalsecretkeyselector)_ |  |
| `name` _string_ |  |
| `accessKeyID` _string_ | The Access key ID used to authenticate against AWS.
Can be read from `credentialsReference` instead. |
| `secretAccessKey` _string_ | The Secret Access Key used to authenticate against AWS.
Can be read from `credentialsReference` instead. |
| `region` _string_ |  |
| `roleArn` _string_ | The Amazon Resource Name (ARN) of the IAM role that provides permissions
for the Kubernetes control plane to make calls to Amazon Web Services API
operations on your behalf. |
| `vpcID` _string_ | The VPC associated with your cluster. |
| `subnetIDs` _string array_ | The subnets associated with your cluster. |
| `securityGroupIDs` _string array_ | The security groups associated with the cross-account elastic network interfaces
that are used to allow communication between your nodes and the Kubernetes
control plane. |
| `assumeRoleARN` _string_ | The ARN for an IAM role that should be assumed when handling resources on AWS. It will be used
to acquire temporary security credentials using an STS AssumeRole API operation whenever creating an AWS session.
required: false |
| `assumeRoleExternalID` _string_ | An arbitrary string that may be needed when calling the STS AssumeRole API operation.
Using an external ID can help to prevent the "confused deputy problem".
required: false |


[Back to top](#top)



### ExternalClusterGKECloudSpec





_Appears in:_
- [ExternalClusterCloudSpec](#externalclustercloudspec)

| Field | Description |
| --- | --- |
| `credentialsReference` _[GlobalSecretKeySelector](#globalsecretkeyselector)_ |  |
| `name` _string_ |  |
| `serviceAccount` _string_ | ServiceAccount: The Google Cloud Platform Service Account.
Can be read from `credentialsReference` instead. |
| `zone` _string_ | Zone: The name of the Google Compute Engine zone
(https://cloud.google.com/compute/docs/zones#available) in which the
cluster resides. |


[Back to top](#top)



### ExternalClusterKubeOneCloudSpec





_Appears in:_
- [ExternalClusterCloudSpec](#externalclustercloudspec)

| Field | Description |
| --- | --- |
| `providerName` _string_ | The name of the cloud provider used, one of
"aws", "azure", "digitalocean", "gcp",
"hetzner", "nutanix", "openstack", "packet", "vsphere" KubeOne natively-supported providers |
| `region` _string_ | The cloud provider region in which the cluster resides.
This field is used only to display information. |
| `credentialsReference` _[GlobalSecretKeySelector](#globalsecretkeyselector)_ |  |
| `sshReference` _[GlobalSecretKeySelector](#globalsecretkeyselector)_ |  |
| `manifestReference` _[GlobalSecretKeySelector](#globalsecretkeyselector)_ |  |


[Back to top](#top)



### ExternalClusterList



ExternalClusterList specifies a list of external kubernetes clusters.



| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `ExternalClusterList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[ExternalCluster](#externalcluster) array_ | Items holds the list of the External Kubernetes cluster. |


[Back to top](#top)



### ExternalClusterNetworkRanges



ExternalClusterNetworkRanges represents ranges of network addresses.

_Appears in:_
- [ExternalClusterNetworkingConfig](#externalclusternetworkingconfig)

| Field | Description |
| --- | --- |
| `cidrBlocks` _string array_ |  |


[Back to top](#top)



### ExternalClusterNetworkingConfig



ExternalClusterNetworkingConfig specifies the different networking
parameters for an external cluster.

_Appears in:_
- [ExternalClusterSpec](#externalclusterspec)

| Field | Description |
| --- | --- |
| `services` _[ExternalClusterNetworkRanges](#externalclusternetworkranges)_ | The network ranges from which service VIPs are allocated.
It can contain one IPv4 and/or one IPv6 CIDR.
If both address families are specified, the first one defines the primary address family. |
| `pods` _[ExternalClusterNetworkRanges](#externalclusternetworkranges)_ | The network ranges from which POD networks are allocated.
It can contain one IPv4 and/or one IPv6 CIDR.
If both address families are specified, the first one defines the primary address family. |


[Back to top](#top)



### ExternalClusterPhase

_Underlying type:_ `string`



_Appears in:_
- [ExternalClusterCondition](#externalclustercondition)



### ExternalClusterProvider

_Underlying type:_ `string`

ExternalClusterProvider is the identifier for the cloud provider that hosts
the external cluster control plane.

_Appears in:_
- [ExternalClusterCloudSpec](#externalclustercloudspec)



### ExternalClusterProviderType

_Underlying type:_ `string`

ExternalClusterProviderType is used to indicate ExternalCluster Provider Types.

_Appears in:_
- [KubermaticVersioningConfiguration](#kubermaticversioningconfiguration)



### ExternalClusterProviderVersioningConfiguration



ExternalClusterProviderVersioningConfiguration configures the available and default Kubernetes versions for ExternalCluster Providers.

_Appears in:_
- [KubermaticVersioningConfiguration](#kubermaticversioningconfiguration)

| Field | Description |
| --- | --- |
| `versions` _[Semver](#semver) array_ | Versions lists the available versions. |
| `default` _[Semver](#semver)_ | Default is the default version to offer users. |
| `updates` _[Semver](#semver) array_ | Updates is a list of available upgrades. |


[Back to top](#top)



### ExternalClusterSpec



ExternalClusterSpec specifies the data for a new external kubernetes cluster.

_Appears in:_
- [ExternalCluster](#externalcluster)

| Field | Description |
| --- | --- |
| `humanReadableName` _string_ | HumanReadableName is the cluster name provided by the user |
| `kubeconfigReference` _[GlobalSecretKeySelector](#globalsecretkeyselector)_ | Reference to cluster Kubeconfig |
| `version` _[Semver](#semver)_ | Defines the wanted version of the control plane. |
| `cloudSpec` _[ExternalClusterCloudSpec](#externalclustercloudspec)_ | CloudSpec contains provider specific fields |
| `clusterNetwork` _[ExternalClusterNetworkingConfig](#externalclusternetworkingconfig)_ | ClusterNetwork contains the different networking parameters for an external cluster. |
| `containerRuntime` _string_ | ContainerRuntime to use, i.e. `docker` or `containerd`. |
| `pause` _boolean_ | If this is set to true, the cluster will not be reconciled by KKP.
This indicates that the user needs to do some action to resolve the pause. |
| `pauseReason` _string_ | PauseReason is the reason why the cluster is not being managed. This field is for informational
purpose only and can be set by a user or a controller to communicate the reason for pausing the cluster. |


[Back to top](#top)



### ExternalClusterStatus



ExternalClusterStatus denotes status information about an ExternalCluster.

_Appears in:_
- [ExternalCluster](#externalcluster)

| Field | Description |
| --- | --- |
| `condition` _[ExternalClusterCondition](#externalclustercondition)_ | Conditions contains conditions an externalcluster is in, its primary use case is status signaling for controller |


[Back to top](#top)





### GCP





_Appears in:_
- [PresetSpec](#presetspec)

| Field | Description |
| --- | --- |
| `enabled` _boolean_ | Only enabled presets will be available in the KKP dashboard. |
| `datacenter` _string_ | If datacenter is set, this preset is only applicable to the
configured datacenter. |
| `serviceAccount` _string_ | ServiceAccount is the Google Service Account (JSON format), encoded with base64. |
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
| `serviceAccount` _string_ | The Google Service Account (JSON format), encoded with base64. |
| `network` _string_ |  |
| `subnetwork` _string_ |  |
| `nodePortsAllowedIPRange` _string_ | A CIDR range that will be used to allow access to the node port range in the firewall rules to.
If NodePortsAllowedIPRange nor NodePortsAllowedIPRanges is set, the node port range can be accessed from anywhere. |
| `nodePortsAllowedIPRanges` _[NetworkRanges](#networkranges)_ | Optional: CIDR ranges that will be used to allow access to the node port range in the firewall rules to.
If NodePortsAllowedIPRange nor NodePortsAllowedIPRanges is set,  the node port range can be accessed from anywhere. |


[Back to top](#top)



### GKE





_Appears in:_
- [PresetSpec](#presetspec)

| Field | Description |
| --- | --- |
| `enabled` _boolean_ | Only enabled presets will be available in the KKP dashboard. |
| `datacenter` _string_ | If datacenter is set, this preset is only applicable to the
configured datacenter. |
| `serviceAccount` _string_ |  |


[Back to top](#top)



### GroupProjectBinding



GroupProjectBinding specifies a binding between a group and a project
This resource is used by the user management to manipulate member groups of the given project.

_Appears in:_
- [GroupProjectBindingList](#groupprojectbindinglist)

| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `GroupProjectBinding`
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[GroupProjectBindingSpec](#groupprojectbindingspec)_ | Spec describes an oidc group binding to a project. |


[Back to top](#top)



### GroupProjectBindingList



GroupProjectBindingList is a list of group project bindings.



| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `GroupProjectBindingList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[GroupProjectBinding](#groupprojectbinding) array_ | Items holds the list of the group and project bindings. |


[Back to top](#top)



### GroupProjectBindingSpec



GroupProjectBindingSpec specifies an oidc group binding to a project.

_Appears in:_
- [GroupProjectBinding](#groupprojectbinding)

| Field | Description |
| --- | --- |
| `group` _string_ | Group is the group name that is bound to the given project. |
| `projectID` _string_ | ProjectID is the ID of the target project.
Should be a valid lowercase RFC1123 domain name |
| `role` _string_ | Role is the user's role within the project, determining their permissions.
Possible roles are:
"viewers" - allowed to get/list project resources
"editors" - allowed to edit all project resources
"owners" - same as editors, but also can manage users in the project |


[Back to top](#top)



### GroupVersionKind



GroupVersionKind unambiguously identifies a kind. It doesn't anonymously include GroupVersion
to avoid automatic coercion. It doesn't use a GroupVersion to avoid custom marshalling.

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
| `enabled` _boolean_ | Only enabled presets will be available in the KKP dashboard. |
| `datacenter` _string_ | If datacenter is set, this preset is only applicable to the
configured datacenter. |
| `token` _string_ | Token is used to authenticate with the Hetzner API. |
| `network` _string_ | Network is the pre-existing Hetzner network in which the machines are running.
While machines can be in multiple networks, a single one must be chosen for the
HCloud CCM to work.
If this is empty, the network configured on the datacenter will be used. |


[Back to top](#top)



### HetznerCloudSpec



HetznerCloudSpec specifies access data to hetzner cloud.

_Appears in:_
- [CloudSpec](#cloudspec)

| Field | Description |
| --- | --- |
| `credentialsReference` _[GlobalSecretKeySelector](#globalsecretkeyselector)_ |  |
| `token` _string_ | Token is used to authenticate with the Hetzner cloud API. |
| `network` _string_ | Network is the pre-existing Hetzner network in which the machines are running.
While machines can be in multiple networks, a single one must be chosen for the
HCloud CCM to work.
If this is empty, the network configured on the datacenter will be used. |


[Back to top](#top)



### IPAMAllocation



IPAMAllocation is the object representing an allocation from an IPAMPool
made for a particular KKP user cluster.

_Appears in:_
- [IPAMAllocationList](#ipamallocationlist)

| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `IPAMAllocation`
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[IPAMAllocationSpec](#ipamallocationspec)_ |  |


[Back to top](#top)



### IPAMAllocationList







| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `IPAMAllocationList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[IPAMAllocation](#ipamallocation) array_ |  |


[Back to top](#top)



### IPAMAllocationSpec



IPAMAllocationSpec specifies an allocation from an IPAMPool
made for a particular KKP user cluster.

_Appears in:_
- [IPAMAllocation](#ipamallocation)

| Field | Description |
| --- | --- |
| `type` _[IPAMPoolAllocationType](#ipampoolallocationtype)_ | Type is the allocation type that is being used. |
| `dc` _string_ | DC is the datacenter of the allocation. |
| `cidr` _[SubnetCIDR](#subnetcidr)_ | CIDR is the CIDR that is being used for the allocation.
Set when "type=prefix". |
| `addresses` _string array_ | Addresses are the IP address ranges that are being used for the allocation.
Set when "type=range". |


[Back to top](#top)



### IPAMPool



IPAMPool is the object representing Multi-Cluster IP Address Management (IPAM)
configuration for KKP user clusters.

_Appears in:_
- [IPAMPoolList](#ipampoollist)

| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `IPAMPool`
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[IPAMPoolSpec](#ipampoolspec)_ | Spec describes the Multi-Cluster IP Address Management (IPAM) configuration for KKP user clusters. |


[Back to top](#top)



### IPAMPoolAllocationType

_Underlying type:_ `string`

IPAMPoolAllocationType defines the type of allocation to be used.
Possible values are `prefix` and `range`.

_Appears in:_
- [IPAMAllocationSpec](#ipamallocationspec)
- [IPAMPoolDatacenterSettings](#ipampooldatacentersettings)



### IPAMPoolDatacenterSettings



IPAMPoolDatacenterSettings contains IPAM Pool configuration for a datacenter.

_Appears in:_
- [IPAMPoolSpec](#ipampoolspec)

| Field | Description |
| --- | --- |
| `type` _[IPAMPoolAllocationType](#ipampoolallocationtype)_ | Type is the allocation type to be used. |
| `poolCidr` _[SubnetCIDR](#subnetcidr)_ | PoolCIDR is the pool CIDR to be used for the allocation. |
| `allocationPrefix` _integer_ | AllocationPrefix is the prefix for the allocation.
Used when "type=prefix". |
| `excludePrefixes` _[SubnetCIDR](#subnetcidr) array_ | Optional: ExcludePrefixes is used to exclude particular subnets for the allocation.
NOTE: must be the same length as allocationPrefix.
Can be used when "type=prefix". |
| `allocationRange` _integer_ | AllocationRange is the range for the allocation.
Used when "type=range". |
| `excludeRanges` _string array_ | Optional: ExcludeRanges is used to exclude particular IPs or IP ranges for the allocation.
Examples: "192.168.1.100-192.168.1.110", "192.168.1.255".
Can be used when "type=range". |


[Back to top](#top)



### IPAMPoolList



IPAMPoolList is the list of the object representing Multi-Cluster IP Address Management (IPAM)
configuration for KKP user clusters.



| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `IPAMPoolList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[IPAMPool](#ipampool) array_ | Items holds the list of IPAM pool objects. |


[Back to top](#top)



### IPAMPoolSpec



IPAMPoolSpec specifies the  Multi-Cluster IP Address Management (IPAM)
configuration for KKP user clusters.

_Appears in:_
- [IPAMPool](#ipampool)

| Field | Description |
| --- | --- |
| `datacenters` _object (keys:string, values:[IPAMPoolDatacenterSettings](#ipampooldatacentersettings))_ | Datacenters contains a map of datacenters (DCs) for the allocation. |


[Back to top](#top)



### IPFamily

_Underlying type:_ `string`



_Appears in:_
- [ClusterNetworkingConfig](#clusternetworkingconfig)



### IPVSConfiguration



IPVSConfiguration contains ipvs-related configuration details for kube-proxy.

_Appears in:_
- [ClusterNetworkingConfig](#clusternetworkingconfig)

| Field | Description |
| --- | --- |
| `strictArp` _boolean_ | StrictArp configure arp_ignore and arp_announce to avoid answering ARP queries from kube-ipvs0 interface.
defaults to true. |


[Back to top](#top)



### ImageList

_Underlying type:_ `OperatingSystem]string`

ImageList defines a map of operating system and the image to use.

_Appears in:_
- [DatacenterSpecAWS](#datacenterspecaws)
- [DatacenterSpecNutanix](#datacenterspecnutanix)
- [DatacenterSpecOpenstack](#datacenterspecopenstack)
- [DatacenterSpecVMwareCloudDirector](#datacenterspecvmwareclouddirector)
- [DatacenterSpecVSphere](#datacenterspecvsphere)





### Incompatibility



Incompatibility represents a version incompatibility for a user cluster.

_Appears in:_
- [KubermaticVersioningConfiguration](#kubermaticversioningconfiguration)

| Field | Description |
| --- | --- |
| `provider` _string_ | Provider to which to apply the compatibility check.
Empty string matches all providers |
| `version` _string_ | Version is the Kubernetes version that must be checked. Wildcards are allowed, e.g. "1.25.*". |
| `condition` _[ConditionType](#conditiontype)_ | Condition is the cluster or datacenter condition that must be met to block a specific version |
| `operation` _[OperationType](#operationtype)_ | Operation is the operation triggering the compatibility check (CREATE or UPDATE) |


[Back to top](#top)



### Kind



Kind specifies the resource Kind and APIGroup.

_Appears in:_
- [Match](#match)

| Field | Description |
| --- | --- |
| `kinds` _string array_ | Kinds specifies the kinds of the resources |
| `apiGroups` _string array_ | APIGroups specifies the APIGroups of the resources |


[Back to top](#top)



### KonnectivityProxySettings





_Appears in:_
- [ComponentSettings](#componentsettings)

| Field | Description |
| --- | --- |
| `resources` _[ResourceRequirements](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#resourcerequirements-v1-core)_ | Resources configure limits/requests for Konnectivity components. |
| `keepaliveTime` _string_ | KeepaliveTime represents a duration of time to check if the transport is still alive.
The option is propagated to agents and server.
Defaults to 1m. |


[Back to top](#top)



### KubeLB



KubeLB contains settings for the kubeLB component as part of the cluster control plane. This component is responsible for managing load balancers.
Only available in Enterprise Edition.

_Appears in:_
- [ClusterSpec](#clusterspec)

| Field | Description |
| --- | --- |
| `enabled` _boolean_ | Controls whether kubeLB is deployed or not. |


[Back to top](#top)



### KubeLBDatacenterSettings





_Appears in:_
- [DatacenterSpec](#datacenterspec)

| Field | Description |
| --- | --- |
| `kubeconfig` _[ObjectReference](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#objectreference-v1-core)_ | Kubeconfig is reference to the Kubeconfig for the kubeLB management cluster. |
| `enabled` _boolean_ | Enabled is used to enable/disable kubeLB for the datacenter. This is used to control whether installing kubeLB is allowed or not for the datacenter. |
| `enforced` _boolean_ | Enforced is used to enforce kubeLB installation for all the user clusters belonging to this datacenter. Setting enforced to false will not uninstall kubeLB from the user clusters and it needs to be disabled manually. |
| `nodeAddressType` _string_ | NodeAddressType is used to configure the address type from node, used for load balancing.
Optional: Defaults to ExternalIP. |


[Back to top](#top)



### KubeLBSettings





_Appears in:_
- [KubeLBDatacenterSettings](#kubelbdatacentersettings)
- [SeedSpec](#seedspec)

| Field | Description |
| --- | --- |
| `kubeconfig` _[ObjectReference](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#objectreference-v1-core)_ | Kubeconfig is reference to the Kubeconfig for the kubeLB management cluster. |


[Back to top](#top)





### KubeVirtImageSources



KubeVirtImageSources represents KubeVirt image sources.

_Appears in:_
- [DatacenterSpecKubevirt](#datacenterspeckubevirt)

| Field | Description |
| --- | --- |
| `http` _[KubeVirtHTTPSource](#kubevirthttpsource)_ | HTTP represents a http source. |


[Back to top](#top)



### KubeVirtInfraStorageClass





_Appears in:_
- [DatacenterSpecKubevirt](#datacenterspeckubevirt)
- [KubevirtCloudSpec](#kubevirtcloudspec)

| Field | Description |
| --- | --- |
| `name` _string_ |  |
| `isDefaultClass` _boolean_ | Optional: IsDefaultClass. If true, the created StorageClass in the tenant cluster will be annotated with:
storageclass.kubernetes.io/is-default-class : true
If missing or false, annotation will be:
storageclass.kubernetes.io/is-default-class : false |


[Back to top](#top)



### KubermaticAPIConfiguration



KubermaticAPIConfiguration configures the dashboard.

_Appears in:_
- [KubermaticConfigurationSpec](#kubermaticconfigurationspec)

| Field | Description |
| --- | --- |
| `dockerRepository` _string_ | DockerRepository is the repository containing the Kubermatic REST API image. |
| `accessibleAddons` _string array_ | AccessibleAddons is a list of addons that should be enabled in the API. |
| `pprofEndpoint` _string_ | PProfEndpoint controls the port the API should listen on to provide pprof
data. This port is never exposed from the container and only available via port-forwardings. |
| `resources` _[ResourceRequirements](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#resourcerequirements-v1-core)_ | Resources describes the requested and maximum allowed CPU/memory usage. |
| `debugLog` _boolean_ | DebugLog enables more verbose logging. |
| `replicas` _integer_ | Replicas sets the number of pod replicas for the API deployment. |


[Back to top](#top)



### KubermaticAddonsConfiguration



KubermaticAddonConfiguration describes the addons for a given cluster runtime.

_Appears in:_
- [KubermaticUserClusterConfiguration](#kubermaticuserclusterconfiguration)

| Field | Description |
| --- | --- |
| `default` _string array_ | Default is the list of addons to be installed by default into each cluster.
Mutually exclusive with "defaultManifests". |
| `defaultManifests` _string_ | DefaultManifests is a list of addon manifests to install into all clusters.
Mutually exclusive with "default". |
| `dockerRepository` _string_ | DockerRepository is the repository containing the Docker image containing
the possible addon manifests. |
| `dockerTagSuffix` _string_ | DockerTagSuffix is appended to the tag used for referring to the addons image.
If left empty, the tag will be the KKP version (e.g. "v2.15.0"), with a
suffix it becomes "v2.15.0-SUFFIX". |


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
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[KubermaticConfigurationSpec](#kubermaticconfigurationspec)_ |  |
| `status` _[KubermaticConfigurationStatus](#kubermaticconfigurationstatus)_ |  |


[Back to top](#top)



### KubermaticConfigurationList



KubermaticConfigurationList is a collection of KubermaticConfigurations.



| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `KubermaticConfigurationList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[KubermaticConfiguration](#kubermaticconfiguration) array_ |  |


[Back to top](#top)



### KubermaticConfigurationSpec



KubermaticConfigurationSpec is the spec for a Kubermatic installation.

_Appears in:_
- [KubermaticConfiguration](#kubermaticconfiguration)

| Field | Description |
| --- | --- |
| `caBundle` _[TypedLocalObjectReference](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#typedlocalobjectreference-v1-core)_ | CABundle references a ConfigMap in the same namespace as the KubermaticConfiguration.
This ConfigMap must contain a ca-bundle.pem with PEM-encoded certificates. This bundle
automatically synchronized into each seed and each usercluster. APIGroup and Kind are
currently ignored. |
| `imagePullSecret` _string_ | ImagePullSecret is used to authenticate against Docker registries. |
| `auth` _[KubermaticAuthConfiguration](#kubermaticauthconfiguration)_ | Auth defines keys and URLs for Dex. These must be defined unless the HeadlessInstallation
feature gate is set, which will disable the UI/API and its need for an OIDC provider entirely. |
| `featureGates` _object (keys:string, values:boolean)_ | FeatureGates are used to optionally enable certain features. |
| `ui` _[KubermaticUIConfiguration](#kubermaticuiconfiguration)_ | UI configures the dashboard. |
| `api` _[KubermaticAPIConfiguration](#kubermaticapiconfiguration)_ | API configures the frontend REST API used by the dashboard. |
| `seedController` _[KubermaticSeedControllerConfiguration](#kubermaticseedcontrollerconfiguration)_ | SeedController configures the seed-controller-manager. |
| `masterController` _[KubermaticMasterControllerConfiguration](#kubermaticmastercontrollerconfiguration)_ | MasterController configures the master-controller-manager. |
| `webhook` _[KubermaticWebhookConfiguration](#kubermaticwebhookconfiguration)_ | Webhook configures the webhook. |
| `userCluster` _[KubermaticUserClusterConfiguration](#kubermaticuserclusterconfiguration)_ | UserCluster configures various aspects of the user-created clusters. |
| `exposeStrategy` _[ExposeStrategy](#exposestrategy)_ | ExposeStrategy is the strategy to expose the cluster with.
Note: The `seed_dns_overwrite` setting of a Seed's datacenter doesn't have any effect
if this is set to LoadBalancerStrategy. |
| `ingress` _[KubermaticIngressConfiguration](#kubermaticingressconfiguration)_ | Ingress contains settings for making the API and UI accessible remotely. |
| `versions` _[KubermaticVersioningConfiguration](#kubermaticversioningconfiguration)_ | Versions configures the available and default Kubernetes versions and updates. |
| `verticalPodAutoscaler` _[KubermaticVPAConfiguration](#kubermaticvpaconfiguration)_ | VerticalPodAutoscaler configures the Kubernetes VPA integration. |
| `proxy` _[KubermaticProxyConfiguration](#kubermaticproxyconfiguration)_ | Proxy allows to configure Kubermatic to use proxies to talk to the
world outside of its cluster. |


[Back to top](#top)



### KubermaticConfigurationStatus



KubermaticConfigurationStatus stores status information about a KubermaticConfiguration.

_Appears in:_
- [KubermaticConfiguration](#kubermaticconfiguration)

| Field | Description |
| --- | --- |
| `kubermaticVersion` _string_ | KubermaticVersion current Kubermatic Version. |
| `kubermaticEdition` _string_ | KubermaticEdition current Kubermatic Edition , i.e. Community Edition or Enterprise Edition. |


[Back to top](#top)



### KubermaticIngressConfiguration





_Appears in:_
- [KubermaticConfigurationSpec](#kubermaticconfigurationspec)

| Field | Description |
| --- | --- |
| `domain` _string_ | Domain is the base domain where the dashboard shall be available. Even with
a disabled Ingress, this must always be a valid hostname. |
| `className` _string_ | ClassName is the Ingress resource's class name, used for selecting the appropriate
ingress controller. |
| `namespaceOverride` _string_ | NamespaceOverride need to be set if a different ingress-controller is used than the KKP default one. |
| `disable` _boolean_ | Disable will prevent an Ingress from being created at all. This is mostly useful
during testing. If the Ingress is disabled, the CertificateIssuer setting can also
be left empty, as no Certificate resource will be created. |
| `certificateIssuer` _[TypedLocalObjectReference](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#typedlocalobjectreference-v1-core)_ | CertificateIssuer is the name of a cert-manager Issuer or ClusterIssuer (default)
that will be used to acquire the certificate for the configured domain.
To use a namespaced Issuer, set the Kind to "Issuer" and manually create the
matching Issuer in Kubermatic's namespace.
Setting an empty name disables the automatic creation of certificates and disables
the TLS settings on the Kubermatic Ingress. |


[Back to top](#top)



### KubermaticMasterControllerConfiguration



KubermaticMasterControllerConfiguration configures the Kubermatic master controller-manager.

_Appears in:_
- [KubermaticConfigurationSpec](#kubermaticconfigurationspec)

| Field | Description |
| --- | --- |
| `dockerRepository` _string_ | DockerRepository is the repository containing the Kubermatic master-controller-manager image. |
| `projectsMigrator` _[KubermaticProjectsMigratorConfiguration](#kubermaticprojectsmigratorconfiguration)_ | ProjectsMigrator configures the migrator for user projects. |
| `pprofEndpoint` _string_ | PProfEndpoint controls the port the master-controller-manager should listen on to provide pprof
data. This port is never exposed from the container and only available via port-forwardings. |
| `resources` _[ResourceRequirements](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#resourcerequirements-v1-core)_ | Resources describes the requested and maximum allowed CPU/memory usage. |
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



KubermaticProxyConfiguration can be used to control how the various
Kubermatic components reach external services / the Internet. These
settings are reflected as environment variables for the Kubermatic
pods.

_Appears in:_
- [KubermaticConfigurationSpec](#kubermaticconfigurationspec)

| Field | Description |
| --- | --- |
| `http` _string_ | HTTP is the full URL to the proxy to use for plaintext HTTP
connections, e.g. "http://internalproxy.example.com:8080". |
| `https` _string_ | HTTPS is the full URL to the proxy to use for encrypted HTTPS
connections, e.g. "http://secureinternalproxy.example.com:8080". |
| `noProxy` _string_ | NoProxy is a comma-separated list of hostnames / network masks
for which no proxy shall be used. If you make use of proxies,
this list should contain all local and cluster-internal domains
and networks, e.g. "10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,mydomain".
The operator will always prepend the following elements to this
list if proxying is configured (i.e. HTTP/HTTPS are not empty):
"127.0.0.1/8", "localhost", ".local", ".local.", "kubernetes", ".default", ".svc" |


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
| `backupCleanupContainer` _string_ | Deprecated: BackupCleanupContainer is the container used for removing expired backups from the storage location.
This field is a no-op and is no longer used. The old backup controller it was used for has been
removed. Do not set this field. |
| `maximumParallelReconciles` _integer_ | MaximumParallelReconciles limits the number of cluster reconciliations
that are active at any given time. |
| `pprofEndpoint` _string_ | PProfEndpoint controls the port the seed-controller-manager should listen on to provide pprof
data. This port is never exposed from the container and only available via port-forwardings. |
| `resources` _[ResourceRequirements](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#resourcerequirements-v1-core)_ | Resources describes the requested and maximum allowed CPU/memory usage. |
| `debugLog` _boolean_ | DebugLog enables more verbose logging. |
| `replicas` _integer_ | Replicas sets the number of pod replicas for the seed-controller-manager. |


[Back to top](#top)



### KubermaticSetting



KubermaticSetting is the type representing a KubermaticSetting.
These settings affect the KKP dashboard and are not relevant when
using the Kube API on the master/seed clusters directly.

_Appears in:_
- [KubermaticSettingList](#kubermaticsettinglist)

| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `KubermaticSetting`
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[SettingSpec](#settingspec)_ |  |


[Back to top](#top)



### KubermaticSettingList



KubermaticSettingList is a list of settings.



| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `KubermaticSettingList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[KubermaticSetting](#kubermaticsetting) array_ |  |


[Back to top](#top)



### KubermaticUIConfiguration



KubermaticUIConfiguration configures the dashboard.

_Appears in:_
- [KubermaticConfigurationSpec](#kubermaticconfigurationspec)

| Field | Description |
| --- | --- |
| `dockerRepository` _string_ | DockerRepository is the repository containing the Kubermatic dashboard image. |
| `dockerTag` _string_ | DockerTag is used to overwrite the dashboard Docker image tag and is only for development
purposes. This field must not be set in production environments. If DockerTag is specified then
DockerTagSuffix will be ignored.
--- |
| `dockerTagSuffix` _string_ | DockerTagSuffix is appended to the KKP version used for referring to the custom dashboard image.
If left empty, either the `DockerTag` if specified or the original dashboard Docker image tag will be used.
With DockerTagSuffix the tag becomes <KKP_VERSION:SUFFIX> i.e. "v2.15.0-SUFFIX". |
| `config` _string_ | Config sets flags for various dashboard features. |
| `resources` _[ResourceRequirements](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#resourcerequirements-v1-core)_ | Resources describes the requested and maximum allowed CPU/memory usage. |
| `replicas` _integer_ | Replicas sets the number of pod replicas for the UI deployment. |
| `extraVolumeMounts` _[VolumeMount](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#volumemount-v1-core) array_ | ExtraVolumeMounts allows to mount additional volumes into the UI container. |
| `extraVolumes` _[Volume](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#volume-v1-core) array_ | ExtraVolumes allows to mount additional volumes into the UI container. |


[Back to top](#top)



### KubermaticUserClusterConfiguration



KubermaticUserClusterConfiguration controls various aspects of the user-created clusters.

_Appears in:_
- [KubermaticConfigurationSpec](#kubermaticconfigurationspec)

| Field | Description |
| --- | --- |
| `kubermaticDockerRepository` _string_ | KubermaticDockerRepository is the repository containing the Kubermatic user-cluster-controller-manager image. |
| `dnatControllerDockerRepository` _string_ | DNATControllerDockerRepository is the repository containing the
dnat-controller image. |
| `etcdLauncherDockerRepository` _string_ | EtcdLauncherDockerRepository is the repository containing the Kubermatic
etcd-launcher image. |
| `overwriteRegistry` _string_ | OverwriteRegistry specifies a custom Docker registry which will be used for all images
used for user clusters (user cluster control plane + addons). This also applies to
the KubermaticDockerRepository and DNATControllerDockerRepository fields. |
| `addons` _[KubermaticAddonsConfiguration](#kubermaticaddonsconfiguration)_ | Addons controls the optional additions installed into each user cluster. |
| `systemApplications` _[SystemApplicationsConfiguration](#systemapplicationsconfiguration)_ | SystemApplications contains configuration for system Applications (such as CNI). |
| `nodePortRange` _string_ | NodePortRange is the port range for user clusters - this must match the NodePort
range of the seed cluster. |
| `monitoring` _[KubermaticUserClusterMonitoringConfiguration](#kubermaticuserclustermonitoringconfiguration)_ | Monitoring can be used to fine-tune to in-cluster Prometheus. |
| `disableApiserverEndpointReconciling` _boolean_ | DisableAPIServerEndpointReconciling can be used to toggle the `--endpoint-reconciler-type` flag for
the Kubernetes API server. |
| `etcdVolumeSize` _string_ | EtcdVolumeSize configures the volume size to use for each etcd pod inside user clusters. |
| `apiserverReplicas` _integer_ | APIServerReplicas configures the replica count for the API-Server deployment inside user clusters. |
| `machineController` _[MachineControllerConfiguration](#machinecontrollerconfiguration)_ | MachineController configures the Machine Controller |
| `operatingSystemManager` _[OperatingSystemManager](#operatingsystemmanager)_ | OperatingSystemManager configures the image repo and the tag version for osm deployment. |


[Back to top](#top)



### KubermaticUserClusterMonitoringConfiguration



KubermaticUserClusterMonitoringConfiguration can be used to fine-tune to in-cluster Prometheus.

_Appears in:_
- [KubermaticUserClusterConfiguration](#kubermaticuserclusterconfiguration)

| Field | Description |
| --- | --- |
| `disableDefaultRules` _boolean_ | DisableDefaultRules disables the recording and alerting rules. |
| `disableDefaultScrapingConfigs` _boolean_ | DisableDefaultScrapingConfigs disables the default scraping targets. |
| `customRules` _string_ | CustomRules can be used to inject custom recording and alerting rules. This field
must be a YAML-formatted string with a `group` element at its root, as documented
on https://prometheus.io/docs/prometheus/latest/configuration/alerting_rules/.
This value is treated as a Go template, which allows to inject dynamic values like
the internal cluster address or the cluster ID. Refer to pkg/resources/prometheus
and the documentation for more information on the available fields. |
| `customScrapingConfigs` _string_ | CustomScrapingConfigs can be used to inject custom scraping rules. This must be a
YAML-formatted string containing an array of scrape configurations as documented
on https://prometheus.io/docs/prometheus/latest/configuration/configuration/#scrape_config.
This value is treated as a Go template, which allows to inject dynamic values like
the internal cluster address or the cluster ID. Refer to pkg/resources/prometheus
and the documentation for more information on the available fields. |
| `scrapeAnnotationPrefix` _string_ | ScrapeAnnotationPrefix (if set) is used to make the in-cluster Prometheus scrape pods
inside the user clusters. |


[Back to top](#top)



### KubermaticVPAComponent





_Appears in:_
- [KubermaticVPAConfiguration](#kubermaticvpaconfiguration)

| Field | Description |
| --- | --- |
| `dockerRepository` _string_ | DockerRepository is the repository containing the component's image. |
| `resources` _[ResourceRequirements](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#resourcerequirements-v1-core)_ | Resources describes the requested and maximum allowed CPU/memory usage. |


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
| `versions` _[Semver](#semver) array_ | Versions lists the available versions. |
| `default` _[Semver](#semver)_ | Default is the default version to offer users. |
| `updates` _[Update](#update) array_ | Updates is a list of available and automatic upgrades.
All 'to' versions must be configured in the version list for this orchestrator.
Each update may optionally be configured to be 'automatic: true', in which case the
controlplane of all clusters whose version matches the 'from' directive will get
updated to the 'to' version. If automatic is enabled, the 'to' version must be a
version and not a version range.
Also, updates may set 'automaticNodeUpdate: true', in which case Nodes will get
updates as well. 'automaticNodeUpdate: true' implies 'automatic: true' as well,
because Nodes may not have a newer version than the controlplane. |
| `providerIncompatibilities` _[Incompatibility](#incompatibility) array_ | ProviderIncompatibilities lists all the Kubernetes version incompatibilities |
| `externalClusters` _object (keys:[ExternalClusterProviderType](#externalclusterprovidertype), values:[ExternalClusterProviderVersioningConfiguration](#externalclusterproviderversioningconfiguration))_ | ExternalClusters contains the available and default Kubernetes versions and updates for ExternalClusters. |


[Back to top](#top)



### KubermaticWebhookConfiguration



KubermaticWebhookConfiguration configures the Kubermatic webhook.

_Appears in:_
- [KubermaticConfigurationSpec](#kubermaticconfigurationspec)

| Field | Description |
| --- | --- |
| `dockerRepository` _string_ | DockerRepository is the repository containing the Kubermatic webhook image. |
| `pprofEndpoint` _string_ | PProfEndpoint controls the port the webhook should listen on to provide pprof
data. This port is never exposed from the container and only available via port-forwardings. |
| `resources` _[ResourceRequirements](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#resourcerequirements-v1-core)_ | Resources describes the requested and maximum allowed CPU/memory usage. |
| `debugLog` _boolean_ | DebugLog enables more verbose logging. |
| `replicas` _integer_ | Replicas sets the number of pod replicas for the webhook. |


[Back to top](#top)



### KubernetesDashboard



KubernetesDashboard contains settings for the kubernetes-dashboard component as part of the cluster control plane.

_Appears in:_
- [ClusterSpec](#clusterspec)

| Field | Description |
| --- | --- |
| `enabled` _boolean_ | Controls whether kubernetes-dashboard is deployed to the user cluster or not.
Enabled by default. |


[Back to top](#top)



### Kubevirt





_Appears in:_
- [PresetSpec](#presetspec)

| Field | Description |
| --- | --- |
| `enabled` _boolean_ | Only enabled presets will be available in the KKP dashboard. |
| `datacenter` _string_ | If datacenter is set, this preset is only applicable to the
configured datacenter. |
| `kubeconfig` _string_ | Kubeconfig is the cluster's kubeconfig file, encoded with base64. |


[Back to top](#top)



### KubevirtCloudSpec



KubevirtCloudSpec specifies the access data to Kubevirt.

_Appears in:_
- [CloudSpec](#cloudspec)

| Field | Description |
| --- | --- |
| `credentialsReference` _[GlobalSecretKeySelector](#globalsecretkeyselector)_ |  |
| `kubeconfig` _string_ | The cluster's kubeconfig file, encoded with base64. |
| `csiKubeconfig` _string_ |  |
| `preAllocatedDataVolumes` _[PreAllocatedDataVolume](#preallocateddatavolume) array_ | Custom Images are a good example of this use case. |
| `infraStorageClasses` _string array_ | Deprecated: in favor of StorageClasses.
InfraStorageClasses is a list of storage classes from KubeVirt infra cluster that are used for
initialization of user cluster storage classes by the CSI driver kubevirt (hot pluggable disks) |
| `storageClasses` _[KubeVirtInfraStorageClass](#kubevirtinfrastorageclass) array_ | StorageClasses is a list of storage classes from KubeVirt infra cluster that are used for
initialization of user cluster storage classes by the CSI driver kubevirt (hot pluggable disks.
It contains also some flag specifying which one is the default one. |
| `imageCloningEnabled` _boolean_ | ImageCloningEnabled flag enable/disable cloning for a cluster. |


[Back to top](#top)



### LBSKU

_Underlying type:_ `string`

Azure SKU for Load Balancers. Possible values are `basic` and `standard`.

_Appears in:_
- [Azure](#azure)
- [AzureCloudSpec](#azurecloudspec)



### LeaderElectionSettings





_Appears in:_
- [ControllerSettings](#controllersettings)

| Field | Description |
| --- | --- |
| `leaseDurationSeconds` _integer_ | LeaseDurationSeconds is the duration in seconds that non-leader candidates
will wait to force acquire leadership. This is measured against time of
last observed ack. |
| `renewDeadlineSeconds` _integer_ | RenewDeadlineSeconds is the duration in seconds that the acting controlplane
will retry refreshing leadership before giving up. |
| `retryPeriodSeconds` _integer_ | RetryPeriodSeconds is the duration in seconds the LeaderElector clients
should wait between tries of actions. |


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



MLAAdminSetting is the object representing cluster-specific administrator settings
for KKP user cluster MLA (monitoring, logging & alerting) stack.

_Appears in:_
- [MLAAdminSettingList](#mlaadminsettinglist)

| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `MLAAdminSetting`
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[MLAAdminSettingSpec](#mlaadminsettingspec)_ | Spec describes the cluster-specific administrator settings for KKP user cluster MLA
(monitoring, logging & alerting) stack. |


[Back to top](#top)



### MLAAdminSettingList



MLAAdminSettingList specifies a list of administrtor settings for KKP
user cluster MLA (monitoring, logging & alerting) stack.



| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `MLAAdminSettingList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[MLAAdminSetting](#mlaadminsetting) array_ | Items holds the list of the cluster-specific administrative settings
for KKP user cluster MLA. |


[Back to top](#top)



### MLAAdminSettingSpec



MLAAdminSettingSpec specifies the cluster-specific administrator settings
for KKP user cluster MLA (monitoring, logging & alerting) stack.

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
| `monitoringResources` _[ResourceRequirements](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#resourcerequirements-v1-core)_ | MonitoringResources is the resource requirements for user cluster prometheus. |
| `loggingResources` _[ResourceRequirements](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#resourcerequirements-v1-core)_ | LoggingResources is the resource requirements for user cluster promtail. |
| `monitoringReplicas` _integer_ | MonitoringReplicas is the number of desired pods of user cluster prometheus deployment. |


[Back to top](#top)



### MachineControllerConfiguration



MachineControllerConfiguration configures Machine Controller.

_Appears in:_
- [KubermaticUserClusterConfiguration](#kubermaticuserclusterconfiguration)

| Field | Description |
| --- | --- |
| `imageRepository` _string_ | ImageRepository is used to override the Machine Controller image repository.
It is only for development, tests and PoC purposes. This field must not be set in production environments. |
| `imageTag` _string_ | ImageTag is used to override the Machine Controller image.
It is only for development, tests and PoC purposes. This field must not be set in production environments. |


[Back to top](#top)



### MachineDeploymentOptions





_Appears in:_
- [SettingSpec](#settingspec)

| Field | Description |
| --- | --- |
| `autoUpdatesEnabled` _boolean_ | AutoUpdatesEnabled enables the auto updates option for machine deployments on the dashboard.
In case of flatcar linux, this will enable automatic updates through update engine and for other operating systems,
this will enable package updates on boot for the machines. |
| `autoUpdatesEnforced` _boolean_ | AutoUpdatesEnforced enforces the auto updates option for machine deployments on the dashboard.
In case of flatcar linux, this will enable automatic updates through update engine and for other operating systems,
this will enable package updates on boot for the machines. |


[Back to top](#top)



### MachineFlavorFilter





_Appears in:_
- [DatacenterSpec](#datacenterspec)
- [SettingSpec](#settingspec)

| Field | Description |
| --- | --- |
| `minCPU` _integer_ | Minimum number of vCPU |
| `maxCPU` _integer_ | Maximum number of vCPU |
| `minRAM` _integer_ | Minimum RAM size in GB |
| `maxRAM` _integer_ | Maximum RAM size in GB |
| `enableGPU` _boolean_ | Include VMs with GPU |


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



Match contains the constraint to resource matching data.

_Appears in:_
- [ConstraintSpec](#constraintspec)

| Field | Description |
| --- | --- |
| `kinds` _[Kind](#kind) array_ | Kinds accepts a list of objects with apiGroups and kinds fields that list the groups/kinds of objects to which
the constraint will apply. If multiple groups/kinds objects are specified, only one match is needed for the resource to be in scope |
| `scope` _string_ | Scope accepts *, Cluster, or Namespaced which determines if cluster-scoped and/or namespace-scoped resources are selected. (defaults to *) |
| `namespaces` _string array_ | Namespaces is a list of namespace names. If defined, a constraint will only apply to resources in a listed namespace. |
| `excludedNamespaces` _string array_ | ExcludedNamespaces is a list of namespace names. If defined, a constraint will only apply to resources not in a listed namespace. |
| `labelSelector` _[LabelSelector](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#labelselector-v1-meta)_ | LabelSelector is a standard Kubernetes label selector. |
| `namespaceSelector` _[LabelSelector](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#labelselector-v1-meta)_ | NamespaceSelector  is a standard Kubernetes namespace selector. If defined, make sure to add Namespaces to your
configs.config.gatekeeper.sh object to ensure namespaces are synced into OPA |


[Back to top](#top)



### MeteringConfiguration



MeteringConfiguration contains all the configuration for the metering tool.

_Appears in:_
- [SeedSpec](#seedspec)

| Field | Description |
| --- | --- |
| `enabled` _boolean_ |  |
| `storageClassName` _string_ | StorageClassName is the name of the storage class that the metering Prometheus instance uses to store metric data for reporting. |
| `storageSize` _string_ | StorageSize is the size of the storage class. Default value is 100Gi. Changing this value requires
manual deletion of the existing Prometheus PVC (and thereby removing all metering data). |
| `retentionDays` _integer_ | RetentionDays is the number of days for which data should be kept in Prometheus. Default value is 90. |
| `reports` _object (keys:string, values:[MeteringReportConfiguration](#meteringreportconfiguration))_ | ReportConfigurations is a map of report configuration definitions. |


[Back to top](#top)



### MeteringReportConfiguration





_Appears in:_
- [MeteringConfiguration](#meteringconfiguration)

| Field | Description |
| --- | --- |
| `schedule` _string_ | Schedule in Cron format, see https://en.wikipedia.org/wiki/Cron. Please take a note that Schedule is responsible
only for setting the time when a report generation mechanism kicks off. The Interval MUST be set independently. |
| `interval` _integer_ | Interval defines the number of days consulted in the metering report.
Ignored when `Monthly` is set to true |
| `monthly` _boolean_ | Monthly creates a report for the previous month. |
| `retention` _integer_ | Retention defines a number of days after which reports are queued for removal. If not set, reports are kept forever.
Please note that this functionality works only for object storage that supports an object lifecycle management mechanism. |
| `type` _string array_ | Types of reports to generate. Available report types are cluster and namespace. By default, all types of reports are generated. |
| `format` _[MeteringReportFormat](#meteringreportformat)_ | Format is the file format of the generated report, one of "csv" or "json" (defaults to "csv"). |


[Back to top](#top)



### MeteringReportFormat

_Underlying type:_ `string`

MeteringReportFormat maps directly to the values supported by the kubermatic-metering tool.

_Appears in:_
- [MeteringReportConfiguration](#meteringreportconfiguration)



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
- [AWSCloudSpec](#awscloudspec)
- [AzureCloudSpec](#azurecloudspec)
- [ClusterNetworkingConfig](#clusternetworkingconfig)
- [ClusterSpec](#clusterspec)
- [GCPCloudSpec](#gcpcloudspec)
- [OpenstackCloudSpec](#openstackcloudspec)

| Field | Description |
| --- | --- |
| `cidrBlocks` _string array_ |  |


[Back to top](#top)



### NodePortProxyComponentEnvoy





_Appears in:_
- [NodeportProxyConfig](#nodeportproxyconfig)

| Field | Description |
| --- | --- |
| `dockerRepository` _string_ | DockerRepository is the repository containing the component's image. |
| `resources` _[ResourceRequirements](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#resourcerequirements-v1-core)_ | Resources describes the requested and maximum allowed CPU/memory usage. |
| `loadBalancerService` _[EnvoyLoadBalancerService](#envoyloadbalancerservice)_ |  |


[Back to top](#top)



### NodeSettings



NodeSettings are node specific flags which can be configured on datacenter level.

_Appears in:_
- [Datacenter](#datacenter)

| Field | Description |
| --- | --- |
| `httpProxy` _[ProxyValue](#proxyvalue)_ | Optional: If set, this proxy will be configured for both HTTP and HTTPS. |
| `noProxy` _[ProxyValue](#proxyvalue)_ | Optional: If set this will be set as NO_PROXY environment variable on the node;
The value must be a comma-separated list of domains for which no proxy
should be used, e.g. "*.example.com,internal.dev".
Note that the in-cluster apiserver URL will be automatically prepended
to this value. |
| `insecureRegistries` _string array_ | Optional: These image registries will be configured as insecure
on the container runtime. |
| `registryMirrors` _string array_ | Optional: These image registries will be configured as registry mirrors
on the container runtime. |
| `pauseImage` _string_ | Optional: Translates to --pod-infra-container-image on the kubelet.
If not set, the kubelet will default it. |
| `containerdRegistryMirrors` _[ContainerRuntimeContainerd](#containerruntimecontainerd)_ | Optional: ContainerdRegistryMirrors configure registry mirrors endpoints. Can be used multiple times to specify multiple mirrors. |


[Back to top](#top)



### NodeportProxyComponent





_Appears in:_
- [ComponentSettings](#componentsettings)
- [NodePortProxyComponentEnvoy](#nodeportproxycomponentenvoy)
- [NodeportProxyConfig](#nodeportproxyconfig)

| Field | Description |
| --- | --- |
| `dockerRepository` _string_ | DockerRepository is the repository containing the component's image. |
| `resources` _[ResourceRequirements](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#resourcerequirements-v1-core)_ | Resources describes the requested and maximum allowed CPU/memory usage. |


[Back to top](#top)



### NodeportProxyConfig





_Appears in:_
- [SeedSpec](#seedspec)

| Field | Description |
| --- | --- |
| `disable` _boolean_ | Disable will prevent the Kubermatic Operator from creating a nodeport-proxy
setup on the seed cluster. This should only be used if a suitable replacement
is installed (like the nodeport-proxy Helm chart). |
| `annotations` _object (keys:string, values:string)_ | Annotations are used to further tweak the LoadBalancer integration with the
cloud provider where the seed cluster is running.
Deprecated: Use .envoy.loadBalancerService.annotations instead. |
| `envoy` _[NodePortProxyComponentEnvoy](#nodeportproxycomponentenvoy)_ | Envoy configures the Envoy application itself. |
| `envoyManager` _[NodeportProxyComponent](#nodeportproxycomponent)_ | EnvoyManager configures the Kubermatic-internal Envoy manager. |
| `updater` _[NodeportProxyComponent](#nodeportproxycomponent)_ | Updater configures the component responsible for updating the LoadBalancer
service. |
| `ipFamilyPolicy` _[IPFamilyPolicy](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#ipfamilypolicy-v1-core)_ | IPFamilyPolicy configures the IP family policy for the LoadBalancer service. |
| `ipFamilies` _[IPFamily](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#ipfamily-v1-core) array_ | IPFamilies configures the IP families to use for the LoadBalancer service. |


[Back to top](#top)



### NotificationsOptions





_Appears in:_
- [SettingSpec](#settingspec)

| Field | Description |
| --- | --- |
| `hideErrors` _boolean_ | HideErrors will silence error notifications for the dashboard. |
| `hideErrorEvents` _boolean_ | HideErrorEvents will silence error events for the dashboard. |


[Back to top](#top)



### Nutanix





_Appears in:_
- [PresetSpec](#presetspec)

| Field | Description |
| --- | --- |
| `enabled` _boolean_ | Only enabled presets will be available in the KKP dashboard. |
| `datacenter` _string_ | If datacenter is set, this preset is only applicable to the
configured datacenter. |
| `proxyURL` _string_ | Optional: To configure a HTTP proxy to access Nutanix Prism Central. |
| `username` _string_ | Username that is used to access the Nutanix Prism Central API. |
| `password` _string_ | Password corresponding to the provided user. |
| `clusterName` _string_ | The name of the Nutanix cluster to which the resources and nodes are deployed to. |
| `projectName` _string_ | Optional: Nutanix project to use. If none is given,
no project will be used. |
| `csiUsername` _string_ | Prism Element Username for CSI driver. |
| `csiPassword` _string_ | Prism Element Password for CSI driver. |
| `csiEndpoint` _string_ | CSIEndpoint to access Nutanix Prism Element for CSI driver. |
| `csiPort` _integer_ | CSIPort to use when connecting to the Nutanix Prism Element endpoint (defaults to 9440). |


[Back to top](#top)



### NutanixCSIConfig



NutanixCSIConfig contains credentials and the endpoint for the Nutanix Prism Element to which the CSI driver connects.

_Appears in:_
- [NutanixCloudSpec](#nutanixcloudspec)

| Field | Description |
| --- | --- |
| `username` _string_ | Prism Element Username for CSI driver. |
| `password` _string_ | Prism Element Password for CSI driver. |
| `endpoint` _string_ | Prism Element Endpoint to access Nutanix Prism Element for CSI driver. |
| `port` _integer_ | Optional: Port to use when connecting to the Nutanix Prism Element endpoint (defaults to 9440). |
| `storageContainer` _string_ | Optional: defaults to "SelfServiceContainer". |
| `fstype` _string_ | Optional: defaults to "xfs" |
| `ssSegmentedIscsiNetwork` _boolean_ | Optional: defaults to "false". |


[Back to top](#top)



### NutanixCloudSpec



NutanixCloudSpec specifies the access data to Nutanix.

_Appears in:_
- [CloudSpec](#cloudspec)

| Field | Description |
| --- | --- |
| `credentialsReference` _[GlobalSecretKeySelector](#globalsecretkeyselector)_ |  |
| `clusterName` _string_ | ClusterName is the Nutanix cluster that this user cluster will be deployed to. |
| `projectName` _string_ | The name of the project that this cluster is deployed into. If none is given, no project will be used. |
| `proxyURL` _string_ | Optional: Used to configure a HTTP proxy to access Nutanix Prism Central. |
| `username` _string_ | Username to access the Nutanix Prism Central API. |
| `password` _string_ | Password corresponding to the provided user. |
| `csi` _[NutanixCSIConfig](#nutanixcsiconfig)_ | NutanixCSIConfig for CSI driver that connects to a prism element. |


[Back to top](#top)



### OIDCProviderConfiguration



OIDCProviderConfiguration allows to configure OIDC provider at the Seed level. If set, it overwrites the OIDC configuration from the KubermaticConfiguration.
OIDC is later used to configure:
- access to User Cluster API-Servers (via user kubeconfigs) - https://kubernetes.io/docs/reference/access-authn-authz/authentication/#openid-connect-tokens,
- access to User Cluster's Kubernetes Dashboards.

_Appears in:_
- [SeedSpec](#seedspec)

| Field | Description |
| --- | --- |
| `issuerURL` _string_ | URL of the provider which allows the API server to discover public signing keys. |
| `issuerClientID` _string_ | IssuerClientID is the application's ID. |
| `issuerClientSecret` _string_ | IssuerClientSecret is the application's secret. |
| `cookieHashKey` _string_ | Optional: CookieHashKey is required, used to authenticate the cookie value using HMAC.
It is recommended to use a key with 32 or 64 bytes.
If not set, configuration is inherited from the default OIDC provider. |
| `cookieSecureMode` _boolean_ | Optional: CookieSecureMode if true then cookie received only with HTTPS otherwise with HTTP.
If not set, configuration is inherited from the default OIDC provider. |
| `offlineAccessAsScope` _boolean_ | Optional:  OfflineAccessAsScope if true then "offline_access" scope will be used
otherwise 'access_type=offline" query param will be passed.
If not set, configuration is inherited from the default OIDC provider. |
| `skipTLSVerify` _boolean_ | Optional: SkipTLSVerify skip TLS verification for the token issuer.
If not set, configuration is inherited from the default OIDC provider. |


[Back to top](#top)



### OIDCSettings



OIDCSettings contains OIDC configuration parameters for enabling authentication mechanism for the cluster.

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
| `usernamePrefix` _string_ |  |
| `groupsPrefix` _string_ |  |


[Back to top](#top)



### OPAIntegrationSettings



OPAIntegrationSettings configures the usage of OPA (Open Policy Agent) Gatekeeper inside the user cluster.

_Appears in:_
- [ClusterSpec](#clusterspec)

| Field | Description |
| --- | --- |
| `enabled` _boolean_ | Enables OPA Gatekeeper integration. |
| `webhookTimeoutSeconds` _integer_ | The timeout in seconds that is set for the Gatekeeper validating webhook admission review calls.
Defaults to `10` (seconds). |
| `experimentalEnableMutation` _boolean_ | Optional: Enables experimental mutation in Gatekeeper. |
| `controllerResources` _[ResourceRequirements](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#resourcerequirements-v1-core)_ | Optional: ControllerResources is the resource requirements for user cluster gatekeeper controller. |
| `auditResources` _[ResourceRequirements](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#resourcerequirements-v1-core)_ | Optional: AuditResources is the resource requirements for user cluster gatekeeper audit. |


[Back to top](#top)



### OSVersions

_Underlying type:_ `object`

OSVersions defines a map of OS version and the source to download the image.

_Appears in:_
- [ImageListWithVersions](#imagelistwithversions)
- [KubeVirtHTTPSource](#kubevirthttpsource)



### OpaOptions





_Appears in:_
- [SettingSpec](#settingspec)

| Field | Description |
| --- | --- |
| `enabled` _boolean_ |  |
| `enforced` _boolean_ |  |


[Back to top](#top)



### OpenStack





_Appears in:_
- [ProviderConfiguration](#providerconfiguration)

| Field | Description |
| --- | --- |
| `enforceCustomDisk` _boolean_ | EnforceCustomDisk will enforce the custom disk option for machines for the dashboard. |


[Back to top](#top)



### Openstack





_Appears in:_
- [PresetSpec](#presetspec)

| Field | Description |
| --- | --- |
| `enabled` _boolean_ | Only enabled presets will be available in the KKP dashboard. |
| `datacenter` _string_ | If datacenter is set, this preset is only applicable to the
configured datacenter. |
| `useToken` _boolean_ |  |
| `applicationCredentialID` _string_ |  |
| `applicationCredentialSecret` _string_ |  |
| `username` _string_ |  |
| `password` _string_ |  |
| `project` _string_ | Project, formally known as tenant. |
| `projectID` _string_ | ProjectID, formally known as tenantID. |
| `domain` _string_ |  |
| `network` _string_ | Network holds the name of the internal network When specified, all worker nodes will be attached to this network. If not specified, a network, subnet & router will be created. |
| `securityGroups` _string_ |  |
| `floatingIPPool` _string_ | FloatingIPPool holds the name of the public network The public network is reachable from the outside world and should provide the pool of IP addresses to choose from. |
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
| `project` _string_ | project, formally known as tenant. |
| `projectID` _string_ | project id, formally known as tenantID. |
| `domain` _string_ |  |
| `applicationCredentialID` _string_ |  |
| `applicationCredentialSecret` _string_ |  |
| `useToken` _boolean_ |  |
| `token` _string_ | Used internally during cluster creation |
| `network` _string_ | Network holds the name of the internal network
When specified, all worker nodes will be attached to this network. If not specified, a network, subnet & router will be created.


Note that the network is internal if the "External" field is set to false |
| `securityGroups` _string_ |  |
| `nodePortsAllowedIPRange` _string_ | A CIDR range that will be used to allow access to the node port range in the security group to. Only applies if
the security group is generated by KKP and not preexisting.
If NodePortsAllowedIPRange nor NodePortsAllowedIPRanges is set, the node port range can be accessed from anywhere. |
| `nodePortsAllowedIPRanges` _[NetworkRanges](#networkranges)_ | Optional: CIDR ranges that will be used to allow access to the node port range in the security group to. Only applies if
the security group is generated by KKP and not preexisting.
If NodePortsAllowedIPRange nor NodePortsAllowedIPRanges is set, the node port range can be accessed from anywhere. |
| `floatingIPPool` _string_ | FloatingIPPool holds the name of the public network
The public network is reachable from the outside world
and should provide the pool of IP addresses to choose from.


When specified, all worker nodes will receive a public ip from this floating ip pool


Note that the network is external if the "External" field is set to true |
| `routerID` _string_ |  |
| `subnetID` _string_ |  |
| `ipv6SubnetID` _string_ | IPv6SubnetID holds the ID of the subnet used for IPv6 networking.
If not provided, a new subnet will be created if IPv6 is enabled. |
| `ipv6SubnetPool` _string_ | IPv6SubnetPool holds the name of the subnet pool used for creating new IPv6 subnets.
If not provided, the default IPv6 subnet pool will be used. |
| `useOctavia` _boolean_ | Whether or not to use Octavia for LoadBalancer type of Service
implementation instead of using Neutron-LBaaS.
Attention:Openstack CCM use Octavia as default load balancer
implementation since v1.17.0


Takes precedence over the 'use_octavia' flag provided at datacenter
level if both are specified. |
| `enableIngressHostname` _boolean_ | Enable the `enable-ingress-hostname` cloud provider option on the Openstack CCM. Can only be used with the
external CCM and might be deprecated and removed in future versions as it is considered a workaround for the PROXY
protocol to preserve client IPs. |
| `ingressHostnameSuffix` _string_ | Set a specific suffix for the hostnames used for the PROXY protocol workaround that is enabled by EnableIngressHostname.
The suffix is set to `nip.io` by default. Can only be used with the external CCM and might be deprecated and removed in
future versions as it is considered a workaround only. |
| `cinderTopologyEnabled` _boolean_ | Flag to configure enablement of topology support for the Cinder CSI plugin.
This requires Nova and Cinder to have matching availability zones configured. |


[Back to top](#top)



### OpenstackNodeSizeRequirements

_Underlying type:_ `[struct{MinimumVCPUs int "json:\"minimumVCPUs,omitempty\""; MinimumMemory int "json:\"minimumMemory,omitempty\""}](#struct{minimumvcpus-int-"json:\"minimumvcpus,omitempty\"";-minimummemory-int-"json:\"minimummemory,omitempty\""})`



_Appears in:_
- [DatacenterSpecOpenstack](#datacenterspecopenstack)



### OperatingSystemManager



OperatingSystemManager configures the image repo and the tag version for osm deployment.

_Appears in:_
- [KubermaticUserClusterConfiguration](#kubermaticuserclusterconfiguration)

| Field | Description |
| --- | --- |
| `imageRepository` _string_ | ImageRepository is used to override the OperatingSystemManager image repository.
It is recommended to use this field only for development, tests and PoC purposes. For production environments.
it is not recommended, to use this field due to compatibility with the overall KKP stack. |
| `imageTag` _string_ | ImageTag is used to override the OperatingSystemManager image.
It is recommended to use this field only for development, tests and PoC purposes. For production environments.
it is not recommended, to use this field due to compatibility with the overall KKP stack. |


[Back to top](#top)



### OperatingSystemProfileList

_Underlying type:_ `OperatingSystem]string`

OperatingSystemProfileList defines a map of operating system and the OperatingSystemProfile to use.

_Appears in:_
- [DatacenterSpec](#datacenterspec)



### OperationType

_Underlying type:_ `string`

OperationType is the type defining the operations triggering the compatibility check (CREATE or UPDATE).

_Appears in:_
- [Incompatibility](#incompatibility)



### Packet





_Appears in:_
- [PresetSpec](#presetspec)

| Field | Description |
| --- | --- |
| `enabled` _boolean_ | Only enabled presets will be available in the KKP dashboard. |
| `datacenter` _string_ | If datacenter is set, this preset is only applicable to the
configured datacenter. |
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



### Parameters

_Underlying type:_ `RawMessage`



_Appears in:_
- [ConstraintSpec](#constraintspec)



### PreAllocatedDataVolume





_Appears in:_
- [KubevirtCloudSpec](#kubevirtcloudspec)

| Field | Description |
| --- | --- |
| `name` _string_ |  |
| `annotations` _object (keys:string, values:string)_ |  |
| `url` _string_ |  |
| `size` _string_ |  |
| `storageClass` _string_ |  |


[Back to top](#top)



### Preset



Presets are preconfigured cloud provider credentials that can be applied
to new clusters. This frees end users from having to know the actual
credentials used for their clusters.

_Appears in:_
- [PresetList](#presetlist)

| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `Preset`
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[PresetSpec](#presetspec)_ |  |


[Back to top](#top)





### PresetList



PresetList is the type representing a PresetList.



| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `PresetList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[Preset](#preset) array_ | List of presets |


[Back to top](#top)



### PresetSpec



Presets specifies default presets for supported providers.

_Appears in:_
- [Preset](#preset)

| Field | Description |
| --- | --- |
| `digitalocean` _[Digitalocean](#digitalocean)_ | Access data for DigitalOcean. |
| `hetzner` _[Hetzner](#hetzner)_ | Access data for Hetzner. |
| `azure` _[Azure](#azure)_ | Access data for Microsoft Azure Cloud. |
| `vsphere` _[VSphere](#vsphere)_ | Access data for vSphere. |
| `aws` _[AWS](#aws)_ | Access data for Amazon Web Services(AWS) Cloud. |
| `openstack` _[Openstack](#openstack)_ | Access data for OpenStack. |
| `packet` _[Packet](#packet)_ | Access data for Packet Cloud. |
| `gcp` _[GCP](#gcp)_ | Access data for Google Cloud Platform(GCP). |
| `kubevirt` _[Kubevirt](#kubevirt)_ | Access data for KuberVirt. |
| `alibaba` _[Alibaba](#alibaba)_ | Access data for Alibaba Cloud. |
| `anexia` _[Anexia](#anexia)_ | Access data for Anexia. |
| `nutanix` _[Nutanix](#nutanix)_ | Access data for Nutanix. |
| `vmwareclouddirector` _[VMwareCloudDirector](#vmwareclouddirector)_ | Access data for VMware Cloud Director. |
| `gke` _[GKE](#gke)_ | Access data for Google Kubernetes Engine(GKE). |
| `eks` _[EKS](#eks)_ | Access data for Amazon Elastic Kubernetes Service(EKS). |
| `aks` _[AKS](#aks)_ | Access data for Azure Kubernetes Service(AKS). |
| `requiredEmails` _string array_ | RequiredEmails is a list of e-mail addresses that this presets should
be restricted to. Each item in the list can be either a full e-mail
address or just a domain name. This restriction is only enforced in the
KKP API. |
| `projects` _string array_ | Projects is a list of project IDs that this preset is limited to. |
| `enabled` _boolean_ | Only enabled presets will be available in the KKP dashboard. |


[Back to top](#top)



### Project



Project is the type describing a project. A project is a collection of
SSH keys, clusters and members. Members are assigned by creating UserProjectBinding
objects.

_Appears in:_
- [ProjectList](#projectlist)

| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `Project`
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[ProjectSpec](#projectspec)_ | Spec describes the configuration of the project. |
| `status` _[ProjectStatus](#projectstatus)_ | Status holds the current status of the project. |


[Back to top](#top)





### ProjectList



ProjectList is a collection of projects.



| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `ProjectList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[Project](#project) array_ | Items is the list of the projects. |


[Back to top](#top)



### ProjectPhase

_Underlying type:_ `string`



_Appears in:_
- [ProjectStatus](#projectstatus)



### ProjectSpec



ProjectSpec is a specification of a project.

_Appears in:_
- [Project](#project)

| Field | Description |
| --- | --- |
| `name` _string_ | Name is the human-readable name given to the project. |


[Back to top](#top)



### ProjectStatus



ProjectStatus represents the current status of a project.

_Appears in:_
- [Project](#project)

| Field | Description |
| --- | --- |
| `phase` _[ProjectPhase](#projectphase)_ | Phase describes the project phase. New projects are in the `Inactive`
phase; after being reconciled they move to `Active` and during deletion
they are `Terminating`. |


[Back to top](#top)



### ProviderConfiguration





_Appears in:_
- [SettingSpec](#settingspec)

| Field | Description |
| --- | --- |
| `openStack` _[OpenStack](#openstack)_ | OpenStack are the configurations for openstack provider. |
| `vmwareCloudDirector` _[VMwareCloudDirectorSettings](#vmwareclouddirectorsettings)_ | VMwareCloudDirector are the configurations for VMware Cloud Director provider. |


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
- [VMwareCloudDirector](#vmwareclouddirector)
- [VSphere](#vsphere)

| Field | Description |
| --- | --- |
| `enabled` _boolean_ | Only enabled presets will be available in the KKP dashboard. |
| `datacenter` _string_ | If datacenter is set, this preset is only applicable to the
configured datacenter. |


[Back to top](#top)





### ProxySettings



ProxySettings allow configuring a HTTP proxy for the controlplanes
and nodes.

_Appears in:_
- [NodeSettings](#nodesettings)
- [SeedSpec](#seedspec)

| Field | Description |
| --- | --- |
| `httpProxy` _[ProxyValue](#proxyvalue)_ | Optional: If set, this proxy will be configured for both HTTP and HTTPS. |
| `noProxy` _[ProxyValue](#proxyvalue)_ | Optional: If set this will be set as NO_PROXY environment variable on the node;
The value must be a comma-separated list of domains for which no proxy
should be used, e.g. "*.example.com,internal.dev".
Note that the in-cluster apiserver URL will be automatically prepended
to this value. |


[Back to top](#top)



### ProxyValue

_Underlying type:_ `string`



_Appears in:_
- [NodeSettings](#nodesettings)
- [ProxySettings](#proxysettings)



### ResourceDetails



ResourceDetails holds the CPU, Memory and Storage quantities.

_Appears in:_
- [ClusterStatus](#clusterstatus)
- [DefaultProjectResourceQuota](#defaultprojectresourcequota)
- [ResourceQuotaSpec](#resourcequotaspec)
- [ResourceQuotaStatus](#resourcequotastatus)



### ResourceQuota



ResourceQuota specifies the amount of cluster resources a project can use.

_Appears in:_
- [ResourceQuotaList](#resourcequotalist)

| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `ResourceQuota`
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[ResourceQuotaSpec](#resourcequotaspec)_ | Spec describes the desired state of the resource quota. |
| `status` _[ResourceQuotaStatus](#resourcequotastatus)_ | Status holds the current state of the resource quota. |


[Back to top](#top)



### ResourceQuotaList



ResourceQuotaList is a collection of resource quotas.



| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `ResourceQuotaList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[ResourceQuota](#resourcequota) array_ | Items is the list of the resource quotas. |


[Back to top](#top)



### ResourceQuotaSpec



ResourceQuotaSpec describes the desired state of a resource quota.

_Appears in:_
- [ResourceQuota](#resourcequota)

| Field | Description |
| --- | --- |
| `subject` _[Subject](#subject)_ | Subject specifies to which entity the quota applies to. |
| `quota` _[ResourceDetails](#resourcedetails)_ | Quota specifies the current maximum allowed usage of resources. |


[Back to top](#top)



### ResourceQuotaStatus



ResourceQuotaStatus describes the current state of a resource quota.

_Appears in:_
- [ResourceQuota](#resourcequota)

| Field | Description |
| --- | --- |
| `globalUsage` _[ResourceDetails](#resourcedetails)_ | GlobalUsage is holds the current usage of resources for all seeds. |
| `localUsage` _[ResourceDetails](#resourcedetails)_ | LocalUsage is holds the current usage of resources for the local seed. |


[Back to top](#top)



### RuleGroup





_Appears in:_
- [RuleGroupList](#rulegrouplist)

| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `RuleGroup`
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[RuleGroupSpec](#rulegroupspec)_ |  |


[Back to top](#top)



### RuleGroupList







| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `RuleGroupList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[RuleGroup](#rulegroup) array_ |  |


[Back to top](#top)



### RuleGroupSpec





_Appears in:_
- [RuleGroup](#rulegroup)

| Field | Description |
| --- | --- |
| `isDefault` _boolean_ | IsDefault indicates whether the ruleGroup is default |
| `ruleGroupType` _[RuleGroupType](#rulegrouptype)_ | RuleGroupType is the type of this ruleGroup applies to. It can be `Metrics` or `Logs`. |
| `cluster` _[ObjectReference](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#objectreference-v1-core)_ | Cluster is the reference to the cluster the ruleGroup should be created in. All fields
except for the name are ignored. |
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
| `name` _string_ | Name is the human readable name for this SSH key. |
| `owner` _string_ | Owner is the name of the User object that owns this SSH key.
Deprecated: This field is not used anymore. |
| `project` _string_ | Project is the name of the Project object that this SSH key belongs to.
This field is immutable. |
| `clusters` _string array_ | Clusters is the list of cluster names that this SSH key is assigned to. |
| `fingerprint` _string_ | Fingerprint is calculated server-side based on the supplied public key
and doesn't need to be set by clients. |
| `publicKey` _string_ | PublicKey is the SSH public key. |


[Back to top](#top)



### SecretboxEncryptionConfiguration



SecretboxEncryptionConfiguration defines static key encryption based on the 'secretbox' solution for Kubernetes.

_Appears in:_
- [EncryptionConfiguration](#encryptionconfiguration)

| Field | Description |
| --- | --- |
| `keys` _[SecretboxKey](#secretboxkey) array_ | List of 'secretbox' encryption keys. The first element of this list is considered
the "primary" key which will be used for encrypting data while writing it. Additional
keys will be used for decrypting data while reading it, if keys higher in the list
did not succeed in decrypting it. |


[Back to top](#top)



### SecretboxKey



SecretboxKey stores a key or key reference for encrypting Kubernetes API data at rest with a static key.

_Appears in:_
- [SecretboxEncryptionConfiguration](#secretboxencryptionconfiguration)

| Field | Description |
| --- | --- |
| `name` _string_ | Identifier of a key, used in various places to refer to the key. |
| `value` _string_ | Value contains a 32-byte random key that is base64 encoded. This is the key used
for encryption. Can be generated via `head -c 32 /dev/urandom | base64`, for example. |
| `secretRef` _[SecretKeySelector](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#secretkeyselector-v1-core)_ | Instead of passing the sensitive encryption key via the `value` field, a secret can be
referenced. The key of the secret referenced here needs to hold a key equivalent to the `value` field. |


[Back to top](#top)



### Seed



Seed is the type representing a Seed cluster. Seed clusters host the the control planes
for KKP user clusters.

_Appears in:_
- [SeedList](#seedlist)

| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `Seed`
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[SeedSpec](#seedspec)_ | Spec describes the configuration of the Seed cluster. |
| `status` _[SeedStatus](#seedstatus)_ | Status holds the runtime information of the Seed cluster. |


[Back to top](#top)



### SeedCondition





_Appears in:_
- [SeedStatus](#seedstatus)

| Field | Description |
| --- | --- |
| `status` _[ConditionStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#conditionstatus-v1-core)_ | Status of the condition, one of True, False, Unknown. |
| `lastHeartbeatTime` _[Time](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#time-v1-meta)_ | Last time we got an update on a given condition. |
| `lastTransitionTime` _[Time](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#time-v1-meta)_ | Last time the condition transit from one status to another. |
| `reason` _string_ | (brief) reason for the condition's last transition. |
| `message` _string_ | Human readable message indicating details about last transition. |


[Back to top](#top)



### SeedConditionType

_Underlying type:_ `string`

SeedConditionType is used to indicate the type of a seed condition. For all condition
types, the `true` value must indicate success. All condition types must be registered
within the `AllSeedConditionTypes` variable.

_Appears in:_
- [SeedStatus](#seedstatus)



### SeedList



SeedDatacenterList is the type representing a SeedDatacenterList.



| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `SeedList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
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



### SeedPhase

_Underlying type:_ `string`



_Appears in:_
- [SeedStatus](#seedstatus)



### SeedSpec



The spec for a seed cluster.

_Appears in:_
- [Seed](#seed)

| Field | Description |
| --- | --- |
| `country` _string_ | Optional: Country of the seed as ISO-3166 two-letter code, e.g. DE or UK.
For informational purposes in the Kubermatic dashboard only. |
| `location` _string_ | Optional: Detailed location of the cluster, like "Hamburg" or "Datacenter 7".
For informational purposes in the Kubermatic dashboard only. |
| `kubeconfig` _[ObjectReference](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#objectreference-v1-core)_ | A reference to the Kubeconfig of this cluster. The Kubeconfig must
have cluster-admin privileges. This field is mandatory for every
seed, even if there are no datacenters defined yet. |
| `datacenters` _object (keys:string, values:[Datacenter](#datacenter))_ | Datacenters contains a map of the possible datacenters (DCs) in this seed.
Each DC must have a globally unique identifier (i.e. names must be unique
across all seeds). |
| `seedDNSOverwrite` _string_ | Optional: This can be used to override the DNS name used for this seed.
By default the seed name is used. |
| `nodeportProxy` _[NodeportProxyConfig](#nodeportproxyconfig)_ | NodeportProxy can be used to configure the NodePort proxy service that is
responsible for making user-cluster control planes accessible from the outside. |
| `proxySettings` _[ProxySettings](#proxysettings)_ | Optional: ProxySettings can be used to configure HTTP proxy settings on the
worker nodes in user clusters. However, proxy settings on nodes take precedence. |
| `exposeStrategy` _[ExposeStrategy](#exposestrategy)_ | Optional: ExposeStrategy explicitly sets the expose strategy for this seed cluster, if not set, the default provided by the master is used. |
| `mla` _[SeedMLASettings](#seedmlasettings)_ | Optional: MLA allows configuring seed level MLA (Monitoring, Logging & Alerting) stack settings. |
| `defaultComponentSettings` _[ComponentSettings](#componentsettings)_ | DefaultComponentSettings are default values to set for newly created clusters.
Deprecated: Use DefaultClusterTemplate instead. |
| `defaultClusterTemplate` _string_ | DefaultClusterTemplate is the name of a cluster template of scope "seed" that is used
to default all new created clusters |
| `metering` _[MeteringConfiguration](#meteringconfiguration)_ | Metering configures the metering tool on user clusters across the seed. |
| `etcdBackupRestore` _[EtcdBackupRestore](#etcdbackuprestore)_ | EtcdBackupRestore holds the configuration of the automatic etcd backup restores for the Seed;
if this is set, the new backup/restore controllers are enabled for this Seed. |
| `oidcProviderConfiguration` _[OIDCProviderConfiguration](#oidcproviderconfiguration)_ | OIDCProviderConfiguration allows to configure OIDC provider at the Seed level. |
| `kubelb` _[KubeLBSettings](#kubelbsettings)_ | KubeLB holds the configuration for the kubeLB at the Seed level. This component is responsible for managing load balancers.
Only available in Enterprise Edition. |


[Back to top](#top)



### SeedStatus



SeedStatus contains runtime information regarding the seed.

_Appears in:_
- [Seed](#seed)

| Field | Description |
| --- | --- |
| `phase` _[SeedPhase](#seedphase)_ | Phase contains a human readable text to indicate the seed cluster status. No logic should be tied
to this field, as its content can change in between KKP releases. |
| `clusters` _integer_ | Clusters is the total number of user clusters that exist on this seed. |
| `versions` _[SeedVersionsStatus](#seedversionsstatus)_ | Versions contains information regarding versions of components in the cluster and the cluster
itself. |
| `conditions` _object (keys:[SeedConditionType](#seedconditiontype), values:[SeedCondition](#seedcondition))_ | Conditions contains conditions the seed is in, its primary use case is status signaling
between controllers or between controllers and the API. |


[Back to top](#top)



### SeedVersionsStatus



SeedVersionsStatus contains information regarding versions of components in the cluster
and the cluster itself.

_Appears in:_
- [SeedStatus](#seedstatus)

| Field | Description |
| --- | --- |
| `kubermatic` _string_ | Kubermatic is the version of the currently deployed KKP components. Note that a permanent
version skew between master and seed is not supported and KKP setups should never run for
longer times with a skew between the clusters. |
| `cluster` _string_ | Cluster is the Kubernetes version of the cluster's control plane. |


[Back to top](#top)



### ServiceAccountSettings





_Appears in:_
- [ClusterSpec](#clusterspec)

| Field | Description |
| --- | --- |
| `tokenVolumeProjectionEnabled` _boolean_ |  |
| `issuer` _string_ | Issuer is the identifier of the service account token issuer
If this is not specified, it will be set to the URL of apiserver by default |
| `apiAudiences` _string array_ | APIAudiences are the Identifiers of the API
If this is not specified, it will be set to a single element list containing the issuer URL |


[Back to top](#top)



### SettingSpec





_Appears in:_
- [KubermaticSetting](#kubermaticsetting)

| Field | Description |
| --- | --- |
| `customLinks` _[CustomLinks](#customlinks)_ | CustomLinks are additional links that can be shown the dashboard's footer. |
| `defaultNodeCount` _integer_ | DefaultNodeCount is the default number of replicas for the initial MachineDeployment. |
| `displayDemoInfo` _boolean_ | DisplayDemoInfo controls whether a "Demo System" hint is shown in the footer. |
| `displayAPIDocs` _boolean_ | DisplayDemoInfo controls whether a a link to the KKP API documentation is shown in the footer. |
| `displayTermsOfService` _boolean_ | DisplayDemoInfo controls whether a a link to TOS is shown in the footer. |
| `enableDashboard` _boolean_ | EnableDashboard enables the link to the Kubernetes dashboard for a user cluster. |
| `enableWebTerminal` _boolean_ | EnableWebTerminal enables the Web Terminal feature for the user clusters. |
| `enableShareCluster` _boolean_ | EnableShareCluster enables the Share Cluster feature for the user clusters. |
| `enableOIDCKubeconfig` _boolean_ |  |
| `enableClusterBackup` _boolean_ | EnableClusterBackup enables the Cluster Backup feature in the dashboard. |
| `disableAdminKubeconfig` _boolean_ | DisableAdminKubeconfig disables the admin kubeconfig functionality on the dashboard. |
| `userProjectsLimit` _integer_ | UserProjectsLimit is the maximum number of projects a user can create. |
| `restrictProjectCreation` _boolean_ |  |
| `restrictProjectDeletion` _boolean_ |  |
| `enableExternalClusterImport` _boolean_ |  |
| `cleanupOptions` _[CleanupOptions](#cleanupoptions)_ | CleanupOptions control what happens when a cluster is deleted via the dashboard. |
| `opaOptions` _[OpaOptions](#opaoptions)_ |  |
| `mlaOptions` _[MlaOptions](#mlaoptions)_ |  |
| `mlaAlertmanagerPrefix` _string_ |  |
| `mlaGrafanaPrefix` _string_ |  |
| `notifications` _[NotificationsOptions](#notificationsoptions)_ | Notifications are the configuration for notifications on dashboard. |
| `providerConfiguration` _[ProviderConfiguration](#providerconfiguration)_ | ProviderConfiguration are the cloud provider specific configurations on dashboard. |
| `machineDeploymentVMResourceQuota` _[MachineFlavorFilter](#machineflavorfilter)_ | MachineDeploymentVMResourceQuota is used to filter out allowed machine flavors based on the specified resource limits like CPU, Memory, and GPU etc. |
| `allowedOperatingSystems` _[allowedOperatingSystems](#allowedoperatingsystems)_ | AllowedOperatingSystems shows if the operating system is allowed to be use in the machinedeployment. |
| `defaultQuota` _[DefaultProjectResourceQuota](#defaultprojectresourcequota)_ | DefaultProjectResourceQuota allows to configure a default project resource quota which
will be set for all projects that do not have a custom quota already set. EE-version only. |
| `machineDeploymentOptions` _[MachineDeploymentOptions](#machinedeploymentoptions)_ |  |
| `disableChangelogPopup` _boolean_ | DisableChangelogPopup disables the changelog popup in KKP dashboard. |


[Back to top](#top)



### StatefulSetSettings





_Appears in:_
- [ComponentSettings](#componentsettings)

| Field | Description |
| --- | --- |
| `resources` _[ResourceRequirements](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#resourcerequirements-v1-core)_ |  |


[Back to top](#top)



### Subject



Subject describes the entity to which the quota applies to.

_Appears in:_
- [ResourceQuotaSpec](#resourcequotaspec)

| Field | Description |
| --- | --- |
| `name` _string_ | Name of the quota subject. |


[Back to top](#top)



### SubnetCIDR

_Underlying type:_ `string`

SubnetCIDR is used to store IPv4/IPv6 CIDR.

_Appears in:_
- [IPAMAllocationSpec](#ipamallocationspec)
- [IPAMPoolDatacenterSettings](#ipampooldatacentersettings)



### SystemApplicationsConfiguration



SystemApplicationsConfiguration contains configuration for system Applications (e.g. CNI).

_Appears in:_
- [KubermaticUserClusterConfiguration](#kubermaticuserclusterconfiguration)

| Field | Description |
| --- | --- |
| `helmRepository` _string_ | HelmRepository specifies OCI repository containing Helm charts of system Applications. |
| `helmRegistryConfigFile` _[SecretKeySelector](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#secretkeyselector-v1-core)_ | HelmRegistryConfigFile optionally holds the ref and key in the secret for the OCI registry credential file.
The value is dockercfg file that follows the same format rules as ~/.docker/config.json
The Secret must exist in the namespace where KKP is installed (default is "kubermatic").
The Secret must be annotated with `apps.kubermatic.k8c.io/secret-type:` set to "helm". |


[Back to top](#top)



### Update



Update represents an update option for a user cluster.

_Appears in:_
- [KubermaticVersioningConfiguration](#kubermaticversioningconfiguration)

| Field | Description |
| --- | --- |
| `from` _string_ | From is the version from which an update is allowed. Wildcards are allowed, e.g. "1.18.*". |
| `to` _string_ | To is the version to which an update is allowed.
Must be a valid version if `automatic` is set to true, e.g. "1.20.13".
Can be a wildcard otherwise, e.g. "1.20.*". |
| `automatic` _boolean_ | Automatic controls whether this update is executed automatically
for the control plane of all matching user clusters.
--- |
| `automaticNodeUpdate` _boolean_ | Automatic controls whether this update is executed automatically
for the worker nodes of all matching user clusters.
--- |


[Back to top](#top)



### UpdateWindow



UpdateWindow allows defining windows for maintenance tasks related to OS updates.
This is only applied to cluster nodes using Flatcar Linux.
The reference time for this is the node system time and might differ from
the user's timezone, which needs to be considered when configuring a window.

_Appears in:_
- [ClusterSpec](#clusterspec)

| Field | Description |
| --- | --- |
| `start` _string_ | Sets the start time of the update window. This can be a time of day in 24h format, e.g. `22:30`,
or a day of week plus a time of day, for example `Mon 21:00`. Only short names for week days are supported,
i.e. `Mon`, `Tue`, `Wed`, `Thu`, `Fri`, `Sat` and `Sun`. |
| `length` _string_ | Sets the length of the update window beginning with the start time. This needs to be a valid duration
as parsed by Go's time.ParseDuration (https://pkg.go.dev/time#ParseDuration), e.g. `2h`. |


[Back to top](#top)



### User



User specifies a KKP user. Users can be either humans or KKP service
accounts.

_Appears in:_
- [UserList](#userlist)

| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `User`
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[UserSpec](#userspec)_ | Spec describes a KKP user. |
| `status` _[UserStatus](#userstatus)_ | Status holds the information about the KKP user. |


[Back to top](#top)



### UserList



UserList is a list of users.



| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `UserList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[User](#user) array_ | Items is the list of KKP users. |


[Back to top](#top)



### UserProjectBinding



UserProjectBinding specifies a binding between a user and a project
This resource is used by the user management to manipulate members of the given project.

_Appears in:_
- [UserProjectBindingList](#userprojectbindinglist)

| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `UserProjectBinding`
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[UserProjectBindingSpec](#userprojectbindingspec)_ | Spec describes a KKP user and project binding. |


[Back to top](#top)



### UserProjectBindingList



UserProjectBindingList is a list of KKP user and project bindings.



| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `UserProjectBindingList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[UserProjectBinding](#userprojectbinding) array_ | Items is the list of KKP user and project bindings. |


[Back to top](#top)



### UserProjectBindingSpec



UserProjectBindingSpec specifies a user and project binding.

_Appears in:_
- [UserProjectBinding](#userprojectbinding)

| Field | Description |
| --- | --- |
| `userEmail` _string_ | UserEmail is the email of the user that is bound to the given project. |
| `projectID` _string_ | ProjectID is the name of the target project. |
| `group` _string_ | Group is the user's group, determining their permissions within the project.
Must be one of `owners`, `editors`, `viewers` or `projectmanagers`. |


[Back to top](#top)



### UserSSHKey



UserSSHKey specifies a users UserSSHKey.

_Appears in:_
- [UserSSHKeyList](#usersshkeylist)

| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `UserSSHKey`
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[SSHKeySpec](#sshkeyspec)_ |  |


[Back to top](#top)



### UserSSHKeyList



UserSSHKeyList specifies a users UserSSHKey.



| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `UserSSHKeyList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[UserSSHKey](#usersshkey) array_ |  |


[Back to top](#top)



### UserSettings



UserSettings represent an user settings.

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
| `useClustersView` _boolean_ |  |


[Back to top](#top)



### UserSpec



UserSpec specifies a user.

_Appears in:_
- [User](#user)

| Field | Description |
| --- | --- |
| `id` _string_ | ID is an unused legacy field.
Deprecated: do not set this field anymore. |
| `name` _string_ | Name is the full name of this user. |
| `email` _string_ | Email is the email address of this user. Emails must be globally unique across
all KKP users. |
| `admin` _boolean_ | IsAdmin defines whether this user is an administrator with additional permissions.
Admins can for example see all projects and clusters in the KKP dashboard. |
| `groups` _string array_ | Groups holds the information to which groups the user belongs to. Set automatically when logging in to the
KKP API, and used by the KKP API. |
| `project` _string_ | Project is the name of the project that this service account user is tied to. This
field is only applicable to service accounts and regular users must not set this field. |
| `settings` _[UserSettings](#usersettings)_ | Settings contains both user-configurable and system-owned configuration for the
KKP dashboard. |
| `invalidTokensReference` _[GlobalSecretKeySelector](#globalsecretkeyselector)_ | InvalidTokensReference is a reference to a Secret that contains invalidated
login tokens. The tokens are used to provide a safe logout mechanism. |


[Back to top](#top)



### UserStatus



UserStatus stores status information about a user.

_Appears in:_
- [User](#user)

| Field | Description |
| --- | --- |
| `lastSeen` _[Time](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#time-v1-meta)_ |  |


[Back to top](#top)



### VMwareCloudDirector





_Appears in:_
- [PresetSpec](#presetspec)

| Field | Description |
| --- | --- |
| `enabled` _boolean_ | Only enabled presets will be available in the KKP dashboard. |
| `datacenter` _string_ | If datacenter is set, this preset is only applicable to the
configured datacenter. |
| `username` _string_ | The VMware Cloud Director user name. |
| `password` _string_ | The VMware Cloud Director user password. |
| `apiToken` _string_ | The VMware Cloud Director API token. |
| `vdc` _string_ | The organizational virtual data center. |
| `organization` _string_ | The name of organization to use. |
| `ovdcNetwork` _string_ | The name of organizational virtual data center network that will be associated with the VMs and vApp.
Deprecated: OVDCNetwork has been deprecated starting with KKP 2.25 and will be removed in KKP 2.27+. It is recommended to use OVDCNetworks instead. |
| `ovdcNetworks` _string array_ | OVDCNetworks is the list of organizational virtual data center networks that will be attached to the vApp and can be consumed the VMs. |


[Back to top](#top)



### VMwareCloudDirectorCSIConfig





_Appears in:_
- [VMwareCloudDirectorCloudSpec](#vmwareclouddirectorcloudspec)

| Field | Description |
| --- | --- |
| `storageProfile` _string_ | The name of the storage profile to use for disks created by CSI driver |
| `filesystem` _string_ | Filesystem to use for named disks, defaults to "ext4" |


[Back to top](#top)



### VMwareCloudDirectorCloudSpec



VMwareCloudDirectorCloudSpec specifies access data to VMware Cloud Director cloud.

_Appears in:_
- [CloudSpec](#cloudspec)

| Field | Description |
| --- | --- |
| `credentialsReference` _[GlobalSecretKeySelector](#globalsecretkeyselector)_ |  |
| `username` _string_ | The VMware Cloud Director user name. |
| `password` _string_ | The VMware Cloud Director user password. |
| `apiToken` _string_ | The VMware Cloud Director API token. |
| `organization` _string_ | The name of organization to use. |
| `vdc` _string_ | The organizational virtual data center. |
| `ovdcNetwork` _string_ | The name of organizational virtual data center network that will be associated with the VMs and vApp.
Deprecated: OVDCNetwork has been deprecated starting with KKP 2.25 and will be removed in KKP 2.27+. It is recommended to use OVDCNetworks instead. |
| `ovdcNetworks` _string array_ | OVDCNetworks is the list of organizational virtual data center networks that will be attached to the vApp and can be consumed the VMs. |
| `vapp` _string_ | VApp used for isolation of VMs and their associated network |
| `csi` _[VMwareCloudDirectorCSIConfig](#vmwareclouddirectorcsiconfig)_ | Config for CSI driver |


[Back to top](#top)



### VMwareCloudDirectorSettings





_Appears in:_
- [ProviderConfiguration](#providerconfiguration)

| Field | Description |
| --- | --- |
| `ipAllocationModes` _[ipAllocationMode](#ipallocationmode) array_ | IPAllocationModes are the allowed IP allocation modes for the VMware Cloud Director provider. If not set, all modes are allowed. |


[Back to top](#top)



### VSphere





_Appears in:_
- [PresetSpec](#presetspec)

| Field | Description |
| --- | --- |
| `enabled` _boolean_ | Only enabled presets will be available in the KKP dashboard. |
| `datacenter` _string_ | If datacenter is set, this preset is only applicable to the
configured datacenter. |
| `username` _string_ | The vSphere user name. |
| `password` _string_ | The vSphere user password. |
| `vmNetName` _string_ | Deprecated: Use networks instead. |
| `networks` _string array_ | List of vSphere networks. |
| `datastore` _string_ | Datastore to be used for storing virtual machines and as a default for dynamic volume provisioning, it is mutually exclusive with DatastoreCluster. |
| `datastoreCluster` _string_ | DatastoreCluster to be used for storing virtual machines, it is mutually exclusive with Datastore. |
| `resourcePool` _string_ | ResourcePool is used to manage resources such as cpu and memory for vSphere virtual machines. The resource pool should be defined on vSphere cluster level. |
| `basePath` _string_ | BasePath configures a vCenter folder path that KKP will create an individual cluster folder in.
If it's an absolute path, the RootPath configured in the datacenter will be ignored. If it is a relative path,
the BasePath part will be appended to the RootPath to construct the full path. For both cases,
the full folder structure needs to exist. KKP will only try to create the cluster folder. |


[Back to top](#top)



### VSphereCloudSpec



VSphereCloudSpec specifies access data to VSphere cloud.

_Appears in:_
- [CloudSpec](#cloudspec)

| Field | Description |
| --- | --- |
| `credentialsReference` _[GlobalSecretKeySelector](#globalsecretkeyselector)_ |  |
| `username` _string_ | The vSphere user name. |
| `password` _string_ | The vSphere user password. |
| `vmNetName` _string_ | The name of the vSphere network.
Deprecated: Use networks instead. |
| `networks` _string array_ | List of vSphere networks. |
| `folder` _string_ | Folder to be used to group the provisioned virtual
machines. |
| `basePath` _string_ | Optional: BasePath configures a vCenter folder path that KKP will create an individual cluster folder in.
If it's an absolute path, the RootPath configured in the datacenter will be ignored. If it is a relative path,
the BasePath part will be appended to the RootPath to construct the full path. For both cases,
the full folder structure needs to exist. KKP will only try to create the cluster folder. |
| `datastore` _string_ | Datastore to be used for storing virtual machines and as a default for
dynamic volume provisioning, it is mutually exclusive with
DatastoreCluster. |
| `datastoreCluster` _string_ | DatastoreCluster to be used for storing virtual machines, it is mutually
exclusive with Datastore. |
| `storagePolicy` _string_ | StoragePolicy to be used for storage provisioning |
| `resourcePool` _string_ | ResourcePool is used to manage resources such as cpu and memory for vSphere virtual machines. The resource pool
should be defined on vSphere cluster level. |
| `infraManagementUser` _[VSphereCredentials](#vspherecredentials)_ | This user will be used for everything except cloud provider functionality |
| `tags` _[VSphereTag](#vspheretag)_ | Tags represents the tags that are attached or created on the cluster level, that are then propagated down to the
MachineDeployments. In order to attach tags on MachineDeployment, users must create the tag on a cluster level first
then attach that tag on the MachineDeployment. |


[Back to top](#top)



### VSphereCredentials



VSphereCredentials credentials represents a credential for accessing vSphere.

_Appears in:_
- [DatacenterSpecVSphere](#datacenterspecvsphere)
- [VSphereCloudSpec](#vspherecloudspec)

| Field | Description |
| --- | --- |
| `username` _string_ |  |
| `password` _string_ |  |


[Back to top](#top)



### VSphereTag



VSphereTag represents the tags that are attached or created on the cluster level, that are then propagated down to the
MachineDeployments. In order to attach tags on MachineDeployment, users must create the tag on a cluster level first
then attach that tag on the MachineDeployment.

_Appears in:_
- [VSphereCloudSpec](#vspherecloudspec)

| Field | Description |
| --- | --- |
| `tags` _string array_ | Tags represents the name of the created tags. |
| `categoryID` _string_ | CategoryID is the id of the vsphere category that the tag belongs to. If the category id is left empty, the default
category id for the cluster will be used. |


[Back to top](#top)



