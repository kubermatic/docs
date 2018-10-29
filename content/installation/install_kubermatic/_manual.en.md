+++
title = "Manual Installation"
date = 2018-04-28T12:07:15+02:00
weight = 20
pre = "<b></b>"
+++

### Creating the kubeconfig

The Kubermatic API lives inside the master cluster and therefore speaks to it via in-cluster communication.

The Kubermatic cluster controller needs to have a kubeconfig which contains all contexts for each seed cluster it should manage. The name of the context within the kubeconfig needs to match an entry within the `datacenters.yaml`. See below.

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

### Defining the Datacenters

There are 2 types of datacenters:

- Seed datacenter
- Node datacenter

Both are defined in a file named `datacenters.yaml`:

{{%expand "Sample datacenters.yaml"%}}
```yaml
datacenters:
#==================================
#============== Seed ==============
#==================================
  # The name needs to match the a context in the kubeconfig given to the controller
  seed-1: #Master
    location: Datacenter 1
    country: DE
    provider: Loodse
    # Defines this datacenter as a seed
    is_seed: true
    # Seeds are normally defined as a bringyourown style of datacenter
    spec:
      bringyourown:
        region: DE
      seed:
        bringyourown:
  # The name needs to match the a context in the kubeconfig given to the kubermatic-api
  seed-2: #Master
    location: Datacenter 2
    country: US
    provider: Loodse
    # Defines this datacenter as a seed
    is_seed: true
    # Seeds are normally defined as a bringyourown style of datacenter
    spec:
      bringyourown:
        region: US
      seed:
        bringyourown:

#==================================
#======= Node Datacenters =========
#==================================

#==================================
#============OpenStack=============
#==================================
  openstack-zone-1:
    location: Datacenter 2
    # The name of the seed
    # When someone creates a cluster with nodes in this dc, the master components will live in seed-1
    seed: seed-1
    country: DE
    provider: Loodse
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
#===========Digitalocean===========
#==================================
  do-ams2:
    location: Amsterdam
    # The name of the seed
    # When someone creates a cluster with nodes in this dc, the master components will live in seed-1
    seed: seed-1
    country: NL
    spec:
      digitalocean:
        # Digitalocean region for the nodes
        region: ams2

#==================================
#===============AWS================
#==================================
  aws-us-east-1a:
    location: US East (N. Virginia)
    # The name of the seed
    # When someone creates a cluster with nodes in this dc, the master components will live in seed-1
    seed: seed-2
    country: US
    provider: aws
    spec:
      aws:
        # Container linux ami id to be used within this region
        ami: ami-ac7a68d7
        # Region to use for nodes
        region: us-east-1
        # Character of the zone in the given region
        zone_character: a

#==================================
#=============Hetzner==============
#==================================
  hetzner-fsn1:
    location: Falkenstein 1 DC 8
    seed: seed-1
    country: DE
    provider: hetzner
    spec:
      hetzner:
        datacenter: fsn1-dc8

#==================================
#=============vSphere==============
#==================================
  vsphere-office1:
    location: Office
    seed: europe-west3-c
    country: DE
    provider: Loodse
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
    seed: europe-west3-c
    country: NL
    provider: azure
    spec:
      azure:
        location: "westeurope"
```
{{%/expand%}}

### Creating the Master Cluster `values.yaml`

