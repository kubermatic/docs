+++
title = "Provisioning"
date = 2020-04-01T12:00:00+02:00
weight = 7
enableToc = true
aliases = [
    "/kubeone/master/quickstarts/",
    "/kubeone/master/quickstarts/aws/",
    "/kubeone/master/quickstarts/azure/",
    "/kubeone/master/quickstarts/digitalocean/",
    "/kubeone/master/quickstarts/gce/",
    "/kubeone/master/quickstarts/hetzner/",
    "/kubeone/master/quickstarts/openstack/",
    "/kubeone/master/quickstarts/packet/",
    "/kubeone/master/quickstarts/vsphere/",
]
+++

This document shows how to install and provision a Kubernetes cluster using
KubeOne.

## Prerequisites

It's expected that you've already created the infrastructure to be used for the
cluster. If you didn't, you should check the
[Infrastructure docs][provisioning]. We provide the
[example Terraform configs][terraform-configs] that you can use to get started.

If you want to use the [Terraform Integration][terraform-integration], make
sure that you exported the Terraform state file as
[described here][terraform-state]. We'll refer to this file as `tf.json`
throughput the document.

## Creating The KubeOne Configuration Manifest

KubeOne declares clusters declaratively using the KubeOne Configuration
Manifest. The first step in the provisioning process is to create the manifest
and define the cluster that's going to be provisioned. The manifest **must**
define at least the following properties:

* The Kubernetes version to be deployed
* Provider-specific information
* Endpoint of the Kubernetes API server load balancer 
* Information about hosts that will be provisioned as control plane
* Information needed to provision worker nodes

If you're using the [Terraform Integration][terraform-integration], you only
need to specify the Kubernetes version and provider-specific information,
as other required information is sourced from the exported Terraform state
file.

Additionally, you can use the configuration manifest to change various
properties of your cluster, such as the cluster networking configuration,
the CNI plugin to be used, enable various features (e.g. PSP, PodPresets...),
and more. For the full configuration manifest reference, run
`kubeone config print --full` or check the [API reference page][api-reference].

Below, you can find example manifests for each
[supported provider][supported-provider] that you can use to get started.

{{< tabs name="Manifests" >}}
{{% tab name="AWS" %}}
```yaml
apiVersion: kubeone.io/v1beta1
kind: KubeOneCluster
versions:
  kubernetes: '1.18.6'
cloudProvider:
  aws: {}
```
{{% /tab %}}
{{% tab name="Azure" %}}
**Make sure to replace the placeholder values with real values in the
cloud-config section.**

