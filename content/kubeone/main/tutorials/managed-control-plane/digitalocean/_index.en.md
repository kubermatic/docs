+++
title = "DigitalOcean"
date = 2026-11-14T12:00:00+02:00
weight = 6
+++

KubeOne can create the control plane droplets and the kube-apiserver load
balancer on DigitalOcean itself. You don't need Terraform or any other
infrastructure.

When `controlPlane.nodeSets` is set together with
`cloudProvider.digitalocean`, `kubeone apply`:

1. Creates a load balancer if it doesn't exist yet, or uses an existing one
   referenced by ID. KubeOne sets `apiEndpoint` from its IP address.
2. Creates the control plane droplets with the machine-controller DigitalOcean
   driver.
3. Tags each droplet with `kubeone-cluster:<CLUSTER_NAME>`. The load balancer
   selects its backends by this tag, so the droplets become targets
   automatically.

## Prerequisites

* A DigitalOcean API token (see [Credentials](#credentials)).
* No other infrastructure. The droplets and the load balancer are created in
  the default VPC of the region, with private networking enabled.
* A cluster name that is unique in the DigitalOcean account, across all
  regions. The name identifies the droplets and the load balancer.
* Droplets are named `<CLUSTER_NAME>-<NODESET>-<INDEX>`, and this name becomes
  the hostname. It can be at most 63 characters long.

## Credentials

KubeOne reads the API token from the `DIGITALOCEAN_TOKEN` key of the
credentials file, or from the `DIGITALOCEAN_TOKEN` environment variable:

```yaml
DIGITALOCEAN_TOKEN: <your-api-token>
```

Use a token with full access, or a custom-scoped token with these scopes:

| Resource | Scopes | Used for |
|----------|--------|----------|
| `droplet` | create, read, update, delete | Control plane droplets |
| `load_balancer` | create, read, update, delete | kube-apiserver load balancer |
| `tag` | create, read, delete | Droplet tags and the backends of the load balancer |
| `ssh_key` | create, read, delete | machine-controller uploads a temporary SSH key for each droplet |
| `vpc` | read | Checking the VPC of a load balancer referenced by `id` |
| `regions`, `sizes`, `image` | read | Creating droplets |

## Configuration

```yaml
apiVersion: kubeone.k8c.io/v1beta2
kind: KubeOneCluster
name: my-cluster

versions:
  kubernetes: 1.37.2

cloudProvider:
  external: true
  digitalocean:
    controlPlane:
      loadBalancer:
        # Name of the load balancer. Default: "<CLUSTER_NAME>-kubeapi"
        name: my-cluster-kubeapi
        # Region of the load balancer, must be the nodeSets region.
        # Default: region of the first nodeSet
        region: fra1
        # Number of load balancer nodes (1-100). Default: 1
        sizeUnit: 1
        # Use an existing load balancer instead of creating one
        # id: 4de7ac8b-495b-4884-9a69-1050c6793cd6

controlPlane:
  nodeSets:
    - name: cp
      replicas: 3
      # ubuntu or rockylinux
      operatingSystem: ubuntu
      ssh:
        publicKeys:
          - ssh-ed25519 AAAA...
        username: root
      cloudProviderSpec:
        region: fra1
        size: s-2vcpu-4gb
        # Default: true, must not be false
        private_networking: true
        tags:
          - env-production
```

The `cloudProviderSpec` is the [machine-controller DigitalOcean provider
spec][mc-digitalocean]. KubeOne rejects unknown fields in it, and you must not
set `token` because KubeOne takes the token from the credentials. All nodeSets
must use the same region.

You can't change the region after the droplets are created, because
DigitalOcean can't move droplets between regions. KubeOne fails if a droplet
tagged `kubeone-owned:<CLUSTER_NAME>` is in another region than the nodeSets.
To move a cluster to another region, reset it and create it again.

### Load Balancer Options

| Field | Default | Description |
|-------|---------|-------------|
| `id` | empty | ID of an existing load balancer. KubeOne never creates or deletes it |
| `name` | `<CLUSTER_NAME>-kubeapi` | Name of the load balancer to create |
| `region` | region of the first nodeSet | Region of the load balancer, must be the nodeSets region |
| `sizeUnit` | `1` | Number of load balancer nodes (1-100). Only used when KubeOne creates the load balancer. Resize an existing one in the DigitalOcean console |

If `apiEndpoint.host` is set, KubeOne doesn't create or look up any load
balancer and uses the given endpoint as it is, for example a DNS name managed
outside of KubeOne.

## How the Load Balancer Works

During `kubeone apply`, KubeOne:

1. Looks up the load balancer by name in the nodeSets region. DigitalOcean
   doesn't require unique names. If several load balancers match, KubeOne
   uses the one that targets `kubeone-cluster:<CLUSTER_NAME>`.
2. Reuses an existing load balancer only if it targets the
   `kubeone-cluster:<CLUSTER_NAME>` tag. Otherwise `kubeone apply` fails,
   because the load balancer wasn't created by KubeOne for this cluster or was
   modified. If the TCP 6443 forwarding rule is missing or the health check was
   changed, KubeOne restores them. If port 6443 forwards somewhere else,
   `kubeone apply` fails.
3. Otherwise, creates the load balancer in the default VPC of the region with:
   * A TCP forwarding rule on port 6443
   * A TCP health check on port 6443
   * Backends selected by the `kubeone-cluster:<CLUSTER_NAME>` tag
4. Waits until the load balancer is active and has an IP address, which
   usually takes a few minutes. The IP address becomes `apiEndpoint.host`.
5. Creates the control plane droplets with the cluster tag.

Don't use this load balancer for other droplets. All forwarding rules of a
DigitalOcean load balancer share the same backends, and
`kubeone reset --destroy-control-plane-load-balancer` deletes it. For
workloads, use a Service of type `LoadBalancer`.

### Using an Existing Load Balancer

When `loadBalancer.id` is set, KubeOne checks that the load balancer:

* Is regional. Global load balancers only forward HTTP and HTTPS.
* Is in the nodeSets region and in the default VPC of the region, where the
  droplets are created.
* Doesn't target other droplets or tags. A load balancer without backends is
  configured to target the `kubeone-cluster:<CLUSTER_NAME>` tag.
* Doesn't forward port 6443 to another port or protocol.
* Health checks kube-apiserver: TCP on port 6443, or HTTPS on port 6443 with
  the path `/readyz`, `/livez` or `/healthz`. KubeOne never changes the health
  check, so configure it before running `kubeone apply`. The DigitalOcean
  default (HTTP on port 80) is rejected.

KubeOne then adds the TCP 6443 forwarding rule if it's missing.

KubeOne never deletes this load balancer. On reset, KubeOne only removes the
`kubeone-cluster:<CLUSTER_NAME>` backend selector and keeps the forwarding rule
and the health check.

{{% notice warning %}}
Don't replace `id` with a `name` that points to this load balancer before you
reset the cluster. While the load balancer targets the cluster tag, KubeOne
treats it as its own and deletes it on reset.
{{% /notice %}}

### Droplet Tags

DigitalOcean doesn't store tags on load balancers. KubeOne treats a load
balancer as its own when the backends are selected by the cluster tag. KubeOne
adds these tags to each control plane droplet, in addition to
`cloudProviderSpec.tags`:

| Tag | Purpose |
|-----|---------|
| `kubeone-cluster:<CLUSTER_NAME>` | Selects the droplet as a load balancer target |
| `kubeone-owned:<CLUSTER_NAME>` | Marks the droplet as created by KubeOne |
| `kubeone_cluster_name:<CLUSTER_NAME>` | Identifies the cluster |
| `kubeone_role:control-plane` | Identifies the node role |

KubeOne replaces characters that DigitalOcean doesn't allow in tags, such as
`.`, with `_`.

### Firewall

KubeOne doesn't create a DigitalOcean cloud firewall. If you add one, the
control plane droplets must allow:

* SSH (22) from the machine where KubeOne runs
* kube-apiserver (6443) from the load balancer and the nodes
* The ports that Kubernetes and the CNI need between the nodes

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

KubeOne finds the control plane droplets in all regions by name and machine
UID tag. Don't change the cluster `name` or the nodeSet names between
`kubeone apply` and `kubeone reset`.

KubeOne deletes the load balancer only if all of these are true:

* It targets the cluster tag.
* It isn't referenced by `id`.
* `apiEndpoint.host` is unset or is the IP of the load balancer.

[mc-digitalocean]: https://github.com/kubermatic/machine-controller/blob/main/docs/cloud-provider.md#digitalocean
