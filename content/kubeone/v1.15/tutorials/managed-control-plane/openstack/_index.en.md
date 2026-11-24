+++
title = "OpenStack"
date = 2026-11-14T12:00:00+02:00
weight = 2
+++

KubeOne can create the control plane VMs on OpenStack itself, so you don't have to create them with Terraform.
kube-apiserver is exposed through an Octavia load balancer.

When `controlPlane.nodeSets` is set together with `cloudProvider.openstack.controlPlane`, `kubeone apply`:

1. Finds the existing Octavia load balancer by name and sets `apiEndpoint` from its VIP address.
2. Creates the control plane VMs with the machine-controller OpenStack driver.
3. Adds the address of each control plane VM to the load balancer pool as soon as the VM is created.

{{% notice warning %}}
Unlike the other providers, KubeOne **doesn't create** the Octavia load balancer on OpenStack. The load balancer, its
TCP listener on port 6443, a pool and a health monitor must exist before you run `kubeone apply`.
{{% /notice %}}

## Prerequisites

* OpenStack credentials (see [Credentials](#credentials)).
* An Octavia load balancer with:
  * A TCP listener on port 6443
  * A pool. You don't need to add members, KubeOne adds them.
  * A health monitor for the pool
* A network, a subnet and a security group for the control plane VMs.

The [`openstack-managed-control-plane`][tf-openstack-mcp] Terraform configs create the network, subnet, router, security
group, a bastion host and the Octavia load balancer, but no control plane VMs:

* Set the Terraform `cluster_name` variable to the KubeOne cluster name. The load balancer is then named
  `<CLUSTER_NAME>-kube-apiserver`, which is the KubeOne default. Otherwise, set `loadBalancer.name` to the
  `loadbalancer.name` Terraform output.
* The control plane VMs have no floating IPs. Set the `bastion` Terraform output as `ssh.bastion`, `ssh.bastionPort` and
  `ssh.bastionUser` of the nodeSets.
* Use the `vm` and `networking` Terraform outputs for `image`, `network`, `subnet` and `securityGroups` in
  `cloudProviderSpec`. Set the subnet by ID, because KubeOne adds the control plane VMs on this subnet to the load
  balancer pool.

The API endpoint is the private VIP of the load balancer. KubeOne connects to kube-apiserver through an SSH tunnel. To
reach the cluster from outside the network, use `kubeone proxy`.

## Credentials

KubeOne reads OpenStack credentials from the standard `OS_*` environment variables or from the credentials file.
Password authentication and application credentials are both supported.

Password authentication:

| Variable | Required | Description |
|----------|----------|-------------|
| `OS_AUTH_URL` | Yes | Identity service endpoint, e.g. `https://identity.example.com/v3` |
| `OS_USERNAME` | Yes | Username |
| `OS_PASSWORD` | Yes | Password |
| `OS_DOMAIN_NAME` | Yes | Domain name |
| `OS_TENANT_NAME` | No | Project name |
| `OS_TENANT_ID` | No | Project ID |
| `OS_REGION_NAME` | Yes | Region of the load balancer and compute services |

Application credentials:

| Variable | Required | Description |
|----------|----------|-------------|
| `OS_AUTH_URL` | Yes | Identity service endpoint |
| `OS_APPLICATION_CREDENTIAL_ID` | Yes | Application credential ID |
| `OS_APPLICATION_CREDENTIAL_SECRET` | Yes | Application credential secret |
| `OS_REGION_NAME` | Yes | Region of the load balancer and compute services |

## Configuration

```yaml
apiVersion: kubeone.k8c.io/v1beta2
kind: KubeOneCluster
name: my-cluster

versions:
  kubernetes: 1.37.2

cloudProvider:
  external: true
  openstack:
    controlPlane:
      loadBalancer:
        # Name of the existing Octavia load balancer.
        # Default: "<CLUSTER_NAME>-kube-apiserver"
        name: my-cluster-kube-apiserver
        # ID of the Octavia pool. If empty, KubeOne finds the pool
        # of the load balancer.
        # poolID: ""

controlPlane:
  nodeSets:
    - name: cp
      replicas: 3
      operatingSystem: ubuntu
      ssh:
        publicKeys:
          - ssh-ed25519 AAAA...
        username: ubuntu
        # The `bastion` Terraform output
        bastion: 203.0.113.20
        bastionPort: 22
        bastionUser: ubuntu
      cloudProviderSpec:
        image: ubuntu-24.04
        flavor: m1.small
        # IDs from the `networking` Terraform output
        network: 6c4c2a0b-...
        subnet: 0d1f6a2e-...
        securityGroups:
          - my-cluster
        configDrive: false
```

The `cloudProviderSpec` is the [machine-controller OpenStack provider spec][mc-openstack].

### Load Balancer Options

| Field | Default | Description |
|-------|---------|-------------|
| `name` | `<CLUSTER_NAME>-kube-apiserver` | Name of the existing Octavia load balancer |
| `poolID` | empty | ID of the Octavia pool. If empty, KubeOne lists the pools of the load balancer and uses the first one |

## How the Load Balancer Works

During `kubeone apply`, KubeOne:

1. Finds the load balancer by name. Its VIP address becomes `apiEndpoint.host`.
2. Finds the pool, unless `poolID` is set.
3. Adds the private IP of each control plane VM (or the public IP, if it has no private one) to the pool on port 6443 as
   soon as the VM is created. The first control plane node is then reachable through the load balancer when the cluster
   is initialized. KubeOne only adds VMs that aren't members yet.

If `apiEndpoint` is already known from a previous run, KubeOne skips the lookup.

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

`--destroy-control-plane` deletes the control plane VMs.

{{% notice warning %}}

`--destroy-control-plane-load-balancer` deletes the Octavia load balancer with its listeners and pools (cascade delete),
even though Terraform created it. If you manage the load balancer with Terraform, omit this flag and run `terraform
destroy` instead.

{{% /notice %}}

[tf-openstack-mcp]: https://github.com/kubermatic/kubeone/tree/main/examples/terraform/openstack-managed-control-plane
[mc-openstack]: https://github.com/kubermatic/machine-controller/blob/main/docs/cloud-provider.md#openstack
