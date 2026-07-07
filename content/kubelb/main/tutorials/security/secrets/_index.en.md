+++
title = "Bring Your Own Secrets"
linkTitle = "Bring Your Own Secrets"
date = 2023-10-27T10:07:15+02:00
weight = 6
+++

To propagate secrets from the tenant to the management cluster, KubeLB provides the custom resource `SyncSecret`, a wrapper over the native Kubernetes secret. It ensures that no secrets from the management cluster are exposed to the tenants.

## SyncSecret Example

### Native Kubernetes Secret

```
kind: Secret
apiVersion: v1
metadata:
  name: mongodb-credentials
stringData:
  mongodb-password: "123456"
  mongodb-root-password: "123456"
type: Opaque
```

### Converted to a Sync Secret

```
kind: SyncSecret
apiVersion: kubelb.k8c.io/v1alpha1
metadata:
  name: mongodb-credentials
stringData:
  mongodb-password: "123456"
  mongodb-root-password: "123456"
type: Opaque
```

### Automation

To automate the process of creating SyncSecrets from kubernetes secrets, re-deploy the kubeLB CCM with the following modifications:

```yaml
kubelb:
    enableSecretSynchronizer: true
```

This would assign CRUD access for secrets to KubeLB controller and enable a syncer that can convert secrets labelled with `kubelb.k8c.io/managed-by: kubelb` to SyncSecrets.
