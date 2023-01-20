+++
title = "OPA Integration"
date = 2021-09-08T12:07:15+02:00
weight = 11

+++

This manual explains how Kubermatic integrates with OPA and how to use it.

### OPA

[OPA](https://www.openpolicyagent.org/) (Open Policy Agent) is an open-source, general-purpose policy engine that unifies
 policy enforcement across the stack.
We are integrating with it using [Gatekeeper](https://github.com/open-policy-agent/gatekeeper), which is an OPA's Kubernetes-native
policy engine.

More info about OPA and Gatekeeper can be read from their docs and tutorials, but the general idea is that by using the
Constraint Template CRD the users can create rule templates whose parameters are then filled out by the corresponding Constraints.


### How to activate OPA Integration on your cluster

The integration is specific per user cluster, meaning that it is activated by a flag in the cluster spec.

```yaml
apiVersion: kubermatic.k8c.io/v1
kind: Cluster
metadata:
  name: l78dsl4l8x
spec:
  humanReadableName: cocky-thompson
  oidc: {}
  opaIntegration:
    enabled: true
  pause: false
```

By setting this flag to true, Kubermatic automatically deploys the needed Gatekeeper components to the control plane
as well as the user cluster.

### Managing Constraint Templates

Constraint Templates are managed by the Kubermatic platform admins. Kubermatic introduces a Kubermatic Constraint Template wrapper CRD through which the users can interact with the OPA CT's. The Kubermatic master clusters contain the
Kubermatic CT's which designated controllers to reconcile to the seed and to user cluster with activated OPA integration as Gatekeeper CT's.

Example of a Kubermatic Constraint Template:
```yaml
apiVersion: kubermatic.k8c.io/v1
kind: ConstraintTemplate
metadata:
  name: k8srequiredlabels
spec:
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
              items:
                type: string
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

Kubermatic Constraint Template corresponds 1:1 to the Gatekeeper Constraint Template.

#### Deleting Constraint Templates

Deleting Constraint Templates causes all related Constraints to be deleted as well.

### Managing Constraints

Constraints are managed similarly to Constraint Templates through Kubermatic CRD wrappers around the Gatekeeper Constraints,
the difference being that Constraints are managed on the user cluster level. Furthermore, due to the way Gatekeeper works,
Constraints need to be associated with a Constraint Template.

![Cluster Details View](/img/kubermatic/main/ui/opa_cluster_view.png?height=500px&classes=shadow,border "Cluster Details View")

![Constraints Cluster View](/img/kubermatic/main/ui/opa_constraints_cluster.png?classes=shadow,border "Constraints Cluster View")

To add a new constraint click on the `+ Add Constraint` icon on the right at the bottom of cluster view. A new dialog will appear, where you can specify the name, the constraint template, and the spec:
Spec is the only field that needs to be filled with a yaml.


![Add Constraints Dialog](/img/kubermatic/main/ui/opa_add_constraint.png?height=350px&classes=shadow,border "Add Constraints Dialog")

`Note: You can now manage Default Constraints from the Admin Panel.`

Kubermatic Constraint controller reconciles the Kubermatic Constraints on the seed clusters as Gatekeeper Constraints on the user cluster.

Example of a Kubermatic Constraint:

```yaml
apiVersion: kubermatic.k8c.io/v1
kind: Constraint
metadata:
  name: ns-must-have-gk
  namespace: cluster-l78dsl4l8x
spec:
  constraintType: K8sRequiredLabels
  enforcementAction: "deny"
  match:
    kinds:
      - apiGroups: [""]
        kinds: ["Namespace"]
  parameters:
    labels: ["gatekeeper"]
```

- `constraintType` - must be equal to the name of an existing Constraint Template
- `enforcementAction` - (optional) defines the action to take in response to a constraint being violated. By default, EnforcementAction is set to deny as the default behavior is to deny admission requests with any violation. Works the same as [Gatekeeper enforcementAction](https://open-policy-agent.github.io/gatekeeper/website/docs/violations/)
- `match` - works the same as [Gatekeeper Constraint matching](https://github.com/open-policy-agent/gatekeeper#constraints)
- `parameters` - holds the parameters that are used in Constraints. As in Gatekeeper, this can be basically anything that fits the related Constraint Template.

### Default Constraints

Default Constraints allow admins to conveniently apply policies to all OPA enabled clusters.
This would allow admins an easier way to make sure all user clusters are following some policies (for example security), instead of the current way in which Constraints need to be created for each cluster separately.
Kubermatic operator/admin creates a Constraint in the admin panel, it gets propagated to seed clusters and user clusters with OPA-integration.

The following example is regarding `Restricting escalation to root privileges` in Pod Security Policy but implemented as Constraints and Constraint Templates with Gatekeeper.

Constraint Templates
```yaml
crd:
  spec:
    names:
      kind: K8sPSPAllowPrivilegeEscalationContainer
targets:
  - target: admission.k8s.gatekeeper.sh
    rego: |
      package k8spspallowprivilegeescalationcontainer
      violation[{"msg": msg, "details": {}}] {
          c := input_containers[_]
          input_allow_privilege_escalation(c)
          msg := sprintf("Privilege escalation container is not allowed: %v", [c.name])
      }
      input_allow_privilege_escalation(c) {
          not has_field(c, "securityContext")
      }
      input_allow_privilege_escalation(c) {
          not c.securityContext.allowPrivilegeEscalation == false
      }
      input_containers[c] {
          c := input.review.object.spec.containers[_]
      }
      input_containers[c] {
          c := input.review.object.spec.initContainers[_]
      }
      # has_field returns whether an object has a field
      has_field(object, field) = true {
          object[field]
      }
selector:
  labelSelector: {}
```

Constraint
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

### Managing Default Constraints

Default Constraints are managed similarly to Constraint through Kubermatic CRD wrappers around the Gatekeeper Constraints, the difference being that Default Constraints are managed on the `Admin level` by Kubermatic platform admins.
Also Default Constraints are created in `kubermatic` namespace in Master Cluster from where they are propagated to seed clusters `kubermatic` namespace and then to user clusters with OPA-integration.
cluster namespaces

In the Admin Panel navigate to the OPA menu and then to Default Constraints.

![Default Constraints](/img/kubermatic/main/ui/default-constraint-admin.png?height=300px&classes=shadow,border "Default Constraints")

To add a new default constraint click on the `+Add Default Constraint` icon on the right. A new dialog will appear, where you can specify the name, the constraint template and the spec:
Spec is the only field that needs to be filled with a yaml.

![Create Default Constraint](/img/kubermatic/main/ui/create-default-constraint-dialog.png?height=300px&classes=shadow,border "Create Default Constraint")

On Cluster Level, Default Constraints are the same as Constraints with a `default` label to differentiate them from other Constraints.

Note that they can not be edited/deleted at the Cluster level.

Example of a Kubermatic Default Constraint:

```yaml
apiVersion: kubermatic.k8c.io/v1
kind: Constraint
metadata:
  name: ns-must-have-gk
  namespace: cluster-bpc9nstqvk
  labels:
    default: ns-must-have-gk
spec:
  constraintType: K8sRequiredLabels
  match:
    kinds:
      - apiGroups: [""]
        kinds: ["Namespace"]
  parameters:
    labels: ["gatekeeper"]
```
### Disabling Constraint

The constraint can be Disabled/Turned off by setting the `disabled` flag to true in the constraint spec.

To Enable Default Constraints again, you can just remove the `disabled` flag or set it to `false`.

{{% notice info %}}
This is an EE feature.
{{% /notice %}}

Example of a Disabled Kubermatic Constraint:

```yaml
apiVersion: kubermatic.k8c.io/v1
kind: Constraint
metadata:
  name: ns-must-have-gk
  namespace: cluster-l78dsl4l8x
spec:
  constraintType: K8sRequiredLabels
  disabled: true
  match:
    kinds:
      - apiGroups: [""]
        kinds: ["Namespace"]
  parameters:
    labels: ["gatekeeper"]
```

#### Disabling Default Constraint

By setting `disabled` flag to true, Kubermatic deletes the constraint from all User clusters.

Note: Constraint will still be present in the user cluster namespace on the Seed Cluster for future use.

To Enable Default Constraints again, you can just remove the `disabled` flag or set it to `false`.

To disable Default Constraintsin the Admin View, click on the green button under `On/Off`
![Disable Default Constraint](/img/kubermatic/main/ui/default-constraint-on.png?height=200px&classes=shadow,border "Disable Default Constraint")

Enable the constraint by clicking the same button
![Enable Default Constraint](/img/kubermatic/main/ui/disabled-default-constraint.png?height=200px&classes=shadow,border "Enable Default Constraint")

### Filtering Clusters on Default Constraints

Admins can filter clusters where they want Default constraints applied using Cloud Provider and Label Selectors filters.
{{% notice info %}}
This is an EE feature.
{{% /notice %}}

The following example will make sure that the Constraint is applied only on OPA enabled Clusters with Cloud Provider `aws` or `gcp` which have label `filtered: 'true'`.

```yaml
constraintType: K8sRequiredLabels
match:
  kinds:
    - kinds:
        - Namespace
      apiGroups:
  labelSelector: {}
  namespaceSelector: {}
parameters:
  labels: ["gatekeeper"]
selector:
  providers:
    - aws
    - gcp
  labelSelector:
    matchLabels:
      filtered: 'true'
```
### Deleting Default Constraint

Deleting Default Constraint causes all related Constraints on the user clusters to be deleted as well.

Note: Cluster Admins will not be able to edit/delete Default Constraints

### AllowedRegistry

AllowedRegistry allows admins to easily control what image registries can be used in user clusters. This is the first KKP
inbuilt Constraint and its goal is to make creating Constraint Templates and Default Constraints simpler.

{{% notice info %}}
This is an EE feature.
{{% /notice %}}

![Allowed Registries View](/img/kubermatic/main/ui/allowed_registries.png?classes=shadow,border "Allowed Registry View")

AllowedRegistry functions as its own CR, which when created, triggers the creation of the corresponding
[Constraint Template]({{< ref "#managing-constraint-templates" >}})(`allowedregistry`) and [Default Constraints]({{< ref "#default-constraints" >}})(`allowedregistry`).
It accepts only 2 parameters, its name and the registry prefix of the registry which can be used on the user cluster.
When there are multiple AllowedRegistries, we collect all registry prefixes and put them into a list in the allowedregistry Default Constraint.
OPA matches these prefixes with the Pods container `image` field and if it matches with at least one, it allows the Pod to be created/updated.
They are cluster-scoped and reside in the KKP Master cluster.

Example of a AllowedRegistry:
```yaml
apiVersion: kubermatic.k8c.io/v1
kind: AllowedRegistry
metadata:
  name: quay
spec:
  registryPrefix: quay.io
```

Corresponding ConstraintTemplate:

```yaml
apiVersion: kubermatic.k8c.io/v1
kind: ConstraintTemplate
metadata:
  name: allowedregistry
spec:
  crd:
    spec:
      names:
        kind: allowedregistry
      validation:
        openAPIV3Schema:
          properties:
            allowed_registry:
              items:
                type: string
              type: array
  selector:
    labelSelector: {}
  targets:
  - rego: |-
      package allowedregistry

      violation[{"msg": msg}] {
        container := input.review.object.spec.containers[_]
        satisfied := [good | repo = input.parameters.allowed_registry[_] ; good = startswith(container.image, repo)]
        not any(satisfied)
        msg := sprintf("container <%v> has an invalid image registry <%v>, allowed image registries are %v", [container.name, container.image, input.parameters.allowed_registry])
      }
      violation[{"msg": msg}] {
        container := input.review.object.spec.initContainers[_]
        satisfied := [good | repo = input.parameters.allowed_registry[_] ; good = startswith(container.image, repo)]
        not any(satisfied)
        msg := sprintf("container <%v> has an invalid image registry <%v>, allowed image registries are %v", [container.name, container.image, input.parameters.allowed_registry])
      }
    target: admission.k8s.gatekeeper.sh
```

Corresponding Default Constraint:

```yaml
apiVersion: kubermatic.k8c.io/v1
kind: Constraint
metadata:
  name: allowedregistry
  namespace: kubermatic
spec:
  constraintType: allowedregistry
  match:
    kinds:
    - apiGroups:
      - ""
      kinds:
      - Pod
    labelSelector: {}
    namespaceSelector: {}
  parameters:
    allowed_registry:
    - quay.io
  selector:
    labelSelector: {}
```

![Allowed Registry Default Constraint](/img/kubermatic/main/ui/allowed_registry_default_constraint.png?classes=shadow,border "Allowed Registry Default Constraint")

For the existing `allowedregistry` [Default Constraint]({{< ref "#default-constraints" >}}), feel free to edit the [Filtering]({{< ref "#filtering-clusters-on-default-constraints" >}}).

When a user tries to create a Pod with an image coming from a registry that is not prefixed by one of the AllowedRegistries,
they will get a similar error:
```
container <unwanted> has an invalid image registry <unwanted.registry/unwanted>, allowed image registries are ["quay.io"]
```

A similar feature as AllowedRegistries can be achieved by an OPA-familiar user, using Constraint Templates and Default Constraints,
AllowedRegistries are just a way to make admins life easier.

{{% notice info %}}
When there are no AllowedRegistries, we automatically disable the Default Constraint.
{{% /notice %}}

### Managing Config

Gatekeeper [Config](https://github.com/open-policy-agent/gatekeeper#replicating-data) can also be managed through Kubermatic.
As Gatekeeper treats it as a kind of singleton CRD resource, Kubermatic just manages this resource directly on the user cluster.

You can manage the config in the user cluster view, per user cluster.

### Removing OPA Integration

OPA integration on a user cluster can simply be removed by disabling the OPA Integration flag on the Cluster object.
Be advised that this action removes all Constraint Templates, Constraints, and Config related to the cluster.

**Exempting Namespaces**

`gatekeeper-system` and `kube-system` namespace are by default entirely exempted from Gatekeeper webhook which means they are exempted from the Admission Webhook and Auditing.

More on this here [Exempt-Namespace](https://open-policy-agent.github.io/gatekeeper/website/docs/exempt-namespaces/)
