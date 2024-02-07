+++
title = "Flux2 Application"
linkTitle = "Flux2"
enterprise = true
date = 2024-01-16T12:57:00+02:00
weight = 2

+++

# What is Flux2?

Flux is a tool for keeping Kubernetes clusters in sync with sources of configuration (like Git repositories and OCI artifacts), automating updates to configuration when there is new code to deploy.

Flux version 2 ("v2") is built from the ground up to use Kubernetes' API extension system, and to integrate with Prometheus and other core components of the Kubernetes ecosystem. In version 2, Flux supports multi-tenancy and support for syncing an arbitrary number of Git repositories, among other long-requested features.

Flux v2 is constructed with the [GitOps Toolkit](https://github.com/fluxcd/flux2?tab=readme-ov-file#gitops-toolkit), a set of composable APIs and specialized tools for building Continuous Delivery on top of Kubernetes.

Flux is a Cloud Native Computing Foundation [CNCF](https://www.cncf.io/) project, used in production by various [organisations](https://fluxcd.io/adopters/) and [cloud providers](https://fluxcd.io/ecosystem/).

For more information on the Flux2, please refer to the [official documentation](https://github.com/fluxcd-community/helm-charts)

# How to deploy?

Flux2 is available as part of the KKP's default application catalog. 
It can be deployed to the user cluster either during the cluster creation or after the cluster is ready(existing cluster) from the Applications tab via UI.

* Select the Flux2 application from the Application Catalog.

![Select Flux2 Application](/img/kubermatic/common/applications/default-apps-catalog/01-select-application-flux2-app.png)

* Under the Settings section, select and provide appropriate details and clck `-> Next` button.

![Settings for Flux2 Application](/img/kubermatic/common/applications/default-apps-catalog/02-settings-flux2-app.png)

* Under the Application values page section, check the default values and add values if any required to be configured explicitly. Finally click on the `+ Add Application` to deploy the Flux2 application to the user cluster.

A full list of available Helm values is on [flux2's ArtifactHub page](https://artifacthub.io/packages/helm/fluxcd-community/flux2)
