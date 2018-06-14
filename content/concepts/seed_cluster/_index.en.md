+++
title = "Seed Cluster"
date = 2018-04-28T12:07:15+02:00
weight = 10
pre = "<b></b>"
+++

## Seed Cluster


The **Seed Cluster** is a Kubernetes cluster which is responsible for hosting the master components of a customer cluster.

The Seed Cluster uses namespaces of Kubernetes to logically separate resources from each other. Kubermatic will install the master components of a kubernetes cluster within each namespace.

In this context, the term **Seed Data Center** should also be explained. The Seed Datacenter is the data center where the seed cluster and its master and node components are hosted. Usually the master and the nodes are on the same network to keep latencies as low as possible.
