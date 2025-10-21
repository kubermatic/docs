+++
title = "Configure via Dashboard"
date = 2025-10-14T12:00:00+02:00
weight = 10
+++

Encryption at rest secures sensitive data stored in Kubernetes resources by encrypting data while stored in etcd.

{{% notice note %}}
 Encryption at Rest is supported for `Secrets` resources only
{{% /notice %}}

## Overview

Encryption at rest protects sensitive data in your Kubernetes clusters by encrypting it before storage in etcd. The data is only decrypted when requested via Kubernetes API calls.

## Enable Encryption During Cluster Creation

You need to enable **Encryption at Rest** when creating the cluster. You can do this in the cluster creation step, under the **Specification** section.

![Enable Encryption at Rest](images/encryption-at-rest-enable.png?classes=shadow,border "Enable Encryption at Rest")

{{% notice info %}}
The encryption key for Encryption at Rest must be **32 bytes in length and base64-encoded**.
You can generate a suitable key using:

```bash
head -c 32 /dev/urandom | base64
```

**Important:** If you lose the encryption key, your encrypted Secret data will become unrecoverable.
Always store your keys securely and create backups before enabling or rotating them.
{{% /notice %}}

{{% notice warning %}}
When specifying the encryption key for Encryption at Rest, it must be a **valid 32-byte base64** encoded string.
If you provide an invalid or incorrectly base64-encoded key, the system will display an error and will not allow you to proceed.
{{% /notice %}}

{{< figure src="images/invalid-encryption-at-rest-key.png" width="500" height="auto" class="shadow border" alt="Enable Encryption at Rest" >}}


Complete the remaining cluster configuration steps and click **Create Cluster** to deploy your encrypted cluster.

You can also view whether the feature is enabled or disabled before creation—this can be checked at the wizard summary page.

![Cluster Wizard Summary ](images/encryption-at-rest-summary.png?classes=shadow,border "Wizard Summary")

## Verify Encryption Status

The cluster details page displays encryption status with visual indicators:

The encryption status of your cluster is indicated as follows:

- **Active**: Encryption is fully enabled and actively protecting your secrets.
- **Pending**: Encryption is being set up or changes are still being applied.
- **Disabled**: Encryption at rest is currently not enabled for this cluster.

{{% notice info %}}
No status indicator visible: Encryption at rest has never been **enabled** or **configured**.
{{% /notice %}}

![Encryption Status: Pending](images/encryption-at-rest-pending.png?classes=shadow,border "Encryption status is being applied")

![Encryption Status: Encryption Needed](images/encryption-at-rest-encryption-needed.png?classes=shadow,border "Encryption key required to enable encryption")

![Encryption Status: Active](images/encryption-at-rest-active.png?classes=shadow,border "Encryption at rest is active")

You can also use `kubectl` to check the encryption settings and real-time status of your cluster.

#### Check if Encryption at Rest is Enabled

Replace `<Cluster_ID>` with your actual cluster's identifier:

```bash
kubectl get cluster <Cluster_ID> -o jsonpath="{.spec.features.encryptionAtRest}"
```
If encryption is enabled, this will return `true`. If disabled, it will return `false`.

#### Check the Current Encryption Status

Use the following command to see the current encryption phase:

```bash
kubectl get cluster <Cluster_ID> -o jsonpath="{.status.encryption.phase}"
```

## Disable Encryption At Rest

{{< figure src="images/disable-encryption-at-rest.png" width="450" height="500" class="shadow border" alt="Already Status Active" >}}

{{% notice note %}}
To disable Encryption at Rest, you must uncheck the "Encryption at Rest" option and then click **Save Changes**. Simply toggling the checkbox does not immediately disable encryption; changes are only applied after saving.
{{% /notice %}}

{{< figure src="images/encryption-at-rest-disabled-successfully.png" class="shadow border" alt="Disabled Encryption At Rest Successfully" >}}

## Enable or Re-Enable Encryption on Existing Clusters

To enable Encryption at Rest for an existing cluster using the edit cluster dialog, provide an encryption key before saving. The process is similar to enabling encryption during cluster creation.

{{< figure src="images/enable-via-edit-cluster.png" width="450" height="500" class="shadow border" alt="Enabled Encryption At Rest" >}}

{{% notice note %}}
 If Encryption at Rest is already enabled, you must first disable it and save your changes. This process will decrypt resources that were encrypted with the old encryption key.
{{% /notice %}}

## View Encryption Status After Enabling via Edit Cluster

Once you enable or re-enable Encryption at Rest via the edit cluster dialog, the encryption status will be displayed in the cluster details page just like for clusters where encryption was enabled during creation. You will see the visual status indicators as described in the [Verify Encryption Status](#verify-encryption-status) section (e.g., **Active**, **Pending**, or **Disabled**) based on the current state of encryption for your cluster. 
