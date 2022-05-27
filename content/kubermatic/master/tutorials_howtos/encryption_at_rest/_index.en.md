+++
title = "Data Encryption at Rest"
date = 2022-05-27T12:00:00+02:00
weight = 100

+++

{{% notice warning %}}
This feature is in an early stage and considered a **preview feature**. It is **not recommended** to enable this for production environments due to potential data loss.
{{% /notice %}}

To secure sensitive data stored in Kubernetes resources (e.g. `Secrets`), that data can be encrypted at rest. In Kubernetes this means that data is encrypted while stored in etcd and is only decrypted when the resource is requested via a Kubernetes API request.

Data will either be encrypted with static encryption keys or via envelope encryption based on cloud provider KMS services (see [Configuring Encryption at Rest](#configuring-encryption-at-rest)).

This feature is based on the [Kubernetes upstream feature for encrypting data at rest](https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/).

## Important Notes

- Data is only encrypted "at rest" and not when requested by users with sufficient RBAC to access it. This means that the output of `kubectl get secret <secret> -o yaml` (or similar commands/actions) remains unencrypted and is only base64-encoded. Proper RBAC management is mandatory to secure secret data at all stages.
- Due to multiple revisions of data existing in etcd, [etcd backups]({{< ref "../etcd_backups/" >}}) might contain previous revisions of a resource that are unencrypted if the etcd backup is taken less than five minutes after data has been encrypted. Previous revisions are compacted every five minutes by `kube-apiserver`.

## Configuring Encryption at Rest

### Validating that Data is Encrypted
