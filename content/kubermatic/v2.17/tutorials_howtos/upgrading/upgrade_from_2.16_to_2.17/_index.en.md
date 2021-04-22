+++
title = "Upgrading from 2.16 to 2.17"
date = 2020-06-09T11:09:15+02:00
weight = 90

+++

## [EE] End of support for `kubermatic` Helm Chart

After the Kubermatic Operator has been introduced as a beta in version 2.14, it is now the recommended way of
installing and managing KKP. This means that the `kubermatic` Helm chart was deprecated as of
version 2.15 and starting from version 2.17 it is not supported any longer.

The Kubermatic Operator does not support previously deprecated features like the `datacenters.yaml`
or the full feature set of the `kubermatic` chart's customization options. Instead, datacenters
have to be converted to `Seed` resources, while the chart configuration must be converted to a
`KubermaticConfiguration`. The Kubermatic Installer offers commands to perform these conversions
automatically.

Note that the following customization options are not yet supported in the Kubermatic Operator:

* `maxParallelReconcile` (always defaults to `10`)
* Node and Pod affinities, node selectors for the KKP components
* Worker goroutine count for the KKP components

Depending on your chosen installation method, a number of upgrade paths are documented:

* [Upgrade from Helm-based installations]({{< ref "." >}})
* [Upgrade from Operator-based installations]({{< ref "./kubermatic_operator" >}})
