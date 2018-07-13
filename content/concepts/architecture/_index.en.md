+++
title = "Architecture"
date = 2018-05-04T12:07:15+02:00
weight = 5
pre = "<b></b>"
+++

## Architecture

![Kubermatic architecture diagram](/img/concepts/architecture/kubermatic_architecture.png)

### Master Cluster

The **Master Cluster** a Kubernetes cluster which is responsible for storing the information about clusters and SSH keys.
It hosts the Kubermatic components and might also act as a seed cluster.

The Kubermatic components are the

* Dashboard
* Kubermatic API
* Kubermatic Controller Manager

### Seed Cluster

The **Seed Cluster** is a Kubernetes cluster which is responsible for hosting the master components of a customer cluster.

The Seed Cluster uses namespaces of Kubernetes to logically separate resources from each other. Kubermatic will install the master components of a Kubernetes cluster within each namespace.

### Customer Cluster

In this context, the term **Seed Data Center** should also be explained. The Seed Datacenter is the data center where the seed cluster and its master and node components are hosted. Usually the master and the nodes are on the same network to keep latencies as low as possible.

The **Customer Cluster** is a Kubernetes cluster created and managed by Kubermatic.
