+++
title = "Applications"
date = 2023-01-27T14:07:15+02:00
weight = 21

+++

KKP Applications offer a seamless experience to add third-party applications into a KKP cluster and offer full [integration with KKP's UI]({{< ref "../../../../tutorials-howtos/applications/add-applications-to-cluster#managing-applications-via-the-ui" >}}) as well as [GitOps Systems]({{< ref "../../../../tutorials-howtos/applications/add-applications-to-cluster#managing-applications-via-gitops" >}}).

KKP Applications leverage established Kubernetes projects (e.g. helm) for templating manifests. This ensures compatibility within the Kubernetes ecosystem. For example, a list of community-developed charts can be found on [ArtifactHub's Helm Section](https://artifacthub.io/packages/search?kind=0&sort=relevance&page=1)

![Example of an Application Catalogue](/img/kubermatic/common/applications/application-catalogue.png "Example of an Application Catalogue")

Currently, helm is exclusively supported as a templating method, but integrations with other templating engines are planned.
Helm Applications can both be installed from helm registries directly or from a git repository.

## Concepts
KKP manages Applications using two key mechanisms: [ApplicationDefinitions]({{< ref "./application-definition" >}}) and [ApplicationInstallations]({{< ref "./application-installation" >}}).

`ApplicationDefinitions` are managed by KKP Admins and contain all the necessary information for an application's installation.

`ApplicationInstallations`, on the other hand, are managed by Cluster Admins and simplify the installation process by referencing `ApplicationDefinitions` and defining custom parameters for the installation. `ApplicationInstallations` aim to simplify the installation of applications, which helps users to get their apps up and running quickly and continue their work on domain-related topics.

Concretely KKP admins "publish" available applications via the [ApplicationDefinition]({{< ref "./application-definition" >}}) CR, and Cluster admins will be able to install the application using [ApplicationInstallations]({{< ref "./application-installation" >}}) CR or [UI]({{< ref "../../../../tutorials-howtos/applications/add-applications-to-cluster#managing-applications-via-the-ui" >}}).

## Comparison To KKP Addons

While sharing a similar goal, KKP Applications and [KKP Addons]({{< ref "../addons/" >}}) differ in scope and complexity:

KKP Applications provide an integration using established Kubernetes Technologies to deploy Application workload and configuration.
They are a great choice for leveraging Kubernetes community contributions or basing your own applications on them. For example, to deploy the popular monitoring solution Prometheus, you can make use of the community-developed [Prometheus Helm Chart](https://github.com/prometheus-community/helm-charts) and do not have to package the application yourself.
Furthermore, Applications integrate seamlessly into the KKP lifecycle and can be stored in KKP Cluster Templates for re-usability.

KKP Addons, on the other hand, are powerful extensions that can not only deploy workload and configuration into a cluster but also change the underlying functionality of the cluster itself. The majority of KKP addons are provided directly by Kubermatic.
Addons are a great choice if you want to extend the functionality of your cluster and when you need access to lower-level functionality.

In general, we recommend the usage of Applications for workloads running inside a cluster and recommend to use Addons when specific lower-level capabilities are required (e.g. making changes to nodes of a cluster or changing network interfaces).
