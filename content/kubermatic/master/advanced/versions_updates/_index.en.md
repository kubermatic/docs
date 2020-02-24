+++
title = "Versions & Update Configuration"
date = 2019-07-05T10:45:00+02:00
weight = 6
pre = "<b></b>"
+++

This chapter describes how to configure the available Kubernetes/OpenShift versions and how to
provide update paths for user clusters.

The list of selectable versions when [specifying cluster name and Kubernetes version]({{< ref "../../getting_started/create_cluster/#step-2-specify-the-cluster-name-and-kubernetes-version" >}}) is defined in the `spec.versions`
section in the [KubermaticConfiguration]({{< ref "../../concepts/kubermaticconfiguration" >}}) CRD.
This is also where updates are configured.

### Default Versions

The list of default versions is shown in the CRD example linked to above, but it's recommended
to retrieve the actual list from the Kubermatic Operator itself.

The operator comes with a `kubermatic-operator-util` tool, which can output a full default
KubermaticConfiguration:

```bash
docker run --rm quay.io/kubermatic/api:KUBERMATIC_VERSION kubermatic-operator-util defaults
#apiVersion: operator.kubermatic.io/v1alpha1
#kind: KubermaticConfiguration
#metadata:
#  name: kubermatic
#  namespace: kubermatic
#spec:
#  ...
#  versions:
#    kubernetes: ...
#      versions: ...
#      default: ...
#      updates: ...
#    openshift: ...
#      versions: ...
#      default: ...
#      updates: ...
```

A simplified configuration for Kubernetes might look like this:

```yaml
spec:
  versions:
    kubernetes:
      versions:
        - '1.15.99'
        - '1.16.0'
        - '1.16.1'
        - '1.16.2'
      default: '1.16.2'
      updates:
        # allow version updates to any minor version
        - from: '1.16.*'
          to: '1.16.*'
        # assuming 1.15.99 has security issues, this would force an
        # update for clusters using it
        - from: '1.15.99'
          to: '1.16.2'
          automatic: true
```

### Configuring Versions

The structure for Kubernetes and OpenShift versions is identical. Each contains

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

Each element of the two orchestrators can be overwritten independently, i.e. you can only override
the list of allowed and default Kubernetes versions, while still relying on the default value for
the update paths and all default settings for OpenShift by setting:

```yaml
spec:
  versions:
    kubernetes:
      versions: ['1.16.0', '1.16.2']
      default: '1.16.2'
```

{{% notice note %}}
It's not possible to add or remove individual elements from the `versions` or `updates` arrays.
You always have to specify the entire list in the `KubermaticConfiguration`.
{{% /notice %}}

Edit your KubermaticConfiguration either using `kubectl edit` or editing a local file and applying
it with `kubectl apply`, the Kubermatic Operator will reconcile the setup and after a few moments
the new configuration will take effect.
