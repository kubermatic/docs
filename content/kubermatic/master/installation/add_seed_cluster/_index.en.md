+++
title = "Add Seed Cluster"
date = 2018-08-09T12:07:15+02:00
weight = 30
pre = "<b></b>"
+++

This document describes how a new seed cluster can be added to an existing Kubermatic master cluster.

### 1. Install Kubernetes cluster

First, you need to install a Kubernetes cluster with some additional components. After the installation of
Kubernetes you will need a copy of the `kubeconfig` to create a configuration for the new Kubermatic
master/seed setup.

To aid in setting up the seed and master clusters, we provide [KubeOne](https://github.com/kubermatic/kubeone/),
which can be used to set up a highly-available Kubernetes cluster. Refer to the [KubeOne readme](https://github.com/kubermatic/kubeone/)
and [docs](https://github.com/kubermatic/kubeone/tree/master/docs) for details on how to use it.

Please take note of the [recommended hardware and networking requirements](../../requirements/cluster_requirements/)
before provisioning a cluster.

### 2. Install Kubermatic Dependencies

Kubermatic requires the NodePort Proxy to be installed in each seed cluster. The proxy is shipped as a
[Helm](https://helm.sh) chart in the kubermatic-installer repository.

Install Helm's Tiller into the seed cluster first (when using Helm 2; Helm 3 does not use Tiller anymore):

```bash
kubectl create namespace kubermatic
kubectl create serviceaccount -n kubermatic tiller
kubectl create clusterrolebinding tiller-cluster-role --clusterrole=cluster-admin --serviceaccount=kubermatic:tiller
helm --service-account tiller --tiller-namespace kubermatic init
```

As the NodePort Proxy Docker image is in a private registry, you need to configure the Docker Pull Secret for
the Helm chart. Create a `helm-values.yaml` and configure it like so:

```yaml
kubermatic:
  # This is the base64 encoded Docker Pull Secret provided by Loodse. To create it, you can
  # put the Docker Pull Secret (JSON) into a file and then run `base64 docker-auth.json -w0`.
  imagePullSecretData: "<base64 encoded pull secret>"
```

With this you can install the chart:

```bash
helm --tiller-namespace kubermatic upgrade --install --values /path/to/your/helm-values.yaml --namespace nodeport-proxy nodeport-proxy charts/nodeport-proxy/
```

### 3. Create Seed resource in master cluster

To connect the new seed cluster with the master, you need to create a kubeconfig Secret and a Seed resource
in the master cluster. Make sure the kubeconfig contains static, long-lived credentials. Some cloud providers
use custom authentication providers (like GKE using gcloud and EKS using aws-iam-authenticator). Those will
not work in Kubermatic’s usecase because the required tools are not installed. You can use the
`kubeconfig-serviceaccounts.sh` script from the kubermatic-installer repository to automatically create proper
service accounts inside the cluster with static credentials.

The Seed resource then needs to reference the new kubeconfig Secret like so:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: kubeconfig-cluster1
  namespace: kubermatic
type: Opaque
data:
  kubeconfig: <base64 encoded kubeconfig>

---
apiVersion: kubermatic.k8s.io/v1
kind: Seed
metadata:
  name: cluster1
  namespace: kubermatic
spec:
  # these two fields are only informational
  country: DE
  location: Hamburg

  # list of datacenters where this seed cluster is allowed to create clusters in
  datacenters: []

  # reference to the kubeconfig to use when connecting to this seed cluster
  kubeconfig:
    name: kubeconfig-cluster1
    namespace: kubermatic
```

Refer to the [Seed documentation]({{< ref "../../concepts/seeds" >}}) for a complete example of the
Seed CustomResource and all possible datacenters.

Apply the manifest above in the master cluster and Kubermatic will pick up the new Seed and begin to
reconcile it by installing the required Kubermatic components.

### 4. Update DNS

The final step in the setup is to create a wildcard DNS record that points to the NodePort proxy LoadBalancer
inside the seed cluster. For this you first need to get the Service's IP/hostname via

```bash
kubectl -n nodeport-proxy get svc nodeport-lb
```

Take the `EXTERNAL IP` and create a DNS record in the form of `*.<seed-name>.<primary domain>`, for example
`*.cluster1.example.com`. Once this new DNS record is propagated through the network, you can start creating
user clusters in your new seed.
