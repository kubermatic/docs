+++
title = "KubermaticConfiguration"
date = 2020-02-04T12:07:15+02:00
weight = 20
pre = "<b></b>"
+++

## Overview

The KubermaticConfiguration CustomResourceDefinition is used for configuring the Kubermatic Operator and
replaces what previously was done with the `values.yaml` for the Kubermatic Helm chart.

{{% notice warning %}}
The operator is not yet considered ready for production use. Likewise, the CRD structure is not yet
finalized and changes may occur at any time.
{{% /notice %}}

The following is an example configuration, showing all possible options. Note that all fields that you
don't define explicitly are always defaulted to these values.

```yaml
{{< readfile "data/kubermaticConfiguration.yaml" >}}
```
