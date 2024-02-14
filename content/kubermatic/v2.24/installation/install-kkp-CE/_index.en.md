+++
title = "Install Kubermatic Kubernetes Platform (KKP) CE"
linkTitle = "Install Community Edition"
date = 2018-04-28T12:07:15+02:00
weight = 10
enableToc = true
+++

Kubermatic Kubernetes Platform (KKP) is a Kubernetes management platform that helps address the operational and security challenges of enterprise customers seeking to run Kubernetes at scale. KKP automates deployment and operations of hundreds or thousands of Kubernetes clusters across hybrid-cloud, multi-cloud and edge environments while enabling DevOps teams with a self-service developer and operations portal. If you are looking for more general information on KKP, we recommend our [documentation start page]({{< ref "../../" >}}) and the [Architecture section of the documentation]({{< ref "../../architecture/" >}}) to get familiar with KKP's core concepts.

This chapter explains the installation procedure of KKP into a pre-existing Kubernetes cluster using KKP's installer (called `kubermatic-installer`). KKP can be installed on any infrastructure provider that can host a Kubernetes cluster, i.e. any major cloud provider like Amazon Web Services (AWS), Azure, Google Cloud Platform (GCP), Digital Ocean or Hetzner. Private infrastructure providers like vSphere, OpenStack or Nutanix are supported as well, e.g. by using [KubeOne](https://docs.kubermatic.com/kubeone/). See [Set up Kubernetes](#set-up-kubernetes) for details.

Typically the setup of KKP cluster, including creation of a base Kubernetes cluster on which KKP is deployed, should be no more than 2 hours. Inclusive of preparation of the Infrastructure.

Expected skills and knowledge for the installation: moderate level of familiarity with cloud services (like AWS, Azure, GCP or others) and familiarity with container and Kubernetes technologies, constructs, and configurations.

## Terminology

In this chapter, you will find the following KKP-specific terms:

* **Master Cluster** -- A Kubernetes cluster which is responsible for storing central information about users, projects and SSH keys. It hosts the KKP master components and might also act as a seed cluster.
* **Seed Cluster** -- A Kubernetes cluster which is responsible for hosting the control plane components (kube-apiserver, kube-scheduler, kube-controller-manager, etcd and more) of a User Cluster.
* **User Cluster** -- A Kubernetes cluster created and managed by KKP, hosting applications managed by users.

It is also recommended to make yourself familiar with our [architecture documentation]({{< ref "../../architecture/" >}}).

## Requirements

{{% notice warning %}}
This guide assumes a clean installation into an empty cluster. Please refer to the [upgrade notes]({{< ref "../upgrading/upgrade-from-2.23-to-2.24/" >}}) for more information on
migrating existing installations.
{{% /notice %}}

