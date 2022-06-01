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
- Due to multiple revisions of data existing in etcd, [etcd backups]({{< ref "../etcd_backups/" >}}) might contain previous revisions of a resource that are unencrypted if the etcd backup is taken less than five minutes after data has been encrypted. Previous revisions are compacted every five minutes by `kube-apiserver`.

## Configuring Encryption at Rest

At the moment, encryption at rest can only be configured via KKP's Kubernetes API custom resource type `Cluster`. For example, an existing cluster can be updated via `kubectl edit cluster <Cluster ID>`. Here is an example of what `spec.encryptionConfiguration` can look like:

```yaml
# only a snippet, not valid on its own!
spec:
    [...]
    encryptionConfiguration:
        enabled: true
        resources:
            - secrets
        secretbox:
            keys:
                - name: encryption-key-2022-01
                  secretRef:
                    name: encryption-key-2022
                    key: key
```

Check out the [Kubermatic CRD documentation]({{< ref "../../references/crds/#encryptionconfiguration" >}}) for a full overview of the configuration options.

### Encrypted Resources

While most users might want to encrypt their `Secret` resources at rest, the encryption at rest feature is flexible enough to expand to other resource types. This can be useful if you have CRDs for custom resources that store sensitive data. A list of encrypted resources can be passed via `spec.encryptionConfiguration.resources` (defaults to encrypting `Secret` resources if not configured).

Additional resource types should be passed in their plural form, all lowercase.

### Currently Available Encryption Schemes

At the moment, the following encryption schemes/methods are available:

#### Secretbox

The `secretbox` encryption scheme can be configured via `spec.encryptionConfiguration.secretbox`. It takes static keys used for symmetric encryption using XSalsa20 and Poly1305.

Each key needs to be 32-byte long and needs to be base64-encoded. A key can be generated via `head -c 32 /dev/urandom | base64` on Linux, for example. Consider your IT security guidelines for a sufficiently secure way to generate such keys. Keys can either be configured directly via `spec.encryptionConfiguration.secretbox.keys[].value`, which can be problematic when `Cluster` resources are stored in git or several people have access to `Cluster` resources. For those situations, `spec.encryptionConfiguration.secretbox.keys[].secretRef` allows to reference a `Secret` resource in the `Cluster`'s control plane namespace (usually `cluster-<Cluster ID>`).

If a key is referenced by a `secretRef`, KKP does not react to updates to the key `Secret` after it has been used for configuring encryption at rest. Follow the key rotation process with a new `Secret` if you want to update the active encryption key.

### Disabling Encryption at Rest

Once configured, encryption at rest can be disabled via setting `spec.encryptionConfiguration.enabled` to `false` or removing `spec.encryptionConfiguration` from the Cluster specification. KKP will reconfigure Kubernetes components and run a decryption job for existing resources.

