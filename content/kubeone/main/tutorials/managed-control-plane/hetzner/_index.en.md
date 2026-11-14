+++
title = "Hetzner"
date = 2026-11-14T12:00:00+02:00
weight = 1
+++

KubeOne can create the control plane servers and the kube-apiserver load
balancer on Hetzner Cloud itself, so you don't have to create them with
Terraform.

When `controlPlane.nodeSets` is set together with
`cloudProvider.hetzner.controlPlane`, `kubeone apply`:

1. Creates a Hetzner Cloud load balancer, or reuses an existing one with the
   same name, and sets `apiEndpoint` from its public IPv4 address.
2. Creates the control plane servers with the machine-controller Hetzner
   driver.
3. Labels the servers so that the load balancer selects them as targets
   automatically.

{{% notice warning %}}
Hetzner managed control plane support was introduced in KubeOne 1.13 as a
beta feature.
{{% /notice %}}

## Prerequisites

* A Hetzner Cloud API token with read/write access.
* A private network. KubeOne attaches the load balancer to it, and the load
  balancer reaches kube-apiserver through the private addresses of the
  servers. The load balancer location must be in the network zone of the
  subnet. For example, `nbg1` is in `eu-central`.

The [`hetzner-managed-control-plane`][tf-hetzner-mcp] Terraform configs create
the private network, a subnet and a firewall. They don't create any control
plane servers or a load balancer. The firewall applies to all servers with the
label `kubeone_cluster_name=<CLUSTER_NAME>`. KubeOne adds this label to the
control plane servers. Add it to the worker `labels` too.

## Credentials

KubeOne reads the API token from the `HCLOUD_TOKEN` key of the credentials
file, or from the `HCLOUD_TOKEN` environment variable:

```yaml
HCLOUD_TOKEN: <your-api-token>
```

## Configuration

```yaml
apiVersion: kubeone.k8c.io/v1beta2
kind: KubeOneCluster
name: my-cluster

versions:
  kubernetes: 1.36.2

cloudProvider:
  external: true
  hetzner:
    # Name or ID of the private network. Required with the managed control plane.
    networkID: my-cluster

    controlPlane:
      loadBalancer:
        # Name of the load balancer. Default: "<CLUSTER_NAME>-kubeapi"
        name: my-cluster-kubeapi
        # Load balancer type. Default: "lb11"
        type: lb11
        # Location of the load balancer. Default: "nbg1"
        location: nbg1
        # Assign a public IPv4 address. Default: true
        publicIP: true
        # Additional labels of the load balancer
        labels:
          env: production

controlPlane:
  nodeSets:
    - name: cp
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
        # The load balancer reaches the control plane over the private network
        networks:
          - my-cluster

dynamicWorkers:
  - name: my-cluster-pool1
    replicas: 2
    providerSpec:
      sshPublicKeys:
        - ssh-ed25519 AAAA...
      operatingSystem: ubuntu
      cloudProviderSpec:
        serverType: cx23
        location: nbg1
        image: ubuntu-24.04
        networks:
          - my-cluster
        labels:
          kubeone_cluster_name: my-cluster
```

The `cloudProviderSpec` is the [machine-controller Hetzner provider
spec][mc-hetzner].

### Load Balancer Options

| Field | Default | Description |
|-------|---------|-------------|
| `name` | `<CLUSTER_NAME>-kubeapi` | Name of the load balancer |
| `type` | `lb11` | Load balancer type (size) |
| `location` | `nbg1` | Location of the load balancer |
| `publicIP` | `true` | Assign a public IPv4 address to the load balancer |
| `labels` | empty | Additional labels of the load balancer |

## How the Load Balancer Works

During `kubeone apply`, KubeOne looks up the load balancer by name. If it
exists, KubeOne reuses it. Otherwise, KubeOne creates it with:

* A TCP service on port 6443 with a health check on port 6443
* An attachment to the private network from `networkID`
* Targets selected by label, using the private IPs of the servers

KubeOne adds these labels to the load balancer and to every control plane
server:

| Label | Value | Purpose |
|-------|-------|---------|
| `kubeone_cluster_name` | `<CLUSTER_NAME>` | Identifies the cluster |
| `kubeone_role` | `api` | The load balancer selects its targets by this label |
| `kubeone_own_since_timestamp` | Unix timestamp | Records when the server was created |

Servers with these labels become load balancer targets automatically, so
KubeOne doesn't need to register them. If `apiEndpoint` is already known from a
previous run, KubeOne skips the load balancer step.

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

This deletes the control plane servers and the load balancer. Then delete the
network and the firewall with `terraform destroy`.

[tf-hetzner-mcp]: https://github.com/kubermatic/kubeone/tree/main/examples/terraform/hetzner-managed-control-plane
[mc-hetzner]: https://github.com/kubermatic/machine-controller/blob/main/docs/cloud-provider.md#hetzner-cloud
