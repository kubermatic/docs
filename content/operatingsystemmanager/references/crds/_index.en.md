+++
title = "OperatingSystemManager CRDs Reference"
date = 2022-08-20T12:00:00+02:00
weight = 40
+++

## Packages
- [operatingsystemmanager.k8c.io/v1alpha1](#operatingsystemmanagerk8ciov1alpha1)


## operatingsystemmanager.k8c.io/v1alpha1

Package v1alpha1 defines the v1alpha1 version of the OSM API



### CloudInitModule



CloudInitModule contains the fields of the cloud init module.

_Appears in:_
- [OSCConfig](#oscconfig)
- [OSPConfig](#ospconfig)

| Field | Description |
| --- | --- |
| `bootcmd` _string array_ | BootCMD module runs arbitrary commands very early in the boot process, only slightly after a boothook would run. |
| `rh_subscription` _object (keys:string, values:string)_ | RHSubscription registers a Red Hat system either by username and password or activation and org |
| `runcmd` _string array_ | RunCMD Run arbitrary commands at a rc.local like level with output to the console. |
| `yum_repos` _object (keys:string, values:object)_ | YumRepos adds yum repository configuration to the system. |
| `yum_repo_dir` _string_ | YumRepoDir the repo parts directory where individual yum repo config files will be written. Default: /etc/yum.repos.d |


[Back to top](#top)



### CloudProviderSpec



CloudProviderSpec contains the os/image reference for a specific supported cloud provider

_Appears in:_
- [OperatingSystemConfigSpec](#operatingsystemconfigspec)
- [OperatingSystemProfileSpec](#operatingsystemprofilespec)

| Field | Description |
| --- | --- |
| `name` _CloudProvider_ | Name represents the name of the supported cloud provider |
| `spec` _[RawExtension](#rawextension)_ | Spec represents the os/image reference in the supported cloud provider |


[Back to top](#top)



### ContainerRuntimeSpec



ContainerRuntimeSpec aggregates information about a specific container runtime

_Appears in:_
- [OSPConfig](#ospconfig)

| Field | Description |
| --- | --- |
| `name` _ContainerRuntime_ | Name of the Container runtime |
| `files` _[File](#file) array_ | Files to add to the main files list when the containerRuntime is selected |
| `templates` _object (keys:string, values:string)_ | Templates to add to the available templates when the containerRuntime is selected |


[Back to top](#top)



### DropIn



DropIn is a drop-in configuration for a systemd unit.

_Appears in:_
- [Unit](#unit)

| Field | Description |
| --- | --- |
| `name` _string_ | Name is the name of the drop-in. |
| `content` _string_ | Content is the content of the drop-in. |


[Back to top](#top)



### File



File is a file that should get written to the host's file system. The content can either be inlined or referenced from a secret in the same namespace.

_Appears in:_
- [ContainerRuntimeSpec](#containerruntimespec)
- [OSCConfig](#oscconfig)
- [OSPConfig](#ospconfig)

| Field | Description |
| --- | --- |
| `path` _string_ | Path is the path of the file system where the file should get written to. |
| `permissions` _integer_ | Permissions describes with which permissions the file should get written to the file system. Should be in decimal base and without any leading zeroes. |
| `content` _[FileContent](#filecontent)_ | Content describe the file's content. |


[Back to top](#top)



### FileContent



FileContent can either reference a secret or contain inline configuration.

_Appears in:_
- [File](#file)

| Field | Description |
| --- | --- |
| `inline` _[FileContentInline](#filecontentinline)_ | Inline is a struct that contains information about the inlined data. |


[Back to top](#top)



### FileContentInline



FileContentInline contains keys for inlining a file content's data and encoding.

_Appears in:_
- [FileContent](#filecontent)

| Field | Description |
| --- | --- |
| `encoding` _string_ | Encoding is the file's encoding (e.g. base64). |
| `data` _string_ | Data is the file's data. |


[Back to top](#top)



### OSCConfig





_Appears in:_
- [OperatingSystemConfigSpec](#operatingsystemconfigspec)

| Field | Description |
| --- | --- |
| `units` _[Unit](#unit) array_ | Units a list of the systemd unit files which will run on the instance |
| `files` _[File](#file) array_ | Files is a list of files that should exist in the instance |
| `userSSHKeys` _string array_ | UserSSHKeys is a list of attached user ssh keys |
| `modules` _[CloudInitModule](#cloudinitmodule)_ | CloudInitModules contains the supported cloud-init modules |


[Back to top](#top)



### OSPConfig





_Appears in:_
- [OperatingSystemProfileSpec](#operatingsystemprofilespec)

| Field | Description |
| --- | --- |
| `supportedContainerRuntimes` _[ContainerRuntimeSpec](#containerruntimespec) array_ | SupportedContainerRuntimes represents the container runtimes supported by the given OS |
| `templates` _object (keys:string, values:string)_ | Templates to be included in units and files |
| `units` _[Unit](#unit) array_ | Units a list of the systemd unit files which will run on the instance |
| `files` _[File](#file) array_ | Files is a list of files that should exist in the instance |
| `modules` _[CloudInitModule](#cloudinitmodule)_ | CloudInitModules field contains the optional cloud-init modules which are supported by OSM |


[Back to top](#top)



### OperatingSystemConfig



OperatingSystemConfig is the object that represents the OperatingSystemConfig

_Appears in:_
- [OperatingSystemConfigList](#operatingsystemconfiglist)

| Field | Description |
| --- | --- |
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.26/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[OperatingSystemConfigSpec](#operatingsystemconfigspec)_ | OperatingSystemConfigSpec represents the operating system configuration spec. |


[Back to top](#top)





### OperatingSystemConfigSpec



OperatingSystemConfigSpec represents the data in the newly created OperatingSystemConfig

_Appears in:_
- [OperatingSystemConfig](#operatingsystemconfig)

| Field | Description |
| --- | --- |
| `osName` _OperatingSystem_ | OSType represent the operating system name e.g: ubuntu |
| `osVersion` _string_ | OSVersion the version of the operating system |
| `cloudProvider` _[CloudProviderSpec](#cloudproviderspec)_ | CloudProvider represent the cloud provider that support the given operating system version |
| `bootstrapConfig` _[OSCConfig](#oscconfig)_ | BootstrapConfig is used for initial configuration of machine and to fetch the kubernetes secret that contains the provisioning config. |
| `provisioningConfig` _[OSCConfig](#oscconfig)_ | ProvisioningConfig is used for provisioning the worker node. |
| `provisioningUtility` _ProvisioningUtility_ | ProvisioningUtility used for configuring the worker node. Defaults to cloud-init. |


[Back to top](#top)



### OperatingSystemProfile



OperatingSystemProfile is the object that represents the OperatingSystemProfile

_Appears in:_
- [OperatingSystemProfileList](#operatingsystemprofilelist)

| Field | Description |
| --- | --- |
| `metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.26/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`. |
| `spec` _[OperatingSystemProfileSpec](#operatingsystemprofilespec)_ | OperatingSystemProfileSpec represents the operating system configuration spec. |


[Back to top](#top)





### OperatingSystemProfileSpec



OperatingSystemProfileSpec represents the data in the newly created OperatingSystemProfile

_Appears in:_
- [OperatingSystemProfile](#operatingsystemprofile)

| Field | Description |
| --- | --- |
| `osName` _OperatingSystem_ | OSType represent the operating system name e.g: ubuntu |
| `osVersion` _string_ | OSVersion the version of the operating system |
| `version` _string_ | Version is the version of the operating System Profile |
| `supportedCloudProviders` _[CloudProviderSpec](#cloudproviderspec) array_ | SupportedCloudProviders represent the cloud providers that support the given operating system version |
| `bootstrapConfig` _[OSPConfig](#ospconfig)_ | BootstrapConfig is used for initial configuration of machine and to fetch the kubernetes secret that contains the provisioning config. |
| `provisioningConfig` _[OSPConfig](#ospconfig)_ | ProvisioningConfig is used for provisioning the worker node. |
| `provisioningUtility` _ProvisioningUtility_ | ProvisioningUtility used for configuring the worker node. Defaults to cloud-init. |


[Back to top](#top)



### Unit



Unit is a systemd unit used for the operating system config.

_Appears in:_
- [OSCConfig](#oscconfig)
- [OSPConfig](#ospconfig)

| Field | Description |
| --- | --- |
| `name` _string_ | Name is the name of a unit. |
| `enable` _boolean_ | Enable describes whether the unit is enabled or not. |
| `mask` _boolean_ | Mask describes whether the unit is masked or not. |
| `content` _string_ | Content is the unit's content. |
| `dropIns` _[DropIn](#dropin) array_ | DropIns is a list of drop-ins for this unit. |


[Back to top](#top)