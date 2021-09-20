+++
title = "Cluster Settings"
date = 2020-02-10T11:07:15+02:00
weight = 20
+++

Cluster Settings section in the Admin Panel allows user to control various cluster-related settings. They
can influence cluster creation, management and cleanup after deletion.

![](/img/kubermatic/v2.18/ui/cluster_settings.png?height=300px&classes=shadow,border)

- ### [Cleanup on Cluster Deletion](#cleanup-on-cluster-deletion)
- ### [Machine Deployment](#machine-deployment)
- ### [Enable Kubernetes Dashboard](#enable-kubernetes-dashboard)
- ### [Enable OIDC Kubeconfig](#enable-oidc-kubeconfig)
- ### [Enable External Clusters](#enable-external-clusters)
- ### [User Projects Limit](#user-projects-limit)
- ### [Resource Quota](#resource-quota)

## Cleanup on Cluster Deletion

![](/img/kubermatic/v2.18/ui/cleanup_on_cluster_deletion.png?classes=shadow,border)

This section controls cluster cleanup settings available inside cluster delete dialog.

![](/img/kubermatic/v2.18/ui/delete_cluster_dialog.png?height=200px&classes=shadow,border)

### Enable by Default

Controls the checkboxes in the dialog. When selected, cleanup checkboxes will be checked by default.

### Enforce

Controls the status of checkboxes in the dialog. When selected, cleanup checkboxes will be disabled and user will not
be able to check/uncheck them.

## Machine Deployment

![](/img/kubermatic/v2.18/ui/machine_deployment.png?classes=shadow,border)

This section controls the default number of initial Machine Deployment replicas. It can be seen and changed
in the cluster creation wizard on the Initial Nodes step and also on the add/edit machine deployment dialog on
the cluster details.

#### Cluster Creation Wizard - Initial Nodes Step
![](/img/kubermatic/v2.18/ui/wizard_initial_nodes_step.png?height=300px&classes=shadow,border)

## Enable Kubernetes Dashboard

![](/img/kubermatic/v2.18/ui/enable_kubernetes_dashboard.png?classes=shadow,border)

This section controls the Kubernetes Dashboard support for created user clusters. When enabled an `Open Dashboard` 
button will appear on the cluster details, and the API will allow Kubernetes Dashboard proxy access through the API.

#### Cluster Details
![](/img/kubermatic/v2.18/ui/cluster_details.png?height=300px&classes=shadow,border)

## Enable OIDC Kubeconfig

![](/img/kubermatic/v2.18/ui/enable_oidc_kubeconfig.png?classes=shadow,border)

This setting controls whether OIDC provider should be used as a proxy for `kubeconfig` download. Enabling this option
will also disable the possibility of using `Share` feature on the cluster details.

![](/img/kubermatic/v2.18/ui/cluster_details_top.png?classes=shadow,border)

## Enable External Clusters

![](/img/kubermatic/v2.18/ui/enable_external_clusters.png?classes=shadow,border)

External clusters feature allows you to connect third-party Kubernetes clusters in a read-only mode to your Kubermatic
project. Those clusters will not be managed by the Kubermatic Kubernetes Platform therefore the available information
will be limited. Clusters on the list will have an `External` badge to indicate their origin.

#### External Cluster on the Cluster List
![](/img/kubermatic/v2.18/ui/external_cluster.png?classes=shadow,border)

#### External Cluster Details
![](/img/kubermatic/v2.18/ui/external_cluster_details.png?classes=shadow,border)

## User Projects Limit

![](/img/kubermatic/v2.18/ui/user_projects_limit.png?classes=shadow,border)

This setting controls how project creation will be handled by the Kubermatic. The administrator can control
if regular users should be able to create projects. There is also an option to control maximum number of projects
that regular users will be able to create. The `User Projects Limit` is controlled on a per-user basis and affects
only non-admin users.

## Resource Quota

![](/img/kubermatic/v2.18/ui/resource_quota.png?classes=shadow,border)

Resource Quota settings provide an easy way to control the size of machines used to create user clusters. The administrator
can also control if selection of instances with GPU should be possible. Every node size that does not match the
specified criteria will be filtered out and not displayed to the user.
