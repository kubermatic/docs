+++
title = "Application Installation"
date = 2023-01-27T14:07:15+02:00
weight = 2

+++

An `ApplicationInstallation` is an instance of an application to install into user-cluster.
It abstracts to the end user how to get the application deployment sources (i.e. the k8s manifests, hem chart... ) and how to install it into the cluster. So he can install and use the application with minimal knowledge of Kubernetes.

## Anatomy of an Application
```yaml
apiVersion: apps.kubermatic.k8c.io/v1
kind: ApplicationInstallation
metadata:
  name: my-apache
  namespace: default
spec:
  applicationRef:
    name: apache
    version: 9.2.9
  namespace:
    name: frontend
    create: true
    labels:
      owner: "team-1"
  valuesBlock: |
    commonLabels:
      owner: "team-1"
```

The `applicationRef` is a reference to the `applicationDefinition` that handles this installation.
The `.spec.namespace` defines in which namespace the application will be installed. If `.spec.namespace.create` is `true`, then it will ensure that the namespace exists and have the desired labels.
The `values` is a schemaless field that describes overrides for manifest-rendering (e.g. if the method is Helm, then this field contains the Helm values.)

## Application Life Cycle
It mainly composes of 2 steps: download the application's source and install or upgrade the application. You can monitor these steps thanks to the conditions in the applicationInstallation's status.

- `ManifestsRetrieved` condition indicates if application's source has been correctly downloaded.
- `Ready` condition indicates the installation / upgrade status. it can have four states:
  - `{status: "Unknown", reason: "InstallationInProgress"}`: meaning the application installation / upgrade is in progress.
  - `{status: "True", reason: "InstallationSuccessful"}`: meaning the application installation / upgrade was successful.
  - `{status: "False", reason: "InstallationFailed"}`:  meaning the installation / upgrade has failed.
  - `{status: "False", reason: "InstallationFailedRetriesExceeded"}`:  meaning the max number of retries was exceeded.

### Helm additional information
If the [templating method]({{< ref "../application-definition#templating-method" >}}) is `Helm`, then additional information regarding the install or upgrade is provided under `.status.helmRelease`.

Example:
```yaml
status:
  [...]
  helmRelease:
    info:
      description: Install complete
      firstDeployed: "2023-02-02T07:52:58Z"
      lastDeployed: "2023-02-02T07:52:58Z"
      notes: |+
        CHART NAME: apache
        CHART VERSION: 9.2.9
        APP VERSION: 2.4.54

        ** Please be patient while the chart is being deployed **

        1. Get the Apache URL by running:

        ** Please ensure an external IP is associated to the default-apache service before proceeding **
        ** Watch the status using: kubectl get svc --namespace default -w default-apache **

          export SERVICE_IP=$(kubectl get svc --namespace default default-apache --template "{{ range (index .status.loadBalancer.ingress 0) }}{{ . }}{{ end }}")
          echo URL            : http://$SERVICE_IP/


        WARNING: You did not provide a custom web application. Apache will be deployed with a default page. Check the README section "Deploying your custom web application" in https://github.com/bitnami/charts/blob/main/bitnami/apache/README.md#deploying-a-custom-web-application.


      status: deployed
    name: default-apache
    version: 1
```

## Advanced Configuration
This section is relevant to advanced users. However, configuring advanced parameters may impact performance, load, and workload stability. Consequently, it must be treated carefully.

### Periodic Reconciliation
By default, Applications are only reconciled on changes in the spec, annotations, or the parent application definition. Meaning that if the user manually deletes the workload deployed by the application, nothing will happen until the `ApplicationInstallation` CR changes.

You can periodically force the reconciliation of the application by settings `.spec.reconciliationInterval`:
- a value greater than zero force reconciliation even if no changes occurred on application CR.
- a value equal to 0 disables the force reconciliation of the application (default behavior).

{{% notice warning %}}
Setting this too low can cause a heavy load and disrupt your application workload, depending on the template method.
{{% /notice %}}

The application will not be reconciled if the maximum number of retries is exceeded.

### Customize Deployment
You can tune how the application will be installed by setting `.spec.deployOptions`.
The options depends of the template method (i.e. `.spec.method`) of the `ApplicationDefinition`.

*note: if `deployOptions` is not set then it used the default defined at the `ApplicationDefinition` level (`.spec.defaultDeployOptions`)*

#### Customize Deployment for Helm Method
You may tune how Helm deploys the application with the following options:

* `atomic`: corresponds to the `--atomic` flag on Helm CLI. If set, the installation process deletes the installation on failure; the upgrade process rolls back changes made in case of failed upgrade.
* `wait`: corresponds to the `--wait` flag on Helm CLI. If set, will wait until all Pods, PVCs, Services, and minimum number of Pods of a Deployment, StatefulSet, or ReplicaSet are in a ready state before marking the release as successful. It will wait for as long as `--timeout`
* `timeout`: corresponds to the `--timeout` flag on Helm CLI. It's time to wait for any individual Kubernetes operation.
* `enableDNS`: corresponds to the `-enable-dns ` flag on Helm CLI. It enables DNS lookups when rendering templates. if you enable this flag, you have to verify that helm template function 'getHostByName' is not being used in a chart to disclose any information you do not want to be passed to DNS servers.(c.f. [CVE-2023-25165](https://github.com/helm/helm/security/advisories/GHSA-pwcw-6f5g-gxf8))

Example:
```yaml
apiVersion: apps.kubermatic.k8c.io/v1
kind: ApplicationInstallation
metadata:
  name: my-apache
spec:
  deployOptions:
    helm:
      atomic: true
      wait: true
      timeout: "5m"
```

*note: if `atomic` is true, then wait must be true. If `wait` is true then `timeout` must be defined.*

If `.spec.deployOptions.helm.atomic` is true, then when installation or upgrade of an application fails, `ApplicationsInstallation.Status.Failures` counter is incremented.
If it reaches the max number of retries (hardcoded to 5), then the applicationInstallation controller will stop trying to install or upgrade the application until applicationInstallation 's spec changes.
This behavior reduces the load on the cluster and avoids an infinite loop that disrupts workload.

## ApplicationInstallation Reference
**The following is an example of ApplicationInstallation, showing all the possible options**.

```yaml
{{< readfile "kubermatic/main/data/applicationInstallation.yaml" >}}
```
