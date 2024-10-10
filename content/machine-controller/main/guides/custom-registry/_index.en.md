+++
title = "Using a custom image registry"
date = 2024-05-31T07:00:00+02:00
+++

Except for custom workload, the kubelet requires access to the "pause" container. This container is
being used to keep the network namespace for each Pod alive.

By default the image `registry.k8s.io/pause:3.10` will be used. If that image won't be accessible from
the node, a custom image can be specified on the machine-controller:

```bash
-node-pause-image="192.168.1.1:5000/kubernetes/pause:3.10"
```

## Kubelet images

### Flatcar Linux

For Flatcar Linux nodes, [kubelet][1] image must be accessible as well. This is due to the fact
that kubelet is running as a Docker container.

By default the image `quay.io/kubermatic/kubelet` will be used. If that image won't be accessible
from the node, a custom image can be specified on the machine-controller:

```bash
# Do not set a tag. The tag depends on the used Kubernetes version of a machine.
-node-kubelet-image="192.168.1.1:5000/my-custom/kubelet-amd64"
```

# Insecure registries

If nodes require access to insecure registries, all registries must be specified via a flag:

```bash
-node-insecure-registries="192.168.1.1:5000,10.0.0.1:5000"
```

[1]: https://quay.io/kubermatic/kubelet
