+++
title = "Cross-Cluster Service Provisioning"
date = 2021-02-24T12:00:00+02:00
weight = 2
enableToc = true
+++

This example will show you how to provision a [KubeMQ](https://kubemq.io/) service cross cluster via KubeCarrier.

## Prerequisites
### Clusters
You need two Kubernetes clusters:
- [**KubeCarrier Management Cluster**]({{< relref "../../architecture/concepts#management-cluster" >}}), where KubeCarrier 
  operator will be installed.
- A [**Service Cluster**]({{< relref "../../architecture/concepts#service-clusters" >}}), where KubeMQ operator will be 
  deployed and KubeMQ workload will be created.
  
For setting up KubeCarrier Manager Cluster and connecting a Service Cluster to it, please refer to 
[KubeCarrier Requirements]({{< relref "../../tutorials_howtos/requirements" >}}),
[KubeCarrier Installation]({{< relref "../../tutorials_howtos/installation" >}}), and [Setting up A Service Cluster]({{< relref "../../tutorials_howtos/api_usage/service_clusters" >}})
for more details.

### Accounts
In this example, we will create two `Account` objects, one is `Provider`(service provider), and one as `Tenant`(service consumer).
You can do:
```bash
$ kubectl apply \
  -f https://raw.githubusercontent.com/kubermatic/kubecarrier/master/docs/manifests/accounts.yaml
```
This will create two `Account` objects for you: `team-a`(Provider), and `team-b`(Tenant).
Please refer to [Account API page]({{< relref "../../tutorials_howtos/api_usage/accounts" >}}) for more details.

### Catalog
In order to select which services to offer to which tenant, a `Catalog` object needs to be created: 
```bash
$ kubectl apply -n team-a \
  -f https://raw.githubusercontent.com/kubermatic/kubecarrier/master/docs/manifests/catalog.yaml
```
This will create a `Catalog` object which selects all `CatalogEntries` and offers them to all `Tenants`.
Please refer to [Catalog API page]({{< relref "../../tutorials_howtos/api_usage/catalogs" >}}) for more details.

## KubeMQ Operator
After you set up the KubeCarrier Management Cluster and connect the Service Cluster to it, we will install KubeMQ operator
to the Service Cluster.
In this example, we will install KubeMQ operator via [OperatorHub](https://operatorhub.io/), please follow instructions on
[KubeMQ Operator Page](https://operatorhub.io/operator/kubemq-operator) to install it.

## Service provisioning
After KubeMQ Operator is deployed in the Service Cluster, 
