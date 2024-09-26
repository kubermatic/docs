+++
title = "Vertical Pod Autoscaler integration with KKP"
date = 2024-09-25T14:07:10+02:00
weight = 9
+++

This section explains how Kubernetes Vertical Pod Autoscaler helps in a scaling the control plane components for user-clusters with rising load on that user-cluster.

## What is a Vertical Pod Autoscaler in Kubernetes?
[Vertical Pod Autoscaler](https://github.com/kubernetes/autoscaler/tree/master/vertical-pod-autoscaler) (VPA) frees users from the necessity of setting up-to-date resource limits and requests for the containers in their pods. When configured, it will set the requests automatically based on usage and thus allow proper scheduling onto nodes so that appropriate resource amount is available for each pod. It will also maintain ratios between limits and requests that were specified in initial containers configuration.

Unlike HPA, VPA does not bundled with kubernetes itself. It must get installed in the cluster separately.

## KKP Components controllable via VPA
KKP natively integrates VPA resource creation, reconciliation and management for all user-cluster control plane components. This allows these components to have optimal resource allocations - which can grow with growing cluster's needs. This reduces administration burden on KKP administrators.

Components controlled by VPA are:
1. apiserver
1. controller-manager
1. etcd
1. kube-state-metrics
1. machine-controller
1. machine-controller-webhook
1. prometheus
1. scheduler

All these components have default resources allocated by KKP. You can either use [`componentsOverride` section](../../../tutorials-howtos/operation/control-plane/scaling-the-control-plane/#setting-custom-overrides) of cluster resource to override the resources manually, or let VPA handle it for you!

> Note: If you enable VPA and add `componentsOverride` block as well for a given cluster to specify resources, `componentsOverride` takes precedence.

## How to enable VPA in KKP
To enable VPA controlled control-plane components for user-clusters, we just need to turn on a featureFlag in Kubermatic Configuration.
```
spec:
  featureGates:
    VerticalPodAutoscaler: true
```
This installs necessary VPA components in `kube-system` namespace of each seed. It also create VPA custom resources for each of the control-plane components as noted above.

## Customizing VPA installation
You can customize various aspects of VPA deployments themselves (i.e. admissionController, recommender and updater) via [KKP configuration](../../../tutorials-howtos/kkp-configuration/)
