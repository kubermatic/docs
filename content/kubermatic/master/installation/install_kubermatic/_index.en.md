+++
title = "Install Kubermatic"
date = 2018-04-28T12:07:15+02:00
weight = 20
pre = "<b></b>"
+++

This chapter explains the installation procedure of Kubermatic into a pre-existing Kubernetes cluster.

{{% notice note %}}
At the moment you need to be invited to get access to Kubermatic's Docker registry before you can try it out. Please [contact sales](mailto:sales@loodse.com) to receive your credentials.
{{% /notice %}}

## Terminology

* **User/Customer cluster** -- A Kubernetes cluster created and managed by Kubermatic
* **Seed cluster** -- A Kubernetes cluster which is responsible for hosting the master components of a customer cluster
* **Master cluster** -- A Kubernetes cluster which is responsible for storing the information about users, projects and SSH keys. It hosts the Kubermatic components and might also act as a seed cluster.
* **Seed datacenter** -- A definition/reference to a seed cluster
* **Node datacenter** -- A definition/reference of a datacenter/region/zone at a cloud provider (aws=zone, digitalocean=region, openstack=zone)

## Requirements

Before installing, make sure your Kubernetes cluster meets the [minimal requirements]({{< ref "../../requirements" >}})
and make yourself familiar with the requirements for your chosen cloud provider.

