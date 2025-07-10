+++
title = "External CNI"
date = 2025-07-10T12:00:00+02:00
weight = 3
+++

It is possible to use CNI plugins that are not directly supported by the
KubeOne. Here's an example for Flannel.

## Example KubeOne config

```yaml
apiVersion: kubeone.k8c.io/v1beta2
kind: KubeOneCluster

versions:
  kubernetes: 1.33.2

clusterNetwork:
  cni:
    external: {}

addons:
  addons:
  - name: default-storage-class

helmReleases:
  - chart: flannel
    repoURL: https://flannel-io.github.io/flannel/
    namespace: kube-system
    version: v0.27.0
```
