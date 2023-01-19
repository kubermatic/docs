+++
title = "Migrating to the KubeOneCluster v1beta1 API"
date = 2020-04-01T12:00:00+02:00
weight = 2
+++

Starting with `v1.0.0`, KubeOne comes with a new, `v1beta1` version of the
KubeOneCluster API. The new API is similar to the v1alpha1 API, with
a couple of improvements.

This document shows how to migrate from the v1alpha1 API to the v1beta1
API, as well as, what has been changed between two versions.

It remains possible to use all KubeOne commands with the v1alpha1 manifest,
however, it's strongly advised to migrate to the latest API version as soon
as possible.

{{% notice note %}}
To migrate to the v1beta1 API, you must upgrade KubeOne to `v1.0.0` or newer.
{{% /notice %}}

## Migrating the manifest using the `config migrate` command

The `config migrate` command automatically migrates the v1alpha1 manifests to
the new v1beta1 API. The command takes the path to the v1alpha1 manifest
and prints the converted manifest to the standard output.

Example usage:

```bash
kubeone config migrate --manifest kubeone.yaml
```

{{% notice warning %}}
It's strongly advised to compare the old and new manifests to ensure that no
information is missing in the new manifest. If you see anything unexpected
and not covered by the [The API Changelog]({{< ref "#the-api-changelog" >}}) portion of this document, please
[file a new issue on GitHub](https://github.com/kubermatic/kubeone/issues/new?labels=kind%2Fbug&template=bug-report.md).
{{% /notice %}}

## The API Changelog

The API version of the new API is `v1beta1`. The kind remains `KubeOneCluster`.

### Defining providers as typed structs

The `cloudProvider.Name` field has been removed and replaced with typed
structs. The valid provider struct names are same as valid
`cloudProvider.Name` values.

```yaml
# v1alpha1 API
cloudProvider:
  name: aws

# v1beta1 API
cloudProvider:
  aws: {}
```

#### Moving the `network.networkID` to the HetznerSpec struct

The `network.networkID` field, used for Hetzner clusters to configure the CCM,
has been moved to the `.cloudProvider.Hetzner` struct.

```yaml
# v1alpha1 API
cloudProvider:
  name: hetzner
network:
  networkID: "1234"

# v1beta1 API
cloudProvider:
  hetzner:
    networkID: "1234"
```

### Defining CNI plugins as typed structs

Similar as for `.cloudProvider.Name`, the `network.cni.name` field has been
replaced with the appropriate structs.

```yaml
# v1alpha1 API
network:
  cni:
    name: canal

# v1beta1 API
network:
  cni:
    canal: {}
```

```yaml
# v1alpha1 API
network:
  cni:
    name: weave
    encrypted: true

# v1beta1 API
network:
  cni:
    weave:
      encrypted: true
```

#### Moving the `network.cni.encrypted` field to the WeaveNet struct

Since only WeaveNet supports encryption, the `.network.cni.encrypted` field has
been moved to the WeaveNet struct.

```yaml
# v1alpha1 API
network:
  cni:
    name: weave
    encrypted: true

# v1beta1 API
network:
  cni:
    weave:
      encrypted: true
```

### Hosts-related fields are renamed

The hosts-related fields has been renamed to make the difference between
different type of hosts clear.

* `.hosts` -> `.controlPlane.Hosts`
* `.staticWorkers` -> `.staticWorkers.Hosts`
* `.workers` -> `.dynamicWorkers`

### Changes to the `.untaint` field

The `.untaint` field in the HostConfig struct has been replaced with the
`.taints` field. The new field takes a list of taints that will be applied on
the node.

If omitted from the manifest, the default value is:

* for control plane nodes: `node-role.kubernetes.io/master` with `NoSchedule` effect
* for worker nodes: no taints

If it's explicitly empty, no taints will be applied to the node. This behavior
is same as if `.untaint` is `true`.

```yaml
# v1alpha1 API
hosts:
- ...
  untaint: true

# v1beta1 API
controlPlane:
  hosts:
  - ...
    taints: {}
```

```yaml
# v1alpha1 API
hosts:
- ...
  untaint: false

# v1beta1 API
controlPlane:
  hosts:
  - ...
    taints:
    - key: "node-role.kubernetes.io/master"
      effect: "NoSchedule"
```

### Removal of the `.machineControllerConfig.Provider` field

The `.machineControllerConfig.Provider` has been removed from the API.

This field had no effect in the `v1alpha1` API and after reconsideration (see
[#765][issue-765] for more details) it has been decided to remove this field.
machine-controller will be configured to work for provider specified in the
`.cloudProvider` property.

### Removal of the `.credentials` field

The `.credentials` field has been removed from the API.

For a long time, the credentials are automatically sourced from the
environment, with a support for specifying credentials using the credentials
file. Considering that the `.credentials` field had no effect, it has been
decided to remove this field.

[issue-765]: https://github.com/kubermatic/kubeone/issues/765
