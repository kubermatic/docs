+++
title = "Managed Control Plane"
date = 2026-11-14T12:00:00+02:00
weight = 4
+++

Usually you create the control plane VMs and the kube-apiserver load balancer
yourself, for example with the [example Terraform configs][terraform-configs].
Then you list the VMs under `controlPlane.hosts` and set `apiEndpoint` in the
KubeOne manifest. With the managed control plane, KubeOne creates these
resources itself.

You describe the control plane with `controlPlane.nodeSets` and configure the
load balancer under `cloudProvider.<provider>.controlPlane`. Then
`kubeone apply`:

1. Creates or finds the kube-apiserver load balancer and sets `apiEndpoint` from its address.
2. Creates the control plane VMs with the [machine-controller][machine-controller] driver of the provider. KubeOne runs
   the driver itself, so no cluster is needed yet.
3. Waits until the VMs have IP addresses and adds them to `controlPlane.hosts`.
4. Adds the VMs to the load balancer.
5. Provisions the cluster as usual.

Worker nodes are still managed with `dynamicWorkers` and machine-controller, as in any other KubeOne cluster.

## Guides

The managed control plane is supported on Hetzner, OpenStack, KubeVirt, Azure, AWS, DigitalOcean and GCP. To move an
existing cluster from control plane VMs created by Terraform to the managed control plane, see
[Migrating From Terraform][migration].

{{% children depth=1 %}}
{{% /children %}}

## The `nodeSets` API

Each entry under `controlPlane.nodeSets` describes a group of identical control plane VMs:

```yaml
controlPlane:
  nodeSets:
    - name: cp              # used in the VM names: <CLUSTER_NAME>-<NODESET>-<INDEX>
      replicas: 3
      operatingSystem: ubuntu
      operatingSystemSpec:
        distUpgradeOnBoot: false
      nodeSettings:         # optional labels, annotations and taints of the Nodes
        labels: {}
        annotations: {}
        taints: []
      ssh:
        username: ubuntu
        publicKeys:
          - ssh-ed25519 AAAA...
        # Optional, same as for controlPlane.hosts
        # privateKeyFile: /path/to/key
        # agentSocket: env:SSH_AUTH_SOCK
        # port: 22
        # bastion: 203.0.113.20
        # bastionPort: 22
        # bastionUser: ubuntu
      cloudProviderSpec:
        # machine-controller provider spec, see the provider pages
```

| Field | Description |
|-------|-------------|
| `name` | Name of the nodeSet. Part of the VM names, so don't change it after the VMs were created |
| `replicas` | Number of control plane VMs in this nodeSet |
| `operatingSystem` | Operating system of the VMs, e.g. `ubuntu`. Must be supported by the machine-controller driver of the provider |
| `operatingSystemSpec` | Operating system options, e.g. `distUpgradeOnBoot` |
| `nodeSettings` | Labels, annotations and taints of the control plane Nodes |
| `ssh` | Public keys added to the VMs, and how KubeOne connects to them over SSH |
| `cloudProviderSpec` | machine-controller provider spec. It has the same format as `dynamicWorkers[].providerSpec.cloudProviderSpec` |

You need an odd number of control plane nodes for etcd quorum, usually three.
Set `replicas: 3` in one nodeSet, or use one nodeSet with `replicas: 1` per
availability zone.

## Destroying the Control Plane

By default, `kubeone reset` only resets the nodes. Two flags make it delete the
resources created by KubeOne:

```bash
kubeone reset --manifest kubeone.yaml --credentials credentials.yaml \
  --destroy-control-plane \
  --destroy-control-plane-load-balancer
```

| Flag | Description |
|------|-------------|
| `--destroy-control-plane` | Deletes the control plane VMs at the cloud provider instead of only resetting them |
| `--destroy-control-plane-load-balancer` | Also deletes the kube-apiserver load balancer. Requires `--destroy-control-plane` |

The provider pages describe which resources each provider deletes.

## Without Managed Control Plane

If you don't set `controlPlane.nodeSets`, nothing changes. You create the control plane VMs and the load balancer
yourself, and set `controlPlane.hosts` and `apiEndpoint` in the manifest, for example from the Terraform output. See
[Creating a Kubernetes Cluster][creating-clusters].

[terraform-configs]: {{< ref "../../guides/using-terraform-configs" >}}
[machine-controller]: {{< ref "../../guides/machine-controller" >}}
[creating-clusters]: {{< ref "../creating-clusters" >}}
[migration]: {{< ref "./migration" >}}
