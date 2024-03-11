+++
title = "Falco Application"
linkTitle = "Falco"
enterprise = true
date = 2024-01-16T12:57:00+02:00
weight = 7

+++

# What is Falco?

Falco is a cloud-native security tool designed for Linux systems. It employs custom rules on kernel events, which are enriched with container and Kubernetes metadata, to provide real-time alerts. Falco helps you gain visibility into abnormal behavior, potential security threats, and compliance violations, contributing to comprehensive runtime security.

For more information on the Falco, please refer to the [official documentation](https://falco.org/)

# How to deploy?

Falco is available as part of the KKP's default application catalog. 
It can be deployed to the user cluster either during the cluster creation or after the cluster is ready(existing cluster) from the Applications tab via UI.

* Select the Falco application from the Application Catalog.

![Select Falco Application](/img/kubermatic/v2.24/architecture/concepts/applications/default-applications-catalog/01-select-application-falco-app.png)

* Under the Settings section, select and provide appropriate details and clck `-> Next` button.

![Settings for Falco Application](/img/kubermatic/v2.24/architecture/concepts/applications/default-applications-catalog/02-settings-falco-app.png)

* Under the Application values page section, check the default values and add values if any required to be configured explicitly. Finally click on the `+ Add Application` to deploy the Falco application to the user cluster.

To further configure the values.yaml, find more information on the [Falco Helm chart documentation](https://github.com/falcosecurity/charts/tree/master/charts/falco).
