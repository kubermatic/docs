+++
title = "Tenants"
linkTitle = "Tenants"
date = 2023-10-27T10:07:15+02:00
weight = 2
+++

## Kubermatic Kubernetes Platform (Enterprise Edition Only)

For details, go through [KKP integration details]({{< relref "../../tutorials/kkp">}})

## Usage

For usage outside of KKP please follow the guide along. This guide assumes that the KubeLB manager cluster has been configured by following the [installation guide](../../installation/).

### KubeLB Manager configuration

Each cluster that wants load balancer services is treated as a unique **tenant** by KubeLB. This means that the KubeLB manager needs to be aware of the tenant clusters. To register a tenant in the KubeLB manager cluster, we need to create a namespace with the unique name of tenant and labelling it with **kubelb.k8c.io/managed-by: kubelb**.

We then create a restricted service account in the tenant cluster that will be used by the KubeLB CCM to communicate with the KubeLB manager cluster. Eventually, we need a `kubeconfig` that can be configured in the KubeLB CCM to communicate with the KubeLB manager cluster.

This script can be used for creating the required RBAC and generating the kubeconfig:

```sh
{{< readfile "kubelb/v1.0/data/create-kubelb-sa.sh" >}}
```

### KubeLB CCM configuration

For CCM, during installation we need to provide the `kubeconfig` that we generated in the previous step. Also, the `tenantName` field in the values.yaml should be set to the name of the tenant cluster.
