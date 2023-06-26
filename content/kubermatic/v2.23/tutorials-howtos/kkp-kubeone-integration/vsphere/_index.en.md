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

![Import KubeOne Cluster](/img/kubermatic/main/tutorials/kubeone_clusters/cluster_list_empty.png "Import KubeOne Cluster")

- Pick `vSphere` provider.

![Select Provider](/img/kubermatic/main/tutorials/kubeone_clusters/import_kubeone_cluster.png "Select Provider")

- Provide cluster Manifest config yaml, SSH private key and SSH key Passphrase (if any) used to create the cluster you are importing, to access the KubeOne cluster using KKP.

![Cluster Settings](/img/kubermatic/main/tutorials/kubeone_clusters/cluster_settings_step.png "Cluster Settings")

- Enter the credentials `Username`, `Password`, and `ServerURL` used to create the KubeOne cluster you are importing.


![vSphere credentials](/img/kubermatic/main/tutorials/kubeone_clusters/vsphere_credentials_step.png "vSphere credentials")

- Review provided settings and click `Import KubeOne Cluster`.
