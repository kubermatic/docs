+++
title = "Cluster Settings"
date = 2020-02-10T11:07:15+02:00
weight = 20
+++


Interface section in the Admin Panel allows user to control various cluster-related settings. They
can influence cluster creation, management and cleanup after deletion.

## Defaults Cluster Settings
![Defaults cluster settings](@/images/ui/defaults-cluster-settings.png?classes=shadow,border)

- ### [Cleanup on Cluster Deletion](#cleanup-on-cluster-deletion)

- ### [Machine Deployment](#machine-deployment)

### Cleanup on Cluster Deletion

![Cleanup on cluster deletion](@/images/ui/cleanup-on-cluster-deletion.png?classes=shadow,border)

This section controls cluster cleanup settings available inside cluster delete dialog.

![Cluster delete dialog](@/images/ui/delete-cluster-dialog.png?classes=shadow,border)

### Enable by Default

Controls the checkboxes in the dialog. When selected, cleanup checkboxes will be checked by default.

### Enforce

Controls the status of checkboxes in the dialog. When selected, cleanup checkboxes will be disabled and user will not
be able to check/uncheck them.

## Machine Deployment

![Machine deployment](@/images/ui/machine-deployment.png?classes=shadow,border)

This section controls the default number of initial Machine Deployment replicas. It can be seen and changed
in the cluster creation wizard on the Initial Nodes step and also on the add/edit machine deployment dialog on
the cluster details.

#### Cluster Creation Wizard - Initial Nodes Step

![Cluster creation wizard initial nodes step](@/images/ui/wizard-initial-nodes-step.png?classes=shadow,border)


## Limits

![Interface limits](@/images/ui/interface-limits.png?classes=shadow,border)
- ### [User Projects Limit](#user-projects-limit)

- ### [Resource Filter](#resource-filter)


## User Projects Limit

![User projects limit](@/images/ui/user-projects-limit.png?classes=shadow,border)

This setting controls how project creation will be handled by the Kubermatic. The administrator can control
if regular users should be able to create projects. There is also an option to control maximum number of projects
that regular users will be able to create. The `User Projects Limit` is controlled on a per-user basis and affects
only non-admin users.

## Resource Filter

![Resource filter](@/images/ui/resource-filter.png?classes=shadow,border)

Resource Filter settings provide an easy way to control the size of machines used to create user clusters. The administrator
can also control if selection of instances with GPU should be possible. Every node size that does not match the
specified criteria will be filtered out and not displayed to the user.
