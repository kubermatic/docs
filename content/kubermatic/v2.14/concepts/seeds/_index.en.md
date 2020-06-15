+++
title = "Seed Clusters"
date = 2019-10-21T12:07:15+02:00
weight = 10

+++

## Overview

The Seed CustomResourceDefinition replaces the legacy [`datacenters.yaml`]({{< ref "../datacenters" >}}) with
a more flexible, dynamic way of managing seed clusters. Seeds can be added and removed at runtime by simply
managing Seed resources inside the [master cluster]({{< ref "../architecture" >}}).

{{% notice note %}}
**Note:** This feature is **experimental** and not enabled by default.
{{% /notice %}}

### Example Seed

The following is an example Seed, showing all possible options.

```yaml
{{< readfile "kubermatic/2.14/data/seed.yaml" >}}
```
