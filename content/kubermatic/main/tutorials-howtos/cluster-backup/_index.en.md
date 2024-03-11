+++
title = "Integrated User Cluster Backup"
date = 2023-02-20T12:00:00+01:00
weight = 3

+++

## [Experimental] Integrated User Cluster Backup

With KKP version 2.18, the Community Edition provided users with the ability to perform and manage [automated backups and restores]({{< ref "../etcd-backups" >}}) for the user clusters' etcd rings. With this automated backup feature, cluster and project administrators are able to fully restore a user cluster to a previous state.

KKP 2.25 introduces a new backup feature for Enterprize customers, by integrating [Velero backup](https://velero.io/) as a backup solution for user clusters. In the 2.25 release, the integration is experimental and expected to be extended in the future. 

With this integration, KKP allows project owners to manage backups for specific workloads, namespaces or labels. It also supports the backup and restore of Persistent Volumes content. 

For this experimental release, KKP supports the default AWS provider for s3 compatible storage backends, and Velero's [File System Backup](https://velero.io/docs/v1.12/file-system-backup/) for PersistentVolume backups. This allows the feature to be used with minimal infrastructure requirements and cover a wide range of use cases.

KKP Velero integration provides project owners with the ability to centrally manage user cluster backups from a simple interface. The project owner can define as many Cluster Backup Storage Locations as needed, and can assign them to user clusters. Project owners can also define Backup Schedules per cluster, perform on-time backups and restores.

### Using Integrated User Cluster Backup 

Cluster backup is disabled by default as an experimental feature. To use it, the KKP Administrator needs to enable it the Admin Panel.
![Enable Backup](/img/kubermatic/main/tutorials/cluster-backup/enable-bakcup-kkp.png?classes=shadow,border "Enable Backup")

Once UI dashboard options are available, the project owner must defined at least one Cluster Backup Storage Location.

#### Cluster Backup Storage Locations

The KKP UI allows Project owners to manage Cluster Backup Storage Locations that can be used for any clusters in the same project.

The `ClusterBackupStorageLocation` resource is a simple wrapper for Velero's [Backup Storage Location](https://velero.io/docs/v1.12/api-types/backupstoragelocation/) API type. Both types share the same Spec.

When Custer Backup is enabled for a user cluster, KKP will deploy a managed instance of Velero on the user cluster, and propagate a the required Velero `BackupStorageLocation` to the user cluster, with a special prefix to avoid collisions with other user clusters that could be using the same storage.


![Create ClusterBackupStorageLocation](/img/kubermatic/main/tutorials/cluster-backup/create-cbsl.png?classes=shadow,border "Create ClusterBackupStorageLocation")

For simplicity, the KKP UI requires the minimal required values to enabled a working Velero Backup Storage Location. If further parameters are needed, they can be added by editing the `ClusterBackupStorageLocation` resources on the Seed cluster:

```bash
$ kubectl edit -n kubermatic cbsl test-cbsl-1
```

Once a `CBSL` is created through the UI, the `CBSL` resources will be created in the `kubermatic` namespace. KKP will check if the storage location available or not and update the `CBSL` resource status.

{{% notice note %}}
The KKP control plane nodes need to have access to s3 endpoint defined in the Storage Location endpoint to be able to perform the availability check successfully. Additionally, the user cluster worker nodes must also have access to the s3 endpoint to be able to perform backups and restores.
{{% /notice %}}

#### Enabling Backup for User Clusters
Cluster Backup can be used for existing clusters and newly created ones. When creating a new user cluster, you can enable the `Cluster Backup` option in the cluster creation wizard. Once enabled, you will be required to assign the Backup Storage Location that you have created previously. 

![Enable Backup for New Clusters](/img/kubermatic/main/tutorials/cluster-backup/enable-backup-new-cluster.png?classes=shadow,border "Enable Backup for New Clusters")


For existing clusters, you can edit the cluster to assign the required Cluster Backup Location:
![Edit Existing Cluster](/img/kubermatic/main/tutorials/cluster-backup/enable-backup-edit-cluster.png?classes=shadow,border "Edit Existing Cluster")

{{% notice note %}}
Velero's Backup Storage Location Spec supports using s3 prefixes. When the storage location is propagated into the user cluster, an additional prefix of the Project ID and Cluster ID is added to avoid collision and provide isolation in case the storage location is used for multiple clusters.
{{% /notice %}}

{{% notice note %}}
Currently, KKP support defining a single storage location per cluster. The storage location is defined as the default `BackupStorageLocation` for Velero in the user cluster.
{{% /notice %}}

#### Configuring Backups and Schedules
Using the KKP UI, you can configure one-time backups that run as soon as they are defined, or recurring backup schedules that run at specific intervals.

Using the user cluster Kubernetes API, you can also create these resources using the Velero command line tool. They should show up automatically one the KKP UI once created.

##### One-time Backups
As with the `CBSL`, KKP UI allows the user to set the minimal required options to create a backup configuration. Since the backup process is started immediately after creation, it's not possible to edit it via the Kubernetes API. If you need to customize your backup further, you should use a Schedule.

To configure a new one-time backup, go to the Backups list, select the cluster you would like to create the backup for from the drop-down list, and click `Create Cluster Backup`.
![Create Backup](/img/kubermatic/main/tutorials/cluster-backup/create-backup.png?classes=shadow,border "Create Backup")


You can select the Namespaces that you want to include in this backup configuration from the dropdown list. Note that this list of Namespaces is directly fetched from your cluster, so you need to create the Namespaces before configuring the backup.

You can define the backup expiration period, which defaults to **30 days** and you can also choose if you want to to backup Persistent Volumes or not. KKP integration uses Velero's [File System Backup](https://velero.io/docs/v1.12/file-system-backup/) to cover the widest range of uses cases. Persistent Volumes backup is enabled by default.

{{% notice note %}}
Backing up Persistent Volume data to s3 backend can be resource intensive, especially if your cluster has a large volume of working data that is not critical or if you have limited storage resources in the backend. You can defined opt-in/out configuration for your user cluster workloads as detailed in the Velero [documentation](https://velero.io/docs/v1.12/file-system-backup/#to-back-up)
{{% /notice %}}

##### Scheduled Backups
Creating Scheduled almost identical to one-time backups. In this case, you will go to the Schedules submenu, select your user cluster and click `Create Backup Schedule`.

For Schedules, you also need to add a cron-style schedule to perform the backups. 

![Create Backup Schedule](/img/kubermatic/main/tutorials/cluster-backup/create-schedule.png?classes=shadow,border "Create Backup Schedule")


##### Downloading Backups
KKP UI provides a convenient button to down load Backups. You can simply to the Backups list, select a user cluster and a specific backup, then click the Download Backup button.
{{% notice note %}}
The s3 endpoint defined the Cluster Backup Storage Location must be accessible to the device used to download the backup.
{{% /notice %}}

#### Performing Restores
To restore a specific backup, go to the Backups page, select you cluster and find the required backup. Click on the `Restore Backup` button.

Velero restores backups by creating a `Restore` API resource on the clusters and then reconciles it.

![Create Restore](/img/kubermatic/main/tutorials/cluster-backup/create-restore.png?classes=shadow,border "Create Restore")

Simply, set a name for the restore request, and select the Namespaces that you would like to restore.

You can later track the restore status from the Restore Page.

![Restore Status](/img/kubermatic/main/tutorials/cluster-backup/restore-status.png?classes=shadow,border "Restore Status")



### Security Consideration
KKP administrators and Project Owners should be carefully plan the backup storage strategy of projects and user clusters.

Velero Backup is not currently designed with multi-tenancy in mind. While the upstream project is working on that, it's not there yet. As a result, Velero is expected to be managed by the cluster administrator who has full access to Velero resources as well as the backup storage backend.

Specifically, this means that the user cluster administrator, or any user provided with `cluster-admin` privileges on the user cluster, can access the Backup Storage Location credentials and can modify the Velero resources.

If the backup storage is not carefully planned with this in mind, the following scenarios can happen if multiple user clusters are using the same storage backend:

- A cluster admin can access and use the s3 backend credentials stored on the user cluster to access backups and files on the storage backend outside of their designated prefix. 

- A cluster admin can modify the user cluster `BackupStorageLocation` resource and access backups for other clusters.

To avoid these issues, multiple guidelines can be applied individually or combined to achieve proper isolation:

- Create and use a dedicated set of user credentials per user cluster, and use s3 bucket policies (if supported) to limit access to the user cluster specific prefix.
- Use the same backup storage backend, but create a dedicated bucket per user cluster.
- Create a dedicated Cluster Backup Storage Location resource per user cluster.
- Only share Cluster Backup Storage Locations among user clusters managed by the same admin.