+++
title = "Cloud Providers"
date = 2024-05-31T07:00:00+02:00
weight = 1
+++

## Alibaba

`machine.spec.providerConfig.cloudProviderSpec`:

```yaml
# If empty, can be set via ALIBABA_ACCESS_KEY_ID env var
accessKeyID: "<< YOUR ACCESS ID >>"
accessKeySecret: "<< YOUR ACCESS SECRET >>"
# instance type
instanceType: "ecs.t1.xsmall"
# instance name
instanceName: "alibaba-instance"
# region
regionID: eu-central-1
# image id
imageID: "aliyun_2_1903_64_20G_alibase_20190829.vhd"
# disk type
diskType: "cloud_efficiency"
# disk size in GB
diskSize: "40"
# set an existing vSwitch ID to use, VPC default is used if not set.
vSwitchID:
labels:
  "kubernetesCluster": "my-cluster"
```

## Anexia Engine

Refer to the [Anexia Engine]({{< relref "./anexia" >}}) specific documentation.

## AWS

`machine.spec.providerConfig.cloudProviderSpec`:

```yaml
# your aws access key id
accessKeyId: "<< YOUR_ACCESS_KEY_ID >>"
# your aws secret access key id
secretAccessKey: "<< YOUR_SECRET_ACCESS_KEY_ID >>"
# region for the instance
region: "eu-central-1"
# availability zone for the instance
availabilityZone: "eu-central-1a"
# vpc id for the instance
vpcId: "vpc-079f7648481a11e77"
# subnet id for the instance
subnetId: "subnet-2bff4f43"
# enable public IP assignment, default is true
assignPublicIP: true
# instance type
instanceType: "t2.micro"
# enable provisioning as spot instance machine, default false
isSpotInstance: false
# size of the root disk in gb
diskSize: 50
# root disk type (gp2, gp3, io1, io2, st1, sc1, or standard)
diskType: "io2"
# IOPS for EBS volumes, required with diskType: io1
diskIops: 500
# enable EBS volume encryption
ebsVolumeEncrypted: false
# optional! the ami id to use. Needs to fit to the specified operating system
ami: ""
# optional! The security group ids for the instance.
# When not set a 'kubernetes-v1' security group will get created
securityGroupIDs:
  - ""
# name of the instance profile to use, required.
instanceProfile : ""

# instance tags ("KubernetesCluster": "my-cluster" is a required tag.
# If not set, the kubernetes controller-manager will delete the nodes)
tags:
  "KubernetesCluster": "my-cluster"
```

## Azure

`machine.spec.providerConfig.cloudProviderSpec`:

```yaml
# Can also be set via the env var 'AZURE_TENANT_ID' on the machine-controller
tenantID: "<< AZURE_TENANT_ID >>"
# Can also be set via the env var 'AZURE_CLIENT_ID' on the machine-controller
clientID: "<< AZURE_CLIENT_ID >>"
# Can also be set via the env var 'AZURE_CLIENT_SECRET' on the machine-controller
clientSecret: "<< AZURE_CLIENT_SECRET >>"
# Can also be set via the env var 'AZURE_SUBSCRIPTION_ID' on the machine-controller
subscriptionID: "<< AZURE_SUBSCRIPTION_ID >>"
# Azure location
location: "westeurope"
# Azure resource group
resourceGroup: "<< YOUR_RESOURCE_GROUP >>"
# Azure resource group of the vnet
vnetResourceGroup: "<< YOUR_VNET_RESOURCE_GROUP >>"
# Azure availability set
availabilitySet: "<< YOUR AVAILABILITY SET >>"
# VM size
vmSize: "Standard_B1ms"
# optional OS and Data disk size values in GB. If not set, the defaults for the vmSize will be used.
osDiskSize: 30
dataDiskSize: 30
# network name
vnetName: "<< VNET_NAME >>"
# subnet name
subnetName: "<< SUBNET_NAME >>"
# route able name
routeTableName: "<< ROUTE_TABLE_NAME >>"
# assign public IP addresses for nodes, required for Internet access
assignPublicIP: true
# security group
securityGroupName: my-security-group
# node tags
tags:
  "kubernetesCluster": "my-cluster"
```

## DigitalOcean

`machine.spec.providerConfig.cloudProviderSpec`:

```yaml
# your digitalocean token
token: "<< YOUR_DO_TOKEN >>"
# droplet region
region: "fra1"
# droplet size
size: "2gb"
# enable backups for the droplet
backups: false
# enable ipv6 for the droplet
ipv6: false- Add operating system config
# enable private networking for the droplet
private_networking: true
# enable monitoring for the droplet
monitoring: true
# add the following tags to the droplet
tags:
- "machine-controller"
```

## Equinix Metal

`machine.spec.providerConfig.cloudProviderSpec`:

```yaml
# If empty, can be set via METAL_AUTH_TOKEN env var
token: "<< METAL_AUTH_TOKEN >>"
# instance type
instanceType: "t1.small.x86"
# Equinix Metal project ID
projectID: "<< PROJECT_ID >>"
# Equinix Metal facilities
facilities:
  - "ewr1"
# Equinix Metal billingCycle
billingCycle: ""
# node tags
tags:
  "kubernetesCluster": "my-cluster"
```

