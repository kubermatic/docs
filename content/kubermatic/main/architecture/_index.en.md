+++
title = "Architecture"
date = 2018-05-04T12:07:15+02:00
weight = 5

+++

Kubermatic Kubernetes Platform (KKP) makes full use of Kubernetes cluster to organize and scale workloads, depending on your and your customer's needs. On a high level we differentiate between the Master Cluster, Seed Clusters, and User Clusters.

## Terminology

### Master Cluster

The **Master Cluster** is a Kubernetes cluster which is responsible for storing the information about users, projects, SSH keys and credentials for infrastructure providers. All sensitive information is stored in etcd, which is split across the nodes of the master cluster.
It hosts the KKP components and might also act as a seed cluster.

The KKP components are the

* Dashboard
* KKP API
* KKP Controller Manager

### Seed Cluster

The **Seed Cluster** is a Kubernetes cluster which is responsible for hosting the master components of a user cluster including credentials for the available infrastructure providers. All sensitive information is stored in etcd, which is split across the nodes of the seed cluster.

The seed cluster uses namespaces of Kubernetes to logically separate resources from each other. KKP will install the master components of a Kubernetes cluster within each namespace, plus a light monitoring stack consisting of Prometheus and an OpenVPN server to allow secure communication between the master components in the seed cluster and the pod/service network of the worker nodes.

### User Cluster

The **User Cluster** is a Kubernetes cluster created and managed by KKP.

### Datacenters

KKP has the concept of **Datacenters**, for example "AWS US-East", "DigitalOcean Frankfurt" or a local vSphere deployment. Datacenters are used to specify where user clusters can be created in, so you can choose to only support running user clusters on AWS.

## Deployment Types

### Small-Scale Deployments

In a typical small-scale setup, pictured below, a single cluster contains KKP and the master components for every user cluster.

![KKP Architecture Diagram](/img/kubermatic/main/architecture/combined-master-seed.png)

### Large-Scale Deployments

Instead of running the KKP master and seed components in a single cluster, it is advisable for large-scale deployments to have multiple, dedicated seed clusters, as pictured below.

![KKP Architecture Diagram](/img/kubermatic/main/architecture/dedicated-seeds.png)

This setup is useful for keeping the latency between the master components of a user cluster and the worker nodes as small as possible, improving the Kubernetes performance for customers. In this setup, the supported datacenters are assigned to a single seed, for example

* Seed `seed-us` on GKE in `us-east1` supports creating clusters in
  * AWS us-east-2 and us-west-1
  * Google Cloud us-east1 and us-west1
  * DigitalOcean New York 1
* Seed `seed-eu` on Amazon EC2 in `eu-west-1` supports creating clusters in
  * AWS eu-central-1 and eu-west-1
  * DigitalOcean ams1 and lon1

See the [installation documentation]({{< relref "../installation/install-kkp-ce/">}}) for more details on how to setup datacenters.

## Pages

{{% children depth=5 %}}
{{% /children %}}