You can find the requirements for azure and a setup guide in the [Kubermatic documentation](https://docs.kubermatic.com/kubermatic/v2.15/requirements/cloud_provider/_azure/)

```yaml
apiVersion: kubeone.io/v1beta1
kind: KubeOneCluster
versions:
  kubernetes: '1.18.6'
cloudProvider:
  azure: {}
  cloudConfig: |
    {
      "tenantId": "<AZURE TENANT ID>",
      "subscriptionId": "<AZURE SUBSCIBTION ID>",
      "aadClientId": "<AZURE CLIENT ID>",
      "aadClientSecret": "<AZURE CLIENT SECRET>",
      "resourceGroup": "<SOME RESOURCE GROUP>",
      "location": "westeurope",
      "subnetName": "<SOME SUBNET NAME>",
      "routeTableName": "",
      "securityGroupName": "<SOME SECURITY GROUP>",
      "vnetName": "<SOME VIRTUAL NETWORK>",
      "primaryAvailabilitySetName": "<SOME AVAILABILITY SET NAME>",
      "useInstanceMetadata": true,
      "useManagedIdentityExtension": false,
      "userAssignedIdentityID": ""
    }
```
{{% /tab %}}
{{% tab name="DigitalOcean" %}}
`external: true` instructs KubeOne to deploy the
[DigitalOcean Cloud Controller Manager](https://github.com/digitalocean/digitalocean-cloud-controller-manager).
The CCM provides additional cluster features, such as LoadBalancer Services,
and fetches information about nodes from the API.

```yaml
apiVersion: kubeone.io/v1beta1
kind: KubeOneCluster
versions:
  kubernetes: '1.18.6'
cloudProvider:
  digitalocean: {}
  external: true
```
{{% /tab %}}
{{% tab name="GCE" %}}
Setting `regional = true` in the cloud-config is required when control plane
nodes are across multiple availability zones. We deploy control plane hosts
in multiple AZs by default in our example Terraform configs.

```yaml
apiVersion: kubeone.io/v1beta1
kind: KubeOneCluster
versions:
  kubernetes: '1.18.6'
cloudProvider:
  gce: {}
  cloudConfig: |
    [global]
    regional = true
```

Due to how GCP LBs work, initial `terraform apply` requires variable `control_plane_target_pool_members_count` to be set
to 1.

```bash
terraform apply -var=control_plane_target_pool_members_count=1
```

Once initial `kubeone install` or `kubeone apply` is done, the `control_plane_target_pool_members_count` should not be
used.
{{% /tab %}}
{{% tab name="Hetzner" %}}
`external: true` instructs KubeOne to deploy the
[Hetzner Cloud Controller Manager](https://github.com/hetznercloud/hcloud-cloud-controller-manager).
The Hetzner CCM fetches information about nodes from the API.

```yaml
apiVersion: kubeone.io/v1beta1
kind: KubeOneCluster
versions:
  kubernetes: '1.18.6'
cloudProvider:
  hetzner: {}
  external: true
```
{{% /tab %}}
{{% tab name="OpenStack" %}}
**Make sure to replace the placeholder values with real values in the
cloud-config section.**

```yaml
apiVersion: kubeone.io/v1beta1
kind: KubeOneCluster
versions:
  kubernetes: '1.18.6'
cloudProvider:
  openstack: {}
  cloudConfig: |
    [Global]
    username=OS_USERNAME
    password=OS_PASSWORD
    auth-url=https://OS_AUTH_URL/identity/v3
    tenant-id=OS_TENANT_ID
    domain-id=OS_DOMAIN_ID

    [LoadBalancer]
    subnet-id=SUBNET_ID
```
{{% /tab %}}
{{% tab name="Packet" %}}
`external: true` instructs KubeOne to deploy the
[Packet Cloud Controller Manager](https://github.com/packethost/packet-ccm).
The Packet CCM fetches information about nodes from the API.

**It’s important to provide custom clusterNetwork settings in order to avoid
colliding with the Packet private network which is `10.0.0.0/8`.**

```yaml
apiVersion: kubeone.io/v1beta1
kind: KubeOneCluster

versions:
  kubernetes: "1.18.6"

cloudProvider:
  packet: {}
  external: true

clusterNetwork:
  podSubnet: "192.168.0.0/16"
  serviceSubnet: "172.16.0.0/12"
```
{{% /tab %}}
{{% tab name="vSphere" %}}
**Make sure to replace the placeholder values with real values in the
cloud-config section. The `vsphere-ccm-credentials` Secret is created
automatically by KubeOne as of v1.0.4.**

```yaml
apiVersion: kubeone.io/v1beta1
kind: KubeOneCluster
versions:
  kubernetes: '1.18.6'
cloudProvider:
  vsphere: {}
  cloudConfig: |
    [Global]
    secret-name = "vsphere-ccm-credentials"
    secret-namespace = "kube-system"
    port = "443"
    insecure-flag = "0"

    [VirtualCenter "1.1.1.1"]

    [Workspace]
    server = "1.1.1.1"
    datacenter = "dc-1"
    default-datastore="exsi-nas"
    resourcepool-path="kubeone"
    folder = "kubeone"

    [Disk]
    scsicontrollertype = pvscsi

    [Network]
    public-network = "NAT Network"
```
{{% /tab %}}
{{< /tabs >}}

Throughput the document, we're going to assume that you've placed your
configuration manifest in a file called `kubeone.yaml`.

## Provisioning The Cluster

With the configuration manifest in place, you're ready to provision the
cluster. The cluster is provisioned by running the appropriate
`kubeone apply` command, and providing it the configuration manifest and the
exported Terraform state file if the Terraform integration is used.

```bash
kubeone apply --manifest kubeone.yaml -t tf.json
```

The `apply` command analyzes the given instances, verifies that there is no
Kubernetes running on those instances, and offers you to provision the cluster.
You'll be asked to confirm your intention to provision the cluster by typing
`yes`.

```
INFO[11:37:21 CEST] Determine hostname…                          
INFO[11:37:28 CEST] Determine operating system…                  
INFO[11:37:30 CEST] Running host probes…                         
The following actions will be taken: 
Run with --verbose flag for more information.
	+ initialize control plane node "ip-172-31-220-51.eu-west-3.compute.internal" (172.31.220.51) using 1.18.6
	+ join control plane node "ip-172-31-221-177.eu-west-3.compute.internal" (172.31.221.177) using 1.18.6
	+ join control plane node "ip-172-31-222-48.eu-west-3.compute.internal" (172.31.222.48) using 1.18.6
	+ ensure machinedeployment "marko-1-eu-west-3a" with 1 replica(s) exists
	+ ensure machinedeployment "marko-1-eu-west-3b" with 1 replica(s) exists
	+ ensure machinedeployment "marko-1-eu-west-3c" with 1 replica(s) exists

Do you want to proceed (yes/no):
```

{{% notice note %}}
If you encounter any issue with the `apply` command or you want
to force the installation process, you can run the installation command
manually: `kubeone install --manifest kubeone.yaml -t tf.json`.
It's recommended to use the `apply` command whenever it's possible.
{{% /notice %}}


After confirming your intention to provision the cluster, the process will
start. It usually takes 5-10 minutes for cluster to be provisioned. At the end,
you should see output such as the following one:

```
INFO[11:42:11 CEST] Determine hostname…                          
INFO[11:42:11 CEST] Determine operating system…                  
INFO[11:42:11 CEST] Installing prerequisites…                    
INFO[11:42:11 CEST] Creating environment file…                    node=172.31.222.48 os=ubuntu
INFO[11:42:11 CEST] Creating environment file…                    node=172.31.220.51 os=ubuntu
INFO[11:42:11 CEST] Creating environment file…                    node=172.31.221.177 os=ubuntu
INFO[11:42:11 CEST] Configuring proxy…                            node=172.31.221.177 os=ubuntu
INFO[11:42:11 CEST] Installing kubeadm…                           node=172.31.221.177 os=ubuntu
INFO[11:42:11 CEST] Configuring proxy…                            node=172.31.222.48 os=ubuntu
INFO[11:42:11 CEST] Installing kubeadm…                           node=172.31.222.48 os=ubuntu
INFO[11:42:11 CEST] Configuring proxy…                            node=172.31.220.51 os=ubuntu
INFO[11:42:11 CEST] Installing kubeadm…                           node=172.31.220.51 os=ubuntu
INFO[11:43:17 CEST] Generating kubeadm config file…              
INFO[11:43:18 CEST] Uploading config files…                       node=172.31.222.48
INFO[11:43:18 CEST] Uploading config files…                       node=172.31.220.51
INFO[11:43:18 CEST] Uploading config files…                       node=172.31.221.177
INFO[11:43:20 CEST] Configuring certs and etcd on first controller… 
INFO[11:43:20 CEST] Ensuring Certificates…                        node=172.31.220.51
INFO[11:43:22 CEST] Downloading PKI…                             
INFO[11:43:23 CEST] Downloading PKI files…                        node=172.31.220.51
INFO[11:43:24 CEST] Creating local backup…                        node=172.31.220.51
INFO[11:43:24 CEST] Deploying PKI…                               
INFO[11:43:24 CEST] Uploading PKI files…                          node=172.31.222.48
INFO[11:43:24 CEST] Uploading PKI files…                          node=172.31.221.177
INFO[11:43:28 CEST] Configuring certs and etcd on consecutive controller… 
INFO[11:43:28 CEST] Ensuring Certificates…                        node=172.31.222.48
INFO[11:43:28 CEST] Ensuring Certificates…                        node=172.31.221.177
INFO[11:43:30 CEST] Initializing Kubernetes on leader…           
INFO[11:43:30 CEST] Running kubeadm…                              node=172.31.220.51
INFO[11:45:05 CEST] Building Kubernetes clientset…               
INFO[11:45:05 CEST] Check if cluster needs any repairs…          
INFO[11:45:07 CEST] Joining controlplane node…                   
INFO[11:45:07 CEST] Waiting 15s to ensure main control plane components are up…  node=172.31.221.177
INFO[11:45:22 CEST] Joining control plane node                    node=172.31.221.177
INFO[11:46:05 CEST] Waiting 15s to ensure main control plane components are up…  node=172.31.222.48
INFO[11:46:20 CEST] Joining control plane node                    node=172.31.222.48
INFO[11:46:54 CEST] Downloading kubeconfig…                      
INFO[11:46:54 CEST] Ensure node local DNS cache…                 
INFO[11:46:54 CEST] Activating additional features…              
INFO[11:46:56 CEST] Applying canal CNI plugin…                   
INFO[11:47:10 CEST] Creating credentials secret…                 
INFO[11:47:10 CEST] Installing machine-controller…               
INFO[11:47:17 CEST] Installing machine-controller webhooks…      
INFO[11:47:17 CEST] Waiting for machine-controller to come up…   
INFO[11:48:07 CEST] Creating worker machines…               
```

At this point, your cluster is provisioned, but it may take several more
minutes for worker nodes to get created and joined the cluster. In meanwhile,
you can configure the cluster access.

## Configuring The Cluster Access

KubeOne automatically downloads the Kubeconfig file for the cluster. It's named
as **\<cluster_name>-kubeconfig**, where **\<cluster_name>** is the name
provided in the `terraform.tfvars` file. You can use it with kubectl such as:

```bash
kubectl --kubeconfig=<cluster_name>-kubeconfig
```

or export the `KUBECONFIG` environment variable:

```bash
export KUBECONFIG=$PWD/<cluster_name>-kubeconfig
```

You can check the [Configure Access To Multiple Clusters][access-clusters]
document to learn more about managing access to your clusters.

Finally, to test is everything properly, you can try to get nodes and
verify that worker nodes joined a cluster and that all nodes are ready.

```bash
kubectl get nodes
```

Note that the number of worker nodes may differ between providers.
In our example Terraform configs, we usually deploy 3 worker nodes on providers
with multiple availability zones and one worker node for other providers.

```
NAME                                           STATUS   ROLES    AGE   VERSION
ip-172-31-220-166.eu-west-3.compute.internal   Ready    <none>   38m   v1.18.6
ip-172-31-220-51.eu-west-3.compute.internal    Ready    master   43m   v1.18.6
ip-172-31-221-177.eu-west-3.compute.internal   Ready    master   42m   v1.18.6
ip-172-31-221-18.eu-west-3.compute.internal    Ready    <none>   38m   v1.18.6
ip-172-31-222-211.eu-west-3.compute.internal   Ready    <none>   38m   v1.18.6
ip-172-31-222-48.eu-west-3.compute.internal    Ready    master   41m   v1.18.6
```

If you get output as above, it means that your cluster is fully provisioned and
ready, and that you can access it using kubectl.

## Next Steps

Once you have a working cluster, you should learn more about managing your
worker nodes by checking the [Managing Worker Nodes section][managing-workers].

[provisioning]: {{< ref "../infrastructure" >}}
[terraform-configs]: {{< ref "../infrastructure/terraform_configs" >}}
[terraform-integration]: {{< ref "../infrastructure/terraform_integration" >}}
[terraform-state]: {{< ref "../infrastructure/terraform_configs#exporting-terraform-state" >}}
[api-reference]: {{< ref "../api_reference/v1beta1" >}}
[supported-provider]: {{< ref "../compatibility_info" >}}
[access-clusters]: https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/
[managing-workers]: {{< ref "../workers" >}}
