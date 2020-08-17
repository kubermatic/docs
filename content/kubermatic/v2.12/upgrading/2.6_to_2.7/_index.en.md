+++
title = "Upgrading from 2.6 to 2.7"
date = 2018-07-04T12:07:15+02:00
weight = 10

+++

After modifying the `values.yaml` files according to the information below, you merely need to re-apply helm charts upgrade from the `release/2.7` branch.

{{% notice warning %}}
There is a know issue with re-applying the s3-exporter chart. If Helm reports issues with upgrading ServiceAccounts or ClusterRoles, run:

```bash
kubectl -n kube-system delete serviceaccount s3-exporter
kubectl -n kube-system delete ClusterRole kubermatic:s3exporter:clusters:reader
kubectl -n kube-system delete ClusterRoleBinding kubermatic:s3exporter:clusters:reader
kubectl -n kube-system delete Deployment s3-exporter
```

{{% /notice %}}

### Changes to *values.yaml*

{{% notice note %}}
An automated `values.yaml` converter for 2.6->2.7 is available in the `release/2.7` branch of the Kubermatic Installer.
{{% /notice %}}

#### Default Addons

The section `kubermatic->addons->defaultAddons` is now moved to 'kubermatic->controller->addons->defaultAddons'. The `kubermatic->addons` section is gone.

#### Image Versions

The new versions of the images at the time of writing this are:

 - `kubermatic->controller->image->tag` is now `v2.7.7`
 - `kubermatic->api->image->tag` is now `v2.7.7`
 - `kubermatic->ui->image->tag` is now `v0.38.0`
 - `kubermatic->controller->addons->image->tag` is now `v0.1.11`
 - `nginx->image->tag` is now `0.18.0`
 - `alertmanager->version` is now `v0.1.11`
 - `kubeStateMetrics->resizer->image->repository` is now `k8s.gcr.io/addon-resizer`
 - `kubeStateMetrics->resizer->image->tag` is now `1.7`

#### S3 Exporter Section

A new section for configuring an S3 metrics exporter has been added at `kubermatic->s3_exporter`. Example data:

```yaml
kubermatic:
  s3_exporter:
    image:
      repository: quay.io/kubermatic/s3-exporter
      tag: v0.2
    endpoint: http://minio.minio.svc.cluster.local:9000
    bucket: kubermatic-etcd-backups
```

#### kube-state-metrics RBAC Proxy

The section `kubeStateMetrics->rbacProxy` is now gone.

#### Prometheus Config

New options for configuring resource limits have been added. The following example section needs to be merged into existing config:

```yaml
prometheus:
  storageSize: 100Gi
  externalLabels:
    region: default
  containers:
    prometheus:
      resources:
        limits:
          cpu: 1
          memory: 2Gi
        requests:
          cpu: 100m
          memory: 512Mi
    reloader:
      resources:
        limits:
          cpu: 100m
          memory: 64Mi
        requests:
          cpu: 25m
          memory: 16Mi
```

#### Prometheus Operator

The `prometheusOperator` section is now gone.

### Changes to `datacenters.yaml`

A new optional VSphere spec parameter `infra_management_user` has been added to specify a separate account with wider permissions, to be used by Kubermatic for provisioning resources. This allows to restrict permissions for the credentials passed in the UI to the cluster's cloud provider functionality of Kubernetes.

A new optional parameter `seed_dns_overwrite` allows force-changing the datacenter's name used in external DNS names.

Example:

```yaml
datacenters:
  vsphere-1:
    location: Antarctica
    seed: europe-west3-c
    country: DE
    provider: Kubermatic
    seed_dns_overwrite: internal8
    spec:
      vsphere:
        endpoint: "https://antarctica.kubermatic.io"
        datacenter: "Datacenter-foo"
        datastore: "datastore-bar"
        cluster: "loodse-cluster"
        allow_insecure: false
        root_path: "/Datacenter/vm/kubermatic"
        templates:
          ubuntu: "ubuntu-template"
          centos: "centos-template"
        infra_management_user:
          username: uplink
          password: rosebud
```
