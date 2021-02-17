+++
title = "Cluster Settings"
date = 2020-02-10T11:07:15+02:00
weight = 20
+++

Cluster Settings section in the Admin Panel allows user to control various cluster-related settings. They
can influence cluster creation, management and cleanup after deletion.

![](/img/kubermatic/master/ui/cluster_settings.png?height=300px&classes=shadow)

- ### [Cleanup on Cluster Deletion](#cleanup-on-cluster-deletion)
- ### [Displayed Distributions](#displayed-distributions) {{< badge type="warning" text="Deprecated" >}}
- ### [Machine Deployment](#machine-deployment)
- ### [Enable Kubernetes Dashboard](#enable-kubernetes-dashboard)
- ### [Enable OIDC Kubeconfig](#enable-oidc-kubeconfig)
- ### [Enable External Clusters](#enable-external-clusters)
- ### [User Projects Limit](#user-projects-limit)
- ### [Resource Quota](#resource-quota)

## Cleanup on Cluster Deletion

![](/img/kubermatic/master/ui/cleanup_on_cluster_deletion.png?classes=shadow,floatleft)

This section controls cluster cleanup settings available inside cluster delete dialog.

![](/img/kubermatic/master/ui/delete_cluster_dialog.png?height=200px&classes=shadow,floatleft)

### Enable by Default

Controls the checkboxes in the dialog. When selected, cleanup checkboxes will be checked by default.

### Enforce

Controls the status of checkboxes in the dialog. When selected, cleanup checkboxes will be disabled and user will not
be able to check/uncheck them.

## Displayed Distributions {{< badge type="warning" text="Deprecated" >}}

{{% notice warning %}}
OpenShift support is scheduled to be removed in one of the upcoming releases.
{{% /notice %}}

This section controls which distributions will be enabled in the wizard. By selecting shown distributions
administrator can control what kind of clusters will be possible to get created by the Kubermatic users.

#### Admin Panel
![](/img/kubermatic/master/ui/displayed_distributions.png?classes=shadow,floatleft)


#### Cluster Creation Wizard - Cluster Step
![](/img/kubermatic/master/ui/wizard_cluster_step.png?height=300px&classes=shadow,floatleft)

## Machine Deployment

This section controls the default number of initial Machine Deployment replicas. It can be seen and changed
in the cluster creation wizard on the Initial Nodes step and also on the add/edit machine deployment dialog on
the cluster details.

#### Admin Panel
![](/img/kubermatic/master/ui/machine_deployment.png?classes=shadow,floatleft)

#### Cluster Creation Wizard - Initial Nodes Step
![](/img/kubermatic/master/ui/wizard_initial_nodes_step.png?height=300px&classes=shadow,floatleft)

## Enable Kubernetes Dashboard

This section controls the Kubernetes Dashboard support for created user clusters. When enabled an `Open Dashboard` 
button will appear on the cluster details, and the API will allow Kubernetes Dashboard proxy access through the API.

#### Admin Panel
![](/img/kubermatic/master/ui/enable_kubernetes_dashboard.png?classes=shadow,floatleft)

#### Cluster Details
![](/img/kubermatic/master/ui/cluster_details.png?height=300px&classes=shadow,floatleft)

## Enable OIDC Kubeconfig

#### Admin Panel
![](/img/kubermatic/master/ui/enable_oidc_kubeconfig.png?classes=shadow,floatleft)

## Enable External Clusters

#### Admin Panel
![](/img/kubermatic/master/ui/enable_external_clusters.png?classes=shadow,floatleft)

## User Projects Limit

#### Admin Panel
![](/img/kubermatic/master/ui/user_projects_limit.png?classes=shadow,floatleft)

## Resource Quota

#### Admin Panel
![](/img/kubermatic/master/ui/resource_quota.png?classes=shadow,floatleft)
