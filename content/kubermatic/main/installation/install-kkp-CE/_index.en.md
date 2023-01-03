+++
title = "Install Kubermatic Kubernetes Platform (KKP) CE"
linkTitle = "Install Community Edition"
date = 2023-01-03T12:00:00+02:00
weight = 20

+++

This chapter explains the installation procedure of KKP into a pre-existing Kubernetes cluster using KKP's installer (called `kubermatic-installer`).

## Terminology

* **User cluster** -- A Kubernetes cluster created and managed by KKP
* **Seed cluster** -- A Kubernetes cluster which is responsible for hosting the master components of a user cluster
* **Master cluster** -- A Kubernetes cluster which is responsible for storing the information about users, projects and SSH keys. It hosts the KKP components and might also act as a seed cluster.
* **Seed datacenter** -- A definition/reference to a seed cluster
* **Node datacenter** -- A definition/reference of a datacenter/region/zone at a cloud provider (aws=zone, digitalocean=region, openstack=zone)

## Requirements

{{% notice warning %}}
This guide assumes a clean installation into an empty cluster. Please refer to the [upgrade notes]({{< ref "../../tutorials-howtos/upgrading" >}}) for more information on
migrating existing installations.
{{% /notice %}}

For this guide you will have to have [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl) and [Helm](https://www.helm.sh/) (version 3) installed locally.

### Set up Kubernetes

To aid in setting up the seed and master clusters, we provide [KubeOne](https://github.com/kubermatic/kubeone/) which can be used to set up a highly-available Kubernetes cluster.
Refer to the [KubeOne documentation](https://docs.kubermatic.com/kubeone) for details on how to use it.

Please take note of the [recommended hardware and networking requirements]({{< ref "../../architecture/requirements/cluster-requirements/" >}}) before provisioning a cluster.

## Installation

To begin the installation, make sure you have a kubeconfig file at hand, with a user context that grants `cluster-admin` permissions.

### Download the Installer

Download the [tarball](https://github.com/kubermatic/kubermatic/releases/) (e.g. kubermatic-ce-X.Y-linux-amd64.tar.gz)
containing the Kubermatic Installer and the required Helm charts for your operating system and extract it locally. Note that
for Windows, ZIP files are provided instead of tar.gz files.

```bash
# For latest version:
VERSION=$(curl -w '%{url_effective}' -I -L -s -S https://github.com/kubermatic/kubermatic/releases/latest -o /dev/null | sed -e 's|.*/v||')
# For specific version set it explicitly:
# VERSION=2.21.x
wget https://github.com/kubermatic/kubermatic/releases/download/v${VERSION}/kubermatic-ce-v${VERSION}-linux-amd64.tar.gz
tar -xzvf kubermatic-ce-v${VERSION}-linux-amd64.tar.gz
```

### Prepare Configuration

The installation and configuration for a KKP system consists of two important files:

* A `values.yaml` used to configure the various Helm charts KKP ships with. This is where nginx, Prometheus,
  Dex etc. can be adjusted to the target environment. A single `values.yaml` is used to configure all Helm charts
  combined.
* A `kubermatic.yaml` that configures KKP itself and is an instance of the
  [KubermaticConfiguration]({{< ref "." >}}) CRD. This configuration will
  be stored in the cluster and serves as the basis for the Kubermatic Operator to manage the actual KKP installation.

The release archive hosted on GitHub contains examples for both of the configuration files (`values.example.yaml` and
`kubermatic.example.yaml`). It's a good idea to take them as a starting point and add more options as necessary.

The key items to configure are:

* The base domain under which KKP shall be accessible (e.g. `kubermatic.example.com`).
* The certificate issuer: KKP requires that its dashboard and Dex are only accessible via HTTPS, so a
  certificate is required. By default cert-manager is used, but you have to choose between the production or
  staging Let's Encrypt services (if in doubt, choose the production server).
  It is possible to use a custom CA (i.e. self-signed certificates), but this is outside of the scope of this
  document.
* For proper authentication, shared secrets must be configured between Dex and KKP. Likewise, Dex uses
  yet another random secret to encrypt cookies stored in the users' browsers.
* The expose strategy, that is the strategy used to expose the control plane
  components of a user cluster to the worker nodes
  (see [expose strategy documentation]({{< ref "../../tutorials-howtos/networking/expose-strategies">}}) for available options)

There are many more options, but these are essential to get a minimal system up and running. The secret keys
mentioned above can be generated using any password generator or on the shell using
`cat /dev/urandom | tr -dc A-Za-z0-9 | head -c32`. On macOS, use `brew install gnu-tar` and
`cat /dev/urandom | gtr -dc A-Za-z0-9 | head -c32`. Alternatively, the Kubermatic Installer will suggest some
properly generated secrets for you when it notices that some are missing, for example:

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

### Create a StorageClass

KKP uses a custom storage class for the volumes created for user clusters. This class, `kubermatic-fast`, needs
to be created before the installation can succeed and is strongly recommended to use SSDs. The etcd clusters for
every user cluster will store their data in this StorageClass and etcd is highly sensitive to slow disk I/O.

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

Once the installer has finished, the KKP Master cluster has been installed and will be ready to use once
the necessary cert-manager configuration and DNS records have been configured (see the next steps).

{{% notice note %}}
Note that because you don't have a TLS certificate and no DNS records configured yet, some of the pods will crashloop.
This is normal for fresh setups and once the DNS records have been set, things will sort themselves out.
{{% /notice %}}

If you change your mind later on and adjust configuration options, it's safe to just run the installer again
to apply your changes.

### Configure ClusterIssuers

By default, KKP installation uses cert-manager to generate TLS certificates for the platform. If you didn't decide to 
change the settings (`kubermatic.certIssuer` in `values.yaml`), you need to create a `ClusterIssuer` object, named 
`letsencrypt-prod` to enable cert-manager to issue the certificates. Example of this file can be found below.
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

Save this (or the adjusted `ClusterIssuer` you are going to use) to a file, e.g. `clusterissuer.yaml` and apply it
to your cluster:

```bash
kubectl apply -f ./clusterissuer.yaml
```


### Create DNS Records

In order to acquire a valid certificate, a DNS name needs to point to your cluster. Depending on your environment,
this can mean a LoadBalancer service or a NodePort service. The nginx-ingress-controller Helm chart will by default
create a LoadBalancer, unless you reconfigure it because your environment does not support LoadBalancers.

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

When your cloud provider supports LoadBalancers, you can find the target IP / hostname by looking at the
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

Without a LoadBalancer, you will need to use a NodePort service (refer to the `charts/nginx-ingress-controller/values.yaml`
for more information) and set up the DNS records to point to one or many of your cluster nodes. You can get a list of
external IPs like so:

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
Some cloud providers list the external IP as the `INTERNAL-IP` and show no value for the `EXTENAL-IP`. In this case,
use the internal IP.
{{% /notice %}}

For this example we choose the second node, and so `1.2.3.5` is our DNS record target.

#### DNS Records

The main DNS record must connect the `kubermatic.example.com` domain with the target IP / hostname. Depending on whether
or not your LoadBalancer/node uses hostnames instead of IPs (like AWS ELB), create either an **A** or a **CNAME** record,
respectively.

```plain
kubermatic.example.com.   IN   A   1.2.3.4
; or for a CNAME:
kubermatic.example.com.   IN   CNAME   myloadbalancer.example.com.
```

#### Identity Aware Proxy

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

If CNAME records are not possible, you can configure individual records instead:

```plain
prometheus.kubermatic.example.com.     IN   A       1.2.3.4
alertmanager.kubermatic.example.com.   IN   A       1.2.3.4
```

#### Validation

With the 2 DNS records configured, it's now time to wait for the certificate to be acquired. You can watch the progress
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
Typical faults include bad DNS records or a misconfigured KubermaticConfiguration pointing to a different domain.

### Initializing the first Kubermatic Admin user

With all this in place, you should be able to access https://kubermatic.example.com/ and login either with your static
password from the `values.yaml` or using any of your chosen connectors. This will initiate your first contact with the 
KKP API which will create an initial User resource for your account. To become a KKP admin, edit your User instance 
and set the `admin` flag to `true`. 

```yaml
apiVersion: kubermatic.k8c.io/v1
kind: User
metadata:
  creationTimestamp: "2020-05-04T07:20:37Z"
  name: 3ec2d8e832964a39b8e8a3df5d25adeea8677f5d6d4706bf23842d3d9663d37c
spec:
  admin: true
  email: example@example.com
  id: eb279a47c2c869ea89efa48c193ff813b34b96b5c81ada345629205a
  name: KKP User
```

This will allow you to use the KKP UI and API as an admin. Other users can be promoted to Admins using the [Admin Panel]({{< ref "../../tutorials-howtos/administration/admin-panel/administrators" >}})

### Have a Break

All pods running inside the `kubermatic` namespace should now be running. If they are not, check their logs to find out what's broken.

### Next Steps

* [Add a Seed cluster]({{< ref "./add-seed-cluster-CE" >}}) to start creating user clusters.
* Install the [Master / Seed Monitoring, Logging & Alerting Stack]({{< ref "../../tutorials-howtos/monitoring-logging-alerting/master-seed/installation" >}}) to collect cluster-wide metrics in a central place.
