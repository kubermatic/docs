+++
title = "Cluster Defaulting"
date = 2021-08-02T14:07:15+02:00
weight = 20

+++

This section describes the usage of cluster templates for a seed.

Cluster templates are designed to standardize and simplify the creation of Kubernetes clusters. A cluster template is a
reusable cluster template object. At seed level, cluster templates are used to set default values for new created clusters.

## Defaulting Cluster Template

Some required values for new clusters are defaulted by KKP.

To adjust the defaulting behavior to fit your needs it is possible to define a `defaultClusterTemplate` in a seed object.

This template will merge with the input made by the user and only adjust fields that are not set.
KKP always provides default values for mandatory fields, even if they are not specified in the template.

`defaultClusterTemplate` expects a name of a `ClusterTemplate` with label `scope: seed` to be existent in the seed cluster.

Example ClusterTemplate:

```yaml

apiVersion: kubermatic.k8c.io/v1
kind: ClusterTemplate
metadata:
  labels:
    name: seed-defaults
    scope: seed
  name: seed-defaults
  namespace: kubermatic
credential: ""
spec:
  auditLogging: {}
  cloud:
    providerName: ""
    dc: byo-europe-west3-c
  clusterNetwork:
    dnsDomain: ""
    pods:
      cidrBlocks: []
    proxyMode: "ipvs"
    services:
      cidrBlocks: []
  componentsOverride:
    apiserver: {}
    controllerManager:
      leaderElection: {}
    etcd:
      clusterSize: 3
    prometheus: {}
    scheduler:
      leaderElection: {}
    nodePortProxyEnvoy: {}
  containerRuntime: containerd
  enableUserSSHKeyAgent: true
  exposeStrategy: Tunneling
  mla:
    loggingEnabled: true
    monitoringEnabled: true
  oidc: {}
  opaIntegration: {}
  version: 1.21.3
  humanReadableName: "SeedDefaults"
  pause: false
```

{{% notice warning %}}
Cloud provider specific configurations are not allowed in the default Cluster Template.
{{% /notice %}}
