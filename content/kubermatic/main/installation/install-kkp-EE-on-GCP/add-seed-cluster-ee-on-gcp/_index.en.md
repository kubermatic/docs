+++
title = "Add Seed Cluster for EE on GCP"
date = 2018-08-09T12:07:15+02:00
description = "Learn how to add a new seed cluster to an existing KKP (Enterprise Edition) master cluster on Google Cloud Platform (GCP)"
weight = 130
enterprise = true
+++

This document describes how a new seed cluster can be added to an existing KKP master cluster.

{{% notice note %}}
For smaller scale setups it's possible to use the existing master cluster as a seed cluster (a "shared"
cluster installation). In this case both master and seed components will run on the same cluster and in
the same namespace. It is however not possible to use the same cluster for multiple seeds.
{{% /notice %}}

Please refer to the [architecture]({{< ref "../../../architecture/" >}}) diagrams for more information
about the cluster relationships.

## Overview

The setup procedure for seed clusters happens in multiple stages:

1. You must setup the CRDs and Helm charts (preferably using the KKP installer, but can also be done manually)
1. You create a `Seed` resource on the master cluster.
1. The KKP Operator checks if the configured `Seed` cluster is valid and installs the KKP components like the
   seed-controller-manager. This is an automated process.

## Configure Cluster Backups

