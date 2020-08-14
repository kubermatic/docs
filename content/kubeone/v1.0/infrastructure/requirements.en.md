+++
title = "Requirements"
date = 2020-04-01T12:00:00+02:00
weight = 1
+++

{{% notice note %}}
If you're using our [example Terraform configs]({{< ref "./terraform_configs" >}}),
all requirements are satisfied by default.
{{% /notice %}}

## Infrastructure Requirements for Control Plane

The following infrastructure requirements **must** be satisfied to successfully
provision a Kubernetes cluster using KubeOne:

* You need the appropriate number of instances dedicated for the
  [control plane][k8s-control-plane]
  * You need **even** number of instances with a minimum of **three** instances
  for the Highly-Available control plane
  * If you decide to use a single-node control plane instead, one instance is
    enough, however, highly-available control plane is highly advised,
    especially in the production environments
* All control plane instances must satisfy the
  [system requirements for a kubeadm cluster][kubeadm-sysreq]
* For highly-available control plane, a load balancer pointing to the
  control plane instances (the Kubernetes API server) is needed
  * Load balancer must include all control plane instances and distribute
    traffic to the TCP port 6443 (default port of the Kubernetes API server)
  * It's recommended to use a provider's offering for load balancers if such is
    available
  * If provider doesn't offer load balacners, you can create an instance and
    setup a solution such as HAProxy
  * In our example Terraform configs, we use [GoBetween][gobetween] when
    provider doesn't offer load balancers. A simple GoBetween setup is a good
    way to get started, but it might **not** be suitable for the production
    environments
* You must have an SSH key deployed on all control plane instances and
  SSH configured as described in the [Configuring SSH][ssh] document

Depending on the environment, you may need additional objects, such as VPCs,
firewall rules, or images. For [natively-supported
providers][supported-providers], we recommended checking our [example Terraform
configs][terraform-configs-github] as a reference what objects you should consider
creating.

## Infrastructure Requirements for Worker Nodes

Instances for worker nodes can be managed in two ways:

* using [Kubermatic machine-controller][machine-controller], which creates and
  provisions instances, and joins them a cluster, automatically
* using KubeOne Static Workers, by using the preferred tooling to create
  instances and then provision them using KubeOne

Using Kubermatic machine-controller is highly advised if your provider is
[natively supported][supported-providers]. Otherwise, KubeOne Static Workers
are recommended instead. More details about the machine-controller and the
Cluster-API can be found in the [Concepts][concepts] document.

The requirements for the KubeOne Static Workers are similar as for the control
plane instances:

* All instances must satisfy the
  [system requirements for a kubeadm cluster][kubeadm-sysreq]
* You must have an SSH key deployed on all control plane instances and
  SSH configured as described in the [Configuring SSH][ssh] document

[production-recommendations]: {{< ref "./production_recommendations" >}}
[k8s-control-plane]: {{< ref "../concepts#control-plane" >}}
[kubeadm-sysreq]: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#before-you-begin
[gobetween]: http://gobetween.io/
[ssh]: {{< ref "../prerequisites/ssh#sshd-requirements-on-instances" >}}
[supported-providers]: {{< ref "../compatibility_info#supported-providers" >}}
[terraform-configs-github]: https://github.com/kubermatic/kubeone/tree/release/v1.0/examples/terraform
[machine-controller]: https://github.com/kubermatic/machine-controller
[concepts]: {{< ref "../concepts#kubermatic-machine-controller" >}}
[concepts-md]: {{< ref "../concepts#machinedeployments" >}}
