+++
title = "Using a custom image registry"
date = 2024-05-31T07:00:00+02:00
+++

Except for custom workload, the kubelet requires access to the "pause" container. This container is
being used to keep the network namespace for each Pod alive.

By default the image `registry.k8s.io/pause:3.10` will be used. If that image won't be accessible from
the node, a custom image can be specified on the machine-controller:

```bash
-pause-image="192.168.1.1:5000/kubernetes/pause:3.10"
```

## Insecure registries

If nodes require access to insecure registries, all registries must be specified via a flag:

```bash
-node-insecure-registries="192.168.1.1:5000,10.0.0.1:5000"
```
