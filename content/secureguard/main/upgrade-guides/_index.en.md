+++
title = "Upgrade Guides"
date = 2026-06-13T09:00:00+02:00
weight = 10
description = "Best practices for upgrading SecureGuard components — OpenBao snapshots, ESO CRD upgrades, and rolling updates for the UI, proxy, and SG Agent."
sitemapexclude = true
searchexclude = true
private = true
+++

Keeping SecureGuard updated ensures you have the latest security patches for OpenBao, Dex, ESO, and the UI components. This guide outlines the best practices for upgrading a production deployment.

## General Upgrade Path

Because SecureGuard is deployed via Helm, upgrades follow the standard Helm release lifecycle.

{{% notice note %}}
OCI-based Helm charts do not require `helm repo add` or `helm repo update`. Simply run `helm upgrade` with the registry URL.
{{% /notice %}}

1. **Review the Release Notes** in the SecureGuard repository for any breaking changes or manual migration steps.
2. **Execute the Upgrade**, passing your custom `values-production.yaml` file to preserve your HA, ingress, and IDP configurations.
   ```bash
   helm upgrade secureguard oci://quay.io/kubermatic/helm-charts/secureguard \
     -f values-production.yaml \
     --namespace secureguard-system
   ```

## Pre-Upgrade Requirement: OpenBao Backups (Snapshots)

{{% notice warning %}}
**CRITICAL:** Before performing any upgrade, especially one that bumps the OpenBao major/minor version, you MUST take a snapshot of the OpenBao integrated storage (Raft). Failure to do so risks catastrophic data loss if the upgrade fails.
{{% /notice %}}

1.  Authenticate to OpenBao with a privileged token:
    ```bash
    kubectl exec -it secureguard-openbao-0 -n secureguard-system -- /bin/sh
    bao login <root-or-admin-token>
    ```

2.  Trigger the snapshot and save it locally:
    ```bash
    bao operator raft snapshot save /tmp/backup.snap
    ```

3.  Copy the snapshot out of the pod to secure cold storage:
    ```bash
    kubectl cp secureguard-system/secureguard-openbao-0:/tmp/backup.snap ./vault_backup_$(date +%F).snap
    ```

## Component Specifics

### Upgrading OpenBao

When Helm updates the OpenBao StatefulSet image version, Kubernetes will perform a rolling restart of the OpenBao pods.

*   **HA Clusters (Raft)**: The rolling restart must be monitored carefully. When a pod restarts, it will trigger leader election. Ensure that the cluster remains quorate during the roll.
*   **Auto-Unseal**: If you have configured Auto-Unseal (e.g., AWS KMS), the pods will automatically unseal and rejoin the cluster upon starting.
*   **Manual Unseal**: If you are *not* using Auto-Unseal, the pods will restart into a `Sealed` state. You must manually execute the `bao operator unseal` commands on each newly started pod *before* the StatefulSet controller proceeds to restart the next pod. This requires active operator intervention during the `helm upgrade`.

### Upgrading the External Secrets Operator (ESO) CRDs

Helm does not automatically upgrade Custom Resource Definitions (CRDs) during a `helm upgrade` command to prevent accidental deletion of stored data.

If a new version of SecureGuard bumps the ESO version and introduces new CRD fields, you must manually apply the updated CRDs before upgrading the Helm chart.

1. Download the new CRD manifests corresponding to the ESO version packaged in the new chart.
2. Apply them directly:
   ```bash
   kubectl apply -f https://raw.githubusercontent.com/external-secrets/external-secrets/v<NEW_VERSION>/deploy/crds/bundle.yaml
   ```
3. Make the new release selectable in the dashboard by adding it to the **ESO
   Version Catalog**: apply a new `ESOVersion` CR (and move the `latest: true`
   flag onto it). See [Advanced Configuration → ESO Version Catalog]({{< ref "../advanced-configuration/#eso-version-catalog-esoversion-crd" >}}).
   Only ESO `v2.0.0` and newer are supported.

### Upgrading the SecureGuard UI and Proxy

The React UI and **Go proxy** are stateless applications deployed as standard Kubernetes Deployments. Helm will perform a standard rolling rollout of the new ReplicaSets, ensuring zero-downtime availability of the dashboard during the upgrade.

### Upgrading the SG Agent Controller

The SG Agent Controller (`agent/`) is a Go controller-runtime binary deployed as a Kubernetes Deployment. It follows the same rolling update pattern as the proxy — Helm will perform a standard rolling rollout of the new ReplicaSet. No special migration steps are required; the controller is stateless and will automatically resume reconciliation of SGAgent and ESODeployment resources after restart.
