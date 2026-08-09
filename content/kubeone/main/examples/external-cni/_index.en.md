+++
title = "External CNI"
date = 2025-07-10T12:00:00+02:00
weight = 3
+++

It is possible to use CNI plugins that are not directly supported by the
KubeOne. Here's an example for Flannel.

## Example KubeOne config

Create a custom addon to get the NS with the required label: `addons/kube-flannel-namespace/ns.yml`
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: kube-flannel
  labels:
    pod-security.kubernetes.io/enforce: privileged
```

KubeOneCluster config
```yaml
apiVersion: kubeone.k8c.io/v1beta2
kind: KubeOneCluster

versions:
  kubernetes: 1.36.3

clusterNetwork:
  cni:
    external: {}

addons:
  enable: true
  path: "./addons"
  addons:
  - name: default-storage-class

helmReleases:
  - chart: flannel
    repoURL: https://flannel-io.github.io/flannel/
    namespace: kube-system
    version: v0.28.9
```
