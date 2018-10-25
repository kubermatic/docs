+++
title = "Install Kubermatic"
date = 2018-04-28T12:07:15+02:00
weight = 20
pre = "<b></b>"
+++

## Terminology

* **User/Customer cluster** -- A Kubernetes cluster created and managed by Kubermatic
* **Seed cluster** -- A Kubernetes cluster which is responsible for hosting the master components of a customer cluster
* **Master cluster** -- A Kubernetes cluster which is responsible for storing the information about users, projects and SSH keys. It hosts the Kubermatic components and might also act as a seed cluster.
* **Seed datacenter** -- A definition/reference to a seed cluster
* **Node datacenter** -- A definition/reference of a datacenter/region/zone at a cloud provider (aws=zone, digitalocean=region, openstack=zone)

See the [architecture overview](../../concepts/architecture) for more details on seed and master clusters.

## Setup

### Creating the kubeconfig

The Kubermatic API lives inside the master cluster and therefore speaks to it via in-cluster communication, using the `kubermatic` service account. Communication with the seed clusters happens by providing the API with a kubeconfig that
has the required contexts and credentials for each seed cluster. The name of the context within the kubeconfig needs to match an entry within the `datacenters.yaml` (see below).

Also make sure your kubeconfig contains _static_, long-lived credentials. Some cloud providers use custom authentication providers (like GKE using `gcloud` and EKS using `aws-iam-authenticator`). Those will not work in Kubermatic's usecase because the required tools are not installed.

{{%expand "Sample kubeconfig"%}}
```yaml
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: AAAAAA
    server: https://seed-1.kubermatic.de:6443
  name: seed-1
- cluster:
    certificate-authority-data: AAAAAA
    server: https://seed-2.kubermatic.de:6443
  name: seed-2
contexts:
- context:
    cluster: seed-1
    user: seed-1
  name: seed-1
- context:
    cluster: seed-2
    user: seed-2
  name: seed-2
current-context: seed-1
kind: Config
preferences: {}
users:
- name: seed-1
  user:
    token: very-secure-token
- name: seed-2
  user:
    token: very-secure-token
```
{{%/expand%}}

In the example above, we define two possible seed identifiers for the `datacenters.yml`: `seed-1` and `seed-2`.

### Defining the Datacenters

There are 2 types of datacenters:

- **Seed datacenter**, where Kubermatic's controller-manager and the control planes for each customer cluster are running.
- **Node datacenter**, where the customer worker nodes are provisioned.

Both are defined in a file named `datacenters.yaml`:

{{%expand "Sample datacenters.yaml"%}}
```yaml
datacenters:
  #==================================
  #============== Seeds =============
  #==================================

  # The name needs to match the a context in the kubeconfig given to the API
  seed-1:
    # Defines this datacenter as a seed
    is_seed: true
    # Though not used, you must configured a provider spec even for seeds.
    # The bringyourown provider is a good placeholder, as it requires no
    # further configuration.
    spec:
      bringyourown: ~

  seed-2:
    is_seed: true
    spec:
      bringyourown: ~

  #==================================
  #======= Node Datacenters =========
  #==================================

  #==================================
  #=========== OpenStack ============
  #==================================
  # The keys for non-seeds can be freely chosen.
  openstack-zone-1:
    # The location is shown in the Kubermatic dashboard
    # and should be descriptive within each provider (e.g.
    # for AWS a good location name would be "US East-1").
    location: Datacenter 2

    # The country is also used by the dashboard to show
    # the corresponding flag and make it easier to select
    # the proper region.
    country: DE

    # The name of the seed to use when creating clusters in
    # this datacenter; when someone creates a cluster with
    # nodes in this dc, the master components will live in seed-1.
    seed: seed-1

    # Configure cloud provider-specific further information.
    spec:
      openstack:
        # Authentication endpoint for Openstack, must be v3
        auth_url: https://our-openstack-api/v3
        availability_zone: zone-1
        # This DNS server will be set when Kubermatic creates a network
        dns_servers:
        - "8.8.8.8"
        - "8.8.4.4"

  #==================================
  #========== Digitalocean ==========
  #==================================
  do-ams2:
    location: Amsterdam
    country: NL
    seed: seed-1
    spec:
      digitalocean:
        # Digitalocean region for the nodes
        region: ams2

  #==================================
  #============== AWS ===============
  #==================================
  aws-us-east-1a:
    location: US East (N. Virginia)
    country: US
    seed: seed-2
    spec:
      aws:
        # Container linux AMI ID to be used within this region
        ami: ami-ac7a68d7
        # Region to use for nodes
        region: us-east-1
        # Character of the zone in the given region
        zone_character: a

  #==================================
  #============ Hetzner =============
  #==================================
  hetzner-fsn1:
    location: Falkenstein 1 DC 8
    country: DE
    seed: seed-1
    spec:
      hetzner:
        datacenter: fsn1-dc8

  #==================================
  #============ vSphere =============
  #==================================
  vsphere-office1:
    location: Office
    country: DE
    seed: europe-west3-c
    spec:
      vsphere:
        endpoint: "https://some-vcenter.com"
        datacenter: "Datacenter"
        datastore: "example-datastore"
        cluster: "example-cluster"
        allow_insecure: true
        root_path: "/Datacenter/vm/foo"
        templates:
          ubuntu: "ubuntu-template"
          centos: "centos-template"
          coreos: "coreos-template"

  #==================================
  #============= Azure ==============
  #==================================
  azure-westeurope:
    location: "Azure West europe"
    country: NL
    seed: europe-west3-c
    spec:
      azure:
        location: "westeurope"
```
{{%/expand%}}

