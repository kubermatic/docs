+++
title = "MetalLB Application"
linkTitle = "MetalLB"
enterprise = true
date = 2024-01-16T12:57:00+02:00
weight = 4

+++

# What is MetalLB?

MetalLB is a load-balancer implementation for bare metal Kubernetes clusters, using standard routing protocols.


For more information on the MetalLB, please refer to the [official documentation](https://metallb.universe.tf/)

# How to deploy?

MetalLB is available as part of the KKP's default application catalog. 
It can be deployed to the user cluster either during the cluster creation or after the cluster is ready(existing cluster) from the Applications tab via UI.

* Select the MetalLB application from the Application Catalog.

![Select MetalLB Application](/img/kubermatic/v2.24/architecture/concepts/applications/default-applications-catalog/01-select-application-metallb-app.png)

* Under the Settings section, select and provide appropriate details and clck `-> Next` button.

![Settings for MetalLB Application](/img/kubermatic/v2.24/architecture/concepts/applications/default-applications-catalog/02-settings-metallb-app.png)

* Under the Application values page section, check the default values and add values if any required to be configured explicitly. Finally click on the `+ Add Application` to deploy the MetalLB application to the user cluster.

To further configure the values.yaml, find more information on the [MetalLB Helm chart documentation](https://github.com/metallb/metallb/tree/main/charts/metallb).