Installation of Kubermatic uses the [Kubermatic Installer](https://github.com/kubermatic/kubermatic-installer), which is essentially a Kubernetes job with [Helm](https://helm.sh/) and the required charts to install Kubermatic and its associated resources.
Customization of the cluster configuration is done using a cluster-specific `values.yaml`, stored as a secret within the cluster.

As a reference you can check out [values.example.yaml](https://github.com/kubermatic/kubermatic-installer/blob/release/v2.7/values.example.yaml).

For the kubermatic configuration you need to add `base64` encoded configuration of `datacenter.yaml` and `kubeconfig` to the `values.yaml` file. You can do this with fallowing command:

```
base64 kubeconfig | tr -d '\n'
```

### Kibana, grafana, prometheus, alertmanager and OIDC authentication

In order to open in browser system service like
kibana/grafana/prometheus/alertmanager oAuth static client credentials and
callback URLs for each of them need to be configured in `dex` and then in `iap`
section.

#### Dex

Static clients are confired in
```
dex:
  clients:
  - id: example # clientID
    name: Example App
    secret: very-secret # clientSecret
    RedirectURIs:
    - https://you.app.callback.url/oauth/callback # where to redirect once all good
```
Each service should have own credentials. See example `dex` section in
https://github.com/kubermatic/kubermatic-installer/blob/release/v2.7/values.example.yaml

#### IAP

Next configure IAP (identity aware proxy), use oauth credentials from dex's
static clients config, for each service respectively.

```
iap:
  deployments:
    example_service:
      name: example_service # will be used to create kubernetes Deployment object
      client_id: example
      client_secret: very-secret
      encryption_key: very-secret_2 # used only locally
      config: ## see https://github.com/gambol99/keycloak-proxy#configuration
      ## example configuration allowing access only to the mygroup from
      ## mygithuborg organization
        scopes:
        - "groups"
        resources:
        - uri: "/*"
          groups:
          - "mygithuborg:mygroup"
      upstream_service: example.namespace.svc.cluster.local
      upstream_port: 9999
      ingress:
        host: "hostname.kubermatic.tld" # used in Ingress object
```

See `iap` section for more information:
https://github.com/kubermatic/kubermatic-installer/blob/release/v2.7/values.example.yaml

### Storage

A storageclass with the name `kubermatic-fast` needs to exist within the cluster.

### Deploy/Update all charts

Install helm on you local system & setup tiller within the cluster:

Create a service account for tiller and bind it to the `cluster-admin` role

```bash
kubectl create serviceaccount -n kube-system tiller-sa
kubectl create clusterrolebinding tiller-cluster-role --clusterrole=cluster-admin --serviceaccount=kube-system:tiller-sa
```

Afterwards install tiller with the correct set service account

```bash
helm init --service-account tiller-sa --tiller-namespace kube-system
```

To deploy all charts:

```bash
helm upgrade --install --wait --timeout 300 --values values.yaml --namespace nginx-ingress-controller nginx-ingress-controller charts/nginx-ingress-controller/
helm upgrade --install --wait --timeout 300 --values values.yaml --namespace cert-manager cert-manager charts/cert-manager/
helm upgrade --install --wait --timeout 300 --values values.yaml --namespace default certs charts/certs/
helm upgrade --install --wait --timeout 300 --values values.yaml --namespace oauth oauth charts/oauth/

# Used for storing etcd snapshots
helm upgrade --install --wait --timeout 300 --values values.yaml --namespace minio minio charts/minio/

helm upgrade --install --wait --timeout 300 --values values.yaml --namespace kubermatic kubermatic charts/kubermatic/
# When running on a cloud Provider like GCP, AWS or Azure with LB support also install the nodeport-proxy
helm upgrade --install --wait --timeout 300 --values values.yaml --namespace nodeport-proxy nodeport-proxy charts/nodeport-proxy/

# For logging stack, ensure that all charts are deployed within the logging namespace:
helm upgrade --install --wait --timeout 300 --values values.yaml --namespace logging elasticsearch charts/logging/elasticsearch/
helm upgrade --install --wait --timeout 300 --values values.yaml --namespace logging fluentd charts/logging/fluentd/
helm upgrade --install --wait --timeout 300 --values values.yaml --namespace logging kibana charts/logging/kibana/

# For monitoring stack
helm upgrade --install --wait --timeout 300 --values values.yaml --namespace monitoring prometheus charts/monitoring/prometheus/
helm upgrade --install --wait --timeout 300 --values values.yaml --namespace monitoring node-exporter charts/monitoring/node-exporter/
helm upgrade --install --wait --timeout 300 --values values.yaml --namespace monitoring kube-state-metrics charts/monitoring/kube-state-metrics/
helm upgrade --install --wait --timeout 300 --values values.yaml --namespace monitoring grafana charts/monitoring/grafana/
helm upgrade --install --wait --timeout 300 --values values.yaml --namespace monitoring alertmanager charts/monitoring/alertmanager/

# create system ingress objects for kibana/grafana/prometheus/alertmanager
# and configure Identity Aware Proxy for them
helm upgrade --install --wait --timeout 300 --values values.yaml --namespace iap iap charts/iap/
```

### etcd backups

We run an individual Cronjob every 20 minutes for each cluster to backup the etcd-clusters.
Snapshots will be stored by default to an internal S3 provided by minio.
But this can be changed by modifying the `storeContainer` & `cleanupContainer` in the `values.yaml` to your needs.

The cronjobs will be executed in the `kube-system` namespace. Therefore if a container needs credentials, a secret must be created in the kube-system namespace.

The workflow:

1. Init-container creates snapshot
2. snapshot will be saved in a shared volume
3. `storeContainer` takes the snapshot and stores it somewhere

#### storeContainer

The `storeContainer` will be executed on each backup process after a snapshot has been created and stored on a shared volume accessible by the container.
By default only the last 20 revisions will be kept. Older snapshots will be deleted.
By default the container will store the snapshot to minio.

#### cleanupContainer

The `cleanupContainer` will delete all snapshots in S3 after a cluster has been deleted.

#### Credentials

If the default container will be used, a secret in the `kube-system` namespace must be created:

```yaml
apiVersion: v1
data:
  ACCESS_KEY_ID: "SOME_BASE64_ENCODED_ACCESS_KEY"
  SECRET_ACCESS_KEY: "SOME_BASE64_ENCODED_SECRET_KEY"
kind: Secret
metadata:
  name: s3-credentials
  namespace: kube-system
type: Opaque
```

### Create DNS entries

Kubermatic needs to have at least 2 DNS entries set.

#### Dashboard, API, Dex

The frontend of kubermatic needs to run once, therefore we need exactly one DNS entry to access it.
For example, the domain could look like `kubermatic.example.com`.

##### With LoadBalancer
When running on a cloud provider which supports services of type [LoadBalancer](https://kubernetes.io/docs/concepts/services-networking/service/#loadbalancer), the nginx-chart should be configured to create such a service [values.yaml](https://github.com/kubermatic/kubermatic-installer/blob/release/v2.7/values.example.yaml).
The IP can then be fetched via:
```bash
kubectl -n ingress-nginx get service nginx-ingress-controller -o wide
#NAME                       TYPE           CLUSTER-IP     EXTERNAL-IP     PORT(S)                      AGE       SELECTOR
#nginx-ingress-controller   LoadBalancer   10.47.242.69   35.198.146.37   80:30822/TCP,443:31412/TCP   160d      app=ingress-nginx
```
The `ExternalIP` field shows the correct IP used for the DNS entry.

##### Without LoadBalancer

Without a LoadBalancer nginx will run as DaemonSet & allocate 2 ports on the host (80 & 443). Configuration of nginx happens via the [values.yaml](https://github.com/kubermatic/kubermatic-installer/blob/release/v2.7/values.example.yaml).
The DNS entry needs to be configured to point to one, or more of the cluster nodes.

#### Seed cluster (user cluster apiservers)

For each seed cluster (hosts the user cluster control plane) a single wildcard DNS entry must be configured.
All apiservers of all user clusters are being exposed via either NodePorts or a single LoadBalancer.

The domain will be based on the name of the seed-cluster as defined in the [datacenters.yaml](https://docs.kubermatic.io/installation/install_kubermatic/#defining-the-datacenters) and the domain under which the frontend is available.

For example:

* Frontend domain: kubermatic.example.com
* Seed cluster name according to [datacenters.yaml](https://docs.kubermatic.io/installation/install_kubermatic/#defining-the-datacenters) is `europe-west1`

The seed cluster domain would be: `europe-west1.kubermatic.example.com`
The corresponding wildcard entry would be: `*.europe-west1.kubermatic.example.com`

A user cluster created in this seed cluster would get the domain: `pskxx28w7k.europe-west1.kubermatic.example.com`

##### With LoadBalancer

Getting the IP:
```bash
kubectl -n nodeport-proxy get service nodeport-lb
#NAME          TYPE           CLUSTER-IP      EXTERNAL-IP    PORT(S)                                                           AGE
#nodeport-lb   LoadBalancer   10.47.242.236   35.198.93.90   32493:30195/TCP,31434:30739/TCP,30825:32503/TCP,30659:30324/TCP   93d
```

##### Without LoadBalancer

Take one or more of the seed cluster worker nodes IP's.
