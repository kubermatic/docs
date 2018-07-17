+++
title = "Cloud Provider"
date = 2018-07-04T12:07:15+02:00
weight = 7
pre = "<b></b>"
+++

## Cloud Provider

### VSphere

The vsphere user has to have to following permissions on the correct resources:

#### Seed Cluster

* Role `k8c-storage-vmfolder-propagate`
  * Granted at __VM Folder__, propagated
  * Permissions
    * VirtualMachine
      * Config
        * AddExistingDisk
        * AddNewDisk
        * AddRemoveDevice
        * RemoveDisk

* Role `k8c-storage-datastore-propagate`
  * Granted at __Datastore__, propagated
  * Permissions
    * Datastore
      * AllocateSpace
      * FileManagement (Low level file operations)

* Role `Read-only` (predefined)
  * Granted at ..., **not** propagated
    * Datacenter

#### User Cluster

* Role `k8c-user-datacenter`
  * Granted at __datacenter__ level, **not** propagated
  * Needed for cloning the template VM (obviously this is not done in a folder at this time)
  * Permissions
    * Datastore
      * Allocate space
      * Browse datastore
      * Low level file operations
      * Remove file
    * vApp
      * vApp application configuration
      * vApp instance configuration
    * Virtual Machine
      * Change CPU count
      * Memory
      * Settings
    * Inventory
      * Create from existing

* Role `k8c-user-cluster-propagate`
  * Granted at __cluster__ level, propagated
  * Needed for upload of `cloud-init.iso`
  * Permissions
    * Host
      * Configuration
        * System Management
    * Resource
      * Assign virtual machine to resource pool

* Role `k8c-user-datastore-propagate`
  * Granted at __datastore / datastore cluster__ level, propagated
  * Permissions
    * Datastore
      * Allocate space
      * Browse datastore

* Role `k8c-user-folder-propagate`
  * Granted at __folder__ level, propagated
  * Needed for managing the node VMs
  * Permissions
    * Folder
      * Create folder
      * Delete folder
    * Virtual machine
      * Configuration
        * Add or remove device
      * Interaction
        * Power Off
        * Power On
      * Inventory
        * Remove
      * Provisioning
        * Clone virtual machine
      * Snapshot management
        * Create snapshot

### AWS

* Ensure that the seed cluster has (atleast) the following IAM permissions:

    ```json
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Sid": "VisualEditor0",
                "Effect": "Allow",
                "Action": [
                    "iam:ListRoles"
                ],
                "Resource": [
                    "arn:aws:iam::ACCOUNTID:role/",
                    "arn:aws:iam::ACCOUNTID:role/*"
                ]
            },
            {
                "Sid": "VisualEditor2",
                "Effect": "Allow",
                "Action": [
                    "iam:ListInstanceProfiles"
                ],
                "Resource": [
                    "arn:aws:iam::ACCOUNTID:instance-profile/"
                ]
            },
            {
                "Sid": "VisualEditor1",
                "Effect": "Allow",
                "Action": [
                    "iam:GetRole",
                    "iam:PassRole",
                    "iam:ListRolePolicies"
                    "iam:ListAttachedRolePolicies",
                    "iam:DeleteRolePolicy",
                    "iam:DetachRolePolicy"
                ],
                "Resource": [
                    "arn:aws:iam::ACCOUNTID:role/SpacesKubermatic",
                    "arn:aws:iam::ACCOUNTID:role/kubermatic-*"
                ]
            },
            {
                "Sid": "UseKubermaticRoles",
                "Effect": "Allow",
                "Action": [
                    "iam:AttachRolePolicy",
                    "iam:CreateRole",
                    "iam:DeleteRole"
                ],
                "Resource": [
                    "arn:aws:iam::ACCOUNTID:role/kubermatic-*"
                ]
            },
            {
                "Sid": "UseInstanceProfiles",
                "Effect": "Allow",
                "Action": [
                    "iam:CreateInstanceProfile",
                    "iam:GetInstanceProfile",
                    "iam:DeleteInstanceProfile",
                    "iam:AddRoleToInstanceProfile",
                    "iam:RemoveRoleFromInstanceProfile"
                ],
                "Resource": [
                    "arn:aws:iam::ACCOUNTID:instance-profile/kubermatic-*"
                ]
            }
        ]
    }
    ```
