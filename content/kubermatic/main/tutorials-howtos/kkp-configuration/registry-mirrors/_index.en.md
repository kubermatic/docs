+++
title = "Registry Mirrors"
date = 2025-03-11T10:07:15+02:00
weight = 8

+++

## Overview

Registry mirrors allow you to configure mirror endpoints for container registries to improve image pull performance, avoid rate limits, and increase reliability through fallback mirrors.

Container registry configuration can be applied at two levels:

- **Datacenter Level** (via Seed `NodeSettings`): Default settings for all clusters in a datacenter
- **Cluster Level** (via Cluster `ContainerRuntimeOpts`): Cluster-specific overrides

## Datacenter-Level Configuration

Configure registry mirrors at the datacenter level to provide defaults for all user clusters.

### Example: Configuring docker.io Mirror

`docker.io` registry has rate limits for unauthenticated requests. You can configure a caching proxy like [Google's mirror.gcr.io](https://cloud.google.com/artifact-registry/docs/pull-cached-dockerhub-images):

```yaml
apiVersion: kubermatic.k8c.io/v1
kind: Seed
metadata:
  name: <<exampleseed>>
  namespace: kubermatic
spec:
  ### ... content omitted for brevity
  datacenters:
    dc1:
      ### ... content omitted for brevity
      node:
        containerdRegistryMirrors:
          # A map of registries to use to render configs and mirrors for containerd registries
          registries:
            docker.io:
              # List of registry mirrors to use
              mirrors:
                - mirror.gcr.io
```

### Example: Multiple Mirrors for High Availability

Configure multiple mirrors per registry for automatic fallback:

```yaml
apiVersion: kubermatic.k8c.io/v1
kind: Seed
metadata:
  name: <<exampleseed>>
  namespace: kubermatic
spec:
  datacenters:
    dc1:
      node:
        containerdRegistryMirrors:
          registries:
            docker.io:
              mirrors:
                - https://mirror1.company.com
                - https://mirror2.company.com
                - mirror.gcr.io
            quay.io:
              mirrors:
                - https://quay-mirror.company.com
```

When configured this way, containerd attempts mirrors in order and falls back to the next if one fails, ensuring high availability.

## Cluster-Level Configuration

Override datacenter defaults for specific clusters using `ContainerRuntimeOpts`:

```yaml
apiVersion: kubermatic.k8c.io/v1
kind: Cluster
metadata:
  name: my-cluster
spec:
  containerRuntimeOpts:
    containerdRegistryMirrors:
      registries:
        docker.io:
          mirrors:
            - https://cluster-specific-mirror.company.com
            - mirror.gcr.io
```

Cluster-level configuration completely overrides datacenter-level settings for that cluster (not merged).

For other container runtime settings including:
- Insecure registries
- Registry mirrors
- Custom pause container images
- Non-root device ownership
- Legacy registry mirror format


See more for the [full example of Seed][seed-example] with comments and all possible
options.

[seed-example]: {{< ref "../seed" >}}
