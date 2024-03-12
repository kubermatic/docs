+++
title = "Installation"
date = 2018-04-28T12:07:15+02:00
weight = 15
+++

This chapter offers guidance on how to install Kubermatic Kubernetes Platform (KKP).

## Terminology

In this chapter, you will find the following KKP-specific terms:

* **Master Cluster** -- A Kubernetes cluster which is responsible for storing central information about users, projects and SSH keys. It hosts the KKP master components and might also act as a seed cluster.
* **Seed Cluster** -- A Kubernetes cluster which is responsible for hosting the control plane components (kube-apiserver, kube-scheduler, kube-controller-manager, etcd and more) of a User Cluster.
* **User Cluster** -- A Kubernetes cluster created and managed by KKP, hosting applications managed by users.

It is also recommended to make yourself familiar with our [architecture documentation]({{< ref "../architecture/" >}}).

## Installation Methods

At the moment, the only supported installation method for KKP is using the Kubermatic Installer. We provide an [installation guide for the Community Edition (CE)]({{< ref "./install-kkp-ce/" >}}) that uses this method. Installation for the Enterprise Edition (EE) is fundamentally the same and only requires a adjustments to the CE installation that you can find [here]({{< ref "./install-kkp-ee/" >}}).

## Pages

{{% children depth=5 %}}
{{% /children %}}
