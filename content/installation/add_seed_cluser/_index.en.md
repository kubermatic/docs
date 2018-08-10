+++
title = "Add Seed Cluster"
date = 2018-08-09T12:07:15+02:00
weight = 6
pre = "<b></b>"
+++

## Add new seed cluster to existing master

### Install kubernetes cluster

First you need to install kubernetes cluster with some additional components. You can use [installation guide](../install_kubermatic) for it.

* install `tiller` on it
* install `nodeport-proxy` when running on a cloud provider
* install `minio` for storing etcd snapshots
* install `kubermatic` like below

After the installation of kubernetes you will need  a copy of `kubeconfig` to create a configuration for the new kubermatic master/seed setup.

### Install kubermatic for seed cluster

First you will need to update `values.yaml` and use this file to update `kubermatic master` using `helm`.
Second you will need a part of master `values.yaml` e.g. `values-seed.yaml` and install `kubermatic` to the seed cluster with this values.

#### Edit existing kubeconfig of the kubermatic master

Add a second `cluster` to the kubeconfig (first seed is where the master component is running), this is our `seed cluster`. You can copy the values from kubeconfig of cluster you have just created.
```
apiVersion: v1
clusters:
- cluster:
  certificate-authority-data: ...
  name: ...
```

Add a second `context` to the `contexts` area:
```
- context:
    cluster: ...
    user: ..
  name: ...
```

Add a second `user` to the `users` area:
```
- name: ...
  user:
    client-certificate-data: ...
    client-key-data: ...
    token: ...
```

#### Edit existing datacenters.yaml of the kubermatic master

Add a second seed cluster to the `datacenters.yaml`. You can change some of the existing data centers to have a new seed. Now put the new `base64` encoded values for `datacenters: ...` and `kubeconfig: ...` to `values.yaml` with configuration for kubermatic.

#### Create a configuration for kubermatic seed

Create a copy of the main `values.yaml`, name it `values-seed.yaml` and leave only this parts:
```
kubermatic:
  docker:
    secret: "..."
  quay:
    secret: "..."
  auth:
    tokenIssuer: "..."
    clientID: "..."
    skipTokenIssuerTLSVerify: "false"
  datacenters: "..."
  kubeconfig: "..."
  domain: ""
  controller:
    datacenterName: "..." # the name of the second seed here

# if needed
minio:
  storeSize: "100Gi"
  credentials:
    accessKey: "..."
    secretKey: "..."
```

Install `kubermatic` on the new seed cluster with the new `values-seed.yaml`:
```
helm upgrade --install --wait --timeout 300 --values values-seed.yaml --namespace kubermatic kubermatic charts/kubermatic/
```

Update the master cluster:
```
helm upgrade --install --wait --timeout 300 --values values.yaml --namespace kubermatic kubermatic charts/kubermatic/
```

The second seed cluster is now installed.
