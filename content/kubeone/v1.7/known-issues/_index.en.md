+++
title = "Known Issues"
date = 2023-09-08T09:00:00+02:00
description = "Known Issues in Kubermatic KubeOne"
weight = 99
+++

This page documents the list of known issues in Kubermatic KubeOne along with
possible workarounds and recommendations.

This list applies to KubeOne 1.7 releases. For KubeOne 1.6, please consider
the [v1.6 version of this document][known-issues-1.6]. For earlier releases,
please consult the [appropriate changelog][changelogs].

[known-issues-1.6]: {{< ref "../../v1.6/known-issues" >}}
[changelogs]: https://github.com/kubermatic/kubeone/tree/main/CHANGELOG

## Invalid cluster name set on OpenStack CCM and OpenStack Cinder CSI

|              |                                                   |
|--------------|---------------------------------------------------|
| Status       | Fixed in KubeOne 1.7.2                            |
| Severity     | Critical                                          |
| GitHub issue | https://github.com/kubermatic/kubeone/issues/2976 |

### Who's affected by this issue?

**This issue affects only OpenStack clusters. The following OpenStack
users are affected by this issue:**

- Users who provisioned their OpenStack cluster with **KubeOne 1.6 or
  earlier**, then upgraded to **KubeOne 1.7.0 or 1.7.1** and ran
  `kubeone apply` **two or more times**
- Users who used **KubeOne 1.7.0 or 1.7.1** to provision their OpenStack
  cluster

### Description

The OpenStack CCM and Cinder CSI are taking the cluster name property which is
used upon creating OpenStack Load Balancers and Volumes. The cluster name
property is provided as a flag on OpenStack CCM DaemonSet and Cinder CSI
Controller Deployment. This cluster name property is used:

- for naming Octavia Load Balancers and Load Balancer Listeners
- for tagging Volumes with the `cinder.csi.openstack.org/cluster` tag

**Due to a bug introduced in KubeOne 1.7.0, the cluster name property is
unconditionally set to `kubernetes` instead of the desired cluster's name.
As a result:**

- Existing Octavia Load Balancers will fail to reconcile
- Newly created Load Balancers will have incorrect name
- Volumes should not be affected besides the `cinder.csi.openstack.org/cluster`
  tag having a wrong value

#### What's considered a valid/desired cluster name?

In general, the cluster name property must equal to the cluster name provided
to KubeOne (either via KubeOneCluster manifest (`kubeone.yaml` by default) or
via the `cluster_name` Terraform variable). This is especially important if you
have multiple Kubernetes clusters in the same OpenStack project.

### How to check if you're affected?

You **might** be affected only if you're using KubeOne 1.7.

Run the following `kubectl` command, with `kubectl` pointing to your
potentially affected cluster:

```shell
kubectl get daemonset \
    --namespace kube-system \
    openstack-cloud-controller-manager \
    --output=jsonpath='{.spec.template.spec.containers[?(@.name=="openstack-cloud-controller-manager")].env[?(@.name=="CLUSTER_NAME")].value}'
```

If you get the following output:

- `kubernetes`: **you're affected by this issue**
- a valid cluster name (as described in the previous section): you're NOT
  affected by this issue
- if you don't get anything, you're mostly like not running KubeOne 1.7 yet

Regardless if you're affected or not, we strongly recommend upgrading
to KubeOne 1.7.2 or newer **as soon as possible**!

### Mitigation

If you're affected by this issue, we strongly recommend taking the mitigation
steps.

Please be aware that changing the cluster name might make some Octavia Load
Balancers fail to reconcile. Volumes shouldn't be affected.

First, determine your desired cluster name. The safest way is to dump the whole
KubeOneCluster manifest using the `kubeone config dump` command
(make sure to replace `tf.json` and `kubeone.yaml` with valid files before
running the command):

```shell
kubeone config dump -t tf.json -m kubeone.yaml | grep "name:"
```

You'll get output such as:

```yaml
  - name: default-storage-class
    hostname: test-1-cp-0
    sshUsername: ubuntu
    hostname: test-1-cp-1
    sshUsername: ubuntu
    hostname: test-1-cp-2
    sshUsername: ubuntu
- name: test-1-pool1
name: test-1
```

Note the top-level `name` value, in this case `test-1` -- this is your desired
cluster name.

The next step is to patch the OpenStack CCM DaemonSet and Cinder CSI Deployment
(replace `<<REPLACE_ME>>` with your cluster's name in the following two
commands):

```shell
kubectl patch --namespace kube-system daemonset openstack-cloud-controller-manager --type='strategic' --patch='
{
  "spec": {
    "template": {
      "spec": {
        "containers": [
          {
            "name": "openstack-cloud-controller-manager",
            "env": [
              {
                "name": "CLUSTER_NAME",
                "value": "<<REPLACE_ME>>"
              }
            ]
          }
        ]
      }
    }
  }
}'
```

```shell
kubectl patch --namespace kube-system deployment openstack-cinder-csi-controllerplugin --type='strategic' --patch='
{
  "spec": {
    "template": {
      "spec": {
        "containers": [
          {
            "name": "cinder-csi-plugin",
            "env": [
              {
                "name": "CLUSTER_NAME",
                "value": "<<REPLACE_ME>>"
              }
            ]
          }
        ]
      }
    }
  }
}'
```

You should see the following output from these two commands:

```shell
daemonset.apps/openstack-cloud-controller-manager patched
deployment.apps/openstack-cinder-csi-controllerplugin patched
```

At this point, you need to remediate errors and failed reconcilations that
might be caused by this change. As mentioned earlier, volumes are not affected
by this change, but Octavia Load Balancers might be.

The easiest way to determine if you have Load Balancers affected by this change
is to look for `SyncLoadBalancerFailed` events. You can do that using the
following command:

