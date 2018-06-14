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
  # The name needs to match the a context in the kubeconfig given to the controller
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

```


### Creating the Master Cluster `values.yaml`
Installation of Kubermatic uses the [Kubermatic Installer][4], which is essentially a kubernetes job with [Helm][5] and the required charts to install Kubermatic and its associated resources.
Customization of the cluster configuration is done using a cluster-specific `values.yaml`, stored as a secret within the cluster.

As a reference you can check out [values.yaml](values.yaml).

### Storage
A storageclass with the name `kubermatic-fast` needs to exist within the cluster.

### Deploy installer
```bash
kubectl create -f installer/namespace.yaml
kubectl create -f installer/serviceaccount.yaml
kubectl create -f installer/clusterrolebinding.yaml
# values.yaml is the file you created during the step above
kubectl -n kubermatic-installer create secret generic values --from-file=values.yaml
#Create the docker secret - needs to have read access to kubermatic/installer
kubectl -n kubermatic-installer create secret docker-registry dockercfg --docker-username='' --docker-password='' --docker-email=''
kubectl -n kubermatic-installer create secret docker-registry quay --docker-username='' --docker-password='' --docker-email=''
# Create and run the installer job
# Replace the version in the installer job template
cp installer/install-job.template.yaml install-job.yaml
sed -i "s/{INSTALLER_TAG}/v2.5.15/g" install-job.yaml
kubectl create -f install-job.yaml
```

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
kubectl -n nodeport-exposer describe service nodeport-exposer | grep "LoadBalancer Ingress"
```
