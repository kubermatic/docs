+++
title = "KubeOne"
date = 2020-04-01T09:00:00+02:00
+++

# What is KubeOne?

Kubermatic KubeOne automates cluster operations on all your cloud, on-prem,
edge, and IoT environments. It comes as a CLI that allows you to manage the
full lifecycle of your clusters, including installing and provisioning,
upgrading, repairing, and unprovisioning your Kubernetes clusters.

## Features

### Easily Deploy Your Highly Available Cluster On Any Infrastructure

KubeOne works on any infrastructure out of the box. All you need to do is to
provision the infrastructure and let KubeOne know about it. KubeOne will take
care of setting up a production ready Highly Available cluster!

### Native Support For The Most Popular Providers

KubeOne natively supports the most popular providers, including AWS, Azure,
DigitalOcean, GCP, Hetzner Cloud, OpenStack, and VMware vSphere. The natively
supported providers enjoy additional features such as integration with Terraform
and Kubermatic machine-controller.

### Kubernetes Conformance Certified

KubeOne is a Kubernetes Conformance Certified installer with support for
all [upstream-supported][upstream-supported-versions] Kubernetes versions.

### Declarative Cluster Definition

Define all your clusters declaratively, in a form of a YAML manifest.
You describe what features you want and KubeOne takes care of setting them up.

### Integration With Terraform

The built-in integration with Terraform, allows you to easily provision your
infrastructure using Terraform and let KubeOne take all the needed information
from the Terraform state.

### Integration With Cluster-API and Kubermatic machine-controller

Manage your worker nodes declaratively by utilizing the [Cluster-API][cluster-api]
and [Kubermatic machine-controller][machine-controller]. Create, remove,
upgrade, or scale your worker nodes using kubectl.

## Getting Started

Check out the Getting Started section to learn how to install KubeOne and get
started with it.

## Getting Involved

We very appreciate contributions! If you want to contribute or have an idea for
a new feature or improvement, please check out our
[contributing guide][contributing-guide].

If you have any question or if you'd like to discuss about improvements and new
features, connect with us over the forums or Slack:

* [`#kubeone` channel][slack-kubeone] on [Kubernetes Slack][slack-k8s]
* [Kubermatic forums][forums]


[upstream-supported-versions]: https://kubernetes.io/docs/setup/release/version-skew-policy/#supported-versions
[cluster-api]: https://github.com/kubernetes-sigs/cluster-api
[machine-controller]: https://github.com/kubermatic/machine-controller
[contributing-guide]: https://github.com/kubermatic/kubeone/blob/master/CONTRIBUTING.md
[slack-kubeone]: https://kubernetes.slack.com/messages/CNEV2UMT7
[slack-k8s]: http://slack.k8s.io/
[forums]: https://forum.kubermatic.com/
