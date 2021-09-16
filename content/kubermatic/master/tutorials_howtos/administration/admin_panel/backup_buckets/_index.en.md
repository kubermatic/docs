+++
title = "Backup Buckets"
date = 2020-02-10T11:07:15+02:00
weight = 20
+++

Through the Backup Buckets settings you can enable and configure the new etcd backups for each Seed.

![Backup Buckets](/img/kubermatic/master/tutorials/backups/backup_buckets.png?classes=shadow,border "Backup Bucket Settings View")


### Bucket Settings

Setting the Bucket and Endpoint for a Seed turns on the automatic etcd Backups and Restore feature, for that Seed only. For now,
we only support S3 compatible endpoints.

To set the endpoint and bucket, just click on the `Edit Bucket Setting` pen icon on the right. 

![Edit Buckets](/img/kubermatic/master/tutorials/backups/edit_buckets.png?classes=shadow,border "Backup Bucket Settings Edit")

### Credentials

For the etcd Backups and Restore to work correctly, the credentials for the bucket need to be set up as well. This can be
done by clicking on the `Edit Credentials` button on the right.

For security reasons, the API/UI does not offer a way to get the current credentials.

![Edit Buckets](/img/kubermatic/master/tutorials/backups/set_backup_credentials.png?classes=shadow,border "Backup Bucket Credentials Edit")