### Creating the Master Cluster `values.yaml`

Installation of Kubermatic uses the [Kubermatic Installer](https://github.com/kubermatic/kubermatic-installer), which is essentially a Kubernetes job with [Helm](https://helm.sh/) and the required charts to install Kubermatic and its associated resources.
Customization of the cluster configuration is done using a cluster-specific `values.yaml`, stored as a secret within the cluster.

As a reference you can check out [values.example.yaml](https://github.com/kubermatic/kubermatic-installer/blob/release/v2.8/values.example.yaml).

For the kubermatic configuration you need to add `base64` encoded configuration of `datacenter.yaml` and `kubeconfig` to the `values.yaml` file. You can do this with following command:

```bash
base64 kubeconfig | tr -d '\n'
```

#### Kubermatic & 3rd-Party Authentication

Access to Kibana, Grafana and all other 3rd-party services included with Kubermatic is secured by running them behind [Keycloak-Proxy](https://github.com/keycloak/keycloak-gatekeeper) and using [Dex](https://github.com/dexidp/dex) as the authentication provider. Dex can then be configured to use external authentication sources like GitHub's or Google's OAuth endpoint, LDAP or OpenID Connect. Kubermatic itself makes use of Dex as well, but since it supports OAuth natively does not make use of Keycloak-Proxy.

For this to work you have to configure both Dex and Keycloak-Proxy (called "IAP", Identity-Aware Proxy) in your `values.yaml`.

##### Dex

{{% notice note %}}
Please note that despite its name, Dex is part of the `oauth` Helm chart.
{{% /notice %}}

For each service that is supposed to use Dex as an authentication provider, configure a `client`. The callback URL is called after authentication has been completed and must point to `https://<domain>/oauth/callback`. Remember that this will point to Keycloak and is therefore independent of the actual underlying application. Generate a secure random secret for each client as well.

A sample configuration for Prometheus could look like this:

```yaml
dex:
  clients:
  - id: prometheus # a unique identifier
    name: Prometheus
    secret: very-very-very-secret # clientSecret
    # list of allowed redirect URIs
    # (which one is used is determined by what Keycloak-Proxy decides)
    RedirectURIs:
    - https://kubermatic.initech.com/oauth/callback
```

Each service should have its own credentials. See the `dex` section in the [example values.yaml](https://github.com/kubermatic/kubermatic-installer/blob/release/v2.8/values.example.yaml).

##### Keycloak-Proxy (IAP)

Now that you have setup your "virtual OAuth provider" in the form of Dex, you need to configure Keycloak-Proxy to sit in front of the 3rd-party services and use it for authentication. For each client that we configured in Dex, add a `deployment` to the IAP configuration. Use the client's secret as the `client_secret` and generate another random, secure encryption key to encrypt the client state with (which is then stored as a cookie in the user's browser).

A sample deployment for Prometheus could look like this:

```yaml
iap:
  deployments:
    prometheus:
      name: prometheus # will be used to create kubernetes Deployment object

      # OAuth configuration from Dex
      client_id: prometheus
      client_secret: very-very-very-secret

      # encryption key for cookie storage
      encryption_key: ultra-secret-random-value

      ## see https://github.com/gambol99/keycloak-proxy#configuration
      ## example configuration allowing access only to the mygroup from
      ## mygithuborg organization
      config:
        scopes:
        - "groups"
        resources:
        - uri: "/*"
          groups:
          - "mygithuborg:mygroup"

      upstream_service: prometheus.monitoring.svc.cluster.local
      upstream_port: 9999
      ingress:
        host: prometheus.kubermatic.initech.com
```

See the `iap` section in the [example values.yaml](https://github.com/kubermatic/kubermatic-installer/blob/release/v2.8/values.example.yaml) for more information.

### Providing Storage

A storage class with the name `kubermatic-fast` needs to exist within the cluster. Also, make sure to either have a default storage class defined or configure Minio in your `values.yaml` to use a specific one:

```yaml
minio:
  storageClass: hdd-disk
```

### Deploying the Helm charts

Install [Helm](https://www.helm.sh/) on you local system and setup Tiller within the cluster.

1. Create a service account for Tiller and bind it to the `cluster-admin` role:

    ```bash
    kubectl create namespace kubermatic
    kubectl create serviceaccount -n kubermatic tiller-sa
    kubectl create clusterrolebinding tiller-cluster-role --clusterrole=cluster-admin --serviceaccount=kubermatic:tiller-sa
    ```

2. Afterwards install Tiller with the correct service account:

    ```bash
    helm --service-account tiller-sa --tiller-namespace kubermatic init
    ```

Now you're ready to deploy Kubermatic and its charts. It's generally advisable to postpone installing the final `certs` chart until you acquired LoadBalancer IPs/hostnames and can update your DNS zone to point to your new installation. This ensure that the `cert-manager` can quickly acquire TLS certificates instead of running into DNS issues.

```bash
helm upgrade --install --wait --timeout 300 --values values.yaml --namespace nginx-ingress-controller nginx-ingress-controller charts/nginx-ingress-controller/
helm upgrade --install --wait --timeout 300 --values values.yaml --namespace cert-manager cert-manager charts/cert-manager/
helm upgrade --install --wait --timeout 300 --values values.yaml --namespace oauth oauth charts/oauth/

# Used for storing etcd snapshots
helm upgrade --install --wait --timeout 300 --values values.yaml --namespace minio minio charts/minio/

helm upgrade --install --wait --timeout 300 --values values.yaml --namespace kubermatic kubermatic charts/kubermatic/
helm upgrade --install --wait --timeout 300 --values values.yaml --namespace iap iap charts/iap/
# When running on a cloud Provider like GCP, AWS or Azure with LB support also install the nodeport-proxy
helm upgrade --install --wait --timeout 300 --values values.yaml --namespace nodeport-proxy nodeport-proxy charts/nodeport-proxy/

# For logging stack, ensure that all charts are deployed within the logging namespace
helm upgrade --install --wait --timeout 300 --values values.yaml --namespace logging elasticsearch charts/logging/elasticsearch/
helm upgrade --install --wait --timeout 300 --values values.yaml --namespace logging fluentd charts/logging/fluentd/
helm upgrade --install --wait --timeout 300 --values values.yaml --namespace logging kibana charts/logging/kibana/

# For monitoring stack
helm upgrade --install --wait --timeout 300 --values values.yaml --namespace monitoring prometheus charts/monitoring/prometheus/
helm upgrade --install --wait --timeout 300 --values values.yaml --namespace monitoring node-exporter charts/monitoring/node-exporter/
helm upgrade --install --wait --timeout 300 --values values.yaml --namespace monitoring kube-state-metrics charts/monitoring/kube-state-metrics/
helm upgrade --install --wait --timeout 300 --values values.yaml --namespace monitoring grafana charts/monitoring/grafana/
helm upgrade --install --wait --timeout 300 --values values.yaml --namespace monitoring alertmanager charts/monitoring/alertmanager/
```

After all charts have been deployed, update your DNS accordingly. See the last section on this page for more details. Once that is done, wait a bit and then install the final Helm chart:

```bash
helm upgrade --install --wait --timeout 300 --values values.yaml --namespace default certs charts/certs/
```

### etcd backups

We run an individual cronjob every 20 minutes for each customer cluster to backup the etcd-ring. Snapshots will be stored by default to an internal S3 bucket provided by minio, though this can be changed by modifying the `storeContainer` & `cleanupContainer` in the `values.yaml` to your needs.

The cronjobs will be executed in the `kube-system` namespace. Therefore if a container needs credentials, a secret must be created in the kube-system namespace.

The workflow:

1. init-container creates snapshot
2. snapshot will be saved in a shared volume
3. `storeContainer` takes the snapshot and stores it somewhere

#### storeContainer

The `storeContainer` will be executed on each backup process after a snapshot has been created and stored on a shared volume accessible by the container. By default only the last 20 revisions will be kept. Older snapshots will be deleted. By default the container will store the snapshot to minio.

#### cleanupContainer

The `cleanupContainer` will delete all snapshots in S3 after a cluster has been deleted.

#### Credentials

If the default container will be used, a secret in the `kube-system` namespace must be created:

```yaml
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  name: s3-credentials
  namespace: kube-system
data:
  ACCESS_KEY_ID: "SOME_BASE64_ENCODED_ACCESS_KEY"
  SECRET_ACCESS_KEY: "SOME_BASE64_ENCODED_SECRET_KEY"
```

### Create DNS Entries

Kubermatic needs to have at least 2 DNS entries set.

#### Dashboard, API, Dex

The frontend of Kubermatic needs a single, simple DNS entry. Let's assume it is being installed to serve `kubermatic.initech.com`. For the 3rd-party services like Prometheus or Grafana, you will also want to create a wildcard DNS record `*.kubermatic.initech.com` pointing to the same IP/hostname.

##### With LoadBalancer

When running on a cloud provider which supports services of type [LoadBalancer](https://kubernetes.io/docs/concepts/services-networking/service/#loadbalancer), the nginx-ingress chart should be configured to create such a service. The load balancer's IP can then be fetched via:

```bash
kubectl -n nginx-ingress-controller get service nginx-ingress-controller -o wide
#NAME                       TYPE           CLUSTER-IP     EXTERNAL-IP     PORT(S)                      AGE       SELECTOR
#nginx-ingress-controller   LoadBalancer   10.47.242.69   35.198.146.37   80:30822/TCP,443:31412/TCP   160d      app=ingress-nginx
```

The `EXTERNAL-IP` field shows the correct IP used for the DNS entry. Depending on your provider, this might also be a hostname, in which case you should set a CNAME record instead of an A record.

##### Without LoadBalancer

Without a LoadBalancer nginx will run as DaemonSet & allocate 2 ports on the host (80 & 443). Configuration of nginx happens via the [values.yaml](https://github.com/kubermatic/kubermatic-installer/blob/release/v2.8/values.example.yaml). The DNS entry needs to be configured to point to one or more of the cluster nodes.

#### Seed Clusters (customer-cluster apiservers)

For each seed cluster a single wildcard DNS entry must be configured. All apiservers of all customer clusters are being exposed via either NodePorts or a single LoadBalancer.

The domain will be based on the name of the seed-cluster as defined in the [datacenters.yaml](https://docs.kubermatic.io/installation/install_kubermatic/#defining-the-datacenters) and the domain under which the frontend is available.

For example, when the base domain is `kubermatic.initech.com` and a seed cluster in your `datacenters.yaml` is called `europe-west1`, then

* The seed cluster domain would be: `europe-west1.kubermatic.initech.com`
* The corresponding wildcard entry would be: `*.europe-west1.kubermatic.initech.com`

A customer cluster created in this seed cluster would get the domain `[cluster ID].europe-west1.kubermatic.example.com`.

##### With LoadBalancer

Get the IP from the `nodeport-lb` service:

```bash
kubectl -n nodeport-proxy get service nodeport-lb
#NAME          TYPE           CLUSTER-IP      EXTERNAL-IP    PORT(S)                                                           AGE
#nodeport-lb   LoadBalancer   10.47.242.236   35.198.93.90   32493:30195/TCP,31434:30739/TCP,30825:32503/TCP,30659:30324/TCP   93d
```

##### Without LoadBalancer

Take one or more of the seed cluster worker nodes IPs.
