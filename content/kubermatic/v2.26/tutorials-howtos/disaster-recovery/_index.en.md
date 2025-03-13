+++
title = "Disaster Recovery"
date =  2024-11-05T12:00:43+02:00
weight = 151
+++

## **Intro**

This document describes how to back up and restore the Kubermatic Kubernetes Platform . The system must be backed up in a way that it can be recovered from any imaginable disaster scenario. This means all parts of the system have to be backed up regularly, separately on different mediums, and must be restored from those backups quickly in case of a disaster.

In such a case the goal is to restore the system to the most recent state possible (RPO), as quickly as possible (RTO). 

Recovery Point Objective (RPO) defines the amount of data loss a customer can tolerate in the event of a disaster. ​​Recovery Time Objective (RTO) defines how soon after a disaster a system or application can be recovered.

We propose a multi-layered approach to backups. The underlying infrastructure in terms of Cloud or on-prem Provider VMs and their storage needs to be backed up to allow core system components to be restored quickly. This will reduce the RTO of restoring the overall system. 

Additionally, especially on the application layer, Kubernetes tooling, most notably Velero, will come into play, to ensure low RPO and RTO on application-functionality and -state.


## **Overview**

### **Infrastructure**

Control plane VMs need to be backed up regularly (ideally once a day) on provider level. Backups have to be clones of the VMs including a copy of all attached volumes. The backups have to be stored on a separate datastore.

In case of a broken node, the underlying VM must be restorable from the backup.


### githu

### Kubermatic Master / Seed Level

#### **S3 / MinIO** 

S3 / MinIO is used as a cluster-internal central datastore for all Kubernetes system-related backups. 

All data stored on S3 / MinIO is backed up every 30 minutes to Azure Blob Storage via a Kubernetes cronjob, using the command-line tool rclone, which allows delta synchronization to S3-compatible datastores.

Using a cluster-internal datastore to collect all backup data before syncing it outside the clusters gives us benefits in terms of redundancy, performance, and ease of use. 


#### **etcd/PKI**

The etcd database holds all the state of a Kubernetes cluster. You can lose up to (N-1)/2 nodes of your etcd “ring” and still have a healthy datastore. If you lose more, etcd must be restored from backup. 

The backup (“snapshot”) of one member of the etcd ring is enough to restore the whole cluster.

The PKI includes the CA, certificates, and keys used for Kubernetes authentication. It’s important to back those up as well for a quick recovery.

We recommend to back etcd snapshots and PKI every 30 minutes and store it outside the cluster. 

Currently this is done via a Kubernetes cronjob. It runs every 30 minutes and collects the PKI data, takes a snapshot of etcd, and uses the command-line tool “restic” to upload the data to cluster-internal MinIO storage.


#### **Kubernetes objects**

Etcd and PKI backups can be used to restore a broken cluster on the same environment, although sometimes it might be necessary to just restore a previous state in the current, and otherwise functional cluster, or to restore previous state into a new cluster.\
This is where Velero is useful. It takes a snapshot of all objects within the cluster and allows for a restore to previous state, similar to a “kubectl get \<crd> \<crd-name>  -o yaml > my-object.yaml”.

We recommend backups at least every 6 hours.


### **MLA data**

All MLA configuration including alerts and dashboards are stored as infrastructure-as-code in the customers codebase. 

Only the Prometheus database needs to be backed up. We recommend backups every 6 hours to strike a balance between performance and usability. 

For backing up the Prometheus database, Velero and its restic-integration is used. Velero takes a dump of the Prometheus database and uses restic to sync it to the cluster-internal MinIO. 

This is included in the Velero backups every 6 hours.


### **User Clusters**

#### **etcd**

To restore user-cluster state during a disaster recovery, it is necessary to have etcd database-snapshots available. KKP offers a fully automated way to regularly back-up and restore user-clusters from snapshots.

This is a configuration which needs to be done on a cluster-by-cluster basis. Generally we recommend turning this feature on and configuring it to run every 20 minutes.\
\
The snapshots are stored on the cluster-internal MinIO.


#### **Workload**

The user-cluster workload, as long as it is stateless, can be restored from the etcd backups. 

As soon as the user-clusters run stateful applications, extra steps have to be taken.\
\
We recommend installing Velero on the user-clusters, e.g. as a [KKP addon](https://github.com/kubermatic/community-components/tree/master/kubermatic-addons/custom-addon/velero) and storing the backups either directly on a dedicated cloud storage, or on the cluster internal MinIO.


##### **Data Replication**

Additionally we recommend running any stateful application with a replication mechanism and to replicate storage over more than one node, ideally even over a different datacenter. 


## **Backup Schedule**

This is the suggested schedule configuration, broken down by backup job, schedule, and how long a backup is kept (TTL).

|                                                         |                  |                       |
| ------------------------------------------------------- | ---------------- | --------------------- |
| **Backup job**                                          | **Schedule**     | **TTL**               |
| KKP master control plane VM backups                     | Once every day   | 3 days                |
| MLA data (KKP master cluster objects + Prometheus data) | Every 6th hour   | 168 hours (7 days)    |
| KKP master etcd and PKI                                 | Every 30 minutes | 24 hours              |
| User-cluster control-planes                             | Every 20 minutes | Last 20 (\~6,5 hours) |
| Cluster-internal backups (S3 / MinIO)                   | Every 30 minutes | 24 hours              |


## **Process**

To speed up the recovery process and eliminate mistakes, a runbook for all recovery phases needs to be written down. 

It should give detailed instructions on which strategy to follow in which cases, and how to recover the broken parts of the system. 

To test the process and the runbooks, regular tests should be conducted. For this, the staging environment can be used to simulate different disaster scenarios. These tests should be executed at least once a year, by different members of the team. This ensures that the documentation is up to date and the knowledge is not only with one team member.
