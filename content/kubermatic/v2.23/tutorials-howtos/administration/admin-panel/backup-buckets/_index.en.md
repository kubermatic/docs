+++
title = "Etcd Backup Settings"
date = 2021-12-09T11:07:15+02:00
weight = 20
+++

Through the Backup Destinations settings you can enable and configure the new etcd backups for each Seed.

![Backup Destinations](/img/kubermatic/v2.23/tutorials/backups/backup_destinations.png?classes=shadow,border "Backup Destinations Settings View")


### Etcd Backup Settings

Setting a Bucket and Endpoint for a Seed turns on the automatic etcd Backups and Restore feature, for that Seed only. For now,
we only support S3 compatible endpoints.

It is possible to set multiple destinations per Seed, so that for example some backups can go into the local minio, and
some to an S3 bucket, depending on the importance.

{{% notice note %}}
For users already using the backups introduced in 2.18, when only one backup bucket and endpoint was available, they need to migrate to using destinations from 2.20 as
backups without destination are not supported anymore.
{{% /notice %}}

To add a new backup destination, just click on the `Add Destination` button on the right.

When a destination is added, credentials also need to be added for the bucket. To do that, click on the `Edit Credentials`
button and set the credentials. When credentials are properly set, the green checkmark appears and the destination can be used.

![Add Backup Destination](/img/kubermatic/v2.23/tutorials/backups/add_backup_destination.png?classes=shadow,border "Backup Destination Settings Add")

To edit, just click on the `Edit Destination` pen icon on the right

![Edit Backup Destination](/img/kubermatic/v2.23/tutorials/backups/edit_backup_destination.png?classes=shadow,border "Backup Destination Settings Edit")

### Credentials

When a destination is added, credentials also need to be added for the bucket. To do that, click on the `Edit Credentials`
button and set the credentials. When credentials are properly set, the green checkmark appears and the destination can be used.

For security reasons, the API/UI does not offer a way to get the current credentials.

![Edit Credentials](/img/kubermatic/v2.23/tutorials/backups/edit_backup_dest_credentials.png?classes=shadow,border "Backup Destination Credentials Edit")

To see how to make backups and restore your cluster, check the [Etcd Backup and Restore Tutorial]({{< ref "../../../etcd-backups" >}}).


### Default Backups

Since 2.20, default destinations are required if the automatic etcd backups are configured. A default EtcdBackupConfig
is created for all the user clusters in the Seed. It has to be a destination that is present in the backup destination list for that Seed.

Example Seed with default destination:
```yaml
...
  etcdBackupRestore:
    destinations:
      s3:
        bucketName: kkpbackuptest
        credentials:
          name: backup-s3
          namespace: kube-system
        endpoint: s3.amazonaws.com
    defaultDestination: s3
...
```

Default EtcdBackupConfig that is created:
```yaml
...
  spec:
    keep: 20
    name: default-backups
    schedule: '@every 20m'
    destination: s3
...
```

![Set Default Destination](/img/kubermatic/v2.23/tutorials/backups/set_backup_dest_as_default.png?classes=shadow,border "Set Backup Destination as Default")
