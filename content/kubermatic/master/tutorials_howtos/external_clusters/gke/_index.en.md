+++
title = "Adding an External GKE Kubernetes Cluster"
date = 2022-01-10T14:07:15+02:00
weight = 7

+++

## Add GKE Cluster

You can add an existing Kubernetes cluster and then manage it using KKP. From the Clusters page, click `External Clusters`.
Click the `Add External Cluster` button and Pick `Google Kubernetes Engine` provider.

![Add External Cluster](/img/kubermatic/master/tutorials/external_clusters/add_external_cluster.png "Add External Cluster")

Select preset with valid credentials or enter GKE Service Account to connect to the provider.

![GKE credentials](/img/kubermatic/master/tutorials/external_clusters/gke_credentials.png "GKE credentials")

You should see the list of all available clusters. Select the one and click the `Import Cluster` button.
Clusters can be imported only once in a single project. The same cluster can be imported for the other projects.

![Select GKE cluster](/img/kubermatic/master/tutorials/external_clusters/select_gke_cluster.png "Select GKE cluster")

## Cluster Details Page

After the cluster is added, the KKP controller retrieves the cluster kubeconfig to display all necessary information. A healthy cluster has `Running` state. Otherwise, the cluster can be in the `Error` state. Move the mouse cursor over the
state indicator to get more details. You can also expand `Events` to get information from the controller.

![GKE cluster](/img/kubermatic/master/tutorials/external_clusters/gke_details.png "GKE cluster")

You can also click on `Machine Deployments` to get the details:

![GKE Machine Deployment](/img/kubermatic/master/tutorials/external_clusters/gke_machine_deployments.png "GKE Machine Deployment")

## Update Cluster

### Upgrade Version

When an upgrade for the cluster is available, a little dropdown arrow will be shown beside the Master Version on the cluster’s page.
To start the upgrade, just click on the link and choose the desired version:

![Upgrade GKE](/img/kubermatic/master/tutorials/external_clusters/upgrade_gke.png "Upgrade GKE")

If the version upgrade is valid, the cluster state will change to `Reconciling`.
### Scale the Machine Deployment

Navigate to the cluster overview, scroll down to machine deployments and click on the edit icon next to the machine deployment you want to edit.
In the popup dialog, you can now increase or decrease the number of worker nodes that are managed by this machine deployment.

![Update GKE Machine Deployment](/img/kubermatic/master/tutorials/external_clusters/update_gke_md.png "Update GKE Machine Deployment")

### Authenticating with GKE

The KKP platform allows getting kubeconfig file for the GKE cluster. 

![Get GKE kubeconfig](/img/kubermatic/master/tutorials/external_clusters/gke_kubeconfig.png "Get cluster kubeconfig")


The end-user must be aware that the kubeconfig expires after some short period of time. To mitigate this disadvantage you
can extend the kubeconfig for the provider information and use exported JSON with the service account for the authentication.


Add `name: gcp` for the users:

```
users:
- name: gke_kubermatic-dev_europe-central2-a_test
  user:
    auth-provider:
      name: gcp
```
Provide authentication credentials to your application code by setting the environment variable GOOGLE_APPLICATION_CREDENTIALS.
This variable applies only to your current shell session. If you want the variable to apply to future shell sessions,
set the variable in your shell startup file, for example in the `~/.bashrc` or `~/.profile` file.

```
export GOOGLE_APPLICATION_CREDENTIALS="KEY_PATH"
```

Replace `KEY_PATH` with the path of the JSON file that contains your service account key.

For example:

```
export GOOGLE_APPLICATION_CREDENTIALS="/home/user/Downloads/service-account-file.json"
```
