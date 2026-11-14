+++
title = "Azure"
date = 2026-11-14T12:00:00+02:00
weight = 4
+++

KubeOne can create the control plane VMs and the kube-apiserver load balancer
on Azure itself, so you don't have to create them with Terraform.

When `controlPlane.nodeSets` is set together with
`cloudProvider.azure.controlPlane`, `kubeone apply`:

1. Creates a static public IP and a load balancer, if they don't exist yet,
   and sets `apiEndpoint` from the public IP address.
2. Creates the control plane VMs with the machine-controller Azure driver.
3. Adds the primary network interface of each control plane VM to the backend
   pool of the load balancer.

## Prerequisites

* Azure credentials with permissions to manage virtual machines, network
  interfaces, public IP addresses and load balancers.
* A resource group, virtual network, subnet, network security group, route
  table and availability set for the control plane VMs.

The [`azure-managed-control-plane`][tf-azure-mcp] Terraform configs create this
infrastructure, but no control plane VMs or load balancer. Use the values of
the `networking` and `vm` Terraform outputs in `cloudProviderSpec` of the
nodeSets.

## Credentials

KubeOne reads the Azure credentials from the credentials file or from the
environment:

```yaml
ARM_CLIENT_ID: <client-id>
ARM_CLIENT_SECRET: <client-secret>
ARM_TENANT_ID: <tenant-id>
ARM_SUBSCRIPTION_ID: <subscription-id>
```

KubeOne passes them to machine-controller as the corresponding `AZURE_*`
variables.

## Configuration

```yaml
apiVersion: kubeone.k8c.io/v1beta2
kind: KubeOneCluster
name: my-cluster

versions:
  kubernetes: 1.36.2

cloudProvider:
  external: true
  azure:
    controlPlane:
      loadBalancer:
        # Name of the load balancer. Default: "<CLUSTER_NAME>-kubeapi"
        name: my-cluster-kubeapi
        # Default: resourceGroup of the first nodeSet
        resourceGroup: my-cluster-rg
        # Default: location of the first nodeSet
        location: westeurope
        # "Standard" (default) or "Basic"
        sku: Standard
        # Name of the public IP. Default: "<LOAD_BALANCER_NAME>-pubip"
        publicIPName: my-cluster-kubeapi-pubip

controlPlane:
  nodeSets:
    - name: cp
      replicas: 3
      operatingSystem: ubuntu
      ssh:
        publicKeys:
          - ssh-ed25519 AAAA...
        username: ubuntu
      cloudProviderSpec:
        # Values of the `networking` Terraform output
        location: westeurope
        resourceGroup: my-cluster-rg
        vnetName: my-cluster-vpc
        subnetName: my-cluster-subnet
        securityGroupName: my-cluster-sg
        routeTableName: my-cluster-rt
        availabilitySet: my-cluster-avset
        loadBalancerSku: Standard
        # Values of the `vm` Terraform output
        imageReference:
          publisher: Canonical
          offer: ubuntu-24_04-lts
          sku: server-gen1
          version: latest
        vmSize: Standard_F2s_v2
        assignPublicIP: true
        publicIPSKU: Standard
```

The `cloudProviderSpec` is the [machine-controller Azure provider
spec][mc-azure].

### Load Balancer Options

| Field | Default | Description |
|-------|---------|-------------|
| `name` | `<CLUSTER_NAME>-kubeapi` | Name of the load balancer |
| `resourceGroup` | `resourceGroup` of the first nodeSet | Resource group of the load balancer and the public IP |
| `location` | `location` of the first nodeSet | Region of the load balancer and the public IP |
| `sku` | `Standard` | Load balancer SKU: `Standard` or `Basic` |
| `publicIPName` | `<LOAD_BALANCER_NAME>-pubip` | Name of the public IP of the load balancer |

## How the Load Balancer Works

During `kubeone apply`, KubeOne uses the Azure Network API to:

1. Create a static IPv4 public IP, if it doesn't exist.
2. Create the load balancer, if it doesn't exist, with:
   * A frontend IP configuration with the public IP
   * A backend pool for the control plane VMs
   * A TCP health probe on port 6443
   * A TCP load balancing rule for port 6443
3. Add the primary network interface of each control plane VM to the backend
   pool as soon as the VM is created.

If `apiEndpoint` is already known from a previous run, KubeOne skips the load
balancer step.

## Creating the Cluster

```bash
kubeone apply --manifest kubeone.yaml --credentials credentials.yaml
```

## Destroying the Cluster

```bash
kubeone reset --manifest kubeone.yaml --credentials credentials.yaml \
  --destroy-control-plane \
  --destroy-control-plane-load-balancer
```

This deletes the control plane VMs, the load balancer and its public IP. Then
delete the rest of the infrastructure with `terraform destroy`.

[tf-azure-mcp]: https://github.com/kubermatic/kubeone/tree/main/examples/terraform/azure-managed-control-plane
[mc-azure]: https://github.com/kubermatic/machine-controller/blob/main/docs/cloud-provider.md#azure
