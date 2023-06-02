+++
title = "OpenStack"
date = 2023-05-14T14:07:15+02:00
description = "Detailed tutorial to help you manage OpenStack KubeOne cluster using KKP"
weight = 7

+++

## Import OpenStack Cluster

You can add an existing OpenStack KubeOne cluster and then manage it using KKP.

- Navigate to `KubeOne Clusters` page.

- Click `Import KubeOne Cluster` button.

![Import KubeOne Cluster](/img/kubermatic/main/tutorials/kubeone_clusters/cluster_list_empty.png "Import KubeOne Cluster")

- Pick `OpenStack` provider.

![Select Provider](/img/kubermatic/main/tutorials/kubeone_clusters/import_kubeone_cluster.png "Select Provider")

- Provide cluster Manifest config yaml, SSH private key and SSH key Passphrase (if any) used to create the cluster you are importing, to access the KubeOne cluster using KKP.

![Cluster Settings](/img/kubermatic/main/tutorials/kubeone_clusters/cluster_settings_step.png "Cluster Settings")

- Provide Credentials in either of the below mentioned ways:
    - Select a pre-created preset which stores the provider specific credentials.

    - Manually enter the credentials `AuthURL`, `Username`, `Password`, `Domain`, `Project Name`, `Project ID`, `Region` used to create the KubeOne cluster you are importing.


![OpenStack credentials](/img/kubermatic/main/tutorials/kubeone_clusters/openstack_credentials_step.png "OpenStack credentials")

- Review provided settings and click `Import KubeOne Cluster`.
