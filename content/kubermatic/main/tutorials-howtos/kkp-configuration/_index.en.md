+++
title = "Configuration"
date = 2020-02-04T12:07:15+02:00
weight = 7

+++

## Overview

The `KubermaticConfiguration` CustomResourceDefinition is used for configuring the Kubermatic Kubernetes Platform (KKP) Operator and
replaces what previously was done with the `values.yaml` for the KKP Helm chart.

The following is an example configuration, showing all possible options. Note that all fields that you
don't define explicitly are always defaulted to these values.

```yaml
{{< readfile "kubermatic/main/data/kubermaticConfiguration.yaml" >}}
```

## Image Registries

Two kinds of settings control where KKP pulls its container images from.

The `dockerRepository` fields configure one image each. KKP provides them on `spec.api`, `spec.ui`, `spec.masterController`, `spec.seedController`, `spec.webhook` and `spec.util`. Each field takes a full repository path, for example `registry.corp/kkp/util`. KKP continues to manage the image tag, so an upgrade still picks the matching version.

`spec.userCluster.overwriteRegistry` replaces only the registry domain. The repository path stays unchanged. The image `quay.io/kubermatic/util:2.10.0` with `overwriteRegistry: mirror.corp` is pulled as `mirror.corp/kubermatic/util:2.10.0`. This setting applies to user cluster control plane components and addons in the `cluster-*` namespaces. It fits registries that mirror an upstream registry one to one.

Use a `dockerRepository` field when your registry follows its own layout. The util image is a shared toolbox container used by components on the seed and in user clusters. `spec.util.dockerRepository` defaults to `quay.io/kubermatic/util`. The seed-proxy and KubeOne jobs pull the configured repository unchanged. User cluster components pull it with `overwriteRegistry` applied, like every other user cluster image.
