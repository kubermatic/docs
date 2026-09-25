+++
title = "Key Algorithms for User Clusters"
date = 2026-09-23T12:00:00+02:00
weight = 140
+++

## Overview

KKP generates a set of private keys for every user cluster it creates: the keys behind the cluster's
certificate authorities and the certificates issued from them, and the key used to sign service account
tokens. The algorithm and size of these keys can be configured. By default they are RSA with a 2048 bit
modulus. Operators can select larger RSA keys or ECDSA to meet security or compliance requirements
without changing how the rest of the cluster is set up.

The configuration has two independent parts:

* **Certificates** covers the user cluster's internal PKI: the cluster CA and the front-proxy CA, the
  serving certificates of etcd and the Kubernetes API server, the client certificates of the control
  plane components, and the certificates of the KKP-managed webhooks and internal kubeconfigs.
* **Service Account Key** covers the key that signs service account tokens issued by the cluster. This key
  is visible outside of the cluster wherever service account tokens are validated, so it is configured
  separately from the certificates.

Each part accepts the same options:

| Option | Values | Notes |
|---|---|---|
| Algorithm | `RSA`, `ECDSA` | Defaults to `RSA`. |
| RSA key size | `2048`, `3072`, `4096` | Only valid with `RSA`. Defaults to `2048`. |
| ECDSA curve | `P256`, `P384` | Only valid with `ECDSA`. Defaults to `P256`. |

Leaving a part unconfigured uses RSA 2048 for that part.

Both parts share the same structure. The full specification is available in the CRD documentation as
[KeyConfiguration]({{< ref "../../../references/crds/#keyconfiguration" >}}) and
[KeySpec]({{< ref "../../../references/crds/#keyspec" >}}).

## Configuring a Global Default

The default for all newly created user clusters is set in the `KubermaticConfiguration` under
`spec.userCluster.keyConfiguration` (see
[KubermaticUserClusterConfiguration]({{< ref "../../../references/crds/#kubermaticuserclusterconfiguration" >}})):

```yaml
apiVersion: kubermatic.k8c.io/v1
kind: KubermaticConfiguration
metadata:
  name: kubermatic
  namespace: kubermatic
spec:
  userCluster:
    keyConfiguration:
      certificates:
        algorithm: ECDSA
        ecdsaCurve: P384
      serviceAccountKey:
        algorithm: RSA
        rsaKeySize: 4096
```

The setting is copied into every user cluster at the moment the cluster is created. Changing the global
default later only affects clusters created after the change; clusters that already exist keep the
key material they were created with.

## Configuring a Single Cluster

A cluster can deviate from the global default by setting `spec.keyConfiguration` in its own `Cluster`
object (see [ClusterSpec]({{< ref "../../../references/crds/#clusterspec" >}})) when it is created:

```yaml
apiVersion: kubermatic.k8c.io/v1
kind: Cluster
metadata:
  name: my-cluster
spec:
  # ...
  keyConfiguration:
    certificates:
      algorithm: RSA
      rsaKeySize: 4096
```

{{% notice note %}}
Only the parts that are set on the cluster override the global default. In the example above, the
service account key is not mentioned, so it still uses whatever the global default specifies for it.
{{% /notice %}}

The same field is available in cluster templates and in the defaulting template of a Seed, which makes
it possible to roll out a key configuration to a group of clusters. When a template and the cluster both
configure the same part, the cluster's own setting wins as a whole; settings are never mixed between the
two.

## Verifying the Configuration

The effective configuration of a cluster is stored on the `Cluster` object and can be read from there:

```bash
kubectl get cluster my-cluster -o jsonpath='{.spec.keyConfiguration}'
```

To confirm that the generated key material matches, inspect the cluster CA in the cluster's namespace
on the seed cluster:

```bash
kubectl --namespace cluster-my-cluster get secret ca -o jsonpath='{.data.ca\.crt}' | base64 -d | openssl x509 -noout -text | grep 'Public Key Algorithm' -A 1
```

## Important Notes

{{% notice warning %}}
The key configuration of a cluster is fixed once the cluster has been created. Changing it, or adding it
to a cluster that was created without one, is rejected. Rotating the key material of a running cluster
is not supported, so moving an existing cluster to a different algorithm or key size requires
recreating the cluster.
{{% /notice %}}

{{% notice info %}}
The setting only affects key material that KKP generates for a single user cluster. It does not cover:

* Certificates that KKP uses for itself, such as the certificate of the KKP webhook or of the Vertical
  Pod Autoscaler admission controller. These are always RSA 2048.
* The certificates used by the OpenVPN tunnel and by the user cluster monitoring, logging and alerting
  gateway. These are always ECDSA with the P256 curve.
* Certificates that nodes request themselves, such as kubelet certificates. They are signed by the cluster
  CA, but their keys are generated on the node.
{{% /notice %}}
