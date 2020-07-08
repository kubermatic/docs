+++
title = "Add Seed Cluster"
date = 2018-08-09T12:07:15+02:00
weight = 30

+++

This document describes how a new seed cluster can be added to an existing Kubermatic master cluster.

{{% notice note %}}
For smaller scale setups it's also possible to use the existing master cluster as a seed cluster (a "shared"
cluster installation). In this case both master and seed components will run on the same cluster and in
the same namespace. You can skip the first step and directly continue with installing the seed dependencies.
{{% /notice %}}

Plese refer to the [architecture]({{< ref "../../concepts/architecture" >}}) diagrams for more information
about the cluster relationships.

### 1. Install Kubernetes Cluster

First, you need to install a Kubernetes cluster with some additional components. After the installation of
Kubernetes you will need a copy of the `kubeconfig` to create a configuration for the new Kubermatic
master/seed setup.

To aid in setting up the seed and master clusters, we provide [KubeOne](https://github.com/kubermatic/kubeone/),
which can be used to set up a highly-available Kubernetes cluster. Refer to the [KubeOne readme](https://github.com/kubermatic/kubeone/)
and [docs](https://github.com/kubermatic/kubeone/tree/master/docs) for details on how to use it.

Please take note of the [recommended hardware and networking requirements](../../requirements/cluster_requirements/)
before provisioning a cluster.

### 2. Install Kubermatic Dependencies

When using Helm 2, install Tiller into the seed cluster first:

```bash
kubectl create namespace kubermatic
kubectl create serviceaccount -n kubermatic tiller
kubectl create clusterrolebinding tiller-cluster-role --clusterrole=cluster-admin --serviceaccount=kubermatic:tiller
helm --service-account tiller --tiller-namespace kubermatic init
```

#### Cluster Backups

Kubermatic performs regular backups of user cluster by snapshotting the etcd of each cluster. By default these backups
are stored locally inside the cluster, but they can be reconfigured to work with any S3-compatible storage.
The in-cluster storage is provided by [Minio](https://min.io/) and the accompanying `minio` Helm chart.

If your cluster has no default storage class, it's required to configure a class explicitely for Minio. You can check
the cluster's storage classes via:

```bash
kubectl get storageclasses
#NAME                 PROVISIONER            AGE
#kubermatic-fast      kubernetes.io/gce-pd   195d
#standard (default)   kubernetes.io/gce-pd   2y43d
```

{{% notice note %}}
Minio does not use `kubermatic-fast` because it does not require SSD speeds. A larger HDD is preferred.
{{% /notice %}}

To configure the storage class and size, extend your `values.yaml` like so:

```yaml
minio:
  storeSize: '200Gi'
  storageClass: hdd
```

It's also advisable to install the `s3-exporter` Helm chart, as it provides basic metrics about user cluster backups.

#### Install Charts

With this you can install the chart:

```bash
cd kubermatic-installer
helm --tiller-namespace kubermatic upgrade --install --values /path/to/your/helm-values.yaml --namespace minio minio charts/minio/
helm --tiller-namespace kubermatic upgrade --install --values /path/to/your/helm-values.yaml --namespace s3-exporter s3-exporter charts/s3-exporter/
```

### 3. Create Seed Resource

To connect the new seed cluster with the master, you need to create a kubeconfig Secret and a Seed resource
**in the master cluster**.

{{% notice warning %}}
Do not install the `kubermatic-operator` chart into seed clusters. It's possible to run master and seed in the same
Kubernetes cluster, but this still means only a single operator is deployed into the shared cluster.
{{% /notice %}}

Make sure the kubeconfig contains static, long-lived credentials. Some cloud providers use custom authentication providers
(like GKE using `gcloud` and EKS using `aws-iam-authenticator`). Those will not work in Kubermatic’s usecase because the
required tools are not installed inside the cluster environment. You can use the `kubeconfig-serviceaccounts.sh` script from
the kubermatic-installer repository to automatically create proper service accounts inside the seed cluster with static
credentials:

```bash
cd kubermatic-installer
./kubeconfig-service-accounts.sh mykubeconfig.yaml
Cluster: example
 > context: europe
 > creating service account kubermatic-seed-account ...
 > assigning cluster role kubermatic-seed-account-cluster-role ...
 > reading auth token ...
 > adding user example-kubermatic-service-account ...
 > updating cluster context ...
 > kubeconfig updated
```

The Seed resource then needs to reference the new kubeconfig Secret like so:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: kubeconfig-europe-west1
  namespace: kubermatic
type: Opaque
data:
  kubeconfig: <base64 encoded kubeconfig>

---
apiVersion: kubermatic.k8s.io/v1
kind: Seed
metadata:
  name: europe-west1
  namespace: kubermatic
spec:
  # these two fields are only informational
  country: DE
  location: Hamburg

  # list of datacenters where this seed cluster is allowed to create clusters in
  datacenters: []

  # reference to the kubeconfig to use when connecting to this seed cluster
  kubeconfig:
    name: kubeconfig-europe-west1
    namespace: kubermatic
```

Refer to the [Seed CRD documentation]({{< ref "../../concepts/seeds" >}}) for a complete example of the
Seed CustomResource and all possible datacenters.

Apply the manifest above in the master cluster and Kubermatic will pick up the new Seed and begin to
reconcile it by installing the required Kubermatic components.

### 4. Update DNS

The apiservers of all user cluster control planes running in the seed cluster are exposed by the
NodePort Proxy. By default each user cluster gets a virtual domain name like
`[cluster-id].[seed-name].[kubermatic-domain]`, e.g. `hdu328tr.europe-west1.kubermatic.example.com`
for the Seed from the previous step when `kubermatic.example.com` is the main domain where the
Kubermatic dashboard/API are available.

To facilitate this, a wildcard DNS record `*.[seed-name].[kubermatic-domain]` must be created. As with
the other DNS records the exact target depends on whether or not LoadBalancer services are supported
on the seed.

#### With LoadBalancers

When your cloud provider supports Load Balancers, you can find the target IP / hostname by looking at the
`nodeport-proxy` Service:

```bash
kubectl -n kubermatic get services
#NAME          TYPE           CLUSTER-IP      EXTERNAL-IP    PORT(S)                      AGE
#nodeport-proxy   LoadBalancer   10.47.248.232   8.7.6.5        80:32014/TCP,443:30772/TCP   449d
```

The `EXTERNAL-IP` is what we need to put into the DNS record.

#### Without Load Balancers

Without a LoadBalancer, you will need to point to one or many of the seed cluster's nodes. You can get a
list of external IPs like so:

```bash
kubectl get nodes -o wide
#NAME                        STATUS   ROLES    AGE     VERSION         INTERNAL-IP   EXTERNAL-IP
#worker-node-cbd686cd-50nx   Ready    <none>   3h36m   v1.15.8-gke.3   10.156.0.36   8.7.6.4
#worker-node-cbd686cd-59s2   Ready    <none>   21m     v1.15.8-gke.3   10.156.0.14   8.7.6.3
#worker-node-cbd686cd-90j3   Ready    <none>   45m     v1.15.8-gke.3   10.156.0.22   8.7.6.2
```

#### DNS Record

Create an A or CNAME record as needed pointing to the target:

```plain
*.europe-west1.kubermatic.example.com.   IN   A   8.7.6.5
```

or, for a CNAME:

```plain
*.europe-west1.kubermatic.example.com.   IN   CNAME   myloadbalancer.example.com.
```
