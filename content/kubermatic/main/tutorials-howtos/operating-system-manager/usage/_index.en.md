+++
title = "Enable Operating System Manager"
date = 2022-01-18T10:07:15+02:00
weight = 2
+++

Starting with KKP 2.21, OSM will be enabled by default for all the new user clusters. This can be configured using the dashboard or CLI.

## Via UI

### Enable OSM

Create a new cluster from the dashboard and toggle **Operating System Manager** feature on.

![Enable OSM during cluster creation](/img/kubermatic/master/tutorials/operating_system_manager/osm_dashboard.png?height=450px&classes=shadow,border "Enable OSM during cluster creation")

{{% notice note %}}
OSM cannot be disabled after cluster creation.
{{% /notice %}}

### Selecting OperatingSystemProfile

![Select OperatingSystemProfile](/img/kubermatic/master/tutorials/operating_system_manager/osm_select.png?height=450px&classes=shadow,border "Select OperatingSystemProfile")

## Via CLI

On cluster creation, set the following values in `Cluster` resource:

```yaml
apiVersion: kubermatic.k8c.io/v1
kind: Cluster
metadata:
  name: crh4xbxz5f
spec:
...
  enableOperatingSystemManager: true
...
```

## Custom OperatingSystemProfiles

To consume custom OperatingSystemProfiles. Users can create their custom OSPs in the seed namespace(kubermatic). They will be automatically synced to all the user-cluster namespaces.

## Migrating existing clusters

For migrating existing clusters, user can enable OSM using either the CLI or UI. That would enable OSM on the user cluster level. Although the machines will not be rotated automatically. To perform this rotation for existing MachineDeployments please follow the guide at [Rolling Restart MachineDeploments][rolling-restart].

[rolling-restart]: {{< ref "../../../cheat-sheets/rollout-machinedeployment" >}}
