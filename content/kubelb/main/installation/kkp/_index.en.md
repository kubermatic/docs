+++
title = "Kubermatic Kubernetes Platform Integration"
linkTitle = "KKP Integration"
date = 2023-10-27T10:07:15+02:00
description = "Enable and configure KubeLB for user clusters in the Kubermatic Kubernetes Platform."
weight = 50
enterprise = true
aliases = ["/kubelb/main/tutorials/kkp/"]
+++

KubeLB Enterprise Edition is integrated into the Kubermatic Kubernetes Platform (KKP), so KubeLB can provision load balancers for KKP clusters. KKP handles configuration and deployment in the user cluster. Admins mainly need to create the KubeLB management cluster and configure KKP to use it.

## Prerequisites

To configure KubeLB for KKP, you first need a KubeLB management cluster and its Kubeconfig. The KKP integration requires access to certain resources like Tenants, LoadBalancer, and Routes. Instead of the admin Kubeconfig, use a Kubeconfig with the necessary RBAC permissions to access the required resources.

1. Create a KubeLB management cluster with the following settings in the `values.yaml` file for the `kubelb-management` chart:

```yaml
kkpintegration.rbac: true
```

2. Install the [kubectl-view-serviceaccount-kubeconfig](https://github.com/superbrothers/kubectl-view-serviceaccount-kubeconfig-plugin?tab=readme-ov-file#install-the-plugin) plugin.
3. Use the following command to generate a Kubeconfig for the service account `kubelb-manager` in the `kubelb` namespace:

```bash
kubectl view-serviceaccount-kubeconfig kubelb-kkp -n kubelb
```

4. Use the output of the previous command to create a file `kubelb-secret.yaml` with the required secret:

```bash
kubectl create secret generic kubelb-management-cluster \
  --namespace=kubermatic \
  --from-literal=kubeconfig="$(kubectl view-serviceaccount-kubeconfig kubelb-kkp -n kubelb)" \
  --dry-run=client -o yaml > kubelb-secret.yaml
```

5. Apply the file `kubelb-secret.yaml` to the `kubermatic` namespace in your KKP cluster.

```bash
kubectl apply -f kubelb-secret.yaml
```

For further configuration, see the [official KKP documentation](https://docs.kubermatic.com/kubermatic/latest/tutorials-howtos/kubelb).

{{% notice note %}}
The KubeLB Enterprise offering requires a valid license. [Contact sales](mailto:sales@kubermatic.com) for more information.
{{% /notice %}}
