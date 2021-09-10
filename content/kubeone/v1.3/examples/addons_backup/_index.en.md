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

Original [addon source][backups-addon-src] can be found in kubeone repository.

```yaml
{{< readfile "kubeone/v1.2/data/backups-restic.yaml" >}}
```

You need to replace the following values with the actual ones:
* `<<RESTIC_PASSWORD>>` - a password used to encrypt the backups
* `<<S3_BUCKET>>` - the name of the S3 bucket to be used for backups
* `<<AWS_DEFAULT_REGION>>` - default AWS region

Credentials are fetched automatically if you are deploying on AWS. If you want
to use non-default credentials or you're not deploying on AWS, update the
`s3-credentials` secret (`AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` keys).

[backups-addon-src]: https://raw.githubusercontent.com/kubermatic/kubeone/release/v1.3/addons/backups-restic/backups-restic.yaml
[restic-net]: https://restic.net/
