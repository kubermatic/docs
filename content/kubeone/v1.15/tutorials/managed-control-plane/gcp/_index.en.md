+++
title = "GCP"
date = 2026-11-14T12:00:00+02:00
weight = 7
+++

KubeOne can create the control plane Compute Engine VMs and the kube-apiserver
load balancer on Google Cloud Platform (GCP) itself, so you don't have to
create them with Terraform.

When `controlPlane.nodeSets` is set together with `cloudProvider.gce`,
`kubeone apply`:

1. Creates the firewall rules and a load balancer for kube-apiserver, if they
   don't exist yet. The load balancer is a backend service-based regional
   external passthrough Network Load Balancer. KubeOne sets `apiEndpoint` from
   its static IP address.
2. Creates the control plane VMs with the machine-controller GCE driver.
3. Adds each control plane VM to the network endpoint group of its zone once
   it can serve kube-apiserver (see
   [Load Balancer Membership](#load-balancer-membership)).

## Prerequisites

* A GCP project with the Compute Engine API enabled.
* A service account JSON key with the roles listed under
  [Credentials](#credentials). A gcloud or OAuth access token is not enough,
  because machine-controller, the GCP cloud controller manager and the CSI
  driver use the same key.
* A VPC network that allows SSH (22) from where KubeOne runs and all traffic
  between the nodes. The `default` network allows this with its
  `default-allow-ssh` and `default-allow-internal` rules. For other networks,
  create equivalent firewall rules. KubeOne only creates the firewall rules of
  the load balancer.
* A public IP address on the control plane VMs (`assignPublicIPAddress: true`,
  the default) or a bastion (`ssh.bastion`), so that KubeOne can connect over
  SSH.
* Valid GCP names. The cluster name, the nodeSet names and the load balancer
  name are used in resource names and labels. These must be 1-63 lowercase
  letters, digits or `-`, and start with a letter. KubeOne validates all
  derived names, such as `<CLUSTER_NAME>-<NODESET>-<INDEX>`,
  `<CLUSTER_NAME>-control-plane` and `<LOAD_BALANCER_NAME>-<ZONE>`.

## Credentials

KubeOne reads the service account JSON key from the `GOOGLE_CREDENTIALS` key
of the credentials file, or from the `GOOGLE_CREDENTIALS` environment variable:

```yaml
GOOGLE_CREDENTIALS: |
  { "type": "service_account", "project_id": "my-project", ... }
```

The service account needs these roles in the project:

| Role | Used for |
|------|----------|
| `roles/compute.instanceAdmin.v1` | Control plane VMs |
| `roles/compute.loadBalancerAdmin` | Health check, backend service, forwarding rule, network endpoint groups |
| `roles/compute.securityAdmin` | Firewall rules |
| `roles/compute.publicIpAdmin` | Static IP address |
| `roles/iam.serviceAccountUser` | Running the VMs as the service account |

For a [Shared VPC][shared-vpc] network, it also needs
`roles/compute.securityAdmin` in the host project.

Unless you set `loadBalancer.projectID` or `cloudProviderSpec.projectID`,
KubeOne creates the VMs and the load balancer in the `project_id` of the key.
KubeOne doesn't record the project of a cluster.

{{% notice warning %}}
Use a key of the same project for every `kubeone apply` and `kubeone reset`,
or set `loadBalancer.projectID` and `cloudProviderSpec.projectID` in every
nodeSet. With a key of another project, `kubeone apply` creates a second
cluster in that project. `kubeone reset` then finds nothing to delete and
succeeds, leaving the VMs and the load balancer in the original project.
{{% /notice %}}

## Configuration

```yaml
apiVersion: kubeone.k8c.io/v1beta2
kind: KubeOneCluster
name: my-cluster

versions:
  kubernetes: 1.36.2

cloudProvider:
  external: true
  gce:
    controlPlane:
      loadBalancer:
        # Project of the load balancer, the VMs must be in the same project.
        # Default: project_id of the service account
        projectID: my-project
        # Region of the load balancer, must contain the zones of all nodeSets.
        # Default: region of the zone of the first nodeSet
        region: europe-west3
        # Network of the control plane VMs, where the firewall rules are created.
        # Default: the network of the nodeSets
        # network: global/networks/default
        # Name of the load balancer resources. Default: "<CLUSTER_NAME>-kubeapi"
        name: my-cluster-kubeapi
        # IPv4 CIDRs allowed to reach kube-apiserver. Default: ["0.0.0.0/0"]
        allowedSourceRanges:
          - 0.0.0.0/0
  cloudConfig: |
    [global]
    regional = true
    multizone = true

controlPlane:
  # One nodeSet per zone spreads the control plane across the region
  nodeSets:
    - name: cp-a
      replicas: 1
      operatingSystem: ubuntu
      ssh:
        publicKeys:
          - ssh-ed25519 AAAA...
        username: ubuntu
      cloudProviderSpec:
        zone: europe-west3-a
        machineType: e2-standard-2
        diskSize: 50
        diskType: pd-ssd
        assignPublicIPAddress: true
        multizone: true
        # network: global/networks/my-vpc
        # subnetwork: regions/europe-west3/subnetworks/my-subnet
    - name: cp-b
      replicas: 1
      operatingSystem: ubuntu
      ssh:
        publicKeys:
          - ssh-ed25519 AAAA...
        username: ubuntu
      cloudProviderSpec:
        zone: europe-west3-b
        machineType: e2-standard-2
        diskSize: 50
        diskType: pd-ssd
        assignPublicIPAddress: true
        multizone: true
    - name: cp-c
      replicas: 1
      operatingSystem: ubuntu
      ssh:
        publicKeys:
          - ssh-ed25519 AAAA...
        username: ubuntu
      cloudProviderSpec:
        zone: europe-west3-c
        machineType: e2-standard-2
        diskSize: 50
        diskType: pd-ssd
        assignPublicIPAddress: true
        multizone: true
```

The `cloudProviderSpec` is the [machine-controller GCE provider
spec][mc-gce]. KubeOne rejects unknown fields in it.

* `zone` is required and must be in the load balancer region.
* Don't set `serviceAccount`. KubeOne takes it from the credentials. The VMs
  run as this service account unless `disableMachineServiceAccount: true` is
  set.
* All nodeSets must be in the same network.

KubeOne adds the network tag `<CLUSTER_NAME>-control-plane` and the labels
`kubeone_cluster_name` and `kubeone_role` to the control plane VMs. The
control plane nodes are named after their instances, for example
`my-cluster-cp-a-0`.

For `LoadBalancer` Services, the GCP cloud controller manager targets its
firewall rules at a network tag of each node that is a prefix of the instance
name. Give the workers such a tag, for example the MachineDeployment name.
Worker instances are named `<MACHINEDEPLOYMENT>-<HASH>-<SUFFIX>`.

### Load Balancer Options

| Field | Default | Description |
|-------|---------|-------------|
| `projectID` | `project_id` of the service account | Project of the load balancer resources. The VMs must be in the same project. Set `cloudProviderSpec.projectID` of the nodeSets if it's not the project of the service account |
| `region` | region of the zone of the first nodeSet | Region of the load balancer. Must contain the zones of all nodeSets |
| `network` | network of the nodeSets | Network of the control plane VMs, where the firewall rules are created. Taken from `cloudProviderSpec.network`, or from the network of `cloudProviderSpec.subnetwork`, otherwise `default`. If set, it must match that network |
| `name` | `<CLUSTER_NAME>-kubeapi` | Name of the load balancer resources, and prefix of the network endpoint groups and firewall rules |
| `allowedSourceRanges` | `["0.0.0.0/0"]` | IPv4 CIDRs allowed to reach kube-apiserver through the load balancer |

The load balancer keeps the client source IP, so `allowedSourceRanges` is the
only access control. The nodes reach kube-apiserver through the load balancer
from their public (or Cloud NAT) IP addresses. If you restrict
`allowedSourceRanges`, include these addresses, otherwise control plane nodes
can't join and workers can't register. KubeOne logs a warning if `0.0.0.0/0`
isn't included. The load balancer is external and IPv4 only.

If `apiEndpoint.host` is set, KubeOne doesn't create or look up the load
balancer and uses the given endpoint as it is. KubeOne still creates the
firewall rules.

## How the Load Balancer Works

During `kubeone apply`, KubeOne uses the Compute Engine API to:

1. Create the firewall rules in the network of the control plane VMs, targeting
   the `<CLUSTER_NAME>-control-plane` network tag:
   * `<name>-6443`: TCP 6443 from `allowedSourceRanges`
   * `<name>-6443-hc`: TCP 6443 from the health check ranges `35.191.0.0/16`,
     `209.85.152.0/22` and `209.85.204.0/22`

   For a Shared VPC network, KubeOne creates the firewall rules in the host
   project.
2. Create the [load balancer][gcp-nlb] resources, all named `<name>`:
   * A regional static external IP address, which becomes `apiEndpoint.host`
   * A regional TCP health check on port 6443
   * A regional backend service (`EXTERNAL`, TCP) with the health check
   * A regional forwarding rule (`EXTERNAL`, TCP 6443) with the address and the
     backend service
3. Create the control plane VMs and add each VM to the zonal network endpoint
   group (`GCE_VM_IP`) `<name>-<zone>`. KubeOne creates the group and adds it
   to the backend service with the first VM of its zone. KubeOne uses network
   endpoint groups instead of instance groups because a VM can only be in one
   load-balanced instance group, and the GCP cloud controller manager uses
   instance groups for `LoadBalancer` Services.

Every resource gets the description `kubeone:<CLUSTER_NAME>`. KubeOne never
adopts, changes or deletes a resource without this description. If a resource
with the same name but another description exists, `kubeone apply` fails. When
`allowedSourceRanges` changes, KubeOne updates the existing firewall rules.

### Load Balancer Membership

On every VM behind a passthrough load balancer, the GCE guest environment adds
a local route for the load balancer address. Traffic that a VM sends to the
load balancer address is therefore [always answered by the VM
itself][gcp-ilb-self], whether it's healthy or not. A control plane VM that
joins the cluster through the load balancer must not be behind it yet.
Otherwise it reaches itself, finds no kube-apiserver, and `kubeadm join`
hangs. So KubeOne:

1. Adds only the first VM of the first nodeSet, which initializes a new
   cluster, if no other member of the load balancer is healthy.
2. Before the other VMs join, adds the initializing VM and removes the VMs
   that are about to join. For example, these can be VMs of a cluster that was
   reset without destroying them, or a recreated VM.
3. Adds all control plane VMs after they joined, on every `kubeone apply`.

The kubelet and the other components of each control plane node reach
kube-apiserver through the load balancer address, which is always their own
kube-apiserver. If the kube-apiserver of a node stops, that node becomes
`NotReady` instead of failing over to another control plane node. Workers
aren't affected.

KubeOne doesn't clean up membership in these cases:

* Scaling down the control plane or renaming a nodeSet doesn't remove the old
  VMs from the load balancer. Remove their endpoints with
  `gcloud compute network-endpoint-groups update <name>-<zone> --remove-endpoint=instance=<vm>`.
* If a run fails after the other VMs joined but before they were added back to
  the load balancer, and the cluster isn't healthy, the next `kubeone apply`
  doesn't add them. The first `kubeone apply` on a healthy cluster adds them.
* The health check is TCP. A leftover kube-apiserver of a VM whose
  `kubeadm reset` failed still counts as healthy, so the first VM of a new
  cluster isn't added to the load balancer. Reset or delete that VM first.

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

This deletes the control plane VMs, and then the load balancer resources and
the firewall rules. Add `--force` if kube-apiserver isn't reachable, for
example after a failed `kubeone apply`. KubeOne skips VMs and load balancer
resources that don't exist.

* The machine-controller GCE driver deletes VMs by name only. Before deleting
  any VM, KubeOne checks that every existing VM with a control plane name has
  the labels set by KubeOne and machine-controller.
* KubeOne deletes only resources with the description `kubeone:<CLUSTER_NAME>`,
  and logs and keeps the others.
* If `apiEndpoint.host` is set to anything other than the load balancer
  address, including a DNS name that points to it, KubeOne keeps the load
  balancer and deletes only its firewall rules.
* `kubeone reset` without `--destroy-control-plane` keeps the VMs and their
  load balancer membership. The next `kubeone apply` removes the VMs that join
  again from the load balancer until they joined.
* If KubeOne can't find the network of the control plane during reset, for
  example because its subnetwork was already deleted, it looks for the
  firewall rules in the load balancer project. Delete them manually if they
  are in a Shared VPC host project.

Don't change the cluster name, the nodeSet names or the project between
`kubeone apply` and `kubeone reset`.

[shared-vpc]: https://cloud.google.com/vpc/docs/shared-vpc
[gcp-nlb]: https://cloud.google.com/load-balancing/docs/network/networklb-backend-service
[gcp-ilb-self]: https://cloud.google.com/load-balancing/docs/internal/setting-up-internal
[mc-gce]: https://github.com/kubermatic/machine-controller/blob/main/docs/cloud-provider.md#google-cloud-platform