```shell
kubectl get events --all-namespaces --field-selector reason=SyncLoadBalancerFailed
```

You might get output like this:

```shell
NAMESPACE   LAST SEEN   TYPE      REASON                   OBJECT            MESSAGE
default     2s          Warning   SyncLoadBalancerFailed   service/nginx-2   Error syncing load balancer: failed to ensure load balancer: the listener port 80 already exists
default     4h49m       Warning   SyncLoadBalancerFailed   service/nginx     Error syncing load balancer: failed to ensure load balancer: the listener port 80 already exists
default     3h7m        Warning   SyncLoadBalancerFailed   service/nginx     Error syncing load balancer: failed to ensure load balancer: the listener port 80 already exists
default     89m         Warning   SyncLoadBalancerFailed   service/nginx     Error syncing load balancer: failed to ensure load balancer: the listener port 80 already exists
default     22m         Warning   SyncLoadBalancerFailed   service/nginx     Error syncing load balancer: failed to ensure load balancer: the listener port 80 already exists
default     3m1s        Warning   SyncLoadBalancerFailed   service/nginx     Error syncing load balancer: failed to ensure load balancer: the listener port 80 already exists
```

Only events that are **last seen after** you made the cluster name change are
relevant. Other events can be ignored, although you might want to describe
those Services and ensure that you see `EnsuredLoadBalancer` event.

For Services that are showing `SyncLoadBalancerFailed`, you will need to take
steps depending on the error message. For example, if the error message is
the listener port 80 already exists, you can manually delete the listener and
OpenStack CCM will create a valid one again after some time.

## KubeOne is unable to upgrade AzureDisk CSI driver upon upgrading KubeOne from 1.6 to 1.7

|              |                                                   |
|--------------|---------------------------------------------------|
| Status       | Fixed in KubeOne 1.7.2                            |
| Severity     | Low                                               |
| GitHub issue | https://github.com/kubermatic/kubeone/issues/2971 |

### Who's affected by this issue?

Users who used **KubeOne 1.6 or earlier** to provision a cluster running on
Microsoft Azure **are affected by this issue**.

### Description

The AzureDisk CSI driver got updated to a newer version in KubeOne 1.7.
This upgrade accidentally changed the `csi-azuredisk-node-secret-binding`
ClusterRoleBinding object so that the referenced role (`roleRef`) is
`csi-azuredisk-node-role` instead of `csi-azuredisk-node-secret-role`.
Given that the referenced role is immutable, KubeOne wasn't able to
upgrade the AzureDisk CSI driver when upgrading KubeOne from 1.6
to 1.7.0 or 1.7.1.

### Recommendation

If you're affected by this issue, it's recommended to upgrade to KubeOne 1.7.2
or newer. KubeOne 1.7.2 removes the `csi-azuredisk-node-secret-binding`
ClusterRoleBinding object if the referenced role is
`csi-azuredisk-node-secret-role` to allow the upgrade process to proceed.

The issue can also be mitigated manually by removing the ClusterRoleBinding
object if KubeOne is stuck trying to upgrade the AzureDisk CSI driver:

```shell
kubectl delete clusterrolebinding csi-azuredisk-node-secret-binding
```

## Cilium CNI is not working on clusters running CentOS 7

|              |                                                   |
|--------------|---------------------------------------------------|
| Status       | Known Issue                                       |
| Severity     | Low                                               |
| GitHub issue | N/A                                               |

### Description

Cilium CNI is not supported on CentOS 7 because it's using too older kernel
version which is not supported by Cilium itself. For more details, consider
[the official Cilium documentation][cilium-requirements].

[cilium-requirements]: https://docs.cilium.io/en/v1.13/operations/system_requirements/

### Recommendation

Please consider using an operating system with a newer kernel version, such
as Ubuntu, Rocky Linux, and Flatcar. See
[the official Cilium documentation][cilium-requirements] for a list of
operating systems and versions supported by Cilium.

## Internal Kubernetes endpoints unreachable on vSphere with Cilium/Canal

|              |                                                   |
|--------------|---------------------------------------------------|
| Status       | Workaround available                              |
| Severity     | Low                                               |
| GitHub issue | https://github.com/cilium/cilium/issues/21801     |

### Description

#### Symptoms

* Unable to perform CRUD operations on resources governed by webhooks (e.g. ValidatingWebhookConfiguration, MutatingWebhookConfiguration, etc.). The following error is observed:

```sh
Internal error occurred: failed calling webhook "webhook-name": failed to call webhook: Post "https://webhook-service-name.namespace.svc:443/webhook-endpoint": context deadline exceeded
```

* Unable to reach internal Kubernetes endpoints from pods/nodes.
* ICMP is working but TCP/UDP is not.

#### Cause

On recent enough VMware hardware compatibility version (i.e >= 15 or maybe >= 14), CNI connectivity breaks because of hardware segmentation offload. `cilium-health status` has ICMP connectivity working, but not TCP connectivity. cilium-health status may also fail completely.

### Recommendation

```sh
sudo ethtool -K ens192 tx-udp_tnl-segmentation off
sudo ethtool -K ens192 tx-udp_tnl-csum-segmentation off
```

These flags are related to the hardware segmentation offload done by the vSphere driver VMXNET3. We have observed this issue for both Cilium and Canal CNI running on Ubuntu 22.04.

We have two options to configure these flags for KubeOne installations:

* When configuring the VM template, set these flags as well.
* Create a [custom Operating System Profile]({{< ref "../architecture/operating-system-manager/usage#using-custom-operatingsystemprofile" >}}) and configure the flags there.

### References

* <https://github.com/cilium/cilium/issues/13096>
* <https://github.com/cilium/cilium/issues/21801>
