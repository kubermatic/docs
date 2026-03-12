+++
title = "KKP Backup"
date = 2026-03-09T19:45:00+02:00
weight = 151
+++

## Introduction

The following is a recommended procedure for backup and restore Kubermatic Kubernetes Platform. A comprehensive backup strategy is essential to guarantee recovery from any potential disaster scenario. Consequently, all system components must be backed up regularly to separate storage mediums, ensuring rapid restoration when necessary. 

The primary objective during a disaster is to restore the system to the most recent state possible (RPO) as quickly as possible (RTO).

* **Recovery Point Objective (RPO):** Defines the maximum acceptable amount of data loss a customer can tolerate during a disaster.
* **Recovery Time Objective (RTO):** Defines the maximum acceptable amount of time it takes to recover a system or application after a disaster.

## Overview


We propose a multi-layered approach to backups. Backing up the underlying virtual machine (VM) infrastructure and its storage enables the rapid restoration of core system components, thereby reducing the overall RTO. 

Furthermore, at the application layer, Kubernetes tools — most notably Velero — are utilized to maintain low RPO and RTO for application state and functionality.

<img width="2240" height="1914" alt="kkp_backup_tuned_matched copy" src="https://github.com/user-attachments/assets/bba2575c-4cf0-46df-b236-31fbe7b72a3d" />


## Recommended backup and disaster recovery strategy

### Infrastructure
* Control plane VMs must be backed up regularly (ideally daily) at the virtual machine level.
* Backups must be exact clones of the VMs, including copies of all attached volumes.
* These backups must reside on a separate datastore.
* In the event of a node failure, the underlying VM must be fully restorable from its backup.
* Tools such as Veem, or native cloud provider VM backup solutions, can be utilized to automate these regular backups.

### Kubermatic Master / Seed Level

#### MinIO
* MinIO serves as a cluster-internal, central datastore for all Kubernetes system-related backups.
* All data stored within MinIO should be synchronized every 30 minutes to an external object storage solution (e.g., Azure Blob Storage, AWS S3) via a Kubernetes cronjob. This process utilizes the `rclone` command-line tool, which enables delta synchronization to S3-compatible datastores.
* Aggregating all backup data in a cluster-internal datastore before external synchronization provides significant benefits regarding redundancy, performance, and ease of use.

#### etcd / PKI
* The etcd database contains the complete state of a Kubernetes cluster. 
* An etcd "ring" can tolerate the loss of up to (N-1)/2 nodes and remain healthy. However, if more nodes are lost, the database must be restored from a backup. A snapshot from a single member of the etcd ring is sufficient to restore the entire cluster.
* The Public Key Infrastructure (PKI) encompasses the Certificate Authority (CA), certificates, and keys required for Kubernetes authentication. Backing up the PKI is equally critical for a swift recovery.
* We recommend backing up etcd snapshots and the PKI every 30 minutes and storing these backups outside the cluster.
* A Kubernetes cronjob should handle this process: it runs every 30 minutes, collects the PKI data, captures an etcd snapshot, and can use the `restic` command-line tool to upload the data to the cluster-internal MinIO storage.

#### Kubernetes Objects
* While etcd and PKI backups are sufficient for restoring a broken cluster within the same environment, it is often necessary to restore a previous state within an otherwise functional cluster, or to migrate a previous state to an entirely new cluster.
* This is where Velero excels. Velero captures a snapshot of all objects within the cluster, enabling targeted state restoration (similar to executing `kubectl get <crd> <crd-name> -o yaml > my-object.yaml`).
* Velero is recommended to run, for example, every 6 hours.

#### MLA Data
* All Monitoring, Logging, and Alerting (MLA) configurations, including alerts and dashboards, are stored as infrastructure-as-code within the platform owner's codebase.
* Therefore, only the Prometheus database requires backing up. To balance performance and usability, we recommend backing up the database every 6 hours.
* Velero, in conjunction with its `restic` integration, can be utilized for this task.
* Velero extracts a dump of the Prometheus database and securely syncs it to the cluster-internal MinIO datastore.
* This process can be seamlessly integrated into the standard Velero backup cycle.

### User Clusters

#### etcd
* To restore the state of user clusters during disaster recovery, etcd database snapshots must be available.
* The Kubermatic Kubernetes Platform (KKP) provides a fully automated mechanism for the regular backup and restoration of user clusters via snapshots.
* This configuration must be applied on a per-cluster basis.
* We strongly recommend enabling this feature and scheduling it to run every 20 minutes. These snapshots are subsequently stored on the cluster-internal MinIO.

#### Workload
* Stateless user cluster workloads can be easily restored from etcd backups.
* However, once a user cluster runs stateful applications, additional measures are required.
* The Kubermatic Kubernetes Platform (KKP) provides a fully automated and integrated mechanism with Velero on user clusters to manage these backups, storing them on dedicated cloud storage.
* You can learn more about our Integrated User Cluster Backup feature here: [documentation of Integrated User Cluster Backup in KKP](cluster-backup/)

#### Data Replication
* Furthermore, we recommend designing any stateful application with built-in replication mechanisms. Storage should be replicated across multiple nodes, and ideally, across different datacenters or availability zones.

---

## Backup Schedule

Below is the suggested schedule configuration, categorized by backup job, frequency, and retention period (Time to Live - TTL).

| Backup Job | Schedule | TTL |
| :--- | :--- | :--- |
| KKP master control plane VM backups | Once daily | 3 days |
| MLA data (KKP master cluster objects + Prometheus data) | Every 6 hours | 168 hours (7 days) |
| KKP master etcd and PKI | Every 30 minutes | 24 hours |
| User-cluster control-planes | Every 20 minutes | Last 20 (~6.5 hours) |
| Cluster-internal backups | Every 30 minutes | Configured via External Storage Provider |

---

## Process

* To accelerate the recovery process and minimize human error, a comprehensive disaster recovery runbook must be documented.
* This runbook should provide explicit, step-by-step instructions detailing the appropriate recovery strategies for various failure scenarios.
* To validate both the recovery procedures and the runbook itself, regular disaster recovery drills are essential.
* The staging environment serves as an ideal platform for simulating these diverse disaster scenarios.
* These tests must be conducted at least annually and should be executed by various team members. 
* This practice ensures that the documentation remains current and prevents knowledge silos within the team.

## References for KubeOne cluster backup and restore

If KKP master and seed cluster lifecycle management is being done by KubeOne, you may find further information regarding backup strategies for KubeOne on the following links:

* [Backups Addon in KubeOne](../kubeone/main/examples/addons-backup/)
* [KubeOne Manual Cluster Recovery](../kubeone/main/guides/manual-cluster-recovery/)
* [KubeOne Manual Cluster Repair](../kubeone/main/guides/manual-cluster-repair/)


