+++
title = "Cluster Settings"
date = 2025-07-24T09:45:00+05:00
weight = 20
+++

Interface section in the Admin Panel allows user to control various cluster-related settings. They
can influence cluster creation, management and cleanup after deletion.

## Defaults Cluster Settings

![Defaults cluster settings](images/defaults-cluster-settings.png?classes=shadow,border)

- [Cleanup on Cluster Deletion](#cleanup-on-cluster-deletion)
- [Machine Deployment](#machine-deployment)
- [Static Labels](#static-labels)
- [Annotation Settings](#annotation-settings)

### Cleanup on Cluster Deletion

![Cleanup on cluster deletion](images/cleanup-on-cluster-deletion.png?classes=shadow,border)

This section controls cluster cleanup settings available inside cluster delete dialog.

![Cluster delete dialog](images/delete-cluster-dialog.png?classes=shadow,border)

- **Enable by Default**: Controls the checkboxes in the dialog. When selected, cleanup checkboxes will be checked by default.

- **Enforce Default**: Controls the status of checkboxes in the dialog. When selected, cleanup checkboxes will be disabled and user will not be able to check/uncheck them.

### Machine Deployment

![Machine deployment](images/machine-deployment.png?classes=shadow,border)

This section controls the default number of initial Machine Deployment replicas. It can be seen and changed
in the cluster creation wizard on the Initial Nodes step and also on the add/edit machine deployment dialog on
the cluster details.

#### Cluster Creation Wizard - Initial Nodes Step

![Cluster creation wizard initial nodes step](images/wizard-initial-nodes-step.png?classes=shadow,border)

### Static Labels

![Static labels](images/static-labels.png?classes=shadow,border)

Static labels are a list of labels that the admin can add. Users can select from these labels when creating a cluster during the cluster settings step.
The admin can set these labels as either default or protected:

- **Default label**: This label is automatically added, but the user can delete it.
- **Protected label**: This label is automatically added and cannot be deleted by the user.

### Annotation settings

![Annotation settings](images/annotation-settings.png?classes=shadow,border)

Annotation settings provide an easy way to control annotations that are shown and managed using KKP dashboard. KKP admins can configure the following:

- **Hidden annotations**: These annotations will not be shown to the user.
- **Protected annotations**: These annotations will be shown to the user, but they will not be able to modify them.

## Limits

![Interface limits](images/interface-limits.png?classes=shadow,border)

Limits section in the Admin Panel allows user to control various limits that can be applied to regular users.

- [Project Restrictions](#project-restrictions)
- [User Projects Limit](#user-projects-limit)
- [Resource Filter](#resource-filter)

### Project Restrictions

![Project restrictions](images/project-restrictions.png?classes=shadow,border)

Project Restrictions settings allow the administrator to control if regular users should be allowed to create, delete or edit projects.

### User Projects Limit

![User projects limit](images/user-projects-limit.png?classes=shadow,border)

User Projects Limit is an option to control maximum number of projects that regular users will be able to create. This limit is controlled on a per-user basis and affects only non-admin users.

### Resource Filter

![Resource filter](images/resource-filter.png?classes=shadow,border)

Resource Filter settings provide an easy way to control the size of machines used to create user clusters. The administrator
can also control if selection of instances with GPU should be possible. Every node size that does not match the
specified criteria will be filtered out and not displayed to the user.
