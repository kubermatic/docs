+++
title = "Google Kubernetes Engine"
date = 2022-01-10T14:07:15+02:00
description = "Detailed tutorial to help you add an existing Kubernetes cluster in GKE and then manage it using KKP"
weight = 7

+++

## Add GKE Cluster

You can add an existing Kubernetes cluster and then manage it using KKP.

- Navigate to `External Clusters` page.

![Add External Cluster](@/images/tutorials/external-clusters/external-cluster-page.png "Add External Cluster")

- Click the `Import External Cluster` button and Pick `Google Kubernetes Engine` provider.

![Add External Cluster](@/images/tutorials/external-clusters/connect.png "Select Provider")

- Select preset with valid credentials or enter GKE Service Account to connect to the provider.

![GKE credentials](@/images/tutorials/external-clusters/gke-credentials.png "GKE credentials")

You should see the list of all available clusters. Select the one and click the `Import Cluster` button.
Clusters can be imported only once in a single project. The same cluster can be imported in multiple projects.

![Select GKE cluster](@/images/tutorials/external-clusters/select-gke-cluster.png "Select GKE cluster")

- Provide Credentials in either of the below mentioned ways:
    - Select a pre-created preset which stores the provider specific credentials.

      Create a preset on your KKP cluster with `spec.gke.serviceAccount` containing the base64 encoded service account.

    - Manually enter the credentials ServiceAccount

- After user provides all required credentials, credentials will be validated.

{{% notice info %}}
Validation performed will only check if the credentials have `Read` access.
{{% /notice %}}

## Create GKE Preset
Admin can create a preset on a KKP cluster using KKP `Admin Panel`.
This Preset can then be used to Create/Import an GKE cluster.

- Click on `Admin Panel` from the menu.

![Select Admin Panel](@/images/tutorials/external-clusters/select-adminpanel.png "Select Admin Panel")

- Navigate to `Provider Presets` Page and Click on `+ Create Preset` button.

![Provider Preset Page](@/images/ui/preset-management.png?height=300px&classes=shadow,border "Provider Preset Page")

- Enter Preset Name.

![Provide Preset Name](@/images/tutorials/external-clusters/create-gkepreset.png "Provide Preset Name")

- Choose `Google Kubernetes Engine` from the list of providers.

![Choose EKS Preset](@/images/tutorials/external-clusters/choose-akspreset.png "Choose GKE Preset")

-  Enter GKE credentials and Click on `Create` button.

![Enter Credentials](@/images/tutorials/external-clusters/enter-gke-credentials-preset.png "Enter Credentials")

- You can now use created GKE Preset to Create or Import GKE Cluster.

![Select GKE Preset](@/images/tutorials/external-clusters/existing-gke-preset.png "Select GKE Preset")

## Cluster Details Page

After the cluster is added, the KKP controller retrieves the cluster kubeconfig to display all necessary information. A healthy cluster has `Running` state. Otherwise, the cluster can be in the `Error` state. Move the mouse cursor over the
state indicator to get more details. You can also expand `Events` to get information from the controller.

![GKE cluster](@/images/tutorials/external-clusters/gke-details.png "GKE cluster")

You can also expand `Events` to get information from the controller.

![GKE Events](@/images/tutorials/external-clusters/gke-cluster-events.png "GKE Events")

You can also click on `Machine Deployments` to get the details:

![GKE Machine Deployment](@/images/tutorials/external-clusters/gke-machine-deployments.png "GKE Machine Deployment")

## Update Cluster

### Upgrade Version

When an upgrade for the cluster is available, a little dropdown arrow will be shown beside the Master Version on the cluster’s page.
To start the upgrade, just click on the link and choose the desired version:

![Upgrade GKE](@/images/tutorials/external-clusters/upgrade-gke.png "Upgrade GKE")

If the version upgrade is valid, the cluster state will change to `Reconciling`.

### Edit the Machine Deployment

{{% notice info %}}
Only one operation can be performed at one point of time. If the replica count is updated then Kubernetes version upgrade will be disabled and vice versa.
{{% /notice %}}

- Navigate to the cluster overview, scroll down to machine deployments
- Click on the edit icon next to the machine deployment you want to edit.

![Edit GKE Machine Deployment](@/images/tutorials/external-clusters/edit-gke-md.png "Edit GKE Machine Deployment")

- Upgrade Kubernetes Version. Select the Kubernetes Version from the dropdown to upgrade the md.

![Update GKE Machine Deployment](@/images/tutorials/external-clusters/upgrade-gke-md.png "Update GKE Machine Deployment")

- Scale the replicas: In the popup dialog, you can increase or decrease the number of worker nodes that are managed by this machine deployment. Either specify the number of desired nodes or use the + or - to increase or decrease node count.

![Scale GKE Machine Deployment](@/images/tutorials/external-clusters/scale-gke-md.png "Scale GKE Machine Deployment")

## Delete Cluster

{{% notice info %}}
Delete operation is not allowed for imported clusters
{{% /notice %}}

Delete cluster operation allows to delete the cluster from the Provider. Click on the `Delete` button.

![Delete Cluster](@/images/tutorials/external-clusters/gke-delete-button.png
 "Delete Cluster")

## Delete the Node Pool

Navigate to the cluster overview, scroll down to machine deployments and click on the delete icon next to the machine deployment you want to delete.

![Update GKE Machine Deployment](@/images/tutorials/external-clusters/delete-md.png "Delete GKE Machine Deployment")

### Authenticating with GKE

The KKP platform allows getting kubeconfig file for the GKE cluster.

![Get GKE kubeconfig](@/images/tutorials/external-clusters/gke-kubeconfig.png "Get cluster kubeconfig")


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
