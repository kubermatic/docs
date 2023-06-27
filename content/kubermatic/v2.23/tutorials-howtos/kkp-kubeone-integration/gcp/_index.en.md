+++
title = "Google Cloud Provider"
date = 2023-02-21T14:07:15+02:00
description = "Detailed tutorial to help you manage Google KubeOne cluster using KKP"
weight = 4

+++

## Import GCP Cluster

You can add an existing Google KubeOne cluster and then manage it using KKP.

- Navigate to `KubeOne Clusters` page.

- Click `Import KubeOne Cluster` button.

![Import KubeOne Cluster](/img/kubermatic/v2.23/tutorials/kubeone_clusters/cluster_list_empty.png "Import KubeOne Cluster")

- Pick `Google` provider.

![Select Provider](/img/kubermatic/v2.23/tutorials/kubeone_clusters/import_kubeone_cluster.png "Select Provider")

- Provide cluster Manifest config and enter private key to access the KubeOne cluster.

![Cluster Settings](/img/kubermatic/v2.23/tutorials/kubeone_clusters/cluster_settings_step.png "Cluster Settings")

- Provide Credentials in either of the below mentioned ways:
    - Select a pre-created preset which stores the provider specific credentials.

    - Manually enter the credentials `Service Account`.

![GCP credentials](/img/kubermatic/v2.23/tutorials/kubeone_clusters/gcp_credentials_step.png "GCP credentials")

- Review provided settings and click `Import KubeOne Cluster`.
