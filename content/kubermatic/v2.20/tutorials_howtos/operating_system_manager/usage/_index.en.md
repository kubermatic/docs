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
apiVersion: kubermatic.k8c.io/v1
kind: KubermaticConfiguration
metadata:
  name: <<mykubermatic>>
  namespace: kubermatic
spec:
  # FeatureGates are used to optionally enable certain features.
  featureGates:
    OperatingSystemManager: true
```

**NOTE:** This doesn't enable or deploy OSM on the user cluster. It just ensures that all the required resources/pre-requisites are deployed on the seed.

## Cluster Level

### Via UI

Create a new cluster from the dashboard and toggle **Operating System Manager** feature on.

![Enable OSM during cluster creation](/img/kubermatic/v2.20/tutorials/operating_system_manager/osm_dashboard.png?height=450px&classes=shadow,border "Enable OSM during cluster creation")

**NOTE:** Once the cluster is created, OSM cannot be disabled or enabled.

### Via CLI

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

### Provisioning User Cluster Using OSM

Once KKP Operating System Manager(OSM) is enabled on seed and user cluster level, users have the possibility to provision user
clusters using OSM. To enable machine controller to pick up the right operating system profile, each machine deployment
needs to be annotated with the chosen profile. OSM ships default operating system profile by default, once the feature is
enabled on the user cluster, default OSPs will be available in the cluster namespace in the seed. For instance, if a users
would like to enable osm provisioning for a machine that runs Ubuntu as an operating system, they should a specific annotation
accordingly:

```yaml
apiVersion: "cluster.k8s.io/v1alpha1"
kind: MachineDeployment
metadata:
  annotations:
    "k8c.io/operating-system-profile": "osp-ubuntu"
```

**NOTE:** At the moment, it is  not possible to choose an operating system profile and attach to a machine deployment in the UI.