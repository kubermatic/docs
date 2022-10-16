+++
title = "Data Encryption at Rest"
date = 2022-05-27T12:00:00+02:00
weight = 100

+++

{{% notice warning %}}
This feature is in an early stage and considered a **preview feature**. It is **not recommended** to enable this for production environments due to potential data loss.
{{% /notice %}}

To secure sensitive data stored in Kubernetes resources (e.g. `Secrets`), that data can be encrypted at rest. In Kubernetes this means that data is encrypted while stored in etcd and is only decrypted when the resource is requested via a Kubernetes API request.

Data will either be encrypted with static encryption keys or via envelope encryption based on cloud provider KMS services (see [Configuring Encryption at Rest](#configuring-encryption-at-rest)). This feature is based on the [Kubernetes upstream feature for encrypting data at rest](https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/).

## Important Notes

- Data is only encrypted _at rest_ and not when requested by users with sufficient RBAC to access it. This means that the output of `kubectl get secret <secret> -o yaml` (or similar commands/actions) remains unencrypted and is only base64-encoded. Proper RBAC management is mandatory to secure secret data at all stages.
- Due to multiple revisions of data existing in etcd, [etcd backups]({{< ref "../etcd-backups/" >}}) might contain previous revisions of a resource that are unencrypted if the etcd backup is taken less than five minutes after data has been encrypted. Previous revisions are compacted every five minutes by `kube-apiserver`.

## Configuring Encryption at Rest

Encryption at rest can be configured by updating an existing `Cluster` resource via `kubectl edit cluster <Cluster ID>`. At the moment, a feature gate is required on the cluster to enable the feature. Here is an example of what `spec.encryptionConfiguration` can look like:

```yaml
# only a snippet, not valid on its own!
spec:
  features:
    encryptionAtRest: true
  encryptionConfiguration:
    enabled: true
    resources:
      - secrets
    secretbox:
      keys:
        - name: encryption-key-2022-01
          secretRef:
            name: encryption-key-2022-01
            key: key
```

Check out the [Kubermatic CRD documentation]({{< ref "../../references/crds/#encryptionconfiguration" >}}) for a full overview of the configuration options.

### Encrypted Resources

While most users might want to encrypt their `Secret` resources at rest, the encryption at rest feature is flexible enough to expand to other resource types. This can be useful if you have CRDs for custom resources that store sensitive data. A list of encrypted resources can be passed via `spec.encryptionConfiguration.resources`. At the moment, the list of resources is static and cannot be changed once encryption at rest is enabled. You will need to disable encryption at rest before re-configuring it. This might change in future versions of the feature.

Resource types should be passed in their plural form, all lowercase.

### Currently Available Encryption Providers

At the moment, the following encryption providers/schemes/methods are available:

#### Secretbox

The Secretbox encryption scheme can be configured via `spec.encryptionConfiguration.secretbox`. It takes static keys used for symmetric encryption using XSalsa20 and Poly1305.

Each key needs to be 32-byte long and needs to be base64-encoded. A key can be generated via `head -c 32 /dev/urandom | base64` on Linux, for example. Consider your IT security guidelines for a sufficiently secure way to generate such keys. Keys can be configured directly via `spec.encryptionConfiguration.secretbox.keys[].value`, which can be problematic when `Cluster` resources are stored in git or several people have access to `Cluster` resources. For those situations, `spec.encryptionConfiguration.secretbox.keys[].secretRef` allows to reference a `Secret` resource in the `Cluster`'s control plane namespace (usually `cluster-<Cluster ID>`).

```yaml
# snippet for directly passing a key
spec:
  encryptionConfiguration:
    enabled: true
    resources:
      - secrets
    secretbox:
      keys:
        - name: encryption-key-2022-01
          value: ynCl8otobs5NuHu$3TLghqwFXVpv6N//SE6ZVTimYok=
```

```
# snippet for referencing a secret
spec:
  encryptionConfiguration:
    enabled: true
    resources:
      - secrets
    secretbox:
      keys:
        - name: encryption-key-2022-01
          secretRef:
            name: encryption-key-2022-01
            key: key
```

If a key is referenced by a `secretRef`, KKP does not react to updates to the key `Secret` after it has been used for configuring encryption at rest. Follow the key rotation process with a new `Secret` if you want to update the active encryption key.

## Disabling Encryption at Rest

Once configured, encryption at rest can be disabled via setting `spec.encryptionConfiguration.enabled` to `false` or removing `spec.encryptionConfiguration` from the Cluster specification. KKP will reconfigure Kubernetes components and run a decryption job for existing resources.

## Querying Encryption Status

Since encryption at rest needs to reconfigure the control plane and re-encrypt existing data in a user cluster, applying changes to the encryption configuration can take a while. Encryption status can be queried via `kubectl`:

```sh
$ kubectl get cluster <Cluster ID> -o jsonpath="{.status.encryption.phase}"
Active
```

Only "Active" means that the configured encryption is fully applied.

## Rotating Encryption Keys

Occasionally, it might be necessary to rotate encryption keys for data encrypted at rest, for example on a regular basis as a good security practice or when a key has been compromised.

Key rotation can be facilitated by first adding a secondary key to the respective encryption provider that is configured (rotating between different providers is not supported). For example for Secretbox, you would reconfigure the example given earlier to include a secondary key:

```yaml
# only a snippet, not valid on its own!
spec:
  encryptionConfiguration:
    enabled: true
    resources:
      - secrets
    secretbox:
      keys:
        - name: encryption-key-2022-01
          secretRef:
            name: encryption-key-2022-01
            key: key
        - name: encryption-key-2022-02
          secretRef:
            name: encryption-key-2022-02
            key: key
```

This will configure the contents of `encryption-key-2022-02` as secondary encryption key. Secondary keys allow to decrypt data that is not encrypted with the primary key. This needs to be done so all control plane components can decrypt data once the key is rotated to be the primary key and is thus used to encrypt resources. KKP will rotate involved components, but will not run a re-encryption job, as data in etcd does not need to be encrypted again for this update.

After control plane components have been rotated, switch the position of the two keys in the `keys` array. The given example will look like this:


```yaml
# only a snippet, not valid on its own!
spec:
  encryptionConfiguration:
    enabled: true
    resources:
      - secrets
    secretbox:
      keys:
        - name: encryption-key-2022-02
          secretRef:
            name: encryption-key-2022-02
            key: key
        - name: encryption-key-2022-01
          secretRef:
            name: encryption-key-2022-01
            key: key
```

The secondary key now becomes the primary key. Data in etcd can still be read because the old key is still configured as a secondary key. KKP will reconfigure control plane components and launch a data re-encryption job for existing resources.

After data has been re-encrypted (check encryption status as per [Querying Encryption Status](#querying-encryption-status)) the old key can be removed from the configuration. Make sure to not remove it before that, as that will make data in etcd unreadable.
