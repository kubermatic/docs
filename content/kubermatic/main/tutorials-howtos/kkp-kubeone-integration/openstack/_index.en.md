+++
title = "OpenStack"
date = 2023-05-14T14:07:15+02:00
description = "Detailed tutorial to help you manage OpenStack KubeOne cluster using KKP"
weight = 6

+++

## Import OpenStack Cluster

You can add an existing OpenStack KubeOne cluster and then manage it using KKP.

- Navigate to `KubeOne Clusters` page.

- Click `Import KubeOne Cluster` button.

![Import KubeOne Cluster](@/images/tutorials/kubeone-clusters/cluster-list-empty.png "Import KubeOne Cluster")

- Pick `OpenStack` provider.

![Select Provider](@/images/tutorials/kubeone-clusters/import-kubeone-cluster.png "Select Provider")

- Provide cluster Manifest config yaml, SSH private key and SSH key Passphrase (if any) used to create the cluster you are importing, to access the KubeOne cluster using KKP.

![Cluster Settings](@/images/tutorials/kubeone-clusters/cluster-settings-step.png "Cluster Settings")

- Enter the credentials `AuthURL`, `Username`, `Password`, `Domain`, `Project Name`, `Project ID` and `Region` used to create the KubeOne cluster you are importing.


![OpenStack credentials](@/images/tutorials/kubeone-clusters/openstack-credentials-step.png "OpenStack credentials")

- Review provided settings and click `Import KubeOne Cluster`.
