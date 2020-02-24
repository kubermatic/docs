+++
title = "Update list of selectable Kubernetes versions"
date = 2019-07-05T10:45:00+02:00
weight = 6
pre = "<b></b>"
+++

The list of selectable versions when [specifying cluster name and Kubernetes version]({{< ref "../../getting_started/create_cluster/#step-2-specify-the-cluster-name-and-kubernetes-version" >}}) is defined in the `spec.versions`
section in the [KubermaticConfiguration]({{< ref "../../concepts/kubermaticconfiguration" >}}) CRD.

### Default Versions

The list of default Kubernetes/OpenShift versions is shown in the CRD example linked to previously,
but it's recommended to retrieve the actual list from the Kubermatic Operator itself.

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
#    openshift: ...
```

### Configuring Versions

The structure for Kubernetes and OpenShift versions is identical. Each contains

* `versions` (array) is a list of user-selectable versions. These must be concrete
  [semantic versions](https://semver.org/), wildcards or ranges are not supported.
* `default` (string) is the default version for this cluster orchestrator, i.e. one of the
  items from `versions`.
* `updates` (array) is a list of allowed upgrade paths for a cluster. Each update consists
  of the following fields:

  * `from` (string) is a version or version range a cluster must match for this update
    to be allowed.
  * `to` (string) is a version or version range that the cluster can be upgraded to.
  * `automatic` (bool) controls whether an upgrade is performed immediately after applying the
    configuration. This is useful for force upgrades in case of security patch releases.
  * `automaticNodeUpgrade` (bool) controls whether worker nodes are updated as well. If this
    is left to its default (false), only the controlplane will be updated. When set to true,
    it implies `automatic`.

Each element of the two orchestrators can be overwritten independently, i.e. you can only override
the list of allowed and default Kubernetes versions, while still relying on the default value for
the upgrade paths and all default settings for OpenShift by setting:

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
