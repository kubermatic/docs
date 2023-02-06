+++
title = "Add or Remove an Application Version"
date =  2023-01-23T11:25:41+02:00
weight = 3
+++

This guide targets KKP Admins and details adding and removing a version to an `ApplicationDefinition`.

## How to add a version to an ApplicationDefinition
To make a new version of an application available, you only have to add it to `ApplicationDefinition` version's list.  
Let's say you have the following `ApplicationDefinition`
```yaml
apiVersion: apps.kubermatic.k8c.io/v1
kind: ApplicationDefinition
metadata:
  name: apache
spec:
  defaultValues:
    commonLabels:
      owner: somebody
  description: Apache HTTP Server is an open-source HTTP server for modern operating systems
  method: helm
  versions:
    - template:
        source:
          helm:
            chartName: apache
            chartVersion: 9.2.9
            url: https://charts.bitnami.com/bitnami
      version: 9.2.9
```
And want to make the new version `9.2.11` available. Then, all you have to do is to add the new version as described below:

```yaml
apiVersion: apps.kubermatic.k8c.io/v1
kind: ApplicationDefinition
metadata:
  name: apache
spec:
  defaultValues:
    commonLabels:
      owner: somebody
  description: Apache HTTP Server is an open-source HTTP server for modern operating systems
  method: helm
  versions:
    - template:
        source:
          helm:
            chartName: apache
            chartVersion: 9.2.9
            url: https://charts.bitnami.com/bitnami
      version: 9.2.9
    - template:
        source:
          helm:
            chartName: apache
            chartVersion: 9.2.11
            url: https://charts.bitnami.com/bitnami
      version: 9.2.11
```
Users will now be able to reference this version in their `ApplicationInstallation`. For additional details, see the [update an application guide]({{< ref "../update-application" >}}).

{{% notice warning %}}
Do not replace one version with another, as it will be perceived as a **deletion** by the application installation controller leading to **deletion of all `ApplicationInstallation` using this version.**
For more details, see how to delete a version from an `ApplicationDefinition`.
{{% /notice %}}

## How to delete a version from an ApplicationDefinition
Deleting a version from `ApplicationDefinition` will trigger the deletion of all `ApplicationInstallations` that reference this version! It guarantees that only desired versions are installed in user clusters, which is helpful if a version contains a critical security breach.
Under normal circumstances, we recommend following the deprecation policy to delete a version.

### Deprecation policy
Our recommended deprecation policy is as follows:
* stop the user from creating or upgrading to the deprecated version. But let them edit the application using a deprecated version (it may be needed for operational purposes).
* notify the user running this version that it's deprecated.

Once the deprecation period is over, delete the version from the `ApplicationDefinition`.

{{% notice info %}}
This deprecation policy is an example and may have to be adapted to your organization's needs.
{{% /notice %}}

The best way to achieve that is using the [gatekepper / opa integration]({{< ref "../../OPA-integration" >}}) to create a `ContraintTemplate` and two [Default Constraints]({{< ref "../../OPA-integration#default-constraints" >}}) (one for each point of the deprecation policy)

