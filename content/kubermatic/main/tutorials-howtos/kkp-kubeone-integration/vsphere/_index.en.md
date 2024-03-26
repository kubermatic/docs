+++
title = "vSphere"
date = 2023-06-15T14:07:15+02:00
description = "Detailed tutorial to help you manage vSphere KubeOne cluster using KKP"
weight = 7

+++

## Import vSphere Cluster

You can add an existing vSphere KubeOne cluster and then manage it using KKP.

- Navigate to `KubeOne Clusters` page.

- Click `Import KubeOne Cluster` button.

![Import KubeOne Cluster](@/images/main/tutorials/kubeone-clusters/cluster-list-empty.png "Import KubeOne Cluster")

- Pick `vSphere` provider.

![Select Provider](@/images/main/tutorials/kubeone-clusters/import-kubeone-cluster.png "Select Provider")

- Provide cluster Manifest config yaml, SSH private key and SSH key Passphrase (if any) used to create the cluster you are importing, to access the KubeOne cluster using KKP.

![Cluster Settings](@/images/main/tutorials/kubeone-clusters/cluster-settings-step.png "Cluster Settings")

- Enter the credentials `Username`, `Password`, and `ServerURL` used to create the KubeOne cluster you are importing.


![vSphere credentials](@/images/main/tutorials/kubeone-clusters/vsphere-credentials-step.png "vSphere credentials")

- Review provided settings and click `Import KubeOne Cluster`.