KKP performs regular backups of user clusters by snapshotting the etcd of each cluster. The default configuration
uses in-cluster object storage provided by [Minio](https://min.io). It can be installed using `minio` Helm chart
provided with the KKP installer.

If you wish to use a different S3-compatible solution for storage of backups, it can be configured within the
`KubermaticConfiguration` object. Refer to the
[KubermaticConfiguration documentation]({{< ref "../../../tutorials-howtos/kkp-configuration" >}}) for an example
of the `.spec.backup` fields and values. The following content assumes you're using the provided `minio` Helm chart.

### Prepare Minio configuration

Minio requires a storage class which will be used as a backend for the exposed object storage. You can view the
storage classes available on the cluster using the following command:

```bash
kubectl get storageclasses
```

```
#NAME                 PROVISIONER              AGE
#kubermatic-fast      kubernetes.io/gce-pd   195d
#kubermatic-backup    kubernetes.io/gce-pd   195d
#standard (default)   kubernetes.io/gce-pd   2y43d
```

It's recommended that Minio uses a separate storage class with a different location/security level, but you can also use the default one if you desire.

As Minio does not require any of the SSD's advantages, we can use HDD-backed storage. It's recommended that Minio uses
a separate storage class with a different location/security level. For a cluster running on Azure, an example class could
look as follows:

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: kubermatic-backup
provisioner: kubernetes.io/gce-pd
parameters:
  type: pd-ssd
```

To configure the storage class to use and the size of backing storage, edit `minio` section in your `values.yaml` file.
For more information about the Minio options, take a look at
[minio chart `values.yaml`](https://github.com/kubermatic/kubermatic/blob/main/charts/minio/values.yaml) and the
[min.io documentation - S3 gateway](https://docs.min.io/docs/minio-gateway-for-s3.html).

```yaml
minio:
  storeSize: '200Gi'
  # specified storageClass will be used as a storage provider for minio
  # which will be used store the etcd backup of the seed hosted user clusters
  storageClass: kubermatic-backup
  # access key/secret for the exposed minio S3 gateway
  credentials:
    # generated access key length should be at least 3 characters
    accessKey: "YOUR-ACCESS-KEY"
    # generated secret key length should be at least 8 characters
    secretKey: "YOUR-SECRET-KEY"
```

As a good practice, we also recommend installing the `s3-exporter` Helm chart, which provides metrics regarding user
cluster backups.

## Installation

The Kubermatic Installler is the recommended way to setup new seed clusters. A manual installation is possible, however
more work needs to be done.

### Using the Installer

Similar to how the master cluster can be installed with the installler, run the `deploy` command. You still need to
manually ensure that the StorageClass you configured for Minio exists already.

```bash
export KUBECONFIG=/path/to/seed-cluster/kubeconfig
./kubermatic-installer deploy kubermatic-seed --config kubermatic.yaml --helm-values values.yaml
```

The command above will take care of installing/updating the CRDs, setting up Minio and the S3-exporter and attempts
to provide you with the necessary DNS settings after the installation has completed.

Once the installer has completed, check the `kubermatic` namespace on the seed cluster, where the new controller managers
should be deployed automatically. If the deployment gets stuck, check the `kubermatic-operator` logs on the master
cluster.

### Manual Installation

Once the preparation for the cluster backup are done (setting up the StorageClass), install the Kubermatic CRDs using `kubectl`. The `charts` directory is part of the download archive on GitHub. Run the following command on the seed cluster:

```bash
kubectl replace -f charts/kubermatic-operator/crd/
```

After configuring the required options, you can install the charts:

```bash
helm --namespace minio upgrade --install --wait --values /path/to/your/helm-values.yaml minio charts/minio/
helm --namespace kube-system upgrade --install --wait --values /path/to/your/helm-values.yaml s3-exporter charts/s3-exporter/
```

## Add the Seed Resource

To connect the new seed cluster with the master, you need to create a kubeconfig Secret and a Seed resource
**on the master cluster**. This allows the KKP components in the master cluster to communicate with the seed cluster and
reconcile user-cluster control planes.

{{% notice warning %}}
To make sure that the kubeconfig stays valid forever, it must not contain temporary login tokens. Depending on the
cloud provider, the default kubeconfig that is provided may not contain username+password / a client certificate, but instead
try to talk to local token helper programs like `gcloud` for the Google Cloud (GKE).
These kubeconfig files **will not work** for setting up Seeds.
{{% /notice %}}

The `kubermatic-installer` tool provides a command `convert-kubeconfig` that can be used to prepare a kubeconfig for
usage in Kubermatic. The script will create a ServiceAccount in the seed cluster, bind it to the `cluster-admin` role
and then put the ServiceAccount's token into the kubeconfig file. Afterwards the file can be used in KKP.

```bash
./kubermatic-installer convert-kubeconfig <ORIGINAL-KUBECONFIG-FILE> > my-kubeconfig-file
```

The Seed resource then needs to reference the new kubeconfig Secret like so:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: kubeconfig-europe-west3
  namespace: kubermatic
type: Opaque
data:
  # You can use `base64 -w0 my-kubeconfig-file` to encode the
  # kubeconfig properly for inserting into this Secret.
  kubeconfig: <base64 encoded kubeconfig>

---
apiVersion: kubermatic.k8c.io/v1
kind: Seed
metadata:
  name: europe-west3
  namespace: kubermatic
spec:
  # these two fields are only informational
  country: DE
  location: Frankfurt

  # list of datacenters where this seed cluster is allowed to create clusters in
  # Example:
  # datacenters:
  #   gce-eu-west-3:
  #    country: DE
  #    location: "Frankfurt"
  #    spec:
  #      gcp:
  #        region: "europe-west3"
  #        regional: true
  #        zone_suffixes: [a,b,c]
  datacenters: {}

  # reference to the kubeconfig to use when connecting to this seed cluster
  kubeconfig:
    name: kubeconfig-europe-west3
    namespace: kubermatic
```

Refer to the [Seed CRD documentation]({{< ref "../../../tutorials-howtos/project-and-cluster-management/seed-cluster" >}}) for a
complete example of the Seed CustomResource and all possible datacenters.
¹
You can override the global [Expose Strategy]({{< ref "../../../tutorials-howtos/networking/expose-strategies">}}) at
Seed level if you wish to.

Apply the manifest above in the master cluster and KKP will pick up the new Seed and begin to reconcile it by installing the
required KKP components. You can watch the progress by using `kubectl` and `watch`:

```bash
kubectl apply -f seed-with-secret.yaml
```

```
#Secret/kubeconfig-kubermatic created.
#Seed/kubermatic created.
```

```bash
watch kubectl -n kubermatic get pods
```

```
#NAME                                                   READY   STATUS    RESTARTS   AGE
#kubermatic-api-55765568f7-br9jl                        1/1     Running   0          5m4s
#kubermatic-api-55765568f7-xbvz2                        1/1     Running   0          5m13s
#kubermatic-dashboard-5d784d586b-f46f8                  1/1     Running   0          35m
#kubermatic-dashboard-5d784d586b-rgl29                  1/1     Running   0          35m
#kubermatic-master-controller-manager-f58d4df59-w7rkz   1/1     Running   0          5m13s
#kubermatic-operator-7f6957869d-89g55                   1/1     Running   0          5m37s
#nodeport-proxy-envoy-6d8bb6fbff-9z57l                  2/2     Running   0          5m6s
#nodeport-proxy-envoy-6d8bb6fbff-dl58l                  2/2     Running   0          4m54s
#nodeport-proxy-envoy-6d8bb6fbff-k4gp8                  2/2     Running   0          4m44s
#nodeport-proxy-updater-7fd55f948-cll8n                 1/1     Running   0          4m44s
#seed-proxy-europe-west3-6dd5cc95cf-r6wvb               1/1     Running   0          80m
```

If you experience issues with the seed cluster setup, for example nothing happening in the `kubermatic` namespace,
check the Kubermatic Operator's logs on the master cluster, for example via `kubectl --namespace kubermatic logs -f kubermatic-operator-7f6957869d-89g55`.

## Update DNS

Depending on the chosen [Expose Strategy]({{< ref "../../../tutorials-howtos/networking/expose-strategies">}}), the control planes of all user clusters
running in the Seed cluster will be exposed by the `nodeport-proxy` or using services of type `NodePort` directly.
By default each user cluster gets a virtual domain name like `[cluster-id].[seed-name].[kubermatic-domain]`, e.g.
`hdu328tr.kubermatic.kubermatic.example.com` for the Seed from the previous step with `kubermatic.example.com` being the main domain
where the KKP dashboard/API are available.

A wildcard DNS record `*.[seed-name].[kubermatic-domain]` must be created. The target of the DNS wildcard record should be the
`EXTERNAL-IP` of the `nodeport-proxy` service in the `kubermatic` namespace or a set of seed nodes IPs.

### With LoadBalancers

When your cloud provider supports LoadBalancers, you can find the target IP by looking at the
`nodeport-proxy` Service:

```bash
kubectl -n kubermatic get services
```

```
#NAME             TYPE           CLUSTER-IP      EXTERNAL-IP    PORT(S)                      AGE
#nodeport-proxy   LoadBalancer   10.47.248.232   8.7.6.5        80:32014/TCP,443:30772/TCP   449d
```

The `EXTERNAL-IP` is what we need to put into the DNS record.

### Without LoadBalancers

Without a LoadBalancer, you will need to point to one or many of the seed cluster's nodes. You can get a
list of external IPs like so:

```bash
kubectl get nodes -o wide
```

```
#NAME                        STATUS   ROLES    AGE     VERSION    INTERNAL-IP   EXTERNAL-IP
#worker-node-cbd686cd-50nx   Ready    <none>   3h36m   v1.22.5    10.156.0.36   8.7.6.4
#worker-node-cbd686cd-59s2   Ready    <none>   21m     v1.22.5    10.156.0.14   8.7.6.3
#worker-node-cbd686cd-90j3   Ready    <none>   45m     v1.22.5    10.156.0.22   8.7.6.2
```

### DNS Record

Create an A record as needed pointing to the target:

```plain
*.europe-west3.kubermatic.example.com.   IN   A   8.7.6.5
```
