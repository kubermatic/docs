+++
title = "Upgrading from 1.8 to 1.9"
date = 2024-11-20T12:00:00+02:00
+++

This document contains important upgrade notes for upgrading from KubeOne 1.8
to 1.9. For the complete changelog, please check the
[complete v1.9.0 changelog on GitHub][changelog].

[changelog]: https://github.com/kubermatic/kubeone/blob/main/CHANGELOG/CHANGELOG-1.9.md

## Known Issues

Make sure to familiarize yourself with the known issues in KubeOne 1.9 before
upgrading by checking the [Known Issues document][known-issues].

[known-issues]: {{< ref "../../../known-issues" >}}

## Kubernetes Compatibility Changes

KubeOne 1.9 introduces support for Kubernetes 1.31. Support for Kubernetes
versions prior to 1.29 is removed as those releases already reached End-of-Life (EOL).

If you have a Kubernetes cluster running 1.28 or earlier, you need to update to
Kubernetes 1.29 or newer using KubeOne 1.8. For more information, check out
the [Kubernetes compatibility document][k8s-compat].

[k8s-compat]: {{< ref "../../../architecture/compatibility/supported-versions/" >}}

## CentOS 7 Support Removal

CentOS 7 has reached end-of-life (EOL) on June 30, 2024. With that, the packages repositories
for CentOS 7 are not functional and cloud providers are not providing CentOS 7 images any
longer. We have made a decision to drop support for CentOS 7 from KubeOne starting with this
release.

If you're still using CentOS 7, we strogly recommend migrating to another [supported operating
system][supported-os].

[supported-os]: {{< ref "../../../architecture/compatibility/os-support-matrix" >}}

## Ubuntu 24.04 Support

The KubeOne 1.9 release introduces support for Ubuntu 24.04 (Noble Numbat). Ubuntu 24.04 is now
a default operating system in:

- All relevant example Terraform configurations (this is mostly relevant to example Terraform
  configurations for cloud providers)
- machine-controller, i.e. machine-controller will use Ubuntu 24.04 for all new Ubuntu-based worker
  nodes on cloud providers

If you want to use the new Terraform configurations with an existing cluster, make sure to pin the image
to the image that you're using right now, otherwise Terraform might recreate/destroy your existing instances
and therefore the whole cluster.

If you don't want to use Ubuntu 24.04 for worker nodes managed by machine-controller, you should
edit all Ubuntu-based MachineDeployment objects to pin the image to the Ubuntu version that you want
to use. Please note that this might cause machine-controller to rollout the affected MachineDeployments
(i.e. to recreate all Machines/nodes).

## Changing The Default Instance Type on Hetzner

Hetzner doesn't allow creating new instances based on the `cx21` instance type which we used prior to
KubeOne 1.9. Because of that, the example Terraform configurations for Hetzner are using the `cx22`
instance type starting with KubeOne 1.9.

If you want to use the new Terraform configurations with an existing cluster, make sure to explicitly set
the instance type that you're using right now, otherwise Terraform might recreate/destroy your existing
instances and therefore the whole cluster.

## Stricter Validation For Control Plane And Static Worker Nodes

We introduced a change to the KubeOneCluster manifest validation to prevent specifying the same instance
both as a control plane node and as a static worker node. In other words, the following manifest is
now considered **invalid** and will be rejected by KubeOne:

```yaml
apiVersion: kubeone.k8c.io/v1beta2
kind: KubeOneCluster
name: demo
controlPlane:
  hosts:
    - publicAddress: '1.1.1.1'
      privateAddress: '10.0.0.2'
      hostname: 'instance-1'
staticWorkers:
  hosts:
    - publicAddress: '1.1.1.1'
      privateAddress: '10.0.0.2'
      hostname: 'instance-1'
```

This has never been supported by KubeOne, but now we formalized this via a stricter validation.
Instead of doing this, you should define your instance as a control plane node and remove
the `node-role.kubernetes.io/control-plane:NoSchedule` taint from it.

For example, this is considered a valid manifest:

```yaml
apiVersion: kubeone.k8c.io/v1beta2
kind: KubeOneCluster
name: demo
controlPlane:
  hosts:
    - publicAddress: '1.1.1.1'
      privateAddress: '10.0.0.2'
      hostname: 'instance-1'
      taints: []
```

On such node, you can run both the control plane components and your workload Pods.

## Removal Of Deprecated And Non-Functional Commands

`kubeone install` and `kubeone upgrade` commands are removed in this release. These commands
have been deprecated in KubeOne 1.4 and hidden in KubeOne 1.5. Instead of these commands,
you should be using the `kubeone apply` command.

Additionally, two commands have been marked as hidden and will be removed in the next release:

- `kubeone migrate to-ccm-csi`
- `kubeone migrate to-containerd`

Both commands are considered non-functional in this release because these tasks could have been
done up to Kubernetes v1.28 and v1.24 respectively.

## Changes To The Cilium Architecture

We upgraded Cilium to v1.16 in this KubeOne release. This Cilium upgrade comes with an architecture
change in a way that the Envoy Proxy is not integrated into the Cilium Pod, but is a standalone
component/DaemonSet now.

This change might only affect users that have nodes that are low on capacity (pods or resources wise).
If you're affected, you might not be able to run the standalone Envoy Proxy DaemonSet/Pods,
in which case you need to override the Cilium CNI addon to switch to the old architecture.

For information about other changes, we recommend checking out the
[changelog][changelog].
