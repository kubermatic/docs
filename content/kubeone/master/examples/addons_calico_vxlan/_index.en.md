+++
title = "Calico VXLAN Addon"
date = 2021-02-10T12:00:00+02:00
weight = 3
enableToc = true
+++

It is possible to use CNI plugins that are not directly supported by the KubeOne. Here's an example for Calico.

## Example AWS kubeone config

```yaml
apiVersion: kubeone.k8c.io/v1beta2
kind: KubeOneCluster

versions:
  kubernetes: 1.22.5

cloudProvider:
  aws: {}

clusterNetwork:
  cni:
    external: {}

addons:
  enable: true
  addons:
    - name: calico-vxlan
      params:
        MTU: "0" # auto-detect MTU
```

You can use the following MTU values depending on your provider:

* `MTU: ""` — auto-detect MTU
* `MTU: "8951"` — use this if provider is AWS
* `MTU: "1400"` — use this if provider is OpenStack
* `MTU: "1410"` — use this if provider is GCE
