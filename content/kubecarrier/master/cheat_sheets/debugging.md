---
title: Debugging KubeCarrier
weight: 10
date: 2021-02-10T11:30:00+02:00
---

## Debugging KubeCarrier Installation

KubeCarrier is installed into the `kubecarrier-system` Namespace by default.

If a step in the [installation via the kubectl plugin]({{< relref "../tutorials_howtos/installation" >}}) is timing out, you should check the logs of the respective component:

### KubeCarrier Operator
```bash
$ kubectl kubecarrier setup
0.03s ✔  Create "kubecarrier-system" Namespace
10.09s ✖  Deploy KubeCarrier Operator
Error: deploying kubecarrier operator: timed out waiting for the condition

$ kubectl get po -n kubecarrier-system
NAME                                          READY   STATUS   RESTARTS   AGE
kubecarrier-operator-manager-7d4b8f74-mgbgn   0/1     Error    2          32s

$ kubectl logs -n kubecarrier-system kubecarrier-operator-manager-7d4b8f74-mgbgn
[...]
Error: running manager: no matches for kind "Issuer" in version "cert-manager.io/v1alpha2"
[...]
```

In this case, the cert-manager was not installed before installing KubeCarrier.

### KubeCarrier Controller Manager
```bash
$ kubectl kubecarrier setup
0.03s ✔  Create "kubecarrier-system" Namespace
0.19s ✔  Deploy KubeCarrier Operator
60.09s ✖  Deploy KubeCarrier
Error: deploying kubecarrier: timed out waiting for the condition

$ kubectl get po -n kubecarrier-system
NAME                                                      READY   STATUS             RESTARTS   AGE
kubecarrier-manager-controller-manager-56bfd4dcbd-8rg4l   1/1     CrashLoopBackOff   0          11m
kubecarrier-operator-manager-7d4b8f74-vfsxl               1/1     Running            0          11m

$ kubectl logs -n kubecarrier-system kubecarrier-manager-controller-manager-56bfd4dcbd-8rg4l
```

An error here may suggest a bug, or incompatibility with your system. Please open a [Github Issue](https://github.com/kubermatic/kubecarrier/issues) with this log.
