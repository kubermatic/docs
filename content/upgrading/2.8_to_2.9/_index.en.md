+++
title = "From 2.8 to 2.9"
date = 2018-10-23T12:07:15+02:00
weight = 13
pre = "<b></b>"
+++

### CRD Migration

With v2.9 the Kubermatic chart wont contain any CustomResourceDefinitions.
Upgrading the existing kubermatic installation with new charts would result in all CRD's being deleted.

For this purpose we wrote a migration script.
The script will mainly:
- Manually delete installed kubermatic manifests (Except CustomResourceDefinitions)
- Remove the helm release ConfigMaps ([more information about Helm ConfigMaps](http://technosophos.com/2017/03/23/how-helm-uses-configmaps-to-store-data.html))
- Install the new kubermatic helm chart

### Alpha features

With kubermatic v2.9 a few new features got introduced as Alpha.
To activate those features, the corresponding feature flags must be explicitly enabled.

####  VerticalPodAutoscaler

Disabled by default.
Can be enabled by setting the feature flag:
```
#Feature flag
kubermatic.controller.featureGates="VerticalPodAutoscaler=true"
```

This will instruct the kubermatic cluster controller to deploy VerticalPodAutoscaler resources for all control plane components.
For example:
```yaml
apiVersion: autoscaling.k8s.io/v1beta1
kind: VerticalPodAutoscaler
metadata:
  name: apiserver
  namespace: cluster-z2f6xjz9ng
spec:
  resourcePolicy:
    containerPolicies:
    - containerName: openvpn-client
      maxAllowed:
        cpu: 100m
        memory: 256Mi
      minAllowed:
        cpu: 5m
        memory: 16Mi
    - containerName: dnat-controller
      maxAllowed:
        cpu: 100m
        memory: 512Mi
      minAllowed:
        cpu: 5m
        memory: 16Mi
    - containerName: apiserver
      maxAllowed:
        cpu: "2"
        memory: 4Gi
      minAllowed:
        cpu: 100m
        memory: 256Mi
  selector:
    matchLabels:
      app: apiserver
  updatePolicy:
    updateMode: Auto
```

The [VerticalPodAutoscaler](https://github.com/kubernetes/autoscaler/tree/master/vertical-pod-autoscaler#vertical-pod-autoscaler) will then make sure that those pod will receive resource requests according to the actual usage.

If the VerticalPodAutoscaler notices a difference by 20% between the current usage and the specified resource request, the pod will be deleted, so it gets recreated by the controller(ReplicaSet, StatefulSet). 
More details on the VerticalPodAutoscaler can be found in the official repository: https://github.com/kubernetes/autoscaler/tree/master/vertical-pod-autoscaler#vertical-pod-autoscaler

#### Issues

**API server downtime**
In case the VPA needs to scale up the API server and the cluster only has 1 replica, the API server won't be available for a short timeframe. 

**New pods cannot be scheduled**
In case the VPA deletes a Pod, the new Pod might be rescheduled in case the cluster has not enough resources available for fulfil the pods resource request.
