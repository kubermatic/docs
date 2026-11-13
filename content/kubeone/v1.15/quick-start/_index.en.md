+++
title = "Quick Start"
date = 2026-01-16T20:30:00+01:00
weight = 1
+++

The fastest way to get a local development all-in-one KubeOne Kubernetes cluster on a fresh Linux machine is to use the
installation script:

```bash
curl -sfL get.kubeone.io | sh
kubeone local
# Wait
export KUBECONFIG=local-kubeconfig
kubectl get pod -A
```

{{% notice warning %}}
`kubeone local` will install services globally! Run it only on a machine that is not used otherwise.
{{% /notice %}}

See more information about [all-in-one Cluster](local-guide).

[local-guide]: {{< ref "../guides/local" >}}
