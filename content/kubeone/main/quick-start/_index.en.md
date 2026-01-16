+++
title = "Quick Start"
date = 2026-01-16T20:30:00+01:00
weight = 1
+++

The fastest way to deploy a KubeOne Kubernetes cluster is to use the installation script:

```bash
curl -sfL get.kubeone.io | sh
kubeone local
# Wait 
export KUBECONFIG=local-kubeconfig
kubectl get pod -A
```

Check out, 
[All-in-one Cluster]({{< ref "../guides/local" >}}).
