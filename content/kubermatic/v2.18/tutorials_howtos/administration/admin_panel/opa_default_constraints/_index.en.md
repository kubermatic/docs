+++
title = "OPA Default Constraint"
date = 2021-09-08T12:07:15+02:00
weight = 20
+++

## Default Constraints

Default Constraints allow admins to conveniently apply policies to all OPA enabled clusters
This would allow admins an easier way to make sure all user clusters are following some policies (for example security), instead of the current way in which Constraints need to be created for each cluster separately.
Kubermatic operator/admin creates a Constraint in the admin panel, it gets propagated to seed clusters and user clusters with OPA-integration

### Create Default Constraint

In the Admin view navigate to the OPA menu and then to Default Constraints.

![Default Constraints](/img/kubermatic/master/ui/default-constraint-admin.png?height=300px&classes=shadow,border "Default Constraints")
To add a new default constraint click on the `+Add Default Constraint` icon on the right. A new dialog will appear, where you can specify the name, the constraint template and the spec:

![Create Default Constraint](/img/kubermatic/master/ui/create-default-constraint-dialog.png?height=300px&classes=shadow,border "Create Default Constraint")

```
constraintType: K8sPSPAllowPrivilegeEscalationContainer
match:
  kinds:
    - kinds:
        - Pod
      apiGroups:
        - ''
  labelSelector: {}
  namespaceSelector: {}
selector:
  labelSelector: {}
```

![Created Default Constraint](/img/kubermatic/master/ui/default-constraint-admin-view.png?height=200px&classes=shadow,border "Created Default Constraint")

The Default Constraint created will also show up in the applied cluster view with `Admin Constraint` label
![Created Default Constraint on the Cluster](/img/kubermatic/master/ui/default_constraint_cluster_view.png?height=200px&classes=shadow,border "Created Default Constraint on the Cluster")

### Edit Default Constraint

Editing Default Constraint will sync the changes to all the respective constraints on the user clusters.

To edit the constraint click on edit button on the right that appears when hovering over one of the rows.
![Edit Default Constraint](/img/kubermatic/master/ui/edit-delete-default-constraint.png?height=200px&classes=shadow,border "Edit Default Constraint")

In the appearing dialog you can now edit the Default Constraint.
![Edit Constraint Dialog](/img/kubermatic/master/ui/edit-default-constraint-dialog.png?height=350px&classes=shadow,border "Edit Constraint Dialog")

### Filtering Clusters on Default Constraints

{{% notice info %}}
This is an EE feature.
{{% /notice %}}

Filter Clusters feature enables Admin to filter User Clusters where Default Constraint is applied using with  Cloud Provider and Label Selector filters.

In case of no filtering applied Default Constraints are synced to all User Clusters which can be verified by the `Applies To` field as shown here:
![Default Constraint Applies To](/img/kubermatic/master/ui/default-constraint-admin-view.png?height=200px&classes=shadow,border "Default Constraint Applies To")

for example, Admin wants to apply a policy only on clusters with the provider as `aws` and label selector as `filtered:true`
To enable this add the following selectors in the constraint spec for the above use case.

```
selector:
  providers:
    - aws
  labelSelector:
    matchLabels:
      filtered: 'true'
```

![Default Constraint Filters](/img/kubermatic/master/ui/default-constraint-applied-to.png?height=200px&classes=shadow,border "Default Constraint Filters")

Constraints then can only be seen in the clusters which satisfy the filters.
for example, for the above use case Default Constraints will be applied to Cluster `blissful-stallman` with Provider `aws` and filter `filtered: 'true'` and not on the Cluster `zen-knuth` with Provider `gcp`

![Clusters](/img/kubermatic/master/ui/filtered-clusters.png?height=200px&classes=shadow,border "Clusters")

![Filtered Cluster with Default Constraint](/img/kubermatic/master/ui/cluster-aws-filter.png?height=400px&classes=shadow,border "Filtered Cluster with Default Constraint")

### Disable Default Constraints

In Admin View to disable Default Constraints, click on the green button under `On/Off`
![Disable Default Constraint](/img/kubermatic/master/ui/default-constraint-on.png?height=200px&classes=shadow,border "Disable Default Constraint")

Kubermatic adds a label `disabled: true` to the Disabled Constraint
![Disabled Default Constraint](/img/kubermatic/master/ui/default-constraint-default-true.png?height=400px&classes=shadow,border "Disabled Default Constraint")

Disabled Constraint in the Applied cluster View
disabled-default-constraint-cluster-view.png
![Disabled Default Constraint](/img/kubermatic/master/ui/disabled-default-constraint-cluster-view.png?height=200px&classes=shadow,border "Disabled Default Constraint")


Enable the constraint by clicking the same button
![Enable Default Constraint](/img/kubermatic/master/ui/disabled-default-constraint.png?height=200px&classes=shadow,border "Enable Default Constraint")

### Delete Default Constraint

Deleting Default Constraint causes all related Constraints on the user clusters to be deleted as well.

To delete the constraint click on delete button on the right that appears when hovering over one of the rows.
![Delete Default Constraint](/img/kubermatic/master/ui/edit-delete-default-constraint.png?height=200px&classes=shadow,border "Delete Default Constraint")