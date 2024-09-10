+++
title = "Admin Panel"
date = 2018-08-09T12:07:15+02:00
weight = 40
+++

The Admin Panel is a place where the Kubermatic administrators can manage the global settings that
impact all Kubermatic users directly. Admin rights can be granted from the admin panel itself and also from the kubectl by
setting the `spec.admin` field of the user object to `true`.

```bash
$ kubectl get user -o=custom-columns=INTERNAL_NAME:.metadata.name,NAME:.spec.name,EMAIL:.spec.email,ADMIN:.spec.admin
$ kubectl edit user ...
```

After logging in to the dashboard as an administrator, you should be able to access the admin panel from the menu up
top.

![](/img/kubermatic/v2.24/ui/admin_panel_access.png?height=300px&classes=shadow,border "Accessing the Admin Panel")

![](/img/kubermatic/v2.24/ui/panel.png?height=350px&classes=shadow,border "Admin Panel")

Global settings can also be modified from the command line with kubectl. It can be done by editing the `globalsettings` in `KubermaticSetting` CRD. This resource has the following structure:

```
apiVersion: kubermatic.k8c.io/v1
kind: KubermaticSetting
metadata:
  name: globalsettings
  ...
spec:
  cleanupOptions:
    Enabled: true
    Enforced: false
  clusterTypeOptions: 0
  customLinks:
  - icon: ""
    label: Twitter
    location: footer
    url: https://www.twitter.com/kubermatic
  - icon: ""
    label: GitHub
    location: footer
    url: https://github.com/kubermatic
  - icon: ""
    label: Slack
    location: footer
    url: http://slack.kubermatic.io/
  defaultNodeCount: 1
  displayAPIDocs: true
  displayDemoInfo: false
  displayTermsOfService: true
  enableDashboard: true
  enableExternalClusterImport: true
  enableOIDCKubeconfig: false
  machineDeploymentVMResourceQuota:
    enableGPU: true
    maxCPU: 8
    maxRAM: 64
    minCPU: 1
    minRAM: 2
  restrictProjectCreation: false
  userProjectsLimit: 0

```

It can be edited directly from the command line:

```
$ kubectl edit kubermaticsetting globalsettings
```

**Note:** Custom link `icon` is not required and defaults will be used if field is not specified. `icon` URL can
point to the images inside the container as well, i.e. `/assets/images/icons/custom/github.svg`.

## Manage Global Settings via UI

The below global settings are managed via UI:

### Manage Custom Links
Control the way custom links are displayed in the Kubermatic Dashboard. Choose the place that suits you best, whether
it is a sidebar, footer or a help & support panel. Check out the [Custom Links]({{< ref "./custom-links" >}}) section for
more details.

### Control Cluster Settings
Control number of initial Machine Deployment replicas, cluster deletion cleanup settings, availability of
Kubernetes Dashboard for user clusters and more. Check out the [Cluster Settings]({{< ref "./cluster-settings" >}}) section
for more details.

### Manage Dynamic Datacenters
Use number of filtering options to find and control existing dynamic datacenters or simply create a new one.Check out the 
[Dynamic Datacenters]({{< ref "./dynamic-datacenters-management" >}}) section for more details.

### Manage Administrators
Manage all Kubermatic Dashboard Administrator in a single place. Decide who should be granted or revoked an administrator
privileges. Check out the [Administrators]({{< ref "./administrators" >}}) section for more details.

### Manage Presets
Prepare custom provider presets for a variety of use cases. Control which presets will be visible to the users down to
the per-provider level. Check out the [Presets]({{< ref "./presets-management" >}}) section for more details.

### OPA Constraint Templates
Constraint Templates allow you to declare new Constraints. They are intended to work as a schema for Constraint parameters 
and enforce their behavior. Check out the [OPA Constraint Templates]({{< ref "./opa-constraint-templates" >}}) section for 
more details.

### Backup Buckets
Through the Backup Buckets settings you can enable and configure the new etcd backups per Seed. Check out the 
[Etcd Backup Settings]({{< ref "./backup-buckets" >}}) section for more details.
