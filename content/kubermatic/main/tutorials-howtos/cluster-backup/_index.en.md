+++
title = "Integrated User Cluster Backup"
date = 2023-02-20T12:00:00+01:00
weight = 3
enterprise = true
+++

With KKP version 2.18, the Community Edition provided users with the ability to perform and manage [automated backups and restores]({{< ref "../etcd-backups" >}}) for the user clusters' etcd rings. With this automated backup feature, cluster and project administrators are able to fully restore a user cluster to a previous state.

KKP 2.25 introduces a new backup feature for Enterprise customers, by integrating [Velero backup](https://velero.io/) as a backup solution for user clusters.

With this integration, KKP allows project owners/editors to manage backups for specific workloads, namespaces or labels. It also supports the backup and restore of Persistent Volumes content.

For this feature, KKP supports the default AWS provider for S3 compatible storage backends, and Velero's [File System Backup](https://velero.io/docs/v1.12/file-system-backup/) for PersistentVolume backups. This allows the feature to be used with minimal infrastructure requirements and cover a wide range of use cases.

KKP Velero integration provides project owners/editors with the ability to centrally manage user cluster backups from a simple interface. The project owner can define as many Cluster Backup Storage Locations as needed, and can assign them to user clusters. Project owners/editors can also define Backup Schedules per cluster, perform on-time backups, import external backups and restore backups.

### Using Integrated User Cluster Backup

Cluster backup is disabled by default and to use it, the KKP administrator needs to enable it the admin panel.
![Enable Backup](images/enable-backup-kkp.png?classes=shadow,border "Enable Backup")

Once UI dashboard options are available, the project owner must defined at least one Cluster Backup Storage Location.

#### Cluster Backup Storage Locations

The KKP UI allows project owners/editors to manage Cluster Backup Storage Locations that can be used for any clusters in the same project.

The `ClusterBackupStorageLocation` resource is a simple wrapper for Velero's [Backup Storage Location](https://velero.io/docs/v1.12/api-types/backupstoragelocation/) API type. Both types share the same spec.

When Custer Backup is enabled for a user cluster, KKP will deploy a managed instance of Velero on the user cluster, and propagate the required Velero `BackupStorageLocation` to the user cluster, with a special prefix to avoid collisions with other user clusters that could be using the same storage.


![Create ClusterBackupStorageLocation](images/create-cbsl.png?classes=shadow,border "Create ClusterBackupStorageLocation")

For simplicity, the KKP UI requires the minimal required values to enabled a working Velero Backup Storage Location. If further parameters are needed, they can be added by editing the `ClusterBackupStorageLocation` resources on the Seed cluster:

```bash
$ kubectl edit -n kubermatic cbsl test-cbsl-1
```

Once a `CBSL` is created through the UI, the `CBSL` resources will be created in the `kubermatic` namespace. KKP will check if the storage location available or not and update the `CBSL` resource status.

{{% notice note %}}
The KKP control plane nodes need to have access to S3 endpoint defined in the Storage Location endpoint to be able to perform the availability check successfully. Additionally, the user cluster worker nodes must also have access to the S3 endpoint to be able to perform backups and restores.
{{% /notice %}}

#### Enabling Backup for User Clusters
Cluster Backup can be used for existing clusters and newly created ones. When creating a new user cluster, you can enable the `Cluster Backup` option in the cluster creation wizard. Once enabled, you will be required to assign the Backup Storage Location that you have created previously.

![Enable Backup for New Clusters](images/enable-backup-new-cluster.png?classes=shadow,border "Enable Backup for New Clusters")


For existing clusters, you can edit the cluster to assign the required Cluster Backup Location:
![Edit Existing Cluster](images/enable-backup-edit-cluster.png?classes=shadow,border "Edit Existing Cluster")

{{% notice note %}}
Velero's Backup Storage Location Spec supports using S3 prefixes. When the storage location is propagated into the user cluster, an additional prefix of the Project ID and Cluster ID is added to avoid collision and provide isolation in case the storage location is used for multiple clusters.
{{% /notice %}}

{{% notice note %}}
Currently, KKP support defining a single storage location per cluster. The storage location is defined as the default `BackupStorageLocation` for Velero in the user cluster.
{{% /notice %}}

#### Configuring Backups and Schedules
Using the KKP UI, you can configure one-time backups that run as soon as they are defined, or recurring backup schedules that run at specific intervals.

Using the user cluster Kubernetes API, you can also create these resources using the Velero command line tool. They should show up automatically on the KKP UI once created.

##### One-time Backups
As with the `CBSL`, KKP UI allows the user to set the minimal required options to create a backup configuration. Since the backup process is started immediately after creation, it's not possible to edit it via the Kubernetes API. If you need to customize your backup further, you should use a Schedule.

To configure a new one-time backup, go to the Backups list, select the cluster you would like to create the backup for from the drop-down list, and click `Create Cluster Backup`.
![Create Backup](images/create-backup.png?classes=shadow,border "Create Backup")


You can select the Namespaces that you want to include in this backup configuration from the dropdown list. Note that this list of Namespaces is directly fetched from your cluster, so you need to create the Namespaces before configuring the backup.

You can define the backup expiration period, which defaults to **30 days** and you can also choose if you want to backup Persistent Volumes or not. KKP integration uses Velero's [File System Backup](https://velero.io/docs/v1.12/file-system-backup/) to cover the widest range of use cases. Persistent Volumes backup is enabled by default.

{{% notice note %}}
Backing up Persistent Volume data to S3 backend can be resource intensive, especially if your cluster has a large volume of working data that is not critical or if you have limited storage resources in the backend. You can defined opt-in/out configuration for your user cluster workloads as detailed in the Velero [documentation](https://velero.io/docs/v1.12/file-system-backup/#to-back-up)
{{% /notice %}}

##### Scheduled Backups
Creating scheduled backups is almost identical to one-time backups. Configuration is available from the "Schedules" submenu, selecting your user cluster and clicking `Create Backup Schedule`.

For schedules, you also need to add a cron-style schedule to perform the backups.

![Create Backup Schedule](images/create-schedule.png?classes=shadow,border "Create Backup Schedule")


##### Downloading Backups
KKP UI provides a convenient button to download backups. You can simply go to the "Backups" list, select a user cluster and a specific backup, then click the "Download Backup" button.
{{% notice note %}}
The S3 endpoint defined in the Cluster Backup Storage Location must be accessible to the device used to download the backup.
{{% /notice %}}

#### Performing Restores
To restore a specific backup, go to the Backups page, select your cluster and find the required backup. Click on the `Restore Backup` button.

Velero restores backups by creating a `Restore` API resource on the clusters and then reconciles it.

![Create Restore](images/create-restore.png?classes=shadow,border "Create Restore")

Simply, set a name for the restore request, and select the Namespaces that you would like to restore.

You can later track the restore status from the Restore page.

![Restore Status](images/restore-status.png?classes=shadow,border "Restore Status")

#### Importing External Backups

KKP UI supports importing external backups from supported S3 providers to user clusters. A new "Import External Backups" button has been added on Backups page.

![Import External Backups](images/import-external-backups-button.png?classes=shadow,border "Import External Backups")

Clicking "Import External Backups" button brings up a dialog where user can select the Backup Storage Location to import backups from.

![Import External Backups Dialog](images/import-external-backups-dialog.png?classes=shadow,border "Import External Backups Dialog")

After Backup Storage Location is selected, an explorer UI is shown which displays S3 bucket configured with selected BSL. You can select the directory which contains backups that are to be imported into the target cluster.
By default, KKP uses the sub-directory convention of `/<project-id>/<cluster-id>` for each user cluster. The backup folder created by Velero contains **backups** and **kopia** directories.
Please note that if the selected path is incorrect, Velero won’t be able to sync the backups.

Additionally you can also customize the Backup Sync Period which will be used to sync backups from S3. By default this value is same as the Backup Sync Period configured in selected Backup Storage Location.

When "Import Backup" button is clicked, a new Backup Storage Location is created in the target user cluster where `prefix` value is set to the selected directory path. Backups in the selected directory should appear automatically after the Backup Sync Period and then those backups can be downloaded or restored as required.

#### Uploading Backups

KKP UI supports uploading backups to supported S3 providers. An "Upload Backups" button has been added on Backups page.

![Upload Backups](images/upload-backups-button.png?classes=shadow,border "Upload Backups")

After clicking "Upload Backups" button, a dialog is shown where user can select the Backup Storage Location to upload backups.

![Upload Backups Dialog](images/upload-backups-dialog.png?classes=shadow,border "Upload Backups Dialog")

By default, the KKP UI uploads backups to a directory named after the current Project ID. Users can specify a subdirectory name, which will be created within the Project ID directory.
After that, users must select the Backup and Kopia files to be uploaded in the designated directories on S3. In order to simplify the process, user can upload entire directories containing these files.
Backup and Kopia files will be uploaded inside `backups` and `kopia` directories respectively. Since Velero requires the Kopia files to sync backups, its important that files are uploaded in their respective directories.

KKP UI will use multipart upload for files larger than the 100MB size and maximum allowed file size is 1TB. Its important that the dashboard window and upload backups dialog are kept open until all files have finished uploading. If the dialog or window is closed prematurely then this may result in unfinished multipart uploads which can incur additional cloud storage charges.
After all files have been uploaded successfully, user can follow the instructions mentioned above for Importing External Backups.

### Security Consideration
KKP administrators and project owners/editors should be carefully plan the backup storage strategy of projects and user clusters.

Velero Backup is not currently designed with multi-tenancy in mind. While the upstream project is working on that, it's not there yet. As a result, Velero is expected to be managed by the cluster administrator who has full access to Velero resources as well as the backup storage backend.

Specifically, this means that the user cluster administrator, or any user provided with `cluster-admin` privileges on the user cluster, can access the Backup Storage Location credentials and can modify the Velero resources.

If the backup storage is not carefully planned with this in mind, the following scenarios can happen if multiple user clusters are using the same storage backend:

- A cluster admin can access and use the S3 backend credentials stored on the user cluster to access backups and files on the storage backend outside of their designated prefix.

- A cluster admin can modify the user cluster `BackupStorageLocation` resource and access backups for other clusters.

To avoid these issues, multiple guidelines can be applied individually or combined to achieve proper isolation:

- Create and use a dedicated set of user credentials per user cluster, and use S3 bucket policies (if supported) to limit access to the user cluster specific prefix.
- Use the same backup storage backend, but create a dedicated bucket per user cluster.
- Create a dedicated Cluster Backup Storage Location resource per user cluster.
- Only share Cluster Backup Storage Locations among user clusters managed by the same admin.