## Google Cloud Platform

`machine.spec.providerConfig.cloudProviderSpec`:

```yaml
# The service account needs to be base64-encoded.
serviceAccount: "<< GOOGLE_SERVICE_ACCOUNT_BASE64 >>"
# See https://cloud.google.com/compute/docs/regions-zones/
zone: "europe-west3-a"
# See https://cloud.google.com/compute/docs/machine-types
machineType: "n1-standard-2"
# See https://cloud.google.com/compute/docs/instances/preemptible
preemptible: false
# In GB
diskSize: 25
# Can be 'pd-standard' or 'pd-ssd'
diskType: "pd-standard"
# The name or self_link of the network and subnetwork to attach this interface to;
# either of both can be provided, otherwise default network will taken
# in case if both empty — default network will be used
network: "my-cool-network"
subnetwork: "my-cool-subnetwork"
# assign a public IP Address. Required for Internet access
assignPublicIPAddress: true
# if true, does not inject the Service Account from the controller in the machine, leaving it empty
disableMachineServiceAccount: false
# set node labels
labels:
  "kubernetesCluster": "my-cluster"
```

## Hetzner Cloud

`machine.spec.providerConfig.cloudProviderSpec`:

```yaml
token: "<< HETZNER_API_TOKEN >>"
serverType: "cx11"
datacenter: ""
location: "fsn1"
# Optional: network IDs or names
networks:
  - "<< YOUR_NETWORK >>"
# set node labels
labels:
  "kubernetesCluster": "my-cluster"
```

## KubeVirt

`machine.spec.providerConfig.cloudProviderSpec`:

```yaml
# base64-encoded kubeconfig to access KubeVirt cluster
kubeconfig: '<< KUBECONFIG_BASE64 >>'
# KubeVirt namespace
namespace: kube-system
# kubernetes storage class
storageClassName: kubermatic-fast
# storage PVC size
pvcSize: "10Gi"
# OS Image URL
sourceURL: http://10.109.79.210/<< OS_NAME >>.img
# instance resources
cpus: "1"
memory: "2048M"
```

See also the [KubeVirt documentation]({{< relref "./kubevirt" >}}).

## Linode

{{% notice info %}}
This is a [community provider]({{< relref "../#community-providers" >}}).
{{% /notice %}}

`machine.spec.providerConfig.cloudProviderSpec`:

```yaml
# your linode token
token: "<< YOUR_LINODE_TOKEN >>"
# linode region
region: "eu-west"
# linode size
type: "g6-standard-2"
# enable backups for the linode
backups: false
# enable private networking for the linode
private_networking: true
# add the following tags to the linode
tags:
- "machine-controller"
```

## Nutanix

Refer to the [Nutanix]({{< relref "./nutanix" >}}) specific documentation.

## OpenNebula

{{% notice info %}}
This is a [community provider]({{< relref "../#community-providers" >}}).
{{% /notice %}}

`machine.spec.providerConfig.cloudProviderSpec`:

```yaml
# XML-RPC endpoint of your OpenNebula installation
endpoint: ""
# your OpenNebula username
username: ""
# your OpenNebula password
password: ""

# cpu (float64)
cpu: 1
# vcpu
vcpu: 2
# memory in MB
memory: 1024

# the name of the image to use, needs to be owned by the current user
image: "Amazon Linux 2"
# which datastore to use for the image
datastore: ""
# size of the disk in MB
diskSize: 51200

# network name, needs to be owned by the current user
network: ""

# whether to enable the VNC console
enableVNC: true

# optional key/value pairs to add to the VM template
vmTemplateExtra:
  # useful for e.g. setting the placement attributes as defined in https://docs.opennebula.io/6.4/management_and_operations/references/template.html#template-placement-section
  SCHED_REQUIREMENTS: 'RACK="G4"'
```

## OpenStack

Refer to the [OpenStack]({{< relref "./openstack#provider-configuration" >}}) specific documentation.

## Scaleway

`machine.spec.providerConfig.cloudProviderSpec`:

```yaml
# your scaleway access key
accessKey: "<< SCW_ACCESS_KEY >>"
# your scaleway secret key
secretKey: "<< SCW_SECRET_KEY >>"
# your scaleway project ID
projectId: "<< SCW_DEFAULT_PROJECT_ID >>"
# server zone
zone: "fr-par-1"
# server commercial type
commercialType: "DEV1-M"
# enable ipv6 for the server
ipv6: false
# add the following tags to the server
tags:
  - "machine-controller"
```

## VMware Cloud Director

Refer to the [VMware Cloud Director]({{< relref "./vmware-cloud-director#provider-configuration" >}}) specific documentation.

## vSphere

Refer to the [vSphere]({{< relref "./vsphere#provider-configuration" >}}) specific documentation.

## Vultr

{{% notice info %}}
This is a [community provider]({{< relref "../#community-providers" >}}).
{{% /notice %}}

`machine.spec.providerConfig.cloudProviderSpec`:

```yaml
apiKey: "<< VULTR_API_KEY >>"
plan: "vhf-8c-32gb"
region: ""
osId: 127
```
