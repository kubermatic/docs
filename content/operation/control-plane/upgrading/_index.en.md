+++
title = "Upgrading the control plane and the kubelets"
date = 2019-03-12T08:55:54+01:00
weight = 0
pre = "<b></b>"
+++

## Intro

A specific version of Kubernetes’ control plane typically supports a specific range of kubelet versions connected to
it. [Kubernetes Version and Version Skew Policy](https://kubernetes.io/docs/setup/version-skew-policy/) describes it
with a set of rules, where one of the most important ones is:

> kubelet must not be newer than kube-apiserver, and may be up to two minor versions older.

Kubermatic enforces this rule on its own by checking during each upgrade of the cluster's control plane or node's
kubelet that it is followed. Additionally, only compatible versions will be listed in the UI as available for upgrade.

### Upgrading the control plane

When listing compatible control plane versions it is checked that the upgrade is not restricted by any of the kubelets'
versions. If any of the available control plane versions are restricted by too low kubelet version then a warning will
be shown in the UI and this version will not be listed in the upgrade dialog:

![Warning about control plane version restricted by kubelet](/img/operation/control-plane/upgrade-warning.png)

### Upgrading the kubelets

When listing compatible kubelet versions it is checked that the versions are compatible with the current cluster's
control plane version. If any of the available kubelet versions is not compatible with the control plane version then
it will be skipped.
