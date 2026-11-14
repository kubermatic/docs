+++
title = "Migrating From Terraform"
date = 2026-11-14T12:00:00+02:00
weight = 100
+++

This guide shows how to move a running cluster from control plane VMs created by Terraform to control plane VMs
created by KubeOne. You replace the VMs while the cluster keeps running. The kube-apiserver endpoint doesn't change.

## How It Works

The API endpoint is in the kube-apiserver certificate and in every kubeconfig, so it can't change on a running cluster.
The migration keeps the load balancer created by Terraform and its address as `apiEndpoint`. Only the VMs behind it
are replaced:

1. Add `controlPlane.nodeSets` next to the existing `controlPlane.hosts`. KubeOne creates the new VMs and adds them to
   `controlPlane.hosts`. `kubeone apply` then joins them to the cluster as additional control plane nodes, the same
   way it joins a [replaced control plane node][manual-cluster-repair].
2. Add the new VMs to the Terraform load balancer. Some providers do this automatically, others need one of the
   workarounds described under [Provider Instructions](#provider-instructions).
3. Delete the old VMs one at a time. Each time, remove the VM from `controlPlane.hosts` and run `kubeone apply`.
   KubeOne sees more etcd members than control plane hosts, and removes the etcd member and the Node of the deleted
   VM.

Because `apiEndpoint.host` is set, KubeOne never creates its own load balancer in this setup. Terraform keeps managing
the load balancer and the network after the migration.

{{% notice warning %}}
Delete the old VMs **one at a time** and run `kubeone apply` after each one. With 3 old and 3 new control plane nodes,
etcd has 6 members and needs 4 for quorum. Deleting more than one old VM before KubeOne removes its etcd member can
break quorum.
{{% /notice %}}

## Before You Begin

* Use a KubeOne version that supports the managed control plane on your provider. See the
  [provider pages]({{< ref "../" >}}).
* Make sure the cluster is healthy. `kubeone status` must report all nodes as healthy, and `kubectl get nodes` must
  show all nodes as `Ready`.
* Don't combine the migration with a Kubernetes upgrade. KubeOne doesn't support repair and upgrade at the same time.
  Upgrade first, or after the migration.
* Take an etcd snapshot:

  ```bash
  kubeone etcd snapshot --manifest kubeone.yaml -t tf.json etcd-backup.db
  ```

* Find the current API endpoint. It's the `kubeone_api` Terraform output:

  ```bash
  terraform output -json kubeone_api
  ```

The examples below assume the [example Terraform configs][terraform-configs] and a manifest used with `-t tf.json`,
where `tf.json` is the output of `terraform output -json`. If you list the hosts in the manifest instead, edit
`controlPlane.hosts` in the manifest where this guide regenerates `tf.json`.

## Step 1: Configure the New Control Plane

Add the following to `kubeone.yaml`:

* `apiEndpoint.host` and `apiEndpoint.port`, set to the current endpoint. The Terraform output sets the same value,
  but setting it in the manifest keeps the endpoint when the Terraform output no longer has control plane hosts.
* `cloudProvider.<provider>.controlPlane` with the load balancer settings from the
  [provider instructions](#provider-instructions).
* `controlPlane.nodeSets` for the new VMs.

Put the new VMs in the same network, subnet and security groups or firewall as the old VMs, so that etcd, the
kube-apiserver and the CNI can reach each other. The `kubeone_workers` Terraform output contains these values in the
`cloudProviderSpec` of the workers, and you can copy them from there.

Give the new VMs names that don't collide with the old ones, because the VM name becomes the hostname and the Node
name. KubeOne names them `<CLUSTER_NAME>-<NODESET>-<INDEX>`, starting at index 0. The Terraform configs name them
`<CLUSTER_NAME>-cp-<N>` (OpenStack, Azure) or `<CLUSTER_NAME>-control-plane-<N>` (Hetzner, DigitalOcean, GCP). Don't
name the nodeSet `cp` or `control-plane`. This guide uses `mcp`.

For example, on Hetzner:

```yaml
apiVersion: kubeone.k8c.io/v1beta2
kind: KubeOneCluster
name: my-cluster

versions:
  kubernetes: 1.36.2

apiEndpoint:
  host: 203.0.113.10   # the current kubeone_api endpoint
  port: 6443

cloudProvider:
  external: true
  hetzner:
    networkID: my-cluster
    controlPlane:
      loadBalancer: {}

controlPlane:
  nodeSets:
    - name: mcp
      replicas: 3
      operatingSystem: ubuntu
      ssh:
        publicKeys:
          - ssh-ed25519 AAAA...
        username: root
      cloudProviderSpec:
        serverType: cx23
        location: nbg1
        image: ubuntu-24.04
        networks:
          - my-cluster
        labels:
          role: api   # selected by the Terraform load balancer
```

## Step 2: Create and Join the New VMs

```bash
terraform output -json > tf.json
kubeone apply --manifest kubeone.yaml --credentials credentials.yaml -t tf.json
```

KubeOne creates the new VMs, and the plan lists them as `+ join control plane node`. After `kubeone apply` finishes:

```bash
kubectl get nodes -l node-role.kubernetes.io/control-plane
kubeone etcd members --manifest kubeone.yaml --credentials credentials.yaml -t tf.json
```

Both must show the old and the new control plane nodes.

Then add the new VMs to the load balancer if your provider needs it (see
[Provider Instructions](#provider-instructions)), and check that the load balancer reports them as healthy.

## Step 3: Remove the Old VMs

Repeat these steps for each old control plane VM:

1. If your provider needs it, remove the VM from the load balancer (see
   [Provider Instructions](#provider-instructions)).
2. Lower `control_plane_vm_count` in the Terraform variables by one and apply. Terraform deletes the VM with the
   highest index. The first VM stays until last, so it remains the KubeOne leader until then.

   ```bash
   terraform apply -var control_plane_vm_count=2
   ```

3. Regenerate the Terraform output, so that the deleted VM is no longer in `controlPlane.hosts`, and run
   `kubeone apply`:

   ```bash
   terraform output -json > tf.json
   kubeone apply --manifest kubeone.yaml --credentials credentials.yaml -t tf.json
   ```

   KubeOne reports that the count of etcd members is higher than the count of control plane nodes, and removes the
   etcd member and the Node of the deleted VM.

4. Check that `kubeone etcd members` and `kubectl get nodes` no longer show the VM, and that the cluster is healthy,
   before you delete the next one.

After the last old VM is deleted, `control_plane_vm_count` is `0`, and all control plane hosts come from `nodeSets`.

{{% notice note %}}
Some Terraform configs refer to the first control plane VM, for example when `disable_kubeapi_loadbalancer` is set. If
`terraform apply` fails with `control_plane_vm_count = 0`, remove these references from your Terraform config.
{{% /notice %}}

## Provider Instructions

The Terraform configs create a different load balancer than KubeOne does. Each provider needs its own setup so that
the new VMs join the Terraform load balancer.

### OpenStack

KubeOne uses an existing Octavia load balancer on OpenStack anyway. The Terraform load balancer is named
`<CLUSTER_NAME>-kube-apiserver`, which is the KubeOne default, so:

```yaml
cloudProvider:
  openstack:
    controlPlane:
      loadBalancer: {}
```

KubeOne adds the new VMs to the pool of the load balancer as soon as they're created. Set the subnet of the nodeSets
by ID, KubeOne adds the VMs on it to the pool. When Terraform deletes an old VM, it removes the VM from the pool too.

{{% notice warning %}}
Don't pass `--destroy-control-plane-load-balancer` to `kubeone reset` later. It deletes the Terraform load balancer.
Delete it with `terraform destroy` instead.
{{% /notice %}}

### Hetzner

The Terraform load balancer selects its targets with the label selector `kubeone_cluster_name=<CLUSTER_NAME>,role=api`.
KubeOne adds `kubeone_cluster_name` to the servers it creates. Add `role: api` to the server labels:

```yaml
cloudProvider:
  hetzner:
    networkID: my-cluster   # the Terraform network is named after the cluster
    controlPlane:
      loadBalancer: {}

controlPlane:
  nodeSets:
    - name: mcp
      cloudProviderSpec:
        networks:
          - my-cluster
        labels:
          role: api
        # ...
```

The load balancer reaches the servers over the private network, so the nodeSets must use the Terraform network. The
Terraform firewall applies to all servers labeled `kubeone_cluster_name=<CLUSTER_NAME>`, which includes the new
servers.

The Terraform load balancer is named `<CLUSTER_NAME>-lb`. Keep the default `loadBalancer.name`
(`<CLUSTER_NAME>-kubeapi`). Then `kubeone reset --destroy-control-plane-load-balancer` finds no load balancer and
leaves the Terraform load balancer in place.

### DigitalOcean

The Terraform load balancer selects its droplets with the tag `kubernetes-cluster:<CLUSTER_NAME>`. Add the tag to the
new droplets:

```yaml
cloudProvider:
  digitalocean:
    controlPlane:
      loadBalancer: {}

controlPlane:
  nodeSets:
    - name: mcp
      cloudProviderSpec:
        region: fra1   # the region of the Terraform droplets
        tags:
          - kubernetes-cluster:my-cluster
        # ...
```

KubeOne and the Terraform configs both create droplets in the default VPC of the region, so the droplets reach each
other and the load balancer. KubeOne only deletes load balancers that target the `kubeone-cluster:<CLUSTER_NAME>` tag,
so `kubeone reset --destroy-control-plane-load-balancer` leaves the Terraform load balancer in place.

### Azure

The Terraform load balancer is named `kubernetes`, and its backend pool is `ApiServers`. KubeOne adds the network
interface of each new VM to a backend pool named `backend` on the load balancer from `loadBalancer.name`, and fails
if the pool doesn't exist. Before the migration, create a `backend` pool, move the old VMs into it, and switch the load
balancing rule to it:

```bash
RG=my-cluster-rg

az network lb address-pool create -g $RG --lb-name kubernetes -n backend

# For each Terraform control plane VM
az network nic ip-config address-pool add -g $RG \
  --nic-name <NIC_NAME> --ip-config-name <IP_CONFIG_NAME> \
  --lb-name kubernetes --address-pool backend

az network lb rule update -g $RG --lb-name kubernetes -n LBRule --backend-pool-name backend
```

To stop Terraform from switching the rule back, ignore the change in the Terraform config:

```hcl
resource "azurerm_lb_rule" "lb_rule" {
  # ...
  lifecycle {
    ignore_changes = [backend_address_pool_ids]
  }
}
```

Then point KubeOne at the Terraform load balancer:

```yaml
cloudProvider:
  azure:
    controlPlane:
      loadBalancer:
        name: kubernetes
        resourceGroup: my-cluster-rg
        location: westeurope
        sku: Standard
        publicIPName: my-cluster-lbip
```

Use the resource group, virtual network, subnet, network security group, route table and availability set of the
Terraform VMs in `cloudProviderSpec`.

{{% notice warning %}}
Don't pass `--destroy-control-plane-load-balancer` to `kubeone reset` later. It deletes the Terraform load balancer and
its public IP. Delete them with `terraform destroy` instead.
{{% /notice %}}

### AWS

The Terraform configs create a Classic Load Balancer named `<CLUSTER_NAME>-api-lb`. KubeOne registers each new
instance in an ELBv2 target group named `<LOAD_BALANCER_NAME>-tg` (cut to 32 characters), and fails if it doesn't
exist. Classic Load Balancers don't use target groups, so:

1. Create the target group KubeOne expects. It isn't attached to any load balancer, and the targets KubeOne registers
   in it don't receive traffic:

   ```bash
   aws elbv2 create-target-group --name my-cluster-kubeapi-tg \
     --protocol TCP --port 6443 --target-type ip --vpc-id <VPC_ID>
   ```

2. Stop Terraform from managing the instances of the Classic Load Balancer. Otherwise it removes the new instances
   again:

   ```hcl
   resource "aws_elb" "control_plane" {
     # ...
     lifecycle {
       ignore_changes = [instances]
     }
   }
   ```

3. Configure KubeOne:

   ```yaml
   cloudProvider:
     aws:
       region: eu-west-1
       controlPlane:
         loadBalancer:
           name: my-cluster-kubeapi   # KubeOne looks for the target group "my-cluster-kubeapi-tg"
   ```

   Use the VPC, subnet, security groups and instance profile (`<CLUSTER_NAME>-host`) of the Terraform instances in
   `cloudProviderSpec`. The Terraform load balancer is in the `common` security group, so instances in that group are
   reachable on port 6443.

4. After [Step 2](#step-2-create-and-join-the-new-vms), register the new instances on the Classic Load Balancer:

   ```bash
   aws elb register-instances-with-load-balancer --load-balancer-name my-cluster-api-lb \
     --instances <INSTANCE_ID_1> <INSTANCE_ID_2> <INSTANCE_ID_3>
   ```

5. In [Step 3](#step-3-remove-the-old-vms), deregister each old instance before you delete it:

   ```bash
   aws elb deregister-instances-from-load-balancer --load-balancer-name my-cluster-api-lb \
     --instances <OLD_INSTANCE_ID>
   ```

{{% notice warning %}}
Don't pass `--destroy-control-plane-load-balancer` to `kubeone reset` later, it fails because there's no ELBv2 load
balancer with the configured name. Delete the Classic Load Balancer with `terraform destroy` and the target group with
`aws elbv2 delete-target-group`.
{{% /notice %}}

### GCP

The Terraform configs create a target pool named `<CLUSTER_NAME>-control-plane`. KubeOne doesn't manage target pools,
and doesn't add VMs to any load balancer while `apiEndpoint.host` is set. You add the new VMs to the target pool
yourself.

1. Stop Terraform from managing the instances of the target pool:

   ```hcl
   resource "google_compute_target_pool" "control_plane_pool" {
     # ...
     lifecycle {
       ignore_changes = [instances]
     }
   }
   ```

2. Configure KubeOne. With `apiEndpoint.host` set, KubeOne only creates the firewall rules for port 6443:

   ```yaml
   cloudProvider:
     gce:
       controlPlane:
         loadBalancer: {}
   ```

   Use the network and subnetwork of the Terraform VMs in `cloudProviderSpec` of the nodeSets.

3. After [Step 2](#step-2-create-and-join-the-new-vms), add the new VMs to the target pool:

   ```bash
   gcloud compute target-pools add-instances my-cluster-control-plane \
     --instances my-cluster-mcp-a-0 --instances-zone europe-west3-a
   ```

   Add the VMs only after they joined the cluster. The GCE guest environment routes the load balancer address of a VM
   in the target pool to the VM itself. A VM that is in the target pool before it joins reaches itself instead of the
   cluster.

4. In [Step 3](#step-3-remove-the-old-vms), remove each old VM from the target pool before you delete it:

   ```bash
   gcloud compute target-pools remove-instances my-cluster-control-plane \
     --instances my-cluster-control-plane-3 --instances-zone europe-west3-a
   ```

The KubeOne load balancer name stays at its default, `<CLUSTER_NAME>-kubeapi`. KubeOne only deletes resources with the
description `kubeone:<CLUSTER_NAME>`, so `kubeone reset --destroy-control-plane-load-balancer` leaves the Terraform
load balancer in place and only deletes the firewall rules KubeOne created.

### KubeVirt

There are no KubeVirt Terraform configs, so the setup depends on how you created the control plane VMs and the API
endpoint. Keep `apiEndpoint.host`, and leave out `cloudProvider.kubevirt.controlPlane`. KubeOne then only creates the
VMs and doesn't create a Service. Add the new VMs to your existing load balancer yourself after they joined.

## After the Migration

* Keep `apiEndpoint` in `kubeone.yaml`. It's the address of the Terraform load balancer.
* Keep the Terraform configs. They still manage the load balancer, the network and the firewall or security groups.
  Don't run `terraform destroy` while the cluster is running.
* To delete the cluster, run `kubeone reset --destroy-control-plane` first, then `terraform destroy`. On OpenStack,
  Azure and AWS, don't pass `--destroy-control-plane-load-balancer`.

[manual-cluster-repair]: {{< ref "../../../guides/manual-cluster-repair" >}}
[terraform-configs]: {{< ref "../../../guides/using-terraform-configs" >}}
