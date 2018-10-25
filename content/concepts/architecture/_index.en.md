+++
title = "Architecture"
date = 2018-05-04T12:07:15+02:00
weight = 5
pre = "<b></b>"
+++

Kubermatic makes full use of Kubernetes cluster to organize and scale workloads, depending on your and your customer's needs. In a typical small-scale setup, pictured below, a single cluster contains Kubermatic and the master components for every customer cluster.

![Kubermatic Architecture Diagram](/img/concepts/architecture/combined-master-seed.png)

### Master Cluster

The **Master Cluster** a Kubernetes cluster which is responsible for storing the information about users, projects and SSH keys.
It hosts the Kubermatic components and might also act as a seed cluster.

The Kubermatic components are the

* Dashboard
* Kubermatic API
* Kubermatic Controller Manager

### Seed Cluster

The **Seed Cluster** is a Kubernetes cluster which is responsible for hosting the master components of a customer cluster.

The seed cluster uses namespaces of Kubernetes to logically separate resources from each other. Kubermatic will install the master components of a Kubernetes cluster within each namespace, plus a light monitoring stack consisting of Prometheus and an OpenVPN server to allow secure communication between the master components in the seed cluster and the pod/service network of the worker nodes.

### Customer Cluster

The **Customer Cluster** is a Kubernetes cluster created and managed by Kubermatic.

### Datacenters

Kubermatic has the concept of **Datacenters**, for example "AWS US-East", "DigitalOcean Frankfurt" or a local vSphere deployment. Datacenters are used to specify where customer clusters can be created in, so you can choose to only support running customer clusters on AWS.

### Large-Scale Deployments

Instead of running the Kubermatic master and seed components in a single cluster, it is advisable for large-scale deployments to have multiple, dedicated seed clusters, as pictured below.

![Kubermatic Architecture Diagram](/img/concepts/architecture/dedicated-seeds.png)

This setup is useful for keeping the latency between the master components of a customer cluster and the worker nodes as small as possible, improving the Kubernetes performance for customers. In this setup, the supported datacenters are assigned to a single seed, for example

* Seed `seed-us` on GKE in `us-east1` supports creating clusters in
  * AWS us-east-2 and us-west-1
  * Google Cloud us-east1 and us-west1
  * DigitalOcean New York 1
* Seed `seed-eu` on Amazon EC2 in `eu-west-1` supports creating clusters in
  * AWS eu-central-1 and eu-west-1
  * DigitalOcean ams1 and lon1

See the [installation documentation](../../installation/install_kubermatic/) for more details on how to setup datacenters.
