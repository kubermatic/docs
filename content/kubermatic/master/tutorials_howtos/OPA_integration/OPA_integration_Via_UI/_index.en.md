+++
title = "Open Policy Agent (OPA) via UI"
date = 2021-02-10T12:07:15+02:00
weight = 10

+++

## Open Policy Agent (OPA)

[Open Policy Agent](https://www.openpolicyagent.org/) (OPA) is an open-source, general-purpose policy engine that unifies policy enforcement across the stack. We are integrating it with using [Gatekeeper](https://github.com/open-policy-agent/gatekeeper), which is an OPA's Kubernetes-native policy engine. More info about OPA and Gatekeeper can be read from their docs and tutorials.


### Admin Panel for OPA Options

As an admin you will find a few options in the `Admin Panel`. You can access this panel by clicking on the account icon on the top right and select `Admin Panel`.

![Access Admin Panel](/img/kubermatic/master/ui/admin_panel_access.png?height=300px&classes=shadow,border "Accessing the Admin Panel")

In here you can see the `OPA Options` with two checkboxes attached.
- `Enable by Default`: Set `OPA Integration` checkbox on cluster creation to enabled by default. 
- `Enforce`: Enable to make users unable to edit the checkbox.

![Admin OPA Options](/img/kubermatic/master/ui/opa_admin_options.png?classes=shadow,border "Admin OPA Options")

The Admin Panel also offers you the possibility to specify Constraint Templates.

![Constraint Templates](/img/kubermatic/master/ui/opa_admin_ct.png?classes=shadow,border "Constraint Templates")


### Cluster Details View

The cluster details view is extended by some more information if OPA is enabled.
- `OPA Integration` in the top area is indicating if OPA is enabled or not.
- `OPA Gatekeeper Controller` and `OPA Gatekeeper Audit` provide information about the status of those controllers.
- `OPA Constraints` and `OPA Gatekeeper Config` are added to the tab menu on the bottom. More details in the following sections.

![Cluster Details View](/img/kubermatic/master/ui/opa_cluster_details.png?height=350px&classes=shadow,border "Cluster Details View")


### Activating OPA

To create a new cluster with OPA enabled you only have to enable the `OPA Integration` checkbox during the cluster creation process. It is placed in Step 2 `Cluster` and can be enabled by default as mentioned in the [Admin Panel for OPA Options]({{< ref "#admin-panel-for-opa-options" >}}) section. 
If you don't know how to create a cluster using the Kubermatic Kubernetes Platform follow our [Project and cluster management]({{< ref "../../project_and_cluster_management" >}}) tutorial.

![OPA Integration during Cluster Creation](/img/kubermatic/master/ui/opa_wizard.png?height=350px&classes=shadow,border "OPA Integration during Cluster Creation")

It is also possible to enable - or disable - OPA for an existing cluster. In the cluster detail view simply click on the vertical ellipsis menu and select `Edit Cluster`.

![Cluster Details Ellipsis Menu](/img/kubermatic/master/ui/edit_cluster_menu.png?height=300px&classes=shadow,border "Cluster Details Ellipsis Menu")

In the appearing dialog you can now enable/disable the OPA Integration. 

![Edit Cluster Dialog](/img/kubermatic/master/ui/opa_edit_cluster_dialog.png?height=350px&classes=shadow,border "Edit Cluster Dialog")


### Operating OPA

#### Constraint Templates

Constraint Templates allow you to declare new Constraints. They are intended to work as a schema for constraint parameters and enforce their behavior.
To add a new constraint template click on the `+` icon on the right. A new dialog will appear, where you can specify the spec of the template:

![Add Constraint Template](/img/kubermatic/master/ui/opa_admin_add_ct.png?height=350px&classes=shadow,border "Add Constraint Template")

Following example requires all labels that are described by the constraint to be present:
```
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

Just click on `Add` to create the constraint template. In this table you can also edit or delete it again if needed.

![Constraint Templates](/img/kubermatic/master/ui/opa_admin_ct_overview.png?classes=shadow,border "Constraint Templates")


#### Constraints

Constraints are the filler for rules that are defined by the constraint templates. Constraints provide the parameters which are used in the Constraint Template rule. 

![Constraints](/img/kubermatic/master/ui/opa_constraints.png?classes=shadow,border "Constraints")

To add a new constraint template click on the `+` icon on the right. A new dialog will appear, where you can specify the name, the constraint template and the spec:

![Add Constraints Dialog](/img/kubermatic/master/ui/opa_add_constraints.png?height=350px&classes=shadow,border "Add Constraints Dialog")

Following example will make sure that the gatekeeper label is defined on all namespaces, if you are using the `K8sRequiredLabels` constraint template from above:
```
match:
  kinds:
    - apiGroups: [""]
      kinds: ["Namespace"]
parameters:
  rawJSON: '{"labels":["gatekeeper"]}'
```

Just click on `Add` to create the constraint. In this table you can also edit or delete it again if needed.

![Constraints](/img/kubermatic/master/ui/opa_constraints_overview.png?classes=shadow,border "Constraints")

It also shows you possible violations. Click on the row to expand the view and to see all violations in detail.

![Violations](/img/kubermatic/master/ui/opa_constraints_violations.png?classes=shadow,border "Violations")


#### Gatekeeper Config

In this area you have the possibility to define a Gatekeeper Config. It is not required, but might be needed for some constraints that need more access.
Initially you will only see the `Add Gatekeeper Config` button. 

![Gatekeeper Config](/img/kubermatic/master/ui/opa_config.png?classes=shadow,border "Gatekeeper Config")

Click on this button to create a config. A new dialog will appear, where you can insert your spec:

![Add Gatekeeper Config](/img/kubermatic/master/ui/opa_add_config.png?height=350px&classes=shadow,border "Add Gatekeeper Config")

Following example will dynamically update what objects are synced:
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
![Gatekeeper Config](/img/kubermatic/master/ui/opa_config_overview.png?height=350px&classes=shadow,border "Gatekeeper Config")
