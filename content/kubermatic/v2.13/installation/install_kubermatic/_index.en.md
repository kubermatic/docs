+++
title = "Install Kubermatic Kubernetes  (KKP)"
date = 2018-04-28T12:07:15+02:00
weight = 20

+++

This chapter explains the automated as well as the manual installation of KKP into a pre-existing Kubernetes cluster.

{{% notice note %}}
At the moment you need to be invited to get access to KKP's Docker registry before you can try it out. Please [contact sales](mailto:sales@kubermatic.com) to receive your credentials.
{{% /notice %}}

## Terminology

* **User/Customer cluster** -- A Kubernetes cluster created and managed by KKP
* **Seed cluster** -- A Kubernetes cluster which is responsible for hosting the master components of a customer cluster
* **Master cluster** -- A Kubernetes cluster which is responsible for storing the information about users, projects and SSH keys. It hosts the KKP components and might also act as a seed cluster.
* **Seed datacenter** -- A definition/reference to a seed cluster
* **Node datacenter** -- A definition/reference of a datacenter/region/zone at a cloud provider (aws=zone, digitalocean=region, openstack=zone)
