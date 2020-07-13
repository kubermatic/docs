+++
title = "KubeOne FAQ"
date = 2020-04-01T12:00:00+02:00
weight = 100
enableToc = true
+++

This document is supposed to answer some commonly asked questions about KubeOne,
what it does, and how it works. If you have any question not covered here,
please create [a new GitHub issue][1], contact us on the
[`#kubeone` channel on Kubernetes Slack][2] or on [our community forums][3].

## What is KubeOne?

Kubermatic KubeOne is a tool that automates cluster operations on all your
cloud, on-prem, edge, and IoT environments.

## What Kubernetes versions are supported by KubeOne?

KubeOne only supports versions supported by the [upstream support policy][9].
While older versions might work, we can't guarantee that and we strongly advise
that you use only officially supported versions.

## What cloud providers KubeOne does support?

KubeOne is supposed to work on any cloud provider, on-prem and bare-metal.
However, to utilize all KubeOne features, such as Terraform integration and
managing worker nodes using [Kubermatic machine-controller][4] and Cluster-API,
the provider needs to be supported by KubeOne.

Currently we support AWS, DigitalOcean, Google Compute Engine (GCE), Hetzner,
Packet, OpenStack, VMware vSphere and Azure.

## Are on-prem and bare metal clusters supported?

Yes. We officially support VMware vSphere and OpenStack.

## Does KubeOne manages the infrastructure and cloud resources?

No, it's up to the operator to setup the needed infrastructure and provide the
needed parameters to KubeOne.

To make this task easier, we provide [Terraform scripts][5] and integration 
for all supported providers. The Terraform scripts can be used to create the
needed infrastructure, and then using the Terraform integration, all needed
parameters can be sourced directly from the Terraform output.

This decision was based on that fact that we didn't want to limit operators how
the infrastructure can be configured and what infrastructure providers can be used.
There are many possible setups and officially supporting each setup isn't possible
in most of cases. Operators are free to define infrastructure how they prefer and then
use KubeOne to provision the cluster.

## How KubeOne works?

KubeOne uses [kubeadm][6] to provision and upgrade the Kubernetes clusters.
The worker nodes are managed by the Cluster-API and [Kubermatic machine-controller][4].
KubeOne also supports provisioning worker nodes using kubeadm, but the infrastructure for
nodes needs to be created and managed by the operator.

KubeOne takes care of installing Docker and all needed dependencies for
Kubernetes and kubeadm. After the cluster is provisioned, KubeOne deploys
the CNI plugin, [Kubermatic machine-controller][4], and other
needed components.

## Can I deploy other controller than machine-controller or decide not to deploy and machine-controller?

You can opt out of deploying machine-controller by setting
`machineController.Deploy` to `false`.

## Can I use KubeOne to provision the worker nodes?

Yes, KubeOne can provision and upgrade the worker nodes using kubeadm.
The infrastructure (e.g. instances) needs to be managed by the operator.

We recommend using machine-controller to manage worker nodes, however, 
this can be useful in cases when machine-controller doesn't support the provider,
for example when using bare-metal.

## How are commands executed on nodes?

All commands are executed over SSH. Because we don't take care of the
infrastructure, it's impossible to use cloud-config. Components, such as CNI
and machine-controller are deployed using the [controller-runtime client][7]
library.

## KubeOne can't connect to nodes over SSH. How can I fix this?

Check [the following document][8] to find out how KubeOne uses SSH and what are
SSH requirements.

## Can I deploy other CNI plugin then Canal?

KubeOne can deploy Canal and WeaveNet CNI plugins out-of-box, with support
for allowing operators to deploy CNI plugin of their choice using the
`external` CNI option.

The `external` CNI option is usually combined with the [KubeOne Addons][11].
feature. For example, you can checkout how Calico VXLAN plugin can be deploy
using [the Calico addon][12].

## How many versions can I upgrade at the same time?

It is only possible to upgrade from one minor to the next minor version (n+1).
For example, if you want to upgrade from Kubernetes 1.13 to Kubernetes 1.15,
you'd need to upgrade to 1.14 and then to 1.15.

## I'd like to contribute to KubeOne! Where can I start?

Please check our [contributing guide][10].

[1]: https://github.com/kubermatic/kubeone/issues/new/choose
[2]: http://slack.k8s.io/
[3]: https://forum.kubermatic.com/
[4]: https://github.com/kubermatic/machine-controller
[5]: http://github.com/kubermatic/kubeone/tree/master/examples/terraform
[6]: https://github.com/kubernetes/kubeadm
[7]: https://godoc.org/sigs.k8s.io/controller-runtime/pkg/client
[8]: ../using_kubeone/ssh/
[9]: https://kubernetes.io/docs/setup/release/version-skew-policy/#supported-versions
[10]: https://github.com/kubermatic/kubeone/blob/master/CONTRIBUTING.md
[11]: ../using_kubeone/addons
[12]: ../using_kubeone/calico-vxlan-addon
