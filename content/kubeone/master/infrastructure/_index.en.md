+++
title = "Infrastructure"
date = 2020-04-01T12:00:00+02:00
weight = 5
+++

This sections shows how to create the needed infrastructure for a
KubeOne-managed Kubernetes cluster.

All required infrastructure for the cluster along with instances needed for
control plane nodes are **managed by the user**. It can be done manually or by
integrating with tools such as Terraform.

To make it easier to get started, we
provide **example Terraform scripts** that you can use to create the needed
infrastructure. You can find out how to get started with the example scripts
by following the [Using Example Terrafrom Scripts][terraform-scripts] guide.

Additionally, KubeOne integrates with Terraform by reading the Terraform state
for the information about the cluster. You can use the KubeOne Terraform
Integration regardless of do you use our example Terraform scripts or your own
Terraform scripts. More information about the integration can be found in the
[KubeOne Terraform Integration][terraform-integration] document.

If you decide not to use our example Terraform scripts, you should comply with
the requirements specified in the [Requirements][requirements] document.
Additionally, regardless of do you use our example Terraform scripts or not,
we highly advise checking the
[Production Recommendations][production-recommendations] document.

[terraform-scripts]: {{< ref "terraform_scripts" >}}
[terraform-integration]: {{< ref "terraform_integration" >}}
[requirements]: {{< ref "./requirements" >}}
[production-recommendations]: {{< ref "production_recommendations" >}}
