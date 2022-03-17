+++
title = "Open Policy Agent (OPA) via UI"
date = 2021-09-08T12:07:15+02:00
weight = 40

+++

## Open Policy Agent (OPA)

[Open Policy Agent](https://www.openpolicyagent.org/) (OPA) is an open-source, general-purpose policy engine that unifies policy enforcement across the stack. We are integrating it with using [Gatekeeper](https://github.com/open-policy-agent/gatekeeper), which is an OPA's Kubernetes-native policy engine. More info about OPA and Gatekeeper can be read from their docs and tutorials.


### Admin Panel for OPA Options

As an admin, you will find a few options in the `Admin Panel`. You can access this panel by clicking on the account icon on the top right and select `Admin Panel`.

![Access Admin Panel](/img/kubermatic/v2.20/ui/admin_panel.png?height=300px&classes=shadow,border "Accessing the Admin Panel")

In here you can see the `OPA Options` with two checkboxes attached.
- `Enable by Default`: Set the `OPA Integration` checkbox on cluster creation to enabled by default.
- `Enforce`: Enable to make users unable to edit the checkbox.

![Admin OPA Options](/img/kubermatic/v2.20/ui/opa_admin_options.png?classes=shadow,border "Admin OPA Options")

The Admin Panel also offers you the possibility to specify Constraint Templates.

![Constraint Templates](/img/kubermatic/v2.20/ui/opa_admin_ct_view.png?classes=shadow,border "Constraint Templates")

Here you navigate to the OPA menu and then to Default Constraints.

![Default Constraints](/img/kubermatic/v2.20/ui/default-constraint-admin.png?height=300px&classes=shadow,border "Default Constraints")

### Cluster Details View

The cluster details view is extended by some more information if OPA is enabled.
- `OPA Integration` in the top area is indicating if OPA is enabled or not.
- `OPA Gatekeeper Controller` and `OPA Gatekeeper Audit` provide information about the status of those controllers.
- `OPA Constraints` and `OPA Gatekeeper Config` are added to the tab menu on the bottom. More details are in the following sections.

![Cluster Details View](/img/kubermatic/v2.20/ui/opa_cluster_view.png?height=500px&classes=shadow,border "Cluster Details View")


### Activating OPA

To create a new cluster with OPA enabled you only have to enable the `OPA Integration` checkbox during the cluster creation process. It is placed in Step 2 `Cluster` and can be enabled by default as mentioned in the [Admin Panel for OPA Options]({{< ref "#admin-panel-for-opa-options" >}}) section. 
If you don't know how to create a cluster using the Kubermatic Kubernetes Platform follow our [Project and cluster management]({{< ref "../../project_and_cluster_management" >}}) tutorial.

![OPA Integration during Cluster Creation](/img/kubermatic/v2.20/ui/opa_enable.png?height=400px&classes=shadow,border "OPA Integration during Cluster Creation")

It is also possible to enable - or disable - OPA for an existing cluster. In the cluster detail view simply click on the vertical ellipsis menu and select `Edit Cluster`.

![Cluster Details Ellipsis Menu](/img/kubermatic/v2.20/ui/edit_cluster_menu.png?height=300px&classes=shadow,border "Cluster Details Ellipsis Menu")

In the appearing dialog, you can now enable/disable the OPA Integration.

![Edit Cluster Dialog](/img/kubermatic/v2.20/ui/edit_cluster_dialog.png?height=400px&classes=shadow,border "Edit Cluster Dialog")

## Operating OPA

### Constraint Templates

Constraint Templates allow you to declare new Constraints. They are intended to work as a schema for Constraint parameters and enforce their behavior. The Constraint Templates view under OPA menu in Admin Panel allows adding, editing and deleting Constraint Templates.

The Admin Panel also offers you the possibility to specify Constraint Templates.

![Constraint Templates](/img/kubermatic/v2.20/ui/opa_admin_ct_view.png?classes=shadow,border "Constraint Templates")

Constraint Templates can be added after clicking on the `+ Add Constraint Template` icon in the top right corner of the view. A new dialog will appear, where you can specify the spec of the template:

Spec is the only field that needs to be filled with a yaml.

![Add Constraint Template](/img/kubermatic/v2.20/ui/opa_admin_add_ct.png?classes=shadow,border&height=350px "Constraint Template Add Dialog")

The following example requires all labels that are described by the constraint to be present:
```yaml
crd:
  spec:
    names:
      kind: K8sRequiredLabels
    validation:
      # Schema for the `parameters` field
      openAPIV3Schema:
        properties:
          labels:
            type: array
            items: string
targets:
  - target: admission.k8s.gatekeeper.sh
    rego: |
      package k8srequiredlabels

      violation[{"msg": msg, "details": {"missing_labels": missing}}] {
        provided := {label | input.review.object.metadata.labels[label]}
        required := {label | label := input.parameters.labels[_]}
        missing := required - provided
        count(missing) > 0
        msg := sprintf("you must provide labels: %v", [missing])
      }
```

Just click on `Add Constraint Template` to create the constraint template.

Constraint Templates can be edited after clicking on the pencil icon that appears when hovering over one of the rows. The form is identical to the one from creation. In this table you can also delete it if needed.

![Edit Constraint Template](/img/kubermatic/v2.20/ui/edit_constraint_template.png?height=300px&classes=shadow,border "Cluster Details View")
### Constraints

Constraints are the filler for rules that are defined by the constraint templates. Constraints provide the parameters which are used in the Constraint Template rule.

#### Create Constraint in the Cluster

![Cluster Details View](/img/kubermatic/v2.20/ui/opa_cluster_view.png?height=500px&classes=shadow,border "Cluster Details View")

![Constraints](/img/kubermatic/v2.20/ui/opa_constraints_cluster.png?classes=shadow,border "Constraints")

To add a new constraint click on the `+ Add Constraint` icon on the right. A new dialog will appear, where you can specify the name, the constraint template, and the spec:

![Add Constraints Dialog](/img/kubermatic/v2.20/ui/opa_add_constraint.png?height=350px&classes=shadow,border "Add Constraints Dialog")

The following example will make sure that the gatekeeper label is defined on all namespaces, if you are using the `K8sRequiredLabels` constraint template from above:
```yaml
match:
  kinds:
    - apiGroups: [""]
      kinds: ["Namespace"]
parameters:
  labels: ["gatekeeper"]
```

Just click on `+ Add Constraint` to create the constraint. In this table, you can also edit or delete it again if needed after clicking on the icons that appears when hovering over one of the rows.

![Constraints](/img/kubermatic/v2.20/ui/cluster_opa_constraints_overview.png?classes=shadow,border "Constraints")

It also shows you possible violations. Click on the row to expand the view and to see all violations in detail.

![Violations](/img/kubermatic/v2.20/ui/opa_created_constraints_violations.png?classes=shadow,border "Violations")

### Default Constraints

Default Constraints allow admins to conveniently apply policies to all OPA enabled clusters
This would allow admins an easier way to make sure all user clusters are following some policies (for example security), instead of the current way in which Constraints need to be created for each cluster separately.
Kubermatic operator/admin creates a Constraint in the admin panel, it gets propagated to seed clusters and user clusters with OPA-integration

On Cluster Level, Default Constraints are differentiated from Constraints with `default` label.

#### Create Default Constraint

In the Admin view navigate to the OPA menu and then to Default Constraints.

![Default Constraints](/img/kubermatic/v2.20/ui/default-constraint-admin.png?height=300px&classes=shadow,border "Default Constraints")
To add a new default constraint click on the `+Add Default Constraint` icon on the right. A new dialog will appear, where you can specify the name, the constraint template and the spec:

![Create Default Constraint](/img/kubermatic/v2.20/ui/create-default-constraint-dialog.png?height=300px&classes=shadow,border "Create Default Constraint")

```yaml
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

![Created Default Constraint](/img/kubermatic/v2.20/ui/default-constraint-admin-view.png?height=200px&classes=shadow,border "Created Default Constraint")

The Default Constraint created will also show up in the applied cluster view with `Admin Constraint` label
![Created Default Constraint on the Cluster](/img/kubermatic/v2.20/ui/default_constraint_cluster_view.png?height=200px&classes=shadow,border "Created Default Constraint on the Cluster")

#### Edit Default Constraint

Editing Default Constraint will sync the changes to all the respective constraints on the user clusters.

admin_default_constraint.png

To edit the constraint click on edit button on the right that appears when hovering over one of the rows.
![Edit Default Constraint](/img/kubermatic/v2.20/ui/edit-delete-default-constraint.png?height=200px&classes=shadow,border "Edit Default Constraint")

In the appearing dialog you can now edit the Default Constraint.
![Edit Constraint Dialog](/img/kubermatic/v2.20/ui/edit-default-constraint-dialog.png?height=350px&classes=shadow,border "Edit Constraint Dialog")

#### Filtering Clusters on Default Constraints

{{% notice info %}}
This is an EE feature.
{{% /notice %}}

Filter Clusters feature enables Admin to filter User Clusters where Default Constraint is applied using with  Cloud Provider and Label Selector filters.

In case of no filtering applied Default Constraints are synced to all User Clusters which can be verified by the `Applies To` field as shown here:
![Default Constraint Applies To](/img/kubermatic/v2.20/ui/default-constraint-admin-view.png?height=200px&classes=shadow,border "Default Constraint Applies To")

for example, Admin wants to apply a policy only on clusters with the provider as `aws` and label selector as `filtered:true`
To enable this add the following selectors in the constraint spec for the above use case.

```yaml
selector:
  providers:
    - aws
  labelSelector:
    matchLabels:
      filtered: 'true'
```

![Default Constraint Filters](/img/kubermatic/v2.20/ui/default-constraint-applied-to.png?height=200px&classes=shadow,border "Default Constraint Filters")

Constraints then can only be seen in the clusters which satisfy the filters.
for example, for the above use case Default Constraints will be applied to Cluster `blissful-stallman` with Provider `aws` and filter `filtered: 'true'` and not on the Cluster `zen-knuth` with Provider `gcp`

![Clusters](/img/kubermatic/v2.20/ui/filtered-clusters.png?height=200px&classes=shadow,border "Clusters")

![Filtered Cluster with Default Constraint](/img/kubermatic/v2.20/ui/cluster-aws-filter.png?height=400px&classes=shadow,border "Filtered Cluster with Default Constraint")

### Disabling Constraint

{{% notice info %}}
This is an EE feature.
{{% /notice %}}

Disabling Constraint feature allows users to disable constraints temporarily for use cases like testing.

Constraint can be Disabled/Turned off by setting `disabled` flag to true in the constraint spec.
As a result Constraint Policy will not be applied to clusters.

![Disabled Constraint Spec](/img/kubermatic/v2.20/ui/disabled_constraint_spec.png?classes=shadow,border "Disabled Constraint Spec")

Disabled Kubermatic Constraint on a Cluster is blurred to differentiate between Enabled and Disabled Constraints

![Disabled Constraint](/img/kubermatic/v2.20/ui/cluster_disabled_constraint.png?classes=shadow,border "Disabled Constraint")

#### Disable Default Constraints

In Admin View to disable Default Constraints, click on the green button under `On/Off`
![Disable Default Constraint](/img/kubermatic/v2.20/ui/default-constraint-on.png?height=200px&classes=shadow,border "Disable Default Constraint")

Kubermatic adds a label `disabled: true` to the Disabled Constraint
![Disabled Default Constraint](/img/kubermatic/v2.20/ui/default-constraint-default-true.png?height=400px&classes=shadow,border "Disabled Default Constraint")


![Disabled Default Constraint](/img/kubermatic/v2.20/ui/disabled-default-constraint-cluster-view.png?height=200px&classes=shadow,border "Disabled Default Constraint")


Enable the constraint by clicking the same button
![Enable Default Constraint](/img/kubermatic/v2.20/ui/disabled-default-constraint.png?height=200px&classes=shadow,border "Enable Default Constraint")

### Delete Default Constraint

Deleting Default Constraint causes all related Constraints on the user clusters to be deleted as well.

To delete the constraint click on delete button on the right that appears when hovering over one of the rows.
![Delete Default Constraint](/img/kubermatic/v2.20/ui/edit-delete-default-constraint.png?height=200px&classes=shadow,border "Delete Default Constraint")

### AllowedRegistry

[AllowedRegistry]({{< ref "../../OPA_integration/#allowedregistry" >}}) is a part of the OPA Integration Admin Panel.

It allows users to manage the built-in KKP Constraint AllowedRegistry through which you can easily create policies on what image registries can be
used for Pods on all OPA-enabled user clusters. 

![Allowed Registries View](/img/kubermatic/v2.20/ui/allowed_registries.png?classes=shadow,border "Allowed Registry View")

To create an AllowedRegistry just click on the `+ Add Allowed Registries` button and set a K8s compliant name and a registry prefix.
OPA matches these prefixes with the Pods container `image` field and if it matches with at least one, it allows the Pod to be created/updated.

![Allowed Registries Create](/img/kubermatic/v2.20/ui/add_allowed_registry.png?classes=shadow,border "Add Allowed Registry")

The Allowed Registries can be managed through the same form by using the edit button, or deleted by the trash button.

A controller is collecting the Allowed Registries prefixes and creates a corresponding Constraint Template and Default Constraint.

![Allowed Registries Default Constraint](/img/kubermatic/v2.20/ui/allowed_registry_default_constraint.png?classes=shadow,border "Allowed Registry Default Constraint")

We manage this Default Constraint automatically (Parameters list, Pod match, Enabled/Disabled) but users can still change other
values, most importantly the [Filtering]({{< ref "#filtering-clusters-on-default-constraints" >}}).

### Gatekeeper Config

In this area, you have the possibility to define a Gatekeeper Config. It is not required but might be needed for some constraints that need more access.
Initially, you will only see the `Add Gatekeeper Config` button.

![Gatekeeper Config](/img/kubermatic/v2.20/ui/opa_config.png?classes=shadow,border "Gatekeeper Config")

Click on this button to create a config. A new dialog will appear, where you can insert your spec:

![Add Gatekeeper Config](/img/kubermatic/v2.20/ui/opa_add_config.png?height=350px&classes=shadow,border "Add Gatekeeper Config")

The following example will dynamically update what objects are synced:
```
sync:
  syncOnly:
    - group: ""
      version: "v1"
      kind: "Namespace"
    - group: ""
      version: "v1"
      kind: "Pod"
```

Just click on `Add` to create the config. The view then displays the config parts you specified. You can also edit and delete it later.
![Gatekeeper Config](/img/kubermatic/v2.20/ui/opa_config_overview.png?height=300px&classes=shadow,border "Gatekeeper Config")
