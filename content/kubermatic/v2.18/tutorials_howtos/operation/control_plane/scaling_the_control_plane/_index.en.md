+++
title = "Scaling the Control Plane"
description = "As the load on the control plane depends on size of cluster, it might be necessary to scale up the control plane during runtime. Learn doing it."
date = 2018-07-24T12:07:15+02:00
weight = 0

+++

## Intro

As the load on the control plane depends on the size of the cluster, it might be necessary to scale up the control plane during runtime.

### Defaults

All control planes, managed by Kubermatic Kubernetes Platform (KKP), have the following defaults:

```yaml
apiserver:
  replicas: 1
  resources:
    limits:
      cpu: 500m
      memory: 1Gi
    requests:
      cpu: 100m
      memory: 256Mi
controllerManager:
  replicas: 1
  resources:
    limits:
      cpu: 250m
      memory: 512Mi
    requests:
      cpu: 100m
      memory: 100Mi
scheduler:
  replicas: 1
  resources:
    limits:
      cpu: 100m
      memory: 128Mi
    requests:
      cpu: 20m
      memory: 64Mi
etcd:
  # replicas cannot be configured - the etcd always runs with 3 members
  resources:
    limits:
     cpu: 100m
     memory: 1Gi
  requests:
    cpu: 50m
    memory: 256Mi
```

### Setting Custom Overrides

Custom settings can be applid by modifying the clusters `cluster.spec.componentsOverride` property:

```yaml
apiVersion: kubermatic.k8s.io/v1
kind: Cluster
metadata:
  name: rwhxp9j5j
spec:
  componentsOverride:
    apiserver:
      replicas: 3
      resources:
        limits:
          cpu: 2
          memory: 2Gi
        requests:
          cpu: 500m
          memory: 1Gi
    controllerManager: {}
    etcd: {}
    scheduler: {}
```

The above override will override the default settings for the API Server, but won't affect the other components.

To note here is that, specifying the `resources` override of a component will override all default `resources`. For example:

```yaml
apiVersion: kubermatic.k8s.io/v1
kind: Cluster
metadata:
  name: rwhxp9j5j
spec:
  componentsOverride:
    apiserver:
      replicas: 3
      resources: {}
    controllerManager: {}
    etcd: {}
    scheduler: {}
```

The above setting `cluster.spec.componentsOverride.apiserver.resources: {}` will lead to no resource limits/requests set on the API Server.
It is not possible therefore to only override a single resource setting.
