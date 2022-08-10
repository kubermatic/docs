+++
title = "Adding Applications To Cluster"
date =  2022-08-03T16:43:41+02:00
weight = 5
+++

{{< toc >}}

## Introduction

This guide targets Cluster Admins and details how KKP Applications can be integrated into a cluster.
KKP Applications offer a seamless experience to add third-party applications into a KKP cluster and offer full [integration with KKP's UI](#adding-applications) as well as [GitOps Systems](#managing-applications-via-gitops).
Before Applications are available to Cluster Admins, a KKP Admin must [create an Application Catalogue](../create-application-catalogue/).

KKP Applications leverage established Kubernetes projects (e.g. helm) for templating manifests. This ensures compatibility within the Kubernetes ecosystem. For example, a list of community-developed charts can be found on [ArtifactHub's Helm Section](https://artifacthub.io/packages/search?kind=0&sort=relevance&page=1)

{{< figure src="../application-catalogue.png" title="Example of an Application Catalogue" >}}

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

## Managing Applications via the UI

### Adding Applications to an Existing Cluster

All App functionality resides in the Applications Tab, from which a new Application can be added.

{{< figure src="./application_section.png" title="Applications Tab" >}}

An application catalogue will be displayed. If no Applications are being displayed, please contact your KKP administrator to [create an Application Catalogue](../create-application-catalogue/)

{{< figure src="../application-catalogue.png" title="Application Catalogue" >}}

After choosing an Application, its installation can be further customized.

{{< figure src="./application_customization.png" title="Application Installation Customization" >}}

The following can be customized:

- `Version` -> The version of the Application that should be displayed
- `Namespace` -> The namespace the workload should be installed in. If the namespace does not exist, KKP will automatically create it
- `Name` -> The name of the Application
- `Values` -> Value override for Installation. This will be left-merged with the default values of your Application.

The combination of Namespace and Name must be unique within your cluster.

After you have selected your customizations, the installation-status of your Application can be viewed in the Applications Tab.

{{< figure src="./application_status.png" title="Application Installation Status" >}}

### Creating a New Cluster With Applications

In the cluster creation wizard, you can select applications to install into your cluster.
KKP will automatically install your selection after the infrastructure is provisioned and the cluster is ready.

Applications can be added in the `Applications` Section of the wizard.
For a detailed flow and explanation of all customizations see  the ["Adding Applications to an Existing Cluster"](#adding-applications-to-an-existing-cluster) section of this guide.

{{< figure src="./applications_flow_in_cluster_wizard.png" title="Application Section in Cluster Creation Wizard" >}}

Afterwards, you can track the installation progress in the Applications Tab.

{{< figure src="./application_status.png" title="Application Installation Status" >}}

### Storing Applications in a ClusterTemplate

ApplicationInstallations can also be added to [ClusterTemplates](../../cluster_templates/) in order to re-use them across multiple clusters. In order to do so, select the `Save Cluster Template` option during the Summary step of the cluster creation wizard.

{{< figure src="./save_to_cluster_template.png" title="Saving As Cluster Template" >}}

## Managing Applications via GitOps

KKP Applications are managed via the `ApplicationInstallation` custom Kubernetes resource.
ApplicationInstallations reside in the user-cluster and represent a desired state of an Application.
For a full reference of all suported fields, please check the [ApplicationInstallation Reference](#applicationinstallation-reference) Section of this guide.

```yaml
# Example of an ApplicationInstallation
apiVersion: apps.kubermatic.k8c.io/v1
kind: ApplicationInstallation
metadata:
  name: prometheus
  namespace: prometheus
spec:
  applicationRef:
    name: prometheus
    version: 2.36.2
  namespace:
    create: true
    name: prometheus
  values:
    alertmanager:
      enabled: false
```

After creating an ApplicationInstallation, you can directly apply it into the desired cluster using kubectl. This will trigger a controller within KKP, which will automatically install your Application. We recommend to apply the ApplicationInstallation to the same namespace as the workload and configuration you want to deploy.

```sh
kubectl apply -n <namespace> -f <your-appinstall>
```

You can check the progress of your installation in `status.conditions`.

```sh
kubectl -n <namespace> get applicationinstallation <name> -o jsonpath='{.status.conditions}'
```

There are 2 conditions:

- `ManifestsRetrieved` -> application's source has been correctly downloaded
- `Ready` ->  application has been correctly installed or upgraded

Additionally when using helm, the field `status.helmRelease` will contain additional information.

```sh
kubectl -n <namespace> get applicationinstallation <name> -o jsonpath='{.status.helmRelease}'
```

## ApplicationInstallation Reference

// TODO Currently there is a bug when generating a reference from a slice field that has two values. Before fixing this, I wanted to make the larger part of the guide already available, so it does not block testing. For the release a full reference will be displayed here.

For now if you want to look into any details, you can run:

```sh
# inside any KKP cluster
kubectl explain applicationinstallation
```