For this guide you need to have [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl) and [Helm](https://www.helm.sh/) (version 3) installed locally.
You should be familiar with core Kubernetes concepts and the YAML file format before proceeding.

<!-- TODO Add quotas for additional providers-->
In addition, we recommend familiarizing yourself with the resource quota system of your infrastructure provider. It is important to provide enough capacity to let KKP provision infrastructure for your future user clusters, but also to enforce a maximum to protect against overspending.

{{< tabs name="resource-quotas" >}}
{{% tab name="AWS" %}}
AWS manages service quotas per region. Please refer to the [official AWS service quotas documentation](https://docs.aws.amazon.com/general/latest/gr/aws_service_limits.html) for further details.
{{% /tab %}}
{{< /tabs >}}

### Plan Your Architecture

Before getting started we strongly recommend you to think ahead and model your KKP setup. In particular you should decide if you want Master and Seed components
to share the same cluster (a shared Master/Seed setup) or run Master and Seed on two separate clusters. See [our architecture overview]({{< ref "../../architecture/" >}}) for
a visual representation of the KKP architecture. A shared Master/Seed is useful for getting up and running quickly, while separate clusters will allow to scale
your KKP environment better.

Depending on which choice you make, you will need to have either one or two Kubernetes clusters available before starting with the KKP setup.

If you would like to run multiple Seeds to scale your setup beyond a single Seed, please check out the [Enterprise Edition]({{< ref "../install-kkp-EE/" >}})
as that feature is only available there.

### Set Up Kubernetes

To aid in setting up the Seed and Master Clusters, we provide [KubeOne](https://github.com/kubermatic/kubeone/), which can be used to set up a highly-available Kubernetes cluster.
Refer to the [KubeOne documentation](https://docs.kubermatic.com/kubeone) for details on how to use it.

Please take note of the [recommended hardware and networking requirements]({{< ref "../../architecture/requirements/cluster-requirements/" >}}) before provisioning a cluster.
Resource requirements on Seed Clusters or combined Master/Seed Clusters grow with each created User Cluster. As such, it is advised to plan ahead and provision enough capacity
to host the anticipated number of User Clusters. If you are using KubeOne, configuring the cluster-autoscaler addon might be a good idea to provide enough resources while the
number of User Clusters grows.

## Installation

Make sure you have a kubeconfig for the desired Master Cluster available. It needs to have `cluster-admin` permissions on that cluster to install all KKP master components.

The installer will use the `KUBECONFIG` environment variable to pick up the right kubeconfig to access the designated Master Cluster. Ensure that you
have exported it, for example like this (on Linux and macOS):

```bash
export KUBECONFIG=/path/to/master/kubeconfig
```

### Download the Installer

Download the [release archive from our GitHub release page](https://github.com/kubermatic/kubermatic/releases/) (e.g. `kubermatic-ce-X.Y-linux-amd64.tar.gz`)
containing the Kubermatic Installer and the required Helm charts for your operating system and extract it locally. Note that
for Windows `zip` files are provided instead of `tar.gz` files.

{{< tabs name="Download the installer" >}}
{{% tab name="Linux" %}}
```bash
# For latest version:
VERSION=$(curl -w '%{url_effective}' -I -L -s -S https://github.com/kubermatic/kubermatic/releases/latest -o /dev/null | sed -e 's|.*/v||')
# For specific version set it explicitly:
# VERSION=2.24.x
wget https://github.com/kubermatic/kubermatic/releases/download/v${VERSION}/kubermatic-ce-v${VERSION}-linux-amd64.tar.gz
tar -xzvf kubermatic-ce-v${VERSION}-linux-amd64.tar.gz
```
{{% /tab %}}
{{% tab name="MacOS" %}}
```bash
# Determine your macOS processor architecture type
# Replace 'amd64' with 'arm64' if using an Apple Silicon (M1) Mac.
export ARCH=amd64
# For latest version:
VERSION=$(curl -w '%{url_effective}' -I -L -s -S https://github.com/kubermatic/kubermatic/releases/latest -o /dev/null | sed -e 's|.*/v||')
# For specific version set it explicitly:
# VERSION=2.24.x
wget "https://github.com/kubermatic/kubermatic/releases/download/v${VERSION}/kubermatic-ce-v${VERSION}-darwin-${ARCH}.tar.gz"
tar -xzvf "kubermatic-ce-v${VERSION}-darwin-${ARCH}.tar.gz"
```
{{% /tab %}}
{{< /tabs >}}

### Prepare Configuration

The installation and configuration for a KKP system consists of two important files:

* A `values.yaml` used to configure the various Helm charts KKP ships with. This is where nginx, Prometheus,
  Dex, etc. can be adjusted to the target environment. A single `values.yaml` is used to configure all Helm charts
  combined.
* A `kubermatic.yaml` that configures KKP itself and is an instance of the
  [KubermaticConfiguration]({{< ref "../../references/crds/#kubermaticconfiguration" >}}) CRD. This configuration will
  be stored in the cluster and serves as the basis for the Kubermatic Operator to manage the actual KKP installation.

{{% notice warning %}}
Both files will include secret data, so make sure to securely store them (e.g. in a secret vault) and not share them freely.
{{% /notice %}}

The release archive hosted on GitHub contains examples for both of the configuration files (`values.example.yaml` and
`kubermatic.example.yaml`). It's a good idea to take them as a starting point and add more options as necessary.

The key items to consider while preparing your configuration files are described in the table below.

| Description                                                                          | YAML Paths and File                                                                         |
| ------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------- |
| The base domain under which KKP shall be accessible (e.g. `kubermatic.example.com`). | `.spec.ingress.domain` (`kubermatic.yaml`), `.dex.ingress.host` (`values.yaml`); also adjust `.dex.clients[*].RedirectURIs` (`values.yaml`) according to your domain. |
| The certificate issuer for KKP (KKP requires that its dashboard and Dex are only accessible via HTTPS); by default cert-manager is used, but you have to reference an issuer that you need to create later on. | `.spec.ingress.certificateIssuer.name` (`kubermatic.yaml`) |
| For proper authentication shared secrets must be configured between Dex and KKP. Likewise, Dex uses yet another random secret to encrypt cookies stored in the users' browsers. | `.dex.clients[*].secret` (`values.yaml`), `.spec.auth.issuerClientSecret` (`kubermatic.yaml`; this needs to be equal to `.dex.clients[name=="kubermaticIssuer"].secret` from `values.yaml`), `.spec.auth.issuerCookieKey` and `.spec.auth.serviceAccountKey` (both `kubermatic.yaml`) |
| To authenticate via an external identity provider you need to set up connectors in Dex. Check out [the Dex documentation](https://dexidp.io/docs/connectors/) for a list of available providers. This is not required but highly recommended for multi-user installations. | `.dex.connectors` (`values.yaml`; not included in example file) |
| The expose strategy which controls how control plane components of a User Cluster are exposed to worker nodes and users. See [the expose strategy documentation]({{< ref "../../tutorials-howtos/networking/expose-strategies/" >}}) for available options. Defaults to `NodePort` strategy if not set. | `.spec.exposeStrategy` (`kubermatic.yaml`; not included in example file) |

There are many more options but these are essential to get a minimal system up and running. A full reference of all options can be found in the [KubermaticConfiguration Reference]({{< relref "../../references/crds/#kubermaticconfigurationspec" >}}). The secret keys
mentioned above can be generated using any password generator or on the shell using
`cat /dev/urandom | base64 | tr -dc 'A-Za-z0-9' | head -c32`. Alternatively, the
Kubermatic Installer will suggest some properly generated secrets for you when it
notices that some are missing, for example:

```bash
./kubermatic-installer deploy --config kubermatic.yaml --helm-values values.yaml
```

Output will be similar to this:
```bash
INFO[15:15:20] 🛫 Initializing installer…                     edition="Community Edition" version=v2.21.2
INFO[15:15:20] 🚦 Validating the provided configuration…
ERROR[15:15:20]    The provided configuration files are invalid:
ERROR[15:15:20]    KubermaticConfiguration: spec.auth.serviceAccountKey must be a non-empty secret, for example: ZPCs7_KzgJxUSA5lCk_oNzL7RQFTQ6cOnHuTLAh4pGw
ERROR[15:15:20]    Operation failed: please review your configuration and try again.
```

{{% notice note %}}
A couple of settings are duplicated across the `values.yaml` and the KubermaticConfiguration CRD. The installer
will take care of filling in the gaps, so it is sufficient to configure the base domain in the
KubermaticConfiguration and let the installer set it in `values.yaml` as well.
{{% /notice %}}

#### Without LoadBalancers

If the Master Cluster's cloud provider does not support `Services` of type `LoadBalancer` (e.g. in an on-premise environment)
you can configure KKP to not create such `Services`. Later parts of the documentation will cover this case while setting up DNS as well.

To prepare your configuration correctly for this case, ensure that `nginx-ingress-controller` will be set up with a `Service`
of type `NodePort` instead of `LoadBalancer`. This can be done by providing the appropriate configuration in your `values.yaml`
file (this will bind access to `Ingress` resources exposed via plain HTTP to port **32080** and encrypted HTTPS to port **32443** on all nodes):

```yaml
# this is a snippet, not a full values.yaml!
nginx:
  controller:
    service:
      type: NodePort
      nodePorts:
        http: 32080
        https: 32443
```

Make sure to include **32443** as port in all URLs both in `kubermatic.yaml` and `values.yaml`, e.g. the token issuer URL from `kubermatic.yaml`
should now be `https://cluster.example.dev:32443/dex`.

### Create a StorageClass

KKP uses a custom storage class for the volumes created for User Clusters. This class, `kubermatic-fast`, needs
to be created before the installation can succeed and is required to use SSDs or a comparable storage layer.
The etcd clusters for every User Cluster will store their data in this StorageClass and etcd is highly sensitive
to slow disk I/O.

The installer can automatically create an SSD-based StorageClass for a subset of cloud providers. It can also
simply copy the default StorageClass, but this is not recommended for production setups unless the default class
is using SSDs.

{{< tabs name="StorageClass Creation" >}}
{{% tab name="AWS" %}}
Pass `--storageclass aws` to `kubermatic-installer deploy`.
{{% /tab %}}
{{% tab name="Azure" %}}
Pass `--storageclass azure` to `kubermatic-installer deploy`.
{{% /tab %}}
{{% tab name="DigitalOcean" %}}
Pass `--storageclass digitalocean` to `kubermatic-installer deploy`.
{{% /tab %}}
{{% tab name="GCP" %}}
Pass `--storageclass gce` to `kubermatic-installer deploy`.
{{% /tab %}}
{{% tab name="Hetzner" %}}
Pass `--storageclass hetzner` to `kubermatic-installer deploy`.
{{% /tab %}}
{{% tab name="vSphere" %}}
Create your own `StorageClass` resource named `kubermatic-fast` that suits your vSphere environment. An example
could be this file:

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: kubermatic-fast
provisioner: csi.vsphere.vmware.com
```

Save this to a file (e.g. `storageclass.yaml`) and apply it to the cluster:

```bash
kubectl apply -f ./storageclass.yaml
```

Also see [vSphere CSI driver documentation](https://docs.vmware.com/en/VMware-vSphere-Container-Storage-Plug-in/2.0/vmware-vsphere-csp-getting-started/GUID-606E179E-4856-484C-8619-773848175396.html) for optional parameters that can be passed as part of this `StorageClass` (e.g. the storage policy name).

{{% /tab %}}
{{% tab name="Other Providers" %}}
For other providers, please refer to the respective CSI driver documentation. It should guide you through setting up a `StorageClass`. Ensure that the `StorageClass` you create is named `kubermatic-fast`. The final resource should look something like this:

```yaml
# snippet, this is not a valid StorageClass!
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: kubermatic-fast
provisioner: csi.example.com
# CSI driver specific parameters
parameters:
  parameter1: value1
  parameter2: value2
```

Save your StorageClass to a file (e.g. `storageclass.yaml`) and apply it to the cluster:

```bash
kubectl apply -f ./storageclass.yaml
```

{{% /tab %}}
{{< /tabs >}}

### Run Installer

Once the configuration files have been prepared, it's time to run the installer, which will validate them
and then install all the required components into the cluster. Open a terminal window and run the installer
like so:

```bash
./kubermatic-installer deploy \
  # uncomment the line below after updating it to your respective provider; remove flag if provider is not supported (see above)
  # --storageclass aws \
  --config kubermatic.yaml \
  --helm-values values.yaml
```

{{% notice warning %}}
If you get an error about Helm being too old, download the most recent version from https://helm.sh/ and either
replace your system's Helm installation or specify the path to the Helm 3 binary via `--helm-binary ...` (for
example `./kubermatic-installer deploy .... --helm-binary /home/me/Downloads/helm-3.3.1`)
{{% /notice %}}

Once the installer has finished, the KKP Master Cluster has been installed and will be ready to use once
the necessary cert-manager configuration and DNS records have been configured (see the next steps).

{{% notice note %}}
Note that because you don't have a TLS certificate and no DNS records configured yet, some of the pods will crashloop.
This is normal for fresh setups and once the DNS records have been set, things will sort themselves out.
{{% /notice %}}

If you change your mind later on and adjust configuration options, it's safe to just run the installer again
to apply your changes.

## Update DNS & TLS

### Configure ClusterIssuers

By default, KKP installation uses cert-manager to generate TLS certificates for the platform. If you didn't decide to
change the settings (`.spec.ingress.certificateIssuer.name` in `kubermatic.yaml`), you need to create a `ClusterIssuer` object, named
`letsencrypt-prod` to enable cert-manager to issue the certificates. Example of this file can be found below. If you
adjusted this configuration option while preparing the configuration files, make sure to change the `ClusterIssuer`
resource name accordingly.

For other possible options, please refer to the [external documentation](https://cert-manager.io/docs/configuration/).

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    email: <INSERT_YOUR_EMAIL_HERE>
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: letsencrypt-prod-acme-account-key
    solvers:
    - http01:
       ingress:
         class: nginx
```

Save this (or the adjusted `ClusterIssuer` you are going to use) to a file (e.g. `clusterissuer.yaml`) and apply it
to your cluster:

```bash
kubectl apply -f ./clusterissuer.yaml
```

### Create DNS Records

In order to acquire a valid certificate, a DNS name needs to point to your cluster. Depending on your environment
this can mean a `LoadBalancer` service or a `NodePort` service. The `nginx-ingress-controller` Helm chart will by default
create a load balancer, unless you [reconfigured it because your environment does not support load balancers](#without-loadbalancers).

The installer will do its best to inform you about the required DNS records to set up. You will receive an output
similar to this:

```bash
INFO[13:03:33]    📝 Applying Kubermatic Configuration…
INFO[13:03:33]    ✅ Success.
INFO[13:03:33]    📡 Determining DNS settings…
INFO[13:03:33]       The main LoadBalancer is ready.
INFO[13:03:33]
INFO[13:03:33]         Service             : nginx-ingress-controller / nginx-ingress-controller
INFO[13:03:33]         Ingress via hostname: EXAMPLEEXAMPLEEXAMPLEEXAMPLE-EXAMPLE.eu-central-1.elb.amazonaws.com
INFO[13:03:33]
INFO[13:03:33]       Please ensure your DNS settings for "kubermatic.example.com" include the following records:
INFO[13:03:33]
INFO[13:03:33]          kubermatic.example.com.    IN  CNAME  EXAMPLEEXAMPLEEXAMPLEEXAMPLE-EXAMPLE.eu-central-1.elb.amazonaws.com.
INFO[13:03:33]          *.kubermatic.example.com.  IN  CNAME  EXAMPLEEXAMPLEEXAMPLEEXAMPLE-EXAMPLE.eu-central-1.elb.amazonaws.com.
INFO[13:03:33]
INFO[13:03:33] 🛬 Installation completed successfully. ✌
```

Follow the instructions on screen to setup your DNS. If the installer for whatever reason is unable to determine
the appropriate DNS settings, it will tell you so and you can manually collect the required information from the
cluster. See the following sections for more information regarding the required DNS records.

#### With LoadBalancers

If your cloud provider supports load balancers, you can find the target IP / hostname by looking at the
`nginx-ingress-controller` Service:

```bash
kubectl -n nginx-ingress-controller get services
```

Output will be similar to this:
```bash
#NAME                       TYPE           CLUSTER-IP      EXTERNAL-IP    PORT(S)                      AGE
#nginx-ingress-controller   LoadBalancer   10.47.248.232   1.2.3.4        80:32014/TCP,443:30772/TCP   449d
```

`EXTERNAL-IP` is what you need to put into the DNS record. Note that this can be a hostname (for example on AWS,
this can be `my-loadbalancer-1234567890.us-west-2.elb.amazonaws.com`) and in this case, the DNS record needs to
be a `CNAME` rather than an `A` record.

#### Without LoadBalancers

If you have [set up KKP to work without LoadBalancer support](#without-loadbalancers), set up the DNS records to
point to one or many of your cluster nodes. You can get a list of external IPs like this:

```bash
kubectl get nodes -o wide
```

Output will be similar to this:

```bash
#NAME                        STATUS   ROLES    AGE     VERSION     INTERNAL-IP   EXTERNAL-IP
#worker-node-cbd686cd-50nx   Ready    <none>   3h36m   v1.22.8     10.156.0.36   1.2.3.4
#worker-node-cbd686cd-59s2   Ready    <none>   21m     v1.22.8     10.156.0.14   1.2.3.5
#worker-node-cbd686cd-90j3   Ready    <none>   45m     v1.22.8     10.156.0.22   1.2.3.6
```

{{% notice note %}}
Some cloud providers list the external IP as the `INTERNAL-IP` and show no value for the `EXTERNAL-IP`. In this case,
use the internal IP.
{{% /notice %}}

For this example you could choose the second node and therefore, `1.2.3.5` is your DNS record target.

#### DNS Records

The main DNS record must connect the `kubermatic.example.com` domain with the target IP / hostname. Depending on whether
or not your load balancer or node uses hostnames instead of IPs (like AWS ELB), create either an **A** or a **CNAME** record,
respectively.

```plain
kubermatic.example.com.   IN   A   1.2.3.4
; or for a CNAME:
kubermatic.example.com.   IN   CNAME   myloadbalancer.example.com.
```

### Identity Aware Proxy

It's a common step to later setup an identity-aware proxy (IAP) to
[securely access other KKP components]({{< ref "../../architecture/concept/kkp-concepts/kkp-security/securing-system-services" >}}) from the logging or monitoring
stacks. This involves setting up either individual DNS records per IAP deployment (one for Prometheus, one for Grafana, etc.)
or simply creating a single **wildcard** record: `*.kubermatic.example.com`.

Whatever you choose, the DNS record needs to point to the same endpoint (IP or hostname, meaning A or CNAME
records respectively) as the previous record, i.e. `1.2.3.4`. This is because the one nginx-ingress-controller is routing
traffic both for KKP and all other services.

```plain
*.kubermatic.example.com.   IN   A       1.2.3.4
; or for a CNAME:
*.kubermatic.example.com.   IN   CNAME   myloadbalancer.example.com.
```

If wildcard records are not possible, you can configure individual records instead:

```plain
prometheus.kubermatic.example.com.     IN   A       1.2.3.4
alertmanager.kubermatic.example.com.   IN   A       1.2.3.4
```

### Validation

With the two DNS records configured, it's now time to wait for the certificate to be acquired. You can watch the progress
by doing `watch kubectl -n kubermatic get certificates` until it shows `READY=True`:

```bash
watch kubectl -n kubermatic get certificates
```

Output will be similar to this:
```bash
#NAME         READY   SECRET           AGE
#kubermatic   True    kubermatic-tls   1h
```

If the certificate does not become ready, `kubectl describe` it and follow the chain from Certificate to Order to Challenges.
Typical faults include:

* Bad DNS records.
* A misconfigured KubermaticConfiguration pointing to a different domain.

All pods running inside the `kubermatic` namespace should now be running. If they are not, check their logs to find out what's broken.

## First Sign In

With all this in place, you should be able to access `https://kubermatic.example.com/` (i.e. the URL to your KKP setup that you
configured) and log in either with your static password from the `values.yaml` files or using any of your chosen connectors.
This will initiate your first contact with the KKP API which will create an initial `User` resource for your account.

{{% notice note %}}
The first user signing into the dashboard will be granted admin permissions.
{{% /notice %}}

This will allow you to use the KKP UI and API as an admin. Other users can be promoted to Admins using the [Admin Panel]({{< ref "../../tutorials-howtos/administration/admin-panel/administrators" >}}).

## Next Steps

* [Add a Seed cluster]({{< ref "./add-seed-cluster-CE" >}}) to start creating User Clusters.
* Install the [Master / Seed Monitoring, Logging & Alerting Stack]({{< ref "../../tutorials-howtos/monitoring-logging-alerting/master-seed/installation" >}}) to collect cluster-wide metrics in a central place.