For this guide you will have to have `kubectl` and [Helm](https://www.helm.sh/) (version 2 or 3) installed locally.

## Installation

To begin the installation, make sure you have a kubeconfig at hand, with a user context that grants `cluster-admin`
permissions.

### Clone the Installer

Clone the [installer repository](https://github.com/kubermatic/kubermatic-installer) to your disk and make sure to
checkout the appropriate release branch (`release/vX.Y`). The latest stable release is already the default branch,
so in most cases there should be no need to switch. Alternatively you can also download a ZIP version from GitHub.

```bash
git clone https://github.com/kubermatic/kubermatic-installer
cd kubermatic-installer
```

### Create a StorageClass

Kubermatic uses a custom storage class for the volumes created for user clusters. This class, `kubermatic-fast`, needs
to be manually created during the installation and its parameters depend highly on the environment where Kubermatic is
installed.

It's highly recommended to use SSD-based volumes, as etcd is very sensitive to slow disk I/O. If your cluster already
provides a default SSD-based storage class, you can simply copy and re-create it as `kubermatic-fast`. For a cluster
running on AWS, an example class could look like this:

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: kubermatic-fast
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp2
```

Store the above YAML snippet in a file and then apply it using `kubectl`:

```bash
kubectl apply -f aws-storageclass.yaml
```

Please consult the [Kubernetes documentation](https://kubernetes.io/docs/concepts/storage/storage-classes/#parameters)
for more information about the possible parameters for your storage backend.

### Install Helm's Tiller

{{% notice note %}}
This step is only required when using Helm 2.
{{% /notice %}}

When using Helm 2, it's required to setup Tiller inside the cluster. This requires setting up a ClusterRole and
-Binding, before installing Tiller itself. If your cluster already has Tiller installed in another namespace, you
can re-use it, but an installation dedicated for Kubermatic is preferred.

```bash
kubectl create namespace kubermatic
kubectl create serviceaccount -n kubermatic tiller
kubectl create clusterrolebinding tiller-cluster-role --clusterrole=cluster-admin --serviceaccount=kubermatic:tiller

helm --service-account tiller --tiller-namespace kubermatic init
```

### Prepare Configuration

Kubermatic ships with a number of Helm charts that need to be installed into the master or seed clusters. These are
built so they can be configured using a single, shared `values.yaml` file. The required charts are

* **Master cluster:** cert-manager, nginx-ingress-controller, oauth(, iap)
* **Seed cluster:** nodeport-proxy, minio, s3-exporter

There are additional charts for the [monitoring]({{< ref "../monitoring_stack" >}}) and [logging stack]({{< ref "../logging_stack" >}})
which will be discussed in their dedicated chapters, as they are not strictly required for running Kubermatic.

In addition to the `values.yaml` for configuring the charts, a number of options will later be made inside a special
`KubermaticConfiguration` resource.

A minimal configuration for Helm charts sets these options. The secret keys mentioned below can be generated using any
password generator or on the shell using `cat /dev/urandom | tr -dc A-Za-z0-9 | head -c32`.

```yaml
# Dex is the OpenID provider for Kubermatic.
dex:
  ingress:
    # configure your base domain, under which the Kubermatic dashboard shall be available
    host: kubermatic.example.com

  clients:
  # The "kubermatic" client is used for logging into the Kubermatic dashboard. It always
  # needs to be configured.
  - id: kubermatic
    name: Kubermatic
    # generate a secure secret key
    secret: <dex-kubermatic-oauth-secret-here>
    RedirectURIs:
    # ensure the URLs below use the dex.ingress.host configured above
    - https://kubermatic.example.com
    - https://kubermatic.example.com/projects

  # Depending on your chosen login method, you need to configure either an OAuth provider like
  # Google or GitHub, or configure a set of static passwords. Check the `charts/oauth/values.yaml`
  # for an overview over all available connectors.

  # For testing purposes, we configure a single static user/password combination.
  staticPasswords:
  - email: "kubermatic@example.com"
    # bcrypt hash of the string "password"
    hash: "$2a$10$2b2cU8CPhOTaGrs1HRQuAueS7JTT5ZHsHSzYiFPm1leZck7Mc8T4W"

    # these are used within Kubermatic to identify the user
    username: "admin"
    userID: "08a8684b-db88-4b73-90a9-3cd1661f5466"

kubermaticOperator:
  # insert the Docker authentication JSON provided by Loodse here
  imagePullSecret: |
    {
      "auths": {
        "quay.io": {....}
      }
    }
```

### Install Dependencies

With the configuration prepared, it's now time to install the required Helm charts into the master
cluster. Take note of where you placed your `values.yaml` and then run the following commands in your
shell:

```bash
helm upgrade --tiller-namespace kubermatic --install --values YOUR_VALUES_YAML_PATH --namespace nginx-ingress-controller nginx-ingress-controller charts/nginx-ingress-controller/
helm upgrade --tiller-namespace kubermatic --install --values YOUR_VALUES_YAML_PATH --namespace cert-manager cert-manager charts/cert-manager/
helm upgrade --tiller-namespace kubermatic --install --values YOUR_VALUES_YAML_PATH --namespace oauth oauth charts/oauth/
```

#### Validation

Before continuing, make sure the charts we just installed are functioning correctly. Check that pods inside the
`nginx-ingress-controller`, `oauth` and `cert-manager` namespaces are in status `Running`:

```bash
kubectl -n nginx-ingress-controller get pods
#NAME                                        READY   STATUS    RESTARTS   AGE
#nginx-ingress-controller-55dd87fc7f-5q4zb   1/1     Running   0          17m
#nginx-ingress-controller-55dd87fc7f-l492k   1/1     Running   0          4h56m
#nginx-ingress-controller-55dd87fc7f-rwcwf   1/1     Running   0          5h33m

kubectl -n oauth get pods
#NAME                   READY   STATUS    RESTARTS   AGE
#dex-7795d657ff-b4fmq   1/1     Running   0          4h59m
#dex-7795d657ff-kqbk8   1/1     Running   0          20m

kubectl -n cert-manager get pods
#NAME                           READY   STATUS    RESTARTS   AGE
#cainjector-5dc8ccbd45-gk6xp    1/1     Running   0          5h36m
#cert-manager-799ccc8b5-m7wxk   1/1     Running   0          20m
#webhook-575b887-zb6m2          1/1     Running   0          5h36m
```

You should also have a working LoadBalancer service created by nginx:

{{% notice note %}}
Not all cloud providers provide support for LoadBalancers. In these environments the `nginx-ingress-controller` chart can
be configured to use a NodePort Service instead, which would open ports 80 and 443 on every node of the cluster. Refer to
the `charts/nginx-ingress-controller/values.yaml` for more information.
{{% /notice %}}

```bash
kubectl -n nginx-ingress-controller get services
#NAME                       TYPE           CLUSTER-IP      EXTERNAL-IP    PORT(S)                      AGE
#nginx-ingress-controller   LoadBalancer   10.47.248.232   1.2.3.4        80:32014/TCP,443:30772/TCP   449d
```

Take note of the `EXTERNAL-IP` of this service (`1.2.3.4` in the example above). You will need to configure a DNS record
pointing to this in a later step.

If any of the pods above are not working, check their logs and describe them (`kubectl -n nginx-ingress-controller describe pod ...`)
to see what's causing the issues.

### Install Kubermatic Operator

Before installing the Kubermatic Operator, the Kubermatic CRDs need to be installed. You can install them like so:

```bash
kubectl apply -f charts/kubermatic/crd/
```

After this, the operator chart can be installed like the previous Helm charts:

```bash
helm upgrade --tiller-namespace kubermatic --install --values YOUR_VALUES_YAML_PATH --namespace kubermatic charts/kubermatic-operator/
```

#### Validation

Once again, let's check that the operator is working properly:

```bash
kubectl -n kubermatic get pods
#NAME                                   READY   STATUS    RESTARTS   AGE
#kubermatic-operator-769986fc8b-7gpsc   1/1     Running   0          28m
```

### Create KubermaticConfiguration

It's now time to configure Kubermatic itself. This will be done in a `KubermaticConfiguration` CRD, for which a
[full example]({{< ref "../../concepts/kubermaticconfiguration" >}}) with all options is available, but for the
purpose of this document we will only need to configure a few things:

```yaml
apiVersion: operator.kubermatic.io/v1alpha1
kind: KubermaticConfiguration
metadata:
  name: kubermatic
  namespace: kubermatic
spec:
  ingress:
    # this domain must match what you configured as dex.ingress.host
    # in the values.yaml
    domain: kubermatic.example.com

  # These secret keys configure the way components commmunicate with Dex.
  auth:
    # this must match the secret configured for the kubermatic client from
    # the values.yaml.
    issuerClientSecret: <dex-kubermatic-oauth-secret-here>

    # these need to be randomly generated
    issuerCookieKey: <a-random-key>
    serviceAccountKey: <another-random-key>
```

Save the YAML above as `kubermatic.yaml` and apply it like so:

```bash
kubectl apply -f kubermatic.yaml
```

This will now cause the operator to being provisioning a master cluster for Kubermatic. You can observe the progress by
looking at `watch kubectl -n kubermatic get pods`:

```bash
watch kubectl -n kubermatic get pods
#NAME                                                    READY   STATUS    RESTARTS   AGE
#kubermatic-api-cfcd95746-5r9z2                          1/1     Running   0          24m
#kubermatic-api-cfcd95746-tsqjc                          1/1     Running   0          28m
#kubermatic-master-controller-manager-7d97bb887d-8nb74   1/1     Running   0          3m23s
#kubermatic-master-controller-manager-7d97bb887d-z8t9w   1/1     Running   0          28m
#kubermatic-operator-769986fc8b-7gpsc                    1/1     Running   0          28m
#kubermatic-ui-7fc858fb4b-dq5b5                          1/1     Running   0          85m
#kubermatic-ui-7fc858fb4b-s8fnn                          1/1     Running   0          24m
```

Note that because we don't yet have a TLS certificate and no DNS records configured, some of the pods will crashloop
until this is fixed.

### Create DNS Records

In order to acquire a valid certificate, a DNS name needs to point to your cluster. Depending on your environment,
this can mean a LoadBalancer service or a NodePort service.

#### With Load Balancers

When your cloud provider supports Load Balancers, you can find the target IP / hostname by looking at the
`nginx-ingress-controller` Service:

```bash
kubectl -n nginx-ingress-controller get services
#NAME                       TYPE           CLUSTER-IP      EXTERNAL-IP    PORT(S)                      AGE
#nginx-ingress-controller   LoadBalancer   10.47.248.232   1.2.3.4        80:32014/TCP,443:30772/TCP   449d
```

The `EXTERNAL-IP` is what we need to put into the DNS record.

#### Without Load Balancers

Without a LoadBalancer, you will need to use the NodePort service (refer to the `charts/nginx-ingress-controller/values.yaml`
for more information) and setup the DNS records to point to one or many of your cluster's nodes. You can get a list of
external IPs like so:

```bash
kubectl get nodes -o wide
#NAME                        STATUS   ROLES    AGE     VERSION         INTERNAL-IP   EXTERNAL-IP
#worker-node-cbd686cd-50nx   Ready    <none>   3h36m   v1.15.8-gke.3   10.156.0.36   1.2.3.4
#worker-node-cbd686cd-59s2   Ready    <none>   21m     v1.15.8-gke.3   10.156.0.14   1.2.3.5
#worker-node-cbd686cd-90j3   Ready    <none>   45m     v1.15.8-gke.3   10.156.0.22   1.2.3.6
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
```

or, for a CNAME:

```plain
kubermatic.example.com.   IN   CNAME   myloadbalancer.example.com.
```

#### Identity Aware Proxy

It's a common step to later setup an identity-aware proxy (IAP) to
[securely access other Kubermatic components]({{< ref "../securing_services" >}}) from the logging or monitoring
stacks. This involves setting up either individual DNS records per IAP deployment or simply creating a single **wildcard**
record: `*.kubermatic.example.com`.

Whatever you choose, the DNS record needs to point to the same endpoint (IP or hostname, meaning A or CNAME
records respectively) as the previous record, i.e. `1.2.3.4`.

```plain
*.kubermatic.example.com.   IN   A       1.2.3.4
; or for a CNAME:
*.kubermatic.example.com.   IN   CNAME   myloadbalancer.example.com.
```

If CNAME records are not possible, you would configure individual records instead:

```plain
prometheus.kubermatic.example.com.     IN   A       1.2.3.4
alertmanager.kubermatic.example.com.   IN   A       1.2.3.4
```

#### Validation

With the 2 DNS records configured, it's now time to wait for the certificate to be acquired. You can watch the progress
by doing `watch kubectl -n kubermatic get certificates` until it shows `READY=True`:

```bash
watch kubectl -n kubermatic get certificates
#NAME         READY   SECRET           AGE
#kubermatic   True    kubermatic-tls   1h
```

If the certificate does not become ready, `describe` it and follow the chain from Certificate to Order to Challenges.
Typical faults include bad DNS records or a misconfigured KubermaticConfiguration pointing to a different domain.

### Have a Break

With all this in place, you should be able to access https://kubermatic.example.com/ and login either with your static
password from the `values.yaml` or using any of your chosen connectors. All pods running inside the `kubermatic` namespace
should now be running. If they are not, check their logs to find out what's broken.

### Next Steps

* [Add a Seed cluster]({{< ref "../add_seed_cluster" >}}) to start creating user clusters.
* Install the [monitoring stack]({{< ref "../monitoring_stack" >}}) to gain metrics and alerting.
* Install the [logging stack]({{< ref "../logging_stack" >}}) to collect cluster-wide metrics in a central place.
