+++
title = "Using the Operator"
date = 2020-02-04T12:07:15+02:00
weight = 30
pre = "<b></b>"
+++

The Kubermatic Operator is the replacement for the Kubermatic Helm chart and currently in beta phase and not recommended for production use. This document details the requirements and installation procedure for the operator.

{{% notice warning %}}
The operator is not yet considered ready for production use.
{{% /notice %}}

### Before You Start

For installing the operator and running Kubermatic, you need

* cluster-admin access to the Kubernetes cluster,
* the ability to create DNS records and
* access to the private quay.io/kubermatic account.

Please also familiarize yourself with the [master/seed architecture]({{< ref "../../concepts/architecture" >}}) before continuing.

### Master Cluster Installation

The required components for running Kubermatic are still installed via Helm. These include

* cert-manager
* nginx-ingress-controller
* oauth (Dex, the OpenID provider)

for a master cluster. In every seed cluster, the following charts need to be installed:

* nodeport-proxy

On shared master/seed clusters, install all charts mentioned above.

#### Install Helm/Tiller

When using [Helm](https://www.helm.sh/) 2.x, install Tiller with RBAC enabled into your cluster:

```bash
kubectl create namespace kubermatic
kubectl create serviceaccount -n kubermatic tiller
kubectl create clusterrolebinding tiller-cluster-role --clusterrole=cluster-admin --serviceaccount=kubermatic:tiller
helm --service-account tiller --tiller-namespace kubermatic init
```

Helm 3.x does not require installing Tiller anymore.

#### Install Helm Charts

The Helm charts require a bit of customizations to fully work. It's recommended to use a single `values.yaml` to configure
all charts. There are a few mandatory changes you have to make and the following YAML snippets shows which ones:

```yaml
dex:
  ingress:
    # This is your primary domain under which Kubermatic's dashboard/API shall be available,
    # for example "example.com".
    host: "<your domain here>"

  clients:
  - id: kubermatic
    name: Kubermatic
    # generate a random secret here, e.g. via `cat /dev/urandom | tr -dc A-Za-z0-9 | head -c32`;
    # this secret needs to be configured in the KubermaticConfiguration later on as well
    secret: "<random secret>"
    RedirectURIs:
    - "https://<your domain here>"
    - "https://<your domain here>/projects"
```

Check the [Helm charts](https://github.com/kubermatic/kubermatic-installer/tree/release/v2.12/charts)
for more information about the available options.

With the configuration ready, it's time to install the charts. Clone/download the
[kubermatic-installer](https://github.com/kubermatic/kubermatic-installer) repository and open
a terminal in there. Then run the following commands.

```bash
helm --tiller-namespace kubermatic upgrade --install --values /path/to/your/values.yaml --namespace oauth oauth charts/oauth/
helm --tiller-namespace kubermatic upgrade --install --values /path/to/your/values.yaml --namespace cert-manager cert-manager charts/cert-manager/
helm --tiller-namespace kubermatic upgrade --install --values /path/to/your/values.yaml --namespace nginx-ingress-controller nginx-ingress-controller charts/nginx-ingress-controller/
```

#### Update Your DNS

The nginx-ingress-controller will by default create a LoadBalancer Service. We need to configure the primary domain
to point to this LoadBalancers. Check the external IPs Kubernetes created by running

```bash
kubectl -n nginx-ingress-controller get svc nginx-ingress-controller
```

You need to point your primary domain to the nginx-ingress-controller LoadBalancer.

#### Install CRDs

Kubermatic ships with a number of Custom Resource Definitions (CRDs) that need to be installed. They are available
in the kubermatic-installer repo as well:

```bash
kubectl apply -f manifests/kubermatic-crds.yaml
```

#### Install Kubermatic Operator

Now we can finally install the operator itself, again with the manifest from the kubermatic-installer repository:

```bash
kubectl apply -f manifests/kubermatic-operator.yaml
```

You also need to create a `dockercfg` Secret with the Docker credentials. The Secret should look like this:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: dockercfg
  namespace: kubermatic
type: kubernetes.io/dockerconfigjson
data:
  .dockerconfigjson: <base64 encoded Docker config JSON here>
```

Note that the operator is only installed into master clusters and will manage seed clusters from there.

#### Configure Kubermatic

The operator does nothing without a `KubermaticConfiguration` resource in the same namespace. This CRD contains all the various things that can
be configured in Kubermatic. An [example with all possible fields]({{< ref "../../concepts/kubermaticconfiguration" >}}) is available. But for a
basic setup only the required information needs to be set and the operator will then apply the default values itself. The most minimal
Kubermatic configuration looks like this:

```yaml
apiVersion: operator.kubermatic.io/v1alpha1
kind: KubermaticConfiguration
metadata:
  name: kubermatic
  namespace: kubermatic
spec:
  imagePullSecret: |
    <Docker Pull Secret as JSON>

  ingress:
    domain: "<primary domain>"

  auth:
    # This secret needs to match the `dex.clients` secret from the helm-values.yaml.
    issuerClientSecret: "<client secret>"

    # These two need to be randomly generated, e.g. via `cat /dev/urandom | tr -dc A-Za-z0-9 | head -c32`
    issuerCookieKey: "<secret>"
    serviceAccountKey: "<secret>"
```

Save this as a YAML file somewhere and then apply it:

```bash
kubectl apply -f kubermatic.yaml
```

This will now make the operator deploy a Master setup for Kubermatic, including a certificate. This certificate then needs to be fulfilled
by the cert-manager in order for Kubermatic to work. Check the cert-manager's progress by observing the certificate resource:

```bash
watch kubectl -n kubermatic get certs
```

Once the certificate shows `READY=true`, the Kubermatic pods should come up. Observe the progress by running

```bash
watch kubectl -n kubermatic get pods
```

Congratulations, your Kubermatic is up and running! You should now be able to access the dashboard by visiting `https://<your primary domain>/`.

#### Next Steps

Now that the master cluster is running, it's time to [add a seed cluster]({{< ref "../add_seed_cluster" >}}) and some datacenters.
Afterwards you will be able to create your first clusters using Kubermatic.
