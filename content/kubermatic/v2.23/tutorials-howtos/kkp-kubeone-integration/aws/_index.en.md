+++
title = "AWS"
date = 2023-02-21T14:07:15+02:00
description = "Detailed tutorial to help you manage AWS KubeOne cluster using KKP"
weight = 1

+++

## Import AWS Cluster

You can add an existing AWS KubeOne cluster and then manage it using KKP.

- Navigate to `KubeOne Clusters` page.

- Click `Import KubeOne Cluster` button.

![Import KubeOne Cluster](/img/kubermatic/v2.23/tutorials/kubeone_clusters/cluster_list_empty.png "Import KubeOne Cluster")

- Pick `AWS` provider.

![Select Provider](/img/kubermatic/v2.23/tutorials/kubeone_clusters/import_kubeone_cluster.png "Select Provider")

- Provide cluster Manifest config and enter SSH private key to access the KubeOne cluster.

![Cluster Settings](/img/kubermatic/v2.23/tutorials/kubeone_clusters/cluster_settings_step.png "Cluster Settings")

- Provide Credentials in either of the below mentioned ways:
    - Select a pre-created preset which stores the provider specific credentials.

    - Manually enter the credentials `Access Key ID`, `Secret Access Key`.

![AWS credentials](/img/kubermatic/v2.23/tutorials/kubeone_clusters/aws_credentials_step.png "AWS credentials")

- Review provided settings and click `Import KubeOne Cluster`.



