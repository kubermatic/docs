+++
title = "Setup a master cluster"
date = 2018-04-28T12:07:15+02:00
weight = 5
pre = "<b></b>"
+++

## Setup a master cluster

### Master cluster

## Terminology

* **User/Customer cluster** A Kubernetes cluster created and managed by Kubermatic  
* **Seed cluster** A Kubernetes cluster which is responsible for hosting the master components of a customer cluster  
* **Master cluster** A Kubernetes cluster which is responsible for storing the information about clusters and SSH keys. It hosts the Kubermatic components and might also act as a seed cluster.
* **Seed datacenter** A definition/reference to a seed cluster  
* **Node datacenter** A definition/reference of a datacenter/region/zone at a cloud provider (aws=zone,digitalocean=region,openstack=zone)  

## Creating

### Creating the kubeconfig

The Kubermatic api lives inside the master cluster and therefore speaks to it via in-cluster communication.

The Kubermatic cluster controller needs to have a kubeconfig which contains all contexts for each seed cluster it should manage.
The name of the context within the kubeconfig needs to match an entry within the `datacenters.yaml`. See below.
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

### Defining the Datacenters
There are 2 types of datacenters:
- Seed datacenter
- Node datacenter

Both are defined in a file named `datacenters.yaml`:
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
  vsphere-hetzner:
    location: Hetzner
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


### Creating the Master Cluster `values.yaml`
Installation of Kubermatic uses the [Kubermatic Installer][4], which is essentially a kubernetes job with [Helm][5] and the required charts to install Kubermatic and its associated resources.
Customization of the cluster configuration is done using a cluster-specific `values.yaml`, stored as a secret within the cluster.

As a reference you can check out [values.yaml](values.yaml).

### Storage
A storageclass with the name `kubermatic-fast` needs to exist within the cluster.

### Deploy all charts
Install helm on you local system & install helm within the cluster:
```bash 
helm init
```

To deploy all charts:
```bash
helm upgrade --install --wait --timeout 300 --values values.yaml --namespace cert-manager cert-manager config/cert-manager/
helm upgrade --install --wait --timeout 300 --values values.yaml --namespace default certs config/certs/
helm upgrade --install --wait --timeout 300 --values values.yaml --namespace nginx-ingress-controller nginx-ingress-controller config/nginx-ingress-controller/
helm upgrade --install --wait --timeout 300 --values values.yaml --namespace oauth oauth config/oauth/
# Used for storing etcd snapshots
helm upgrade --install --wait --timeout 300 --values values.yaml --namespace minio minio config/minio/

helm upgrade --install --wait --timeout 300 --values values.yaml --namespace kubermatic kubermatic config/kubermatic/
# When running on a cloud Provider like GCP, AWS or Azure with LB support also install the nodeport-proxy
helm upgrade --install --wait --timeout 300 --values values.yaml --namespace nodeport-proxy nodeport-proxy config/nodeport-proxy/

# For logging stack, ensure that all charts are deployed within the logging namespace:
helm upgrade --install --wait --timeout 300 --values values.yaml --namespace logging elasticsearch config/logging/elasticsearch/
helm upgrade --install --wait --timeout 300 --values values.yaml --namespace logging fluentd config/logging/fluentd/
helm upgrade --install --wait --timeout 300 --values values.yaml --namespace logging kibana config/logging/kibana/
```

### etcd backups
We run a individual Cronjob every 20minutes for each Cluster to backup the etcd-clusters.
Snapshots will be stored by default to an internal S3 provided by minio.
But this can be changed by modifying the `storeContainer` & `cleanupContainer` in the values.yaml to your needs.

The cronjobs will be executed in the kube-system namespace. Therefore if a container needs credentials, a secret must be created in the kube-system namespace.

The workflow:
- Init-container creates snapshot
- Snapshot will be saved in a shared volume
- `storeContainer` takes the snapshot & stores it somewhere

#### storeContainer
The `storeContainer` will be executed on each backup process after a snapshot has been created and stored on a shared volume accessible by the container.
By default only the last 20 revisions will be kept. Older snapshots will be deleted.
By default the container will store the snapshot to minio.

#### cleanupContainer
The `cleanupContainer` will delete all snapshots in S3 after a cluster has been deleted. 

#### Credentials
If the default container will be used, a secret in the kube-system namespace must be created:

````yaml
apiVersion: v1
data:
  ACCESS_KEY_ID: "SOME_BASE64_ENCODED_ACCESS_KEY"
  SECRET_ACCESS_KEY: "SOME_BASE64_ENCODED_SECRET_KEY"
kind: Secret
metadata:
  name: s3-credentials
  namespace: kube-system
type: Opaque

```` 

### Create DNS entry for your domain
The external ip for the DNS entry can be fetched by executing
```bash
kubectl -n ingress-nginx describe service nginx-ingress-controller | grep "LoadBalancer Ingress"
```

Set the dns entry for the nodeport-exposer (the service which exposes the customer cluster apiservers):
$DATACENTER=us-central1
- *.$DATACENTER.$DOMAIN  =  *.us-central1.dev.kubermatic.io

The external ip for the DNS entry can be fetched by executing
```bash
kubectl -n nodeport-proxy describe service nodeport-lb | grep "LoadBalancer Ingress"
```
