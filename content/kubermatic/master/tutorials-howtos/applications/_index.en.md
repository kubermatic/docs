+++
title = "Applications"
date =  2022-08-03T16:27:43+02:00
weight = 5
+++

{{< toc >}}

## Introduction

KKP Applications offer a seamless experience to add third-party applications into a KKP cluster and offer full [integration with KKP's UI](./add-applications-to-cluster#adding-applications) as well as [GitOps Systems](add-applications-to-cluster#managing-applications-via-gitops).

KKP Applications leverage established Kubernetes projects (e.g. helm) for templating manifests. This ensures compatibility within the Kubernetes ecosystem. For example, a list of community-developed charts can be found on [ArtifactHub's Helm Section](https://artifacthub.io/packages/search?kind=0&sort=relevance&page=1)

{{< figure src="./application-catalogue.png" title="Example of an Application Catalogue" >}}

Currently helm is exclusively supported as a templating method, but integrations with other templating engines are planned.
Helm Applications can both be installed from helm registries directly or from a git repository.

## Comparison To KKP Addons

While sharing a similar goal, KKP Applications and [KKP Addons](../../../architecture/concept/kkp-concepts/addons/) differ in scope and complexity:

KKP Applications provide an integration using established Kubernetes Technologies to deploy Application workload and configuration.
They are a great choice for leveraging Kubernetes community contributions or basing your own applications on them. For example to deploy the popular monitoring solution Prometheus, you can make use of the community-developed [Prometheus Helm Chart](https://github.com/prometheus-community/helm-charts) and do not have to package the application yourself.
Furthermore, Applications integrate seamlessly into the KKP lifecycle and can be stored in KKP Cluster Templates for re-usability.

KKP Addons on the other hand, are powerful extensions which can not only deploy workload and configuration into a cluster, but also change the underlying functionality of the cluster itself. The majority of KKP addons are provided directly by Kubermatic.
Addons are a great choice if you want to extend the functionality of your cluster and when you need access to lower-level functionality.

In general, we recommend the usage of Applications for workloads running inside a cluster and recommend to use Addons when specific lower-level capabilities are required (e.g. making changes to nodes of a cluster or changing network interfaces).

## Practical User Guides

- [Creating An Application Catalogue](./create-application-catalogue/)
- [Adding Applications To A Cluster](./add-applications-to-cluster/)