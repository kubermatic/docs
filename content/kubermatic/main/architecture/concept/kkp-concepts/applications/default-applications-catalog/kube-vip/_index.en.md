+++
title = "Kube-VIP Application"
linkTitle = "Kube-VIP"
enterprise = true
date = 2024-01-16T12:57:00+02:00
weight = 6

+++

# What is Kube-VIP?

For more information on the Kube-VIP, please refer to the [official documentation](https://kube-vip.io/)

# How to deploy?

Kube-VIP is available as part of the KKP's default application catalog. 
It can be deployed to the user cluster either during the cluster creation or after the cluster is ready(existing cluster) from the Applications tab via UI.

* Select the Kube-VIP application from the Application Catalog.

![Select Kube-VIP Application](/img/kubermatic/common/applications/default-apps-catalog/01-select-application-kube-vip-app.png)

* Under the Settings section, select and provide appropriate details and clck `-> Next` button.

![Settings for Kube-VIP Application](/img/kubermatic/common/applications/default-apps-catalog/02-settings-kube-vip-app.png)

* Under the Application values page section, check the default values and add values if any required to be configured explicitly. Finally click on the `+ Add Application` to deploy the Kube-VIP application to the user cluster.

To further configure the values.yaml, find more information on the [Kube-vip Helm chart documentation](https://github.com/kube-vip/helm-charts).
