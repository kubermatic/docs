+++
title = "Kubermatic Kubernetes Platform"
date = 2023-10-27T10:07:15+02:00
weight = 15
enterprise = true
+++

## Kubermatic Kubernetes Platform (Enterprise Edition Only)

Starting with KKP v2.24, KubeLB Enterprise Edition is integrated into the Kubermatic Kubernetes Platform (KKP). This means that you can use KubeLB to provision load balancers for your KKP clusters. KKP will take care of configurations and deployments for you in the user cluster. Admins mainly need to create the KubeLB manager cluster and configure KKP to use it.

{{% notice note %}}
To use KubeLB enterprise offering, you need to have a valid license. Please [contact sales](mailto:sales@kubermatic.com) for more information.
{{% /notice %}}
