+++
title = "Kubermatic Kubernetes Platform Integration"
date = 2023-10-27T10:07:15+02:00
weight = 15
enterprise = true
+++

## Kubermatic Kubernetes Platform (Enterprise Edition Only)

Starting with KKP v2.24, KubeLB Enterprise Edition is integrated into the Kubermatic Kubernetes Platform (KKP). This means that you can use KubeLB to provision load balancers for your KKP clusters. KKP will take care of configurations and deployments for you in the user cluster. Admins mainly need to create the KubeLB manager cluster and configure KKP to use it.

{{% notice warning %}}
For KubeLB v1.1 and above, you must be using KKP v2.26 or higher for proper integration. KubeLB v1.1 introduces `Tenant` API to manage tenants which is not supported below KKP v2.26.
{{% /notice %}}

{{% notice note %}}
To use KubeLB enterprise offering, you need to have a valid license. Please [contact sales](mailto:sales@kubermatic.com) for more information.
{{% /notice %}}
