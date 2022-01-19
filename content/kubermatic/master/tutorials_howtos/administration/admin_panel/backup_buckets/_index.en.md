+++
title = "Etcd Backup Settings"
date = 2021-12-09T11:07:15+02:00
weight = 20
+++

Through the Backup Destinations settings you can enable and configure the new etcd backups for each Seed.

![Backup Destinations](/img/kubermatic/master/tutorials/backups/backup_destinations.png?classes=shadow,border "Backup Destinations Settings View")


### Etcd Backup Settings

Setting a Bucket and Endpoint for a Seed turns on the automatic etcd Backups and Restore feature, for that Seed only. For now,
we only support S3 compatible endpoints.

It is possible to set multiple destinations per Seed, so that for example some backups can go into the local minio, and 
some to an S3 bucket, depending on the importance.

{{% notice note %}}
For users already using the backups introduced in 2.18, when only one backup bucket and endpoint was available, their
backups will still work, and the old method is still supported, but deprecated. A warning will be shown on the seed in question, which 
instructs users to add a destination, and migrate backups to use destination.

![Backup Destinations Warning](/img/kubermatic/master/tutorials/backups/backup_seed_warning.png?classes=shadow,border "Backup Destinations Settings View - Warning")
{{% /notice %}}

To add a new backup destination, just click on the `Add Destination` button on the right. 

When a destination is added, credentials also need to be added for the bucket. To do that, click on the `Edit Credentials`
button and set the credentials. When credentials are properly set, the green checkmark appears and the destination can be used.

![Add Backup Destination](/img/kubermatic/master/tutorials/backups/add_backup_destination.png?classes=shadow,border "Backup Destination Settings Add")

To edit, just click on the `Edit Destination` pen icon on the right

![Edit Backup Destination](/img/kubermatic/master/tutorials/backups/edit_backup_destination.png?classes=shadow,border "Backup Destination Settings Edit")

### Credentials

When a destination is added, credentials also need to be added for the bucket. To do that, click on the `Edit Credentials`
button and set the credentials. When credentials are properly set, the green checkmark appears and the destination can be used.

For security reasons, the API/UI does not offer a way to get the current credentials.

![Edit Credentials](/img/kubermatic/master/tutorials/backups/edit_backup_dest_credentials.png?classes=shadow,border "Backup Destination Credentials Edit")

To see how to make backups and restore your cluster, check the [Etcd Backup and Restore Tutorial]({{< ref "../../../etcd_backups" >}}).


### Enforcing default backups

It is also possible to enforce default backups for each cluster in a Seed. By setting a default destination, a default EtcdBackupConfig
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

![Set Default Destination](/img/kubermatic/master/tutorials/backups/set_backup_dest_as_default.png?classes=shadow,border "Set Backup Destination as Default")

{{% notice warning %}}
Removing the default destination results in the termination of all default backups (Tip: to retain existing backups you can overwrite the default destination instead)
{{% /notice %}}

{{% notice note %}}
For users already using the backups introduced in 2.18, when only one backup bucket and endpoint was available,
if the backup is configured for the Seed, the default backups will be created for each user cluster as in 2.18.
If the legacy configuration is removed, the default backups will be deleted.

When migrating to multiple destinations, if you would like to keep your default backups, first set up the multiple destinations 
with the default destination (set the same destination as the legacy), then remove the old configuration. This will cause the default backups to just switch to a new destination,
and not get deleted and recreated.
{{% /notice %}}
