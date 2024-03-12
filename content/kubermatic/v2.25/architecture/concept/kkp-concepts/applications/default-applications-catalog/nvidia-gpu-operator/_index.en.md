+++
title = "Nvidia GPU Operator Application"
linkTitle = "Nvidia GPU Operator"
enterprise = true
date = 2024-03-11T12:57:00+02:00
weight = 12

+++

# What is Nvidia GPU Operator?
The NVIDIA GPU Operator uses the operator framework within Kubernetes to automate the management of all NVIDIA software components needed to provision GPU.

For more information on the Nvidia GPU Operator, please refer to the [official documentation](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/overview.html)

# How to deploy?

Nvidia GPU Operator is available as part of the KKP's default application catalog. 
It can be deployed to the user cluster either during the cluster creation or after the cluster is ready(existing cluster) from the Applications tab via UI.

* Select the Nvidia GPU Operator application from the Application Catalog.

![Select Nvidia GPU Operator Application](/img/kubermatic/common/applications/default-apps-catalog/01-select-application-nvidia-gpu-operator-app.png)

* Under the Settings section, select and provide appropriate details and clck `-> Next` button.

![Settings for Nvidia GPU Operator Application](/img/kubermatic/common/applications/default-apps-catalog/02-settings-nvidia-gpu-operator-app.png)

* Under the Application values page section, check the default values and add values if any required to be configured explicitly. Finally click on the `+ Add Application` to deploy the Nvidia GPU Operator application to the user cluster.

To further configure the values.yaml, find more information on the [Nvidia GPU Operator Helm chart documentation](https://github.com/NVIDIA/gpu-operator/)
