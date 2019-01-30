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
The script will:

- Manually delete installed kubermatic manifests (Except CustomResourceDefinitions)
- Remove the helm release ConfigMaps ([more information about Helm ConfigMaps](http://technosophos.com/2017/03/23/how-helm-uses-configmaps-to-store-data.html))
- Install the new kubermatic helm chart

The script is located inside the Kubermatic helm chart & must be executed before the chart upgrade:
https://github.com/kubermatic/kubermatic-installer/blob/release/v2.9/charts/kubermatic/migrate/migrate-kubermatic-chart.sh

### Updating Helm Charts

#### Ark

Ark 0.10 requires significant changes to the chart configuation in your `values.yaml`. Please consult the `values.yaml` inside
the chart to learn more about the new configuration structure. For exsiting backups, Heptio provides a script to migrate them.
Consult the [official upgrade guide](https://heptio.github.io/ark/v0.10.0/upgrading-to-v0.10) for more information.

#### cert-manager

When updating an existing cert-manager, make sure to manually label the `cert-manager` namespace:

```bash
kubectl label namespace cert-manager certmanager.k8s.io/disable-validation=true
```

Without this label, the new cert-manager will not be able to create its own PKI and the pods will crashloop because `webhook-tls`
and `webhook-ca` secrets cannot be found.

#### node-exporter

The new version 0.17 has made significant changes to the metric names it provides. Consult the [official guidelines](https://github.com/prometheus/node_exporter/blob/master/docs/V0_16_UPGRADE_GUIDE.md) to learn more about the new names and adjust
your recording and alerting rules as needed. Note that Kubermatic does not install the recording rules to keep the old metric names
intact, so you will notice gaps in the Grafana charts after you updated.


### Enforcing floating IP's for OpenStack nodes

Until Kubermatic v2.9 all OpenStack nodes got assigned a floating IP.
With v2.9 this behaviour changes, as floating IP's are now optional by default.
Within the "Add Node" dialog, the user can specific if a floating IP should be assigned or not.

If the assignment of floating IP's is a requirement to ensure Node-> API server communication, the assignment can be enforced within the datacenters.yaml:
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

Disabled by default.
Can be enabled by setting the feature flag:
```
#Feature flag
kubermatic.controller.featureGates="VerticalPodAutoscaler=true"
```

This will instruct the kubermatic cluster controller to deploy VerticalPodAutoscaler resources for all control plane components.

The [VerticalPodAutoscaler](https://github.com/kubernetes/autoscaler/tree/master/vertical-pod-autoscaler#vertical-pod-autoscaler) will then make sure that those pod will receive resource requests according to the actual usage.

Getting the VPA resources for a cluster:
For example:
```bash
kubectl -n cluster-xxxxxx get vpa
```

If the VerticalPodAutoscaler notices a difference by 20% between the current usage and the specified resource request, the pod will be deleted, so it gets recreated by the controller(ReplicaSet, StatefulSet).
More details on the VerticalPodAutoscaler can be found in the official repository: https://github.com/kubernetes/autoscaler/tree/master/vertical-pod-autoscaler#vertical-pod-autoscaler

##### Issues

**API server downtime**
In case the VPA needs to scale up the API server and the cluster only has 1 replica, the API server won't be available for a short timeframe.

**New pods cannot be scheduled**
In case the VPA deletes a Pod, the new Pod might be rescheduled in case the cluster has not enough resources available for fulfil the pods resource request.
