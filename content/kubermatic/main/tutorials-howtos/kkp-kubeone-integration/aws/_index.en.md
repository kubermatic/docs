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

![Import KubeOne Cluster](@/images/tutorials/kubeone-clusters/cluster-list-empty.png "Import KubeOne Cluster")

- Pick `AWS` provider.

![Select Provider](@/images/tutorials/kubeone-clusters/import-kubeone-cluster.png "Select Provider")

- Provide cluster Manifest config and enter SSH private key to access the KubeOne cluster.

![Cluster Settings](@/images/tutorials/kubeone-clusters/cluster-settings-step.png "Cluster Settings")

- Provide Credentials in either of the below mentioned ways:
    - Select a pre-created preset which stores the provider specific credentials.

    - Manually enter the credentials `Access Key ID`, `Secret Access Key`.

![AWS credentials](@/images/tutorials/kubeone-clusters/aws-credentials-step.png "AWS credentials")

- Review provided settings and click `Import KubeOne Cluster`.
