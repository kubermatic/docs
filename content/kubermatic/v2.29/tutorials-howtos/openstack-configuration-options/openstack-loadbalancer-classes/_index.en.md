+++
title = "OpenStack LoadBalancer Classes"
date = 2025-10-20
weight = 1
+++

This guide provides a comprehensive overview of configuring and managing OpenStack LoadBalancer Classes in Kubermatic Kubernetes Platform (KKP).

OpenStack LoadBalancer Classes let you set up different load balancer configurations for your cluster to match various needs.

{{% notice info %}}
**Important:** LoadBalancer classes can only be configured at cluster creation. To modify them afterward, you must either recreate the cluster or manually update the cluster resource using `kubectl`. Changing classes post-creation may impact cluster network traffic.
{{% /notice %}}

## Configuring LoadBalancer Classes

LoadBalancer Classes can be defined during the creation of an OpenStack cluster:

1. Access the **Create Cluster** wizard in the Kubermatic Dashboard.
2. Choose **OpenStack** as your cloud provider.
3. Within the cluster configuration section, select **Configure LoadBalancer Classes**.

![Add LoadBalancer Class](./images/openstack-configure-classes.png?classes=shadow,border "Add LoadBalancer Class")

The LoadBalancer Classes dialog enables you to add and configure multiple classes:

![Configure LoadBalancer Classes](./images/openstack-modal.png?classes=shadow,border "Configure LoadBalancer Classes Dialog")

### Adding a LoadBalancer Class

Multiple LoadBalancer Classes can be created, each tailored to a specific application or use case within the cluster.

1. Click **Add LoadBalancer Class** in the configuration dialog.
2. Enter a unique **Class Name** (for example, `internal-lb` or `production-web`).
3. Specify the relevant configuration parameters according to your OpenStack environment's needs.
4. Click **Save** to confirm and add the configuration.


## Managing LoadBalancer Classes

From within the configuration dialog, you have the following management capabilities:

- **View Configurations**: Review all configured classes in an expandable overview.
- **Remove Configuration**: Delete any existing LoadBalancer class.


![Configure LoadBalancer Classes](./images/added-classes.png?classes=shadow,border "Configured LoadBalancer Classes")

The **total** number of defined classes is always displayed for reference.

![Configured Classes](./images/configured-count.png?classes=shadow,border "Number of Configured Classes")

{{% notice note %}}
If there are any inconsistencies in your LoadBalancer configurations—for example, due to changes in OpenStack presets, credentials, or datacenter selection—**all LoadBalancer class definitions will be automatically cleared**. This is to ensure configuration consistency and prevent conflicts. Please double-check your configurations after making such changes.
{{% /notice %}}

### Reviewing OpenStack Cloud Configuration

To inspect the current configuration of your OpenStack LoadBalancer Classes, use the following command (replace `$CLUSTER_NS` with your target cluster's namespace):

```bash
kubectl get secret cloud-config -n $CLUSTER_NS -o jsonpath={.data.config} | base64 -d
```

The output provides cloud config entries similar to the following, with a dedicated section for each LoadBalancer class:

```ini
[LoadBalancerClass "production-lb"]
floating-network-id = "xxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
floating-subnet-id = "yyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy"
floating-subnet-tags = "placeholder-tags"
network-id = "zzzzzz-zzzz-zzzz-zzzz-zzzzzzzzzzzz"
subnet-id = "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"
member-subnet-id = "bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb"
```

## Using LoadBalancer Classes with Cluster Templates

When you create a cluster template that includes LoadBalancer class definitions, these configurations are persisted within the template and will be applied automatically to any cluster created from it.

{{% notice note %}}
Note: LoadBalancer classes are not displayed in the Dashboard UI when creating a cluster from a template, but they are saved and can be viewed in the ClusterTemplate Custom Resource Definition (CRD).
{{% /notice %}}

Retrieve and review the configurations in your cluster template as follows (replace `CLUSTER_TEMPLATE_ID` with your template's identifier):

```bash
kubectl get clustertemplate CLUSTER_TEMPLATE_ID -o yaml
```

Example snippet from a template specification:

```yaml
spec:
  cloud:
    openstack:
      loadBalancerClasses:
        - name: production-lb
          config:
            floatingNetworkID: xxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
            floatingSubnetID: yyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy
            floatingSubnetTags:
              - tag-1
              - tag-2
            networkID: zzzzzz-zzzz-zzzz-zzzz-zzzzzzzzzzzz
            subnetID: aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa
            memberSubnetID: bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb
```