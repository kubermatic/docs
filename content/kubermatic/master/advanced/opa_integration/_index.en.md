+++
title = "OPA Integration"
date = 2021-01-21T14:07:15+02:00
weight = 40

+++

This manual explains how Kubermatic integrates with OPA and how to use it. 

### OPA

[OPA](https://www.openpolicyagent.org/) (Open Policy Agent) is an open source, general-purpose policy engine that unifies
 policy enforcement across the stack. 
We are integrating with it using [Gatekeeper](https://github.com/open-policy-agent/gatekeeper), which is a OPA's Kubernetes-native 
policy engine.

More info about OPA and Gatekeeper can be read from their docs and tutorials, but the general idea is that by using the 
Constraint Template CRD the users can create rule templates whose parameters are then filled out by the corresponding Constraints. 


### How to activate OPA integration on your cluster

The integration is specific per user cluster, meaning that it is activated by a flag in the cluster spec. 

```yaml
apiVersion: kubermatic.k8s.io/v1
kind: Cluster
metadata:
  name: crh4xbxz5f
spec:
...
  humanReadableName: suspicious-mcnulty
  oidc: {}
  opaIntegration: 
    enabled: true
  openshift: {}
...
```

By setting this flag to true, Kubermatic automatically deploys the needed Gatekeeper components to the control plane 
as well as the user cluster. 

### Managing Constraint Templates

Constraint Templates are managed by the Kubermatic platform admins. Kubermatic introduces a Kubermatic Constraint Template 
wrapper CRD through which the users can interact with the OPA CT's. The Kubermatic master clusters contain the 
Kubermatic CT's which designated controllers reconcile to the seed and to user cluster with activated OPA integration as 
Gatekeeper CT's.

Example of a Kubermatic Constraint Template:
```yaml
apiVersion: kubermatic.k8s.io/v1
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

Kubermatic Constraint Template corresponds 1:1 to the Gatkeeper Constraint Template.

#### Deleting Constraint Templates

Deleting Constraint Templates causes all related Constraints to be deleted as well.

#### API Endpoints for Constraint Templates

Constraint Template management is currently only available through the API. UI is coming soon.

- GET `/api/v2/constrainttemplates` - List CTs
- GET `/api/v2/constrainttemplates/{ct_name}` Get specific CT
- POST `/api/v2/constrainttemplates` Create CT 
- PATCH `/api/v2/constrainttemplates/{ct_name}` Patch CT
- DELETE `/api/v2/constrainttemplates/{ct_name}` Delete CT

Constraint Template endpoints and API object are described in the Kubermatic Swagger docs at `/rest-api`.

### Managing Constraints

Constraints are manages similarly to Constraint Templates through Kubermatic CRD wrappers around the Gatkeeper Constraints, 
the difference being that Constraints are managed on the user cluster level. Furthermore, due to the way Gatekeeper works, 
Constraints need to be associated with a Constraint Template.

Kubermatic Constraint controller reconciles the Kubermatic Constraints on the seed clusters as Gatekeeper Constraints on 
the user cluster.

Example of a Kubermatic Constraint:

```yaml
apiVersion: kubermatic.k8s.io/v1
kind: Constraint
metadata:
  name: ns-must-have-gk
  namespace: cluster-zdljwf8j7h
spec:
  constraintType: K8sRequiredLabels
  match:
    kinds:
      - apiGroups: [""]
        kinds: ["Namespace"]
  parameters:
    rawJSON: '{"labels":["gatekeeper"]}'
```

- `constraintType` - must be equal to the name of an existing Constraint Template
- `match` - works the same as [Gatekeeper Constraint matching](https://github.com/open-policy-agent/gatekeeper#constraints) 
- `parameters` - holds the rawJSON parameters that are used in Constraints. As in Gatekeeper this can be basically anything, 
Kubermatic just uses it as a raw json string to be able to structure it.

#### API Endpoints for Constraints

Constraint management is currently only available through the API. UI is coming soon.

- GET `/api/v2/projects/{project_id}/clusters/{cluster_id}/constraints` - List Constraints 
- GET `/api/v2/projects/{project_id}/clusters/{cluster_id}/constraints/{constraint_name}` Get specific Constraint
- POST `/api/v2/projects/{project_id}/clusters/{cluster_id}/constraints` Create Constraint 
- PATCH `/api/v2/projects/{project_id}/clusters/{cluster_id}/constraints/{constraint_name}` Patch Constraint
- DELETE `/api/v2/projects/{project_id}/clusters/{cluster_id}/constraints/{constraint_name}` Delete Constraint

Constraint endpoints and API object are described in the Kubermatic Swagger docs at `/rest-api`.

### Managing Config

Gatekeeper [Config](https://github.com/open-policy-agent/gatekeeper#replicating-data) can also be managed through Kubermatic. 
As Gatekeeper treats it as a kind of singleton CRD resource, Kubermatic just manages this resource directly on the user cluster.

#### API Endpoints for Config

Config management is currently only available through the API. UI is coming soon.

- GET `/api/v2/projects/{project_id}/clusters/{cluster_id}/gatekeeper/config` Get Config
- POST `/api/v2/projects/{project_id}/clusters/{cluster_id}/gatekeeper/config` Create Config 
- PATCH `/api/v2/projects/{project_id}/clusters/{cluster_id}/gatekeeper/config` Patch Config
- DELETE `/api/v2/projects/{project_id}/clusters/{cluster_id}/gatekeeper/config` Delete Config

Config endpoints and API object are described in the Kubermatic Swagger docs at `/rest-api`.

### Removing OPA Integration

OPA integration on a user cluster can simply be removed by disabling the OPA Integration flag on the Cluster object. Be 
advised that this action removes all Constraint Templates, Constraints and Config related to the cluster.
