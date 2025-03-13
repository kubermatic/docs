+++
title = "Registry Mirrors"
date = 2025-03-11T10:07:15+02:00
weight = 8

+++

## docker.io Pull Rate Limitations

`docker.io` registry introduced pretty low rate limits for unauthenticated
requests. To ensure uninterrupted workloads it's possible to configure the
`Seed` in a way that docker.io registry will be used throguth the caching proxy.

### Configuring Public Pull-through Caching Proxy

Google has launched [caching public images proxy mirror.gcr.io](https://cloud.google.com/artifact-registry/docs/pull-cached-dockerhub-images).
Let's configure KKP to use it.

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
                - mirror.gcr.io```
```

See more for the [full example of Seed][seed-example] with comments and all possible
options.

[seed-example]: {{< ref "../seed" >}}
