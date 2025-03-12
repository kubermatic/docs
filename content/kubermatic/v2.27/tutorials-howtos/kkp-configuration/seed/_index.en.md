+++
title = "Seed Object"
date = 2020-02-04T12:07:15+02:00
weight = 1

+++

## Overview

The `Seed` CustomResourceDefinition is used for configuring the Kubermatic
Kubernetes Platform (KKP) Datacenters.

The following is an example configuration, showing all possible options. Note
that all fields that you don't define explicitly are always defaulted to these
values.

```yaml
{{< readfile "kubermatic/main/data/seed.ee.yaml" >}}
```
