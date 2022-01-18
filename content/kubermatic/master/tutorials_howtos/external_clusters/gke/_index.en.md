+++
title = "Adding an External GKE Kubernetes Cluster"
date = 2022-01-10T14:07:15+02:00
weight = 7

+++

## Add GKE cluster

You can add an existing Kubernetes cluster and then manage it using KKP. From the Clusters page, click `External Clusters`.
Click `Add External Cluster` button and Pick `Google Kubernetes Engine` provider.

![Add External Cluster](/img/kubermatic/master/tutorials/external_clusters/add_external_cluster.png "Add External Cluster")

Select preset with valid credentials or enter GKE Service Account to connect to the provider.

![GKE credentials](/img/kubermatic/master/tutorials/external_clusters/gke_credentials.png "GKE credentials")

You should see the list of all available clusters. Select the one and click the `Import Cluster` button. Once imported cluster
is unique for the project. The same cluster can be added for the other projects.

![Select GKE cluster](/img/kubermatic/master/tutorials/external_clusters/select_gke_cluster.png "Select GKE cluster")

## Cluster details page

Your cluster is added. The KKP controller retrieves the cluster kubeconfig to display all necessary information. When
everything is fine the cluster is in the `Running` state. Otherwise, the cluster can be in the `Error` state. Move the mouse cursor over the
state indicator to get more details. You can also expand `Events` to get information from the controller.

![GKE cluster](/img/kubermatic/master/tutorials/external_clusters/gke_details.png "GKE cluster")

You can also click on `Machine Deployments` to get the details:

![GKE Machine Deployment](/img/kubermatic/master/tutorials/external_clusters/gke_machine_deployments.png "GKE Machine Deployment")

## Update cluster

### Upgrade Version

When an upgrade for the cluster is available, a little dropdown arrow will be shown besides the Master Version on the cluster’s page.
To start the upgrade, just click on the link and choose the desired version:

![Upgrade GKE](/img/kubermatic/master/tutorials/external_clusters/upgrade_gke.png "Upgrade GKE")

### Scale the Machine Deployment

Navigate to the cluster overview, scroll down to Machine Deployments and click on the edit icon next to the machine deployment you want to edit.
In the popup dialog you can now in- or decrease the number of worker nodes which are managed by this machine deployment.

![Update GKE Machine Deployment](/img/kubermatic/master/tutorials/external_clusters/update_gke_md.png "Update GKE Machine Deployment")