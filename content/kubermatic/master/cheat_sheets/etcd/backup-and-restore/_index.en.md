+++
title = "[Experimental] Etcd Backup and Restore Controllers"
weight = 40
+++


## Overview

Starting with version v2.17, KKP introduced experimental support for new etcd Backup and Restore controller based on the [etcd-launcher]({{< ref "../etcd-launcher" >}}) experimental feature.

The [legacy backup controller]({{< ref "../restoring-from-backup" >}}) is based on a simple cron job and didn't support automated restore operations. The new experimental controllers utilize new CRDs for backups and restore, support multiple backup configurations per cluster, immediate backups and automated restore operations.

The new controllers try to be as backward compatible with the legacy controller possible. However, it's not possible to manage or restore legacy backups with the new controllers.

The new controllers manage backup, restore and cleanup operations using [Kubernetes Jobs](https://kubernetes.io/docs/concepts/workloads/controllers/job/). All jobs triggered use containers that can be passed to the seed controller manager similar to the legacy backup controller. 


All backups managed by these controllers are tracked in the backup configuration status where the users can see their status. 

Currently, only S3 compatible backup backends are supported. 


## Enabling The New controllers

To use the new backup/restore controller, the [etcd-launcher]({{< ref "../etcd-launcher" >}}) experimental feature must be enabled along with specifically enabling the controllers by passing the flag `--enable-etcd-backups-restores` to the seed controller manager. This can be achieved by setting the following values in the [KubermaticConfiguration]({{< ref "../../../architecture/concepts/configuration" >}}):

```yaml
spec:
  # SeedController configures the seed-controller-manager.
  seedController:
    # BackupRestore contains the setup of the new backup and restore controllers.
    backupRestore:
      # Enabled enables the new etcd backup and restore controllers.
      enabled: true
      # S3BucketName is the S3 bucket name to use for backup and restore.
      s3BucketName: ""
      # S3Endpoint is the S3 API endpoint to use for backup and restore. Defaults to s3.amazonaws.com.
      s3Endpoint: ""
    # BackupDeleteContainer is the container used for deleting etcd snapshots from a backup location.
    backupDeleteContainer: ""
```

{{% notice note %}}

{{% /notice %}}

### Backup and Delete Containers

The new Backup controller is designed to be a drop-in replacement for the legacy backup controller. To achieve this, the legacy `backupStoreContainer` and `backupCleanupContainer` are supported by the new controller. However, it's best to use the new containers to enable the full full functionality of the new controller.

 * *`backupStoreContainer`*: it's recommended to update the seed controller configuration to use the new backup container. The new container spec is provided in the `charts` directory shipped with the KKP release:
 ```bash
 charts/kubermatic/static/store-container-new.yaml
 ```

* *`backupDeleteContainer`*: backup deletions are performed using a customizable container that is passed to the seed controller via new optional argument `backupDeleteContainer`. If this option is not set, the controller will not perform deletions and the legacy `backupCleanupContainer` will be used instead. A container spec is provided in the `charts` directory shipped with the KKP release:
```bash
charts/kubermatic/static/delete-container.yaml 
```

{{% notice note %}}
You can't have both `backupCleanupContainer` and backupDeleteContainer` set. backupDeleteContainer` will take precedence when the new controller is enabled.
{{% /notice %}}

{{% notice note %}}
The new containers expect that the S3 backend is SSL enabled. Unfortunately, the released minio chart doesn't support that by default, and will need to be modified to run over minio over SSL.
{{% /notice %}}


### S3 Credentials and Settings

The new controllers will use the credentials from the secret `kube-system/s3-credentials` similar to the legacy backup controller.

However, when using the new containers, creating an additional ConfigMap with the S3 backend settings is required:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: s3-settings
  namespace: kube-system
data:
  BUCKET_NAME: 
  ENDPOINT: 
```


## Creating Backups

By default a new backup configuration resource is created in the cluster namespace for each user cluster once the controllers are enabled. The new backup configuration resource is created with a default of `@every 20m` interval and 20 backup retention.

### Custom Backup Configurations

However, it's possible to create additional backup configuration if needed, simply by creating a backup configuration resource:

```yaml
apiVersion: kubermatic.k8s.io/v1
kind: EtcdBackupConfig
metadata:
  name: daily-backup
  namespace: cluster-zvc78xnnz7
spec:
  cluster:
    apiVersion: kubermatic.k8s.io/v1
    kind: Cluster
    name: zvc78xnnz7
  schedule: '0 1 * * *'
  keep: 40
```

Once created, the controller will start a new backup every time the schedule demands it (i.e. at 1:00 AM in the example), and delete backups once more than `.spec.keep` (40 in the example) have been created. The created backups are named based on the configuration name and the backup timestamp `$backupconfigname-$timestamp`.

Backup creations and deletions are done by spawning Kubernetes jobs. For each backup, a job is created with an init container that creates a snapshot and a main container that will run the customizable store container. It will receive the cluster name and backup name in two environment variables. The store container should upload the snapshot to an S3 compatible backend and return exit code 0 if successful.

When a backup needs to be deleted, the controller starts another job with the delete container configured in the seed controller manager. The delete container receives the cluster and backup names in environment variables and must delete the backup at the place where it was uploaded by the create job earlier, and exit 0 if successful. 

The controller maintains list of backups related to this configuration in the resource status spec, where it tracks the creation and deletion status of all backups that haven't been successfully deleted yet.

### One Time Backups

It's also possible to trigger a one-time backup if needed. Simply by creating a backup configuration that doesn't have a `schedule` set in the spec. The backup controller will immediately create a backup job for the user cluster and will not attempt to run it again or delete it later.

### Listing Backups

The Backup controller tracks all backups related to each configuration in a list in the backup configuration resource status spec. The status spec shows details about the backup status, cleanup status and the jobs triggered to run it and clean it up:

```yaml
status:
  lastBackups:
  - backupFinishedTime: "2021-03-16T01:48:22Z"
    backupName: zvc78xnnz7-jobtest1-2021-03-16T03:48:00
    backupPhase: Completed
    deleteFinishedTime: "2021-03-16T02:01:43Z"
    deleteJobName: zvc78xnnz7-backup-jobtest1-delete-s8sb8mdsp5
    deletePhase: Completed
    jobName: zvc78xnnz7-backup-jobtest1-create-rjjq9d4k6d
    scheduledTime: "2021-03-16T01:48:00Z"
  - backupFinishedTime: "2021-03-16T01:51:25Z"
    backupName: zvc78xnnz7-jobtest1-2021-03-16T03:51:00
    backupPhase: Completed
    deleteFinishedTime: "2021-03-16T02:04:08Z"
    deleteJobName: zvc78xnnz7-backup-jobtest1-delete-wcwvc8nmdt
    deletePhase: Completed
    jobName: zvc78xnnz7-backup-jobtest1-create-96tblznngk
    scheduledTime: "2021-03-16T01:51:00Z"
  - backupFinishedTime: "2021-03-16T01:54:21Z"
    backupName: zvc78xnnz7-jobtest1-2021-03-16T03:54:00
    backupPhase: Completed
    deleteFinishedTime: "2021-03-16T02:08:24Z"
    deleteJobName: zvc78xnnz7-backup-jobtest1-delete-cgmqhlw5fw
    deletePhase: Completed
    jobName: zvc78xnnz7-backup-jobtest1-create-v2gz2ntn46
    scheduledTime: "2021-03-16T01:54:00Z"
```


## Restoring Backups

To restore a cluster from am existing backup, you simply create a restore resource in the cluster namespace:

```yaml
apiVersion: kubermatic.k8s.io/v1
kind: EtcdRestore
metadata:
  name: cluster-restore
  namespace: cluster-zvc78xnnz7
spec:
  cluster:
    apiVersion: kubermatic.k8s.io/v1
    kind: Cluster
    name: zvc78xnnz7
  backupName: daily-backup-2021-03-02T15:24:00
```

Once this resource is created, the controller will reconcile it and apply the following restore procedure:

- Pause the cluster.
- Delete the etcd Statefulset and Volumes.
- Set the `EtcdClusterInitialized` cluster condition to false.
- Unpause the cluster and wait until the cluster controller has recreated the etcd Statefulset. 
- During the etcd Statefulset recreation, the etcd-launcher will detect the active restore resources and will download the backup from the S3 backend based on the credentials from the `kube-system/s3-credentials` secret and the information from the `kube-system/s3-settings` configmap. 
- Once the backup is downloaded successfully, the etcd-launcher will restore the backup and restart the etcd ring.
- Once the etcd cluster is recovered and quorum is achieved, the `EtcdClusterInitialized` cluster condition to true. At this point the 


{{% notice note %}}
Currently, The restore controller only support S3 compatible backends for downloading backups.
{{% /notice %}}
