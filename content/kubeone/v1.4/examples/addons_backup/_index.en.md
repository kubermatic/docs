+++
title = "Backups Addon"
date = 2021-02-10T12:00:00+02:00
weight = 2
enableToc = true
+++

The [backups addon][backups-addon-src] can be used to backup the most important
parts of a cluster, including:
* `etcd`
* `etcd` PKI (certificates and keys used by Kubernetes to access the `etcd`
  cluster)
* Kubernetes PKI (certificates and keys used by Kubernetes and clients)

The addon uses [Restic][restic-net] to upload backups, encrypt them, and handle
backup rotation.

{{% notice warning %}}
By default, backups are done every 30 minutes and are
kept for 48 hours. If you need renention, please adjust the restic CLI flags
`restic forget --prune --keep-last <NEW AMOUNT OF HOURS>`.
{{% /notice %}}

## Prerequisites

In order to use this addon, you need an S3 bucket or Restic-compatible
repository for storing backups.

## Using The Addon

You can enable the addon via the KubeOneCluster manifest. Make sure to replace
the placeholder values in the `params` stanza with the appropriate values.

```yaml
apiVersion: kubeone.k8c.io/v1beta2
kind: KubeOneCluster
versions:
  kubernetes: 1.23.3
cloudProvider:
  aws: {}
addons:
  enable: true
  addons:
    - name: backups-restic
      params:
        resticPassword: "some-secret-value-here"
        s3Bucket: "name-of-the-s3-bucket"
        awsDefaultRegion: "default-AWS-region"
```

Original [addon source][backups-addon-src] can be found in kubeone repository.

Credentials are fetched automatically via the `AWS_ACCESS_KEY_ID` and
`AWS_SECRET_ACCESS_KEY` environment variables. If you want to use non-default
credentials, update the `s3-credentials` secret
(`AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` keys).

[backups-addon-src]: https://raw.githubusercontent.com/kubermatic/kubeone/v1.4/addons/backups-restic/backups-restic.yaml
[restic-net]: https://restic.net/