**Example Kubermatic Constraint Template to deprecate a version:**
```yaml
apiVersion: kubermatic.k8c.io/v1
kind: ConstraintTemplate
metadata:
  name: applicationdeprecation
spec:
  crd:
    spec:
      names:
        kind: ApplicationDeprecation
      validation:
        legacySchema: false
        openAPIV3Schema:
          properties:
            allowEdit:
              description: allow edit of existing application using deprecated version
              type: boolean
            name:
              description: The name of the application to depreciate.
              type: string
            version:
              description: the version of the application to depreciate
              type: string
          type: object
  selector:
    labelSelector: {}
  targets:
  - target: admission.k8s.gatekeeper.sh
    rego: |
      package applicationdeprecation 

      # reject creation of a new application using the deprecated version
      violation[{"msg": msg, "details": {}}] {
          is_operation("CREATE")

          appRef := input.review.object.spec.applicationRef
          is_app_deprecated(appRef)
          msg := sprintf("application `%v` in version `%v` is deprecated. Please upgrade to the next version", [input.parameters.name, input.parameters.version])
        }

      # reject upgrade to the deprecated version but allow edit application that currently use the deprecated version
      violation[{"msg": msg, "details": {}}] {
        is_operation("UPDATE")
        # when removing finilizer on applicationInstallation an Update event is sent.
        not input.review.object.metadata.deletionTimestamp

        appRef := input.review.object.spec.applicationRef
        reject_update
        is_app_deprecated(appRef)

        msg := sprintf("application `%v` in version `%v` is deprecated. Please upgrade to the next version", [input.parameters.name, input.parameters.version])
      }

      is_operation(op)  {
        # check that input.review.operation belongs to the set "ops". This set is composed of op and empty string because in audit mode input.review.operation is empty.
        ops := {op, ""}
        ops[input.review.operation]
      }

      is_app_deprecated(appRef) {
        appRef.name == input.parameters.name
        appRef.version == input.parameters.version
      }

      reject_update  {
        input.parameters.allowEdit == true
        appRef := input.review.object.spec.applicationRef
        appRef != input.review.oldObject.spec.applicationRef
        is_app_deprecated(appRef)
      }

      reject_update  {
        input.parameters.allowEdit == false
        appRef := input.review.object.spec.applicationRef
        is_app_deprecated(appRef)
      }
```

**Example Kubermatic Default constraint to reject creation or upgrade to a deprecated version:**

```yaml
apiVersion: kubermatic.k8c.io/v1
kind: Constraint
metadata:
  name: deprecate-app-apache-9-2-9
  namespace: kubermatic
spec:
  constraintType: ApplicationDeprecation
  match:
    kinds:
    - apiGroups:
      - apps.kubermatic.k8c.io
      kinds:
      - ApplicationInstallation
    labelSelector: {}
    namespaceSelector: {}
  parameters:
    allowEdit: true
    name: apache
    version: 9.2.9
  selector:
    labelSelector: {}
```

If users try to create an  `ApplicationInstallation` using the deprecation version, they will get the following error message:

```
$ kubectl create -f app.yaml
Error from server ([deprecate-app-apache-9-2-9] application `apache` in version `9.2.9` is deprecated. Please upgrade to next version): error when creating "app.yaml": admission webhook "validation.gatekeeper.sh" denied the request: [deprecate-app-apache-9-2-9] application `apache` in version `9.2.9` is deprecated. Please upgrade to the next version
```

**Example Kubermatic Default constraint to warn user using deprecated version:**

```yaml
apiVersion: kubermatic.k8c.io/v1
kind: Constraint
metadata:
  name: warn-app-apache-9-2-9
  namespace: kubermatic
spec:
  constraintType: ApplicationDeprecation
  # The warn enforcement policy will return a warning instead of deny requests.
  enforcementAction: warn
  match:
    kinds:
    - apiGroups:
      - apps.kubermatic.k8c.io
      kinds:
      - ApplicationInstallation
    labelSelector: {}
    namespaceSelector: {}
  parameters:
    allowEdit: false
    name: apache
    version: 9.2.9
  selector:
    labelSelector: {}
```
This constraint will raise a warning if a user tries to create, edit, or upgrade to the deprecated version:

```
$ kubectl edit applicationInstallation  my-apache
Warning: [warn-app-apache-9-2-9] application `apache` in version `9.2.9` is deprecated. Please upgrade to the next version
applicationinstallation.apps.kubermatic.k8c.io/my-apache edited
```

We can see which applications are using the deprecated version by looking at the constraint status.

```
status:
  [...]
  auditTimestamp: "2023-01-23T14:55:47Z"
  totalViolations: 1
  violations:
  - enforcementAction: warn
    kind: ApplicationInstallation
    message: application `apache` in version `9.2.9` is deprecated. Please upgrade
      to next version
    name: my-apache
    namespace: default
```

*note: the number of violations on the status is limited to 20. There are more ways to collect violations. Please refer to the official [Gatekeeper audit documentation](https://open-policy-agent.github.io/gatekeeper/website/docs/audit)*
