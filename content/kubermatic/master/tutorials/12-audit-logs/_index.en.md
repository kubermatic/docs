+++
title = "Audit Logging"
date = 2020-04-02T14:50:15+02:00
weight = 120
+++

Audit Logging is one of key security features provided by Kubernetes. Once enabled in kube-api, it provides a chronological record of operations performed on the clusters by users, administrators and other cluster components.

Audit logging is also a key requirement of [Kubernetes CIS benchmark](https://www.cisecurity.org/benchmark/kubernetes/).

For more details, you can can refer to the [upstream documentation](https://kubernetes.io/docs/tasks/debug-application-cluster/audit/).

{{% notice note %}}
Kubernetes Audit Logging is introduced as a beta feature since **v1.11**.
{{% /notice %}}

### Kubermatic Support
Kubermatic provideds two levels of support for the Audit Logging:

* Audit Logging on user-cluster level
* Audit Logging on a Datacenter level

{{% notice note %}}
Kubernetes Audit Logging is optional and is not enabled by default, since it requires additional memory and storage resources, depending on the specific configuration used.
{{% /notice %}}

Once enabled, Kubermatic will use a [Log Backend](https://kubernetes.io/docs/tasks/debug-application-cluster/audit/#log-backend) and a minimal [Policy](https://kubernetes.io/docs/tasks/debug-application-cluster/audit/#audit-policy) by default:
```yaml
{{< readfile "data/policy.yaml">}}
```

This file is stored in a ConfigMap named `audit-config` on the [Seed Cluster](../../concepts/architecture/#seed-cluster) in your cluster Namespace. To modify the default policy, you can edit this ConfigMap using `kubectl`:

```bash
$ kubectl edit -n cluster-<YOUR CLUSTER ID> configmap audit-config
```


#### User-Cluster Level Audit Logging

To enable user-cluster level Audit cluster, simply enable `Audit Logging` in the Kubermatic dashboard `Create Cluster` page:

![Create Cluster](01-create-cluster.png)

For exiting clusters, you can go to the cluster page, edit your cluster and enable (or disable) `Audit Logging`:

![Edit Cluster](01-edit-cluster.png)

#### Datacenter Level Audit Logging

Kubermatic also supports enabling Audit Logging on the Datacenter level. In this case, the option is enforced on all user-clusters in the Datacenter. The user-cluster level flag is ignored in this case.

To enable this, you will need to edit your [datacenters.yaml](../../concepts/datacenters/) or your [Seed Cluster CRD](../../concepts/seeds/).

You need to add the following flag to your datacenter spec (for a full working version, refer to [Seed Cluster CRD](../../concepts/seeds/)):

```yaml
{{< readfile "data/audit_log.yaml" >}}
```
