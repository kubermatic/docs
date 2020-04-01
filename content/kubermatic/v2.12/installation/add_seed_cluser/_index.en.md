+++
title = "Add Seed Cluster"
date = 2018-08-09T12:07:15+02:00
weight = 30
pre = "<b></b>"
+++

## Add New Seed Cluster to Existing Master

### 1. Install Kubernetes Cluster

First, you need to install Kubernetes cluster with some additional components. After the installation of Kubernetes you will need a copy of the `kubeconfig` to create a configuration for the new Kubermatic master/seed setup.

To aid in setting up the seed and master clusters, we provide [KubeOne](https://github.com/kubermatic/kubeone/) which can be used to set up a highly-available Kubernetes cluster. Refer to the [KubeOne readme](https://github.com/kubermatic/kubeone/) and [docs](https://github.com/kubermatic/kubeone/tree/master/docs) for details on
how to use it.

Please take note of the [recommended hardware and networking requirements](../../requirements/cluster_requirements/) before provisioning a cluster.

### 2. Install Kubermatic on Seed Cluster

First, you will need to update your `values.yaml` and use this file to update the `kubermatic` chart on the master cluster using `helm`. Afterwards, you will need a part of master `values.yaml` e.g. `values-seed.yaml` and install `Kubermatic` in the seed cluster with this values.

#### Edit Existing kubeconfig of the Kubermatic Master

Add a second cluster to the `kubeconfig` by providing the cluster, context and user information:

```yaml
apiVersion: v1
clusters:
- cluster:
  certificate-authority-data: ...
  name: ...
```

Add a second `context` to the `contexts` section:

```yaml
- context:
    cluster: ...
    user: ..
  name: ...
```

Add a second `user` to the `users` section:

```yaml
- name: ...
  user:
    client-certificate-data: ...
    client-key-data: ...
    token: ...
```

{{% notice note %}}
Make sure to provide static, long-lived credentials. Temporary credentials created by authentication providers (like on GKE or EKS) will not work.
{{% /notice %}}

#### Edit Existing `datacenters.yaml` of the Kubermatic Master

Add a second seed cluster to the `datacenters.yaml`. You can change some of the existing data centers to have a new seed. Now put the new base64 encoded values for `datacenters: ...` and `kubeconfig: ...` into your `values.yaml` with configuration for Kubermatic.

#### Create a Configuration for Kubermatic Seed

For the seed cluster, you need a stripped version of the `values.yaml`, you can see an example [here](https://github.com/kubermatic/kubermatic-installer/blob/release/v2.8/values.seed.example.yaml)

After the configuration file is created, you can install Kubermatic to the cluster. You will need some additional services:

* install `tiller` on it
* install `nodeport-proxy` when running on a cloud provider
* install `minio` for storing etcd snapshots
* install `kubermatic` like below

Install Kubermatic on the new seed cluster with the new `values-seed.yaml`:

```bash
helm upgrade --install --wait --timeout 300 --values values-seed.yaml --namespace kubermatic kubermatic charts/kubermatic/
```

Update the master cluster:

```bash
helm upgrade --install --wait --timeout 300 --values values.yaml --namespace kubermatic kubermatic charts/kubermatic/
```

The second seed cluster is now installed.
