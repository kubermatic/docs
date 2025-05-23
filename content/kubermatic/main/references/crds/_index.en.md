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
- [ApplicationDefinitionSpec](#applicationdefinitionspec)
- [ApplicationInstallationSpec](#applicationinstallationspec)

| Field | Description |
| --- | --- |
| `name` _string_ | {{< unsafe >}}Name is the namespace to deploy the Application into.<br />Should be a valid lowercase RFC1123 domain name{{< /unsafe >}} |
| `create` _boolean_ | {{< unsafe >}}Create defines whether the namespace should be created if it does not exist. Defaults to true{{< /unsafe >}} |
| `labels` _object (keys:string, values:string)_ | {{< unsafe >}}Labels of the namespace<br />More info: http://kubernetes.io/docs/user-guide/labels{{< /unsafe >}} |
| `annotations` _object (keys:string, values:string)_ | {{< unsafe >}}Annotations of the namespace<br />More info: http://kubernetes.io/docs/user-guide/annotations{{< /unsafe >}} |


[Back to top](#top)



### ApplicationDefinition



ApplicationDefinition is the Schema for the applicationdefinitions API.

_Appears in:_
- [ApplicationDefinitionList](#applicationdefinitionlist)

| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `apps.kubermatic.k8c.io/v1`
| `kind` _string_ | `ApplicationDefinition`
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[ApplicationDefinitionSpec](#applicationdefinitionspec)_ | {{< unsafe >}}{{< /unsafe >}} |


[Back to top](#top)



### ApplicationDefinitionList



ApplicationDefinitionList contains a list of ApplicationDefinition.



| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `apps.kubermatic.k8c.io/v1`
| `kind` _string_ | `ApplicationDefinitionList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[ApplicationDefinition](#applicationdefinition) array_ | {{< unsafe >}}{{< /unsafe >}} |


[Back to top](#top)



### ApplicationDefinitionSpec



ApplicationDefinitionSpec defines the desired state of ApplicationDefinition.

_Appears in:_
- [ApplicationDefinition](#applicationdefinition)

| Field | Description |
| --- | --- |
| `displayName` _string_ | {{< unsafe >}}DisplayName is the name for the application that will be displayed in the UI.{{< /unsafe >}} |
| `description` _string_ | {{< unsafe >}}Description of the application. what is its purpose{{< /unsafe >}} |
| `method` _[TemplateMethod](#templatemethod)_ | {{< unsafe >}}Method used to install the application{{< /unsafe >}} |
| `defaultValues` _[RawExtension](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#rawextension-runtime-pkg)_ | {{< unsafe >}}DefaultValues specify default values for the UI which are passed to helm templating when creating an application. Comments are not preserved.<br />Deprecated: Use DefaultValuesBlock instead. This field was deprecated in KKP 2.25 and will be removed in KKP 2.27+.{{< /unsafe >}} |
| `defaultValuesBlock` _string_ | {{< unsafe >}}DefaultValuesBlock specifies default values for the UI which are passed to helm templating when creating an application. Comments are preserved.{{< /unsafe >}} |
| `defaultNamespace` _[AppNamespaceSpec](#appnamespacespec)_ | {{< unsafe >}}DefaultNamespace specifies the default namespace which is used if a referencing ApplicationInstallation has no target namespace defined.<br />If unset, the name of the ApplicationDefinition is being used instead.{{< /unsafe >}} |
| `defaultDeployOptions` _[DeployOptions](#deployoptions)_ | {{< unsafe >}}DefaultDeployOptions holds the settings specific to the templating method used to deploy the application.<br />These settings can be overridden in applicationInstallation.{{< /unsafe >}} |
| `defaultVersion` _string_ | {{< unsafe >}}DefaultVersion of the application to use, if not specified the latest available version will be used.{{< /unsafe >}} |
| `enforced` _boolean_ | {{< unsafe >}}Enforced specifies if the application is enforced to be installed on the user clusters. Enforced applications are<br />installed/updated by KKP for the user clusters. Users are not allowed to update/delete them. KKP will revert the changes<br />done by the application to the desired state specified in the ApplicationDefinition.{{< /unsafe >}} |
| `default` _boolean_ | {{< unsafe >}}Default specifies if the application should be installed by default when a new user cluster is created. Default applications are<br />not enforced and users can update/delete them. KKP will only install them during cluster creation if the user didn't explicitly<br />opt out from installing default applications.{{< /unsafe >}} |
| `selector` _[DefaultingSelector](#defaultingselector)_ | {{< unsafe >}}Selector is used to select the targeted user clusters for defaulting and enforcing applications. This is only used for default/enforced applications and ignored otherwise.{{< /unsafe >}} |
| `documentationURL` _string_ | {{< unsafe >}}DocumentationURL holds a link to official documentation of the Application<br />Alternatively this can be a link to the Readme of a chart in a git repository{{< /unsafe >}} |
| `sourceURL` _string_ | {{< unsafe >}}SourceURL holds a link to the official source code mirror or git repository of the application{{< /unsafe >}} |
| `logo` _string_ | {{< unsafe >}}Logo of the Application as a base64 encoded svg{{< /unsafe >}} |
| `logoFormat` _string_ | {{< unsafe >}}LogoFormat contains logo format of the configured Application. Options are "svg+xml" and "png"{{< /unsafe >}} |
| `versions` _[ApplicationVersion](#applicationversion) array_ | {{< unsafe >}}Available version for this application{{< /unsafe >}} |


[Back to top](#top)



### ApplicationInstallation



ApplicationInstallation describes a single installation of an Application.

_Appears in:_
- [ApplicationInstallationList](#applicationinstallationlist)

| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `apps.kubermatic.k8c.io/v1`
| `kind` _string_ | `ApplicationInstallation`
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[ApplicationInstallationSpec](#applicationinstallationspec)_ | {{< unsafe >}}{{< /unsafe >}} |
| `status` _[ApplicationInstallationStatus](#applicationinstallationstatus)_ | {{< unsafe >}}{{< /unsafe >}} |


[Back to top](#top)



### ApplicationInstallationCondition





_Appears in:_
- [ApplicationInstallationStatus](#applicationinstallationstatus)

| Field | Description |
| --- | --- |
| `status` _[ConditionStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#conditionstatus-v1-core)_ | {{< unsafe >}}Status of the condition, one of True, False, Unknown.{{< /unsafe >}} |
| `lastHeartbeatTime` _[Time](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#time-v1-meta)_ | {{< unsafe >}}Last time we got an update on a given condition.{{< /unsafe >}} |
| `lastTransitionTime` _[Time](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#time-v1-meta)_ | {{< unsafe >}}Last time the condition transit from one status to another.{{< /unsafe >}} |
| `reason` _string_ | {{< unsafe >}}(brief) reason for the condition's last transition.{{< /unsafe >}} |
| `message` _string_ | {{< unsafe >}}Human readable message indicating details about last transition.{{< /unsafe >}} |
| `observedGeneration` _integer_ | {{< unsafe >}}observedGeneration represents the .metadata.generation that the condition was set based upon.<br />For instance, if .metadata.generation is currently 12, but the .status.conditions[x].observedGeneration is 9, the condition is out of date<br />with respect to the current state of the instance.{{< /unsafe >}} |


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
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[ApplicationInstallation](#applicationinstallation) array_ | {{< unsafe >}}{{< /unsafe >}} |


[Back to top](#top)



### ApplicationInstallationSpec





_Appears in:_
- [ApplicationInstallation](#applicationinstallation)

| Field | Description |
| --- | --- |
| `namespace` _[AppNamespaceSpec](#appnamespacespec)_ | {{< unsafe >}}Namespace describe the desired state of the namespace where application will be created.{{< /unsafe >}} |
| `applicationRef` _[ApplicationRef](#applicationref)_ | {{< unsafe >}}ApplicationRef is a reference to identify which Application should be deployed{{< /unsafe >}} |
| `values` _[RawExtension](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#rawextension-runtime-pkg)_ | {{< unsafe >}}Values specify values overrides that are passed to helm templating. Comments are not preserved.<br />Deprecated: Use ValuesBlock instead. This field was deprecated in KKP 2.25 and will be removed in KKP 2.27+.{{< /unsafe >}} |
| `valuesBlock` _string_ | {{< unsafe >}}ValuesBlock specifies values overrides that are passed to helm templating. Comments are preserved.{{< /unsafe >}} |
| `reconciliationInterval` _[Duration](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#duration-v1-meta)_ | {{< unsafe >}}ReconciliationInterval is the interval at which to force the reconciliation of the application. By default, Applications are only reconciled<br />on changes on spec, annotations, or the parent application definition. Meaning that if the user manually deletes the workload<br />deployed by the application, nothing will happen until the application CR change.<br /><br />Setting a value greater than zero force reconciliation even if no changes occurred on application CR.<br />Setting a value equal to 0 disables the force reconciliation of the application (default behavior).<br />Setting this too low can cause a heavy load and may disrupt your application workload depending on the template method.{{< /unsafe >}} |
| `deployOptions` _[DeployOptions](#deployoptions)_ | {{< unsafe >}}DeployOptions holds the settings specific to the templating method used to deploy the application.{{< /unsafe >}} |


[Back to top](#top)



### ApplicationInstallationStatus



ApplicationInstallationStatus denotes status information about an ApplicationInstallation.

_Appears in:_
- [ApplicationInstallation](#applicationinstallation)

| Field | Description |
| --- | --- |
| `conditions` _object (keys:[ApplicationInstallationConditionType](#applicationinstallationconditiontype), values:[ApplicationInstallationCondition](#applicationinstallationcondition))_ | {{< unsafe >}}Conditions contains conditions an installation is in, its primary use case is status signaling between controllers or between controllers and the API{{< /unsafe >}} |
| `applicationVersion` _[ApplicationVersion](#applicationversion)_ | {{< unsafe >}}ApplicationVersion contains information installing / removing application{{< /unsafe >}} |
| `method` _[TemplateMethod](#templatemethod)_ | {{< unsafe >}}Method used to install the application{{< /unsafe >}} |
| `helmRelease` _[HelmRelease](#helmrelease)_ | {{< unsafe >}}HelmRelease holds the information about the helm release installed by this application. This field is only filled if template method is 'helm'.{{< /unsafe >}} |
| `failures` _integer_ | {{< unsafe >}}Failures counts the number of failed installation or updagrade. it is reset on successful reconciliation.{{< /unsafe >}} |


[Back to top](#top)



### ApplicationRef



ApplicationRef describes a KKP-wide, unique reference to an Application.

_Appears in:_
- [ApplicationInstallationSpec](#applicationinstallationspec)

| Field | Description |
| --- | --- |
| `name` _string_ | {{< unsafe >}}Name of the Application.<br />Should be a valid lowercase RFC1123 domain name{{< /unsafe >}} |
| `version` _string_ | {{< unsafe >}}Version of the Application. Must be a valid SemVer version{{< /unsafe >}} |


[Back to top](#top)



### ApplicationSource





_Appears in:_
- [ApplicationTemplate](#applicationtemplate)

| Field | Description |
| --- | --- |
| `helm` _[HelmSource](#helmsource)_ | {{< unsafe >}}Install Application from a Helm repository{{< /unsafe >}} |
| `git` _[GitSource](#gitsource)_ | {{< unsafe >}}Install application from a Git repository{{< /unsafe >}} |


[Back to top](#top)



### ApplicationTemplate





_Appears in:_
- [ApplicationVersion](#applicationversion)

| Field | Description |
| --- | --- |
| `source` _[ApplicationSource](#applicationsource)_ | {{< unsafe >}}Defined how the source of the application (e.g Helm chart) is retrieved.<br />Exactly one type of source must be defined.{{< /unsafe >}} |
| `templateCredentials` _[DependencyCredentials](#dependencycredentials)_ | {{< unsafe >}}DependencyCredentials holds the credentials that may be needed for templating the application.{{< /unsafe >}} |


[Back to top](#top)



### ApplicationVersion





_Appears in:_
- [ApplicationDefinitionSpec](#applicationdefinitionspec)
- [ApplicationInstallationStatus](#applicationinstallationstatus)

| Field | Description |
| --- | --- |
| `version` _string_ | {{< unsafe >}}Version of the application (e.g. v1.2.3){{< /unsafe >}} |
| `template` _[ApplicationTemplate](#applicationtemplate)_ | {{< unsafe >}}Template defines how application is installed (source provenance, Method...){{< /unsafe >}} |


[Back to top](#top)



### DefaultingSelector



DefaultingSelector is used to select the targeted user clusters for defaulting and enforcing applications.

_Appears in:_
- [ApplicationDefinitionSpec](#applicationdefinitionspec)

| Field | Description |
| --- | --- |
| `datacenters` _string array_ | {{< unsafe >}}Datacenters is a list of datacenters where the application can be installed.{{< /unsafe >}} |


[Back to top](#top)



### DependencyCredentials





_Appears in:_
- [ApplicationTemplate](#applicationtemplate)

| Field | Description |
| --- | --- |
| `helmCredentials` _[HelmCredentials](#helmcredentials)_ | {{< unsafe >}}HelmCredentials holds the ref to the secret with helm credentials needed to build helm dependencies.<br />It is not required when using helm as a source, as dependencies are already prepackaged in this case.<br />It's either username / password or a registryConfigFile can be defined.{{< /unsafe >}} |


[Back to top](#top)



### DeployOptions



DeployOptions holds the settings specific to the templating method used to deploy the application.

_Appears in:_
- [ApplicationDefinitionSpec](#applicationdefinitionspec)
- [ApplicationInstallationSpec](#applicationinstallationspec)

| Field | Description |
| --- | --- |
| `helm` _[HelmDeployOptions](#helmdeployoptions)_ | {{< unsafe >}}{{< /unsafe >}} |


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
| `method` _[GitAuthMethod](#gitauthmethod)_ | {{< unsafe >}}Authentication method. Either password or token or ssh-key.<br />If method is password then username and password must be defined.<br />If method is token then token must be defined.<br />If method is ssh-key then ssh-key must be defined.{{< /unsafe >}} |
| `username` _[SecretKeySelector](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#secretkeyselector-v1-core)_ | {{< unsafe >}}Username holds the ref and key in the secret for the username credential.<br />The Secret must exist in the namespace where KKP is installed (default is "kubermatic").<br />The Secret must be annotated with `apps.kubermatic.k8c.io/secret-type:` set to "helm" or "git".{{< /unsafe >}} |
| `password` _[SecretKeySelector](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#secretkeyselector-v1-core)_ | {{< unsafe >}}Password holds the ref and key in the secret for the Password credential.<br />The Secret must exist in the namespace where KKP is installed (default is "kubermatic").<br />The Secret must be annotated with `apps.kubermatic.k8c.io/secret-type:` set to "helm" or "git".{{< /unsafe >}} |
| `token` _[SecretKeySelector](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#secretkeyselector-v1-core)_ | {{< unsafe >}}Token holds the ref and key in the secret for the token credential.<br />The Secret must exist in the namespace where KKP is installed (default is "kubermatic").<br />The Secret must be annotated with `apps.kubermatic.k8c.io/secret-type:` set to "helm" or "git".{{< /unsafe >}} |
| `sshKey` _[SecretKeySelector](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#secretkeyselector-v1-core)_ | {{< unsafe >}}SSHKey holds the ref and key in the secret for the SshKey credential.<br />The Secret must exist in the namespace where KKP is installed (default is "kubermatic").<br />The Secret must be annotated with `apps.kubermatic.k8c.io/secret-type:` set to "helm" or "git".{{< /unsafe >}} |


[Back to top](#top)



### GitReference





_Appears in:_
- [GitSource](#gitsource)

| Field | Description |
| --- | --- |
| `branch` _string_ | {{< unsafe >}}Branch to checkout. Only the last commit of the branch will be checkout in order to reduce the amount of data to download.{{< /unsafe >}} |
| `commit` _string_ | {{< unsafe >}}Commit SHA in a Branch to checkout.<br /><br />It must be used in conjunction with branch field.{{< /unsafe >}} |
| `tag` _string_ | {{< unsafe >}}Tag to check out.<br />It can not be used in conjunction with commit or branch.{{< /unsafe >}} |


[Back to top](#top)



### GitSource





_Appears in:_
- [ApplicationSource](#applicationsource)

| Field | Description |
| --- | --- |
| `remote` _string_ | {{< unsafe >}}URL to the repository. Can be HTTP(s) (e.g. https://example.com/myrepo) or<br />SSH (e.g. git://example.com[:port]/path/to/repo.git/).{{< /unsafe >}} |
| `ref` _[GitReference](#gitreference)_ | {{< unsafe >}}Git reference to checkout.<br />For large repositories, we recommend to either use Tag, Branch or Branch+Commit.<br />This allows a shallow clone, which dramatically speeds up performance{{< /unsafe >}} |
| `path` _string_ | {{< unsafe >}}Path of the "source" in the repository. default is repository root{{< /unsafe >}} |
| `credentials` _[GitCredentials](#gitcredentials)_ | {{< unsafe >}}Credentials are optional and holds the git credentials{{< /unsafe >}} |


[Back to top](#top)



### HelmCredentials





_Appears in:_
- [DependencyCredentials](#dependencycredentials)
- [HelmSource](#helmsource)

| Field | Description |
| --- | --- |
| `username` _[SecretKeySelector](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#secretkeyselector-v1-core)_ | {{< unsafe >}}Username holds the ref and key in the secret for the username credential.<br />The Secret must exist in the namespace where KKP is installed (default is "kubermatic").<br />The Secret must be annotated with `apps.kubermatic.k8c.io/secret-type:` set to "helm" or "git"{{< /unsafe >}} |
| `password` _[SecretKeySelector](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#secretkeyselector-v1-core)_ | {{< unsafe >}}Password holds the ref and key in the secret for the password credential.<br />The Secret must exist in the namespace where KKP is installed (default is "kubermatic").<br />The Secret must be annotated with `apps.kubermatic.k8c.io/secret-type:` set to "helm" or "git"{{< /unsafe >}} |
| `registryConfigFile` _[SecretKeySelector](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#secretkeyselector-v1-core)_ | {{< unsafe >}}RegistryConfigFile holds the ref and key in the secret for the registry credential file.<br />The value is dockercfg file that follows the same format rules as ~/.docker/config.json.<br />The Secret must exist in the namespace where KKP is installed (default is "kubermatic").<br />The Secret must be annotated with `apps.kubermatic.k8c.io/secret-type:` set to "helm" or "git"{{< /unsafe >}} |


[Back to top](#top)



### HelmDeployOptions



HelmDeployOptions holds the deployment settings when templating method is Helm.

_Appears in:_
- [DeployOptions](#deployoptions)

| Field | Description |
| --- | --- |
| `wait` _boolean_ | {{< unsafe >}}Wait corresponds to the --wait flag on Helm cli.<br />if set, will wait until all Pods, PVCs, Services, and minimum number of Pods of a Deployment, StatefulSet, or ReplicaSet are in a ready state before marking the release as successful. It will wait for as long as timeout{{< /unsafe >}} |
| `timeout` _[Duration](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#duration-v1-meta)_ | {{< unsafe >}}Timeout corresponds to the --timeout flag on Helm cli.<br />time to wait for any individual Kubernetes operation.{{< /unsafe >}} |
| `atomic` _boolean_ | {{< unsafe >}}Atomic corresponds to the --atomic flag on Helm cli.<br />if set, the installation process deletes the installation on failure; the upgrade process rolls back changes made in case of failed upgrade.{{< /unsafe >}} |
| `enableDNS` _boolean_ | {{< unsafe >}}EnableDNS  corresponds to the --enable-dns flag on Helm cli.<br />enable DNS lookups when rendering templates.<br />if you enable this flag, you have to verify that helm template function 'getHostByName' is not being used in a chart to disclose any information you do not want to be passed to DNS servers.(c.f. CVE-2023-25165){{< /unsafe >}} |


[Back to top](#top)



### HelmRelease





_Appears in:_
- [ApplicationInstallationStatus](#applicationinstallationstatus)

| Field | Description |
| --- | --- |
| `name` _string_ | {{< unsafe >}}Name is the name of the release.{{< /unsafe >}} |
| `version` _integer_ | {{< unsafe >}}Version is an int which represents the revision of the release.{{< /unsafe >}} |
| `info` _[HelmReleaseInfo](#helmreleaseinfo)_ | {{< unsafe >}}Info provides information about a release.{{< /unsafe >}} |


[Back to top](#top)



### HelmReleaseInfo



HelmReleaseInfo describes release information.
tech note: we can not use release.Info from Helm because the underlying type used for time has no json tag.

_Appears in:_
- [HelmRelease](#helmrelease)

| Field | Description |
| --- | --- |
| `firstDeployed` _[Time](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#time-v1-meta)_ | {{< unsafe >}}FirstDeployed is when the release was first deployed.{{< /unsafe >}} |
| `lastDeployed` _[Time](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#time-v1-meta)_ | {{< unsafe >}}LastDeployed is when the release was last deployed.{{< /unsafe >}} |
| `deleted` _[Time](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#time-v1-meta)_ | {{< unsafe >}}Deleted tracks when this object was deleted.{{< /unsafe >}} |
| `description` _string_ | {{< unsafe >}}Description is human-friendly "log entry" about this release.{{< /unsafe >}} |
| `status` _[HelmReleaseStatus](#helmreleasestatus)_ | {{< unsafe >}}Status is the current state of the release.{{< /unsafe >}} |
| `notes` _string_ | {{< unsafe >}}Notes is  the rendered templates/NOTES.txt if available.{{< /unsafe >}} |


[Back to top](#top)



### HelmReleaseStatus

_Underlying type:_ `string`

HelmReleaseStatus is the status of a Helm release. This type mirrors
helm/pkg/release/v1.Status, but was copied here to avoid a very costly dependency.
Since this field is only used in the status of an App, no user should ever
have to set it manually.

_Appears in:_
- [HelmReleaseInfo](#helmreleaseinfo)



### HelmSource





_Appears in:_
- [ApplicationSource](#applicationsource)

| Field | Description |
| --- | --- |
| `url` _string_ | {{< unsafe >}}URL of the Helm repository the following schemes are supported:<br /><br />* http://example.com/myrepo (HTTP)<br />* https://example.com/myrepo (HTTPS)<br />* oci://example.com:5000/myrepo (OCI, HTTPS by default, use plainHTTP to enable unencrypted HTTP){{< /unsafe >}} |
| `insecure` _boolean_ | {{< unsafe >}}Insecure disables certificate validation when using an HTTPS registry. This setting has no<br />effect when using a plaintext connection.{{< /unsafe >}} |
| `plainHTTP` _boolean_ | {{< unsafe >}}PlainHTTP will enable HTTP-only (i.e. unencrypted) traffic for oci:// URLs. By default HTTPS<br />is used when communicating with an oci:// URL.{{< /unsafe >}} |
| `chartName` _string_ | {{< unsafe >}}Name of the Chart.{{< /unsafe >}} |
| `chartVersion` _string_ | {{< unsafe >}}Version of the Chart.{{< /unsafe >}} |
| `credentials` _[HelmCredentials](#helmcredentials)_ | {{< unsafe >}}Credentials are optional and hold the ref to the secret with Helm credentials.<br />Either username / password or registryConfigFile can be defined.{{< /unsafe >}} |


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
- [PolicyBinding](#policybinding)
- [PolicyBindingList](#policybindinglist)
- [PolicyTemplate](#policytemplate)
- [PolicyTemplateList](#policytemplatelist)
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
| `enabled` _boolean_ | {{< unsafe >}}Only enabled presets will be available in the KKP dashboard.{{< /unsafe >}} |
| `isCustomizable` _boolean_ | {{< unsafe >}}IsCustomizable marks a preset as editable on the KKP UI; Customizable presets still have the credentials obscured on the UI, but other fields that are not considered private are displayed during cluster creation. Users can then update those fields, if required.<br />NOTE: This is only supported for OpenStack Cloud Provider in KKP 2.26. Support for other providers will be added later on.{{< /unsafe >}} |
| `datacenter` _string_ | {{< unsafe >}}If datacenter is set, this preset is only applicable to the<br />configured datacenter.{{< /unsafe >}} |
| `tenantID` _string_ | {{< unsafe >}}The Azure Active Directory Tenant used for the user cluster.{{< /unsafe >}} |
| `subscriptionID` _string_ | {{< unsafe >}}The Azure Subscription used for the user cluster.{{< /unsafe >}} |
| `clientID` _string_ | {{< unsafe >}}The service principal used to access Azure.{{< /unsafe >}} |
| `clientSecret` _string_ | {{< unsafe >}}The client secret corresponding to the given service principal.{{< /unsafe >}} |


[Back to top](#top)



### APIServerSettings





_Appears in:_
- [ComponentSettings](#componentsettings)

| Field | Description |
| --- | --- |
| `replicas` _integer_ | {{< unsafe >}}{{< /unsafe >}} |
| `resources` _[ResourceRequirements](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#resourcerequirements-v1-core)_ | {{< unsafe >}}{{< /unsafe >}} |
| `tolerations` _[Toleration](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#toleration-v1-core) array_ | {{< unsafe >}}{{< /unsafe >}} |
| `endpointReconcilingDisabled` _boolean_ | {{< unsafe >}}{{< /unsafe >}} |
| `nodePortRange` _string_ | {{< unsafe >}}{{< /unsafe >}} |


[Back to top](#top)



### AWS





_Appears in:_
- [PresetSpec](#presetspec)

| Field | Description |
| --- | --- |
| `enabled` _boolean_ | {{< unsafe >}}Only enabled presets will be available in the KKP dashboard.{{< /unsafe >}} |
| `isCustomizable` _boolean_ | {{< unsafe >}}IsCustomizable marks a preset as editable on the KKP UI; Customizable presets still have the credentials obscured on the UI, but other fields that are not considered private are displayed during cluster creation. Users can then update those fields, if required.<br />NOTE: This is only supported for OpenStack Cloud Provider in KKP 2.26. Support for other providers will be added later on.{{< /unsafe >}} |
| `datacenter` _string_ | {{< unsafe >}}If datacenter is set, this preset is only applicable to the<br />configured datacenter.{{< /unsafe >}} |
| `accessKeyID` _string_ | {{< unsafe >}}The Access key ID used to authenticate against AWS.{{< /unsafe >}} |
| `secretAccessKey` _string_ | {{< unsafe >}}The Secret Access Key used to authenticate against AWS.{{< /unsafe >}} |
| `assumeRoleARN` _string_ | {{< unsafe >}}Defines the ARN for an IAM role that should be assumed when handling resources on AWS. It will be used<br />to acquire temporary security credentials using an STS AssumeRole API operation whenever creating an AWS session.{{< /unsafe >}} |
| `assumeRoleExternalID` _string_ | {{< unsafe >}}An arbitrary string that may be needed when calling the STS AssumeRole API operation.<br />Using an external ID can help to prevent the "confused deputy problem".{{< /unsafe >}} |
| `vpcID` _string_ | {{< unsafe >}}AWS VPC to use. Must be configured.{{< /unsafe >}} |
| `routeTableID` _string_ | {{< unsafe >}}Route table to use. This can be configured, but if left empty will be<br />automatically filled in during reconciliation.{{< /unsafe >}} |
| `instanceProfileName` _string_ | {{< unsafe >}}Instance profile to use. This can be configured, but if left empty will be<br />automatically filled in during reconciliation.{{< /unsafe >}} |
| `securityGroupID` _string_ | {{< unsafe >}}Security group to use. This can be configured, but if left empty will be<br />automatically filled in during reconciliation.{{< /unsafe >}} |
| `roleARN` _string_ | {{< unsafe >}}ARN to use. This can be configured, but if left empty will be<br />automatically filled in during reconciliation.{{< /unsafe >}} |


[Back to top](#top)



### AWSCloudSpec



AWSCloudSpec specifies access data to Amazon Web Services.

_Appears in:_
- [CloudSpec](#cloudspec)

| Field | Description |
| --- | --- |
| `credentialsReference` _[GlobalSecretKeySelector](#globalsecretkeyselector)_ | {{< unsafe >}}{{< /unsafe >}} |
| `accessKeyID` _string_ | {{< unsafe >}}The Access key ID used to authenticate against AWS.{{< /unsafe >}} |
| `secretAccessKey` _string_ | {{< unsafe >}}The Secret Access Key used to authenticate against AWS.{{< /unsafe >}} |
| `assumeRoleARN` _string_ | {{< unsafe >}}Defines the ARN for an IAM role that should be assumed when handling resources on AWS. It will be used<br />to acquire temporary security credentials using an STS AssumeRole API operation whenever creating an AWS session.{{< /unsafe >}} |
| `assumeRoleExternalID` _string_ | {{< unsafe >}}An arbitrary string that may be needed when calling the STS AssumeRole API operation.<br />Using an external ID can help to prevent the "confused deputy problem".{{< /unsafe >}} |
| `vpcID` _string_ | {{< unsafe >}}{{< /unsafe >}} |
| `roleARN` _string_ | {{< unsafe >}}The IAM role, the control plane will use. The control plane will perform an assume-role{{< /unsafe >}} |
| `routeTableID` _string_ | {{< unsafe >}}{{< /unsafe >}} |
| `instanceProfileName` _string_ | {{< unsafe >}}{{< /unsafe >}} |
| `securityGroupID` _string_ | {{< unsafe >}}{{< /unsafe >}} |
| `nodePortsAllowedIPRange` _string_ | {{< unsafe >}}A CIDR range that will be used to allow access to the node port range in the security group to. Only applies if<br />the security group is generated by KKP and not preexisting.<br />If NodePortsAllowedIPRange nor NodePortsAllowedIPRanges is set, the node port range can be accessed from anywhere.{{< /unsafe >}} |
| `nodePortsAllowedIPRanges` _[NetworkRanges](#networkranges)_ | {{< unsafe >}}Optional: CIDR ranges that will be used to allow access to the node port range in the security group to. Only applies if<br />the security group is generated by KKP and not preexisting.<br />If NodePortsAllowedIPRange nor NodePortsAllowedIPRanges is set,  the node port range can be accessed from anywhere.{{< /unsafe >}} |
| `disableIAMReconciling` _boolean_ | {{< unsafe >}}DisableIAMReconciling is used to disable reconciliation for IAM related configuration. This is useful in air-gapped<br />setups where access to IAM service is not possible.{{< /unsafe >}} |


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
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[AddonSpec](#addonspec)_ | {{< unsafe >}}Spec describes the desired addon state.{{< /unsafe >}} |
| `status` _[AddonStatus](#addonstatus)_ | {{< unsafe >}}Status contains information about the reconciliation status.{{< /unsafe >}} |


[Back to top](#top)



### AddonCondition





_Appears in:_
- [AddonStatus](#addonstatus)

| Field | Description |
| --- | --- |
| `status` _[ConditionStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#conditionstatus-v1-core)_ | {{< unsafe >}}Status of the condition, one of True, False, Unknown.{{< /unsafe >}} |
| `lastHeartbeatTime` _[Time](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#time-v1-meta)_ | {{< unsafe >}}Last time we got an update on a given condition.{{< /unsafe >}} |
| `lastTransitionTime` _[Time](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#time-v1-meta)_ | {{< unsafe >}}Last time the condition transitioned from one status to another.{{< /unsafe >}} |
| `kubermaticVersion` _string_ | {{< unsafe >}}KubermaticVersion is the version of KKP that last _successfully_ reconciled this<br />addon.{{< /unsafe >}} |


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
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[AddonConfigSpec](#addonconfigspec)_ | {{< unsafe >}}Spec describes the configuration of an addon.{{< /unsafe >}} |


[Back to top](#top)



### AddonConfigList



AddonConfigList is a list of addon configs.



| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `AddonConfigList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[AddonConfig](#addonconfig) array_ | {{< unsafe >}}Items refers to the list of AddonConfig objects.{{< /unsafe >}} |


[Back to top](#top)



### AddonConfigSpec



AddonConfigSpec specifies configuration of addon.

_Appears in:_
- [AddonConfig](#addonconfig)

| Field | Description |
| --- | --- |
| `shortDescription` _string_ | {{< unsafe >}}ShortDescription of the configured addon that contains more detailed information about the addon,<br />it will be displayed in the addon details view in the UI{{< /unsafe >}} |
| `description` _string_ | {{< unsafe >}}Description of the configured addon, it will be displayed in the addon overview in the UI{{< /unsafe >}} |
| `logo` _string_ | {{< unsafe >}}Logo of the configured addon, encoded in base64{{< /unsafe >}} |
| `logoFormat` _string_ | {{< unsafe >}}LogoFormat contains logo format of the configured addon, i.e. svg+xml{{< /unsafe >}} |
| `formSpec` _[AddonFormControl](#addonformcontrol) array_ | {{< unsafe >}}Controls that can be set for configured addon{{< /unsafe >}} |


[Back to top](#top)



### AddonFormControl



AddonFormControl specifies addon form control.

_Appears in:_
- [AddonConfigSpec](#addonconfigspec)

| Field | Description |
| --- | --- |
| `displayName` _string_ | {{< unsafe >}}DisplayName is visible in the UI{{< /unsafe >}} |
| `internalName` _string_ | {{< unsafe >}}InternalName is used internally to save in the addon object{{< /unsafe >}} |
| `helpText` _string_ | {{< unsafe >}}HelpText is visible in the UI next to the control{{< /unsafe >}} |
| `required` _boolean_ | {{< unsafe >}}Required indicates if the control has to be set{{< /unsafe >}} |
| `type` _string_ | {{< unsafe >}}Type of displayed control{{< /unsafe >}} |


[Back to top](#top)



### AddonList



AddonList is a list of addons.



| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `AddonList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[Addon](#addon) array_ | {{< unsafe >}}Items refers to the list of the cluster addons.{{< /unsafe >}} |


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
| `name` _string_ | {{< unsafe >}}Name defines the name of the addon to install{{< /unsafe >}} |
| `cluster` _[ObjectReference](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#objectreference-v1-core)_ | {{< unsafe >}}Cluster is the reference to the cluster the addon should be installed in{{< /unsafe >}} |
| `variables` _[RawExtension](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#rawextension-runtime-pkg)_ | {{< unsafe >}}Variables is free form data to use for parsing the manifest templates{{< /unsafe >}} |
| `requiredResourceTypes` _[GroupVersionKind](#groupversionkind) array_ | {{< unsafe >}}RequiredResourceTypes allows to indicate that this addon needs some resource type before it<br />can be installed. This can be used to indicate that a specific CRD and/or extension<br />apiserver must be installed before this addon can be installed. The addon will not<br />be installed until that resource is served.{{< /unsafe >}} |
| `isDefault` _boolean_ | {{< unsafe >}}IsDefault indicates whether the addon is installed because it was configured in<br />the default addon section in the KubermaticConfiguration. User-installed addons<br />must not set this field to true, as extra default Addon objects (that are not in<br />the KubermaticConfiguration) will be garbage-collected.{{< /unsafe >}} |


[Back to top](#top)



### AddonStatus



AddonStatus contains information about the reconciliation status.

_Appears in:_
- [Addon](#addon)

| Field | Description |
| --- | --- |
| `phase` _[AddonPhase](#addonphase)_ | {{< unsafe >}}Phase is a description of the current addon status, summarizing the various conditions.<br />This field is for informational purpose only and no logic should be tied to the phase.{{< /unsafe >}} |
| `conditions` _object (keys:[AddonConditionType](#addonconditiontype), values:[AddonCondition](#addoncondition))_ | {{< unsafe >}}{{< /unsafe >}} |


[Back to top](#top)



### AdmissionPlugin



AdmissionPlugin is the type representing a AdmissionPlugin.

_Appears in:_
- [AdmissionPluginList](#admissionpluginlist)

| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `AdmissionPlugin`
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[AdmissionPluginSpec](#admissionpluginspec)_ | {{< unsafe >}}Spec describes an admission plugin name and in which k8s version it is supported.{{< /unsafe >}} |


[Back to top](#top)



### AdmissionPluginList



AdmissionPluginList is the type representing a AdmissionPluginList.



| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `AdmissionPluginList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[AdmissionPlugin](#admissionplugin) array_ | {{< unsafe >}}Items refers to the list of Admission Plugins{{< /unsafe >}} |


[Back to top](#top)



### AdmissionPluginSpec



AdmissionPluginSpec specifies admission plugin name and from which k8s version is supported.

_Appears in:_
- [AdmissionPlugin](#admissionplugin)

| Field | Description |
| --- | --- |
| `pluginName` _string_ | {{< unsafe >}}{{< /unsafe >}} |
| `fromVersion` _[Semver](#semver)_ | {{< unsafe >}}FromVersion flag can be empty. It means the plugin fit to all k8s versions{{< /unsafe >}} |


[Back to top](#top)



### Alertmanager





_Appears in:_
- [AlertmanagerList](#alertmanagerlist)

| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `Alertmanager`
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[AlertmanagerSpec](#alertmanagerspec)_ | {{< unsafe >}}Spec describes the configuration of the Alertmanager.{{< /unsafe >}} |
| `status` _[AlertmanagerStatus](#alertmanagerstatus)_ | {{< unsafe >}}Status stores status information about the Alertmanager.{{< /unsafe >}} |


[Back to top](#top)



### AlertmanagerConfigurationStatus



AlertmanagerConfigurationStatus stores status information about the AlertManager configuration.

_Appears in:_
- [AlertmanagerStatus](#alertmanagerstatus)

| Field | Description |
| --- | --- |
| `lastUpdated` _[Time](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#time-v1-meta)_ | {{< unsafe >}}LastUpdated stores the last successful time when the configuration was successfully applied{{< /unsafe >}} |
| `status` _[ConditionStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#conditionstatus-v1-core)_ | {{< unsafe >}}Status of whether the configuration was applied, one of True, False{{< /unsafe >}} |
| `errorMessage` _string_ | {{< unsafe >}}ErrorMessage contains a default error message in case the configuration could not be applied.<br />Will be reset if the error was resolved and condition becomes True{{< /unsafe >}} |


[Back to top](#top)



### AlertmanagerList







| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `AlertmanagerList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[Alertmanager](#alertmanager) array_ | {{< unsafe >}}Items refers to the list of Alertmanager objects.{{< /unsafe >}} |


[Back to top](#top)



### AlertmanagerSpec



AlertmanagerSpec describes the configuration of the Alertmanager.

_Appears in:_
- [Alertmanager](#alertmanager)

| Field | Description |
| --- | --- |
| `configSecret` _[LocalObjectReference](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#localobjectreference-v1-core)_ | {{< unsafe >}}ConfigSecret refers to the Secret in the same namespace as the Alertmanager object,<br />which contains configuration for this Alertmanager.{{< /unsafe >}} |


[Back to top](#top)



### AlertmanagerStatus



AlertmanagerStatus stores status information about the AlertManager.

_Appears in:_
- [Alertmanager](#alertmanager)

| Field | Description |
| --- | --- |
| `configStatus` _[AlertmanagerConfigurationStatus](#alertmanagerconfigurationstatus)_ | {{< unsafe >}}ConfigStatus stores status information about the AlertManager configuration.{{< /unsafe >}} |


[Back to top](#top)



### Alibaba





_Appears in:_
- [PresetSpec](#presetspec)

| Field | Description |
| --- | --- |
| `enabled` _boolean_ | {{< unsafe >}}Only enabled presets will be available in the KKP dashboard.{{< /unsafe >}} |
| `isCustomizable` _boolean_ | {{< unsafe >}}IsCustomizable marks a preset as editable on the KKP UI; Customizable presets still have the credentials obscured on the UI, but other fields that are not considered private are displayed during cluster creation. Users can then update those fields, if required.<br />NOTE: This is only supported for OpenStack Cloud Provider in KKP 2.26. Support for other providers will be added later on.{{< /unsafe >}} |
| `datacenter` _string_ | {{< unsafe >}}If datacenter is set, this preset is only applicable to the<br />configured datacenter.{{< /unsafe >}} |
| `accessKeyID` _string_ | {{< unsafe >}}The Access Key ID used to authenticate against Alibaba.{{< /unsafe >}} |
| `accessKeySecret` _string_ | {{< unsafe >}}The Access Key Secret used to authenticate against Alibaba.{{< /unsafe >}} |


[Back to top](#top)



### AlibabaCloudSpec



AlibabaCloudSpec specifies the access data to Alibaba.

_Appears in:_
- [CloudSpec](#cloudspec)

| Field | Description |
| --- | --- |
| `credentialsReference` _[GlobalSecretKeySelector](#globalsecretkeyselector)_ | {{< unsafe >}}{{< /unsafe >}} |
| `accessKeyID` _string_ | {{< unsafe >}}The Access Key ID used to authenticate against Alibaba.{{< /unsafe >}} |
| `accessKeySecret` _string_ | {{< unsafe >}}The Access Key Secret used to authenticate against Alibaba.{{< /unsafe >}} |


[Back to top](#top)



### AllowedRegistry



AllowedRegistry is the object representing an allowed registry.

_Appears in:_
- [AllowedRegistryList](#allowedregistrylist)

| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `AllowedRegistry`
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[AllowedRegistrySpec](#allowedregistryspec)_ | {{< unsafe >}}Spec describes the desired state for an allowed registry.{{< /unsafe >}} |


[Back to top](#top)



### AllowedRegistryList



AllowedRegistryList specifies a list of allowed registries.



| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `AllowedRegistryList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[AllowedRegistry](#allowedregistry) array_ | {{< unsafe >}}Items refers to the list of the allowed registries.{{< /unsafe >}} |


[Back to top](#top)



### AllowedRegistrySpec



AllowedRegistrySpec specifies the data for allowed registry spec.

_Appears in:_
- [AllowedRegistry](#allowedregistry)

| Field | Description |
| --- | --- |
| `registryPrefix` _string_ | {{< unsafe >}}RegistryPrefix contains the prefix of the registry which will be allowed. User clusters will be able to deploy<br />only images which are prefixed with one of the allowed image registry prefixes.{{< /unsafe >}} |


[Back to top](#top)



### Anexia





_Appears in:_
- [PresetSpec](#presetspec)

| Field | Description |
| --- | --- |
| `enabled` _boolean_ | {{< unsafe >}}Only enabled presets will be available in the KKP dashboard.{{< /unsafe >}} |
| `isCustomizable` _boolean_ | {{< unsafe >}}IsCustomizable marks a preset as editable on the KKP UI; Customizable presets still have the credentials obscured on the UI, but other fields that are not considered private are displayed during cluster creation. Users can then update those fields, if required.<br />NOTE: This is only supported for OpenStack Cloud Provider in KKP 2.26. Support for other providers will be added later on.{{< /unsafe >}} |
| `datacenter` _string_ | {{< unsafe >}}If datacenter is set, this preset is only applicable to the<br />configured datacenter.{{< /unsafe >}} |
| `token` _string_ | {{< unsafe >}}Token is used to authenticate with the Anexia API.{{< /unsafe >}} |


[Back to top](#top)



### AnexiaCloudSpec



AnexiaCloudSpec specifies the access data to Anexia.

_Appears in:_
- [CloudSpec](#cloudspec)

| Field | Description |
| --- | --- |
| `credentialsReference` _[GlobalSecretKeySelector](#globalsecretkeyselector)_ | {{< unsafe >}}{{< /unsafe >}} |
| `token` _string_ | {{< unsafe >}}Token is used to authenticate with the Anexia API.{{< /unsafe >}} |


[Back to top](#top)



### AnnotationSettings



AnnotationSettings is the settings for the annotations.

_Appears in:_
- [SettingSpec](#settingspec)

| Field | Description |
| --- | --- |
| `hiddenAnnotations` _string array_ | {{< unsafe >}}HiddenAnnotations are the annotations that are hidden from the user in the UI.{{< /unsafe >}} |
| `protectedAnnotations` _string array_ | {{< unsafe >}}ProtectedAnnotations are the annotations that are visible in the UI but cannot be added or modified by the user.{{< /unsafe >}} |


[Back to top](#top)



### Announcement



The announcement feature allows administrators to broadcast important messages to all users.

_Appears in:_
- [SettingSpec](#settingspec)

| Field | Description |
| --- | --- |
| `message` _string_ | {{< unsafe >}}The message content of the announcement.{{< /unsafe >}} |
| `isActive` _boolean_ | {{< unsafe >}}Indicates whether the announcement is active.{{< /unsafe >}} |
| `createdAt` _[Time](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#time-v1-meta)_ | {{< unsafe >}}Timestamp when the announcement was created.{{< /unsafe >}} |
| `expires` _[Time](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#time-v1-meta)_ | {{< unsafe >}}Expiration date for the announcement.{{< /unsafe >}} |


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



### ApplicationsConfiguration



ApplicationsConfiguration contains configuration for default Applications configuration settings.

_Appears in:_
- [KubermaticUserClusterConfiguration](#kubermaticuserclusterconfiguration)

| Field | Description |
| --- | --- |
| `namespace` _string_ | {{< unsafe >}}Namespace is the namespace which is set as the default for applications installed via ui<br />If left empty the default for the application installation namespace is the name of the resource itself{{< /unsafe >}} |


[Back to top](#top)



### AuditLoggingSettings



AuditLoggingSettings configures audit logging functionality.

_Appears in:_
- [ClusterSpec](#clusterspec)
- [SeedSpec](#seedspec)

| Field | Description |
| --- | --- |
| `enabled` _boolean_ | {{< unsafe >}}Enabled will enable or disable audit logging.{{< /unsafe >}} |
| `policyPreset` _[AuditPolicyPreset](#auditpolicypreset)_ | {{< unsafe >}}Optional: PolicyPreset can be set to utilize a pre-defined set of audit policy rules.{{< /unsafe >}} |
| `sidecar` _[AuditSidecarSettings](#auditsidecarsettings)_ | {{< unsafe >}}Optional: Configures the fluent-bit sidecar deployed alongside kube-apiserver.{{< /unsafe >}} |
| `webhookBackend` _[AuditWebhookBackendSettings](#auditwebhookbackendsettings)_ | {{< unsafe >}}Optional: Configures the webhook backend for audit logs.{{< /unsafe >}} |


[Back to top](#top)



### AuditPolicyPreset

_Underlying type:_ `string`

AuditPolicyPreset refers to a pre-defined set of audit policy rules. Supported values
are `metadata`, `recommended` and `minimal`. See KKP documentation for what each policy preset includes.

_Appears in:_
- [AuditLoggingSettings](#auditloggingsettings)



### AuditSidecarConfiguration



AuditSidecarConfiguration defines custom configuration for the fluent-bit sidecar deployed with a kube-apiserver.
Also see https://docs.fluentbit.io/manual/administration/configuring-fluent-bit/classic-mode/configuration-file.

_Appears in:_
- [AuditSidecarSettings](#auditsidecarsettings)

| Field | Description |
| --- | --- |
| `service` _object (keys:string, values:string)_ | {{< unsafe >}}{{< /unsafe >}} |
| `filters` _object array_ | {{< unsafe >}}{{< /unsafe >}} |
| `outputs` _object array_ | {{< unsafe >}}{{< /unsafe >}} |


[Back to top](#top)



### AuditSidecarSettings





_Appears in:_
- [AuditLoggingSettings](#auditloggingsettings)

| Field | Description |
| --- | --- |
| `resources` _[ResourceRequirements](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#resourcerequirements-v1-core)_ | {{< unsafe >}}{{< /unsafe >}} |
| `config` _[AuditSidecarConfiguration](#auditsidecarconfiguration)_ | {{< unsafe >}}{{< /unsafe >}} |
| `extraEnvs` _[EnvVar](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#envvar-v1-core) array_ | {{< unsafe >}}ExtraEnvs are the additional environment variables that can be set for the audit logging sidecar.<br />Additional environment variables can be set and passed to the AuditSidecarConfiguration field<br />to allow passing variables to the fluent-bit configuration.<br />Only, `Value` field is supported for the environment variables; `ValueFrom` field is not supported.<br />By default, `CLUSTER_ID` is set as an environment variable in the audit-logging sidecar.{{< /unsafe >}} |


[Back to top](#top)



### AuditWebhookBackendSettings



AuditWebhookBackendSettings configures webhook backend for audit logging functionality.

_Appears in:_
- [AuditLoggingSettings](#auditloggingsettings)
- [DatacenterSpec](#datacenterspec)

| Field | Description |
| --- | --- |
| `auditWebhookConfig` _[SecretReference](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#secretreference-v1-core)_ | {{< unsafe >}}Required : AuditWebhookConfig contains reference to secret holding the audit webhook config file{{< /unsafe >}} |
| `auditWebhookInitialBackoff` _string_ | {{< unsafe >}}{{< /unsafe >}} |


[Back to top](#top)



### Azure





_Appears in:_
- [PresetSpec](#presetspec)

| Field | Description |
| --- | --- |
| `enabled` _boolean_ | {{< unsafe >}}Only enabled presets will be available in the KKP dashboard.{{< /unsafe >}} |
| `isCustomizable` _boolean_ | {{< unsafe >}}IsCustomizable marks a preset as editable on the KKP UI; Customizable presets still have the credentials obscured on the UI, but other fields that are not considered private are displayed during cluster creation. Users can then update those fields, if required.<br />NOTE: This is only supported for OpenStack Cloud Provider in KKP 2.26. Support for other providers will be added later on.{{< /unsafe >}} |
| `datacenter` _string_ | {{< unsafe >}}If datacenter is set, this preset is only applicable to the<br />configured datacenter.{{< /unsafe >}} |
| `tenantID` _string_ | {{< unsafe >}}The Azure Active Directory Tenant used for the user cluster.{{< /unsafe >}} |
| `subscriptionID` _string_ | {{< unsafe >}}The Azure Subscription used for the user cluster.{{< /unsafe >}} |
| `clientID` _string_ | {{< unsafe >}}The service principal used to access Azure.{{< /unsafe >}} |
| `clientSecret` _string_ | {{< unsafe >}}The client secret corresponding to the given service principal.{{< /unsafe >}} |
| `resourceGroup` _string_ | {{< unsafe >}}The resource group that will be used to look up and create resources for the cluster in.<br />If set to empty string at cluster creation, a new resource group will be created and this field will be updated to<br />the generated resource group's name.{{< /unsafe >}} |
| `vnetResourceGroup` _string_ | {{< unsafe >}}Optional: Defines a second resource group that will be used for VNet related resources instead.<br />If left empty, NO additional resource group will be created and all VNet related resources use the resource group defined by `resourceGroup`.{{< /unsafe >}} |
| `vnet` _string_ | {{< unsafe >}}The name of the VNet resource used for setting up networking in.<br />If set to empty string at cluster creation, a new VNet will be created and this field will be updated to<br />the generated VNet's name.{{< /unsafe >}} |
| `subnet` _string_ | {{< unsafe >}}The name of a subnet in the VNet referenced by `vnet`.<br />If set to empty string at cluster creation, a new subnet will be created and this field will be updated to<br />the generated subnet's name. If no VNet is defined at cluster creation, this field should be empty as well.{{< /unsafe >}} |
| `routeTable` _string_ | {{< unsafe >}}The name of a route table associated with the subnet referenced by `subnet`.<br />If set to empty string at cluster creation, a new route table will be created and this field will be updated to<br />the generated route table's name. If no subnet is defined at cluster creation, this field should be empty as well.{{< /unsafe >}} |
| `securityGroup` _string_ | {{< unsafe >}}The name of a security group associated with the subnet referenced by `subnet`.<br />If set to empty string at cluster creation, a new security group will be created and this field will be updated to<br />the generated security group's name. If no subnet is defined at cluster creation, this field should be empty as well.{{< /unsafe >}} |
| `loadBalancerSKU` _[LBSKU](#lbsku)_ | {{< unsafe >}}LoadBalancerSKU sets the LB type that will be used for the Azure cluster, possible values are "basic" and "standard", if empty, "standard" will be used{{< /unsafe >}} |


[Back to top](#top)



### AzureCloudSpec



AzureCloudSpec defines cloud resource references for Microsoft Azure.

_Appears in:_
- [CloudSpec](#cloudspec)

| Field | Description |
| --- | --- |
| `credentialsReference` _[GlobalSecretKeySelector](#globalsecretkeyselector)_ | {{< unsafe >}}CredentialsReference allows referencing a `Secret` resource instead of passing secret data in this spec.{{< /unsafe >}} |
| `tenantID` _string_ | {{< unsafe >}}The Azure Active Directory Tenant used for this cluster.<br />Can be read from `credentialsReference` instead.{{< /unsafe >}} |
| `subscriptionID` _string_ | {{< unsafe >}}The Azure Subscription used for this cluster.<br />Can be read from `credentialsReference` instead.{{< /unsafe >}} |
| `clientID` _string_ | {{< unsafe >}}The service principal used to access Azure.<br />Can be read from `credentialsReference` instead.{{< /unsafe >}} |
| `clientSecret` _string_ | {{< unsafe >}}The client secret corresponding to the given service principal.<br />Can be read from `credentialsReference` instead.{{< /unsafe >}} |
| `resourceGroup` _string_ | {{< unsafe >}}The resource group that will be used to look up and create resources for the cluster in.<br />If set to empty string at cluster creation, a new resource group will be created and this field will be updated to<br />the generated resource group's name.{{< /unsafe >}} |
| `vnetResourceGroup` _string_ | {{< unsafe >}}Optional: Defines a second resource group that will be used for VNet related resources instead.<br />If left empty, NO additional resource group will be created and all VNet related resources use the resource group defined by `resourceGroup`.{{< /unsafe >}} |
| `vnet` _string_ | {{< unsafe >}}The name of the VNet resource used for setting up networking in.<br />If set to empty string at cluster creation, a new VNet will be created and this field will be updated to<br />the generated VNet's name.{{< /unsafe >}} |
| `subnet` _string_ | {{< unsafe >}}The name of a subnet in the VNet referenced by `vnet`.<br />If set to empty string at cluster creation, a new subnet will be created and this field will be updated to<br />the generated subnet's name. If no VNet is defined at cluster creation, this field should be empty as well.{{< /unsafe >}} |
| `routeTable` _string_ | {{< unsafe >}}The name of a route table associated with the subnet referenced by `subnet`.<br />If set to empty string at cluster creation, a new route table will be created and this field will be updated to<br />the generated route table's name. If no subnet is defined at cluster creation, this field should be empty as well.{{< /unsafe >}} |
| `securityGroup` _string_ | {{< unsafe >}}The name of a security group associated with the subnet referenced by `subnet`.<br />If set to empty string at cluster creation, a new security group will be created and this field will be updated to<br />the generated security group's name. If no subnet is defined at cluster creation, this field should be empty as well.{{< /unsafe >}} |
| `nodePortsAllowedIPRange` _string_ | {{< unsafe >}}A CIDR range that will be used to allow access to the node port range in the security group to. Only applies if<br />the security group is generated by KKP and not preexisting.<br />If NodePortsAllowedIPRange nor NodePortsAllowedIPRanges is set, the node port range can be accessed from anywhere.{{< /unsafe >}} |
| `nodePortsAllowedIPRanges` _[NetworkRanges](#networkranges)_ | {{< unsafe >}}Optional: CIDR ranges that will be used to allow access to the node port range in the security group to. Only applies if<br />the security group is generated by KKP and not preexisting.<br />If NodePortsAllowedIPRange nor NodePortsAllowedIPRanges is set,  the node port range can be accessed from anywhere.{{< /unsafe >}} |
| `assignAvailabilitySet` _boolean_ | {{< unsafe >}}Optional: AssignAvailabilitySet determines whether KKP creates and assigns an AvailabilitySet to machines.<br />Defaults to `true` internally if not set.{{< /unsafe >}} |
| `availabilitySet` _string_ | {{< unsafe >}}An availability set that will be associated with nodes created for this cluster. If this field is set to empty string<br />at cluster creation and `AssignAvailabilitySet` is set to `true`, a new availability set will be created and this field<br />will be updated to the generated availability set's name.{{< /unsafe >}} |
| `loadBalancerSKU` _[LBSKU](#lbsku)_ | {{< unsafe >}}LoadBalancerSKU sets the LB type that will be used for the Azure cluster, possible values are "basic" and "standard", if empty, "standard" will be used.{{< /unsafe >}} |


[Back to top](#top)



### BackupConfig





_Appears in:_
- [ClusterSpec](#clusterspec)

| Field | Description |
| --- | --- |
| `backupStorageLocation` _[LocalObjectReference](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#localobjectreference-v1-core)_ | {{< unsafe >}}{{< /unsafe >}} |


[Back to top](#top)



### BackupDestination



BackupDestination defines the bucket name and endpoint as a backup destination, and holds reference to the credentials secret.

_Appears in:_
- [EtcdBackupRestore](#etcdbackuprestore)

| Field | Description |
| --- | --- |
| `endpoint` _string_ | {{< unsafe >}}Endpoint is the API endpoint to use for backup and restore.{{< /unsafe >}} |
| `bucketName` _string_ | {{< unsafe >}}BucketName is the bucket name to use for backup and restore.{{< /unsafe >}} |
| `credentials` _[SecretReference](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#secretreference-v1-core)_ | {{< unsafe >}}Credentials hold the ref to the secret with backup credentials{{< /unsafe >}} |


[Back to top](#top)



### BackupStatus





_Appears in:_
- [EtcdBackupConfigStatus](#etcdbackupconfigstatus)

| Field | Description |
| --- | --- |
| `scheduledTime` _[Time](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#time-v1-meta)_ | {{< unsafe >}}ScheduledTime will always be set when the BackupStatus is created, so it'll never be nil{{< /unsafe >}} |
| `backupName` _string_ | {{< unsafe >}}{{< /unsafe >}} |
| `jobName` _string_ | {{< unsafe >}}{{< /unsafe >}} |
| `backupStartTime` _[Time](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#time-v1-meta)_ | {{< unsafe >}}{{< /unsafe >}} |
| `backupFinishedTime` _[Time](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#time-v1-meta)_ | {{< unsafe >}}{{< /unsafe >}} |
| `backupPhase` _[BackupStatusPhase](#backupstatusphase)_ | {{< unsafe >}}{{< /unsafe >}} |
| `backupMessage` _string_ | {{< unsafe >}}{{< /unsafe >}} |
| `deleteJobName` _string_ | {{< unsafe >}}{{< /unsafe >}} |
| `deleteStartTime` _[Time](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#time-v1-meta)_ | {{< unsafe >}}{{< /unsafe >}} |
| `deleteFinishedTime` _[Time](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#time-v1-meta)_ | {{< unsafe >}}{{< /unsafe >}} |
| `deletePhase` _[BackupStatusPhase](#backupstatusphase)_ | {{< unsafe >}}{{< /unsafe >}} |
| `deleteMessage` _string_ | {{< unsafe >}}{{< /unsafe >}} |


[Back to top](#top)



### BackupStatusPhase

_Underlying type:_ `string`



_Appears in:_
- [BackupStatus](#backupstatus)



### Baremetal





_Appears in:_
- [PresetSpec](#presetspec)

| Field | Description |
| --- | --- |
| `enabled` _boolean_ | {{< unsafe >}}Only enabled presets will be available in the KKP dashboard.{{< /unsafe >}} |
| `isCustomizable` _boolean_ | {{< unsafe >}}IsCustomizable marks a preset as editable on the KKP UI; Customizable presets still have the credentials obscured on the UI, but other fields that are not considered private are displayed during cluster creation. Users can then update those fields, if required.<br />NOTE: This is only supported for OpenStack Cloud Provider in KKP 2.26. Support for other providers will be added later on.{{< /unsafe >}} |
| `datacenter` _string_ | {{< unsafe >}}If datacenter is set, this preset is only applicable to the<br />configured datacenter.{{< /unsafe >}} |
| `tinkerbell` _[Tinkerbell](#tinkerbell)_ | {{< unsafe >}}{{< /unsafe >}} |


[Back to top](#top)



### BaremetalCloudSpec



BaremetalCloudSpec specifies access data for a baremetal cluster.

_Appears in:_
- [CloudSpec](#cloudspec)

| Field | Description |
| --- | --- |
| `credentialsReference` _[GlobalSecretKeySelector](#globalsecretkeyselector)_ | {{< unsafe >}}{{< /unsafe >}} |
| `tinkerbell` _[TinkerbellCloudSpec](#tinkerbellcloudspec)_ | {{< unsafe >}}{{< /unsafe >}} |


[Back to top](#top)



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
| `type` _[CNIPluginType](#cniplugintype)_ | {{< unsafe >}}Type is the CNI plugin type to be used.{{< /unsafe >}} |
| `version` _string_ | {{< unsafe >}}Version defines the CNI plugin version to be used. This varies by chosen CNI plugin type.{{< /unsafe >}} |


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
| `enabled` _boolean_ | {{< unsafe >}}Enable checkboxes that allow the user to ask for LoadBalancers and PVCs<br />to be deleted in order to not leave potentially expensive resources behind.{{< /unsafe >}} |
| `enforced` _boolean_ | {{< unsafe >}}If enforced is set to true, the cleanup of LoadBalancers and PVCs is<br />enforced.{{< /unsafe >}} |


[Back to top](#top)



### CloudSpec



CloudSpec stores configuration options for a given cloud provider. Provider specs are mutually exclusive.

_Appears in:_
- [ClusterSpec](#clusterspec)

| Field | Description |
| --- | --- |
| `dc` _string_ | {{< unsafe >}}DatacenterName states the name of a cloud provider "datacenter" (defined in `Seed` resources)<br />this cluster should be deployed into.{{< /unsafe >}} |
| `providerName` _string_ | {{< unsafe >}}ProviderName is the name of the cloud provider used for this cluster.<br />This must match the given provider spec (e.g. if the providerName is<br />"aws", then the `aws` field must be set).{{< /unsafe >}} |
| `digitalocean` _[DigitaloceanCloudSpec](#digitaloceancloudspec)_ | {{< unsafe >}}Digitalocean defines the configuration data of the DigitalOcean cloud provider.{{< /unsafe >}} |
| `baremetal` _[BaremetalCloudSpec](#baremetalcloudspec)_ | {{< unsafe >}}Baremetal defines the configuration data for a Baremetal cluster.{{< /unsafe >}} |
| `bringyourown` _[BringYourOwnCloudSpec](#bringyourowncloudspec)_ | {{< unsafe >}}BringYourOwn defines the configuration data for a Bring Your Own cluster.{{< /unsafe >}} |
| `edge` _[EdgeCloudSpec](#edgecloudspec)_ | {{< unsafe >}}Edge defines the configuration data for an edge cluster.{{< /unsafe >}} |
| `aws` _[AWSCloudSpec](#awscloudspec)_ | {{< unsafe >}}AWS defines the configuration data of the Amazon Web Services(AWS) cloud provider.{{< /unsafe >}} |
| `azure` _[AzureCloudSpec](#azurecloudspec)_ | {{< unsafe >}}Azure defines the configuration data of the Microsoft Azure cloud.{{< /unsafe >}} |
| `openstack` _[OpenstackCloudSpec](#openstackcloudspec)_ | {{< unsafe >}}Openstack defines the configuration data of an OpenStack cloud.{{< /unsafe >}} |
| `packet` _[PacketCloudSpec](#packetcloudspec)_ | {{< unsafe >}}Deprecated: The Packet / Equinix Metal provider is deprecated and will be REMOVED IN VERSION 2.29.<br />This provider is no longer supported. Migrate your configurations away from "packet" immediately.<br />Packet defines the configuration data of a Packet / Equinix Metal cloud.{{< /unsafe >}} |
| `hetzner` _[HetznerCloudSpec](#hetznercloudspec)_ | {{< unsafe >}}Hetzner defines the configuration data of the Hetzner cloud.{{< /unsafe >}} |
| `vsphere` _[VSphereCloudSpec](#vspherecloudspec)_ | {{< unsafe >}}VSphere defines the configuration data of the vSphere.{{< /unsafe >}} |
| `gcp` _[GCPCloudSpec](#gcpcloudspec)_ | {{< unsafe >}}GCP defines the configuration data of the Google Cloud Platform(GCP).{{< /unsafe >}} |
| `kubevirt` _[KubevirtCloudSpec](#kubevirtcloudspec)_ | {{< unsafe >}}Kubevirt defines the configuration data of the KubeVirt.{{< /unsafe >}} |
| `alibaba` _[AlibabaCloudSpec](#alibabacloudspec)_ | {{< unsafe >}}Alibaba defines the configuration data of the Alibaba.{{< /unsafe >}} |
| `anexia` _[AnexiaCloudSpec](#anexiacloudspec)_ | {{< unsafe >}}Anexia defines the configuration data of the Anexia.{{< /unsafe >}} |
| `nutanix` _[NutanixCloudSpec](#nutanixcloudspec)_ | {{< unsafe >}}Nutanix defines the configuration data of the Nutanix.{{< /unsafe >}} |
| `vmwareclouddirector` _[VMwareCloudDirectorCloudSpec](#vmwareclouddirectorcloudspec)_ | {{< unsafe >}}VMwareCloudDirector defines the configuration data of the VMware Cloud Director.{{< /unsafe >}} |


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
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[ClusterSpec](#clusterspec)_ | {{< unsafe >}}Spec describes the desired cluster state.{{< /unsafe >}} |
| `status` _[ClusterStatus](#clusterstatus)_ | {{< unsafe >}}Status contains reconciliation information for the cluster.{{< /unsafe >}} |


[Back to top](#top)



### ClusterAddress



ClusterAddress stores access and address information of a cluster.

_Appears in:_
- [ClusterStatus](#clusterstatus)

| Field | Description |
| --- | --- |
| `url` _string_ | {{< unsafe >}}URL under which the Apiserver is available{{< /unsafe >}} |
| `port` _integer_ | {{< unsafe >}}Port is the port the API server listens on{{< /unsafe >}} |
| `externalName` _string_ | {{< unsafe >}}ExternalName is the DNS name for this cluster{{< /unsafe >}} |
| `internalURL` _string_ | {{< unsafe >}}InternalName is the seed cluster internal absolute DNS name to the API server{{< /unsafe >}} |
| `adminToken` _string_ | {{< unsafe >}}AdminToken is the token for the kubeconfig, the user can download{{< /unsafe >}} |
| `ip` _string_ | {{< unsafe >}}IP is the external IP under which the apiserver is available{{< /unsafe >}} |
| `apiServerExternalAddress` _string_ | {{< unsafe >}}APIServerExternalAddress is the external address of the API server (IP or DNS name)<br />This field is populated only when the API server service is of type LoadBalancer. If set, this address will be used in the<br />kubeconfig for the user cluster that can be downloaded from the KKP UI.{{< /unsafe >}} |


[Back to top](#top)



### ClusterBackupOptions





_Appears in:_
- [SettingSpec](#settingspec)

| Field | Description |
| --- | --- |
| `defaultChecksumAlgorithm` _string_ | {{< unsafe >}}DefaultChecksumAlgorithm allows setting a default checksum algorithm used by Velero for uploading objects to S3.<br /><br />Optional{{< /unsafe >}} |


[Back to top](#top)



### ClusterBackupStorageLocation



ClusterBackupStorageLocation is a KKP wrapper around Velero BSL spec.

_Appears in:_
- [ClusterBackupStorageLocationList](#clusterbackupstoragelocationlist)

| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `ClusterBackupStorageLocation`
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[BackupStorageLocationSpec](#backupstoragelocationspec)_ | {{< unsafe >}}Spec is a Velero BSL spec{{< /unsafe >}} |
| `status` _[BackupStorageLocationStatus](#backupstoragelocationstatus)_ | {{< unsafe >}}{{< /unsafe >}} |


[Back to top](#top)



### ClusterBackupStorageLocationList



ClusterBackupStorageLocationList is a list of ClusterBackupStorageLocations.



| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `ClusterBackupStorageLocationList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[ClusterBackupStorageLocation](#clusterbackupstoragelocation) array_ | {{< unsafe >}}Items is a list of EtcdBackupConfig objects.{{< /unsafe >}} |


[Back to top](#top)



### ClusterCondition





_Appears in:_
- [ClusterStatus](#clusterstatus)

| Field | Description |
| --- | --- |
| `status` _[ConditionStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#conditionstatus-v1-core)_ | {{< unsafe >}}Status of the condition, one of True, False, Unknown.{{< /unsafe >}} |
| `kubermaticVersion` _string_ | {{< unsafe >}}KubermaticVersion current kubermatic version.{{< /unsafe >}} |
| `lastHeartbeatTime` _[Time](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#time-v1-meta)_ | {{< unsafe >}}Last time we got an update on a given condition.{{< /unsafe >}} |
| `lastTransitionTime` _[Time](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#time-v1-meta)_ | {{< unsafe >}}Last time the condition transit from one status to another.{{< /unsafe >}} |
| `reason` _string_ | {{< unsafe >}}(brief) reason for the condition's last transition.{{< /unsafe >}} |
| `message` _string_ | {{< unsafe >}}Human readable message indicating details about last transition.{{< /unsafe >}} |


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
| `activeKey` _string_ | {{< unsafe >}}The current "primary" key used to encrypt data written to etcd. Secondary keys that can be used for decryption<br />(but not encryption) might be configured in the ClusterSpec.{{< /unsafe >}} |
| `encryptedResources` _string array_ | {{< unsafe >}}List of resources currently encrypted.{{< /unsafe >}} |
| `phase` _[ClusterEncryptionPhase](#clusterencryptionphase)_ | {{< unsafe >}}The current phase of the encryption process. Can be one of `Pending`, `Failed`, `Active` or `EncryptionNeeded`.<br />The `encryption_controller` logic will process the cluster based on the current phase and issue necessary changes<br />to make sure encryption on the cluster is active and updated with what the ClusterSpec defines.{{< /unsafe >}} |


[Back to top](#top)



### ClusterList



ClusterList specifies a list of user clusters.



| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `ClusterList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[Cluster](#cluster) array_ | {{< unsafe >}}{{< /unsafe >}} |


[Back to top](#top)



### ClusterNetworkingConfig



ClusterNetworkingConfig specifies the different networking
parameters for a cluster.

_Appears in:_
- [ClusterSpec](#clusterspec)

| Field | Description |
| --- | --- |
| `ipFamily` _[IPFamily](#ipfamily)_ | {{< unsafe >}}Optional: IP family used for cluster networking. Supported values are "", "IPv4" or "IPv4+IPv6".<br />Can be omitted / empty if pods and services network ranges are specified.<br />In that case it defaults according to the IP families of the provided network ranges.<br />If neither ipFamily nor pods & services network ranges are specified, defaults to "IPv4".{{< /unsafe >}} |
| `services` _[NetworkRanges](#networkranges)_ | {{< unsafe >}}The network ranges from which service VIPs are allocated.<br />It can contain one IPv4 and/or one IPv6 CIDR.<br />If both address families are specified, the first one defines the primary address family.{{< /unsafe >}} |
| `pods` _[NetworkRanges](#networkranges)_ | {{< unsafe >}}The network ranges from which POD networks are allocated.<br />It can contain one IPv4 and/or one IPv6 CIDR.<br />If both address families are specified, the first one defines the primary address family.{{< /unsafe >}} |
| `nodeCidrMaskSizeIPv4` _integer_ | {{< unsafe >}}NodeCIDRMaskSizeIPv4 is the mask size used to address the nodes within provided IPv4 Pods CIDR.<br />It has to be larger than the provided IPv4 Pods CIDR. Defaults to 24.{{< /unsafe >}} |
| `nodeCidrMaskSizeIPv6` _integer_ | {{< unsafe >}}NodeCIDRMaskSizeIPv6 is the mask size used to address the nodes within provided IPv6 Pods CIDR.<br />It has to be larger than the provided IPv6 Pods CIDR. Defaults to 64.{{< /unsafe >}} |
| `dnsDomain` _string_ | {{< unsafe >}}Domain name for services.{{< /unsafe >}} |
| `proxyMode` _string_ | {{< unsafe >}}ProxyMode defines the kube-proxy mode ("ipvs" / "iptables" / "ebpf").<br />Defaults to "ipvs". "ebpf" disables kube-proxy and requires CNI support.{{< /unsafe >}} |
| `ipvs` _[IPVSConfiguration](#ipvsconfiguration)_ | {{< unsafe >}}IPVS defines kube-proxy ipvs configuration options{{< /unsafe >}} |
| `nodeLocalDNSCacheEnabled` _boolean_ | {{< unsafe >}}NodeLocalDNSCacheEnabled controls whether the NodeLocal DNS Cache feature is enabled.<br />Defaults to true.{{< /unsafe >}} |
| `coreDNSReplicas` _integer_ | {{< unsafe >}}CoreDNSReplicas is the number of desired pods of user cluster coredns deployment.<br />Deprecated: This field should not be used anymore, use cluster.componentsOverride.coreDNS.replicas<br />instead. Only one of the two fields can be set at any time.{{< /unsafe >}} |
| `konnectivityEnabled` _boolean_ | {{< unsafe >}}Deprecated: KonnectivityEnabled enables konnectivity for controlplane to node network communication.<br />Konnectivity is the only supported choice for controlplane to node network communication. This field is<br />defaulted to true and setting it to false is rejected. It will be removed in a future release.{{< /unsafe >}} |
| `tunnelingAgentIP` _string_ | {{< unsafe >}}TunnelingAgentIP is the address used by the tunneling agents{{< /unsafe >}} |


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
| `humanReadableName` _string_ | {{< unsafe >}}HumanReadableName is the cluster name provided by the user.{{< /unsafe >}} |
| `version` _[Semver](#semver)_ | {{< unsafe >}}Version defines the wanted version of the control plane.{{< /unsafe >}} |
| `cloud` _[CloudSpec](#cloudspec)_ | {{< unsafe >}}Cloud contains information regarding the cloud provider that<br />is responsible for hosting the cluster's workload.{{< /unsafe >}} |
| `containerRuntime` _string_ | {{< unsafe >}}ContainerRuntime to use, i.e. `docker` or `containerd`. By default `containerd` will be used.{{< /unsafe >}} |
| `imagePullSecret` _[SecretReference](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#secretreference-v1-core)_ | {{< unsafe >}}Optional: ImagePullSecret references a secret with container registry credentials. This is passed to the machine-controller which sets the registry credentials on node level.{{< /unsafe >}} |
| `cniPlugin` _[CNIPluginSettings](#cnipluginsettings)_ | {{< unsafe >}}Optional: CNIPlugin refers to the spec of the CNI plugin used by the Cluster.{{< /unsafe >}} |
| `clusterNetwork` _[ClusterNetworkingConfig](#clusternetworkingconfig)_ | {{< unsafe >}}Optional: ClusterNetwork specifies the different networking parameters for a cluster.{{< /unsafe >}} |
| `machineNetworks` _[MachineNetworkingConfig](#machinenetworkingconfig) array_ | {{< unsafe >}}Optional: MachineNetworks is the list of the networking parameters used for IPAM.{{< /unsafe >}} |
| `exposeStrategy` _[ExposeStrategy](#exposestrategy)_ | {{< unsafe >}}ExposeStrategy is the strategy used to expose a cluster control plane.{{< /unsafe >}} |
| `apiServerAllowedIPRanges` _[NetworkRanges](#networkranges)_ | {{< unsafe >}}Optional: APIServerAllowedIPRanges is a list of IP ranges allowed to access the API server.<br />Applicable only if the expose strategy of the cluster is LoadBalancer.<br />If not configured, access to the API server is unrestricted.{{< /unsafe >}} |
| `componentsOverride` _[ComponentSettings](#componentsettings)_ | {{< unsafe >}}Optional: Component specific overrides that allow customization of control plane components.{{< /unsafe >}} |
| `oidc` _[OIDCSettings](#oidcsettings)_ | {{< unsafe >}}Optional: OIDC specifies the OIDC configuration parameters for enabling authentication mechanism for the cluster.{{< /unsafe >}} |
| `features` _object (keys:string, values:boolean)_ | {{< unsafe >}}A map of optional or early-stage features that can be enabled for the user cluster.<br />Some feature gates cannot be disabled after being enabled.<br />The available feature gates vary based on KKP version, Kubernetes version and Seed configuration.<br />Please consult the KKP documentation for specific feature gates.{{< /unsafe >}} |
| `updateWindow` _[UpdateWindow](#updatewindow)_ | {{< unsafe >}}Optional: UpdateWindow configures automatic update systems to respect a maintenance window for<br />applying OS updates to nodes. This is only respected on Flatcar nodes currently.{{< /unsafe >}} |
| `usePodSecurityPolicyAdmissionPlugin` _boolean_ | {{< unsafe >}}Enables the admission plugin `PodSecurityPolicy`. This plugin is deprecated by Kubernetes.{{< /unsafe >}} |
| `usePodNodeSelectorAdmissionPlugin` _boolean_ | {{< unsafe >}}Enables the admission plugin `PodNodeSelector`. Needs additional configuration via the `podNodeSelectorAdmissionPluginConfig` field.{{< /unsafe >}} |
| `useEventRateLimitAdmissionPlugin` _boolean_ | {{< unsafe >}}Enables the admission plugin `EventRateLimit`. Needs additional configuration via the `eventRateLimitConfig` field.<br />This plugin is considered "alpha" by Kubernetes.{{< /unsafe >}} |
| `admissionPlugins` _string array_ | {{< unsafe >}}A list of arbitrary admission plugin names that are passed to kube-apiserver. Must not include admission plugins<br />that can be enabled via a separate setting.{{< /unsafe >}} |
| `podNodeSelectorAdmissionPluginConfig` _object (keys:string, values:string)_ | {{< unsafe >}}Optional: Provides configuration for the PodNodeSelector admission plugin (needs plugin enabled<br />via `usePodNodeSelectorAdmissionPlugin`). It's used by the backend to create a configuration file for this plugin.<br />The key:value from this map is converted to <namespace>:<node-selectors-labels> in the file. Use `clusterDefaultNodeSelector`<br />as key to configure a default node selector.{{< /unsafe >}} |
| `eventRateLimitConfig` _[EventRateLimitConfig](#eventratelimitconfig)_ | {{< unsafe >}}Optional: Configures the EventRateLimit admission plugin (if enabled via `useEventRateLimitAdmissionPlugin`)<br />to create limits on Kubernetes event generation. The EventRateLimit plugin is capable of comparing and rate limiting incoming<br />`Events` based on several configured buckets.{{< /unsafe >}} |
| `enableUserSSHKeyAgent` _boolean_ | {{< unsafe >}}Optional: Deploys the UserSSHKeyAgent to the user cluster. This field is immutable.<br />If enabled, the agent will be deployed and used to sync user ssh keys attached by users to the cluster.<br />No SSH keys will be synced after node creation if this is disabled.{{< /unsafe >}} |
| `enableOperatingSystemManager` _boolean_ | {{< unsafe >}}Deprecated: EnableOperatingSystemManager has been deprecated starting with KKP 2.26 and will be removed in KKP 2.28+. This field is no-op and OSM is always enabled for user clusters.<br />OSM is responsible for creating and managing worker node configuration.{{< /unsafe >}} |
| `kubelb` _[KubeLB](#kubelb)_ | {{< unsafe >}}KubeLB holds the configuration for the kubeLB component.<br />Only available in Enterprise Edition.{{< /unsafe >}} |
| `kubernetesDashboard` _[KubernetesDashboard](#kubernetesdashboard)_ | {{< unsafe >}}KubernetesDashboard holds the configuration for the kubernetes-dashboard component.{{< /unsafe >}} |
| `auditLogging` _[AuditLoggingSettings](#auditloggingsettings)_ | {{< unsafe >}}Optional: AuditLogging configures Kubernetes API audit logging (https://kubernetes.io/docs/tasks/debug-application-cluster/audit/)<br />for the user cluster.{{< /unsafe >}} |
| `opaIntegration` _[OPAIntegrationSettings](#opaintegrationsettings)_ | {{< unsafe >}}Optional: OPAIntegration is a preview feature that enables OPA integration for the cluster.<br />Enabling it causes OPA Gatekeeper and its resources to be deployed on the user cluster.<br />By default it is disabled.{{< /unsafe >}} |
| `serviceAccount` _[ServiceAccountSettings](#serviceaccountsettings)_ | {{< unsafe >}}Optional: ServiceAccount contains service account related settings for the user cluster's kube-apiserver.{{< /unsafe >}} |
| `mla` _[MLASettings](#mlasettings)_ | {{< unsafe >}}Optional: MLA contains monitoring, logging and alerting related settings for the user cluster.{{< /unsafe >}} |
| `applicationSettings` _[ApplicationSettings](#applicationsettings)_ | {{< unsafe >}}Optional: ApplicationSettings contains the settings relative to the application feature.{{< /unsafe >}} |
| `encryptionConfiguration` _[EncryptionConfiguration](#encryptionconfiguration)_ | {{< unsafe >}}Optional: Configures encryption-at-rest for Kubernetes API data. This needs the `encryptionAtRest` feature gate.{{< /unsafe >}} |
| `pause` _boolean_ | {{< unsafe >}}If this is set to true, the cluster will not be reconciled by KKP.<br />This indicates that the user needs to do some action to resolve the pause.{{< /unsafe >}} |
| `pauseReason` _string_ | {{< unsafe >}}PauseReason is the reason why the cluster is not being managed. This field is for informational<br />purpose only and can be set by a user or a controller to communicate the reason for pausing the cluster.{{< /unsafe >}} |
| `debugLog` _boolean_ | {{< unsafe >}}Enables more verbose logging in KKP's user-cluster-controller-manager.{{< /unsafe >}} |
| `disableCsiDriver` _boolean_ | {{< unsafe >}}Optional: DisableCSIDriver disables the installation of CSI driver on the cluster<br />If this is true at the data center then it can't be over-written in the cluster configuration{{< /unsafe >}} |
| `backupConfig` _[BackupConfig](#backupconfig)_ | {{< unsafe >}}Optional: BackupConfig contains the configuration options for managing the Cluster Backup Velero integration feature.{{< /unsafe >}} |
| `kyverno` _[KyvernoSettings](#kyvernosettings)_ | {{< unsafe >}}Kyverno holds the configuration for the Kyverno policy management component.<br />Only available in Enterprise Edition.{{< /unsafe >}} |


[Back to top](#top)



### ClusterStatus



ClusterStatus stores status information about a cluster.

_Appears in:_
- [Cluster](#cluster)

| Field | Description |
| --- | --- |
| `address` _[ClusterAddress](#clusteraddress)_ | {{< unsafe >}}Address contains the IPs/URLs to access the cluster control plane.{{< /unsafe >}} |
| `lastUpdated` _[Time](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#time-v1-meta)_ | {{< unsafe >}}Deprecated: LastUpdated contains the timestamp at which the cluster was last modified.<br />It is kept only for KKP 2.20 release to not break the backwards-compatibility and not being set for KKP higher releases.{{< /unsafe >}} |
| `extendedHealth` _[ExtendedClusterHealth](#extendedclusterhealth)_ | {{< unsafe >}}ExtendedHealth exposes information about the current health state.<br />Extends standard health status for new states.{{< /unsafe >}} |
| `lastProviderReconciliation` _[Time](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#time-v1-meta)_ | {{< unsafe >}}LastProviderReconciliation is the time when the cloud provider resources<br />were last fully reconciled (during normal cluster reconciliation, KKP does<br />not re-check things like security groups, networks etc.).{{< /unsafe >}} |
| `namespaceName` _string_ | {{< unsafe >}}NamespaceName defines the namespace the control plane of this cluster is deployed in.{{< /unsafe >}} |
| `versions` _[ClusterVersionsStatus](#clusterversionsstatus)_ | {{< unsafe >}}Versions contains information regarding the current and desired versions<br />of the cluster control plane and worker nodes.{{< /unsafe >}} |
| `userName` _string_ | {{< unsafe >}}Deprecated: UserName contains the name of the owner of this cluster.<br />This field is not actively used and will be removed in the future.{{< /unsafe >}} |
| `userEmail` _string_ | {{< unsafe >}}UserEmail contains the email of the owner of this cluster.<br />During cluster creation only, this field will be used to bind the `cluster-admin` `ClusterRole` to a cluster owner.{{< /unsafe >}} |
| `errorReason` _[ClusterStatusError](#clusterstatuserror)_ | {{< unsafe >}}ErrorReason contains a error reason in case the controller encountered an error. Will be reset if the error was resolved.{{< /unsafe >}} |
| `errorMessage` _string_ | {{< unsafe >}}ErrorMessage contains a default error message in case the controller encountered an error. Will be reset if the error was resolved.{{< /unsafe >}} |
| `conditions` _object (keys:[ClusterConditionType](#clusterconditiontype), values:[ClusterCondition](#clustercondition))_ | {{< unsafe >}}Conditions contains conditions the cluster is in, its primary use case is status signaling between controllers or between<br />controllers and the API.{{< /unsafe >}} |
| `phase` _[ClusterPhase](#clusterphase)_ | {{< unsafe >}}Phase is a description of the current cluster status, summarizing the various conditions,<br />possible active updates etc. This field is for informational purpose only and no logic<br />should be tied to the phase.{{< /unsafe >}} |
| `inheritedLabels` _object (keys:string, values:string)_ | {{< unsafe >}}InheritedLabels are labels the cluster inherited from the project. They are read-only for users.{{< /unsafe >}} |
| `encryption` _[ClusterEncryptionStatus](#clusterencryptionstatus)_ | {{< unsafe >}}Encryption describes the status of the encryption-at-rest feature for encrypted data in etcd.{{< /unsafe >}} |
| `resourceUsage` _[ResourceDetails](#resourcedetails)_ | {{< unsafe >}}ResourceUsage shows the current usage of resources for the cluster.{{< /unsafe >}} |


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
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `clusterLabels` _object (keys:string, values:string)_ | {{< unsafe >}}{{< /unsafe >}} |
| `inheritedClusterLabels` _object (keys:string, values:string)_ | {{< unsafe >}}{{< /unsafe >}} |
| `credential` _string_ | {{< unsafe >}}{{< /unsafe >}} |
| `userSSHKeys` _[ClusterTemplateSSHKey](#clustertemplatesshkey) array_ | {{< unsafe >}}UserSSHKeys is the list of SSH public keys that should be assigned to all nodes in the cluster.{{< /unsafe >}} |
| `spec` _[ClusterSpec](#clusterspec)_ | {{< unsafe >}}Spec describes the desired state of a user cluster.{{< /unsafe >}} |


[Back to top](#top)



### ClusterTemplateInstance



ClusterTemplateInstance is the object representing a cluster template instance.

_Appears in:_
- [ClusterTemplateInstanceList](#clustertemplateinstancelist)

| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `ClusterTemplateInstance`
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[ClusterTemplateInstanceSpec](#clustertemplateinstancespec)_ | {{< unsafe >}}Spec specifies the data for cluster instances.{{< /unsafe >}} |


[Back to top](#top)



### ClusterTemplateInstanceList



ClusterTemplateInstanceList specifies a list of cluster template instances.



| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `ClusterTemplateInstanceList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[ClusterTemplateInstance](#clustertemplateinstance) array_ | {{< unsafe >}}Items refers to the list of ClusterTemplateInstance objects.{{< /unsafe >}} |


[Back to top](#top)



### ClusterTemplateInstanceSpec



ClusterTemplateInstanceSpec specifies the data for cluster instances.

_Appears in:_
- [ClusterTemplateInstance](#clustertemplateinstance)

| Field | Description |
| --- | --- |
| `projectID` _string_ | {{< unsafe >}}{{< /unsafe >}} |
| `clusterTemplateID` _string_ | {{< unsafe >}}{{< /unsafe >}} |
| `clusterTemplateName` _string_ | {{< unsafe >}}{{< /unsafe >}} |
| `replicas` _integer_ | {{< unsafe >}}{{< /unsafe >}} |


[Back to top](#top)



### ClusterTemplateList



ClusterTemplateList specifies a list of cluster templates.



| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `ClusterTemplateList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[ClusterTemplate](#clustertemplate) array_ | {{< unsafe >}}Items refers to the list of the ClusterTemplate objects.{{< /unsafe >}} |


[Back to top](#top)



### ClusterTemplateSSHKey



ClusterTemplateSSHKey is the object for holding SSH key.

_Appears in:_
- [ClusterTemplate](#clustertemplate)

| Field | Description |
| --- | --- |
| `id` _string_ | {{< unsafe >}}ID is the name of the UserSSHKey object that is supposed to be assigned<br />to any ClusterTemplateInstance created based on this template.{{< /unsafe >}} |
| `name` _string_ | {{< unsafe >}}Name is the human readable SSH key name.{{< /unsafe >}} |


[Back to top](#top)



### ClusterVersionsStatus



ClusterVersionsStatus contains information regarding the current and desired versions
of the cluster control plane and worker nodes.

_Appears in:_
- [ClusterStatus](#clusterstatus)

| Field | Description |
| --- | --- |
| `controlPlane` _[Semver](#semver)_ | {{< unsafe >}}ControlPlane is the currently active cluster version. This can lag behind the apiserver<br />version if an update is currently rolling out.{{< /unsafe >}} |
| `apiserver` _[Semver](#semver)_ | {{< unsafe >}}Apiserver is the currently desired version of the kube-apiserver. During<br />upgrades across multiple minor versions (e.g. from 1.20 to 1.23), this will gradually<br />be increased by the update-controller until the desired cluster version (spec.version)<br />is reached.{{< /unsafe >}} |
| `controllerManager` _[Semver](#semver)_ | {{< unsafe >}}ControllerManager is the currently desired version of the kube-controller-manager. This<br />field behaves the same as the apiserver field.{{< /unsafe >}} |
| `scheduler` _[Semver](#semver)_ | {{< unsafe >}}Scheduler is the currently desired version of the kube-scheduler. This field behaves the<br />same as the apiserver field.{{< /unsafe >}} |
| `oldestNodeVersion` _[Semver](#semver)_ | {{< unsafe >}}OldestNodeVersion is the oldest node version currently in use inside the cluster. This can be<br />nil if there are no nodes. This field is primarily for speeding up reconciling, so that<br />the controller doesn't have to re-fetch to the usercluster and query its node on every<br />reconciliation.{{< /unsafe >}} |


[Back to top](#top)



### ComponentSettings





_Appears in:_
- [ClusterSpec](#clusterspec)
- [SeedSpec](#seedspec)

| Field | Description |
| --- | --- |
| `apiserver` _[APIServerSettings](#apiserversettings)_ | {{< unsafe >}}Apiserver configures kube-apiserver settings.{{< /unsafe >}} |
| `controllerManager` _[ControllerSettings](#controllersettings)_ | {{< unsafe >}}ControllerManager configures kube-controller-manager settings.{{< /unsafe >}} |
| `scheduler` _[ControllerSettings](#controllersettings)_ | {{< unsafe >}}Scheduler configures kube-scheduler settings.{{< /unsafe >}} |
| `etcd` _[EtcdStatefulSetSettings](#etcdstatefulsetsettings)_ | {{< unsafe >}}Etcd configures the etcd ring used to store Kubernetes data.{{< /unsafe >}} |
| `prometheus` _[StatefulSetSettings](#statefulsetsettings)_ | {{< unsafe >}}Prometheus configures the Prometheus instance deployed into the cluster control plane.{{< /unsafe >}} |
| `nodePortProxyEnvoy` _[NodeportProxyComponent](#nodeportproxycomponent)_ | {{< unsafe >}}NodePortProxyEnvoy configures the per-cluster nodeport-proxy-envoy that is deployed if<br />the `LoadBalancer` expose strategy is used. This is not effective if a different expose<br />strategy is configured.{{< /unsafe >}} |
| `konnectivityProxy` _[KonnectivityProxySettings](#konnectivityproxysettings)_ | {{< unsafe >}}KonnectivityProxy configures konnectivity-server and konnectivity-agent components.{{< /unsafe >}} |
| `userClusterController` _[ControllerSettings](#controllersettings)_ | {{< unsafe >}}UserClusterController configures the KKP usercluster-controller deployed as part of the cluster control plane.{{< /unsafe >}} |
| `operatingSystemManager` _[OSMControllerSettings](#osmcontrollersettings)_ | {{< unsafe >}}OperatingSystemManager configures operating-system-manager (the component generating node bootstrap scripts for machine-controller).{{< /unsafe >}} |
| `coreDNS` _[DeploymentSettings](#deploymentsettings)_ | {{< unsafe >}}CoreDNS configures CoreDNS deployed as part of the cluster control plane.{{< /unsafe >}} |


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
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[ConstraintSpec](#constraintspec)_ | {{< unsafe >}}Spec describes the desired state for the constraint.{{< /unsafe >}} |


[Back to top](#top)



### ConstraintList



ConstraintList specifies a list of constraints.



| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `ConstraintList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[Constraint](#constraint) array_ | {{< unsafe >}}Items is a list of Gatekeeper Constraints{{< /unsafe >}} |


[Back to top](#top)



### ConstraintSelector



ConstraintSelector is the object holding the cluster selection filters.

_Appears in:_
- [ConstraintSpec](#constraintspec)

| Field | Description |
| --- | --- |
| `providers` _string array_ | {{< unsafe >}}Providers is a list of cloud providers to which the Constraint applies to. Empty means all providers are selected.{{< /unsafe >}} |
| `labelSelector` _[LabelSelector](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#labelselector-v1-meta)_ | {{< unsafe >}}LabelSelector selects the Clusters to which the Constraint applies based on their labels{{< /unsafe >}} |


[Back to top](#top)



### ConstraintSpec



ConstraintSpec specifies the data for the constraint.

_Appears in:_
- [Constraint](#constraint)

| Field | Description |
| --- | --- |
| `constraintType` _string_ | {{< unsafe >}}ConstraintType specifies the type of gatekeeper constraint that the constraint applies to{{< /unsafe >}} |
| `disabled` _boolean_ | {{< unsafe >}}Disabled  is the flag for disabling OPA constraints{{< /unsafe >}} |
| `match` _[Match](#match)_ | {{< unsafe >}}Match contains the constraint to resource matching data{{< /unsafe >}} |
| `parameters` _[Parameters](#parameters)_ | {{< unsafe >}}Parameters specifies the parameters used by the constraint template REGO.<br />It supports both the legacy rawJSON parameters, in which all the parameters are set in a JSON string, and regular<br />parameters like in Gatekeeper Constraints.<br />If rawJSON is set, during constraint syncing to the user cluster, the other parameters are ignored<br />Example with rawJSON parameters:<br /><br />parameters:<br />  rawJSON: '\{"labels":["gatekeeper"]\}'<br /><br />And with regular parameters:<br /><br />parameters:<br />  labels: ["gatekeeper"]{{< /unsafe >}} |
| `selector` _[ConstraintSelector](#constraintselector)_ | {{< unsafe >}}Selector specifies the cluster selection filters{{< /unsafe >}} |
| `enforcementAction` _string_ | {{< unsafe >}}EnforcementAction defines the action to take in response to a constraint being violated.<br />By default, EnforcementAction is set to deny as the default behavior is to deny admission requests with any violation.{{< /unsafe >}} |


[Back to top](#top)



### ConstraintTemplate



ConstraintTemplate is the object representing a kubermatic wrapper for a gatekeeper constraint template.

_Appears in:_
- [ConstraintTemplateList](#constrainttemplatelist)

| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `ConstraintTemplate`
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[ConstraintTemplateSpec](#constrainttemplatespec)_ | {{< unsafe >}}Spec specifies the gatekeeper constraint template and KKP related spec.{{< /unsafe >}} |


[Back to top](#top)



### ConstraintTemplateList



ConstraintTemplateList specifies a list of constraint templates.



| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `ConstraintTemplateList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[ConstraintTemplate](#constrainttemplate) array_ | {{< unsafe >}}Items refers to the list of ConstraintTemplate objects.{{< /unsafe >}} |


[Back to top](#top)



### ConstraintTemplateSelector



ConstraintTemplateSelector is the object holding the cluster selection filters.

_Appears in:_
- [ConstraintTemplateSpec](#constrainttemplatespec)

| Field | Description |
| --- | --- |
| `providers` _string array_ | {{< unsafe >}}Providers is a list of cloud providers to which the Constraint Template applies to. Empty means all providers are selected.{{< /unsafe >}} |
| `labelSelector` _[LabelSelector](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#labelselector-v1-meta)_ | {{< unsafe >}}LabelSelector selects the Clusters to which the Constraint Template applies based on their labels{{< /unsafe >}} |


[Back to top](#top)



### ConstraintTemplateSpec



ConstraintTemplateSpec is the object representing the gatekeeper constraint template spec and kubermatic related spec.

_Appears in:_
- [ConstraintTemplate](#constrainttemplate)

| Field | Description |
| --- | --- |
| `crd` _[CRD](#crd)_ | {{< unsafe >}}{{< /unsafe >}} |
| `targets` _Target array_ | {{< unsafe >}}{{< /unsafe >}} |
| `selector` _[ConstraintTemplateSelector](#constrainttemplateselector)_ | {{< unsafe >}}Selector configures which clusters this constraint template is applied to.{{< /unsafe >}} |


[Back to top](#top)



### ContainerRuntimeContainerd



ContainerRuntimeContainerd defines containerd container runtime registries configs.

_Appears in:_
- [NodeSettings](#nodesettings)

| Field | Description |
| --- | --- |
| `registries` _object (keys:string, values:[ContainerdRegistry](#containerdregistry))_ | {{< unsafe >}}A map of registries to use to render configs and mirrors for containerd registries{{< /unsafe >}} |


[Back to top](#top)





### ControllerSettings





_Appears in:_
- [ComponentSettings](#componentsettings)
- [OSMControllerSettings](#osmcontrollersettings)

| Field | Description |
| --- | --- |
| `replicas` _integer_ | {{< unsafe >}}{{< /unsafe >}} |
| `resources` _[ResourceRequirements](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#resourcerequirements-v1-core)_ | {{< unsafe >}}{{< /unsafe >}} |
| `tolerations` _[Toleration](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#toleration-v1-core) array_ | {{< unsafe >}}{{< /unsafe >}} |
| `leaderElection` _[LeaderElectionSettings](#leaderelectionsettings)_ | {{< unsafe >}}{{< /unsafe >}} |


[Back to top](#top)



### CustomLink





_Appears in:_
- [CustomLinks](#customlinks)

| Field | Description |
| --- | --- |
| `label` _string_ | {{< unsafe >}}{{< /unsafe >}} |
| `url` _string_ | {{< unsafe >}}{{< /unsafe >}} |
| `icon` _string_ | {{< unsafe >}}{{< /unsafe >}} |
| `location` _string_ | {{< unsafe >}}{{< /unsafe >}} |


[Back to top](#top)



### CustomLinks

_Underlying type:_ `[CustomLink](#customlink)`



_Appears in:_
- [SettingSpec](#settingspec)

| Field | Description |
| --- | --- |
| `label` _string_ | {{< unsafe >}}{{< /unsafe >}} |
| `url` _string_ | {{< unsafe >}}{{< /unsafe >}} |
| `icon` _string_ | {{< unsafe >}}{{< /unsafe >}} |
| `location` _string_ | {{< unsafe >}}{{< /unsafe >}} |


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
| `country` _string_ | {{< unsafe >}}Optional: Country of the seed as ISO-3166 two-letter code, e.g. DE or UK.<br />For informational purposes in the Kubermatic dashboard only.{{< /unsafe >}} |
| `location` _string_ | {{< unsafe >}}Optional: Detailed location of the cluster, like "Hamburg" or "Datacenter 7".<br />For informational purposes in the Kubermatic dashboard only.{{< /unsafe >}} |
| `node` _[NodeSettings](#nodesettings)_ | {{< unsafe >}}Node holds node-specific settings, like e.g. HTTP proxy, Docker<br />registries and the like. Proxy settings are inherited from the seed if<br />not specified here.{{< /unsafe >}} |
| `spec` _[DatacenterSpec](#datacenterspec)_ | {{< unsafe >}}Spec describes the cloud provider settings used to manage resources<br />in this datacenter. Exactly one cloud provider must be defined.{{< /unsafe >}} |


[Back to top](#top)



### DatacenterSpec



DatacenterSpec configures a KKP datacenter. Provider configuration is mutually exclusive,
and as such only a single provider can be configured per datacenter.

_Appears in:_
- [Datacenter](#datacenter)

| Field | Description |
| --- | --- |
| `digitalocean` _[DatacenterSpecDigitalocean](#datacenterspecdigitalocean)_ | {{< unsafe >}}Digitalocean configures a Digitalocean datacenter.{{< /unsafe >}} |
| `bringyourown` _[DatacenterSpecBringYourOwn](#datacenterspecbringyourown)_ | {{< unsafe >}}BringYourOwn contains settings for clusters using manually created<br />nodes via kubeadm.{{< /unsafe >}} |
| `baremetal` _[DatacenterSpecBaremetal](#datacenterspecbaremetal)_ | {{< unsafe >}}Baremetal contains settings for baremetal clusters in datacenters.{{< /unsafe >}} |
| `edge` _[DatacenterSpecEdge](#datacenterspecedge)_ | {{< unsafe >}}Edge contains settings for clusters using manually created<br />nodes in edge envs.{{< /unsafe >}} |
| `aws` _[DatacenterSpecAWS](#datacenterspecaws)_ | {{< unsafe >}}AWS configures an Amazon Web Services (AWS) datacenter.{{< /unsafe >}} |
| `azure` _[DatacenterSpecAzure](#datacenterspecazure)_ | {{< unsafe >}}Azure configures an Azure datacenter.{{< /unsafe >}} |
| `openstack` _[DatacenterSpecOpenstack](#datacenterspecopenstack)_ | {{< unsafe >}}Openstack configures an Openstack datacenter.{{< /unsafe >}} |
| `packet` _[DatacenterSpecPacket](#datacenterspecpacket)_ | {{< unsafe >}}Deprecated: The Packet / Equinix Metal provider is deprecated and will be REMOVED IN VERSION 2.29.<br />This provider is no longer supported. Migrate your configurations away from "packet" immediately.<br />Packet configures an Equinix Metal datacenter.{{< /unsafe >}} |
| `hetzner` _[DatacenterSpecHetzner](#datacenterspechetzner)_ | {{< unsafe >}}Hetzner configures a Hetzner datacenter.{{< /unsafe >}} |
| `vsphere` _[DatacenterSpecVSphere](#datacenterspecvsphere)_ | {{< unsafe >}}VSphere configures a VMware vSphere datacenter.{{< /unsafe >}} |
| `vmwareclouddirector` _[DatacenterSpecVMwareCloudDirector](#datacenterspecvmwareclouddirector)_ | {{< unsafe >}}VMwareCloudDirector configures a VMware Cloud Director datacenter.{{< /unsafe >}} |
| `gcp` _[DatacenterSpecGCP](#datacenterspecgcp)_ | {{< unsafe >}}GCP configures a Google Cloud Platform (GCP) datacenter.{{< /unsafe >}} |
| `kubevirt` _[DatacenterSpecKubevirt](#datacenterspeckubevirt)_ | {{< unsafe >}}Kubevirt configures a KubeVirt datacenter.{{< /unsafe >}} |
| `alibaba` _[DatacenterSpecAlibaba](#datacenterspecalibaba)_ | {{< unsafe >}}Alibaba configures an Alibaba Cloud datacenter.{{< /unsafe >}} |
| `anexia` _[DatacenterSpecAnexia](#datacenterspecanexia)_ | {{< unsafe >}}Anexia configures an Anexia datacenter.{{< /unsafe >}} |
| `nutanix` _[DatacenterSpecNutanix](#datacenterspecnutanix)_ | {{< unsafe >}}Nutanix configures a Nutanix HCI datacenter.{{< /unsafe >}} |
| `requiredEmails` _string array_ | {{< unsafe >}}Optional: When defined, only users with an e-mail address on the<br />given domains can make use of this datacenter. You can define multiple<br />domains, e.g. "example.com", one of which must match the email domain<br />exactly (i.e. "example.com" will not match "user@test.example.com").{{< /unsafe >}} |
| `enforceAuditLogging` _boolean_ | {{< unsafe >}}Optional: EnforceAuditLogging enforces audit logging on every cluster within the DC,<br />ignoring cluster-specific settings.{{< /unsafe >}} |
| `enforcedAuditWebhookSettings` _[AuditWebhookBackendSettings](#auditwebhookbackendsettings)_ | {{< unsafe >}}Optional: EnforcedAuditWebhookSettings allows admins to control webhook backend for audit logs of all the clusters within the DC,<br />ignoring cluster-specific settings.{{< /unsafe >}} |
| `enforcePodSecurityPolicy` _boolean_ | {{< unsafe >}}Optional: EnforcePodSecurityPolicy enforces pod security policy plugin on every clusters within the DC,<br />ignoring cluster-specific settings.{{< /unsafe >}} |
| `providerReconciliationInterval` _[Duration](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#duration-v1-meta)_ | {{< unsafe >}}Optional: ProviderReconciliationInterval is the time that must have passed since a<br />Cluster's status.lastProviderReconciliation to make the cluster controller<br />perform an in-depth provider reconciliation, where for example missing security<br />groups will be reconciled.<br />Setting this too low can cause rate limits by the cloud provider, setting this<br />too high means that *if* a resource at a cloud provider is removed/changed outside<br />of KKP, it will take this long to fix it.{{< /unsafe >}} |
| `operatingSystemProfiles` _[OperatingSystemProfileList](#operatingsystemprofilelist)_ | {{< unsafe >}}Optional: DefaultOperatingSystemProfiles specifies the OperatingSystemProfiles to use for each supported operating system.{{< /unsafe >}} |
| `machineFlavorFilter` _[MachineFlavorFilter](#machineflavorfilter)_ | {{< unsafe >}}Optional: MachineFlavorFilter is used to filter out allowed machine flavors based on the specified resource limits like CPU, Memory, and GPU etc.{{< /unsafe >}} |
| `disableCsiDriver` _boolean_ | {{< unsafe >}}Optional: DisableCSIDriver disables the installation of CSI driver on every clusters within the DC<br />If true it can't be over-written in the cluster configuration{{< /unsafe >}} |
| `kubelb` _[KubeLBDatacenterSettings](#kubelbdatacentersettings)_ | {{< unsafe >}}Optional: KubeLB holds the configuration for the kubeLB at the data center level.<br />Only available in Enterprise Edition.{{< /unsafe >}} |
| `apiServerServiceType` _[ServiceType](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#servicetype-v1-core)_ | {{< unsafe >}}APIServerServiceType is the service type used for API Server service `apiserver-external` for the user clusters.<br />By default, the type of service that will be used is determined by the `ExposeStrategy` used for the cluster.{{< /unsafe >}} |


[Back to top](#top)



### DatacenterSpecAWS



DatacenterSpecAWS describes an AWS datacenter.

_Appears in:_
- [DatacenterSpec](#datacenterspec)

| Field | Description |
| --- | --- |
| `region` _string_ | {{< unsafe >}}The AWS region to use, e.g. "us-east-1". For a list of available regions, see<br />https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html{{< /unsafe >}} |
| `images` _[ImageList](#imagelist)_ | {{< unsafe >}}List of AMIs to use for a given operating system.<br />This gets defaulted by querying for the latest AMI for the given distribution<br />when machines are created, so under normal circumstances it is not necessary<br />to define the AMIs statically.{{< /unsafe >}} |


[Back to top](#top)



### DatacenterSpecAlibaba



DatacenterSpecAlibaba describes a alibaba datacenter.

_Appears in:_
- [DatacenterSpec](#datacenterspec)

| Field | Description |
| --- | --- |
| `region` _string_ | {{< unsafe >}}Region to use, for a full list of regions see<br />https://www.alibabacloud.com/help/doc-detail/40654.htm{{< /unsafe >}} |


[Back to top](#top)



### DatacenterSpecAnexia



DatacenterSpecAnexia describes a anexia datacenter.

_Appears in:_
- [DatacenterSpec](#datacenterspec)

| Field | Description |
| --- | --- |
| `locationID` _string_ | {{< unsafe >}}LocationID the location of the region{{< /unsafe >}} |


[Back to top](#top)



### DatacenterSpecAzure



DatacenterSpecAzure describes an Azure cloud datacenter.

_Appears in:_
- [DatacenterSpec](#datacenterspec)

| Field | Description |
| --- | --- |
| `location` _string_ | {{< unsafe >}}Region to use, for example "westeurope". A list of available regions can be<br />found at https://azure.microsoft.com/en-us/global-infrastructure/locations/{{< /unsafe >}} |
| `images` _[ImageList](#imagelist)_ | {{< unsafe >}}Images to use for each supported operating system{{< /unsafe >}} |


[Back to top](#top)



### DatacenterSpecBaremetal



DatacenterSpecBaremetal describes a datacenter of baremetal nodes.

_Appears in:_
- [DatacenterSpec](#datacenterspec)

| Field | Description |
| --- | --- |
| `tinkerbell` _[DatacenterSpecTinkerbell](#datacenterspectinkerbell)_ | {{< unsafe >}}{{< /unsafe >}} |


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
| `region` _string_ | {{< unsafe >}}Datacenter location, e.g. "ams3". A list of existing datacenters can be found<br />at https://www.digitalocean.com/docs/platform/availability-matrix/{{< /unsafe >}} |


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
| `region` _string_ | {{< unsafe >}}Region to use, for example "europe-west3", for a full list of regions see<br />https://cloud.google.com/compute/docs/regions-zones/{{< /unsafe >}} |
| `zoneSuffixes` _string array_ | {{< unsafe >}}List of enabled zones, for example [a, c]. See the link above for the available<br />zones in your chosen region.{{< /unsafe >}} |
| `regional` _boolean_ | {{< unsafe >}}Optional: Regional clusters spread their resources across multiple availability zones.<br />Refer to the official documentation for more details on this:<br />https://cloud.google.com/kubernetes-engine/docs/concepts/regional-clusters{{< /unsafe >}} |


[Back to top](#top)



### DatacenterSpecHetzner



DatacenterSpecHetzner describes a Hetzner cloud datacenter.

_Appears in:_
- [DatacenterSpec](#datacenterspec)

| Field | Description |
| --- | --- |
| `datacenter` _string_ | {{< unsafe >}}Datacenter location, e.g. "nbg1-dc3". A list of existing datacenters can be found<br />at https://docs.hetzner.com/general/others/data-centers-and-connection/{{< /unsafe >}} |
| `network` _string_ | {{< unsafe >}}Network is the pre-existing Hetzner network in which the machines are running.<br />While machines can be in multiple networks, a single one must be chosen for the<br />HCloud CCM to work.{{< /unsafe >}} |
| `location` _string_ | {{< unsafe >}}Optional: Detailed location of the datacenter, like "Hamburg" or "Datacenter 7".<br />For informational purposes only.{{< /unsafe >}} |


[Back to top](#top)



### DatacenterSpecKubevirt



DatacenterSpecKubevirt describes a kubevirt datacenter.

_Appears in:_
- [DatacenterSpec](#datacenterspec)

| Field | Description |
| --- | --- |
| `namespacedMode` _[NamespacedMode](#namespacedmode)_ | {{< unsafe >}}NamespacedMode represents the configuration for enabling the single namespace mode for all user-clusters in the KubeVirt datacenter.{{< /unsafe >}} |
| `dnsPolicy` _string_ | {{< unsafe >}}DNSPolicy represents the dns policy for the pod. Valid values are 'ClusterFirstWithHostNet', 'ClusterFirst',<br />'Default' or 'None'. Defaults to "ClusterFirst". DNS parameters given in DNSConfig will be merged with the<br />policy selected with DNSPolicy.{{< /unsafe >}} |
| `dnsConfig` _[PodDNSConfig](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#poddnsconfig-v1-core)_ | {{< unsafe >}}DNSConfig represents the DNS parameters of a pod. Parameters specified here will be merged to the generated DNS<br />configuration based on DNSPolicy.{{< /unsafe >}} |
| `enableDefaultNetworkPolicies` _boolean_ | {{< unsafe >}}Optional: EnableDefaultNetworkPolicies enables deployment of default network policies like cluster isolation.<br />Defaults to true.{{< /unsafe >}} |
| `enableDedicatedCpus` _boolean_ | {{< unsafe >}}Optional: EnableDedicatedCPUs enables the assignment of dedicated cpus instead of resource requests and limits for a virtual machine.<br />Defaults to false.{{< /unsafe >}} |
| `customNetworkPolicies` _[CustomNetworkPolicy](#customnetworkpolicy) array_ | {{< unsafe >}}Optional: CustomNetworkPolicies allows to add some extra custom NetworkPolicies, that are deployed<br />in the dedicated infra KubeVirt cluster. They are added to the defaults.{{< /unsafe >}} |
| `images` _[KubeVirtImageSources](#kubevirtimagesources)_ | {{< unsafe >}}Images represents standard VM Image sources.{{< /unsafe >}} |
| `infraStorageClasses` _[KubeVirtInfraStorageClass](#kubevirtinfrastorageclass) array_ | {{< unsafe >}}Optional: InfraStorageClasses contains a list of KubeVirt infra cluster StorageClasses names<br />that will be used to initialise StorageClasses in the tenant cluster.<br />In the tenant cluster, the created StorageClass name will have as name:<br />kubevirt-<infra-storageClass-name>{{< /unsafe >}} |
| `providerNetwork` _[ProviderNetwork](#providernetwork)_ | {{< unsafe >}}Optional: ProviderNetwork describes the infra cluster network fabric that is being used{{< /unsafe >}} |
| `ccmZoneAndRegionEnabled` _boolean_ | {{< unsafe >}}Optional: indicates if region and zone labels from the cloud provider should be fetched.{{< /unsafe >}} |
| `ccmLoadBalancerEnabled` _boolean_ | {{< unsafe >}}Optional: indicates if the ccm should create and manage the clusters load balancers.{{< /unsafe >}} |
| `vmEvictionStrategy` _[EvictionStrategy](#evictionstrategy)_ | {{< unsafe >}}VMEvictionStrategy describes the strategy to follow when a node drain occurs. If not set the default<br />value is External and the VM will be protected by a PDB.{{< /unsafe >}} |
| `csiDriverOperator` _[KubeVirtCSIDriverOperator](#kubevirtcsidriveroperator)_ | {{< unsafe >}}CSIDriverOperator configures the kubevirt csi driver operator in the user cluster such as the csi driver images overwriting.{{< /unsafe >}} |
| `matchSubnetAndStorageLocation` _boolean_ | {{< unsafe >}}Optional: MatchSubnetAndStorageLocation if set to true, the region and zone of the subnet and storage class must match. For<br />example, if the storage class has the region `eu` and zone was `central`, the subnet must be in the same region and zone.<br />otherwise KKP will reject the creation of the machine deployment and eventually the cluster.{{< /unsafe >}} |
| `disableDefaultInstanceTypes` _boolean_ | {{< unsafe >}}DisableDefaultInstanceTypes prevents KKP from automatically creating default instance types.<br />(standard-2, standard-4, standard-8) in KubeVirt environments.{{< /unsafe >}} |
| `disableDefaultPreferences` _boolean_ | {{< unsafe >}}DisableKubermaticPreferences prevents KKP from setting default KubeVirt preferences.{{< /unsafe >}} |


[Back to top](#top)



### DatacenterSpecNutanix



DatacenterSpecNutanix describes a Nutanix datacenter.

_Appears in:_
- [DatacenterSpec](#datacenterspec)

| Field | Description |
| --- | --- |
| `endpoint` _string_ | {{< unsafe >}}Endpoint to use for accessing Nutanix Prism Central. No protocol or port should be passed,<br />for example "nutanix.example.com" or "10.0.0.1"{{< /unsafe >}} |
| `port` _integer_ | {{< unsafe >}}Optional: Port to use when connecting to the Nutanix Prism Central endpoint (defaults to 9440){{< /unsafe >}} |
| `allowInsecure` _boolean_ | {{< unsafe >}}Optional: AllowInsecure allows to disable the TLS certificate check against the endpoint (defaults to false){{< /unsafe >}} |
| `images` _[ImageList](#imagelist)_ | {{< unsafe >}}Images to use for each supported operating system{{< /unsafe >}} |


[Back to top](#top)



### DatacenterSpecOpenstack



DatacenterSpecOpenstack describes an OpenStack datacenter.

_Appears in:_
- [DatacenterSpec](#datacenterspec)

| Field | Description |
| --- | --- |
| `authURL` _string_ | {{< unsafe >}}Authentication URL{{< /unsafe >}} |
| `availabilityZone` _string_ | {{< unsafe >}}Used to configure availability zone.{{< /unsafe >}} |
| `region` _string_ | {{< unsafe >}}Authentication region name{{< /unsafe >}} |
| `ignoreVolumeAZ` _boolean_ | {{< unsafe >}}Optional{{< /unsafe >}} |
| `enforceFloatingIP` _boolean_ | {{< unsafe >}}Optional{{< /unsafe >}} |
| `dnsServers` _string array_ | {{< unsafe >}}Used for automatic network creation{{< /unsafe >}} |
| `images` _[ImageList](#imagelist)_ | {{< unsafe >}}Images to use for each supported operating system.{{< /unsafe >}} |
| `manageSecurityGroups` _boolean_ | {{< unsafe >}}Optional: Gets mapped to the "manage-security-groups" setting in the cloud config.<br />This setting defaults to true.{{< /unsafe >}} |
| `loadBalancerProvider` _string_ | {{< unsafe >}}Optional: Gets mapped to the "lb-provider" setting in the cloud config.<br />defaults to ""{{< /unsafe >}} |
| `loadBalancerMethod` _string_ | {{< unsafe >}}Optional: Gets mapped to the "lb-method" setting in the cloud config.<br />defaults to "ROUND_ROBIN".{{< /unsafe >}} |
| `useOctavia` _boolean_ | {{< unsafe >}}Optional: Gets mapped to the "use-octavia" setting in the cloud config.<br />use-octavia is enabled by default in CCM since v1.17.0, and disabled by<br />default with the in-tree cloud provider.{{< /unsafe >}} |
| `trustDevicePath` _boolean_ | {{< unsafe >}}Optional: Gets mapped to the "trust-device-path" setting in the cloud config.<br />This setting defaults to false.{{< /unsafe >}} |
| `nodeSizeRequirements` _[OpenstackNodeSizeRequirements](#openstacknodesizerequirements)_ | {{< unsafe >}}Optional: Restrict the allowed VM configurations that can be chosen in<br />the KKP dashboard. This setting does not affect the validation webhook for<br />MachineDeployments.{{< /unsafe >}} |
| `enabledFlavors` _string array_ | {{< unsafe >}}Optional: List of enabled flavors for the given datacenter{{< /unsafe >}} |
| `ipv6Enabled` _boolean_ | {{< unsafe >}}Optional: defines if the IPv6 is enabled for the datacenter{{< /unsafe >}} |
| `csiCinderTopologyEnabled` _boolean_ | {{< unsafe >}}Optional: configures enablement of topology support for the Cinder CSI Plugin.<br />This requires Nova and Cinder to have matching availability zones configured.{{< /unsafe >}} |
| `enableConfigDrive` _boolean_ | {{< unsafe >}}Optional: enable a configuration drive that will be attached to the instance when it boots.<br />The instance can mount this drive and read files from it to get information{{< /unsafe >}} |
| `nodePortsAllowedIPRange` _[NetworkRanges](#networkranges)_ | {{< unsafe >}}A CIDR ranges that will be used to allow access to the node port range in the security group. By default it will be open to 0.0.0.0/0.<br />Only applies if the security group is generated by KKP and not preexisting and will be applied only if no ranges are set at the cluster level.{{< /unsafe >}} |
| `loadBalancerClasses` _[LoadBalancerClass](#loadbalancerclass) array_ | {{< unsafe >}}Optional: List of LoadBalancerClass configurations to be used for the OpenStack cloud provider.{{< /unsafe >}} |


[Back to top](#top)



### DatacenterSpecPacket



Deprecated: The Packet / Equinix Metal provider is deprecated and will be REMOVED IN VERSION 2.29.
This provider is no longer supported. Migrate your configurations away from "packet" immediately.
DatacenterSpecPacket describes a Packet datacenter.

_Appears in:_
- [DatacenterSpec](#datacenterspec)

| Field | Description |
| --- | --- |
| `facilities` _string array_ | {{< unsafe >}}The list of enabled facilities, for example "ams1", for a full list of available<br />facilities see https://metal.equinix.com/developers/docs/locations/facilities/{{< /unsafe >}} |
| `metro` _string_ | {{< unsafe >}}Metros are facilities that are grouped together geographically and share capacity<br />and networking features, see https://metal.equinix.com/developers/docs/locations/metros/{{< /unsafe >}} |


[Back to top](#top)



### DatacenterSpecTinkerbell

_Underlying type:_ `[struct{Images TinkerbellImageSources "json:\"images,omitempty\""}](#struct{images-tinkerbellimagesources-"json:\"images,omitempty\""})`

DatacenterSepcTinkerbell contains spec for tinkerbell provider.

_Appears in:_
- [DatacenterSpecBaremetal](#datacenterspecbaremetal)



### DatacenterSpecVMwareCloudDirector





_Appears in:_
- [DatacenterSpec](#datacenterspec)

| Field | Description |
| --- | --- |
| `url` _string_ | {{< unsafe >}}Endpoint URL to use, including protocol, for example "https://vclouddirector.example.com".{{< /unsafe >}} |
| `allowInsecure` _boolean_ | {{< unsafe >}}If set to true, disables the TLS certificate check against the endpoint.{{< /unsafe >}} |
| `catalog` _string_ | {{< unsafe >}}The default catalog which contains the VM templates.{{< /unsafe >}} |
| `storageProfile` _string_ | {{< unsafe >}}The name of the storage profile to use for disks attached to the VMs.{{< /unsafe >}} |
| `templates` _[ImageList](#imagelist)_ | {{< unsafe >}}A list of VM templates to use for a given operating system. You must<br />define at least one template.{{< /unsafe >}} |


[Back to top](#top)



### DatacenterSpecVSphere



DatacenterSpecVSphere describes a vSphere datacenter.

_Appears in:_
- [DatacenterSpec](#datacenterspec)

| Field | Description |
| --- | --- |
| `endpoint` _string_ | {{< unsafe >}}Endpoint URL to use, including protocol, for example "https://vcenter.example.com".{{< /unsafe >}} |
| `allowInsecure` _boolean_ | {{< unsafe >}}If set to true, disables the TLS certificate check against the endpoint.{{< /unsafe >}} |
| `datastore` _string_ | {{< unsafe >}}The default Datastore to be used for provisioning volumes using storage<br />classes/dynamic provisioning and for storing virtual machine files in<br />case no `Datastore` or `DatastoreCluster` is provided at Cluster level.{{< /unsafe >}} |
| `datacenter` _string_ | {{< unsafe >}}The name of the datacenter to use.{{< /unsafe >}} |
| `cluster` _string_ | {{< unsafe >}}The name of the vSphere cluster to use. Used for out-of-tree CSI Driver.{{< /unsafe >}} |
| `storagePolicy` _string_ | {{< unsafe >}}The name of the storage policy to use for the storage class created in the user cluster.{{< /unsafe >}} |
| `rootPath` _string_ | {{< unsafe >}}Optional: The root path for cluster specific VM folders. Each cluster gets its own<br />folder below the root folder. Must be the FQDN (for example<br />"/datacenter-1/vm/all-kubermatic-vms-in-here") and defaults to the root VM<br />folder: "/datacenter-1/vm"{{< /unsafe >}} |
| `templates` _[ImageList](#imagelist)_ | {{< unsafe >}}A list of VM templates to use for a given operating system. You must<br />define at least one template.<br />See: https://github.com/kubermatic/machine-controller/blob/main/docs/vsphere.md#template-vms-preparation{{< /unsafe >}} |
| `infraManagementUser` _[VSphereCredentials](#vspherecredentials)_ | {{< unsafe >}}Optional: Infra management user is the user that will be used for everything<br />except the cloud provider functionality, which will still use the credentials<br />passed in via the Kubermatic dashboard/API.{{< /unsafe >}} |
| `ipv6Enabled` _boolean_ | {{< unsafe >}}Optional: defines if the IPv6 is enabled for the datacenter{{< /unsafe >}} |
| `defaultTagCategoryID` _string_ | {{< unsafe >}}DefaultTagCategoryID is the tag category id that will be used as default, if users don't specify it on a cluster level,<br />and they don't wish KKP to create default generated tag category, upon cluster creation.{{< /unsafe >}} |


[Back to top](#top)



### DefaultProjectResourceQuota



DefaultProjectResourceQuota contains the default resource quota which will be set for all
projects that do not have a custom quota already set.

_Appears in:_
- [SettingSpec](#settingspec)

| Field | Description |
| --- | --- |
| `quota` _[ResourceDetails](#resourcedetails)_ | {{< unsafe >}}Quota specifies the default CPU, Memory and Storage quantities for all the projects.{{< /unsafe >}} |


[Back to top](#top)



### DeploymentSettings





_Appears in:_
- [APIServerSettings](#apiserversettings)
- [ComponentSettings](#componentsettings)
- [ControllerSettings](#controllersettings)
- [OSMControllerSettings](#osmcontrollersettings)

| Field | Description |
| --- | --- |
| `replicas` _integer_ | {{< unsafe >}}{{< /unsafe >}} |
| `resources` _[ResourceRequirements](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#resourcerequirements-v1-core)_ | {{< unsafe >}}{{< /unsafe >}} |
| `tolerations` _[Toleration](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#toleration-v1-core) array_ | {{< unsafe >}}{{< /unsafe >}} |


[Back to top](#top)



### Digitalocean





_Appears in:_
- [PresetSpec](#presetspec)

| Field | Description |
| --- | --- |
| `enabled` _boolean_ | {{< unsafe >}}Only enabled presets will be available in the KKP dashboard.{{< /unsafe >}} |
| `isCustomizable` _boolean_ | {{< unsafe >}}IsCustomizable marks a preset as editable on the KKP UI; Customizable presets still have the credentials obscured on the UI, but other fields that are not considered private are displayed during cluster creation. Users can then update those fields, if required.<br />NOTE: This is only supported for OpenStack Cloud Provider in KKP 2.26. Support for other providers will be added later on.{{< /unsafe >}} |
| `datacenter` _string_ | {{< unsafe >}}If datacenter is set, this preset is only applicable to the<br />configured datacenter.{{< /unsafe >}} |
| `token` _string_ | {{< unsafe >}}Token is used to authenticate with the DigitalOcean API.{{< /unsafe >}} |


[Back to top](#top)



### DigitaloceanCloudSpec



DigitaloceanCloudSpec specifies access data to DigitalOcean.

_Appears in:_
- [CloudSpec](#cloudspec)

| Field | Description |
| --- | --- |
| `credentialsReference` _[GlobalSecretKeySelector](#globalsecretkeyselector)_ | {{< unsafe >}}{{< /unsafe >}} |
| `token` _string_ | {{< unsafe >}}Token is used to authenticate with the DigitalOcean API.{{< /unsafe >}} |


[Back to top](#top)



### EKS





_Appears in:_
- [PresetSpec](#presetspec)

| Field | Description |
| --- | --- |
| `enabled` _boolean_ | {{< unsafe >}}Only enabled presets will be available in the KKP dashboard.{{< /unsafe >}} |
| `isCustomizable` _boolean_ | {{< unsafe >}}IsCustomizable marks a preset as editable on the KKP UI; Customizable presets still have the credentials obscured on the UI, but other fields that are not considered private are displayed during cluster creation. Users can then update those fields, if required.<br />NOTE: This is only supported for OpenStack Cloud Provider in KKP 2.26. Support for other providers will be added later on.{{< /unsafe >}} |
| `datacenter` _string_ | {{< unsafe >}}If datacenter is set, this preset is only applicable to the<br />configured datacenter.{{< /unsafe >}} |
| `accessKeyID` _string_ | {{< unsafe >}}The Access key ID used to authenticate against AWS.{{< /unsafe >}} |
| `secretAccessKey` _string_ | {{< unsafe >}}The Secret Access Key used to authenticate against AWS.{{< /unsafe >}} |
| `assumeRoleARN` _string_ | {{< unsafe >}}Defines the ARN for an IAM role that should be assumed when handling resources on AWS. It will be used<br />to acquire temporary security credentials using an STS AssumeRole API operation whenever creating an AWS session.<br />required: false{{< /unsafe >}} |
| `assumeRoleExternalID` _string_ | {{< unsafe >}}An arbitrary string that may be needed when calling the STS AssumeRole API operation.<br />Using an external ID can help to prevent the "confused deputy problem".<br />required: false{{< /unsafe >}} |


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
| `enabled` _boolean_ | {{< unsafe >}}Enables encryption-at-rest on this cluster.{{< /unsafe >}} |
| `resources` _string array_ | {{< unsafe >}}List of resources that will be stored encrypted in etcd.{{< /unsafe >}} |
| `secretbox` _[SecretboxEncryptionConfiguration](#secretboxencryptionconfiguration)_ | {{< unsafe >}}Configuration for the `secretbox` static key encryption scheme as supported by Kubernetes.<br />More info: https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/#providers{{< /unsafe >}} |


[Back to top](#top)



### EnvoyLoadBalancerService





_Appears in:_
- [NodePortProxyComponentEnvoy](#nodeportproxycomponentenvoy)

| Field | Description |
| --- | --- |
| `annotations` _object (keys:string, values:string)_ | {{< unsafe >}}Annotations are used to further tweak the LoadBalancer integration with the<br />cloud provider.{{< /unsafe >}} |
| `sourceRanges` _[CIDR](#cidr) array_ | {{< unsafe >}}SourceRanges will restrict loadbalancer service to IP ranges specified using CIDR notation like 172.25.0.0/16.<br />This field will be ignored if the cloud-provider does not support the feature.<br />More info: https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/{{< /unsafe >}} |


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
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[EtcdBackupConfigSpec](#etcdbackupconfigspec)_ | {{< unsafe >}}Spec describes details of an Etcd backup.{{< /unsafe >}} |
| `status` _[EtcdBackupConfigStatus](#etcdbackupconfigstatus)_ | {{< unsafe >}}{{< /unsafe >}} |


[Back to top](#top)



### EtcdBackupConfigCondition





_Appears in:_
- [EtcdBackupConfigStatus](#etcdbackupconfigstatus)

| Field | Description |
| --- | --- |
| `status` _[ConditionStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#conditionstatus-v1-core)_ | {{< unsafe >}}Status of the condition, one of True, False, Unknown.{{< /unsafe >}} |
| `lastHeartbeatTime` _[Time](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#time-v1-meta)_ | {{< unsafe >}}Last time we got an update on a given condition.{{< /unsafe >}} |
| `lastTransitionTime` _[Time](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#time-v1-meta)_ | {{< unsafe >}}Last time the condition transit from one status to another.{{< /unsafe >}} |
| `reason` _string_ | {{< unsafe >}}(brief) reason for the condition's last transition.{{< /unsafe >}} |
| `message` _string_ | {{< unsafe >}}Human readable message indicating details about last transition.{{< /unsafe >}} |


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
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[EtcdBackupConfig](#etcdbackupconfig) array_ | {{< unsafe >}}Items is a list of EtcdBackupConfig objects.{{< /unsafe >}} |


[Back to top](#top)



### EtcdBackupConfigSpec



EtcdBackupConfigSpec specifies details of an etcd backup.

_Appears in:_
- [EtcdBackupConfig](#etcdbackupconfig)

| Field | Description |
| --- | --- |
| `name` _string_ | {{< unsafe >}}Name defines the name of the backup<br />The name of the backup file in S3 will be <cluster>-<backup name><br />If a schedule is set (see below), -<timestamp> will be appended.{{< /unsafe >}} |
| `cluster` _[ObjectReference](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#objectreference-v1-core)_ | {{< unsafe >}}Cluster is the reference to the cluster whose etcd will be backed up{{< /unsafe >}} |
| `schedule` _string_ | {{< unsafe >}}Schedule is a cron expression defining when to perform<br />the backup. If not set, the backup is performed exactly<br />once, immediately.{{< /unsafe >}} |
| `keep` _integer_ | {{< unsafe >}}Keep is the number of backups to keep around before deleting the oldest one<br />If not set, defaults to DefaultKeptBackupsCount. Only used if Schedule is set.{{< /unsafe >}} |
| `destination` _string_ | {{< unsafe >}}Destination indicates where the backup will be stored. The destination name must correspond to a destination in<br />the cluster's Seed.Spec.EtcdBackupRestore.{{< /unsafe >}} |


[Back to top](#top)



### EtcdBackupConfigStatus





_Appears in:_
- [EtcdBackupConfig](#etcdbackupconfig)

| Field | Description |
| --- | --- |
| `currentBackups` _[BackupStatus](#backupstatus) array_ | {{< unsafe >}}CurrentBackups tracks the creation and deletion progress of all backups managed by the EtcdBackupConfig{{< /unsafe >}} |
| `conditions` _object (keys:[EtcdBackupConfigConditionType](#etcdbackupconfigconditiontype), values:[EtcdBackupConfigCondition](#etcdbackupconfigcondition))_ | {{< unsafe >}}Conditions contains conditions of the EtcdBackupConfig{{< /unsafe >}} |
| `cleanupRunning` _boolean_ | {{< unsafe >}}If the controller was configured with a cleanupContainer, CleanupRunning keeps track of the corresponding job{{< /unsafe >}} |


[Back to top](#top)



### EtcdBackupRestore



EtcdBackupRestore holds the configuration of the automatic backup and restores.

_Appears in:_
- [SeedSpec](#seedspec)

| Field | Description |
| --- | --- |
| `destinations` _object (keys:string, values:[BackupDestination](#backupdestination))_ | {{< unsafe >}}Destinations stores all the possible destinations where the backups for the Seed can be stored. If not empty,<br />it enables automatic backup and restore for the seed.{{< /unsafe >}} |
| `defaultDestination` _string_ | {{< unsafe >}}DefaultDestination marks the default destination that will be used for the default etcd backup config which is<br />created for every user cluster. Has to correspond to a destination in Destinations.<br />If removed, it removes the related default etcd backup configs.{{< /unsafe >}} |
| `backupInterval` _[Duration](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#duration-v1-meta)_ | {{< unsafe >}}BackupInterval defines the time duration between consecutive etcd backups.<br />Must be a valid time.Duration string format. Only takes effect when backup scheduling is enabled.{{< /unsafe >}} |
| `backupCount` _integer_ | {{< unsafe >}}BackupCount specifies the maximum number of backups to retain (defaults to DefaultKeptBackupsCount).<br />Oldest backups are automatically deleted when this limit is exceeded. Only applies when Schedule is configured.{{< /unsafe >}} |


[Back to top](#top)



### EtcdRestore



EtcdRestore specifies an add-on.

_Appears in:_
- [EtcdRestoreList](#etcdrestorelist)

| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `EtcdRestore`
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[EtcdRestoreSpec](#etcdrestorespec)_ | {{< unsafe >}}Spec describes details of an etcd restore.{{< /unsafe >}} |
| `status` _[EtcdRestoreStatus](#etcdrestorestatus)_ | {{< unsafe >}}{{< /unsafe >}} |


[Back to top](#top)



### EtcdRestoreList



EtcdRestoreList is a list of etcd restores.



| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `EtcdRestoreList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[EtcdRestore](#etcdrestore) array_ | {{< unsafe >}}Items is the list of the Etcd restores.{{< /unsafe >}} |


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
| `name` _string_ | {{< unsafe >}}Name defines the name of the restore<br />The name of the restore file in S3 will be <cluster>-<restore name><br />If a schedule is set (see below), -<timestamp> will be appended.{{< /unsafe >}} |
| `cluster` _[ObjectReference](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#objectreference-v1-core)_ | {{< unsafe >}}Cluster is the reference to the cluster whose etcd will be backed up{{< /unsafe >}} |
| `backupName` _string_ | {{< unsafe >}}BackupName is the name of the backup to restore from{{< /unsafe >}} |
| `backupDownloadCredentialsSecret` _string_ | {{< unsafe >}}BackupDownloadCredentialsSecret is the name of a secret in the cluster-xxx namespace containing<br />credentials needed to download the backup{{< /unsafe >}} |
| `destination` _string_ | {{< unsafe >}}Destination indicates where the backup was stored. The destination name should correspond to a destination in<br />the cluster's Seed.Spec.EtcdBackupRestore. If empty, it will use the legacy destination configured in Seed.Spec.BackupRestore{{< /unsafe >}} |


[Back to top](#top)



### EtcdRestoreStatus





_Appears in:_
- [EtcdRestore](#etcdrestore)

| Field | Description |
| --- | --- |
| `phase` _[EtcdRestorePhase](#etcdrestorephase)_ | {{< unsafe >}}{{< /unsafe >}} |
| `restoreTime` _[Time](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#time-v1-meta)_ | {{< unsafe >}}{{< /unsafe >}} |


[Back to top](#top)



### EtcdStatefulSetSettings





_Appears in:_
- [ComponentSettings](#componentsettings)

| Field | Description |
| --- | --- |
| `clusterSize` _integer_ | {{< unsafe >}}ClusterSize is the number of replicas created for etcd. This should be an<br />odd number to guarantee consensus, e.g. 3, 5 or 7.{{< /unsafe >}} |
| `storageClass` _string_ | {{< unsafe >}}StorageClass is the Kubernetes StorageClass used for persistent storage<br />which stores the etcd WAL and other data persisted across restarts. Defaults to<br />`kubermatic-fast` (the global default).{{< /unsafe >}} |
| `resources` _[ResourceRequirements](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#resourcerequirements-v1-core)_ | {{< unsafe >}}Resources allows to override the resource requirements for etcd Pods.{{< /unsafe >}} |
| `tolerations` _[Toleration](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#toleration-v1-core) array_ | {{< unsafe >}}Tolerations allows to override the scheduling tolerations for etcd Pods.{{< /unsafe >}} |
| `hostAntiAffinity` _[AntiAffinityType](#antiaffinitytype)_ | {{< unsafe >}}HostAntiAffinity allows to enforce a certain type of host anti-affinity on etcd<br />pods. Options are "preferred" (default) and "required". Please note that<br />enforcing anti-affinity via "required" can mean that pods are never scheduled.{{< /unsafe >}} |
| `zoneAntiAffinity` _[AntiAffinityType](#antiaffinitytype)_ | {{< unsafe >}}ZoneAntiAffinity allows to enforce a certain type of availability zone anti-affinity on etcd<br />pods. Options are "preferred" (default) and "required". Please note that<br />enforcing anti-affinity via "required" can mean that pods are never scheduled.{{< /unsafe >}} |
| `nodeSelector` _object (keys:string, values:string)_ | {{< unsafe >}}NodeSelector is a selector which restricts the set of nodes where etcd Pods can run.{{< /unsafe >}} |
| `quotaBackendGb` _integer_ | {{< unsafe >}}QuotaBackendGB is the maximum backend size of etcd in GB (0 means use etcd default).<br /><br />For more details, please see https://etcd.io/docs/v3.5/op-guide/maintenance/{{< /unsafe >}} |


[Back to top](#top)



### EventRateLimitConfig



EventRateLimitConfig configures the `EventRateLimit` admission plugin.
More info: https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#eventratelimit

_Appears in:_
- [ClusterSpec](#clusterspec)

| Field | Description |
| --- | --- |
| `server` _[EventRateLimitConfigItem](#eventratelimitconfigitem)_ | {{< unsafe >}}{{< /unsafe >}} |
| `namespace` _[EventRateLimitConfigItem](#eventratelimitconfigitem)_ | {{< unsafe >}}{{< /unsafe >}} |
| `user` _[EventRateLimitConfigItem](#eventratelimitconfigitem)_ | {{< unsafe >}}{{< /unsafe >}} |
| `sourceAndObject` _[EventRateLimitConfigItem](#eventratelimitconfigitem)_ | {{< unsafe >}}{{< /unsafe >}} |


[Back to top](#top)



### EventRateLimitConfigItem





_Appears in:_
- [EventRateLimitConfig](#eventratelimitconfig)

| Field | Description |
| --- | --- |
| `qps` _integer_ | {{< unsafe >}}{{< /unsafe >}} |
| `burst` _integer_ | {{< unsafe >}}{{< /unsafe >}} |
| `cacheSize` _integer_ | {{< unsafe >}}{{< /unsafe >}} |


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
| `apiserver` _[HealthStatus](#healthstatus)_ | {{< unsafe >}}{{< /unsafe >}} |
| `scheduler` _[HealthStatus](#healthstatus)_ | {{< unsafe >}}{{< /unsafe >}} |
| `controller` _[HealthStatus](#healthstatus)_ | {{< unsafe >}}{{< /unsafe >}} |
| `machineController` _[HealthStatus](#healthstatus)_ | {{< unsafe >}}{{< /unsafe >}} |
| `etcd` _[HealthStatus](#healthstatus)_ | {{< unsafe >}}{{< /unsafe >}} |
| `openvpn` _[HealthStatus](#healthstatus)_ | {{< unsafe >}} Deprecated: OpenVPN will be removed entirely in the future.{{< /unsafe >}} |
| `konnectivity` _[HealthStatus](#healthstatus)_ | {{< unsafe >}}{{< /unsafe >}} |
| `cloudProviderInfrastructure` _[HealthStatus](#healthstatus)_ | {{< unsafe >}}{{< /unsafe >}} |
| `userClusterControllerManager` _[HealthStatus](#healthstatus)_ | {{< unsafe >}}{{< /unsafe >}} |
| `applicationController` _[HealthStatus](#healthstatus)_ | {{< unsafe >}}{{< /unsafe >}} |
| `gatekeeperController` _[HealthStatus](#healthstatus)_ | {{< unsafe >}}{{< /unsafe >}} |
| `gatekeeperAudit` _[HealthStatus](#healthstatus)_ | {{< unsafe >}}{{< /unsafe >}} |
| `monitoring` _[HealthStatus](#healthstatus)_ | {{< unsafe >}}{{< /unsafe >}} |
| `logging` _[HealthStatus](#healthstatus)_ | {{< unsafe >}}{{< /unsafe >}} |
| `alertmanagerConfig` _[HealthStatus](#healthstatus)_ | {{< unsafe >}}{{< /unsafe >}} |
| `mlaGateway` _[HealthStatus](#healthstatus)_ | {{< unsafe >}}{{< /unsafe >}} |
| `operatingSystemManager` _[HealthStatus](#healthstatus)_ | {{< unsafe >}}{{< /unsafe >}} |
| `kubernetesDashboard` _[HealthStatus](#healthstatus)_ | {{< unsafe >}}{{< /unsafe >}} |
| `kubelb` _[HealthStatus](#healthstatus)_ | {{< unsafe >}}{{< /unsafe >}} |


[Back to top](#top)



### ExternalCluster



ExternalCluster is the object representing an external kubernetes cluster.

_Appears in:_
- [ExternalClusterList](#externalclusterlist)

| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `ExternalCluster`
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[ExternalClusterSpec](#externalclusterspec)_ | {{< unsafe >}}Spec describes the desired cluster state.{{< /unsafe >}} |
| `status` _[ExternalClusterStatus](#externalclusterstatus)_ | {{< unsafe >}}Status contains reconciliation information for the cluster.{{< /unsafe >}} |


[Back to top](#top)



### ExternalClusterAKSCloudSpec





_Appears in:_
- [ExternalClusterCloudSpec](#externalclustercloudspec)

| Field | Description |
| --- | --- |
| `credentialsReference` _[GlobalSecretKeySelector](#globalsecretkeyselector)_ | {{< unsafe >}}CredentialsReference allows referencing a `Secret` resource instead of passing secret data in this spec.{{< /unsafe >}} |
| `name` _string_ | {{< unsafe >}}{{< /unsafe >}} |
| `tenantID` _string_ | {{< unsafe >}}The Azure Active Directory Tenant used for this cluster.<br />Can be read from `credentialsReference` instead.{{< /unsafe >}} |
| `subscriptionID` _string_ | {{< unsafe >}}The Azure Subscription used for this cluster.<br />Can be read from `credentialsReference` instead.{{< /unsafe >}} |
| `clientID` _string_ | {{< unsafe >}}The service principal used to access Azure.<br />Can be read from `credentialsReference` instead.{{< /unsafe >}} |
| `clientSecret` _string_ | {{< unsafe >}}The client secret corresponding to the given service principal.<br />Can be read from `credentialsReference` instead.{{< /unsafe >}} |
| `location` _string_ | {{< unsafe >}}The geo-location where the resource lives{{< /unsafe >}} |
| `resourceGroup` _string_ | {{< unsafe >}}The resource group that will be used to look up and create resources for the cluster in.<br />If set to empty string at cluster creation, a new resource group will be created and this field will be updated to<br />the generated resource group's name.{{< /unsafe >}} |


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
| `providerName` _[ExternalClusterProvider](#externalclusterprovider)_ | {{< unsafe >}}{{< /unsafe >}} |
| `gke` _[ExternalClusterGKECloudSpec](#externalclustergkecloudspec)_ | {{< unsafe >}}{{< /unsafe >}} |
| `eks` _[ExternalClusterEKSCloudSpec](#externalclusterekscloudspec)_ | {{< unsafe >}}{{< /unsafe >}} |
| `aks` _[ExternalClusterAKSCloudSpec](#externalclusterakscloudspec)_ | {{< unsafe >}}{{< /unsafe >}} |
| `kubeone` _[ExternalClusterKubeOneCloudSpec](#externalclusterkubeonecloudspec)_ | {{< unsafe >}}{{< /unsafe >}} |
| `bringyourown` _[ExternalClusterBringYourOwnCloudSpec](#externalclusterbringyourowncloudspec)_ | {{< unsafe >}}{{< /unsafe >}} |


[Back to top](#top)



### ExternalClusterCondition





_Appears in:_
- [ExternalClusterStatus](#externalclusterstatus)

| Field | Description |
| --- | --- |
| `phase` _[ExternalClusterPhase](#externalclusterphase)_ | {{< unsafe >}}{{< /unsafe >}} |
| `message` _string_ | {{< unsafe >}}Human readable message indicating details about last transition.{{< /unsafe >}} |


[Back to top](#top)



### ExternalClusterEKSCloudSpec





_Appears in:_
- [ExternalClusterCloudSpec](#externalclustercloudspec)

| Field | Description |
| --- | --- |
| `credentialsReference` _[GlobalSecretKeySelector](#globalsecretkeyselector)_ | {{< unsafe >}}{{< /unsafe >}} |
| `name` _string_ | {{< unsafe >}}{{< /unsafe >}} |
| `accessKeyID` _string_ | {{< unsafe >}}The Access key ID used to authenticate against AWS.<br />Can be read from `credentialsReference` instead.{{< /unsafe >}} |
| `secretAccessKey` _string_ | {{< unsafe >}}The Secret Access Key used to authenticate against AWS.<br />Can be read from `credentialsReference` instead.{{< /unsafe >}} |
| `region` _string_ | {{< unsafe >}}{{< /unsafe >}} |
| `roleArn` _string_ | {{< unsafe >}}The Amazon Resource Name (ARN) of the IAM role that provides permissions<br />for the Kubernetes control plane to make calls to Amazon Web Services API<br />operations on your behalf.{{< /unsafe >}} |
| `vpcID` _string_ | {{< unsafe >}}The VPC associated with your cluster.{{< /unsafe >}} |
| `subnetIDs` _string array_ | {{< unsafe >}}The subnets associated with your cluster.{{< /unsafe >}} |
| `securityGroupIDs` _string array_ | {{< unsafe >}}The security groups associated with the cross-account elastic network interfaces<br />that are used to allow communication between your nodes and the Kubernetes<br />control plane.{{< /unsafe >}} |
| `assumeRoleARN` _string_ | {{< unsafe >}}The ARN for an IAM role that should be assumed when handling resources on AWS. It will be used<br />to acquire temporary security credentials using an STS AssumeRole API operation whenever creating an AWS session.<br />required: false{{< /unsafe >}} |
| `assumeRoleExternalID` _string_ | {{< unsafe >}}An arbitrary string that may be needed when calling the STS AssumeRole API operation.<br />Using an external ID can help to prevent the "confused deputy problem".<br />required: false{{< /unsafe >}} |


[Back to top](#top)



### ExternalClusterGKECloudSpec





_Appears in:_
- [ExternalClusterCloudSpec](#externalclustercloudspec)

| Field | Description |
| --- | --- |
| `credentialsReference` _[GlobalSecretKeySelector](#globalsecretkeyselector)_ | {{< unsafe >}}{{< /unsafe >}} |
| `name` _string_ | {{< unsafe >}}{{< /unsafe >}} |
| `serviceAccount` _string_ | {{< unsafe >}}ServiceAccount: The Google Cloud Platform Service Account.<br />Can be read from `credentialsReference` instead.{{< /unsafe >}} |
| `zone` _string_ | {{< unsafe >}}Zone: The name of the Google Compute Engine zone<br />(https://cloud.google.com/compute/docs/zones#available) in which the<br />cluster resides.{{< /unsafe >}} |


[Back to top](#top)



### ExternalClusterKubeOneCloudSpec





_Appears in:_
- [ExternalClusterCloudSpec](#externalclustercloudspec)

| Field | Description |
| --- | --- |
| `providerName` _string_ | {{< unsafe >}}The name of the cloud provider used, one of<br />"aws", "azure", "digitalocean", "gcp",<br />"hetzner", "nutanix", "openstack", "packet", "vsphere" KubeOne natively-supported providers{{< /unsafe >}} |
| `region` _string_ | {{< unsafe >}}The cloud provider region in which the cluster resides.<br />This field is used only to display information.{{< /unsafe >}} |
| `credentialsReference` _[GlobalSecretKeySelector](#globalsecretkeyselector)_ | {{< unsafe >}}{{< /unsafe >}} |
| `sshReference` _[GlobalSecretKeySelector](#globalsecretkeyselector)_ | {{< unsafe >}}{{< /unsafe >}} |
| `manifestReference` _[GlobalSecretKeySelector](#globalsecretkeyselector)_ | {{< unsafe >}}{{< /unsafe >}} |


[Back to top](#top)



### ExternalClusterList



ExternalClusterList specifies a list of external kubernetes clusters.



| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `ExternalClusterList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[ExternalCluster](#externalcluster) array_ | {{< unsafe >}}Items holds the list of the External Kubernetes cluster.{{< /unsafe >}} |


[Back to top](#top)



### ExternalClusterNetworkRanges



ExternalClusterNetworkRanges represents ranges of network addresses.

_Appears in:_
- [ExternalClusterNetworkingConfig](#externalclusternetworkingconfig)

| Field | Description |
| --- | --- |
| `cidrBlocks` _string array_ | {{< unsafe >}}{{< /unsafe >}} |


[Back to top](#top)



### ExternalClusterNetworkingConfig



ExternalClusterNetworkingConfig specifies the different networking
parameters for an external cluster.

_Appears in:_
- [ExternalClusterSpec](#externalclusterspec)

| Field | Description |
| --- | --- |
| `services` _[ExternalClusterNetworkRanges](#externalclusternetworkranges)_ | {{< unsafe >}}The network ranges from which service VIPs are allocated.<br />It can contain one IPv4 and/or one IPv6 CIDR.<br />If both address families are specified, the first one defines the primary address family.{{< /unsafe >}} |
| `pods` _[ExternalClusterNetworkRanges](#externalclusternetworkranges)_ | {{< unsafe >}}The network ranges from which POD networks are allocated.<br />It can contain one IPv4 and/or one IPv6 CIDR.<br />If both address families are specified, the first one defines the primary address family.{{< /unsafe >}} |


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
| `versions` _[Semver](#semver) array_ | {{< unsafe >}}Versions lists the available versions.{{< /unsafe >}} |
| `default` _[Semver](#semver)_ | {{< unsafe >}}Default is the default version to offer users.{{< /unsafe >}} |
| `updates` _[Semver](#semver) array_ | {{< unsafe >}}Updates is a list of available upgrades.{{< /unsafe >}} |


[Back to top](#top)



### ExternalClusterSpec



ExternalClusterSpec specifies the data for a new external kubernetes cluster.

_Appears in:_
- [ExternalCluster](#externalcluster)

| Field | Description |
| --- | --- |
| `humanReadableName` _string_ | {{< unsafe >}}HumanReadableName is the cluster name provided by the user{{< /unsafe >}} |
| `kubeconfigReference` _[GlobalSecretKeySelector](#globalsecretkeyselector)_ | {{< unsafe >}}Reference to cluster Kubeconfig{{< /unsafe >}} |
| `version` _[Semver](#semver)_ | {{< unsafe >}}Defines the wanted version of the control plane.{{< /unsafe >}} |
| `cloudSpec` _[ExternalClusterCloudSpec](#externalclustercloudspec)_ | {{< unsafe >}}CloudSpec contains provider specific fields{{< /unsafe >}} |
| `clusterNetwork` _[ExternalClusterNetworkingConfig](#externalclusternetworkingconfig)_ | {{< unsafe >}}ClusterNetwork contains the different networking parameters for an external cluster.{{< /unsafe >}} |
| `containerRuntime` _string_ | {{< unsafe >}}ContainerRuntime to use, i.e. `docker` or `containerd`.{{< /unsafe >}} |
| `pause` _boolean_ | {{< unsafe >}}If this is set to true, the cluster will not be reconciled by KKP.<br />This indicates that the user needs to do some action to resolve the pause.{{< /unsafe >}} |
| `pauseReason` _string_ | {{< unsafe >}}PauseReason is the reason why the cluster is not being managed. This field is for informational<br />purpose only and can be set by a user or a controller to communicate the reason for pausing the cluster.{{< /unsafe >}} |


[Back to top](#top)



### ExternalClusterStatus



ExternalClusterStatus denotes status information about an ExternalCluster.

_Appears in:_
- [ExternalCluster](#externalcluster)

| Field | Description |
| --- | --- |
| `condition` _[ExternalClusterCondition](#externalclustercondition)_ | {{< unsafe >}}Conditions contains conditions an externalcluster is in, its primary use case is status signaling for controller{{< /unsafe >}} |


[Back to top](#top)





### GCP





_Appears in:_
- [PresetSpec](#presetspec)

| Field | Description |
| --- | --- |
| `enabled` _boolean_ | {{< unsafe >}}Only enabled presets will be available in the KKP dashboard.{{< /unsafe >}} |
| `isCustomizable` _boolean_ | {{< unsafe >}}IsCustomizable marks a preset as editable on the KKP UI; Customizable presets still have the credentials obscured on the UI, but other fields that are not considered private are displayed during cluster creation. Users can then update those fields, if required.<br />NOTE: This is only supported for OpenStack Cloud Provider in KKP 2.26. Support for other providers will be added later on.{{< /unsafe >}} |
| `datacenter` _string_ | {{< unsafe >}}If datacenter is set, this preset is only applicable to the<br />configured datacenter.{{< /unsafe >}} |
| `serviceAccount` _string_ | {{< unsafe >}}ServiceAccount is the Google Service Account (JSON format), encoded with base64.{{< /unsafe >}} |
| `network` _string_ | {{< unsafe >}}{{< /unsafe >}} |
| `subnetwork` _string_ | {{< unsafe >}}{{< /unsafe >}} |


[Back to top](#top)



### GCPCloudSpec



GCPCloudSpec specifies access data to GCP.

_Appears in:_
- [CloudSpec](#cloudspec)

| Field | Description |
| --- | --- |
| `credentialsReference` _[GlobalSecretKeySelector](#globalsecretkeyselector)_ | {{< unsafe >}}{{< /unsafe >}} |
| `serviceAccount` _string_ | {{< unsafe >}}The Google Service Account (JSON format), encoded with base64.{{< /unsafe >}} |
| `network` _string_ | {{< unsafe >}}{{< /unsafe >}} |
| `subnetwork` _string_ | {{< unsafe >}}{{< /unsafe >}} |
| `nodePortsAllowedIPRange` _string_ | {{< unsafe >}}A CIDR range that will be used to allow access to the node port range in the firewall rules to.<br />If NodePortsAllowedIPRange nor NodePortsAllowedIPRanges is set, the node port range can be accessed from anywhere.{{< /unsafe >}} |
| `nodePortsAllowedIPRanges` _[NetworkRanges](#networkranges)_ | {{< unsafe >}}Optional: CIDR ranges that will be used to allow access to the node port range in the firewall rules to.<br />If NodePortsAllowedIPRange nor NodePortsAllowedIPRanges is set,  the node port range can be accessed from anywhere.{{< /unsafe >}} |


[Back to top](#top)



### GKE





_Appears in:_
- [PresetSpec](#presetspec)

| Field | Description |
| --- | --- |
| `enabled` _boolean_ | {{< unsafe >}}Only enabled presets will be available in the KKP dashboard.{{< /unsafe >}} |
| `isCustomizable` _boolean_ | {{< unsafe >}}IsCustomizable marks a preset as editable on the KKP UI; Customizable presets still have the credentials obscured on the UI, but other fields that are not considered private are displayed during cluster creation. Users can then update those fields, if required.<br />NOTE: This is only supported for OpenStack Cloud Provider in KKP 2.26. Support for other providers will be added later on.{{< /unsafe >}} |
| `datacenter` _string_ | {{< unsafe >}}If datacenter is set, this preset is only applicable to the<br />configured datacenter.{{< /unsafe >}} |
| `serviceAccount` _string_ | {{< unsafe >}}{{< /unsafe >}} |


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
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[GroupProjectBindingSpec](#groupprojectbindingspec)_ | {{< unsafe >}}Spec describes an oidc group binding to a project.{{< /unsafe >}} |


[Back to top](#top)



### GroupProjectBindingList



GroupProjectBindingList is a list of group project bindings.



| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `GroupProjectBindingList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[GroupProjectBinding](#groupprojectbinding) array_ | {{< unsafe >}}Items holds the list of the group and project bindings.{{< /unsafe >}} |


[Back to top](#top)



### GroupProjectBindingSpec



GroupProjectBindingSpec specifies an oidc group binding to a project.

_Appears in:_
- [GroupProjectBinding](#groupprojectbinding)

| Field | Description |
| --- | --- |
| `group` _string_ | {{< unsafe >}}Group is the group name that is bound to the given project.{{< /unsafe >}} |
| `projectID` _string_ | {{< unsafe >}}ProjectID is the ID of the target project.<br />Should be a valid lowercase RFC1123 domain name{{< /unsafe >}} |
| `role` _string_ | {{< unsafe >}}Role is the user's role within the project, determining their permissions.<br />Possible roles are:<br />"viewers" - allowed to get/list project resources<br />"editors" - allowed to edit all project resources<br />"owners" - same as editors, but also can manage users in the project{{< /unsafe >}} |


[Back to top](#top)



### GroupVersionKind



GroupVersionKind unambiguously identifies a kind. It doesn't anonymously include GroupVersion
to avoid automatic coercion. It doesn't use a GroupVersion to avoid custom marshalling.

_Appears in:_
- [AddonSpec](#addonspec)

| Field | Description |
| --- | --- |
| `group` _string_ | {{< unsafe >}}{{< /unsafe >}} |
| `version` _string_ | {{< unsafe >}}{{< /unsafe >}} |


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
| `enabled` _boolean_ | {{< unsafe >}}Only enabled presets will be available in the KKP dashboard.{{< /unsafe >}} |
| `isCustomizable` _boolean_ | {{< unsafe >}}IsCustomizable marks a preset as editable on the KKP UI; Customizable presets still have the credentials obscured on the UI, but other fields that are not considered private are displayed during cluster creation. Users can then update those fields, if required.<br />NOTE: This is only supported for OpenStack Cloud Provider in KKP 2.26. Support for other providers will be added later on.{{< /unsafe >}} |
| `datacenter` _string_ | {{< unsafe >}}If datacenter is set, this preset is only applicable to the<br />configured datacenter.{{< /unsafe >}} |
| `token` _string_ | {{< unsafe >}}Token is used to authenticate with the Hetzner API.{{< /unsafe >}} |
| `network` _string_ | {{< unsafe >}}Network is the pre-existing Hetzner network in which the machines are running.<br />While machines can be in multiple networks, a single one must be chosen for the<br />HCloud CCM to work.<br />If this is empty, the network configured on the datacenter will be used.{{< /unsafe >}} |


[Back to top](#top)



### HetznerCloudSpec



HetznerCloudSpec specifies access data to hetzner cloud.

_Appears in:_
- [CloudSpec](#cloudspec)

| Field | Description |
| --- | --- |
| `credentialsReference` _[GlobalSecretKeySelector](#globalsecretkeyselector)_ | {{< unsafe >}}{{< /unsafe >}} |
| `token` _string_ | {{< unsafe >}}Token is used to authenticate with the Hetzner cloud API.{{< /unsafe >}} |
| `network` _string_ | {{< unsafe >}}Network is the pre-existing Hetzner network in which the machines are running.<br />While machines can be in multiple networks, a single one must be chosen for the<br />HCloud CCM to work.<br />If this is empty, the network configured on the datacenter will be used.{{< /unsafe >}} |


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
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[IPAMAllocationSpec](#ipamallocationspec)_ | {{< unsafe >}}{{< /unsafe >}} |


[Back to top](#top)



### IPAMAllocationList







| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `IPAMAllocationList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[IPAMAllocation](#ipamallocation) array_ | {{< unsafe >}}{{< /unsafe >}} |


[Back to top](#top)



### IPAMAllocationSpec



IPAMAllocationSpec specifies an allocation from an IPAMPool
made for a particular KKP user cluster.

_Appears in:_
- [IPAMAllocation](#ipamallocation)

| Field | Description |
| --- | --- |
| `type` _[IPAMPoolAllocationType](#ipampoolallocationtype)_ | {{< unsafe >}}Type is the allocation type that is being used.{{< /unsafe >}} |
| `dc` _string_ | {{< unsafe >}}DC is the datacenter of the allocation.{{< /unsafe >}} |
| `cidr` _[SubnetCIDR](#subnetcidr)_ | {{< unsafe >}}CIDR is the CIDR that is being used for the allocation.<br />Set when "type=prefix".{{< /unsafe >}} |
| `addresses` _string array_ | {{< unsafe >}}Addresses are the IP address ranges that are being used for the allocation.<br />Set when "type=range".{{< /unsafe >}} |


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
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[IPAMPoolSpec](#ipampoolspec)_ | {{< unsafe >}}Spec describes the Multi-Cluster IP Address Management (IPAM) configuration for KKP user clusters.{{< /unsafe >}} |


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
| `type` _[IPAMPoolAllocationType](#ipampoolallocationtype)_ | {{< unsafe >}}Type is the allocation type to be used.{{< /unsafe >}} |
| `poolCidr` _[SubnetCIDR](#subnetcidr)_ | {{< unsafe >}}PoolCIDR is the pool CIDR to be used for the allocation.{{< /unsafe >}} |
| `allocationPrefix` _integer_ | {{< unsafe >}}AllocationPrefix is the prefix for the allocation.<br />Used when "type=prefix".{{< /unsafe >}} |
| `excludePrefixes` _[SubnetCIDR](#subnetcidr) array_ | {{< unsafe >}}Optional: ExcludePrefixes is used to exclude particular subnets for the allocation.<br />NOTE: must be the same length as allocationPrefix.<br />Can be used when "type=prefix".{{< /unsafe >}} |
| `allocationRange` _integer_ | {{< unsafe >}}AllocationRange is the range for the allocation.<br />Used when "type=range".{{< /unsafe >}} |
| `excludeRanges` _string array_ | {{< unsafe >}}Optional: ExcludeRanges is used to exclude particular IPs or IP ranges for the allocation.<br />Examples: "192.168.1.100-192.168.1.110", "192.168.1.255".<br />Can be used when "type=range".{{< /unsafe >}} |


[Back to top](#top)



### IPAMPoolList



IPAMPoolList is the list of the object representing Multi-Cluster IP Address Management (IPAM)
configuration for KKP user clusters.



| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `IPAMPoolList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[IPAMPool](#ipampool) array_ | {{< unsafe >}}Items holds the list of IPAM pool objects.{{< /unsafe >}} |


[Back to top](#top)



### IPAMPoolSpec



IPAMPoolSpec specifies the  Multi-Cluster IP Address Management (IPAM)
configuration for KKP user clusters.

_Appears in:_
- [IPAMPool](#ipampool)

| Field | Description |
| --- | --- |
| `datacenters` _object (keys:string, values:[IPAMPoolDatacenterSettings](#ipampooldatacentersettings))_ | {{< unsafe >}}Datacenters contains a map of datacenters (DCs) for the allocation.{{< /unsafe >}} |


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
| `strictArp` _boolean_ | {{< unsafe >}}StrictArp configure arp_ignore and arp_announce to avoid answering ARP queries from kube-ipvs0 interface.<br />defaults to true.{{< /unsafe >}} |


[Back to top](#top)



### ImageList

_Underlying type:_ `OperatingSystem]string`

ImageList defines a map of operating system and the image to use.

_Appears in:_
- [DatacenterSpecAWS](#datacenterspecaws)
- [DatacenterSpecAzure](#datacenterspecazure)
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
| `provider` _string_ | {{< unsafe >}}Provider to which to apply the compatibility check.<br />Empty string matches all providers{{< /unsafe >}} |
| `version` _string_ | {{< unsafe >}}Version is the Kubernetes version that must be checked. Wildcards are allowed, e.g. "1.25.*".{{< /unsafe >}} |
| `condition` _[ConditionType](#conditiontype)_ | {{< unsafe >}}Condition is the cluster or datacenter condition that must be met to block a specific version{{< /unsafe >}} |
| `operation` _[OperationType](#operationtype)_ | {{< unsafe >}}Operation is the operation triggering the compatibility check (CREATE or UPDATE){{< /unsafe >}} |


[Back to top](#top)



### Kind



Kind specifies the resource Kind and APIGroup.

_Appears in:_
- [Match](#match)

| Field | Description |
| --- | --- |
| `kinds` _string array_ | {{< unsafe >}}Kinds specifies the kinds of the resources{{< /unsafe >}} |
| `apiGroups` _string array_ | {{< unsafe >}}APIGroups specifies the APIGroups of the resources{{< /unsafe >}} |


[Back to top](#top)



### KonnectivityProxySettings





_Appears in:_
- [ComponentSettings](#componentsettings)

| Field | Description |
| --- | --- |
| `resources` _[ResourceRequirements](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#resourcerequirements-v1-core)_ | {{< unsafe >}}Resources configure limits/requests for Konnectivity components.{{< /unsafe >}} |
| `keepaliveTime` _string_ | {{< unsafe >}}KeepaliveTime represents a duration of time to check if the transport is still alive.<br />The option is propagated to agents and server.<br />Defaults to 1m.{{< /unsafe >}} |
| `args` _string array_ | {{< unsafe >}}Args configures arguments (flags) for the Konnectivity deployments.{{< /unsafe >}} |


[Back to top](#top)



### KubeLB



KubeLB contains settings for the kubeLB component as part of the cluster control plane. This component is responsible for managing load balancers.
Only available in Enterprise Edition.

_Appears in:_
- [ClusterSpec](#clusterspec)

| Field | Description |
| --- | --- |
| `enabled` _boolean_ | {{< unsafe >}}Controls whether kubeLB is deployed or not.{{< /unsafe >}} |
| `useLoadBalancerClass` _boolean_ | {{< unsafe >}}UseLoadBalancerClass is used to configure the use of load balancer class `kubelb` for kubeLB. If false, kubeLB will manage all load balancers in the<br />user cluster irrespective of the load balancer class.{{< /unsafe >}} |
| `enableGatewayAPI` _boolean_ | {{< unsafe >}}EnableGatewayAPI is used to enable Gateway API for KubeLB. Once enabled, KKP installs the Gateway API CRDs for the user cluster.{{< /unsafe >}} |
| `extraArgs` _object (keys:string, values:string)_ | {{< unsafe >}}ExtraArgs are additional arbitrary flags to pass to the kubeLB CCM for the user cluster.{{< /unsafe >}} |


[Back to top](#top)



### KubeLBDatacenterSettings





_Appears in:_
- [DatacenterSpec](#datacenterspec)

| Field | Description |
| --- | --- |
| `kubeconfig` _[ObjectReference](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#objectreference-v1-core)_ | {{< unsafe >}}Kubeconfig is reference to the Kubeconfig for the kubeLB management cluster.{{< /unsafe >}} |
| `enabled` _boolean_ | {{< unsafe >}}Enabled is used to enable/disable kubeLB for the datacenter. This is used to control whether installing kubeLB is allowed or not for the datacenter.{{< /unsafe >}} |
| `enforced` _boolean_ | {{< unsafe >}}Enforced is used to enforce kubeLB installation for all the user clusters belonging to this datacenter. Setting enforced to false will not uninstall kubeLB from the user clusters and it needs to be disabled manually.{{< /unsafe >}} |
| `nodeAddressType` _string_ | {{< unsafe >}}NodeAddressType is used to configure the address type from node, used for load balancing.<br />Optional: Defaults to ExternalIP.{{< /unsafe >}} |
| `useLoadBalancerClass` _boolean_ | {{< unsafe >}}UseLoadBalancerClass is used to configure the use of load balancer class `kubelb` for kubeLB. If false, kubeLB will manage all load balancers in the<br />user cluster irrespective of the load balancer class.{{< /unsafe >}} |
| `enableGatewayAPI` _boolean_ | {{< unsafe >}}EnableGatewayAPI is used to configure the use of gateway API for kubeLB.<br />When this option is enabled for the user cluster, KKP installs the Gateway API CRDs for the user cluster.{{< /unsafe >}} |
| `enableSecretSynchronizer` _boolean_ | {{< unsafe >}}EnableSecretSynchronizer is used to configure the use of secret synchronizer for kubeLB.{{< /unsafe >}} |
| `disableIngressClass` _boolean_ | {{< unsafe >}}DisableIngressClass is used to disable the ingress class `kubelb` filter for kubeLB.{{< /unsafe >}} |
| `extraArgs` _object (keys:string, values:string)_ | {{< unsafe >}}ExtraArgs are additional arbitrary flags to pass to the kubeLB CCM for the user cluster. These args are propagated to all the user clusters unless overridden at a cluster level.{{< /unsafe >}} |


[Back to top](#top)



### KubeLBSeedSettings





_Appears in:_
- [SeedSpec](#seedspec)

| Field | Description |
| --- | --- |
| `kubeconfig` _[ObjectReference](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#objectreference-v1-core)_ | {{< unsafe >}}Kubeconfig is reference to the Kubeconfig for the kubeLB management cluster.{{< /unsafe >}} |
| `enableForAllDatacenters` _boolean_ | {{< unsafe >}}EnableForAllDatacenters is used to enable kubeLB for all the datacenters belonging to this seed.<br />This is only used to control whether installing kubeLB is allowed or not for the datacenter.{{< /unsafe >}} |


[Back to top](#top)



### KubeLBSettings





_Appears in:_
- [KubeLBDatacenterSettings](#kubelbdatacentersettings)
- [KubeLBSeedSettings](#kubelbseedsettings)

| Field | Description |
| --- | --- |
| `kubeconfig` _[ObjectReference](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#objectreference-v1-core)_ | {{< unsafe >}}Kubeconfig is reference to the Kubeconfig for the kubeLB management cluster.{{< /unsafe >}} |


[Back to top](#top)



### KubeVirtCSIDriverOperator



KubeVirtCSIDriverOperator contains the different configurations for the kubevirt csi driver operator in the user cluster.

_Appears in:_
- [DatacenterSpecKubevirt](#datacenterspeckubevirt)
- [KubevirtCloudSpec](#kubevirtcloudspec)

| Field | Description |
| --- | --- |
| `overwriteRegistry` _string_ | {{< unsafe >}}OverwriteRegistry overwrite the images registry that the operator pulls.{{< /unsafe >}} |


[Back to top](#top)





### KubeVirtImageSources



KubeVirtImageSources represents KubeVirt image sources.

_Appears in:_
- [DatacenterSpecKubevirt](#datacenterspeckubevirt)

| Field | Description |
| --- | --- |
| `http` _[KubeVirtHTTPSource](#kubevirthttpsource)_ | {{< unsafe >}}HTTP represents a http source.{{< /unsafe >}} |


[Back to top](#top)



### KubeVirtInfraStorageClass





_Appears in:_
- [DatacenterSpecKubevirt](#datacenterspeckubevirt)
- [KubevirtCloudSpec](#kubevirtcloudspec)

| Field | Description |
| --- | --- |
| `name` _string_ | {{< unsafe >}}{{< /unsafe >}} |
| `isDefaultClass` _boolean_ | {{< unsafe >}}Optional: IsDefaultClass. If true, the created StorageClass in the tenant cluster will be annotated with:<br />storageclass.kubernetes.io/is-default-class : true<br />If missing or false, annotation will be:<br />storageclass.kubernetes.io/is-default-class : false{{< /unsafe >}} |
| `volumeBindingMode` _[VolumeBindingMode](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#volumebindingmode-v1-storage)_ | {{< unsafe >}}VolumeBindingMode indicates how PersistentVolumeClaims should be provisioned and bound. When unset,<br />VolumeBindingImmediate is used.{{< /unsafe >}} |
| `labels` _object (keys:string, values:string)_ | {{< unsafe >}}Labels is a map of string keys and values that can be used to organize and categorize<br />(scope and select) objects. May match selectors of replication controllers<br />and services.{{< /unsafe >}} |
| `zones` _string array_ | {{< unsafe >}}Zones represent a logical failure domain. It is common for Kubernetes clusters to span multiple zones<br />for increased availability{{< /unsafe >}} |
| `regions` _string array_ | {{< unsafe >}}Regions represents a larger domain, made up of one or more zones. It is uncommon for Kubernetes clusters<br />to span multiple regions{{< /unsafe >}} |
| `volumeProvisioner` _[KubeVirtVolumeProvisioner](#kubevirtvolumeprovisioner)_ | {{< unsafe >}}VolumeProvisioner The **Provider** field specifies whether a storage class will be utilized by the Containerized<br />Data Importer (CDI) to create VM disk images and/or by the KubeVirt CSI Driver to provision volumes in the<br />infrastructure cluster. If no storage class in the seed object has this value set, the storage class will be used<br />for both purposes: CDI will create VM disk images, and the CSI driver will provision and attach volumes in the user<br />cluster. However, if the value is set to `kubevirt-csi-driver`, the storage class cannot be used by CDI for VM disk<br />image creation.{{< /unsafe >}} |


[Back to top](#top)



### KubeVirtVolumeProvisioner

_Underlying type:_ `string`

KubeVirtVolumeProvisioner represents what is the provisioner of the storage class volume, whether it will be the csi driver
and/or CDI for disk images.

_Appears in:_
- [KubeVirtInfraStorageClass](#kubevirtinfrastorageclass)



### KubermaticAPIConfiguration



KubermaticAPIConfiguration configures the dashboard.

_Appears in:_
- [KubermaticConfigurationSpec](#kubermaticconfigurationspec)

| Field | Description |
| --- | --- |
| `dockerRepository` _string_ | {{< unsafe >}}DockerRepository is the repository containing the Kubermatic REST API image.{{< /unsafe >}} |
| `dockerTag` _string_ | {{< unsafe >}}DockerTag is used to overwrite the Kubermatic API Docker image tag and is only for development<br />purposes. This field must not be set in production environments. If DockerTag is specified then<br />DockerTagSuffix will be ignored.<br />---{{< /unsafe >}} |
| `dockerTagSuffix` _string_ | {{< unsafe >}}DockerTagSuffix is appended to the KKP version used for referring to the custom Kubermatic API image.<br />If left empty, either the `DockerTag` if specified or the original Kubermatic API Docker image tag will be used.<br />With DockerTagSuffix the tag becomes <KKP_VERSION-SUFFIX> i.e. "v2.15.0-SUFFIX".{{< /unsafe >}} |
| `accessibleAddons` _string array_ | {{< unsafe >}}AccessibleAddons is a list of addons that should be enabled in the API.{{< /unsafe >}} |
| `pprofEndpoint` _string_ | {{< unsafe >}}PProfEndpoint controls the port the API should listen on to provide pprof<br />data. This port is never exposed from the container and only available via port-forwardings.{{< /unsafe >}} |
| `resources` _[ResourceRequirements](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#resourcerequirements-v1-core)_ | {{< unsafe >}}Resources describes the requested and maximum allowed CPU/memory usage.{{< /unsafe >}} |
| `debugLog` _boolean_ | {{< unsafe >}}DebugLog enables more verbose logging.{{< /unsafe >}} |
| `replicas` _integer_ | {{< unsafe >}}Replicas sets the number of pod replicas for the API deployment.{{< /unsafe >}} |


[Back to top](#top)



### KubermaticAddonsConfiguration



KubermaticAddonConfiguration describes the addons for a given cluster runtime.

_Appears in:_
- [KubermaticUserClusterConfiguration](#kubermaticuserclusterconfiguration)

| Field | Description |
| --- | --- |
| `default` _string array_ | {{< unsafe >}}Default is the list of addons to be installed by default into each cluster.<br />Mutually exclusive with "defaultManifests".{{< /unsafe >}} |
| `defaultManifests` _string_ | {{< unsafe >}}DefaultManifests is a list of addon manifests to install into all clusters.<br />Mutually exclusive with "default".{{< /unsafe >}} |
| `dockerRepository` _string_ | {{< unsafe >}}DockerRepository is the repository containing the Docker image containing<br />the possible addon manifests.{{< /unsafe >}} |
| `dockerTagSuffix` _string_ | {{< unsafe >}}DockerTagSuffix is appended to the tag used for referring to the addons image.<br />If left empty, the tag will be the KKP version (e.g. "v2.15.0"), with a<br />suffix it becomes "v2.15.0-SUFFIX".{{< /unsafe >}} |


[Back to top](#top)



### KubermaticAuthConfiguration



KubermaticAuthConfiguration defines keys and URLs for Dex.

_Appears in:_
- [KubermaticConfigurationSpec](#kubermaticconfigurationspec)

| Field | Description |
| --- | --- |
| `clientID` _string_ | {{< unsafe >}}{{< /unsafe >}} |
| `tokenIssuer` _string_ | {{< unsafe >}}{{< /unsafe >}} |
| `issuerRedirectURL` _string_ | {{< unsafe >}}{{< /unsafe >}} |
| `issuerClientID` _string_ | {{< unsafe >}}{{< /unsafe >}} |
| `issuerClientSecret` _string_ | {{< unsafe >}}{{< /unsafe >}} |
| `issuerCookieKey` _string_ | {{< unsafe >}}{{< /unsafe >}} |
| `serviceAccountKey` _string_ | {{< unsafe >}}{{< /unsafe >}} |
| `skipTokenIssuerTLSVerify` _boolean_ | {{< unsafe >}}{{< /unsafe >}} |


[Back to top](#top)



### KubermaticConfiguration



KubermaticConfiguration is the configuration required for running Kubermatic.

_Appears in:_
- [KubermaticConfigurationList](#kubermaticconfigurationlist)

| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `KubermaticConfiguration`
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[KubermaticConfigurationSpec](#kubermaticconfigurationspec)_ | {{< unsafe >}}{{< /unsafe >}} |
| `status` _[KubermaticConfigurationStatus](#kubermaticconfigurationstatus)_ | {{< unsafe >}}{{< /unsafe >}} |


[Back to top](#top)



### KubermaticConfigurationList



KubermaticConfigurationList is a collection of KubermaticConfigurations.



| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `KubermaticConfigurationList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[KubermaticConfiguration](#kubermaticconfiguration) array_ | {{< unsafe >}}{{< /unsafe >}} |


[Back to top](#top)



### KubermaticConfigurationSpec



KubermaticConfigurationSpec is the spec for a Kubermatic installation.

_Appears in:_
- [KubermaticConfiguration](#kubermaticconfiguration)

| Field | Description |
| --- | --- |
| `caBundle` _[TypedLocalObjectReference](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#typedlocalobjectreference-v1-core)_ | {{< unsafe >}}CABundle references a ConfigMap in the same namespace as the KubermaticConfiguration.<br />This ConfigMap must contain a ca-bundle.pem with PEM-encoded certificates. This bundle<br />automatically synchronized into each seed and each usercluster. APIGroup and Kind are<br />currently ignored.{{< /unsafe >}} |
| `imagePullSecret` _string_ | {{< unsafe >}}ImagePullSecret is used to authenticate against Docker registries.{{< /unsafe >}} |
| `auth` _[KubermaticAuthConfiguration](#kubermaticauthconfiguration)_ | {{< unsafe >}}Auth defines keys and URLs for Dex. These must be defined unless the HeadlessInstallation<br />feature gate is set, which will disable the UI/API and its need for an OIDC provider entirely.{{< /unsafe >}} |
| `featureGates` _object (keys:string, values:boolean)_ | {{< unsafe >}}FeatureGates are used to optionally enable certain features.{{< /unsafe >}} |
| `ui` _[KubermaticUIConfiguration](#kubermaticuiconfiguration)_ | {{< unsafe >}}UI configures the dashboard.{{< /unsafe >}} |
| `api` _[KubermaticAPIConfiguration](#kubermaticapiconfiguration)_ | {{< unsafe >}}API configures the frontend REST API used by the dashboard.{{< /unsafe >}} |
| `seedController` _[KubermaticSeedControllerConfiguration](#kubermaticseedcontrollerconfiguration)_ | {{< unsafe >}}SeedController configures the seed-controller-manager.{{< /unsafe >}} |
| `masterController` _[KubermaticMasterControllerConfiguration](#kubermaticmastercontrollerconfiguration)_ | {{< unsafe >}}MasterController configures the master-controller-manager.{{< /unsafe >}} |
| `webhook` _[KubermaticWebhookConfiguration](#kubermaticwebhookconfiguration)_ | {{< unsafe >}}Webhook configures the webhook.{{< /unsafe >}} |
| `userCluster` _[KubermaticUserClusterConfiguration](#kubermaticuserclusterconfiguration)_ | {{< unsafe >}}UserCluster configures various aspects of the user-created clusters.{{< /unsafe >}} |
| `exposeStrategy` _[ExposeStrategy](#exposestrategy)_ | {{< unsafe >}}ExposeStrategy is the strategy to expose the cluster with.<br />Note: The `seed_dns_overwrite` setting of a Seed's datacenter doesn't have any effect<br />if this is set to LoadBalancerStrategy.{{< /unsafe >}} |
| `ingress` _[KubermaticIngressConfiguration](#kubermaticingressconfiguration)_ | {{< unsafe >}}Ingress contains settings for making the API and UI accessible remotely.{{< /unsafe >}} |
| `versions` _[KubermaticVersioningConfiguration](#kubermaticversioningconfiguration)_ | {{< unsafe >}}Versions configures the available and default Kubernetes versions and updates.{{< /unsafe >}} |
| `verticalPodAutoscaler` _[KubermaticVPAConfiguration](#kubermaticvpaconfiguration)_ | {{< unsafe >}}VerticalPodAutoscaler configures the Kubernetes VPA integration.{{< /unsafe >}} |
| `proxy` _[KubermaticProxyConfiguration](#kubermaticproxyconfiguration)_ | {{< unsafe >}}Proxy allows to configure Kubermatic to use proxies to talk to the<br />world outside of its cluster.{{< /unsafe >}} |
| `mirrorImages` _string array_ | {{< unsafe >}}MirrorImages is a list of container images that will be mirrored with the `kubermatic-installer  mirror-images` command.<br />Each entry should be in the format "repository:tag".{{< /unsafe >}} |
| `systemApplications` _[SystemApplicationOptions](#systemapplicationoptions)_ | {{< unsafe >}}SystemApplications contains configuration for system applications.{{< /unsafe >}} |


[Back to top](#top)



### KubermaticConfigurationStatus



KubermaticConfigurationStatus stores status information about a KubermaticConfiguration.

_Appears in:_
- [KubermaticConfiguration](#kubermaticconfiguration)

| Field | Description |
| --- | --- |
| `kubermaticVersion` _string_ | {{< unsafe >}}KubermaticVersion current Kubermatic Version.{{< /unsafe >}} |
| `kubermaticEdition` _string_ | {{< unsafe >}}KubermaticEdition current Kubermatic Edition , i.e. Community Edition or Enterprise Edition.{{< /unsafe >}} |


[Back to top](#top)



### KubermaticIngressConfiguration





_Appears in:_
- [KubermaticConfigurationSpec](#kubermaticconfigurationspec)

| Field | Description |
| --- | --- |
| `domain` _string_ | {{< unsafe >}}Domain is the base domain where the dashboard shall be available. Even with<br />a disabled Ingress, this must always be a valid hostname.{{< /unsafe >}} |
| `className` _string_ | {{< unsafe >}}ClassName is the Ingress resource's class name, used for selecting the appropriate<br />ingress controller.{{< /unsafe >}} |
| `namespaceOverride` _string_ | {{< unsafe >}}NamespaceOverride need to be set if a different ingress-controller is used than the KKP default one.{{< /unsafe >}} |
| `disable` _boolean_ | {{< unsafe >}}Disable will prevent an Ingress from being created at all. This is mostly useful<br />during testing. If the Ingress is disabled, the CertificateIssuer setting can also<br />be left empty, as no Certificate resource will be created.{{< /unsafe >}} |
| `certificateIssuer` _[TypedLocalObjectReference](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#typedlocalobjectreference-v1-core)_ | {{< unsafe >}}CertificateIssuer is the name of a cert-manager Issuer or ClusterIssuer (default)<br />that will be used to acquire the certificate for the configured domain.<br />To use a namespaced Issuer, set the Kind to "Issuer" and manually create the<br />matching Issuer in Kubermatic's namespace.<br />Setting an empty name disables the automatic creation of certificates and disables<br />the TLS settings on the Kubermatic Ingress.{{< /unsafe >}} |


[Back to top](#top)



### KubermaticMasterControllerConfiguration



KubermaticMasterControllerConfiguration configures the Kubermatic master controller-manager.

_Appears in:_
- [KubermaticConfigurationSpec](#kubermaticconfigurationspec)

| Field | Description |
| --- | --- |
| `dockerRepository` _string_ | {{< unsafe >}}DockerRepository is the repository containing the Kubermatic master-controller-manager image.{{< /unsafe >}} |
| `projectsMigrator` _[KubermaticProjectsMigratorConfiguration](#kubermaticprojectsmigratorconfiguration)_ | {{< unsafe >}}ProjectsMigrator configures the migrator for user projects.{{< /unsafe >}} |
| `pprofEndpoint` _string_ | {{< unsafe >}}PProfEndpoint controls the port the master-controller-manager should listen on to provide pprof<br />data. This port is never exposed from the container and only available via port-forwardings.{{< /unsafe >}} |
| `resources` _[ResourceRequirements](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#resourcerequirements-v1-core)_ | {{< unsafe >}}Resources describes the requested and maximum allowed CPU/memory usage.{{< /unsafe >}} |
| `debugLog` _boolean_ | {{< unsafe >}}DebugLog enables more verbose logging.{{< /unsafe >}} |
| `replicas` _integer_ | {{< unsafe >}}Replicas sets the number of pod replicas for the master-controller-manager.{{< /unsafe >}} |


[Back to top](#top)



### KubermaticProjectsMigratorConfiguration



KubermaticProjectsMigratorConfiguration configures the Kubermatic master controller-manager.

_Appears in:_
- [KubermaticMasterControllerConfiguration](#kubermaticmastercontrollerconfiguration)

| Field | Description |
| --- | --- |
| `dryRun` _boolean_ | {{< unsafe >}}DryRun makes the migrator only log the actions it would take.{{< /unsafe >}} |


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
| `http` _string_ | {{< unsafe >}}HTTP is the full URL to the proxy to use for plaintext HTTP<br />connections, e.g. "http://internalproxy.example.com:8080".{{< /unsafe >}} |
| `https` _string_ | {{< unsafe >}}HTTPS is the full URL to the proxy to use for encrypted HTTPS<br />connections, e.g. "http://secureinternalproxy.example.com:8080".{{< /unsafe >}} |
| `noProxy` _string_ | {{< unsafe >}}NoProxy is a comma-separated list of hostnames / network masks<br />for which no proxy shall be used. If you make use of proxies,<br />this list should contain all local and cluster-internal domains<br />and networks, e.g. "10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,mydomain".<br />The operator will always prepend the following elements to this<br />list if proxying is configured (i.e. HTTP/HTTPS are not empty):<br />"127.0.0.1/8", "localhost", ".local", ".local.", "kubernetes", ".default", ".svc"{{< /unsafe >}} |


[Back to top](#top)



### KubermaticSeedControllerConfiguration



KubermaticSeedControllerConfiguration configures the Kubermatic seed controller-manager.

_Appears in:_
- [KubermaticConfigurationSpec](#kubermaticconfigurationspec)

| Field | Description |
| --- | --- |
| `dockerRepository` _string_ | {{< unsafe >}}DockerRepository is the repository containing the Kubermatic seed-controller-manager image.{{< /unsafe >}} |
| `backupStoreContainer` _string_ | {{< unsafe >}}BackupStoreContainer is the container used for shipping etcd snapshots to a backup location.{{< /unsafe >}} |
| `backupDeleteContainer` _string_ | {{< unsafe >}}BackupDeleteContainer is the container used for deleting etcd snapshots from a backup location.{{< /unsafe >}} |
| `backupCleanupContainer` _string_ | {{< unsafe >}}Deprecated: BackupCleanupContainer is the container used for removing expired backups from the storage location.<br />This field is a no-op and is no longer used. The old backup controller it was used for has been<br />removed. Do not set this field.{{< /unsafe >}} |
| `maximumParallelReconciles` _integer_ | {{< unsafe >}}MaximumParallelReconciles limits the number of cluster reconciliations<br />that are active at any given time.{{< /unsafe >}} |
| `pprofEndpoint` _string_ | {{< unsafe >}}PProfEndpoint controls the port the seed-controller-manager should listen on to provide pprof<br />data. This port is never exposed from the container and only available via port-forwardings.{{< /unsafe >}} |
| `resources` _[ResourceRequirements](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#resourcerequirements-v1-core)_ | {{< unsafe >}}Resources describes the requested and maximum allowed CPU/memory usage.{{< /unsafe >}} |
| `debugLog` _boolean_ | {{< unsafe >}}DebugLog enables more verbose logging.{{< /unsafe >}} |
| `replicas` _integer_ | {{< unsafe >}}Replicas sets the number of pod replicas for the seed-controller-manager.{{< /unsafe >}} |
| `disabledCollectors` _[MetricsCollector](#metricscollector) array_ | {{< unsafe >}}DisabledCollectors contains a list of metrics collectors that should be disabled.<br />Acceptable values are "Addon", "Cluster", "ClusterBackup", "Project", and "None".{{< /unsafe >}} |
| `backupInterval` _[Duration](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#duration-v1-meta)_ | {{< unsafe >}}BackupInterval defines the time duration between consecutive etcd backups.<br />Must be a valid time.Duration string format. Only takes effect when backup scheduling is enabled.{{< /unsafe >}} |
| `backupCount` _integer_ | {{< unsafe >}}BackupCount specifies the maximum number of backups to retain (defaults to DefaultKeptBackupsCount).<br />Oldest backups are automatically deleted when this limit is exceeded. Only applies when Schedule is configured.{{< /unsafe >}} |


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
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[SettingSpec](#settingspec)_ | {{< unsafe >}}{{< /unsafe >}} |


[Back to top](#top)



### KubermaticSettingList



KubermaticSettingList is a list of settings.



| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `KubermaticSettingList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[KubermaticSetting](#kubermaticsetting) array_ | {{< unsafe >}}{{< /unsafe >}} |


[Back to top](#top)



### KubermaticUIConfiguration



KubermaticUIConfiguration configures the dashboard.

_Appears in:_
- [KubermaticConfigurationSpec](#kubermaticconfigurationspec)

| Field | Description |
| --- | --- |
| `dockerRepository` _string_ | {{< unsafe >}}DockerRepository is the repository containing the Kubermatic dashboard image.{{< /unsafe >}} |
| `dockerTag` _string_ | {{< unsafe >}}DockerTag is used to overwrite the dashboard Docker image tag and is only for development<br />purposes. This field must not be set in production environments. If DockerTag is specified then<br />DockerTagSuffix will be ignored.<br />---{{< /unsafe >}} |
| `dockerTagSuffix` _string_ | {{< unsafe >}}DockerTagSuffix is appended to the KKP version used for referring to the custom dashboard image.<br />If left empty, either the `DockerTag` if specified or the original dashboard Docker image tag will be used.<br />With DockerTagSuffix the tag becomes <KKP_VERSION-SUFFIX> i.e. "v2.15.0-SUFFIX".{{< /unsafe >}} |
| `config` _string_ | {{< unsafe >}}Config sets flags for various dashboard features.{{< /unsafe >}} |
| `resources` _[ResourceRequirements](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#resourcerequirements-v1-core)_ | {{< unsafe >}}Resources describes the requested and maximum allowed CPU/memory usage.{{< /unsafe >}} |
| `replicas` _integer_ | {{< unsafe >}}Replicas sets the number of pod replicas for the UI deployment.{{< /unsafe >}} |
| `extraVolumeMounts` _[VolumeMount](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#volumemount-v1-core) array_ | {{< unsafe >}}ExtraVolumeMounts allows to mount additional volumes into the UI container.{{< /unsafe >}} |
| `extraVolumes` _[Volume](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#volume-v1-core) array_ | {{< unsafe >}}ExtraVolumes allows to mount additional volumes into the UI container.{{< /unsafe >}} |


[Back to top](#top)



### KubermaticUserClusterConfiguration



KubermaticUserClusterConfiguration controls various aspects of the user-created clusters.

_Appears in:_
- [KubermaticConfigurationSpec](#kubermaticconfigurationspec)

| Field | Description |
| --- | --- |
| `kubermaticDockerRepository` _string_ | {{< unsafe >}}KubermaticDockerRepository is the repository containing the Kubermatic user-cluster-controller-manager image.{{< /unsafe >}} |
| `dnatControllerDockerRepository` _string_ | {{< unsafe >}}DNATControllerDockerRepository is the repository containing the<br />dnat-controller image.{{< /unsafe >}} |
| `etcdLauncherDockerRepository` _string_ | {{< unsafe >}}EtcdLauncherDockerRepository is the repository containing the Kubermatic<br />etcd-launcher image.{{< /unsafe >}} |
| `overwriteRegistry` _string_ | {{< unsafe >}}OverwriteRegistry specifies a custom Docker registry which will be used for all images<br />used for user clusters (user cluster control plane + addons). This also applies to<br />the KubermaticDockerRepository and DNATControllerDockerRepository fields.{{< /unsafe >}} |
| `addons` _[KubermaticAddonsConfiguration](#kubermaticaddonsconfiguration)_ | {{< unsafe >}}Addons controls the optional additions installed into each user cluster.{{< /unsafe >}} |
| `systemApplications` _[SystemApplicationsConfiguration](#systemapplicationsconfiguration)_ | {{< unsafe >}}SystemApplications contains configuration for system Applications (such as CNI).{{< /unsafe >}} |
| `applications` _[ApplicationsConfiguration](#applicationsconfiguration)_ | {{< unsafe >}}Applications contains configuration for default Application settings.{{< /unsafe >}} |
| `nodePortRange` _string_ | {{< unsafe >}}NodePortRange is the port range for user clusters - this must match the NodePort<br />range of the seed cluster.{{< /unsafe >}} |
| `monitoring` _[KubermaticUserClusterMonitoringConfiguration](#kubermaticuserclustermonitoringconfiguration)_ | {{< unsafe >}}Monitoring can be used to fine-tune to in-cluster Prometheus.{{< /unsafe >}} |
| `disableApiserverEndpointReconciling` _boolean_ | {{< unsafe >}}DisableAPIServerEndpointReconciling can be used to toggle the `--endpoint-reconciler-type` flag for<br />the Kubernetes API server.{{< /unsafe >}} |
| `etcdVolumeSize` _string_ | {{< unsafe >}}EtcdVolumeSize configures the volume size to use for each etcd pod inside user clusters.{{< /unsafe >}} |
| `apiserverReplicas` _integer_ | {{< unsafe >}}APIServerReplicas configures the replica count for the API-Server deployment inside user clusters.{{< /unsafe >}} |
| `machineController` _[MachineControllerConfiguration](#machinecontrollerconfiguration)_ | {{< unsafe >}}MachineController configures the Machine Controller{{< /unsafe >}} |
| `operatingSystemManager` _[OperatingSystemManager](#operatingsystemmanager)_ | {{< unsafe >}}OperatingSystemManager configures the image repo and the tag version for osm deployment.{{< /unsafe >}} |


[Back to top](#top)



### KubermaticUserClusterMonitoringConfiguration



KubermaticUserClusterMonitoringConfiguration can be used to fine-tune to in-cluster Prometheus.

_Appears in:_
- [KubermaticUserClusterConfiguration](#kubermaticuserclusterconfiguration)

| Field | Description |
| --- | --- |
| `disableDefaultRules` _boolean_ | {{< unsafe >}}DisableDefaultRules disables the recording and alerting rules.{{< /unsafe >}} |
| `disableDefaultScrapingConfigs` _boolean_ | {{< unsafe >}}DisableDefaultScrapingConfigs disables the default scraping targets.{{< /unsafe >}} |
| `customRules` _string_ | {{< unsafe >}}CustomRules can be used to inject custom recording and alerting rules. This field<br />must be a YAML-formatted string with a `group` element at its root, as documented<br />on https://prometheus.io/docs/prometheus/latest/configuration/alerting_rules/.<br />This value is treated as a Go template, which allows to inject dynamic values like<br />the internal cluster address or the cluster ID. Refer to pkg/resources/prometheus<br />and the documentation for more information on the available fields.{{< /unsafe >}} |
| `customScrapingConfigs` _string_ | {{< unsafe >}}CustomScrapingConfigs can be used to inject custom scraping rules. This must be a<br />YAML-formatted string containing an array of scrape configurations as documented<br />on https://prometheus.io/docs/prometheus/latest/configuration/configuration/#scrape_config.<br />This value is treated as a Go template, which allows to inject dynamic values like<br />the internal cluster address or the cluster ID. Refer to pkg/resources/prometheus<br />and the documentation for more information on the available fields.{{< /unsafe >}} |
| `scrapeAnnotationPrefix` _string_ | {{< unsafe >}}ScrapeAnnotationPrefix (if set) is used to make the in-cluster Prometheus scrape pods<br />inside the user clusters.{{< /unsafe >}} |


[Back to top](#top)



### KubermaticVPAComponent





_Appears in:_
- [KubermaticVPAConfiguration](#kubermaticvpaconfiguration)

| Field | Description |
| --- | --- |
| `dockerRepository` _string_ | {{< unsafe >}}DockerRepository is the repository containing the component's image.{{< /unsafe >}} |
| `resources` _[ResourceRequirements](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#resourcerequirements-v1-core)_ | {{< unsafe >}}Resources describes the requested and maximum allowed CPU/memory usage.{{< /unsafe >}} |


[Back to top](#top)



### KubermaticVPAConfiguration



KubermaticVPAConfiguration configures the Kubernetes VPA.

_Appears in:_
- [KubermaticConfigurationSpec](#kubermaticconfigurationspec)

| Field | Description |
| --- | --- |
| `recommender` _[KubermaticVPAComponent](#kubermaticvpacomponent)_ | {{< unsafe >}}{{< /unsafe >}} |
| `updater` _[KubermaticVPAComponent](#kubermaticvpacomponent)_ | {{< unsafe >}}{{< /unsafe >}} |
| `admissionController` _[KubermaticVPAComponent](#kubermaticvpacomponent)_ | {{< unsafe >}}{{< /unsafe >}} |


[Back to top](#top)



### KubermaticVersioningConfiguration



KubermaticVersioningConfiguration configures the available and default Kubernetes versions.

_Appears in:_
- [KubermaticConfigurationSpec](#kubermaticconfigurationspec)

| Field | Description |
| --- | --- |
| `versions` _[Semver](#semver) array_ | {{< unsafe >}}Versions lists the available versions.{{< /unsafe >}} |
| `default` _[Semver](#semver)_ | {{< unsafe >}}Default is the default version to offer users.{{< /unsafe >}} |
| `updates` _[Update](#update) array_ | {{< unsafe >}}Updates is a list of available and automatic upgrades.<br />All 'to' versions must be configured in the version list for this orchestrator.<br />Each update may optionally be configured to be 'automatic: true', in which case the<br />controlplane of all clusters whose version matches the 'from' directive will get<br />updated to the 'to' version. If automatic is enabled, the 'to' version must be a<br />version and not a version range.<br />Also, updates may set 'automaticNodeUpdate: true', in which case Nodes will get<br />updates as well. 'automaticNodeUpdate: true' implies 'automatic: true' as well,<br />because Nodes may not have a newer version than the controlplane.{{< /unsafe >}} |
| `providerIncompatibilities` _[Incompatibility](#incompatibility) array_ | {{< unsafe >}}ProviderIncompatibilities lists all the Kubernetes version incompatibilities{{< /unsafe >}} |
| `externalClusters` _object (keys:[ExternalClusterProviderType](#externalclusterprovidertype), values:[ExternalClusterProviderVersioningConfiguration](#externalclusterproviderversioningconfiguration))_ | {{< unsafe >}}ExternalClusters contains the available and default Kubernetes versions and updates for ExternalClusters.{{< /unsafe >}} |


[Back to top](#top)



### KubermaticWebhookConfiguration



KubermaticWebhookConfiguration configures the Kubermatic webhook.

_Appears in:_
- [KubermaticConfigurationSpec](#kubermaticconfigurationspec)

| Field | Description |
| --- | --- |
| `dockerRepository` _string_ | {{< unsafe >}}DockerRepository is the repository containing the Kubermatic webhook image.{{< /unsafe >}} |
| `pprofEndpoint` _string_ | {{< unsafe >}}PProfEndpoint controls the port the webhook should listen on to provide pprof<br />data. This port is never exposed from the container and only available via port-forwardings.{{< /unsafe >}} |
| `resources` _[ResourceRequirements](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#resourcerequirements-v1-core)_ | {{< unsafe >}}Resources describes the requested and maximum allowed CPU/memory usage.{{< /unsafe >}} |
| `debugLog` _boolean_ | {{< unsafe >}}DebugLog enables more verbose logging.{{< /unsafe >}} |
| `replicas` _integer_ | {{< unsafe >}}Replicas sets the number of pod replicas for the webhook.{{< /unsafe >}} |


[Back to top](#top)



### KubernetesDashboard



KubernetesDashboard contains settings for the kubernetes-dashboard component as part of the cluster control plane.

_Appears in:_
- [ClusterSpec](#clusterspec)

| Field | Description |
| --- | --- |
| `enabled` _boolean_ | {{< unsafe >}}Controls whether kubernetes-dashboard is deployed to the user cluster or not.<br />Enabled by default.{{< /unsafe >}} |


[Back to top](#top)



### Kubevirt





_Appears in:_
- [PresetSpec](#presetspec)

| Field | Description |
| --- | --- |
| `enabled` _boolean_ | {{< unsafe >}}Only enabled presets will be available in the KKP dashboard.{{< /unsafe >}} |
| `isCustomizable` _boolean_ | {{< unsafe >}}IsCustomizable marks a preset as editable on the KKP UI; Customizable presets still have the credentials obscured on the UI, but other fields that are not considered private are displayed during cluster creation. Users can then update those fields, if required.<br />NOTE: This is only supported for OpenStack Cloud Provider in KKP 2.26. Support for other providers will be added later on.{{< /unsafe >}} |
| `datacenter` _string_ | {{< unsafe >}}If datacenter is set, this preset is only applicable to the<br />configured datacenter.{{< /unsafe >}} |
| `kubeconfig` _string_ | {{< unsafe >}}Kubeconfig is the cluster's kubeconfig file, encoded with base64.{{< /unsafe >}} |
| `vpcName` _string_ | {{< unsafe >}}VPCName  is a virtual network name dedicated to a single tenant within a KubeVirt{{< /unsafe >}} |
| `subnetName` _string_ | {{< unsafe >}}SubnetName is the name of a subnet that is smaller, segmented portion of a larger network, like a Virtual Private Cloud (VPC).{{< /unsafe >}} |


[Back to top](#top)



### KubevirtCloudSpec



KubevirtCloudSpec specifies the access data to Kubevirt.

_Appears in:_
- [CloudSpec](#cloudspec)

| Field | Description |
| --- | --- |
| `credentialsReference` _[GlobalSecretKeySelector](#globalsecretkeyselector)_ | {{< unsafe >}}{{< /unsafe >}} |
| `kubeconfig` _string_ | {{< unsafe >}}The cluster's kubeconfig file, encoded with base64.{{< /unsafe >}} |
| `csiKubeconfig` _string_ | {{< unsafe >}}{{< /unsafe >}} |
| `preAllocatedDataVolumes` _[PreAllocatedDataVolume](#preallocateddatavolume) array_ | {{< unsafe >}}Custom Images are a good example of this use case.{{< /unsafe >}} |
| `infraStorageClasses` _string array_ | {{< unsafe >}}Deprecated: in favor of StorageClasses.<br />InfraStorageClasses is a list of storage classes from KubeVirt infra cluster that are used for<br />initialization of user cluster storage classes by the CSI driver kubevirt (hot pluggable disks){{< /unsafe >}} |
| `storageClasses` _[KubeVirtInfraStorageClass](#kubevirtinfrastorageclass) array_ | {{< unsafe >}}StorageClasses is a list of storage classes from KubeVirt infra cluster that are used for<br />initialization of user cluster storage classes by the CSI driver kubevirt (hot pluggable disks.<br />It contains also some flag specifying which one is the default one.{{< /unsafe >}} |
| `imageCloningEnabled` _boolean_ | {{< unsafe >}}ImageCloningEnabled flag enable/disable cloning for a cluster.{{< /unsafe >}} |
| `vpcName` _string_ | {{< unsafe >}}VPCName  is a virtual network name dedicated to a single tenant within a KubeVirt.{{< /unsafe >}} |
| `subnetName` _string_ | {{< unsafe >}}SubnetName is the name of a subnet that is smaller, segmented portion of a larger network, like a Virtual Private Cloud (VPC).{{< /unsafe >}} |
| `csiDriverOperator` _[KubeVirtCSIDriverOperator](#kubevirtcsidriveroperator)_ | {{< unsafe >}}CSIDriverOperator configures the kubevirt csi driver operator.{{< /unsafe >}} |


[Back to top](#top)



### KyvernoPolicyNamespace



KyvernoPolicyNamespace specifies the namespace to deploy the Kyverno Policy into.
This is relevant only if a Kyverno Policy resource is created because a Kyverno Policy is namespaced.
For Kyverno ClusterPolicy, this field is ignored.

_Appears in:_
- [PolicyBindingSpec](#policybindingspec)

| Field | Description |
| --- | --- |
| `name` _string_ | {{< unsafe >}}Name is the name of the namespace to deploy the Kyverno Policy into.{{< /unsafe >}} |
| `labels` _object (keys:string, values:string)_ | {{< unsafe >}}Labels to apply to this namespace.{{< /unsafe >}} |
| `annotations` _object (keys:string, values:string)_ | {{< unsafe >}}Annotations to apply to this namespace.{{< /unsafe >}} |


[Back to top](#top)



### KyvernoSettings



KyvernoSettings contains settings for the Kyverno component as part of the cluster control plane. This component is responsible for policy management.

_Appears in:_
- [ClusterSpec](#clusterspec)

| Field | Description |
| --- | --- |
| `enabled` _boolean_ | {{< unsafe >}}Controls whether Kyverno is deployed or not.{{< /unsafe >}} |


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
- [OSMControllerSettings](#osmcontrollersettings)

| Field | Description |
| --- | --- |
| `leaseDurationSeconds` _integer_ | {{< unsafe >}}LeaseDurationSeconds is the duration in seconds that non-leader candidates<br />will wait to force acquire leadership. This is measured against time of<br />last observed ack.{{< /unsafe >}} |
| `renewDeadlineSeconds` _integer_ | {{< unsafe >}}RenewDeadlineSeconds is the duration in seconds that the acting controlplane<br />will retry refreshing leadership before giving up.{{< /unsafe >}} |
| `retryPeriodSeconds` _integer_ | {{< unsafe >}}RetryPeriodSeconds is the duration in seconds the LeaderElector clients<br />should wait between tries of actions.{{< /unsafe >}} |


[Back to top](#top)



### LoadBalancerClass

_Underlying type:_ `[struct{Name string "json:\"name\""; Config LBClass "json:\"config\""}](#struct{name-string-"json:\"name\"";-config-lbclass-"json:\"config\""})`



_Appears in:_
- [DatacenterSpecOpenstack](#datacenterspecopenstack)



### LoggingRateLimitSettings



LoggingRateLimitSettings contains rate-limiting configuration for logging in the user cluster.

_Appears in:_
- [MLAAdminSettingSpec](#mlaadminsettingspec)

| Field | Description |
| --- | --- |
| `ingestionRate` _integer_ | {{< unsafe >}}IngestionRate represents ingestion rate limit in requests per second (nginx `rate` in `r/s`).{{< /unsafe >}} |
| `ingestionBurstSize` _integer_ | {{< unsafe >}}IngestionBurstSize represents ingestion burst size in number of requests (nginx `burst`).{{< /unsafe >}} |
| `queryRate` _integer_ | {{< unsafe >}}QueryRate represents query request rate limit per second (nginx `rate` in `r/s`).{{< /unsafe >}} |
| `queryBurstSize` _integer_ | {{< unsafe >}}QueryBurstSize represents query burst size in number of requests (nginx `burst`).{{< /unsafe >}} |


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
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[MLAAdminSettingSpec](#mlaadminsettingspec)_ | {{< unsafe >}}Spec describes the cluster-specific administrator settings for KKP user cluster MLA<br />(monitoring, logging & alerting) stack.{{< /unsafe >}} |


[Back to top](#top)



### MLAAdminSettingList



MLAAdminSettingList specifies a list of administrtor settings for KKP
user cluster MLA (monitoring, logging & alerting) stack.



| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `MLAAdminSettingList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[MLAAdminSetting](#mlaadminsetting) array_ | {{< unsafe >}}Items holds the list of the cluster-specific administrative settings<br />for KKP user cluster MLA.{{< /unsafe >}} |


[Back to top](#top)



### MLAAdminSettingSpec



MLAAdminSettingSpec specifies the cluster-specific administrator settings
for KKP user cluster MLA (monitoring, logging & alerting) stack.

_Appears in:_
- [MLAAdminSetting](#mlaadminsetting)

| Field | Description |
| --- | --- |
| `clusterName` _string_ | {{< unsafe >}}ClusterName is the name of the user cluster whose MLA settings are defined in this object.{{< /unsafe >}} |
| `monitoringRateLimits` _[MonitoringRateLimitSettings](#monitoringratelimitsettings)_ | {{< unsafe >}}MonitoringRateLimits contains rate-limiting configuration for monitoring in the user cluster.{{< /unsafe >}} |
| `loggingRateLimits` _[LoggingRateLimitSettings](#loggingratelimitsettings)_ | {{< unsafe >}}LoggingRateLimits contains rate-limiting configuration logging in the user cluster.{{< /unsafe >}} |


[Back to top](#top)



### MLASettings





_Appears in:_
- [ClusterSpec](#clusterspec)

| Field | Description |
| --- | --- |
| `monitoringEnabled` _boolean_ | {{< unsafe >}}MonitoringEnabled is the flag for enabling monitoring in user cluster.{{< /unsafe >}} |
| `loggingEnabled` _boolean_ | {{< unsafe >}}LoggingEnabled is the flag for enabling logging in user cluster.{{< /unsafe >}} |
| `monitoringResources` _[ResourceRequirements](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#resourcerequirements-v1-core)_ | {{< unsafe >}}MonitoringResources is the resource requirements for user cluster prometheus.{{< /unsafe >}} |
| `loggingResources` _[ResourceRequirements](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#resourcerequirements-v1-core)_ | {{< unsafe >}}LoggingResources is the resource requirements for user cluster promtail.{{< /unsafe >}} |
| `monitoringReplicas` _integer_ | {{< unsafe >}}MonitoringReplicas is the number of desired pods of user cluster prometheus deployment.{{< /unsafe >}} |


[Back to top](#top)



### MachineControllerConfiguration



MachineControllerConfiguration configures Machine Controller.

_Appears in:_
- [KubermaticUserClusterConfiguration](#kubermaticuserclusterconfiguration)

| Field | Description |
| --- | --- |
| `imageRepository` _string_ | {{< unsafe >}}ImageRepository is used to override the Machine Controller image repository.<br />It is only for development, tests and PoC purposes. This field must not be set in production environments.{{< /unsafe >}} |
| `imageTag` _string_ | {{< unsafe >}}ImageTag is used to override the Machine Controller image.<br />It is only for development, tests and PoC purposes. This field must not be set in production environments.{{< /unsafe >}} |


[Back to top](#top)



### MachineDeploymentOptions





_Appears in:_
- [SettingSpec](#settingspec)

| Field | Description |
| --- | --- |
| `autoUpdatesEnabled` _boolean_ | {{< unsafe >}}AutoUpdatesEnabled enables the auto updates option for machine deployments on the dashboard.<br />In case of flatcar linux, this will enable automatic updates through update engine and for other operating systems,<br />this will enable package updates on boot for the machines.{{< /unsafe >}} |
| `autoUpdatesEnforced` _boolean_ | {{< unsafe >}}AutoUpdatesEnforced enforces the auto updates option for machine deployments on the dashboard.<br />In case of flatcar linux, this will enable automatic updates through update engine and for other operating systems,<br />this will enable package updates on boot for the machines.{{< /unsafe >}} |


[Back to top](#top)



### MachineFlavorFilter





_Appears in:_
- [DatacenterSpec](#datacenterspec)
- [SettingSpec](#settingspec)

| Field | Description |
| --- | --- |
| `minCPU` _integer_ | {{< unsafe >}}Minimum number of vCPU{{< /unsafe >}} |
| `maxCPU` _integer_ | {{< unsafe >}}Maximum number of vCPU{{< /unsafe >}} |
| `minRAM` _integer_ | {{< unsafe >}}Minimum RAM size in GB{{< /unsafe >}} |
| `maxRAM` _integer_ | {{< unsafe >}}Maximum RAM size in GB{{< /unsafe >}} |
| `enableGPU` _boolean_ | {{< unsafe >}}Include VMs with GPU{{< /unsafe >}} |


[Back to top](#top)



### MachineNetworkingConfig



MachineNetworkingConfig specifies the networking parameters used for IPAM.

_Appears in:_
- [ClusterSpec](#clusterspec)

| Field | Description |
| --- | --- |
| `cidr` _string_ | {{< unsafe >}}{{< /unsafe >}} |
| `gateway` _string_ | {{< unsafe >}}{{< /unsafe >}} |
| `dnsServers` _string array_ | {{< unsafe >}}{{< /unsafe >}} |


[Back to top](#top)



### ManagementProxySettings





_Appears in:_
- [SeedSpec](#seedspec)

| Field | Description |
| --- | --- |
| `proxyHost` _string_ | {{< unsafe >}}If set, the proxy will be used{{< /unsafe >}} |
| `proxyPort` _integer_ | {{< unsafe >}}the proxies port to be used{{< /unsafe >}} |
| `proxyProtocol` _string_ | {{< unsafe >}}the protocol to use ("http", "https", and "socks5" schemes are supported){{< /unsafe >}} |


[Back to top](#top)



### Match



Match contains the constraint to resource matching data.

_Appears in:_
- [ConstraintSpec](#constraintspec)

| Field | Description |
| --- | --- |
| `kinds` _[Kind](#kind) array_ | {{< unsafe >}}Kinds accepts a list of objects with apiGroups and kinds fields that list the groups/kinds of objects to which<br />the constraint will apply. If multiple groups/kinds objects are specified, only one match is needed for the resource to be in scope{{< /unsafe >}} |
| `scope` _string_ | {{< unsafe >}}Scope accepts *, Cluster, or Namespaced which determines if cluster-scoped and/or namespace-scoped resources are selected. (defaults to *){{< /unsafe >}} |
| `namespaces` _string array_ | {{< unsafe >}}Namespaces is a list of namespace names. If defined, a constraint will only apply to resources in a listed namespace.{{< /unsafe >}} |
| `excludedNamespaces` _string array_ | {{< unsafe >}}ExcludedNamespaces is a list of namespace names. If defined, a constraint will only apply to resources not in a listed namespace.{{< /unsafe >}} |
| `labelSelector` _[LabelSelector](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#labelselector-v1-meta)_ | {{< unsafe >}}LabelSelector is a standard Kubernetes label selector.{{< /unsafe >}} |
| `namespaceSelector` _[LabelSelector](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#labelselector-v1-meta)_ | {{< unsafe >}}NamespaceSelector  is a standard Kubernetes namespace selector. If defined, make sure to add Namespaces to your<br />configs.config.gatekeeper.sh object to ensure namespaces are synced into OPA{{< /unsafe >}} |


[Back to top](#top)



### MeteringConfiguration



MeteringConfiguration contains all the configuration for the metering tool.

_Appears in:_
- [SeedSpec](#seedspec)

| Field | Description |
| --- | --- |
| `enabled` _boolean_ | {{< unsafe >}}{{< /unsafe >}} |
| `storageClassName` _string_ | {{< unsafe >}}StorageClassName is the name of the storage class that the metering Prometheus instance uses to store metric data for reporting.{{< /unsafe >}} |
| `storageSize` _string_ | {{< unsafe >}}StorageSize is the size of the storage class. Default value is 100Gi. Changing this value requires<br />manual deletion of the existing Prometheus PVC (and thereby removing all metering data).{{< /unsafe >}} |
| `retentionDays` _integer_ | {{< unsafe >}}RetentionDays is the number of days for which data should be kept in Prometheus. Default value is 90.{{< /unsafe >}} |
| `reports` _object (keys:string, values:[MeteringReportConfiguration](#meteringreportconfiguration))_ | {{< unsafe >}}ReportConfigurations is a map of report configuration definitions.{{< /unsafe >}} |


[Back to top](#top)



### MeteringReportConfiguration





_Appears in:_
- [MeteringConfiguration](#meteringconfiguration)

| Field | Description |
| --- | --- |
| `schedule` _string_ | {{< unsafe >}}Schedule in Cron format, see https://en.wikipedia.org/wiki/Cron. Please take a note that Schedule is responsible<br />only for setting the time when a report generation mechanism kicks off. The Interval MUST be set independently.{{< /unsafe >}} |
| `interval` _integer_ | {{< unsafe >}}Interval defines the number of days consulted in the metering report.<br />Ignored when `Monthly` is set to true{{< /unsafe >}} |
| `monthly` _boolean_ | {{< unsafe >}}Monthly creates a report for the previous month.{{< /unsafe >}} |
| `retention` _integer_ | {{< unsafe >}}Retention defines a number of days after which reports are queued for removal. If not set, reports are kept forever.<br />Please note that this functionality works only for object storage that supports an object lifecycle management mechanism.{{< /unsafe >}} |
| `type` _string array_ | {{< unsafe >}}Types of reports to generate. Available report types are cluster and namespace. By default, all types of reports are generated.{{< /unsafe >}} |
| `format` _[MeteringReportFormat](#meteringreportformat)_ | {{< unsafe >}}Format is the file format of the generated report, one of "csv" or "json" (defaults to "csv").{{< /unsafe >}} |


[Back to top](#top)



### MeteringReportFormat

_Underlying type:_ `string`

MeteringReportFormat maps directly to the values supported by the kubermatic-metering tool.

_Appears in:_
- [MeteringReportConfiguration](#meteringreportconfiguration)



### MetricsCollector

_Underlying type:_ `string`

MetricsCollector is the name of an available metrics collector.

_Appears in:_
- [KubermaticSeedControllerConfiguration](#kubermaticseedcontrollerconfiguration)
- [SeedSpec](#seedspec)



### MlaOptions





_Appears in:_
- [SettingSpec](#settingspec)

| Field | Description |
| --- | --- |
| `loggingEnabled` _boolean_ | {{< unsafe >}}{{< /unsafe >}} |
| `loggingEnforced` _boolean_ | {{< unsafe >}}{{< /unsafe >}} |
| `monitoringEnabled` _boolean_ | {{< unsafe >}}{{< /unsafe >}} |
| `monitoringEnforced` _boolean_ | {{< unsafe >}}{{< /unsafe >}} |


[Back to top](#top)



### MonitoringRateLimitSettings



MonitoringRateLimitSettings contains rate-limiting configuration for monitoring in the user cluster.

_Appears in:_
- [MLAAdminSettingSpec](#mlaadminsettingspec)

| Field | Description |
| --- | --- |
| `ingestionRate` _integer_ | {{< unsafe >}}IngestionRate represents the ingestion rate limit in samples per second (Cortex `ingestion_rate`).{{< /unsafe >}} |
| `ingestionBurstSize` _integer_ | {{< unsafe >}}IngestionBurstSize represents ingestion burst size in samples per second (Cortex `ingestion_burst_size`).{{< /unsafe >}} |
| `maxSeriesPerMetric` _integer_ | {{< unsafe >}}MaxSeriesPerMetric represents maximum number of series per metric (Cortex `max_series_per_metric`).{{< /unsafe >}} |
| `maxSeriesTotal` _integer_ | {{< unsafe >}}MaxSeriesTotal represents maximum number of series per this user cluster (Cortex `max_series_per_user`).{{< /unsafe >}} |
| `queryRate` _integer_ | {{< unsafe >}}QueryRate represents  query request rate limit per second (nginx `rate` in `r/s`).{{< /unsafe >}} |
| `queryBurstSize` _integer_ | {{< unsafe >}}QueryBurstSize represents query burst size in number of requests (nginx `burst`).{{< /unsafe >}} |
| `maxSamplesPerQuery` _integer_ | {{< unsafe >}}MaxSamplesPerQuery represents maximum number of samples during a query (Cortex `max_samples_per_query`).{{< /unsafe >}} |
| `maxSeriesPerQuery` _integer_ | {{< unsafe >}}MaxSeriesPerQuery represents maximum number of timeseries during a query (Cortex `max_series_per_query`).{{< /unsafe >}} |


[Back to top](#top)



### NamespacedMode

_Underlying type:_ `[struct{Enabled bool "json:\"enabled,omitempty\""; Namespace string "json:\"name,omitempty\""}](#struct{enabled-bool-"json:\"enabled,omitempty\"";-namespace-string-"json:\"name,omitempty\""})`



_Appears in:_
- [DatacenterSpecKubevirt](#datacenterspeckubevirt)





### NetworkPolicyMode

_Underlying type:_ `string`

NetworkPolicyMode maps directly to the values supported by the kubermatic network policy mode for kubevirt
worker nodes in kube-ovn environments.

_Appears in:_
- [NetworkPolicy](#networkpolicy)



### NetworkRanges



NetworkRanges represents ranges of network addresses.

_Appears in:_
- [AWSCloudSpec](#awscloudspec)
- [AzureCloudSpec](#azurecloudspec)
- [ClusterNetworkingConfig](#clusternetworkingconfig)
- [ClusterSpec](#clusterspec)
- [DatacenterSpecOpenstack](#datacenterspecopenstack)
- [GCPCloudSpec](#gcpcloudspec)
- [OpenstackCloudSpec](#openstackcloudspec)

| Field | Description |
| --- | --- |
| `cidrBlocks` _string array_ | {{< unsafe >}}{{< /unsafe >}} |


[Back to top](#top)



### NodePortProxyComponentEnvoy





_Appears in:_
- [NodeportProxyConfig](#nodeportproxyconfig)

| Field | Description |
| --- | --- |
| `dockerRepository` _string_ | {{< unsafe >}}DockerRepository is the repository containing the component's image.{{< /unsafe >}} |
| `resources` _[ResourceRequirements](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#resourcerequirements-v1-core)_ | {{< unsafe >}}Resources describes the requested and maximum allowed CPU/memory usage.{{< /unsafe >}} |
| `loadBalancerService` _[EnvoyLoadBalancerService](#envoyloadbalancerservice)_ | {{< unsafe >}}{{< /unsafe >}} |


[Back to top](#top)



### NodeSettings



NodeSettings are node specific flags which can be configured on datacenter level.

_Appears in:_
- [Datacenter](#datacenter)

| Field | Description |
| --- | --- |
| `httpProxy` _[ProxyValue](#proxyvalue)_ | {{< unsafe >}}Optional: If set, this proxy will be configured for both HTTP and HTTPS.{{< /unsafe >}} |
| `noProxy` _[ProxyValue](#proxyvalue)_ | {{< unsafe >}}Optional: If set this will be set as NO_PROXY environment variable on the node;<br />The value must be a comma-separated list of domains for which no proxy<br />should be used, e.g. "*.example.com,internal.dev".<br />Note that the in-cluster apiserver URL will be automatically prepended<br />to this value.{{< /unsafe >}} |
| `insecureRegistries` _string array_ | {{< unsafe >}}Optional: These image registries will be configured as insecure<br />on the container runtime.{{< /unsafe >}} |
| `registryMirrors` _string array_ | {{< unsafe >}}Optional: These image registries will be configured as registry mirrors<br />on the container runtime.{{< /unsafe >}} |
| `pauseImage` _string_ | {{< unsafe >}}Optional: Translates to --pod-infra-container-image on the kubelet.<br />If not set, the kubelet will default it.{{< /unsafe >}} |
| `containerdRegistryMirrors` _[ContainerRuntimeContainerd](#containerruntimecontainerd)_ | {{< unsafe >}}Optional: ContainerdRegistryMirrors configure registry mirrors endpoints. Can be used multiple times to specify multiple mirrors.{{< /unsafe >}} |


[Back to top](#top)



### NodeportProxyComponent





_Appears in:_
- [ComponentSettings](#componentsettings)
- [NodePortProxyComponentEnvoy](#nodeportproxycomponentenvoy)
- [NodeportProxyConfig](#nodeportproxyconfig)

| Field | Description |
| --- | --- |
| `dockerRepository` _string_ | {{< unsafe >}}DockerRepository is the repository containing the component's image.{{< /unsafe >}} |
| `resources` _[ResourceRequirements](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#resourcerequirements-v1-core)_ | {{< unsafe >}}Resources describes the requested and maximum allowed CPU/memory usage.{{< /unsafe >}} |


[Back to top](#top)



### NodeportProxyConfig





_Appears in:_
- [SeedSpec](#seedspec)

| Field | Description |
| --- | --- |
| `disable` _boolean_ | {{< unsafe >}}Disable will prevent the Kubermatic Operator from creating a nodeport-proxy<br />setup on the seed cluster. This should only be used if a suitable replacement<br />is installed (like the nodeport-proxy Helm chart).{{< /unsafe >}} |
| `annotations` _object (keys:string, values:string)_ | {{< unsafe >}}Annotations are used to further tweak the LoadBalancer integration with the<br />cloud provider where the seed cluster is running.<br />Deprecated: Use .envoy.loadBalancerService.annotations instead.{{< /unsafe >}} |
| `envoy` _[NodePortProxyComponentEnvoy](#nodeportproxycomponentenvoy)_ | {{< unsafe >}}Envoy configures the Envoy application itself.{{< /unsafe >}} |
| `envoyManager` _[NodeportProxyComponent](#nodeportproxycomponent)_ | {{< unsafe >}}EnvoyManager configures the Kubermatic-internal Envoy manager.{{< /unsafe >}} |
| `updater` _[NodeportProxyComponent](#nodeportproxycomponent)_ | {{< unsafe >}}Updater configures the component responsible for updating the LoadBalancer<br />service.{{< /unsafe >}} |
| `ipFamilyPolicy` _[IPFamilyPolicy](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#ipfamilypolicy-v1-core)_ | {{< unsafe >}}IPFamilyPolicy configures the IP family policy for the LoadBalancer service.{{< /unsafe >}} |
| `ipFamilies` _[IPFamily](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#ipfamily-v1-core) array_ | {{< unsafe >}}IPFamilies configures the IP families to use for the LoadBalancer service.{{< /unsafe >}} |


[Back to top](#top)



### NotificationsOptions





_Appears in:_
- [SettingSpec](#settingspec)

| Field | Description |
| --- | --- |
| `hideErrors` _boolean_ | {{< unsafe >}}HideErrors will silence error notifications for the dashboard.{{< /unsafe >}} |
| `hideErrorEvents` _boolean_ | {{< unsafe >}}HideErrorEvents will silence error events for the dashboard.{{< /unsafe >}} |


[Back to top](#top)



### Nutanix





_Appears in:_
- [PresetSpec](#presetspec)

| Field | Description |
| --- | --- |
| `enabled` _boolean_ | {{< unsafe >}}Only enabled presets will be available in the KKP dashboard.{{< /unsafe >}} |
| `isCustomizable` _boolean_ | {{< unsafe >}}IsCustomizable marks a preset as editable on the KKP UI; Customizable presets still have the credentials obscured on the UI, but other fields that are not considered private are displayed during cluster creation. Users can then update those fields, if required.<br />NOTE: This is only supported for OpenStack Cloud Provider in KKP 2.26. Support for other providers will be added later on.{{< /unsafe >}} |
| `datacenter` _string_ | {{< unsafe >}}If datacenter is set, this preset is only applicable to the<br />configured datacenter.{{< /unsafe >}} |
| `proxyURL` _string_ | {{< unsafe >}}Optional: To configure a HTTP proxy to access Nutanix Prism Central.{{< /unsafe >}} |
| `username` _string_ | {{< unsafe >}}Username that is used to access the Nutanix Prism Central API.{{< /unsafe >}} |
| `password` _string_ | {{< unsafe >}}Password corresponding to the provided user.{{< /unsafe >}} |
| `clusterName` _string_ | {{< unsafe >}}The name of the Nutanix cluster to which the resources and nodes are deployed to.{{< /unsafe >}} |
| `projectName` _string_ | {{< unsafe >}}Optional: Nutanix project to use. If none is given,<br />no project will be used.{{< /unsafe >}} |
| `csiUsername` _string_ | {{< unsafe >}}Prism Element Username for CSI driver.{{< /unsafe >}} |
| `csiPassword` _string_ | {{< unsafe >}}Prism Element Password for CSI driver.{{< /unsafe >}} |
| `csiEndpoint` _string_ | {{< unsafe >}}CSIEndpoint to access Nutanix Prism Element for CSI driver.{{< /unsafe >}} |
| `csiPort` _integer_ | {{< unsafe >}}CSIPort to use when connecting to the Nutanix Prism Element endpoint (defaults to 9440).{{< /unsafe >}} |


[Back to top](#top)



### NutanixCSIConfig



NutanixCSIConfig contains credentials and the endpoint for the Nutanix Prism Element to which the CSI driver connects.

_Appears in:_
- [NutanixCloudSpec](#nutanixcloudspec)

| Field | Description |
| --- | --- |
| `username` _string_ | {{< unsafe >}}Prism Element Username for CSI driver.{{< /unsafe >}} |
| `password` _string_ | {{< unsafe >}}Prism Element Password for CSI driver.{{< /unsafe >}} |
| `endpoint` _string_ | {{< unsafe >}}Prism Element Endpoint to access Nutanix Prism Element for CSI driver.{{< /unsafe >}} |
| `port` _integer_ | {{< unsafe >}}Optional: Port to use when connecting to the Nutanix Prism Element endpoint (defaults to 9440).{{< /unsafe >}} |
| `storageContainer` _string_ | {{< unsafe >}}Optional: defaults to "SelfServiceContainer".{{< /unsafe >}} |
| `fstype` _string_ | {{< unsafe >}}Optional: defaults to "xfs"{{< /unsafe >}} |
| `ssSegmentedIscsiNetwork` _boolean_ | {{< unsafe >}}Optional: defaults to "false".{{< /unsafe >}} |


[Back to top](#top)



### NutanixCloudSpec



NutanixCloudSpec specifies the access data to Nutanix.

_Appears in:_
- [CloudSpec](#cloudspec)

| Field | Description |
| --- | --- |
| `credentialsReference` _[GlobalSecretKeySelector](#globalsecretkeyselector)_ | {{< unsafe >}}{{< /unsafe >}} |
| `clusterName` _string_ | {{< unsafe >}}ClusterName is the Nutanix cluster that this user cluster will be deployed to.{{< /unsafe >}} |
| `projectName` _string_ | {{< unsafe >}}The name of the project that this cluster is deployed into. If none is given, no project will be used.{{< /unsafe >}} |
| `proxyURL` _string_ | {{< unsafe >}}Optional: Used to configure a HTTP proxy to access Nutanix Prism Central.{{< /unsafe >}} |
| `username` _string_ | {{< unsafe >}}Username to access the Nutanix Prism Central API.{{< /unsafe >}} |
| `password` _string_ | {{< unsafe >}}Password corresponding to the provided user.{{< /unsafe >}} |
| `csi` _[NutanixCSIConfig](#nutanixcsiconfig)_ | {{< unsafe >}}NutanixCSIConfig for CSI driver that connects to a prism element.{{< /unsafe >}} |


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
| `issuerURL` _string_ | {{< unsafe >}}URL of the provider which allows the API server to discover public signing keys.{{< /unsafe >}} |
| `issuerClientID` _string_ | {{< unsafe >}}IssuerClientID is the application's ID.{{< /unsafe >}} |
| `issuerClientSecret` _string_ | {{< unsafe >}}IssuerClientSecret is the application's secret.{{< /unsafe >}} |
| `cookieHashKey` _string_ | {{< unsafe >}}Optional: CookieHashKey is required, used to authenticate the cookie value using HMAC.<br />It is recommended to use a key with 32 or 64 bytes.<br />If not set, configuration is inherited from the default OIDC provider.{{< /unsafe >}} |
| `cookieSecureMode` _boolean_ | {{< unsafe >}}Optional: CookieSecureMode if true then cookie received only with HTTPS otherwise with HTTP.<br />If not set, configuration is inherited from the default OIDC provider.{{< /unsafe >}} |
| `offlineAccessAsScope` _boolean_ | {{< unsafe >}}Optional:  OfflineAccessAsScope if true then "offline_access" scope will be used<br />otherwise 'access_type=offline" query param will be passed.<br />If not set, configuration is inherited from the default OIDC provider.{{< /unsafe >}} |
| `skipTLSVerify` _boolean_ | {{< unsafe >}}Optional: SkipTLSVerify skip TLS verification for the token issuer.<br />If not set, configuration is inherited from the default OIDC provider.{{< /unsafe >}} |


[Back to top](#top)



### OIDCSettings



OIDCSettings contains OIDC configuration parameters for enabling authentication mechanism for the cluster.

_Appears in:_
- [ClusterSpec](#clusterspec)

| Field | Description |
| --- | --- |
| `issuerURL` _string_ | {{< unsafe >}}{{< /unsafe >}} |
| `clientID` _string_ | {{< unsafe >}}{{< /unsafe >}} |
| `clientSecret` _string_ | {{< unsafe >}}{{< /unsafe >}} |
| `usernameClaim` _string_ | {{< unsafe >}}{{< /unsafe >}} |
| `groupsClaim` _string_ | {{< unsafe >}}{{< /unsafe >}} |
| `requiredClaim` _string_ | {{< unsafe >}}{{< /unsafe >}} |
| `extraScopes` _string_ | {{< unsafe >}}{{< /unsafe >}} |
| `usernamePrefix` _string_ | {{< unsafe >}}{{< /unsafe >}} |
| `groupsPrefix` _string_ | {{< unsafe >}}{{< /unsafe >}} |


[Back to top](#top)



### OPAIntegrationSettings



OPAIntegrationSettings configures the usage of OPA (Open Policy Agent) Gatekeeper inside the user cluster.

_Appears in:_
- [ClusterSpec](#clusterspec)

| Field | Description |
| --- | --- |
| `enabled` _boolean_ | {{< unsafe >}}Enables OPA Gatekeeper integration.{{< /unsafe >}} |
| `webhookTimeoutSeconds` _integer_ | {{< unsafe >}}The timeout in seconds that is set for the Gatekeeper validating webhook admission review calls.<br />Defaults to `10` (seconds).{{< /unsafe >}} |
| `experimentalEnableMutation` _boolean_ | {{< unsafe >}}Optional: Enables experimental mutation in Gatekeeper.{{< /unsafe >}} |
| `controllerResources` _[ResourceRequirements](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#resourcerequirements-v1-core)_ | {{< unsafe >}}Optional: ControllerResources is the resource requirements for user cluster gatekeeper controller.{{< /unsafe >}} |
| `auditResources` _[ResourceRequirements](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#resourcerequirements-v1-core)_ | {{< unsafe >}}Optional: AuditResources is the resource requirements for user cluster gatekeeper audit.{{< /unsafe >}} |


[Back to top](#top)



### OSMControllerSettings





_Appears in:_
- [ComponentSettings](#componentsettings)

| Field | Description |
| --- | --- |
| `replicas` _integer_ | {{< unsafe >}}{{< /unsafe >}} |
| `resources` _[ResourceRequirements](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#resourcerequirements-v1-core)_ | {{< unsafe >}}{{< /unsafe >}} |
| `tolerations` _[Toleration](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#toleration-v1-core) array_ | {{< unsafe >}}{{< /unsafe >}} |
| `leaderElection` _[LeaderElectionSettings](#leaderelectionsettings)_ | {{< unsafe >}}{{< /unsafe >}} |
| `proxy` _[ProxySettings](#proxysettings)_ | {{< unsafe >}}ProxySettings defines optional flags for OperatingSystemManager deployment to allow<br />setting specific proxy configurations for specific user clusters.{{< /unsafe >}} |


[Back to top](#top)



### OSVersions

_Underlying type:_ `object`

OSVersions defines a map of OS version and the source to download the image.

_Appears in:_
- [ImageListWithVersions](#imagelistwithversions)
- [KubeVirtHTTPSource](#kubevirthttpsource)
- [TinkerbellHTTPSource](#tinkerbellhttpsource)



### OpaOptions





_Appears in:_
- [SettingSpec](#settingspec)

| Field | Description |
| --- | --- |
| `enabled` _boolean_ | {{< unsafe >}}{{< /unsafe >}} |
| `enforced` _boolean_ | {{< unsafe >}}{{< /unsafe >}} |


[Back to top](#top)



### OpenStack





_Appears in:_
- [ProviderConfiguration](#providerconfiguration)

| Field | Description |
| --- | --- |
| `enforceCustomDisk` _boolean_ | {{< unsafe >}}EnforceCustomDisk will enforce the custom disk option for machines for the dashboard.{{< /unsafe >}} |


[Back to top](#top)



### Openstack





_Appears in:_
- [PresetSpec](#presetspec)

| Field | Description |
| --- | --- |
| `enabled` _boolean_ | {{< unsafe >}}Only enabled presets will be available in the KKP dashboard.{{< /unsafe >}} |
| `isCustomizable` _boolean_ | {{< unsafe >}}IsCustomizable marks a preset as editable on the KKP UI; Customizable presets still have the credentials obscured on the UI, but other fields that are not considered private are displayed during cluster creation. Users can then update those fields, if required.<br />NOTE: This is only supported for OpenStack Cloud Provider in KKP 2.26. Support for other providers will be added later on.{{< /unsafe >}} |
| `datacenter` _string_ | {{< unsafe >}}If datacenter is set, this preset is only applicable to the<br />configured datacenter.{{< /unsafe >}} |
| `useToken` _boolean_ | {{< unsafe >}}{{< /unsafe >}} |
| `applicationCredentialID` _string_ | {{< unsafe >}}Application credential ID to authenticate in combination with an application credential secret (which is not the user's password).{{< /unsafe >}} |
| `applicationCredentialSecret` _string_ | {{< unsafe >}}Application credential secret (which is not the user's password) to authenticate in combination with an application credential ID.{{< /unsafe >}} |
| `username` _string_ | {{< unsafe >}}{{< /unsafe >}} |
| `password` _string_ | {{< unsafe >}}{{< /unsafe >}} |
| `project` _string_ | {{< unsafe >}}Project, formally known as tenant.{{< /unsafe >}} |
| `projectID` _string_ | {{< unsafe >}}ProjectID, formally known as tenantID.{{< /unsafe >}} |
| `domain` _string_ | {{< unsafe >}}Domain holds the name of the identity service (keystone) domain.{{< /unsafe >}} |
| `network` _string_ | {{< unsafe >}}Network holds the name of the internal network When specified, all worker nodes will be attached to this network. If not specified, a network, subnet & router will be created.{{< /unsafe >}} |
| `securityGroups` _string_ | {{< unsafe >}}{{< /unsafe >}} |
| `floatingIPPool` _string_ | {{< unsafe >}}FloatingIPPool holds the name of the public network The public network is reachable from the outside world and should provide the pool of IP addresses to choose from.{{< /unsafe >}} |
| `routerID` _string_ | {{< unsafe >}}{{< /unsafe >}} |
| `subnetID` _string_ | {{< unsafe >}}{{< /unsafe >}} |


[Back to top](#top)



### OpenstackCloudSpec



OpenstackCloudSpec specifies access data to an OpenStack cloud.

_Appears in:_
- [CloudSpec](#cloudspec)

| Field | Description |
| --- | --- |
| `credentialsReference` _[GlobalSecretKeySelector](#globalsecretkeyselector)_ | {{< unsafe >}}{{< /unsafe >}} |
| `username` _string_ | {{< unsafe >}}{{< /unsafe >}} |
| `password` _string_ | {{< unsafe >}}{{< /unsafe >}} |
| `project` _string_ | {{< unsafe >}}project, formally known as tenant.{{< /unsafe >}} |
| `projectID` _string_ | {{< unsafe >}}project id, formally known as tenantID.{{< /unsafe >}} |
| `domain` _string_ | {{< unsafe >}}Domain holds the name of the identity service (keystone) domain.{{< /unsafe >}} |
| `applicationCredentialID` _string_ | {{< unsafe >}}Application credential ID to authenticate in combination with an application credential secret (which is not the user's password).{{< /unsafe >}} |
| `applicationCredentialSecret` _string_ | {{< unsafe >}}Application credential secret (which is not the user's password) to authenticate in combination with an application credential ID.{{< /unsafe >}} |
| `useToken` _boolean_ | {{< unsafe >}}{{< /unsafe >}} |
| `token` _string_ | {{< unsafe >}}Used internally during cluster creation{{< /unsafe >}} |
| `network` _string_ | {{< unsafe >}}Network holds the name of the internal network<br />When specified, all worker nodes will be attached to this network. If not specified, a network, subnet & router will be created.<br /><br />Note that the network is internal if the "External" field is set to false{{< /unsafe >}} |
| `securityGroups` _string_ | {{< unsafe >}}SecurityGroups is the name of the security group (only supports a singular security group) that will be used for Machines in the cluster.<br />If this field is left empty, a default security group will be created and used.{{< /unsafe >}} |
| `nodePortsAllowedIPRange` _string_ | {{< unsafe >}}A CIDR range that will be used to allow access to the node port range in the security group to. Only applies if<br />the security group is generated by KKP and not preexisting.<br />If NodePortsAllowedIPRange nor NodePortsAllowedIPRanges is set, the node port range can be accessed from anywhere.{{< /unsafe >}} |
| `nodePortsAllowedIPRanges` _[NetworkRanges](#networkranges)_ | {{< unsafe >}}Optional: CIDR ranges that will be used to allow access to the node port range in the security group to. Only applies if<br />the security group is generated by KKP and not preexisting.<br />If NodePortsAllowedIPRange nor NodePortsAllowedIPRanges is set, the node port range can be accessed from anywhere.{{< /unsafe >}} |
| `floatingIPPool` _string_ | {{< unsafe >}}FloatingIPPool holds the name of the public network<br />The public network is reachable from the outside world<br />and should provide the pool of IP addresses to choose from.<br /><br />When specified, all worker nodes will receive a public ip from this floating ip pool<br /><br />Note that the network is external if the "External" field is set to true{{< /unsafe >}} |
| `routerID` _string_ | {{< unsafe >}}{{< /unsafe >}} |
| `subnetID` _string_ | {{< unsafe >}}{{< /unsafe >}} |
| `ipv6SubnetID` _string_ | {{< unsafe >}}IPv6SubnetID holds the ID of the subnet used for IPv6 networking.<br />If not provided, a new subnet will be created if IPv6 is enabled.{{< /unsafe >}} |
| `ipv6SubnetPool` _string_ | {{< unsafe >}}IPv6SubnetPool holds the name of the subnet pool used for creating new IPv6 subnets.<br />If not provided, the default IPv6 subnet pool will be used.{{< /unsafe >}} |
| `useOctavia` _boolean_ | {{< unsafe >}}Whether or not to use Octavia for LoadBalancer type of Service<br />implementation instead of using Neutron-LBaaS.<br />Attention:Openstack CCM use Octavia as default load balancer<br />implementation since v1.17.0<br /><br />Takes precedence over the 'use_octavia' flag provided at datacenter<br />level if both are specified.{{< /unsafe >}} |
| `enableIngressHostname` _boolean_ | {{< unsafe >}}Enable the `enable-ingress-hostname` cloud provider option on the Openstack CCM. Can only be used with the<br />external CCM and might be deprecated and removed in future versions as it is considered a workaround for the PROXY<br />protocol to preserve client IPs.{{< /unsafe >}} |
| `ingressHostnameSuffix` _string_ | {{< unsafe >}}Set a specific suffix for the hostnames used for the PROXY protocol workaround that is enabled by EnableIngressHostname.<br />The suffix is set to `nip.io` by default. Can only be used with the external CCM and might be deprecated and removed in<br />future versions as it is considered a workaround only.{{< /unsafe >}} |
| `cinderTopologyEnabled` _boolean_ | {{< unsafe >}}Flag to configure enablement of topology support for the Cinder CSI plugin.<br />This requires Nova and Cinder to have matching availability zones configured.{{< /unsafe >}} |


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
| `imageRepository` _string_ | {{< unsafe >}}ImageRepository is used to override the OperatingSystemManager image repository.<br />It is recommended to use this field only for development, tests and PoC purposes. For production environments.<br />it is not recommended, to use this field due to compatibility with the overall KKP stack.{{< /unsafe >}} |
| `imageTag` _string_ | {{< unsafe >}}ImageTag is used to override the OperatingSystemManager image.<br />It is recommended to use this field only for development, tests and PoC purposes. For production environments.<br />it is not recommended, to use this field due to compatibility with the overall KKP stack.{{< /unsafe >}} |
| `disableDefaultOperatingSystemProfiles` _boolean_ | {{< unsafe >}}DisableDefaultOperatingSystemProfiles setting this property to true, would disable the creation of OSMs default<br />OperatingSystemProfiles and users would need to provide a CustomOperatingSystemProfile to configure user clusters<br />worker nodes.{{< /unsafe >}} |


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



Deprecated: The Packet / Equinix Metal provider is deprecated and will be REMOVED IN VERSION 2.29.
This provider is no longer supported. Migrate your configurations away from "packet" immediately.

_Appears in:_
- [PresetSpec](#presetspec)

| Field | Description |
| --- | --- |
| `enabled` _boolean_ | {{< unsafe >}}Only enabled presets will be available in the KKP dashboard.{{< /unsafe >}} |
| `isCustomizable` _boolean_ | {{< unsafe >}}IsCustomizable marks a preset as editable on the KKP UI; Customizable presets still have the credentials obscured on the UI, but other fields that are not considered private are displayed during cluster creation. Users can then update those fields, if required.<br />NOTE: This is only supported for OpenStack Cloud Provider in KKP 2.26. Support for other providers will be added later on.{{< /unsafe >}} |
| `datacenter` _string_ | {{< unsafe >}}If datacenter is set, this preset is only applicable to the<br />configured datacenter.{{< /unsafe >}} |
| `apiKey` _string_ | {{< unsafe >}}{{< /unsafe >}} |
| `projectID` _string_ | {{< unsafe >}}{{< /unsafe >}} |
| `billingCycle` _string_ | {{< unsafe >}}{{< /unsafe >}} |


[Back to top](#top)



### PacketCloudSpec



Deprecated: The Packet / Equinix Metal provider is deprecated and will be REMOVED IN VERSION 2.29.
This provider is no longer supported. Migrate your configurations away from "packet" immediately.
PacketCloudSpec specifies access data to a Packet cloud.

_Appears in:_
- [CloudSpec](#cloudspec)

| Field | Description |
| --- | --- |
| `credentialsReference` _[GlobalSecretKeySelector](#globalsecretkeyselector)_ | {{< unsafe >}}{{< /unsafe >}} |
| `apiKey` _string_ | {{< unsafe >}}{{< /unsafe >}} |
| `projectID` _string_ | {{< unsafe >}}{{< /unsafe >}} |
| `billingCycle` _string_ | {{< unsafe >}}{{< /unsafe >}} |


[Back to top](#top)



### Parameters

_Underlying type:_ `RawMessage`



_Appears in:_
- [ConstraintSpec](#constraintspec)



### PolicyBinding



PolicyBinding binds a PolicyTemplate to specific clusters/projects and
optionally enables or disables it (if the template is not enforced).

_Appears in:_
- [PolicyBindingList](#policybindinglist)

| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `PolicyBinding`
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[PolicyBindingSpec](#policybindingspec)_ | {{< unsafe >}}{{< /unsafe >}} |
| `status` _[PolicyBindingStatus](#policybindingstatus)_ | {{< unsafe >}}{{< /unsafe >}} |


[Back to top](#top)





### PolicyBindingList



PolicyBindingList is a list of PolicyBinding objects.



| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `PolicyBindingList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[PolicyBinding](#policybinding) array_ | {{< unsafe >}}Items refers to the list of PolicyBinding objects{{< /unsafe >}} |


[Back to top](#top)



### PolicyBindingSpec



PolicyBindingSpec describes how and where to apply the referenced PolicyTemplate.

_Appears in:_
- [PolicyBinding](#policybinding)

| Field | Description |
| --- | --- |
| `policyTemplateRef` _[ObjectReference](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#objectreference-v1-core)_ | {{< unsafe >}}PolicyTemplateRef references the PolicyTemplate by name{{< /unsafe >}} |
| `kyvernoPolicyNamespace` _[KyvernoPolicyNamespace](#kyvernopolicynamespace)_ | {{< unsafe >}}KyvernoPolicyNamespace specifies the Kyverno namespace to deploy the Kyverno Policy into.<br /><br />Relevant only if the referenced PolicyTemplate has spec.enforced=false.<br />If Template.NamespacedPolicy is true and this field is omitted, no Kyverno Policy resources will be created.{{< /unsafe >}} |


[Back to top](#top)



### PolicyBindingStatus



PolicyBindingStatus is the status of the policy binding.

_Appears in:_
- [PolicyBinding](#policybinding)

| Field | Description |
| --- | --- |
| `observedGeneration` _integer_ | {{< unsafe >}}ObservedGeneration is the generation observed by the controller.{{< /unsafe >}} |
| `templateEnforced` _boolean_ | {{< unsafe >}}TemplateEnforced reflects the value of `spec.enforced` from PolicyTemplate{{< /unsafe >}} |
| `active` _boolean_ | {{< unsafe >}}Active reflects whether the Kyverno policy exists and is active in this User Cluster.{{< /unsafe >}} |
| `conditions` _[Condition](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#condition-v1-meta) array_ | {{< unsafe >}}Conditions represents the latest available observations of the policy binding's current state{{< /unsafe >}} |


[Back to top](#top)



### PolicyTemplate



PolicyTemplate defines a reusable blueprint of a Kyverno policy.

_Appears in:_
- [PolicyTemplateList](#policytemplatelist)

| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `PolicyTemplate`
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[PolicyTemplateSpec](#policytemplatespec)_ | {{< unsafe >}}{{< /unsafe >}} |


[Back to top](#top)



### PolicyTemplateList



PolicyTemplateList is a list of PolicyTemplate objects.



| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `PolicyTemplateList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[PolicyTemplate](#policytemplate) array_ | {{< unsafe >}}Items refers to the list of PolicyTemplate objects{{< /unsafe >}} |


[Back to top](#top)



### PolicyTemplateSpec





_Appears in:_
- [PolicyTemplate](#policytemplate)

| Field | Description |
| --- | --- |
| `title` _string_ | {{< unsafe >}}Title is the title of the policy, specified as an annotation in the Kyverno policy{{< /unsafe >}} |
| `description` _string_ | {{< unsafe >}}Description is the description of the policy, specified as an annotation in the Kyverno policy{{< /unsafe >}} |
| `category` _string_ | {{< unsafe >}}Category is the category of the policy, specified as an annotation in the Kyverno policy{{< /unsafe >}} |
| `severity` _string_ | {{< unsafe >}}Severity indicates the severity level of the policy{{< /unsafe >}} |
| `visibility` _string_ | {{< unsafe >}}Visibility specifies where the policy is visible.<br /><br />Can be one of: global, project, or cluster{{< /unsafe >}} |
| `projectID` _string_ | {{< unsafe >}}ProjectID is the ID of the project for which the policy template is created<br /><br />Relevant only for project visibility policies{{< /unsafe >}} |
| `default` _boolean_ | {{< unsafe >}}Default determines whether we apply the policy (create policy binding) by default{{< /unsafe >}} |
| `enforced` _boolean_ | {{< unsafe >}}Enforced indicates whether this policy is mandatory<br /><br />If true, this policy is mandatory<br />A PolicyBinding referencing it cannot disable it{{< /unsafe >}} |
| `namespacedPolicy` _boolean_ | {{< unsafe >}}NamespacedPolicy dictates the type of Kyverno resource to be created in this User Cluster.{{< /unsafe >}} |
| `target` _[PolicyTemplateTarget](#policytemplatetarget)_ | {{< unsafe >}}Target allows selection of projects and clusters where this template applies,<br />If 'Target' itself is omitted, the scope defaults based on 'Visibility' and 'ProjectID':{{< /unsafe >}} |
| `policySpec` _[RawExtension](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#rawextension-runtime-pkg)_ | {{< unsafe >}}PolicySpec is the policy spec of the Kyverno Policy we want to apply on the cluster.<br /><br />The structure of this spec should follow the rules defined in Kyverno<br />[Writing Policies Docs](https://kyverno.io/docs/writing-policies/).<br /><br />For example, a simple policy spec could be defined as:<br /><br />   policySpec:<br />     validationFailureAction: Audit<br />     background: true<br />     rules:<br />     - name: check-for-labels<br />       match:<br />         any:<br />         - resources:<br />             kinds:<br />             - Pod<br />       validate:<br />         message: "The label `app.kubernetes.io/name` is required."<br />         pattern:<br />           metadata:<br />             labels:<br />               app.kubernetes.io/name: "?*"<br /><br />There are also further examples of Kyverno policies in the<br />[Kyverno Policies Examples](https://kyverno.io/policies/).{{< /unsafe >}} |


[Back to top](#top)



### PolicyTemplateTarget



PolicyTemplateTarget allows specifying label selectors for Projects and Clusters.

_Appears in:_
- [PolicyTemplateSpec](#policytemplatespec)

| Field | Description |
| --- | --- |
| `projectSelector` _[LabelSelector](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#labelselector-v1-meta)_ | {{< unsafe >}}ProjectSelector filters KKP Projects based on their labels.{{< /unsafe >}} |
| `clusterSelector` _[LabelSelector](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#labelselector-v1-meta)_ | {{< unsafe >}}ClusterSelector filters individual KKP Cluster resources based on their labels.{{< /unsafe >}} |


[Back to top](#top)





### PreAllocatedDataVolume





_Appears in:_
- [KubevirtCloudSpec](#kubevirtcloudspec)

| Field | Description |
| --- | --- |
| `name` _string_ | {{< unsafe >}}{{< /unsafe >}} |
| `annotations` _object (keys:string, values:string)_ | {{< unsafe >}}{{< /unsafe >}} |
| `url` _string_ | {{< unsafe >}}{{< /unsafe >}} |
| `size` _string_ | {{< unsafe >}}{{< /unsafe >}} |
| `storageClass` _string_ | {{< unsafe >}}{{< /unsafe >}} |


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
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[PresetSpec](#presetspec)_ | {{< unsafe >}}{{< /unsafe >}} |


[Back to top](#top)





### PresetList



PresetList is the type representing a PresetList.



| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `PresetList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[Preset](#preset) array_ | {{< unsafe >}}List of presets{{< /unsafe >}} |


[Back to top](#top)



### PresetSpec



Presets specifies default presets for supported providers.

_Appears in:_
- [Preset](#preset)

| Field | Description |
| --- | --- |
| `digitalocean` _[Digitalocean](#digitalocean)_ | {{< unsafe >}}Access data for DigitalOcean.{{< /unsafe >}} |
| `hetzner` _[Hetzner](#hetzner)_ | {{< unsafe >}}Access data for Hetzner.{{< /unsafe >}} |
| `azure` _[Azure](#azure)_ | {{< unsafe >}}Access data for Microsoft Azure Cloud.{{< /unsafe >}} |
| `vsphere` _[VSphere](#vsphere)_ | {{< unsafe >}}Access data for vSphere.{{< /unsafe >}} |
| `baremetal` _[Baremetal](#baremetal)_ | {{< unsafe >}}Access data for Baremetal (Tinkerbell only for now).{{< /unsafe >}} |
| `aws` _[AWS](#aws)_ | {{< unsafe >}}Access data for Amazon Web Services(AWS) Cloud.{{< /unsafe >}} |
| `openstack` _[Openstack](#openstack)_ | {{< unsafe >}}Access data for OpenStack.{{< /unsafe >}} |
| `packet` _[Packet](#packet)_ | {{< unsafe >}}Deprecated: The Packet / Equinix Metal provider is deprecated and will be REMOVED IN VERSION 2.29.<br />This provider is no longer supported. Migrate your configurations away from "packet" immediately.<br />Access data for Packet Cloud.{{< /unsafe >}} |
| `gcp` _[GCP](#gcp)_ | {{< unsafe >}}Access data for Google Cloud Platform(GCP).{{< /unsafe >}} |
| `kubevirt` _[Kubevirt](#kubevirt)_ | {{< unsafe >}}Access data for KuberVirt.{{< /unsafe >}} |
| `alibaba` _[Alibaba](#alibaba)_ | {{< unsafe >}}Access data for Alibaba Cloud.{{< /unsafe >}} |
| `anexia` _[Anexia](#anexia)_ | {{< unsafe >}}Access data for Anexia.{{< /unsafe >}} |
| `nutanix` _[Nutanix](#nutanix)_ | {{< unsafe >}}Access data for Nutanix.{{< /unsafe >}} |
| `vmwareclouddirector` _[VMwareCloudDirector](#vmwareclouddirector)_ | {{< unsafe >}}Access data for VMware Cloud Director.{{< /unsafe >}} |
| `gke` _[GKE](#gke)_ | {{< unsafe >}}Access data for Google Kubernetes Engine(GKE).{{< /unsafe >}} |
| `eks` _[EKS](#eks)_ | {{< unsafe >}}Access data for Amazon Elastic Kubernetes Service(EKS).{{< /unsafe >}} |
| `aks` _[AKS](#aks)_ | {{< unsafe >}}Access data for Azure Kubernetes Service(AKS).{{< /unsafe >}} |
| `requiredEmails` _string array_ | {{< unsafe >}}RequiredEmails is a list of e-mail addresses that this presets should<br />be restricted to. Each item in the list can be either a full e-mail<br />address or just a domain name. This restriction is only enforced in the<br />KKP API.{{< /unsafe >}} |
| `projects` _string array_ | {{< unsafe >}}Projects is a list of project IDs that this preset is limited to.{{< /unsafe >}} |
| `enabled` _boolean_ | {{< unsafe >}}Only enabled presets will be available in the KKP dashboard.{{< /unsafe >}} |


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
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[ProjectSpec](#projectspec)_ | {{< unsafe >}}Spec describes the configuration of the project.{{< /unsafe >}} |
| `status` _[ProjectStatus](#projectstatus)_ | {{< unsafe >}}Status holds the current status of the project.{{< /unsafe >}} |


[Back to top](#top)





### ProjectList



ProjectList is a collection of projects.



| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `ProjectList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[Project](#project) array_ | {{< unsafe >}}Items is the list of the projects.{{< /unsafe >}} |


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
| `name` _string_ | {{< unsafe >}}Name is the human-readable name given to the project.{{< /unsafe >}} |
| `allowedOperatingSystems` _[allowedOperatingSystems](#allowedoperatingsystems)_ | {{< unsafe >}}AllowedOperatingSystems defines a map of operating systems that can be used for the machines inside this project.{{< /unsafe >}} |


[Back to top](#top)



### ProjectStatus



ProjectStatus represents the current status of a project.

_Appears in:_
- [Project](#project)

| Field | Description |
| --- | --- |
| `phase` _[ProjectPhase](#projectphase)_ | {{< unsafe >}}Phase describes the project phase. New projects are in the `Inactive`<br />phase; after being reconciled they move to `Active` and during deletion<br />they are `Terminating`.{{< /unsafe >}} |


[Back to top](#top)



### ProviderConfiguration





_Appears in:_
- [SettingSpec](#settingspec)

| Field | Description |
| --- | --- |
| `openStack` _[OpenStack](#openstack)_ | {{< unsafe >}}OpenStack are the configurations for openstack provider.{{< /unsafe >}} |
| `vmwareCloudDirector` _[VMwareCloudDirectorSettings](#vmwareclouddirectorsettings)_ | {{< unsafe >}}VMwareCloudDirector are the configurations for VMware Cloud Director provider.{{< /unsafe >}} |


[Back to top](#top)



### ProviderNetwork

_Underlying type:_ `[struct{Name string "json:\"name\""; VPCs []VPC "json:\"vpcs,omitempty\""; NetworkPolicyEnabled bool "json:\"networkPolicyEnabled,omitempty\""; NetworkPolicy *NetworkPolicy "json:\"networkPolicy,omitempty\""}](#struct{name-string-"json:\"name\"";-vpcs-[]vpc-"json:\"vpcs,omitempty\"";-networkpolicyenabled-bool-"json:\"networkpolicyenabled,omitempty\"";-networkpolicy-*networkpolicy-"json:\"networkpolicy,omitempty\""})`

ProviderNetwork describes the infra cluster network fabric that is being used.

_Appears in:_
- [DatacenterSpecKubevirt](#datacenterspeckubevirt)



### ProviderPreset





_Appears in:_
- [AKS](#aks)
- [AWS](#aws)
- [Alibaba](#alibaba)
- [Anexia](#anexia)
- [Azure](#azure)
- [Baremetal](#baremetal)
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
| `enabled` _boolean_ | {{< unsafe >}}Only enabled presets will be available in the KKP dashboard.{{< /unsafe >}} |
| `isCustomizable` _boolean_ | {{< unsafe >}}IsCustomizable marks a preset as editable on the KKP UI; Customizable presets still have the credentials obscured on the UI, but other fields that are not considered private are displayed during cluster creation. Users can then update those fields, if required.<br />NOTE: This is only supported for OpenStack Cloud Provider in KKP 2.26. Support for other providers will be added later on.{{< /unsafe >}} |
| `datacenter` _string_ | {{< unsafe >}}If datacenter is set, this preset is only applicable to the<br />configured datacenter.{{< /unsafe >}} |


[Back to top](#top)





### ProxySettings



ProxySettings allow configuring a HTTP proxy for the controlplanes
and nodes.

_Appears in:_
- [NodeSettings](#nodesettings)
- [OSMControllerSettings](#osmcontrollersettings)
- [SeedSpec](#seedspec)

| Field | Description |
| --- | --- |
| `httpProxy` _[ProxyValue](#proxyvalue)_ | {{< unsafe >}}Optional: If set, this proxy will be configured for both HTTP and HTTPS.{{< /unsafe >}} |
| `noProxy` _[ProxyValue](#proxyvalue)_ | {{< unsafe >}}Optional: If set this will be set as NO_PROXY environment variable on the node;<br />The value must be a comma-separated list of domains for which no proxy<br />should be used, e.g. "*.example.com,internal.dev".<br />Note that the in-cluster apiserver URL will be automatically prepended<br />to this value.{{< /unsafe >}} |


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
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[ResourceQuotaSpec](#resourcequotaspec)_ | {{< unsafe >}}Spec describes the desired state of the resource quota.{{< /unsafe >}} |
| `status` _[ResourceQuotaStatus](#resourcequotastatus)_ | {{< unsafe >}}Status holds the current state of the resource quota.{{< /unsafe >}} |


[Back to top](#top)



### ResourceQuotaList



ResourceQuotaList is a collection of resource quotas.



| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `ResourceQuotaList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[ResourceQuota](#resourcequota) array_ | {{< unsafe >}}Items is the list of the resource quotas.{{< /unsafe >}} |


[Back to top](#top)



### ResourceQuotaSpec



ResourceQuotaSpec describes the desired state of a resource quota.

_Appears in:_
- [ResourceQuota](#resourcequota)

| Field | Description |
| --- | --- |
| `subject` _[Subject](#subject)_ | {{< unsafe >}}Subject specifies to which entity the quota applies to.{{< /unsafe >}} |
| `quota` _[ResourceDetails](#resourcedetails)_ | {{< unsafe >}}Quota specifies the current maximum allowed usage of resources.{{< /unsafe >}} |


[Back to top](#top)



### ResourceQuotaStatus



ResourceQuotaStatus describes the current state of a resource quota.

_Appears in:_
- [ResourceQuota](#resourcequota)

| Field | Description |
| --- | --- |
| `globalUsage` _[ResourceDetails](#resourcedetails)_ | {{< unsafe >}}GlobalUsage is holds the current usage of resources for all seeds.{{< /unsafe >}} |
| `localUsage` _[ResourceDetails](#resourcedetails)_ | {{< unsafe >}}LocalUsage is holds the current usage of resources for the local seed.{{< /unsafe >}} |


[Back to top](#top)



### RuleGroup





_Appears in:_
- [RuleGroupList](#rulegrouplist)

| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `RuleGroup`
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[RuleGroupSpec](#rulegroupspec)_ | {{< unsafe >}}{{< /unsafe >}} |


[Back to top](#top)



### RuleGroupList







| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `RuleGroupList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[RuleGroup](#rulegroup) array_ | {{< unsafe >}}{{< /unsafe >}} |


[Back to top](#top)



### RuleGroupSpec





_Appears in:_
- [RuleGroup](#rulegroup)

| Field | Description |
| --- | --- |
| `isDefault` _boolean_ | {{< unsafe >}}IsDefault indicates whether the ruleGroup is default{{< /unsafe >}} |
| `ruleGroupType` _[RuleGroupType](#rulegrouptype)_ | {{< unsafe >}}RuleGroupType is the type of this ruleGroup applies to. It can be `Metrics` or `Logs`.{{< /unsafe >}} |
| `cluster` _[ObjectReference](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#objectreference-v1-core)_ | {{< unsafe >}}Cluster is the reference to the cluster the ruleGroup should be created in. All fields<br />except for the name are ignored.{{< /unsafe >}} |
| `data` _integer array_ | {{< unsafe >}}Data contains the RuleGroup data. Ref: https://prometheus.io/docs/prometheus/latest/configuration/recording_rules/#rule_group{{< /unsafe >}} |


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
| `name` _string_ | {{< unsafe >}}Name is the human readable name for this SSH key.{{< /unsafe >}} |
| `owner` _string_ | {{< unsafe >}}Owner is the name of the User object that owns this SSH key.<br />Deprecated: This field is not used anymore.{{< /unsafe >}} |
| `project` _string_ | {{< unsafe >}}Project is the name of the Project object that this SSH key belongs to.<br />This field is immutable.{{< /unsafe >}} |
| `clusters` _string array_ | {{< unsafe >}}Clusters is the list of cluster names that this SSH key is assigned to.{{< /unsafe >}} |
| `fingerprint` _string_ | {{< unsafe >}}Fingerprint is calculated server-side based on the supplied public key<br />and doesn't need to be set by clients.{{< /unsafe >}} |
| `publicKey` _string_ | {{< unsafe >}}PublicKey is the SSH public key.{{< /unsafe >}} |


[Back to top](#top)



### SecretboxEncryptionConfiguration



SecretboxEncryptionConfiguration defines static key encryption based on the 'secretbox' solution for Kubernetes.

_Appears in:_
- [EncryptionConfiguration](#encryptionconfiguration)

| Field | Description |
| --- | --- |
| `keys` _[SecretboxKey](#secretboxkey) array_ | {{< unsafe >}}List of 'secretbox' encryption keys. The first element of this list is considered<br />the "primary" key which will be used for encrypting data while writing it. Additional<br />keys will be used for decrypting data while reading it, if keys higher in the list<br />did not succeed in decrypting it.{{< /unsafe >}} |


[Back to top](#top)



### SecretboxKey



SecretboxKey stores a key or key reference for encrypting Kubernetes API data at rest with a static key.

_Appears in:_
- [SecretboxEncryptionConfiguration](#secretboxencryptionconfiguration)

| Field | Description |
| --- | --- |
| `name` _string_ | {{< unsafe >}}Identifier of a key, used in various places to refer to the key.{{< /unsafe >}} |
| `value` _string_ | {{< unsafe >}}Value contains a 32-byte random key that is base64 encoded. This is the key used<br />for encryption. Can be generated via `head -c 32 /dev/urandom \| base64`, for example.{{< /unsafe >}} |
| `secretRef` _[SecretKeySelector](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#secretkeyselector-v1-core)_ | {{< unsafe >}}Instead of passing the sensitive encryption key via the `value` field, a secret can be<br />referenced. The key of the secret referenced here needs to hold a key equivalent to the `value` field.{{< /unsafe >}} |


[Back to top](#top)



### Seed



Seed is the type representing a Seed cluster. Seed clusters host the control planes
for KKP user clusters.

_Appears in:_
- [SeedList](#seedlist)

| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `Seed`
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[SeedSpec](#seedspec)_ | {{< unsafe >}}Spec describes the configuration of the Seed cluster.{{< /unsafe >}} |
| `status` _[SeedStatus](#seedstatus)_ | {{< unsafe >}}Status holds the runtime information of the Seed cluster.{{< /unsafe >}} |


[Back to top](#top)



### SeedCondition





_Appears in:_
- [SeedStatus](#seedstatus)

| Field | Description |
| --- | --- |
| `status` _[ConditionStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#conditionstatus-v1-core)_ | {{< unsafe >}}Status of the condition, one of True, False, Unknown.{{< /unsafe >}} |
| `lastHeartbeatTime` _[Time](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#time-v1-meta)_ | {{< unsafe >}}Last time we got an update on a given condition.{{< /unsafe >}} |
| `lastTransitionTime` _[Time](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#time-v1-meta)_ | {{< unsafe >}}Last time the condition transit from one status to another.{{< /unsafe >}} |
| `reason` _string_ | {{< unsafe >}}(brief) reason for the condition's last transition.{{< /unsafe >}} |
| `message` _string_ | {{< unsafe >}}Human readable message indicating details about last transition.{{< /unsafe >}} |


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
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[Seed](#seed) array_ | {{< unsafe >}}List of seeds{{< /unsafe >}} |


[Back to top](#top)



### SeedMLASettings



SeedMLASettings allow configuring seed level MLA (Monitoring, Logging & Alerting) stack settings.

_Appears in:_
- [SeedSpec](#seedspec)

| Field | Description |
| --- | --- |
| `userClusterMLAEnabled` _boolean_ | {{< unsafe >}}Optional: UserClusterMLAEnabled controls whether the user cluster MLA (Monitoring, Logging & Alerting) stack is enabled in the seed.{{< /unsafe >}} |


[Back to top](#top)



### SeedPhase

_Underlying type:_ `string`



_Appears in:_
- [SeedStatus](#seedstatus)



### SeedSpec



SeedSpec represents the spec for a seed cluster.

_Appears in:_
- [Seed](#seed)

| Field | Description |
| --- | --- |
| `country` _string_ | {{< unsafe >}}Optional: Country of the seed as ISO-3166 two-letter code, e.g. DE or UK.<br />For informational purposes in the Kubermatic dashboard only.{{< /unsafe >}} |
| `location` _string_ | {{< unsafe >}}Optional: Detailed location of the cluster, like "Hamburg" or "Datacenter 7".<br />For informational purposes in the Kubermatic dashboard only.{{< /unsafe >}} |
| `kubeconfig` _[ObjectReference](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#objectreference-v1-core)_ | {{< unsafe >}}A reference to the Kubeconfig of this cluster. The Kubeconfig must<br />have cluster-admin privileges. This field is mandatory for every<br />seed, even if there are no datacenters defined yet.{{< /unsafe >}} |
| `datacenters` _object (keys:string, values:[Datacenter](#datacenter))_ | {{< unsafe >}}Datacenters contains a map of the possible datacenters (DCs) in this seed.<br />Each DC must have a globally unique identifier (i.e. names must be unique<br />across all seeds).{{< /unsafe >}} |
| `seedDNSOverwrite` _string_ | {{< unsafe >}}Optional: This can be used to override the DNS name used for this seed.<br />By default the seed name is used.{{< /unsafe >}} |
| `nodeportProxy` _[NodeportProxyConfig](#nodeportproxyconfig)_ | {{< unsafe >}}NodeportProxy can be used to configure the NodePort proxy service that is<br />responsible for making user-cluster control planes accessible from the outside.{{< /unsafe >}} |
| `proxySettings` _[ProxySettings](#proxysettings)_ | {{< unsafe >}}Optional: ProxySettings can be used to configure HTTP proxy settings on the<br />worker nodes in user clusters. However, proxy settings on nodes take precedence.{{< /unsafe >}} |
| `exposeStrategy` _[ExposeStrategy](#exposestrategy)_ | {{< unsafe >}}Optional: ExposeStrategy explicitly sets the expose strategy for this seed cluster, if not set, the default provided by the master is used.{{< /unsafe >}} |
| `mla` _[SeedMLASettings](#seedmlasettings)_ | {{< unsafe >}}Optional: MLA allows configuring seed level MLA (Monitoring, Logging & Alerting) stack settings.{{< /unsafe >}} |
| `defaultComponentSettings` _[ComponentSettings](#componentsettings)_ | {{< unsafe >}}DefaultComponentSettings are default values to set for newly created clusters.<br />Deprecated: Use DefaultClusterTemplate instead.{{< /unsafe >}} |
| `defaultClusterTemplate` _string_ | {{< unsafe >}}DefaultClusterTemplate is the name of a cluster template of scope "seed" that is used<br />to default all new created clusters{{< /unsafe >}} |
| `metering` _[MeteringConfiguration](#meteringconfiguration)_ | {{< unsafe >}}Metering configures the metering tool on user clusters across the seed.{{< /unsafe >}} |
| `etcdBackupRestore` _[EtcdBackupRestore](#etcdbackuprestore)_ | {{< unsafe >}}EtcdBackupRestore holds the configuration of the automatic etcd backup restores for the Seed;<br />if this is set, the new backup/restore controllers are enabled for this Seed.{{< /unsafe >}} |
| `oidcProviderConfiguration` _[OIDCProviderConfiguration](#oidcproviderconfiguration)_ | {{< unsafe >}}OIDCProviderConfiguration allows to configure OIDC provider at the Seed level.{{< /unsafe >}} |
| `kubelb` _[KubeLBSeedSettings](#kubelbseedsettings)_ | {{< unsafe >}}KubeLB holds the configuration for the kubeLB at the Seed level. This component is responsible for managing load balancers.<br />Only available in Enterprise Edition.{{< /unsafe >}} |
| `disabledCollectors` _[MetricsCollector](#metricscollector) array_ | {{< unsafe >}}DisabledCollectors contains a list of metrics collectors that should be disabled.<br />Acceptable values are "Addon", "Cluster", "ClusterBackup", "Project", and "None".{{< /unsafe >}} |
| `managementProxySettings` _[ManagementProxySettings](#managementproxysettings)_ | {{< unsafe >}}ManagementProxySettings can be used if the KubeAPI of the user clusters<br />will not be directly available from kkp and a proxy in between should be used{{< /unsafe >}} |
| `defaultAPIServerAllowedIPRanges` _string array_ | {{< unsafe >}}DefaultAPIServerAllowedIPRanges defines a set of CIDR ranges that are **always appended**<br />to the API server's allowed IP ranges for all user clusters in this Seed. These ranges<br />provide a security baseline that cannot be overridden by cluster-specific configurations.{{< /unsafe >}} |
| `auditLogging` _[AuditLoggingSettings](#auditloggingsettings)_ | {{< unsafe >}}Optional: AuditLogging empowers admins to centrally configure Kubernetes API audit logging for all user clusters in the seed (https://kubernetes.io/docs/tasks/debug-application-cluster/audit/ ).{{< /unsafe >}} |


[Back to top](#top)



### SeedStatus



SeedStatus contains runtime information regarding the seed.

_Appears in:_
- [Seed](#seed)

| Field | Description |
| --- | --- |
| `phase` _[SeedPhase](#seedphase)_ | {{< unsafe >}}Phase contains a human readable text to indicate the seed cluster status. No logic should be tied<br />to this field, as its content can change in between KKP releases.{{< /unsafe >}} |
| `clusters` _integer_ | {{< unsafe >}}Clusters is the total number of user clusters that exist on this seed.{{< /unsafe >}} |
| `versions` _[SeedVersionsStatus](#seedversionsstatus)_ | {{< unsafe >}}Versions contains information regarding versions of components in the cluster and the cluster<br />itself.{{< /unsafe >}} |
| `conditions` _object (keys:[SeedConditionType](#seedconditiontype), values:[SeedCondition](#seedcondition))_ | {{< unsafe >}}Conditions contains conditions the seed is in, its primary use case is status signaling<br />between controllers or between controllers and the API.{{< /unsafe >}} |


[Back to top](#top)



### SeedVersionsStatus



SeedVersionsStatus contains information regarding versions of components in the cluster
and the cluster itself.

_Appears in:_
- [SeedStatus](#seedstatus)

| Field | Description |
| --- | --- |
| `kubermatic` _string_ | {{< unsafe >}}Kubermatic is the version of the currently deployed KKP components. Note that a permanent<br />version skew between master and seed is not supported and KKP setups should never run for<br />longer times with a skew between the clusters.{{< /unsafe >}} |
| `cluster` _string_ | {{< unsafe >}}Cluster is the Kubernetes version of the cluster's control plane.{{< /unsafe >}} |


[Back to top](#top)



### ServiceAccountSettings





_Appears in:_
- [ClusterSpec](#clusterspec)

| Field | Description |
| --- | --- |
| `tokenVolumeProjectionEnabled` _boolean_ | {{< unsafe >}}{{< /unsafe >}} |
| `issuer` _string_ | {{< unsafe >}}Issuer is the identifier of the service account token issuer<br />If this is not specified, it will be set to the URL of apiserver by default{{< /unsafe >}} |
| `apiAudiences` _string array_ | {{< unsafe >}}APIAudiences are the Identifiers of the API<br />If this is not specified, it will be set to a single element list containing the issuer URL{{< /unsafe >}} |


[Back to top](#top)



### SettingSpec





_Appears in:_
- [KubermaticSetting](#kubermaticsetting)

| Field | Description |
| --- | --- |
| `customLinks` _[CustomLinks](#customlinks)_ | {{< unsafe >}}CustomLinks are additional links that can be shown the dashboard's footer.{{< /unsafe >}} |
| `defaultNodeCount` _integer_ | {{< unsafe >}}DefaultNodeCount is the default number of replicas for the initial MachineDeployment.{{< /unsafe >}} |
| `displayDemoInfo` _boolean_ | {{< unsafe >}}DisplayDemoInfo controls whether a "Demo System" hint is shown in the footer.{{< /unsafe >}} |
| `displayAPIDocs` _boolean_ | {{< unsafe >}}DisplayDemoInfo controls whether a a link to the KKP API documentation is shown in the footer.{{< /unsafe >}} |
| `displayTermsOfService` _boolean_ | {{< unsafe >}}DisplayDemoInfo controls whether a a link to TOS is shown in the footer.{{< /unsafe >}} |
| `enableDashboard` _boolean_ | {{< unsafe >}}EnableDashboard enables the link to the Kubernetes dashboard for a user cluster.{{< /unsafe >}} |
| `enableWebTerminal` _boolean_ | {{< unsafe >}}EnableWebTerminal enables the Web Terminal feature for the user clusters.<br />Deprecated: EnableWebTerminal is deprecated and should be removed in KKP 2.27+. Please use webTerminalOptions instead. When webTerminalOptions.enabled is set then this field will be ignored.{{< /unsafe >}} |
| `enableShareCluster` _boolean_ | {{< unsafe >}}EnableShareCluster enables the Share Cluster feature for the user clusters.{{< /unsafe >}} |
| `enableOIDCKubeconfig` _boolean_ | {{< unsafe >}}{{< /unsafe >}} |
| `enableClusterBackup` _boolean_ | {{< unsafe >}}EnableClusterBackup enables the Cluster Backup feature in the dashboard.{{< /unsafe >}} |
| `enableEtcdBackup` _boolean_ | {{< unsafe >}}EnableEtcdBackup enables the etcd Backup feature in the dashboard.{{< /unsafe >}} |
| `disableAdminKubeconfig` _boolean_ | {{< unsafe >}}DisableAdminKubeconfig disables the admin kubeconfig functionality on the dashboard.{{< /unsafe >}} |
| `userProjectsLimit` _integer_ | {{< unsafe >}}UserProjectsLimit is the maximum number of projects a user can create.{{< /unsafe >}} |
| `restrictProjectCreation` _boolean_ | {{< unsafe >}}{{< /unsafe >}} |
| `restrictProjectDeletion` _boolean_ | {{< unsafe >}}{{< /unsafe >}} |
| `enableExternalClusterImport` _boolean_ | {{< unsafe >}}{{< /unsafe >}} |
| `cleanupOptions` _[CleanupOptions](#cleanupoptions)_ | {{< unsafe >}}CleanupOptions control what happens when a cluster is deleted via the dashboard.{{< /unsafe >}} |
| `opaOptions` _[OpaOptions](#opaoptions)_ | {{< unsafe >}}{{< /unsafe >}} |
| `mlaOptions` _[MlaOptions](#mlaoptions)_ | {{< unsafe >}}{{< /unsafe >}} |
| `mlaAlertmanagerPrefix` _string_ | {{< unsafe >}}{{< /unsafe >}} |
| `mlaGrafanaPrefix` _string_ | {{< unsafe >}}{{< /unsafe >}} |
| `notifications` _[NotificationsOptions](#notificationsoptions)_ | {{< unsafe >}}Notifications are the configuration for notifications on dashboard.{{< /unsafe >}} |
| `providerConfiguration` _[ProviderConfiguration](#providerconfiguration)_ | {{< unsafe >}}ProviderConfiguration are the cloud provider specific configurations on dashboard.{{< /unsafe >}} |
| `webTerminalOptions` _[WebTerminalOptions](#webterminaloptions)_ | {{< unsafe >}}WebTerminalOptions are the configurations for the Web Terminal feature.{{< /unsafe >}} |
| `machineDeploymentVMResourceQuota` _[MachineFlavorFilter](#machineflavorfilter)_ | {{< unsafe >}}MachineDeploymentVMResourceQuota is used to filter out allowed machine flavors based on the specified resource limits like CPU, Memory, and GPU etc.{{< /unsafe >}} |
| `allowedOperatingSystems` _[allowedOperatingSystems](#allowedoperatingsystems)_ | {{< unsafe >}}AllowedOperatingSystems shows if the operating system is allowed to be use in the machinedeployment.{{< /unsafe >}} |
| `defaultQuota` _[DefaultProjectResourceQuota](#defaultprojectresourcequota)_ | {{< unsafe >}}DefaultProjectResourceQuota allows to configure a default project resource quota which<br />will be set for all projects that do not have a custom quota already set. EE-version only.{{< /unsafe >}} |
| `machineDeploymentOptions` _[MachineDeploymentOptions](#machinedeploymentoptions)_ | {{< unsafe >}}{{< /unsafe >}} |
| `disableChangelogPopup` _boolean_ | {{< unsafe >}}DisableChangelogPopup disables the changelog popup in KKP dashboard.{{< /unsafe >}} |
| `staticLabels` _[StaticLabel](#staticlabel) array_ | {{< unsafe >}}StaticLabels are a list of labels that can be used for the clusters.{{< /unsafe >}} |
| `annotations` _[AnnotationSettings](#annotationsettings)_ | {{< unsafe >}}Annotations are the settings for the annotations in KKP UI.{{< /unsafe >}} |
| `announcements` _object (keys:string, values:[Announcement](#announcement))_ | {{< unsafe >}}The announcement feature allows administrators to broadcast important messages to all users.{{< /unsafe >}} |
| `clusterBackupOptions` _[ClusterBackupOptions](#clusterbackupoptions)_ | {{< unsafe >}}{{< /unsafe >}} |


[Back to top](#top)



### StatefulSetSettings





_Appears in:_
- [ComponentSettings](#componentsettings)

| Field | Description |
| --- | --- |
| `replicas` _integer_ | {{< unsafe >}}{{< /unsafe >}} |
| `resources` _[ResourceRequirements](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#resourcerequirements-v1-core)_ | {{< unsafe >}}{{< /unsafe >}} |
| `tolerations` _[Toleration](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#toleration-v1-core) array_ | {{< unsafe >}}{{< /unsafe >}} |


[Back to top](#top)



### StaticLabel



StaticLabel is a label that can be used for the clusters.

_Appears in:_
- [SettingSpec](#settingspec)

| Field | Description |
| --- | --- |
| `key` _string_ | {{< unsafe >}}{{< /unsafe >}} |
| `values` _string array_ | {{< unsafe >}}{{< /unsafe >}} |
| `default` _boolean_ | {{< unsafe >}}{{< /unsafe >}} |
| `protected` _boolean_ | {{< unsafe >}}{{< /unsafe >}} |


[Back to top](#top)



### Subject



Subject describes the entity to which the quota applies to.

_Appears in:_
- [ResourceQuotaSpec](#resourcequotaspec)

| Field | Description |
| --- | --- |
| `name` _string_ | {{< unsafe >}}Name of the quota subject.{{< /unsafe >}} |


[Back to top](#top)



### Subnet



Subnet a smaller, segmented portion of a larger network, like a Virtual Private Cloud (VPC).

_Appears in:_
- [VPC](#vpc)

| Field | Description |
| --- | --- |
| `name` _string_ | {{< unsafe >}}{{< /unsafe >}} |
| `zones` _string array_ | {{< unsafe >}}Zones represent a logical failure domain. It is common for Kubernetes clusters to span multiple zones<br />for increased availability{{< /unsafe >}} |
| `regions` _string array_ | {{< unsafe >}}Regions represents a larger domain, made up of one or more zones. It is uncommon for Kubernetes clusters<br />to span multiple regions{{< /unsafe >}} |


[Back to top](#top)



### SubnetCIDR

_Underlying type:_ `string`

SubnetCIDR is used to store IPv4/IPv6 CIDR.

_Appears in:_
- [IPAMAllocationSpec](#ipamallocationspec)
- [IPAMPoolDatacenterSettings](#ipampooldatacentersettings)



### SystemApplicationOptions





_Appears in:_
- [KubermaticConfigurationSpec](#kubermaticconfigurationspec)

| Field | Description |
| --- | --- |
| `disable` _boolean_ | {{< unsafe >}}Disable is used to disable the installation of system application definitions in the master cluster.{{< /unsafe >}} |
| `applications` _string array_ | {{< unsafe >}}Applications is a list of system application definition names that should be installed in the master cluster.<br />If not set, the default system applications will be installed.{{< /unsafe >}} |


[Back to top](#top)



### SystemApplicationsConfiguration



SystemApplicationsConfiguration contains configuration for system Applications (e.g. CNI).

_Appears in:_
- [KubermaticUserClusterConfiguration](#kubermaticuserclusterconfiguration)

| Field | Description |
| --- | --- |
| `helmRepository` _string_ | {{< unsafe >}}HelmRepository specifies OCI repository containing Helm charts of system Applications e.g. oci://localhost:5000/myrepo.{{< /unsafe >}} |
| `helmRegistryConfigFile` _[SecretKeySelector](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#secretkeyselector-v1-core)_ | {{< unsafe >}}HelmRegistryConfigFile optionally holds the ref and key in the secret for the OCI registry credential file.<br />The value is dockercfg file that follows the same format rules as ~/.docker/config.json<br />The Secret must exist in the namespace where KKP is installed (default is "kubermatic").<br />The Secret must be annotated with `apps.kubermatic.k8c.io/secret-type:` set to "helm".{{< /unsafe >}} |


[Back to top](#top)



### Tinkerbell





_Appears in:_
- [Baremetal](#baremetal)

| Field | Description |
| --- | --- |
| `kubeconfig` _string_ | {{< unsafe >}}Kubeconfig is the cluster's kubeconfig file, encoded with base64.{{< /unsafe >}} |


[Back to top](#top)



### TinkerbellCloudSpec





_Appears in:_
- [BaremetalCloudSpec](#baremetalcloudspec)

| Field | Description |
| --- | --- |
| `kubeconfig` _string_ | {{< unsafe >}}The cluster's kubeconfig file, encoded with base64.{{< /unsafe >}} |


[Back to top](#top)



### TinkerbellHTTPSource



TinkerbellHTTPSource represents list of images and their versions that can be downloaded over HTTP.

_Appears in:_
- [TinkerbellImageSources](#tinkerbellimagesources)

| Field | Description |
| --- | --- |
| `operatingSystems` _object (keys:OperatingSystem, values:[OSVersions](#osversions))_ | {{< unsafe >}}OperatingSystems represents list of supported operating-systems with their URLs.{{< /unsafe >}} |


[Back to top](#top)





### Update



Update represents an update option for a user cluster.

_Appears in:_
- [KubermaticVersioningConfiguration](#kubermaticversioningconfiguration)

| Field | Description |
| --- | --- |
| `from` _string_ | {{< unsafe >}}From is the version from which an update is allowed. Wildcards are allowed, e.g. "1.18.*".{{< /unsafe >}} |
| `to` _string_ | {{< unsafe >}}To is the version to which an update is allowed.<br />Must be a valid version if `automatic` is set to true, e.g. "1.20.13".<br />Can be a wildcard otherwise, e.g. "1.20.*".{{< /unsafe >}} |
| `automatic` _boolean_ | {{< unsafe >}}Automatic controls whether this update is executed automatically<br />for the control plane of all matching user clusters.<br />---{{< /unsafe >}} |
| `automaticNodeUpdate` _boolean_ | {{< unsafe >}}Automatic controls whether this update is executed automatically<br />for the worker nodes of all matching user clusters.<br />---{{< /unsafe >}} |


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
| `start` _string_ | {{< unsafe >}}Sets the start time of the update window. This can be a time of day in 24h format, e.g. `22:30`,<br />or a day of week plus a time of day, for example `Mon 21:00`. Only short names for week days are supported,<br />i.e. `Mon`, `Tue`, `Wed`, `Thu`, `Fri`, `Sat` and `Sun`.{{< /unsafe >}} |
| `length` _string_ | {{< unsafe >}}Sets the length of the update window beginning with the start time. This needs to be a valid duration<br />as parsed by Go's time.ParseDuration (https://pkg.go.dev/time#ParseDuration), e.g. `2h`.{{< /unsafe >}} |


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
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[UserSpec](#userspec)_ | {{< unsafe >}}Spec describes a KKP user.{{< /unsafe >}} |
| `status` _[UserStatus](#userstatus)_ | {{< unsafe >}}Status holds the information about the KKP user.{{< /unsafe >}} |


[Back to top](#top)



### UserList



UserList is a list of users.



| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `UserList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[User](#user) array_ | {{< unsafe >}}Items is the list of KKP users.{{< /unsafe >}} |


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
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[UserProjectBindingSpec](#userprojectbindingspec)_ | {{< unsafe >}}Spec describes a KKP user and project binding.{{< /unsafe >}} |


[Back to top](#top)



### UserProjectBindingList



UserProjectBindingList is a list of KKP user and project bindings.



| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `UserProjectBindingList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[UserProjectBinding](#userprojectbinding) array_ | {{< unsafe >}}Items is the list of KKP user and project bindings.{{< /unsafe >}} |


[Back to top](#top)



### UserProjectBindingSpec



UserProjectBindingSpec specifies a user and project binding.

_Appears in:_
- [UserProjectBinding](#userprojectbinding)

| Field | Description |
| --- | --- |
| `userEmail` _string_ | {{< unsafe >}}UserEmail is the email of the user that is bound to the given project.{{< /unsafe >}} |
| `projectID` _string_ | {{< unsafe >}}ProjectID is the name of the target project.{{< /unsafe >}} |
| `group` _string_ | {{< unsafe >}}Group is the user's group, determining their permissions within the project.<br />Must be one of `owners`, `editors`, `viewers` or `projectmanagers`.{{< /unsafe >}} |


[Back to top](#top)



### UserSSHKey



UserSSHKey specifies a users UserSSHKey.

_Appears in:_
- [UserSSHKeyList](#usersshkeylist)

| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `UserSSHKey`
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[SSHKeySpec](#sshkeyspec)_ | {{< unsafe >}}{{< /unsafe >}} |


[Back to top](#top)



### UserSSHKeyList



UserSSHKeyList specifies a users UserSSHKey.



| Field | Description |
| --- | --- |
| `apiVersion` _string_ | `kubermatic.k8c.io/v1`
| `kind` _string_ | `UserSSHKeyList`
| `metadata` _[ListMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#listmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `items` _[UserSSHKey](#usersshkey) array_ | {{< unsafe >}}{{< /unsafe >}} |


[Back to top](#top)



### UserSettings



UserSettings represent an user settings.

_Appears in:_
- [UserSpec](#userspec)

| Field | Description |
| --- | --- |
| `selectedTheme` _string_ | {{< unsafe >}}{{< /unsafe >}} |
| `itemsPerPage` _integer_ | {{< unsafe >}}{{< /unsafe >}} |
| `selectedProjectID` _string_ | {{< unsafe >}}{{< /unsafe >}} |
| `selectProjectTableView` _boolean_ | {{< unsafe >}}{{< /unsafe >}} |
| `collapseSidenav` _boolean_ | {{< unsafe >}}{{< /unsafe >}} |
| `displayAllProjectsForAdmin` _boolean_ | {{< unsafe >}}{{< /unsafe >}} |
| `lastSeenChangelogVersion` _string_ | {{< unsafe >}}{{< /unsafe >}} |
| `useClustersView` _boolean_ | {{< unsafe >}}{{< /unsafe >}} |


[Back to top](#top)



### UserSpec



UserSpec specifies a user.

_Appears in:_
- [User](#user)

| Field | Description |
| --- | --- |
| `id` _string_ | {{< unsafe >}}ID is an unused legacy field.<br />Deprecated: do not set this field anymore.{{< /unsafe >}} |
| `name` _string_ | {{< unsafe >}}Name is the full name of this user.{{< /unsafe >}} |
| `email` _string_ | {{< unsafe >}}Email is the email address of this user. Emails must be globally unique across<br />all KKP users.{{< /unsafe >}} |
| `admin` _boolean_ | {{< unsafe >}}IsAdmin defines whether this user is an administrator with additional permissions.<br />Admins can for example see all projects and clusters in the KKP dashboard.{{< /unsafe >}} |
| `isGlobalViewer` _boolean_ | {{< unsafe >}}IsGlobalViewer defines whether this user is a global viewer with read-only access across the KKP dashboard.<br />GlobalViewer can for example see all projects and clusters in the KKP dashboard.{{< /unsafe >}} |
| `groups` _string array_ | {{< unsafe >}}Groups holds the information to which groups the user belongs to. Set automatically when logging in to the<br />KKP API, and used by the KKP API.{{< /unsafe >}} |
| `project` _string_ | {{< unsafe >}}Project is the name of the project that this service account user is tied to. This<br />field is only applicable to service accounts and regular users must not set this field.{{< /unsafe >}} |
| `settings` _[UserSettings](#usersettings)_ | {{< unsafe >}}Settings contains both user-configurable and system-owned configuration for the<br />KKP dashboard.{{< /unsafe >}} |
| `invalidTokensReference` _[GlobalSecretKeySelector](#globalsecretkeyselector)_ | {{< unsafe >}}InvalidTokensReference is a reference to a Secret that contains invalidated<br />login tokens. The tokens are used to provide a safe logout mechanism.{{< /unsafe >}} |
| `readAnnouncements` _string array_ | {{< unsafe >}}ReadAnnouncements holds the IDs of admin announcements that the user has read.{{< /unsafe >}} |


[Back to top](#top)



### UserStatus



UserStatus stores status information about a user.

_Appears in:_
- [User](#user)

| Field | Description |
| --- | --- |
| `lastSeen` _[Time](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#time-v1-meta)_ | {{< unsafe >}}{{< /unsafe >}} |


[Back to top](#top)



### VMwareCloudDirector





_Appears in:_
- [PresetSpec](#presetspec)

| Field | Description |
| --- | --- |
| `enabled` _boolean_ | {{< unsafe >}}Only enabled presets will be available in the KKP dashboard.{{< /unsafe >}} |
| `isCustomizable` _boolean_ | {{< unsafe >}}IsCustomizable marks a preset as editable on the KKP UI; Customizable presets still have the credentials obscured on the UI, but other fields that are not considered private are displayed during cluster creation. Users can then update those fields, if required.<br />NOTE: This is only supported for OpenStack Cloud Provider in KKP 2.26. Support for other providers will be added later on.{{< /unsafe >}} |
| `datacenter` _string_ | {{< unsafe >}}If datacenter is set, this preset is only applicable to the<br />configured datacenter.{{< /unsafe >}} |
| `username` _string_ | {{< unsafe >}}The VMware Cloud Director user name.{{< /unsafe >}} |
| `password` _string_ | {{< unsafe >}}The VMware Cloud Director user password.{{< /unsafe >}} |
| `apiToken` _string_ | {{< unsafe >}}The VMware Cloud Director API token.{{< /unsafe >}} |
| `vdc` _string_ | {{< unsafe >}}The organizational virtual data center.{{< /unsafe >}} |
| `organization` _string_ | {{< unsafe >}}The name of organization to use.{{< /unsafe >}} |
| `ovdcNetwork` _string_ | {{< unsafe >}}The name of organizational virtual data center network that will be associated with the VMs and vApp.<br />Deprecated: OVDCNetwork has been deprecated starting with KKP 2.25 and will be removed in KKP 2.27+. It is recommended to use OVDCNetworks instead.{{< /unsafe >}} |
| `ovdcNetworks` _string array_ | {{< unsafe >}}OVDCNetworks is the list of organizational virtual data center networks that will be attached to the vApp and can be consumed the VMs.{{< /unsafe >}} |


[Back to top](#top)



### VMwareCloudDirectorCSIConfig





_Appears in:_
- [VMwareCloudDirectorCloudSpec](#vmwareclouddirectorcloudspec)

| Field | Description |
| --- | --- |
| `storageProfile` _string_ | {{< unsafe >}}The name of the storage profile to use for disks created by CSI driver{{< /unsafe >}} |
| `filesystem` _string_ | {{< unsafe >}}Filesystem to use for named disks, defaults to "ext4"{{< /unsafe >}} |


[Back to top](#top)



### VMwareCloudDirectorCloudSpec



VMwareCloudDirectorCloudSpec specifies access data to VMware Cloud Director cloud.

_Appears in:_
- [CloudSpec](#cloudspec)

| Field | Description |
| --- | --- |
| `credentialsReference` _[GlobalSecretKeySelector](#globalsecretkeyselector)_ | {{< unsafe >}}{{< /unsafe >}} |
| `username` _string_ | {{< unsafe >}}The VMware Cloud Director user name.{{< /unsafe >}} |
| `password` _string_ | {{< unsafe >}}The VMware Cloud Director user password.{{< /unsafe >}} |
| `apiToken` _string_ | {{< unsafe >}}The VMware Cloud Director API token.{{< /unsafe >}} |
| `organization` _string_ | {{< unsafe >}}The name of organization to use.{{< /unsafe >}} |
| `vdc` _string_ | {{< unsafe >}}The organizational virtual data center.{{< /unsafe >}} |
| `ovdcNetwork` _string_ | {{< unsafe >}}The name of organizational virtual data center network that will be associated with the VMs and vApp.<br />Deprecated: OVDCNetwork has been deprecated starting with KKP 2.25 and will be removed in KKP 2.27+. It is recommended to use OVDCNetworks instead.{{< /unsafe >}} |
| `ovdcNetworks` _string array_ | {{< unsafe >}}OVDCNetworks is the list of organizational virtual data center networks that will be attached to the vApp and can be consumed the VMs.{{< /unsafe >}} |
| `vapp` _string_ | {{< unsafe >}}VApp used for isolation of VMs and their associated network{{< /unsafe >}} |
| `csi` _[VMwareCloudDirectorCSIConfig](#vmwareclouddirectorcsiconfig)_ | {{< unsafe >}}Config for CSI driver{{< /unsafe >}} |


[Back to top](#top)



### VMwareCloudDirectorSettings





_Appears in:_
- [ProviderConfiguration](#providerconfiguration)

| Field | Description |
| --- | --- |
| `ipAllocationModes` _[ipAllocationMode](#ipallocationmode) array_ | {{< unsafe >}}IPAllocationModes are the allowed IP allocation modes for the VMware Cloud Director provider. If not set, all modes are allowed.{{< /unsafe >}} |


[Back to top](#top)





### VSphere





_Appears in:_
- [PresetSpec](#presetspec)

| Field | Description |
| --- | --- |
| `enabled` _boolean_ | {{< unsafe >}}Only enabled presets will be available in the KKP dashboard.{{< /unsafe >}} |
| `isCustomizable` _boolean_ | {{< unsafe >}}IsCustomizable marks a preset as editable on the KKP UI; Customizable presets still have the credentials obscured on the UI, but other fields that are not considered private are displayed during cluster creation. Users can then update those fields, if required.<br />NOTE: This is only supported for OpenStack Cloud Provider in KKP 2.26. Support for other providers will be added later on.{{< /unsafe >}} |
| `datacenter` _string_ | {{< unsafe >}}If datacenter is set, this preset is only applicable to the<br />configured datacenter.{{< /unsafe >}} |
| `username` _string_ | {{< unsafe >}}The vSphere user name.{{< /unsafe >}} |
| `password` _string_ | {{< unsafe >}}The vSphere user password.{{< /unsafe >}} |
| `vmNetName` _string_ | {{< unsafe >}}Deprecated: Use networks instead.{{< /unsafe >}} |
| `networks` _string array_ | {{< unsafe >}}List of vSphere networks.{{< /unsafe >}} |
| `datastore` _string_ | {{< unsafe >}}Datastore to be used for storing virtual machines and as a default for dynamic volume provisioning, it is mutually exclusive with DatastoreCluster.{{< /unsafe >}} |
| `datastoreCluster` _string_ | {{< unsafe >}}DatastoreCluster to be used for storing virtual machines, it is mutually exclusive with Datastore.{{< /unsafe >}} |
| `resourcePool` _string_ | {{< unsafe >}}ResourcePool is used to manage resources such as cpu and memory for vSphere virtual machines. The resource pool should be defined on vSphere cluster level.{{< /unsafe >}} |
| `basePath` _string_ | {{< unsafe >}}BasePath configures a vCenter folder path that KKP will create an individual cluster folder in.<br />If it's an absolute path, the RootPath configured in the datacenter will be ignored. If it is a relative path,<br />the BasePath part will be appended to the RootPath to construct the full path. For both cases,<br />the full folder structure needs to exist. KKP will only try to create the cluster folder.{{< /unsafe >}} |


[Back to top](#top)



### VSphereCloudSpec



VSphereCloudSpec specifies access data to VSphere cloud.

_Appears in:_
- [CloudSpec](#cloudspec)

| Field | Description |
| --- | --- |
| `credentialsReference` _[GlobalSecretKeySelector](#globalsecretkeyselector)_ | {{< unsafe >}}{{< /unsafe >}} |
| `username` _string_ | {{< unsafe >}}The vSphere user name.{{< /unsafe >}} |
| `password` _string_ | {{< unsafe >}}The vSphere user password.{{< /unsafe >}} |
| `vmNetName` _string_ | {{< unsafe >}}The name of the vSphere network.<br />Deprecated: Use networks instead.{{< /unsafe >}} |
| `networks` _string array_ | {{< unsafe >}}List of vSphere networks.{{< /unsafe >}} |
| `folder` _string_ | {{< unsafe >}}Folder to be used to group the provisioned virtual<br />machines.{{< /unsafe >}} |
| `basePath` _string_ | {{< unsafe >}}Optional: BasePath configures a vCenter folder path that KKP will create an individual cluster folder in.<br />If it's an absolute path, the RootPath configured in the datacenter will be ignored. If it is a relative path,<br />the BasePath part will be appended to the RootPath to construct the full path. For both cases,<br />the full folder structure needs to exist. KKP will only try to create the cluster folder.{{< /unsafe >}} |
| `datastore` _string_ | {{< unsafe >}}Datastore to be used for storing virtual machines and as a default for<br />dynamic volume provisioning, it is mutually exclusive with<br />DatastoreCluster.{{< /unsafe >}} |
| `datastoreCluster` _string_ | {{< unsafe >}}DatastoreCluster to be used for storing virtual machines, it is mutually<br />exclusive with Datastore.{{< /unsafe >}} |
| `storagePolicy` _string_ | {{< unsafe >}}StoragePolicy to be used for storage provisioning{{< /unsafe >}} |
| `resourcePool` _string_ | {{< unsafe >}}ResourcePool is used to manage resources such as cpu and memory for vSphere virtual machines. The resource pool<br />should be defined on vSphere cluster level.{{< /unsafe >}} |
| `infraManagementUser` _[VSphereCredentials](#vspherecredentials)_ | {{< unsafe >}}This user will be used for everything except cloud provider functionality{{< /unsafe >}} |
| `tags` _[VSphereTag](#vspheretag)_ | {{< unsafe >}}Tags represents the tags that are attached or created on the cluster level, that are then propagated down to the<br />MachineDeployments. In order to attach tags on MachineDeployment, users must create the tag on a cluster level first<br />then attach that tag on the MachineDeployment.{{< /unsafe >}} |


[Back to top](#top)



### VSphereCredentials



VSphereCredentials credentials represents a credential for accessing vSphere.

_Appears in:_
- [DatacenterSpecVSphere](#datacenterspecvsphere)
- [VSphereCloudSpec](#vspherecloudspec)

| Field | Description |
| --- | --- |
| `username` _string_ | {{< unsafe >}}{{< /unsafe >}} |
| `password` _string_ | {{< unsafe >}}{{< /unsafe >}} |


[Back to top](#top)



### VSphereTag



VSphereTag represents the tags that are attached or created on the cluster level, that are then propagated down to the
MachineDeployments. In order to attach tags on MachineDeployment, users must create the tag on a cluster level first
then attach that tag on the MachineDeployment.

_Appears in:_
- [VSphereCloudSpec](#vspherecloudspec)

| Field | Description |
| --- | --- |
| `tags` _string array_ | {{< unsafe >}}Tags represents the name of the created tags.{{< /unsafe >}} |
| `categoryID` _string_ | {{< unsafe >}}CategoryID is the id of the vsphere category that the tag belongs to. If the category id is left empty, the default<br />category id for the cluster will be used.{{< /unsafe >}} |


[Back to top](#top)



### WebTerminalOptions





_Appears in:_
- [SettingSpec](#settingspec)

| Field | Description |
| --- | --- |
| `enabled` _boolean_ | {{< unsafe >}}Enabled enables the Web Terminal feature for the user clusters.{{< /unsafe >}} |
| `enableInternetAccess` _boolean_ | {{< unsafe >}}EnableInternetAccess enables the Web Terminal feature to access the internet.{{< /unsafe >}} |
| `additionalEnvironmentVariables` _[EnvVar](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.33/#envvar-v1-core) array_ | {{< unsafe >}}AdditionalEnvironmentVariables are the additional environment variables that can be set for the Web Terminal.{{< /unsafe >}} |


[Back to top](#top)



