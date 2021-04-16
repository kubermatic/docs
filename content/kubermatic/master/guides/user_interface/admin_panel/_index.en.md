+++
title = "Admin Panel"
date = 2018-08-09T12:07:15+02:00
weight = 40
+++

The Admin Panel is a place for the Kubermatic administrators where they can manage the global settings that directly
impact all Kubermatic users. Admin rights can be granted from the admin panel itself and also from the kubectl by
setting the `spec.admin` field of the user object to `true`.

```bash
$ kubectl get user -o=custom-columns=INTERNAL_NAME:.metadata.name,NAME:.spec.name,EMAIL:.spec.email,ADMIN:.spec.admin
$ kubectl edit user ...
```

After logging in to the dashboard with an administrator you should be able to access the admin panel from the menu up
top.

![](/img/kubermatic/master/ui/admin_panel_access.png?height=300px&classes=shadow,border "Accessing the Admin Panel")

![](/img/kubermatic/master/ui/panel.png?height=350px&classes=shadow,border "Admin Panel")

The Admin Panel offers a wide set of features including but not limited to:

## [Manage Custom Links]({{< ref "./custom_links" >}})
Control the way custom links are displayed in the Kubermatic Dashboard. Choose the place that suits you best, whether
it is a sidebar, footer or a help & support panel.

## [Control Cluster Settings]({{< ref "./cluster_settings" >}})
Control number of initial Machine Deployment replicas, cluster deletion cleanup settings, availability of
Kubernetes Dashboard for user clusters and more.

## [Manage Dynamic Datacenters]({{< ref "./dynamic_datacenters" >}})
Use number of filtering options to find and control existing dynamic datacenters or simply create a new one.

## [Manage Administrators]({{< ref "./administrators" >}})
Manage all Kubermatic Dashboard Administrator in a single place. Decide who should be granted or revoked an administrator
privileges.

## [Manage Presets]({{< ref "./presets" >}})
Prepare custom provider presets for a variety of use cases. Control which presets will be visible to the users down to
the per-provider level.

## [OPA Constraint Templates]({{< ref "./opa_constraint_templates" >}})
Constraint Templates allow you to declare new Constraints. They are intended to work as a schema for Constraint parameters and enforce their behavior.
