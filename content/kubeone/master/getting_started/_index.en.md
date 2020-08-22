+++
title = "Getting Started"
date = 2020-08-22T12:00:00+02:00
weight = 2
+++

This Getting Started guide shows how you can get started with KubeOne and
create your first cluster.

## Prerequisites

Before getting started, make sure that you've the following prerequisites
satisfied:

* Installed KubeOne as described in the [Getting KubeOne][getting-kubeone]
  document
* Installed Terraform v0.12+ if you want to provision the infrastructure using
  our [example Terraform configs][kubeone-terraform-configs]. You can find the
  installation instructions in the [official Terraform docs][install-terraform]
* The appropriate provider credentials to be used by KubeOne and Terraform as
  described in the [Configuring Credentials][config-credentials] document
* An SSH key and the `ssh-agent` configured as described in the
  [Configuring SSH][config-ssh] document

## Creating A Cluster Using KubeOne

The first step when creating a new cluster is to create the infrastructure
where the cluster will be provisioned. That can be done by following the
[Creating Infrastructure Using Example Terraform Configs guide][using-tf].
Once you have the needed infrastructure, follow the
[Provisioning guide][provisioning] to provision a cluster using KubeOne.

To find what operating systems and Kubernetes versions are supported by
KubeOne, check out the [Compatibility document][compatibility].

## Learn More

Once you have the cluster in the place, you can check other guides to learn how
to use KubeOne to maintain your cluster. We recommend checking at least the
following guides:

* [Managing Worker Nodes using machine-controller][managing-workers-mc]
* [Upgrading clusters using KubeOne][upgrading]

If you want to learn more about tools and concepts used by KubeOne, we
recommend checking the [Concepts document][concepts].

If you have any questions, you can reach out to us on:

* [Kubermatic forums][forums]
* [`#kubeone` channel][slack-kubeone] on [Kubernetes Slack][slack-k8s]

[getting-kubeone]: {{< ref "../getting_kubeone" >}}
[kubeone-terraform-configs]: {{< ref "../concepts#example-terraform-configs" >}}
[install-terraform]: https://learn.hashicorp.com/terraform/getting-started/install.html
[compatibility]: {{< ref "../compatibility_info#supported-terraform-versions" >}}
[config-credentials]: {{< ref "../prerequisites/credentials" >}}
[config-ssh]: {{< ref "../prerequisites/ssh" >}}
[using-tf]: {{< ref "../infrastructure/terraform_configs" >}}
[provisioning]: {{< ref "../provisioning" >}}
[managing-workers-mc]: {{< ref "../workers/machine_controller" >}}
[upgrading]: {{< ref "../upgrading" >}}
[concepts]: {{< ref "../concepts" >}}
[forums]: https://forum.kubermatic.com/
[slack-kubeone]: https://kubernetes.slack.com/messages/CNEV2UMT7
[slack-k8s]: http://slack.k8s.io/
