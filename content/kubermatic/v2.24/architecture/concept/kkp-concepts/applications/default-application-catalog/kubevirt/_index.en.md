+++
title = "KubeVirt Application"
date = 2024-01-16T12:57:00+02:00
weight = 10

+++

# What is KubeVirt?

KubeVirt is a virtual machine management add-on for Kubernetes. The aim is to provide a common ground for virtualization solutions on top of Kubernetes.

As of today KubeVirt can be used to declaratively

- Create a predefined VM
- Schedule a VM on a Kubernetes cluster
- Launch a VM
- Stop a VM
- Delete a VM

For more information on the KubeVirt, please refer to the [official documentation](https://kubevirt.io/)

# How to deploy?

KubeVirt is available as part of the KKP's default application catalog. 
It can be deployed to the user cluster either during the cluster creation or after the cluster is ready(existing cluster) from the Applications tab via UI.

* Select the KubeVirt application from the Application Catalog.

![Select KubeVirt Application](/img/kubermatic/common/applications/default-app-catalog/01-select-application-kubevirt-app.png)

* Under the Settings section, select and provide appropriate details and clck `-> Next` button.

![Settings for KubeVirt Application](/img/kubermatic/common/applications/default-app-catalog/02-settings-kubevirt-app.png)
