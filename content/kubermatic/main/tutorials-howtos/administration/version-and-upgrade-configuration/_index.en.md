+++
title = "Versions & Update Configuration"
date = 2019-07-05T10:45:00+02:00
weight = 200

+++

This chapter describes how to configure the available Kubernetes versions and how to
provide update paths for user clusters.

The list of selectable versions when [specifying cluster name and Kubernetes version]({{< ref "../../../tutorials-howtos/project-and-cluster-management" >}}) is defined in the `spec.versions`
section in the [KubermaticConfiguration]({{< ref "../../../tutorials-howtos/kkp-configuration" >}}) CRD.
This is also where updates are configured.

### Default Versions

The list of default versions, is shown by the CRD example linked above, but it's recommended
to retrieve the actual list from the Kubermatic installer itself.
To print the default configuration run `kubermatic-installer print` which outputs a full KubermaticConfiguration.

### Configuring Versions

The structure to configure Kubernetes version updates contains:

* `versions` (array) is a list of user-selectable versions. These must be concrete
  [semantic versions](https://semver.org/), wildcards or ranges are not supported.
* `default` (string) is the default version for this cluster orchestrator, i.e. one of the
  items from `versions`.
* `updates` (array) is a list of allowed update paths for a cluster. Each update consists
  of the following fields:

  * `from` (string) is a version ("v1.2.3"), a wildcard version ("v1.2.*") or version range
    ("v1.2.0-v1.3.0") a cluster must match for this update to be allowed.
  * `to` (string) is a version, a wildcard version or version range that the cluster can be
    updated to.
  * `automatic` (bool) controls whether an update is performed immediately after applying the
    configuration. This is useful for force updates in case of security patch releases.
  * `automaticNodeUpgrade` (bool) controls whether worker nodes are updated as well. If this
    is left to its default (false), only the controlplane will be updated. When set to true,
    it implies `automatic`.

{{% notice note %}}
It's not possible to add or remove individual elements from the `versions` or `updates` arrays.
You always have to specify the entire list in the `KubermaticConfiguration`.
{{% /notice %}}

Edit your KubermaticConfiguration either using `kubectl edit` or editing a local file and applying
it with `kubectl apply`, the KKP Operator will reconcile the setup and after a few moments
the new configuration will take effect.

{{% notice note %}}
Note that once you start overriding default values in your KubermaticConfiguration, you need to
keep the settings up-to-date when upgrading KKP.
{{% /notice %}}
