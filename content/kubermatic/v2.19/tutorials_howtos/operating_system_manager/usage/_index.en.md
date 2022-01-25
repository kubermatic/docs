+++
title = "Enable Operating System Manager"
date = 2022-01-18T10:07:15+02:00
weight = 2
+++

This page describes how to enable Operating System Manager for seed and for the cluster.

## Seed Level

Since OSM is in experimental phase, it is currently not enabled by default. To enable OSM, edit `KubermaticConfiguration` as follows:

* Enable feature gate for OperatingSystemManager in KubermaticConfiguration. Modify `spec.featureGates` and include `OperatingSystemManager` in the list.

```yaml
# Snippet, not a complete file!
apiVersion: operator.kubermatic.io/v1alpha1
kind: KubermaticConfiguration
metadata:
  name: <<mykubermatic>>
  namespace: kubermatic
spec:
  # FeatureGates are used to optionally enable certain features.
  featureGates:
    OperatingSystemManager:
      enabled: true
```

**NOTE:** This doesn't enable or deploy OSM on the user cluster. It just ensures that all the required resources/pre-requisites are deployed on the seed.

## Cluster Level

### Via UI

Create a new cluster from the dashboard and toggle **Operating System Manager** feature on.

![Enable OSM during cluster creation](/img/kubermatic/master/tutorials/operating_system_manager/osm_dashboard.png?height=450px&classes=shadow,border "Enable OSM during cluster creation")

**NOTE:** Once the cluster is created, OSM cannot be disabled or enabled.

### Via CLI

On cluster creation, set the following values in `Cluster` resource:

```yaml
apiVersion: kubermatic.k8s.io/v1
kind: Cluster
metadata:
  name: crh4xbxz5f
spec:
...
  enableOperatingSystemManager: true
...
```