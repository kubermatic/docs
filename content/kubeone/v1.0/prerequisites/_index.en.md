+++
title = "Prerequisites"
date = 2020-04-01T12:00:00+02:00
weight = 5
+++

You should take these steps before using KubeOne to ensure the smoothest
experience.

Make sure that you have:

* Installed KubeOne as described in the [Getting KubeOne][getting-kubeone]
  document
* Installed Terraform v0.12+ if you want to provision the infrastructure using
  our [example Terraform configs][kubeone-terraform-configs] and/or use the
  [KubeOne Terraform Integration][kubeone-terraform-integration]
  * You can find the installation instructions in the
    [official Terraform docs][install-terraform]
  * Check out the [Compatibility][compatibility] document
    for more details about supported Terraform versions
* The appropriate provider credentials to be used by KubeOne and Terraform as
  described in the [Configuring Credentials][config-credentials] document
* An SSH key and the `ssh-agent` configured as described in the
  [Configuring SSH][config-ssh] document


[getting-kubeone]: {{< ref "../getting_kubeone" >}}
[kubeone-terraform-configs]: {{< ref "../concepts#example-terraform-configs" >}}
[kubeone-terraform-integration]: {{< ref "../concepts#kubeone-terraform-intergration" >}}
[install-terraform]: https://learn.hashicorp.com/terraform/getting-started/install.html
[compatibility]: {{< ref "../compatibility_info#supported-terraform-versions" >}}
[config-credentials]: {{< ref "./credentials" >}}
[config-ssh]: {{< ref "./ssh" >}}
