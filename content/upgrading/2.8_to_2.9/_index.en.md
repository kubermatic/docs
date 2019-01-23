+++
title = "From 2.8 to 2.9"
date = 2018-10-23T12:07:15+02:00
weight = 13
pre = "<b></b>"
+++

### CRD Migration

With v2.9 the Kubermatic chart won't contain any CustomResourceDefinitions. Upgrading the existing kubermatic
installation with new charts would result in all CRD's being deleted.

For this purpose we wrote a migration script. The script will:

- Manually delete installed kubermatic manifests (Except CustomResourceDefinitions)
- Remove the helm release ConfigMaps ([more information about Helm
  ConfigMaps](http://technosophos.com/2017/03/23/how-helm-uses-configmaps-to-store-data.html))
- Install the new kubermatic helm chart

### Enforcing floating IP's for OpenStack nodes

Until Kubermatic v2.9 all OpenStack nodes got assigned a floating IP. With v2.9 this behaviour changes, as floating IP's
are now optional by default. Within the "Add Node" dialog, the user can specific if a floating IP should be assigned or
not.

If the assignment of floating IP's is a requirement to ensure Node-> API server communication, the assignment can be
enforced within the datacenters.yaml:

```yaml
loodse-hamburg-1:
  location: Hamburg
  seed: europe-west3-c
  country: DE
  provider: openstack
  spec:
    openstack:
      auth_url: https://some-keystone:5000/v3
      availability_zone: hamburg-1
      region: hamburg
      dns_servers:
      - "8.8.8.8"
      - "8.8.4.4"
      images:
        ubuntu: "Ubuntu 18.04 LTS - 2018-08-10"
        centos: ""
        coreos: ""
      # Enforce the assignment for floating IP's for nodes of this datacenter
      enforce_floating_ip: true
```

### Alpha features

####  VerticalPodAutoscaler

Disabled by default. Can be enabled by setting the feature flag:

```
#Feature flag
kubermatic.controller.featureGates="VerticalPodAutoscaler=true"
```

This will instruct the kubermatic cluster controller to deploy VerticalPodAutoscaler resources for all control plane
components.

The
[VerticalPodAutoscaler](https://github.com/kubernetes/autoscaler/tree/master/vertical-pod-autoscaler#vertical-pod-autoscaler)
will then make sure that those pod will receive resource requests according to the actual usage.

Getting the VPA resources for a cluster: For example:

```bash
kubectl -n cluster-xxxxxx get vpa
```

If the VerticalPodAutoscaler notices a difference by 20% between the current usage and the specified resource request,
the pod will be deleted, so it gets recreated by the controller(ReplicaSet, StatefulSet). More details on the
VerticalPodAutoscaler can be found in the official repository:
https://github.com/kubernetes/autoscaler/tree/master/vertical-pod-autoscaler#vertical-pod-autoscaler

##### Issues

**API server downtime** In case the VPA needs to scale up the API server and the cluster only has 1 replica, the API
server won't be available for a short timeframe.

**New pods cannot be scheduled** In case the VPA deletes a Pod, the new Pod might be rescheduled in case the cluster has
not enough resources available for fulfil the pods resource request.
