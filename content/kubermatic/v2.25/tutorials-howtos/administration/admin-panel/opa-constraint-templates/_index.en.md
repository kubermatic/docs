+++
title = "OPA Constraint Templates"
date = 2021-09-08T12:07:15+02:00
weight = 20
+++

![Constraint Templates](/img/kubermatic/v2.25/ui/opa-admin-ct-view.png?classes=shadow,border "Constraint Templates")

Constraint Templates allow you to declare new Constraints. They are intended to work as a schema for Constraint parameters and enforce their behavior.
The Constraint Templates view under OPA menu in Admin Panel allows adding, editing and deleting Constraint Templates.

## Adding Constraint Templates
Constraint Templates can be added after clicking on the `+ Add Constraint Template` icon in the top right corner of the view.

![Add Constraint Template](/img/kubermatic/v2.25/ui/opa-admin-add-ct.png?classes=shadow,border&height=350px "Constraint Template Add Dialog")

Spec is the only field that needs to be filled with a yaml. By clicking on `+ Add Constraint Template` a new Constraint Template will be created.

Following example requires all labels that are described by the Constraint to be present:

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

## Editing Constraint Templates
Constraint Templates can be edited after clicking on the pencil icon that appears when hovering over one of the rows. The form is identical to the one from creation.

## Deleting Constraint Templates
Constraint Templates can be deleted after clicking on the trash icon that appears when hovering over one of the rows. Please note, that the deletion of a Constraint Template will also delete all Constraints that are assigned to it.

![Delete Constraint Template](/img/kubermatic/v2.25/ui/opa-admin-delete-ct.png?classes=shadow,border&height=200 "Constraint Template Delete Dialog")
