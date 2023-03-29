+++
title = "Azure"
title_tag = "Tutorials - Integration - Azure"
date = 2023-02-21T14:07:15+02:00
description = "Detailed tutorial to help you manage Azure KubeOne cluster using KKP"
weight = 7

+++

## Import Azure Cluster

You can add an existing Azure KubeOne cluster and then manage it using KKP.

- Navigate to `KubeOne Clusters` page.

- Click `Import KubeOne Cluster` button.

![Import KubeOne Cluster](/img/kubermatic/v2.22/tutorials/kubeone_clusters/cluster_list_empty.png "Import KubeOne Cluster")

- Pick `Azure` provider.

![Select Provider](/img/kubermatic/v2.22/tutorials/kubeone_clusters/import_kubeone_cluster.png "Select Provider")

- Provide cluster Manifest config yaml, SSH private key and SSH key Passphrase (if any) used to create the cluster you are importing, to access the KubeOne cluster using KKP.

![Cluster Settings](/img/kubermatic/v2.22/tutorials/kubeone_clusters/cluster_settings_step.png "Cluster Settings")

- Provide Credentials in either of the below mentioned ways:
    - Select a pre-created preset which stores the provider specific credentials.

    - Manually enter the credentials `Client ID`, `Client Secret`, `Subscription ID`, `Tenant ID` used to create the KubeOne cluster you are importing.

![Azure credentials](/img/kubermatic/v2.22/tutorials/kubeone_clusters/azure_credentials_step.png "Azure credentials")

- Review provided settings and click `Import KubeOne Cluster`.

