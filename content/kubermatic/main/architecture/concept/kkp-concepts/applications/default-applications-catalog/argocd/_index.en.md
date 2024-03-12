+++
title = "ArgoCD Application"
linkTitle = "ArgoCD"
enterprise = true
date = 2024-01-16T12:57:00+02:00
weight = 1

+++

# What is ArgoCD?
ArgoCD is a declarative, GitOps continuous delivery tool for Kubernetes.

ArgoCD follows the GitOps pattern of using Git repositories as the source of truth for defining the desired application state. Kubernetes manifests can be specified in several ways:

- kustomize applications
- helm charts
- jsonnet files
- Plain directory of YAML/json manifests
- Any custom config management tool configured as a config management plugin


For more information on the ArgoCD, please refer to the [official documentation](https://argoproj.github.io/cd/)

# How to deploy?

ArgoCD is available as part of the KKP's default application catalog. 
It can be deployed to the user cluster either during the cluster creation or after the cluster is ready(existing cluster) from the Applications tab via UI.

* Select the ArgoCD application from the Application Catalog.

![Select ArgoCD Application](/img/kubermatic/common/applications/default-apps-catalog/01-select-application-argocd-app.png)

* Under the Settings section, select and provide appropriate details and clck `-> Next` button.

![Settings for ArgoCD Application](/img/kubermatic/common/applications/default-apps-catalog/02-settings-argocd-app.png)

* Under the Application values page section, check the default values and add values if any required to be configured explicitly. Finally click on the `+ Add Application` to deploy the ArgoCD application to the user cluster.

![Application Values for ArgoCD Application](/img/kubermatic/common/applications/default-apps-catalog/03-applicationvalues-argocd-app.png)

To further configure the values.yaml, find more information on the [ArgoCD Helm chart documentation](https://github.com/argoproj/argo-helm)
