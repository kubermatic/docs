+++
title = "Add Seed Cluster for EE"
date = 2018-08-09T12:07:15+02:00
weight = 30

+++


This document describes how a new seed cluster can be added to an existing Kubermatic Kubernetes Platform(KKP) master cluster.

Please refer to the [architecture]({{< ref "../../concepts/architecture" >}}) diagrams for more information
about the cluster relationships.

### Install KKP Dependencies

#### Cluster Backups

KKP performs regular backups of user cluster by snapshotting the etcd of each cluster. By default these backups
are stored locally inside the cluster, but they can be reconfigured to work with any S3-compatible storage.
The in-cluster storage is provided by [Minio](https://min.io/) and the accompanying `minio` Helm chart.

If your cluster has no default storage class, it's required to configure a class explicitly for Minio. You can check
the cluster's storage classes via:

```bash
kubectl get storageclasses
#NAME                 PROVISIONER            AGE
#kubermatic-fast      kubernetes.io/gce-pd   195d
#standard (default)   kubernetes.io/gce-pd   2y43d
```

As Minio does not require any of the SSD's advantages, we can use HDDs.
For a cluster running on AWS, an example class could look like this:

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: minio-hdd
provisioner: kubernetes.io/aws-ebs
parameters:
  type: sc1
```

To configure the storage class and size, extend your `values.yaml` like so:

```yaml
minio:
  storeSize: '500Gi'
  storageClass: minio-hdd
```

#### Install Charts

With this you can install the chart:

```bash
helm --tiller-namespace kubermatic upgrade --install --values /path/to/your/helm-values.yaml --namespace minio minio charts/minio/
helm --tiller-namespace kubermatic upgrade --install --values /path/to/your/helm-values.yaml --namespace s3-exporter s3-exporter charts/s3-exporter/
```

It's also advisable to install the `s3-exporter` Helm chart, as it provides basic metrics about user cluster backups.
This will need the creation of a secret named `s3-credentials` in the `s3-exporter` namespace.
You can use the following command:

```bash
kubectl create secret -n s3-exporter generic s3-credentials --from-literal=ACCESS_KEY_ID=<aws_access_key_id> --from-literal=SECRET_ACCESS_KEY=<aws_secret_access_key>
```

### Add the Seed Resource

To connect the new seed cluster with the master, you need to create a Secret containing the kubeconfig and a Seed resource.

You will add the **master cluster** as the **seed cluster**

Make sure the kubeconfig contains static, long-lived credentials. Some cloud providers use custom authentication providers
(like GKE using `gcloud` and EKS using `aws-iam-authenticator`). Those will not work in KKP’s usecase because the
required tools are not installed inside the cluster environment.

You can follow the template below or use the yaml file inside the examples folder of the tarball.

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
  name: kubermatic
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

Apply the manifest above in the master cluster and KKP will pick up the new Seed and begin to
reconcile it by installing the required KKP components.

### Update DNS

The apiservers of all user cluster control planes running in the seed cluster are exposed by the
NodePort Proxy. By default each user cluster gets a virtual domain name like
`[cluster-id].[seed-name].[kubermatic-domain]`, e.g. `hdu328tr.europe-west1.kubermatic.example.com`
for the Seed from the previous step when `kubermatic.example.com` is the main domain where the
KKP dashboard/API are available.

To facilitate this, a wildcard DNS record `*.[seed-name].[kubermatic-domain]` must be created. The target of the
DNS wildcard record should be the `EXTERNAL-IP` of the `nodeport-proxy` service in the `kubermatic` namespace.

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
