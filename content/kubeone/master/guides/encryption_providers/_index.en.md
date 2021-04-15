+++
title = "Enabling Kubernetes Encryption Providers"
date = 2021-04-14T12:00:00+02:00
enableToc = true
+++

Encryption Providers are supported by [Kubernetes](https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/) since version [v1.13](https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/).

Encryption Providers support is Kubernetes solution to implement data encryption at rest. When enabled, they cluster administrator can ensure that secrets and other sensitive Kubernetes resources are encrypted before they are stored in the etcd backend.

Kubernetes supports several [providers](https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/#providers). Additionally, it supports external Key management systems through the [KMS provider](https://kubernetes.io/docs/tasks/administer-cluster/kms-provider/).

## KubeOne Support

As of version v1.3, KubeOne provides managed support for Encryption Providers. The following operations are supported:
- Enabling/disabling Encryption Providers in KubeAPI.
- Rotating Encryption keys.
- Custom Encryption Providers configuration.


### Enabling Encryption Providers

To enable Encryption Providers support, the following section is added to the Cluster configuration file:

```yaml
apiVersion: kubeone.io/v1beta1
kind: KubeOneCluster
name: k1-cluster
versions:
  kubernetes: '1.18.6'
features:
  # enable encryption providers
  encryptionProviders:
    enable: true
```

For managed configuration, KubeOne will enable the Encryption Providers flag for KubeAPI and will pass a generated configuration file:

```yaml
apiVersion: apiserver.config.k8s.io/v1
kind: EncryptionConfiguration
resources:
- providers:
  - aescbc:
      keys:
      - name: kubeone-xkau31
       secret: 6utsip/8CJ1GFQpM6iWq4oL2z2g8tJ5UkGbIgkSWAAc=
  - identity: {}
  resources:
  - secrets
```

By default, KubeOne will use the AESCBC provider and will generate a randomize key for it. Also, only `secret` resources are encrypted.

Once KubeOne has pushed the configuration file and updated KubeAPI flags as required, it will restart the KubeAPI and ensure all secret resources are rewritten with encryption enabled.

{{% notice note %}}
To enable Encryption Providers support for existing cluster, you must use the `--force-upgrade` flag to apply the feature.
{{% /notice %}}


### Disabling Encryption Providers

To disable this feature, simply set the `enable` option to `false` and upgrade your cluster with the `--force-upgrade flag:


```yaml
apiVersion: kubeone.io/v1beta1
kind: KubeOneCluster
name: k1-cluster
versions:
  kubernetes: '1.18.6'
features:
  # enable encryption providers
  encryptionProviders:
    enable: false
```

```bash
$ kubeone apply --manifest kubeone.yaml --tfjson output.json --force-upgrade
```

KubeOne will remove the configuration file from the Control Plane node and update KubeAPI flags. Additionally, it will rewrite all secret resources again to ensure that they are written back in plain text.


### Rotating Encryption keys

KubeOne also supports rotating encryption keys to allow having a rotation policy for secret keys. The new `--rotate-encryption-key` flag is added to the `apply` for this. 

```bash
$ kubeone apply --manifest kubeone.yaml --tfjson output.json --force-upgrade --rotate-encryption-key
```

{{% notice note %}}
Similar to how enable/disable work, to rotate they key, you need to use the `--force-upgrade` flag as well.
{{% /notice %}}

During rotation, KubeOne will apply [several steps](https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/#rotating-a-decryption-key) that involve restarting the KubeAPI and rewriting the cluster secrets.


### Custom Encryption Providers configuration

KubeOne allows advanced users to manage their own configuration as well, for advanced use cases as specifying multiple resources to encrypt, using multiple key providers or using an external KMS.

However, unlink the managed configuration, for custom configuration files, KubeOne only push the configuration file the control plane nodes and manage the KubeAPI flags only. It will not handle the content of the configuration file. This means that managed key rotation for example is not supported with custom configuration.

When custom configuration is used, the user will be responsible for managing the configuration to apply the steps required for the [enable](https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/#encrypting-your-data), [disable](https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/#decrypting-all-data) and [rotate](https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/#rotating-a-decryption-key) processes.

To use custom configuration, you simply add them inline to your KubeOne cluster configuration:

```yaml
apiVersion: kubeone.io/v1beta1
kind: KubeOneCluster
name: k1-cluster
versions:
  kubernetes: '1.18.6'
features:
  encryptionProviders:
    enable: true
    customEncryptionConfiguration: |
      apiVersion: apiserver.config.k8s.io/v1
      kind: EncryptionConfiguration
      resources:
      - providers:
        - aescbc:
            keys:
            - name: custom-key
              secret: lsn9B5vaIePTsbH2cxxzB0EfbBIZkYplC1fwfiNksJo=
        - identity: {}
        resources:
        - secrets
```

## A Note About Backups

It's important to understand that the data will be encrypted during the etcd backup operation as well. This means that when restoring a backup, the cluster should be configured using the same encryption key that was used during the backup. If that's not the case, the KubeAPI will not be able to access the encrypted data.

