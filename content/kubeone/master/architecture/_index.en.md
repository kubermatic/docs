+++
title = "Architecture"
date = 2021-02-10T09:00:00+02:00
weight = 1
chapter = false
+++

The following diagram shows the KubeOne's architecture, including what
tasks should be done by the user, what tasks are done by KubeOne and in
which particular order.

Additional details about concepts used by KubeOne can be found in the
[Concepts][concepts] document.

![KubeOne Architecture Diagram](/img/kubeone/master/architecture/architecture.png)

1 This diagram shows [officially supported providers][supported-providers].
KubeOne is not limited to those providers and is supposed to work on any 
infrastructure out of the box, for example, on bare-metal.
Officially supported providers have additional features, such as Terraform
integration, example Terraform configurations that can be used to create
the initial infrastructure, and the machine-controller support.

2 [Kubermatic Machine Controller][machine-controller] is available
only for [officially supported providers][supported-providers]. For non-officially
supported providers, you can provision machines manually using KubeOne's
[Static Workers feature][static-workers].

[concepts]: {{< ref "./concepts" >}}
[supported-providers]: {{< ref "./compatibility" >}}
[terraform-integration]: {{< ref "./" >}}
[terraform-configs]: {{< ref "./" >}}
[machine-controller]: https://github.com/kubermatic/machine-controller
[static-workers]: {{< ref "./" >}}
