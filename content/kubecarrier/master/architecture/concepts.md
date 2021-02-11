---
title: Concepts
weight: 10
date: 2021-02-10T11:30:00+02:00
---

KubeCarrier is a multi-cluster application service management tool. Each KubeCarrier deployment consists of two types
of clusters: Management Cluster and Service Clusters.

## Management Cluster
As part of the [KubeCarrier Installation]({{< relref "../tutorials_howtos/installation" >}}) KubeCarrier operator
is installed into a Kubernetes cluster. This cluster will become the Management Cluster, which will provide the central 
Service Hub functionality for management and distribution of applications in one or more Service Clusters that are 
registered in the Management Cluster.

## Service Clusters
Service Clusters are Kubernetes clusters that run the actual application workloads managed by their Operators,
which are driven by the KubeCarrier Service Hub. To allow that, the Service Clusters first have to be
[registered in the Management Cluster]({{< relref "../tutorials_howtos/api_usage/service_clusters" >}}).

Service Clusters run Operators of the applications that they are providing as a service to the central Service Hub.
After including a Custom Resource Definition (CRD) of an application Operator in a
[CatalogEntrySet]({{< relref "../tutorials_howtos/api_usage/catalogs" >}}), KubeCarrier will automatically discover
that CRD in Service Clusters, and make them available for management and distribution via the central Service Hub.

Whenever a new instance of a service's Custom Resource (CR) is created in the Service Hub for a given Service Cluster,
KubeCarrier will automatically propagate it into the target Service Cluster, which will drive the Operator running
in it to deploy the application.
