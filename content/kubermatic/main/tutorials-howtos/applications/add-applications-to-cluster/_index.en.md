+++
title = "Adding Applications To A Cluster"
date =  2022-08-03T16:43:41+02:00
weight = 5
+++

{{< toc >}}

## Introduction

This guide targets Cluster Admins and details how KKP Applications can be integrated into a cluster.
KKP Applications offer a seamless experience to add third-party applications into a KKP cluster and offer full [integration with KKP's UI](#adding-applications) as well as [GitOps Systems](#managing-applications-via-gitops).
For a more details on Applications please refer to our [Applications Primer]({{< relref "../" >}}).

## Managing Applications via the UI

### Adding Applications to an Existing Cluster

All App functionality resides in the Applications Tab, from which a new Application can be added.

![Applications Tab](/img/kubermatic/common/applications/application_section.png "Applications Tab")

An application catalogue will be displayed. If no Applications are being displayed, please contact your KKP administrator to [create an Application Catalogue]({{< relref "../create-application-catalogue/" >}})

![Application Catalogue](/img/kubermatic/common/applications/application-catalogue.png "Application Catalogue")

After choosing an Application, its installation can be further customized.

![Application Settings](/img/kubermatic/common/applications/application_settings.png "Application Settings")

![Application Values](/img/kubermatic/common/applications/application_values.png "Application Values")

The following can be customized:

- `Version` -> The version of the Application that should be displayed
- `Namespace` -> The namespace the workload should be installed in. If the namespace does not exist, KKP will automatically create it
- `Name` -> The name of the Application
- `Values` -> Value override for Installation. This will be left-merged with the default values of your Application.

The combination of Namespace and Name must be unique within your cluster.

After you have selected your customizations, the installation-status of your Application can be viewed in the Applications Tab.

![Application Installation Status](/img/kubermatic/common/applications/application_status.png "Application Installation Status")

### Creating a New Cluster With Applications

In the cluster creation wizard, you can select applications to install into your cluster.
KKP will automatically install your selection after the infrastructure is provisioned and the cluster is ready.

Applications can be added in the `Applications` Section of the wizard.
For a detailed flow and explanation of all customizations see  the ["Adding Applications to an Existing Cluster"](#adding-applications-to-an-existing-cluster) section of this guide.

![Application Section in Cluster Creation Wizard](/img/kubermatic/common/applications/applications_flow_in_cluster_wizard.png "Application Section in Cluster Creation Wizard")

Afterwards, you can track the installation progress in the Applications Tab.

![Application Installation Status](/img/kubermatic/common/applications/application_status.png "Application Installation Status")

### Storing Applications in a ClusterTemplate

ApplicationInstallations can also be added to [ClusterTemplates]({{< relref "../../cluster-templates/" >}}) in order to re-use them across multiple clusters. In order to do so, select the `Save Cluster Template` option during the Summary step of the cluster creation wizard.

![Saving As Cluster Template](/img/kubermatic/common/applications/save_to_cluster_template.png "Saving As Cluster Template")

## Managing Applications via GitOps

KKP Applications are managed via the `ApplicationInstallation` custom Kubernetes resource.
ApplicationInstallations reside in the user-cluster and represent a desired state of an Application.
For a full reference of all supported fields, please check the [ApplicationInstallation Reference](#applicationinstallation-reference) Section of this guide.

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
**The following is an example of ApplicationInstallation, showing all the possible options**.

```yaml
{{< readfile "kubermatic/main/data/applicationInstallation.yaml" >}}
```
