+++
title = "Enabling Kubernetes Encryption Providers"
date = 2021-04-14T12:00:00+02:00
enableToc = true
+++

Encryption Providers support is a Kubernetes solution to implement data
encryption at rest. When enabled, the cluster administrator can ensure that
secrets and other sensitive Kubernetes resources are encrypted before they are
stored in the etcd backend.

Kubernetes supports several [providers][k8s-encryption-providers].
Additionally, it supports external Key Management Systems (KMS) through the
[KMS provider][kms-provider].

Encryption Providers are supported by [Kubernetes][k8s-encrypt-data] since
v1.13.

## KubeOne Support

KubeOne provides managed support for Encryption Providers as of v1.3.
The following operations are supported:

- Enabling/disabling Encryption Providers
- Rotating Encryption keys
- Using custom Encryption Providers configuration

## Enabling Encryption Providers

To enable Encryption Providers support, the following section is added to the
KubeOne Cluster configuration manifest:

```yaml
apiVersion: kubeone.k8c.io/v1beta2
kind: KubeOneCluster
name: k1-cluster
versions:
  kubernetes: '1.22.5'
features:
  # enable encryption providers
  encryptionProviders:
    enable: true
```

For managed configuration, KubeOne will enable the Encryption Providers flag
for the Kubernetes API server and will pass a generated configuration file such
as the following one:

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

By default, KubeOne will use the AESCBC provider and will generate a randomized
key for it. Also, only `secret` resources are encrypted.

Once KubeOne has pushed the configuration file and updated the kube-apiserver
flags as required, it will restart the kube-apiserver pods and ensure all
secret resources are rewritten with encryption enabled.

{{% notice note %}}
To enable Encryption Providers support for existing cluster, you must
run `kubeone apply --force-upgrade` to apply the feature.
{{% /notice %}}


## Disabling Encryption Providers

To disable this feature, simply set the `enable` option to `false` and upgrade
your cluster with the `--force-upgrade` flag:

```yaml
apiVersion: kubeone.k8c.io/v1beta2
kind: KubeOneCluster
name: k1-cluster
versions:
  kubernetes: '1.22.5'
features:
  # enable encryption providers
  encryptionProviders:
    enable: false
```

```bash
kubeone apply --manifest kubeone.yaml --tfjson output.json --force-upgrade
```

KubeOne will remove the configuration file from the control plane nodes and
update the kube-apiserver flags. Additionally, it will rewrite all secret
resources again to ensure that they are written back in plain text.

## Rotating Encryption keys

KubeOne also supports rotating encryption keys to allow having a rotation
policy for secret keys. The new `--rotate-encryption-key` flag is added to
the `apply` command for this. 

```bash
kubeone apply --manifest kubeone.yaml --tfjson output.json --force-upgrade --rotate-encryption-key
```

{{% notice note %}}
Similar to how enable/disable work, to rotate they key, you need to use the
`--force-upgrade` flag as well.
{{% /notice %}}

During rotation, KubeOne will apply [several steps][k8s-rotating-key] that
involve restarting the kube-apiserver pods and rewriting the cluster secrets.

## Custom Encryption Providers configuration

KubeOne allows advanced users to manage their own configuration as well,
for advanced use cases such as specifying multiple resources to encrypt,
using multiple key providers or using an external KMS.

However, unlink the managed configuration, for custom configuration files,
KubeOne only push the configuration file the control plane nodes and manage the
kube-apiserver flags. It will not handle the content of the configuration file.
This means that managed key rotation is not supported with custom
configuration.

When custom configuration is used, the user will be responsible for managing
the configuration to apply the steps required for 
[enable][k8s-encrypt-data-enable], [disable][k8s-encrypt-data-disable]
and [rotate][k8s-rotating-key] processes.

To use custom configuration, you simply add them inline to your KubeOne cluster
configuration manifest:

```yaml
apiVersion: kubeone.k8c.io/v1beta2
kind: KubeOneCluster
name: k1-cluster
versions:
  kubernetes: '1.22.5'
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
### Using an external KMS Provider

It is possible to use KubeOne to configure your Kubernetes cluster to use an external [Key Management System][Key-Management-System]. This provides an additional layer of security since it doesn't require storing the a plain text key on control plane nodes.

Kubernetes requires using a KMS plugin to be able to communicate with the external KMS providers. Most cloud providers have KMS plugin implementations to allow Kubernetes to use their KMS services. For example:
- [AWS Encryption Provider][AWS-Encryption-Provider]
- [Azure KMS Plugin][Azure-KMS-Plugin]
- [Google Cloud KMS plugin][Google-Cloud-KMS-plugin]

Kubernetes communicates with the KMS Encryption Provider through a unix socket. For this to work, the cluster administrator needs to deploy KMS plugin on all control plane nodes. The plugin can be deployed as binary, a standalone docker container, a static pod or as a Daemonset configured to run only the control plan nodes. KubeOne will detect the unix socket path from the custom configuration and add a bind-mount to the KubeAPI static pod to allow it to communicate to the KMS plugins.

An example of custom encryption providers configuration to enable AWS Encryption Provider would look like this:

```yaml
apiVersion: kubeone.k8c.io/v1beta2
kind: KubeOneCluster
name: kms-test
versions:
  kubernetes: '1.22.5'
cloudProvider:
  aws: {}
features:
  encryptionProviders:
    enable: true
    customEncryptionConfiguration: |
      apiVersion: apiserver.config.k8s.io/v1
      kind: EncryptionConfiguration
      resources:
        - resources:
          - secrets
          providers:
          - identity: {}
          - kms:
              name: aws-encryption-provider
              endpoint: unix:///var/run/kmsplugin/socket.sock
              cachesize: 1000
              timeout: 3s
```


## A Note About Backups

It's important to understand that the data will be encrypted during the etcd
backup operation as well. This means that when restoring a backup, the cluster
should be configured using the same encryption key that was used during the
backup. If that's not the case, the Kubernetes API server will not be able to
access the encrypted data.

[k8s-encryption-providers]: https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/#providers
[kms-provider]: https://kubernetes.io/docs/tasks/administer-cluster/kms-provider/
[k8s-encrypt-data]: https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/
[k8s-rotating-key]: https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/#rotating-a-decryption-key
[k8s-encrypt-data-enable]: https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/#encrypting-your-data
[k8s-encrypt-data-disable]: https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/#decrypting-all-data
[Key-Management-System]: https://kubernetes.io/docs/tasks/administer-cluster/kms-provider/
[AWS-Encryption-Provider]: https://github.com/kubernetes-sigs/aws-encryption-provider
[Azure-KMS-Plugin]: https://github.com/Azure/kubernetes-kms
[Google-Cloud-KMS-plugin]: https://github.com/GoogleCloudPlatform/k8s-cloudkms-plugin