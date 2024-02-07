+++
title = "Trivy Operator Application"
linkTitle = "Trivy Operator"
enterprise = true
date = 2024-01-16T12:57:00+02:00
weight = 9

+++

# What is Trivy Operator?

The Trivy Operator leverages Trivy to continuously scan your Kubernetes cluster for security issues. The scans are summarised in security reports as Kubernetes Custom Resources, which become accessible through the Kubernetes API. The Operator does this by watching Kubernetes for state changes and automatically triggering security scans in response. For example, a vulnerability scan is initiated when a new Pod is created. This way, users can find and view the risks that relate to different resources in a Kubernetes-native way.

Trivy Operator can be deployed and used for scanning the resources deployed on the underlying the Kubernetes cluster, while Trivy provides a way to scan images/configurations/secrets to the end users.

For more information on the Trivy Operator, please refer to the [official documentation](https://aquasecurity.github.io/trivy-operator/latest/)

# How to deploy?

Trivy Operator is available as part of the KKP's default application catalog. 
It can be deployed to the user cluster either during the cluster creation or after the cluster is ready(existing cluster) from the Applications tab via UI.

* Select the Trivy Operator application from the Application Catalog.

![Select Trivy Operator Application](/img/kubermatic/common/applications/default-apps-catalog/01-select-application-trivy-operator-app.png)

* Under the Settings section, select and provide appropriate details and clck `-> Next` button.

![Settings for Trivy Operator Application](/img/kubermatic/common/applications/default-apps-catalog/02-settings-trivy-operator-app.png)

* Under the Application values page section, check the default values and add values if any required to be configured explicitly. Finally click on the `+ Add Application` to deploy the Trivy Operator application to the user cluster.

![Application Values for Trivy Operator Application](/img/kubermatic/common/applications/default-apps-catalog/03-applicationvalues-trivy-operator-app.png)

* Under the Application values page section, check the default values and add values if any required to be configured explicitly. Finally click on the `+ Add Application` to deploy the Trivy Operator application to the user cluster.

To further configure the values.yaml, find more information on the [Trivy Operator Helm chart documentation](https://github.com/aquasecurity/trivy-operator/tree/main/deploy/helm).
