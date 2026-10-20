+++
title = "Configuration Guide"
date = 2026-04-23T00:00:00+00:00
weight = 6
+++

This document provides a deep-dive reference for the KubeV cluster configuration file. The configuration file drives `kubermatic-virtualization apply` and controls every aspect of your Kubermatic Virtualization Platform deployment.

## File Format

The configuration file is a YAML document conforming to the KubeV API schema:

```yaml
apiVersion: virtualization.k8c.io/v1alpha1
kind: KubeVCluster
```

Both fields are required and must match exactly. Use `kubermatic-virtualization config print` to generate a starter file, or `kubermatic-virtualization config print --full` for an annotated version with inline guidance.

The installer checks the whole file when it loads it, and stops before it changes anything if a field is invalid. Every field it rejects is listed in one run.

---

## Table of Contents

1. [Nodes: Control Plane & Workers](#nodes-control-plane--workers)
2. [Network Configuration](#network-configuration)
3. [API Endpoint](#api-endpoint)
4. [Load Balancer](#load-balancer)
5. [Storage](#storage)
6. [KubeVirt Configuration](#kubevirt-configuration)
7. [Kubelet Configuration](#kubelet-configuration)
8. [Image Pull Secret](#image-pull-secret)
9. [Offline / Air-Gapped Configuration](#offline--air-gapped-configuration)
10. [Identity Provider (IDP)](#identity-provider-idp)
11. [Dashboard](#dashboard)
12. [cert-manager](#cert-manager)
13. [VM Migration from vSphere](#vm-migration-from-vsphere)
14. [Platform Feature Gates](#platform-feature-gates)
15. [KDP Integration](#kdp-integration)
16. [Complete Example](#complete-example)

---

## Nodes: Control Plane & Workers

KubeV manages two categories of nodes. All nodes share the same `HostConfig` shape and are provisioned over SSH using `kubeadm`.

### Control Plane Nodes

Control plane nodes run the Kubernetes API server, scheduler, and controller manager. You must define at least one.

```yaml
controlPlane:
  hosts:
    - address: "192.168.1.10"
      sshUsername: "ubuntu"
      sshPrivateKeyFile: "/home/ops/.ssh/id_rsa"
    - address: "192.168.1.11"
      sshUsername: "ubuntu"
      sshPrivateKeyFile: "/home/ops/.ssh/id_rsa"
    - address: "192.168.1.12"
      sshUsername: "ubuntu"
      sshPrivateKeyFile: "/home/ops/.ssh/id_rsa"
```

**High-availability guidance:** Always run an odd number of control plane nodes (1, 3, or 5). etcd, which runs on every control plane node, uses Raft consensus and requires a quorum — meaning more than half of members must be reachable to elect a leader and accept writes. A 3-node control plane tolerates one node failure; a 5-node control plane tolerates two. Spread nodes across different physical hosts or failure domains.

A single control plane node is valid and practical for development, lab, or edge deployments where HA is not a requirement.

### Static Worker Nodes

Worker nodes run your virtual machine workloads via KubeVirt. The `staticWorkers` section is optional — a control plane node can also schedule workloads in single-node or resource-constrained environments.

```yaml
staticWorkers:
  hosts:
    - address: "192.168.1.20"
      sshUsername: "ubuntu"
      sshPrivateKeyFile: "/home/ops/.ssh/id_rsa"
    - address: "192.168.1.21"
      sshUsername: "ubuntu"
      sshPrivateKeyFile: "/home/ops/.ssh/id_rsa"
```

### HostConfig Fields

Every node entry (control plane and worker alike) supports the following fields:

| Field | Required | Default | Description |
|---|---|---|---|
| `address` | Yes | — | Internal RFC-1918 IP address of the node. Must be reachable from the machine running `kubermatic-virtualization apply`. |
| `sshUsername` | No | `root` | SSH login username. |
| `sshPrivateKeyFile` | No | `""` | Path to a plaintext (unencrypted) private key file. |
| `labels` | No | `{}` | Kubernetes node labels to apply or remove. |
| `annotations` | No | `{}` | Kubernetes node annotations to apply or remove. |
| `tunnelInterface` | No | — | Per-node override for the Kube-OVN overlay NIC. See [Tunnel Interface](#tunnel-interface). |
| `kubelet` | No | — | Per-node kubelet settings that override the cluster-wide `kubeletConfig`. See [Kubelet Configuration](#kubelet-configuration). |

**SSH key requirements:**
- The key file must exist on the machine running `kubermatic-virtualization apply` and be readable by the invoking user.
- The corresponding public key must be present in `~/.ssh/authorized_keys` on each target node.
- Recommended permissions: `chmod 600 /path/to/key`.
- Passphrase-protected keys are not supported. Use `ssh-keygen -p` to strip a passphrase or generate a dedicated deployment key.

**Applying labels and annotations:**

Labels and annotations follow `kubectl label` / `kubectl annotate` semantics. To remove a key that was previously applied, suffix it with `-`:

```yaml
labels:
  node-role: worker
  topology.kubernetes.io/zone: us-east-1a
  stale-label-: ""        # the trailing dash removes "stale-label" from the node
```

---

## Network Configuration

```yaml
networkConfiguration:
  dnsServerIP: "192.168.1.1"
  networkCIDR: "10.244.0.0/16"
  serviceCIDR: "10.96.0.0/12"
  gatewayIP: "10.244.0.1"
  tunnelInterface: "eth0"
```

### About Kube-OVN

KubeV uses [Kube-OVN](https://kube-ovn.io/) as its CNI network plugin. Kube-OVN is a Kubernetes networking solution built on top of [Open Virtual Network (OVN)](https://www.ovn.org/), which is the control plane layer of [Open vSwitch (OVS)](https://www.openvswitch.org/).

All CIDR ranges are validated at load time and must not overlap with one another or with your physical network.

### Fields

| Field | Required | Default | Description |
|---|---|---|---|
| `dnsServerIP` | No | — | DNS resolvers used cluster-wide: one IP address, or several separated by commas or spaces, such as `"10.0.0.1,10.0.0.2"`. Write it as one quoted string, not as a YAML list. CoreDNS spreads queries across them. In offline deployments these are the only DNS servers the nodes and pods will use. |
| `networkCIDR` | No | `10.244.0.0/16` | Pod network CIDR. All pod and VM IPs are allocated from this range by Kube-OVN's IPAM. |
| `serviceCIDR` | No | `10.96.0.0/12` | Service network CIDR. Virtual IPs for `ClusterIP` services are drawn from here. Must not overlap with `networkCIDR`. |
| `gatewayIP` | No | — | Default gateway for pod traffic leaving the cluster. Must be a valid IP within `networkCIDR`. |
| `tunnelInterface` | No | — | Physical NIC used for Kube-OVN inter-node overlay traffic. See below. |

> **Fixed after installation:** `dnsServerIP` and `serviceCIDR` can't be changed once the cluster is installed. On an installed cluster, `apply` stops before it changes anything if `serviceCIDR` differs from the range the cluster runs with. Clusters installed before v1.3 run `10.96.0.0/12`, whatever their file said, because older installers ignored the field: set `10.96.0.0/12` there, or leave the field out.

### Tunnel Interface

The `tunnelInterface` field tells Kube-OVN which host NIC to use as the underlay for its overlay tunnels. Each node establishes Geneve tunnels to every other node using the IP of this interface. Choosing the wrong interface (e.g., a management NIC with limited throughput) will hurt east-west VM-to-VM performance.

**If left unset**, Kube-OVN selects the interface that holds the node's default route. This works well on simple single-NIC servers but can produce incorrect results on servers with multiple NICs or bonded interfaces.

Three formats are accepted:

```yaml
# Single interface name — all nodes must have an interface with exactly this name
tunnelInterface: "eth0"

# Comma-separated list — Kube-OVN picks the first name that exists on each node
tunnelInterface: "eth0,ens3,enp3s0"

# Regular expression — Kube-OVN uses the first interface whose name matches
tunnelInterface: "^eth[0-9]+$"
```

**Per-node override:** In mixed hardware environments where different servers use different NIC names, set a safe regex globally and override specific nodes that need a different interface:

```yaml
networkConfiguration:
  tunnelInterface: "^ens[0-9]+$"     # matches ens3, ens4, etc. on most nodes

controlPlane:
  hosts:
    - address: "192.168.1.10"
      tunnelInterface: "bond0"        # this node uses a bonded interface

staticWorkers:
  hosts:
    - address: "192.168.1.20"
      tunnelInterface: "enp6s0f0"     # explicit NIC on this node
```

**Validation rules:**
- A per-node `tunnelInterface` must be a single valid Linux interface name: max 15 characters, alphanumeric plus `_`, `.`, `-`.
- The global `tunnelInterface` may be a single name, comma-separated list, or a regex pattern. If the value contains any regex metacharacter (`^`, `$`, `*`, `.`, `+`, `?`, `(`, `)`, `[`, `]`, `{`, `}`, `|`, `\`), it is treated as a regex and is not name-validated.
- `networkCIDR` and `serviceCIDR` must not overlap.
- `gatewayIP` must be within `networkCIDR`.
- Every server in `dnsServerIP` must be a valid IP address.

---

## API Endpoint

```yaml
apiEndpoint:
  host: "api.example.com"
  alternativeNames:
    - "192.168.1.10"
    - "api-internal.example.com"
```

| Field | Required | Description |
|---|---|---|
| `host` | Yes | Hostname or IP where the Kubernetes API server is reachable. This becomes the `server` value in generated kubeconfig files. |
| `alternativeNames` | No | Additional Subject Alternative Names added to the API server TLS certificate. Add every hostname or IP that clients may use to reach the API. |

---

## Load Balancer

Exactly one option must be set. If the section is omitted entirely, `none` is applied as the default.

### MetalLB

[MetalLB](https://metallb.universe.tf/) allocates external IPs for `LoadBalancer`-type services on bare-metal clusters. It operates in L2 mode using ARP/NDP announcements — no BGP router is required.

```yaml
loadBalancer:
  metallb:
    ipRange: "192.168.1.100-192.168.1.150"
```

`ipRange` accepts two formats:

```yaml
# CIDR block — all usable addresses in the block are available
ipRange: "192.168.10.0/24"

# Inclusive range — addresses from start to end (inclusive)
ipRange: "192.168.10.50-192.168.10.100"
```

**Planning notes:**
- The IP range must be routable on your LAN. Hosts outside the cluster must be able to send traffic to these IPs and have it arrive at the node that is currently announcing the address.
- IPs must not overlap with DHCP pools or existing static assignments.
- In L2 mode, one node at a time holds each address. If that node fails, MetalLB re-announces from a healthy node within a few seconds.

### None

```yaml
loadBalancer:
  none: {}
```

Disables external load balancing. `LoadBalancer`-type services will remain in `<pending>` state. Use this when your environment provides its own load balancer, or when only `ClusterIP` / `NodePort` services are needed.

---

## Storage

Set `none`, or `longhorn`, `ceph` or both. If the section is omitted, `none` is applied as the default. With both, Ceph's `ceph-block` StorageClass is the cluster default, so VM disks that do not name a StorageClass go to Ceph.

### Longhorn

[Longhorn](https://longhorn.io/) provides distributed block storage, replicated across the nodes. KubeV installs it with the `longhorn` StorageClass, set up for VM disks that live-migrate.

```yaml
storage:
  longhorn: {}
```

No additional fields are required. Longhorn keeps its data in `/var/lib/longhorn` on each node, and the number of copies of each volume can be changed in Longhorn's own settings after deployment. Without Ceph, `longhorn` is the cluster's default StorageClass.

### Ceph

[Ceph](https://ceph.io/), run by [Rook](https://rook.io/), provides distributed block storage on empty disks of the nodes. KubeV installs it with the `ceph-block` StorageClass, which is the cluster default, and a `VolumeSnapshotClass` for VM backups and snapshots.

```yaml
storage:
  ceph:
    deviceFilter: "^nvme[1-9]n1$"
    replicas: 3
```

| Field | Required | Default | Description |
|---|---|---|---|
| `deviceFilter` | Yes | — | A regular expression matched against the names of each node's disks and partitions, as `lsblk` shows them, such as `^nvme[1-9]n1$` or `^(nvme1n1p3\|sda2)$`. Each node matches it against its own devices. Ceph takes every matching disk that has no partitions and no file system, and every matching partition that has no file system, and formats it. With Longhorn installed too, it must not match `sd` names: Longhorn's volumes appear as `sd` disks on the node they are attached to, and the installer warns about such a filter. |
| `replicas` | No | `3` | How many copies of the data Ceph keeps, each on a different node with a matching disk: 1 to 3, and at most the number of nodes. A cluster of fewer than 3 nodes must set it. Fewer than 3 copies suit test clusters only: a failed node can then take data with it. |

Ceph runs on every node, the control plane included, and uses the nodes' own network rather than the Kube-OVN overlay. `apply` refuses to remove `ceph` from a cluster that runs it, and to remove `longhorn` while volumes are still on Longhorn. The [Ceph Storage]({{< ref "../tutorials-howtos/ceph-storage" >}}) guide covers the disks and nodes Ceph needs, running it next to Longhorn, and its day-2 operations.

### None

```yaml
storage:
  none: {}
```

Disables managed storage. You must supply your own `StorageClass` or provision `PersistentVolume` objects manually.

---

## KubeVirt Configuration

KubeV deploys [KubeVirt](https://kubevirt.io/) to enable running virtual machines as Kubernetes workloads. KubeVirt extends Kubernetes with custom resources — `VirtualMachine`, `VirtualMachineInstance`, `DataVolume`, and others — and runs VM processes directly on the Kubernetes nodes using the host's KVM/QEMU stack.

Alongside KubeVirt, KubeV also deploys the [Containerized Data Importer (CDI)](https://github.com/kubevirt/containerized-data-importer), which handles importing VM disk images from HTTP sources, container registries, or object storage into `PersistentVolumeClaims` that VMs can boot from.

The `kubevirt` section in the configuration file is optional. When omitted, KubeVirt and CDI are deployed with their built-in defaults and no feature gates enabled.

```yaml
kubevirt:
  developerConfiguration:
    featureGates:
      - "LiveMigration"
      - "Snapshot"
    useEmulation: false
  migrations:
    parallelMigrationsPerCluster: 5
    allowAutoConverge: true
  commonInstancetypesDeployment:
    enabled: true
  permittedHostDevices:
    pciHostDevices:
      - pciVendorSelector: "10DE:233B"
        resourceName: "nvidia.com/gpu"
  enforceRegionalScheduling: false
```

Every `apply` writes this section to the KubeVirt CR, so a change takes effect on the next run.

| Field | Required | Default | Description |
|---|---|---|---|
| `developerConfiguration` | No | — | Feature gates and software emulation. See [Developer Configuration](#developer-configuration). |
| `migrations` | No | — | Tuning for live migration between nodes. See [Live Migration](#live-migration). |
| `commonInstancetypesDeployment.enabled` | No | `true` | Deploys KubeVirt's bundle of common instance types and preferences, the sizes and OS presets VMs can be created from. |
| `permittedHostDevices` | No | — | PCI devices, such as GPUs, that VMs may use. See [PCI Passthrough](#pci-passthrough). |
| `enforceRegionalScheduling` | No | `false` | Deploys a Kyverno policy that keeps VMs in their subnet's region. See [Regional Scheduling](#regional-scheduling). |

### Developer Configuration

| Field | Required | Default | Description |
|---|---|---|---|
| `featureGates` | No | `[]` | List of KubeVirt feature gates to enable. See below. |
| `useEmulation` | No | `false` | Fall back to software emulation when KVM is unavailable. |

#### Feature Gates

Feature gates enable functionality in KubeVirt that is either experimental, requires extra cluster resources, or is disabled by default for safety. Gate names must start and end with an alphanumeric character and may contain alphanumerics, dots, or hyphens.

| Gate | What it enables |
|---|---|
| `LiveMigration` | Live-migrate running VMs from one node to another without downtime. Requires shared or replicated storage so the VM disk is accessible from the destination node. |
| `Snapshot` | Create point-in-time snapshots of a `VirtualMachine` and its associated disk volumes. Snapshots can be used to restore the VM to a previous state or clone it. Requires a CSI driver that supports volume snapshots (e.g., Longhorn or Ceph). |
| `HotplugVolumes` | Attach and detach `DataVolume` or `PersistentVolumeClaim` objects to a running VM without stopping it. Useful for dynamically expanding storage or swapping data disks. |
| `VMExport` | Export a VM's disk image to an external destination such as an OCI registry or HTTP endpoint. Useful for backups or migrating VMs out of the cluster. |
| `ExpandDisks` | Resize a VM's root or data disk while the VM is running by expanding the underlying `PersistentVolumeClaim`. The guest OS must also support online resize (e.g., via `virtio-scsi`). |

Example enabling live migration and snapshots:

```yaml
kubevirt:
  developerConfiguration:
    featureGates:
      - "LiveMigration"
      - "Snapshot"
```

#### Software Emulation

```yaml
kubevirt:
  developerConfiguration:
    useEmulation: true
```

When `useEmulation: true`, KubeVirt falls back to QEMU's software TCG emulation if the node does not expose `/dev/kvm`. This is useful in:

- **Nested virtualization environments** (e.g., VMs running inside a cloud provider) where KVM may not be available or requires explicit opt-in.
- **CI/CD pipelines** that run tests against VM workloads on ephemeral runners without KVM.
- **Development laptops** running the cluster inside a VM.

**Do not use `useEmulation: true` in production.** Software emulation is typically 10–50× slower than KVM-accelerated execution. CPU-intensive or I/O-intensive workloads inside VMs will be severely degraded.

Only turn it on for nodes without hardware virtualization. While it is on, every new VM pod starts without `/dev/kvm`, so VMs that already run with KVM can no longer live-migrate, and node drains during an upgrade stall on them.

### Live Migration

`kubevirt.migrations` tunes live migration of VMs between nodes, cluster-wide. Node drains during upgrades use it too. Not to be confused with [VM Migration from vSphere](#vm-migration-from-vsphere).

| Field | Default | Description |
|---|---|---|
| `parallelMigrationsPerCluster` | `5` | Live migrations that may run at the same time in the cluster. Must be greater than 0. |
| `parallelOutboundMigrationsPerNode` | `2` | Live migrations that may leave one node at the same time. Must be greater than 0. |
| `completionTimeoutPerGiB` | `150` | Seconds per GiB of VM memory a migration may take before it is cancelled. Must be greater than 0. |
| `progressTimeout` | `150` | Seconds a migration may make no progress before it is cancelled. Must be greater than 0. |
| `allowAutoConverge` | `true` | Slows down a migrating VM's vCPUs when its memory changes faster than it can be copied, so the migration of a busy VM finishes instead of timing out. Without it, a node drain can wait on such a VM indefinitely. When unset, a value set directly on the KubeVirt CR is kept. |

### PCI Passthrough

`kubevirt.permittedHostDevices.pciHostDevices` lists the PCI devices VMs may get, such as GPUs.

| Field | Required | Description |
|---|---|---|
| `pciVendorSelector` | Yes | Vendor and device ID, as `VENDOR:DEVICE` in hex, such as `10DE:233B`. `lspci -nn` on the node prints it. Each selector may appear once. |
| `resourceName` | Yes | Resource name the device is requested by, such as `nvidia.com/gpu`. |
| `externalResourceProvider` | No | Set `true` when a device plugin of your own, such as NVIDIA's, advertises and allocates the device instead of KubeVirt. |

### Regional Scheduling

With `enforceRegionalScheduling: true`, the installer deploys the Kyverno policy `enforce-vm-regional-scheduling`. When a VM is created with the annotation `ovn.kubernetes.io/logical_switch` on its template, the policy reads the `topology.kubernetes.io/region` label of that Kube-OVN subnet and adds it to the VM's node selector, so the VM runs only on nodes of that region. VMs without the annotation, or on a subnet without the label, are scheduled freely.

---

## Kubelet Configuration

`kubeletConfig` sets kubelet options on every node. A node's `kubelet` field (see [HostConfig Fields](#hostconfig-fields)) overrides them for that node.

```yaml
kubeletConfig:
  systemReserved:
    cpu: "500m"
    memory: "1Gi"
  kubeReserved:
    cpu: "500m"
    memory: "1Gi"
  evictionHard:
    memory.available: "500Mi"
  maxPods: 110

staticWorkers:
  hosts:
    - address: "192.168.1.20"
      kubelet:
        maxPods: 250
```

| Field | Default | Description |
|---|---|---|
| `systemReserved` | — | Resources kept for the operating system, the kubelet's `--system-reserved`. |
| `kubeReserved` | — | Resources kept for Kubernetes components, the kubelet's `--kube-reserved`. |
| `evictionHard` | — | Thresholds at which the kubelet evicts pods, the kubelet's `--eviction-hard`. |
| `maxPods` | `110` | Maximum number of pods per node. Each running VM is one pod. |
| `imageGCHighThresholdPercent` | `85` | Disk usage, in percent, above which unused images are always removed. Must be greater than `imageGCLowThresholdPercent`. |
| `imageGCLowThresholdPercent` | `80` | Disk usage, in percent, below which images are never removed. |
| `imageMinimumGCAge` | `2m` | How long an unused image is kept at least. |
| `imageMaximumGCAge` | `0s` | How long an unused image is kept at most. `0s` keeps it until disk usage removes it. |

See [Reserve Compute Resources for System Daemons](https://kubernetes.io/docs/tasks/administer-cluster/reserve-compute-resources/) for how the reservations add up.

---

## Image Pull Secret

KubeV's own images (the controller-manager, the API server and the dashboard) are in a private registry. The installer needs credentials for it, given in one of two ways:

**Option 1 — `imagePullSecret` in the config file (preferred for automation):**

```yaml
imagePullSecret: |
  {"auths":{"quay.io":{"auth":"<base64 of username:password>"}}}
```

Generate the base64-encoded auth value:

```bash
echo -n "myuser:mypassword" | base64
```

**Option 2 — Environment variables before running `kubermatic-virtualization apply`:**

```bash
export KUBEV_USERNAME=myuser
export KUBEV_PASSWORD=mypassword
kubermatic-virtualization apply -f cluster.yaml
```

`imagePullSecret` is a top-level field and applies to every platform component. If it is set, the environment variables are ignored for these images. If neither is provided, `kubermatic-virtualization apply` fails the pre-flight check before any cluster changes are made. Air-gapped installations with `offlineSettings.enabled: true` are exempt: their images come from the internal registry.

`dashboard.imagePullSecret` overrides it for the API server and the dashboard only. Before v1.2, the credentials lived there; when upgrading such a configuration, move the value to the top level.

---

## Offline / Air-Gapped Configuration

```yaml
offlineSettings:
  enabled: true
  containerRegistry:
    address: "https://registry.internal.example.com:5000"
    username: "registry-user"
    password: "registry-password"
    insecure: false
  helmRegistry:
    address: "https://charts.internal.example.com:5000"
    username: "helm-user"
    password: "helm-password"
    insecure: false
  packageRepository: "https://packages.internal.example.com"
  packageRepositoryKeyFingerprint: "A1B2C3D4E5F60718293A4B5C6D7E8F9012345678"
```

When `enabled: true`, KubeV will not reach out to the public internet during installation or upgrades. Every container image, Helm chart, and OS package must be pre-loaded into the internal mirrors you configure here.

### Fields

| Field | Required when enabled | Description |
|---|---|---|
| `enabled` | — | Set `true` to activate air-gapped mode. |
| `containerRegistry.address` | Yes | URL of the internal OCI-compatible registry hosting all container images (e.g., `https://registry.internal.local:5000`). Must include the protocol. |
| `containerRegistry.username` | No | Basic-auth username for the container registry. |
| `containerRegistry.password` | No | Basic-auth password for the container registry. |
| `containerRegistry.insecure` | No | Disable TLS verification. Use only for internal, trusted registries. Not recommended for production. |
| `helmRegistry.address` | Yes | URL of the internal OCI registry or HTTP server hosting Helm charts. |
| `helmRegistry.username` | No | Basic-auth username for the Helm registry. |
| `helmRegistry.password` | No | Basic-auth password for the Helm registry. |
| `helmRegistry.insecure` | No | Disable TLS verification for the Helm registry. |
| `packageRepository` | No | URL of an internal OS package repository (RPMs, DEBs, or binaries) used during node provisioning and upgrades. |
| `packageRepositoryKeyFingerprint` | No | Fingerprint of the key that signs `packageRepository`, as `gpg --show-keys` prints it for the repository's `key.asc`. Ubuntu nodes then accept only this key, at installation and before every upgrade. |

### Preparing an Air-Gapped Environment

The release's offline bundle provides all of the following on one jump host — see [Offline Installation]({{< ref "../installation/offline-installation" >}}). To use your own registry and repository instead, the following must be in place before running `kubermatic-virtualization apply` in offline mode:

1. **Mirror container images** — use `kubermatic-virtualization mirror-images` to copy all required images to your internal registry. This includes KubeV's own images and those of Kube-OVN, cert-manager, KubeVirt, CDI, Forklift, Longhorn, Rook, Ceph, MetalLB, Kyverno, Multus, and others.
2. **Prepare the package repository** — sync the OS package repository used by your node OS so that kubeadm, kubelet, and kubectl packages are available.
3. **Test connectivity** — verify that all nodes can reach every internal mirror URL before applying.

In offline mode, KubeV's own images come from `containerRegistry` too, so the [Image Pull Secret](#image-pull-secret) is not required.

---

## Identity Provider (IDP)

Exactly one option must be set. If the section is omitted, `none` is applied as the default.

> **Important:** The `idp` section only controls whether KubeV **deploys** an identity provider alongside the cluster. It does **not** configure the dashboard's authentication. Deploying Dex here and enabling OIDC on the dashboard are two separate steps — both are needed to achieve SSO login. See [Using OIDC with in-cluster Dex](#using-oidc-with-the-in-cluster-dex) for the end-to-end wiring.

### When Should You Deploy an IDP?

If you already have an OIDC-compatible identity provider — Keycloak, Okta, Azure AD, Auth0, or any other — set `idp: none: {}` and point `dashboard.auth.oidc.issuerURL` directly at it. No in-cluster IDP is needed.

If you **do not** have an existing OIDC provider and want to get dashboard SSO running quickly without standing up external infrastructure, KubeV can deploy [Dex](https://dexidp.io/) as a lightweight, in-cluster OIDC provider. Dex acts as a federation hub: it speaks OIDC to the dashboard while connecting upstream to your actual user database — whether that is LDAP, GitHub, Google, or a local static password list.

### Dex

[Dex](https://dexidp.io/) is a federated OpenID Connect provider. It does not store users itself; instead, it delegates authentication to upstream connectors (LDAP, GitHub, OIDC providers, SAML, etc.) and issues standard OIDC tokens that downstream applications — like the KubeV dashboard — can verify.

```yaml
idp:
  dex:
    issuer: "https://dex.example.com"
    enablePasswordDB: false
    connectors:
      - type: oidc
        id: google
        name: Google
        config:
          issuer: https://accounts.google.com
          clientID: "your-google-client-id"
          clientSecret: "your-google-client-secret"
          redirectURI: "https://dex.example.com/callback"
    staticClients:
      - id: kubev-dashboard
        name: KubeV Dashboard
        secret: "a-strong-client-secret"
        redirectURIs:
          - "https://dashboard.example.com/auth/callback"
```

#### Dex Fields

| Field | Required | Description |
|---|---|---|
| `issuer` | Yes | Base URL at which Dex will be publicly reachable (e.g., `https://dex.example.com`). This URL is embedded in every token Dex issues. It must exactly match the `issuerURL` value in the dashboard's OIDC config and must be accessible by both browsers and the dashboard API server. |
| `enablePasswordDB` | No | Enable Dex's built-in local password database. Passwords are stored in Kubernetes Secrets in the `dex` namespace. Convenient for testing, small teams, or environments with no upstream connector. Disable in production when using a real upstream identity provider. |
| `connectors` | No | List of upstream identity provider connectors. At least one of `connectors` or `enablePasswordDB: true` must be set. |
| `staticClients` | No | Pre-registered OAuth2 clients that are allowed to obtain tokens from Dex. |

#### Connectors

Connectors tell Dex where to authenticate users. Dex supports a wide range of upstream providers through its connector framework. All connector-specific fields go inside the `config` key, whose schema varies by connector type.

---

**OIDC Connector**

Use this to federate to any upstream OIDC provider: Google, Azure AD (via its OIDC endpoint), Okta, Auth0, another Dex instance, etc.

```yaml
connectors:
  - type: oidc
    id: google
    name: Google
    config:
      issuer: https://accounts.google.com
      clientID: "your-google-client-id"
      clientSecret: "your-google-client-secret"
      redirectURI: "https://dex.example.com/callback"
      # Optional: request additional scopes from the upstream provider
      scopes:
        - openid
        - email
        - profile
      # Optional: claim to use as the user's email address
      userNameKey: email
      # Optional: do not verify the upstream provider's TLS certificate
      insecureSkipEmailVerified: false
```

| Config field | Required | Description |
|---|---|---|
| `issuer` | Yes | OIDC discovery URL of the upstream provider |
| `clientID` | Yes | OAuth2 client ID registered with the upstream provider |
| `clientSecret` | Yes | OAuth2 client secret |
| `redirectURI` | Yes | Must be `<dex-issuer>/callback`. Must be registered as an allowed redirect URI on the upstream provider. |
| `scopes` | No | Scopes to request from the upstream provider. Defaults to `openid`, `email`, `profile`. |

---

**LDAP Connector**

Use this to authenticate against a corporate directory (Active Directory, OpenLDAP, FreeIPA, etc.).

```yaml
connectors:
  - type: ldap
    id: ldap
    name: Corporate Directory
    config:
      host: "ldap.corp.example.com:389"
      # Use ldaps:// port 636 for TLS, or set startTLS: true for STARTTLS on port 389
      startTLS: true
      # Service account for binding to the directory
      bindDN: "cn=kubev-svc,ou=serviceaccounts,dc=corp,dc=example,dc=com"
      bindPW: "service-account-password"
      # Optional: skip TLS verification (only for internal/trusted directories)
      insecureSkipVerify: false

      # How to search for users
      userSearch:
        baseDN: "ou=people,dc=corp,dc=example,dc=com"
        filter: "(objectClass=person)"
        username: uid          # LDAP attribute mapped to the login field
        idAttr: uid            # Attribute used as the unique user identifier
        emailAttr: mail        # Attribute mapped to the user's email
        nameAttr: displayName  # Attribute mapped to the user's display name

      # How to search for groups (optional — needed for group-based access control)
      groupSearch:
        baseDN: "ou=groups,dc=corp,dc=example,dc=com"
        filter: "(objectClass=groupOfNames)"
        userAttr: DN           # User attribute to match against group membership
        groupAttr: member      # Group attribute holding member DNs
        nameAttr: cn           # Group attribute used as the group name in tokens
```

| Config field | Required | Description |
|---|---|---|
| `host` | Yes | LDAP server hostname and port |
| `bindDN` | Yes | Distinguished name of the service account used to search the directory |
| `bindPW` | Yes | Password for the service account |
| `userSearch.baseDN` | Yes | Base DN to search for user entries |
| `userSearch.username` | Yes | LDAP attribute that users type in the login field (e.g., `uid`, `sAMAccountName`) |
| `groupSearch` | No | When configured, Dex includes group membership in the `groups` claim of issued tokens |

---

**GitHub Connector**

Authenticate users via their GitHub account. You need to create an OAuth App in your GitHub organization settings.

```yaml
connectors:
  - type: github
    id: github
    name: GitHub
    config:
      clientID: "your-github-oauth-app-client-id"
      clientSecret: "your-github-oauth-app-client-secret"
      redirectURI: "https://dex.example.com/callback"
      # Optional: restrict login to members of specific organizations
      orgs:
        - name: my-github-org
          # Optional: restrict to members of specific teams within the org
          teams:
            - platform-team
            - sre-team
      # Optional: use GitHub Enterprise instead of github.com
      # hostName: "github.corp.example.com"
```

| Config field | Required | Description |
|---|---|---|
| `clientID` | Yes | GitHub OAuth App client ID |
| `clientSecret` | Yes | GitHub OAuth App client secret |
| `redirectURI` | Yes | Must be `<dex-issuer>/callback`. Must be registered in the OAuth App settings. |
| `orgs` | No | When set, only members of the listed organizations can authenticate. Without this, any GitHub user can log in. |

---

**Microsoft / Azure AD Connector**

Authenticate users via Microsoft Entra ID (formerly Azure Active Directory) or a personal Microsoft account.

```yaml
connectors:
  - type: microsoft
    id: microsoft
    name: Microsoft
    config:
      clientID: "your-azure-app-client-id"
      clientSecret: "your-azure-app-client-secret"
      redirectURI: "https://dex.example.com/callback"
      # Optional: restrict to a specific Azure AD tenant
      tenant: "your-tenant-id-or-domain"
      # Optional: include group membership in tokens (requires Group.Read.All permission)
      groups:
        - "platform-team"
```

---

**Local Password Database**

When no upstream connector is available, or for quick bootstrapping, enable Dex's built-in password store:

```yaml
idp:
  dex:
    issuer: "https://dex.example.com"
    enablePasswordDB: true
```

With `enablePasswordDB: true`, Dex creates a `Password` custom resource in the `dex` namespace for each user. You can add users via the Dex API or directly via `kubectl`. This is suitable for development and small internal deployments. For any environment where more than a handful of people need access, use an upstream connector instead.

#### Static Clients

Static clients are OAuth2 applications pre-registered with Dex. Every application that wants to obtain tokens from Dex must be listed here.

```yaml
staticClients:
  # Confidential client — requires a client secret (e.g., a web app with a backend)
  - id: kubev-dashboard
    name: KubeV Dashboard
    secret: "a-strong-random-secret"
    redirectURIs:
      - "https://dashboard.example.com/auth/callback"

  # Public client — no secret, suitable for CLI tools and native apps using PKCE
  - id: kubev-cli
    name: KubeV CLI
    public: true
    redirectURIs:
      - "http://localhost:8000/callback"
      - "urn:ietf:wg:oauth:2.0:oob"   # out-of-band flow for headless environments
```

| Field | Required | Description |
|---|---|---|
| `id` | Yes | OAuth2 client ID. Must be unique across all static clients. |
| `name` | Yes | Human-readable display name shown in Dex's consent screen. |
| `secret` | Conditional | Client secret. Required unless `public: true`. Use a strong random value (e.g., `openssl rand -base64 32`). |
| `redirectURIs` | No | Allowed redirect URIs. Dex will reject any authorization request whose `redirect_uri` is not in this list. |
| `public` | No | Marks this as a public client. Public clients do not authenticate with a secret; they rely on PKCE for security. Use for CLI tools or native apps. |

**Connector ID uniqueness:** Each connector `id` must be unique within the connectors list. Duplicate IDs cause a validation error.

### None

```yaml
idp:
  none: {}
```

No identity provider is deployed. Use this when you already have an external OIDC provider or when the dashboard is not enabled.

---

## Dashboard

```yaml
dashboard:
  enabled: true
  dashboardURL: "https://dashboard.example.com"
  auth:
    oidc:
      issuerURL: "https://dex.example.com"
      clientID: "kubev-dashboard"
      clientSecret: "a-strong-client-secret"
      redirectURL: "https://dashboard.example.com/auth/callback"
```

| Field | Required | Default | Description |
|---|---|---|---|
| `enabled` | No | `false` | Deploy the KubeV API server and web dashboard. |
| `dashboardURL` | No | — | Public URL where the dashboard is reachable, such as `https://dashboard.example.com`. Used as the redirect target after a successful OIDC login. Without it, the browser is sent to the dashboard's in-cluster address, which only works inside the cluster. Required in [KDP mode](#kdp-integration). |
| `auth` | No | `none` | Authentication mode. Exactly one of `none`, `basic`, or `oidc` must be set. Defaults to `none` when omitted. See [Authentication Modes](#authentication-modes). |
| `imagePullSecret` | No | top-level `imagePullSecret` | Overrides the [Image Pull Secret](#image-pull-secret) for the API server and the dashboard only. |
| `service` | No | `ClusterIP` on port `8080` | The Service in front of the dashboard. See [Service and Scheduling](#service-and-scheduling). |
| `replicaCount`, `resources`, `nodeSelector`, `tolerations`, `affinity`, `podAnnotations`, `podSecurityContext`, `securityContext`, `helmValues` | No | chart defaults | How the dashboard pods run. See [Service and Scheduling](#service-and-scheduling). |

### Service and Scheduling

By default the dashboard runs one pod behind a `ClusterIP` Service on port `8080`, and you publish it yourself, for example with an Ingress. These fields change the dashboard's Helm chart values; unset fields keep the chart defaults.

```yaml
dashboard:
  enabled: true
  service:
    type: LoadBalancer
    port: 8080
  replicaCount: 2
  resources:
    requests: {cpu: 100m, memory: 128Mi}
    limits: {cpu: 500m, memory: 256Mi}
  nodeSelector:
    node-role.kubernetes.io/control-plane: ""
  tolerations:
    - key: node-role.kubernetes.io/control-plane
      operator: Exists
      effect: NoSchedule
```

| Field | Description |
|---|---|
| `service.type` | `ClusterIP` (default), `NodePort` or `LoadBalancer`. A `LoadBalancer` Service gets an external IP from MetalLB, or from whatever else provides `LoadBalancer` Services in the cluster. |
| `service.port` | Port the Service listens on, between 1 and 65535. Default `8080`. |
| `service.allowUnauthenticated` | Must be `true` to use a `NodePort` or `LoadBalancer` Service with `auth: none`. Without authentication, anyone who can reach the Service gets admin rights in KubeV without logging in. |
| `replicaCount` | Number of dashboard pods, at least 1. Default 1. |
| `resources` | Requests and limits of the dashboard container. Requests may not exceed limits. Resource claims are not supported. |
| `nodeSelector`, `tolerations`, `affinity` | Where the dashboard pods may run, as for any pod. |
| `podAnnotations` | Annotations added to the dashboard pods. `checksum/api-server-location` is reserved by the chart. |
| `podSecurityContext`, `securityContext` | Merged over the chart's defaults: `fsGroup: 30000` for the pod, and for the container user 10000, group 30000, a read-only root filesystem and no privilege escalation. |
| `helmValues` | Any other value of the dashboard chart, merged over its defaults. It may not set a value that has a field above, or one the installer manages: `apiServerURL`, `image.tag`, `imagePullSecret`, `existingImagePullSecret`, `nameOverride` and `fullnameOverride`. `image.repository` and `image.pullPolicy` may be set, for example to pull the dashboard from a registry of your own. |

The installer warns when these fields are set but `dashboard.enabled` is `false`, and when a `NodePort` or `LoadBalancer` Service has no `dashboardURL`.

---

### Authentication Modes

The dashboard supports three mutually exclusive authentication modes. Exactly one must be set; if `dashboard.enabled` is true and `auth` is omitted, `none` is applied as the default.

#### None Mode

```yaml
dashboard:
  enabled: true
  auth:
    none: {}
```

The dashboard is publicly accessible without any login. Anyone who can reach `dashboardURL` has full access.

**Use when:** The cluster network is private and access-controlled at the infrastructure layer, or during initial setup before authentication is configured.

---

#### Basic Mode

Username/password authentication backed by a Kubernetes `Secret`. The simplest mode to get started — no OIDC provider required.

The minimal configuration is:

```yaml
dashboard:
  enabled: true
  auth:
    basic: {}
```

That is all that is required. The installer generates a random credential pair, stores it in the default Secret, and prints the path to a credentials file in the post-apply output. Retrieve the credentials with:

```bash
cat <path printed by kubermatic-virtualization apply>
```

**Advanced options** — all fields are optional and have sensible defaults:

```yaml
dashboard:
  enabled: true
  auth:
    basic:
      secretName: "kubev-basic-auth"           # default: kubev-basic-auth
      secretNamespace: "kubermatic-virtualization"  # default: kubermatic-virtualization
      sessionDuration: "24h"                   # default: 24h
```

| Field | Required | Default | Description |
|---|---|---|---|
| `secretName` | No | `kubev-basic-auth` | Name of the Kubernetes `Secret` holding the `username` and `password` keys. The password may be plaintext, as the installer writes it, or a bcrypt hash, which is safer. If the Secret already exists (e.g., from a previous install), its credentials are preserved. |
| `secretNamespace` | No | `kubermatic-virtualization` | Namespace of the Secret. |
| `sessionDuration` | No | `24h` | How long a login session cookie is valid before the user must re-authenticate. Must be a valid Go duration string: `30m`, `8h`, `1h30m`, `7 * 24h` is written as `168h`, etc. |

**Use when:** You need a simple login gate without setting up an external identity provider. Suitable for small teams, internal tooling, and environments where SSO is not a requirement.

---

#### OIDC Mode

Users authenticate via an external OpenID Connect provider. After a successful login the provider redirects back to `redirectURL` with an authorization code; the dashboard's API server exchanges it for ID and access tokens.

```yaml
dashboard:
  enabled: true
  auth:
    oidc:
      issuerURL: "https://dex.example.com"
      clientID: "kubev-dashboard"
      clientSecret: "a-strong-client-secret"
      redirectURL: "https://dashboard.example.com/auth/callback"
      scopes:
        - "openid"
        - "email"
        - "profile"
```

| Field | Required | Description |
|---|---|---|
| `issuerURL` | Yes | OIDC provider discovery URL. The dashboard will fetch `<issuerURL>/.well-known/openid-configuration` to discover endpoints. Must be reachable from both the browser (for redirects) and the API server (for token verification). |
| `clientID` | Yes | OAuth2 client ID registered with the provider. |
| `clientSecret` | Yes | OAuth2 client secret. |
| `redirectURL` | Yes | Callback URL the provider will redirect to after login. Must be `<dashboardURL>/auth/callback`. Must be registered as an allowed redirect URI on the provider side. |
| `scopes` | No | OIDC scopes to request. Defaults to `["openid", "email", "profile"]`. Add `"groups"` if your provider includes group membership in the token and you want group-based access control. |
| `connectors` | No | IDs of the Dex connectors, its login methods, that a link to KubeV may name in `?connector=` to skip Dex's choice of login method. A user whose upstream identity provider still has a session then signs in without a prompt. Each is 1–64 letters, digits, `.`, `_` or `-`; IDs your Dex doesn't offer are ignored. Set it only when the issuer is Dex: with same-layer KDP it also makes the KDP dashboard ask for Dex's `federated:id` scope, which Keycloak, Okta and Entra ID refuse. |

**Use when:** You want SSO backed by a corporate identity provider (Keycloak, Azure AD, Okta, Google Workspace, etc.) or by the in-cluster Dex deployed via `idp.dex`.

#### Using OIDC with the In-Cluster Dex

When you configure `idp.dex`, KubeV deploys Dex but does not automatically connect it to the dashboard. You must wire them together manually:

1. Register the dashboard as a static client in `idp.dex.staticClients`.
2. Set `dashboard.auth.oidc.issuerURL` to exactly match `idp.dex.issuer`.
3. Set `dashboard.auth.oidc.clientID` and `clientSecret` to match the static client registration.
4. Set `dashboard.auth.oidc.redirectURL` to `<dashboardURL>/auth/callback`.

Complete example:

```yaml
idp:
  dex:
    issuer: "https://dex.example.com"
    enablePasswordDB: true          # quick start: local users
    staticClients:
      - id: kubev-dashboard
        name: KubeV Dashboard
        secret: "a-strong-client-secret"
        redirectURIs:
          - "https://dashboard.example.com/auth/callback"

dashboard:
  enabled: true
  dashboardURL: "https://dashboard.example.com"
  auth:
    oidc:
      issuerURL: "https://dex.example.com"       # must match idp.dex.issuer exactly
      clientID: "kubev-dashboard"                # must match staticClients[].id
      clientSecret: "a-strong-client-secret"     # must match staticClients[].secret
      redirectURL: "https://dashboard.example.com/auth/callback"
```

---

## cert-manager

KubeV always installs [cert-manager](https://cert-manager.io/).

```yaml
certManager:
  gatewayAPI: true
```

| Field | Default | Description |
|---|---|---|
| `gatewayAPI` | `false` | Turns on cert-manager's Gateway API support, so it issues certificates for Gateways and answers HTTP-01 challenges through HTTPRoutes. Install the [Gateway API](https://gateway-api.sigs.k8s.io/) CRDs on the cluster first: cert-manager doesn't start with this on while they are missing. |

---

## VM Migration from vSphere

KubeV migrates virtual machines from VMware vSphere with [Forklift](https://github.com/kubev2v/forklift), which the installer installs and manages, in the namespace `konveyor-forklift`. The `migration` section is optional: without it, Forklift is installed.

```yaml
migration:
  enabled: true
  vddk:
    image: "registry.example.com/vddk:8.0.3"
    imagePullSecret: |
      {"auths":{"registry.example.com":{"auth":"<base64 of username:password>"}}}
```

| Field | Required | Default | Description |
|---|---|---|---|
| `enabled` | No | `true` | Installs Forklift. With `false`, the installer installs no Forklift and, in KDP mode, offers no migration to KDP projects. |
| `vddk.image` | No | — | A VDDK image for the whole platform. See [VDDK](#vddk). Requires `enabled`. |
| `vddk.imagePullSecret` | No | — | Raw Docker config JSON for the registry that serves `vddk.image`, in the same format as the top-level [Image Pull Secret](#image-pull-secret). Leave it out when the nodes can pull the image without credentials. Requires `vddk.image`. |

Not to be confused with `kubevirt.migrations`, which tunes [live migration](#live-migration) between nodes.

**Turning migration off** on a cluster that has Forklift uninstalls the Forklift operator. Its CRDs and the `konveyor-forklift` namespace stay, with every provider, plan and migration and the `ForkliftController`. To also stop the components the operator started, delete the `ForkliftController` first, while the operator is still installed, and then set `enabled: false`.

### VDDK

VMware's Virtual Disk Development Kit (VDDK) lets Forklift copy disks faster than over the vCenter's HTTPS datastore path, and it is required for warm migrations. KubeV doesn't ship it: build an image from the VDDK archive you download from Broadcom, push it to a registry the cluster can reach, and name it in `vddk.image`.

Forklift then uses it for every vSphere provider that doesn't name its own image. In KDP mode, providers may not name their own, so `vddk.image` is the only way to give KDP projects VDDK.

With `vddk.image` set, Forklift runs the pods of a migration plan as the ServiceAccount `kubev-migration`, unless the plan names its own. The KubeV controller-manager creates it in each plan's target namespace. With `vddk.imagePullSecret`, the credentials are kept as the Secret `kubev-vddk-pull` in the `kubermatic-virtualization` namespace and copied into each plan's target namespace for as long as a plan targets it. Anyone who can read Secrets there can read the copy, so use a token that can only pull.

---

## Platform Feature Gates

`featureGates` turns on optional KubeV features that are off by default. Unlike `kubevirt.developerConfiguration.featureGates`, which are KubeVirt's own, these gates are KubeV's: an unknown name is refused when the file is loaded.

```yaml
featureGates:
  CopyOffload: true
```

| Gate | What it enables |
|---|---|
| `CopyOffload` | Forklift's copy offload for vSphere: the storage array copies a VM's disks itself (VAAI XCOPY), instead of streaming them through the cluster. It needs the source datastore on a SAN array, NetApp ONTAP, and a Trident `ontap-san` StorageClass on the same array. Not available to KDP projects. |

---

## KDP Integration

The `kdp` section runs KubeV as a service of the Kubermatic Developer Platform (KDP): users get virtual machines in their KDP projects, and KDP manages organizations, projects, members and roles. The [KDP Integration]({{< ref "../kdp-integration" >}}) guide explains how it works and walks through each installation mode, and [The `kdp` section]({{< ref "../kdp-integration/installation#the-kdp-section" >}}) lists every field.

```yaml
kdp:
  enabled: true
  adminGroup: "kubev-platform-admins"
  domains:
    dashboard: kdp.example.com
    kcp: kcp.example.com
```

Which other fields the section has decides the mode:

| Mode | Set | What the installer does |
|---|---|---|
| [Bring your own KDP]({{< ref "../kdp-integration/installation/external-kdp" >}}) | `kdp.external` | Points KubeV at a KDP you already run. `kubermatic-virtualization kdp connect` then registers KubeV in it. |
| [Same layer]({{< ref "../kdp-integration/installation/same-layer" >}}) | neither `external` nor `cluster` | Installs KDP on the KubeV cluster and registers KubeV in it. |
| [Nested cluster]({{< ref "../kdp-integration/installation/nested" >}}) | `kdp.cluster` | Installs KDP in its own cluster on KubeVirt VMs. Experimental. |

In every mode, a configuration with the dashboard enabled also needs:

- `dashboard.auth.oidc`. KDP, kcp and the KubeV dashboard share this one OIDC client.
- `dashboard.dashboardURL`, the absolute `http://` or `https://` address users open KubeV at.

The nested mode needs `dashboard.enabled: false`. In the same layer and nested modes, the installer pulls the KDP charts with `KUBEV_USERNAME` and `KUBEV_PASSWORD`, even when `imagePullSecret` is set.

**Use when:** You run, or want to run, KDP as your internal developer platform, and want teams to get virtual machines from its catalog.

---

## Complete Example

A production-grade configuration with 3-node HA control plane, 2 worker nodes, MetalLB, Longhorn, in-cluster Dex federated to Google and LDAP, the dashboard in OIDC mode, and VM migration from vSphere with a VDDK image:

```yaml
apiVersion: virtualization.k8c.io/v1alpha1
kind: KubeVCluster

networkConfiguration:
  dnsServerIP: "192.168.1.1"
  networkCIDR: "10.244.0.0/16"
  serviceCIDR: "10.96.0.0/12"
  gatewayIP: "10.244.0.1"
  tunnelInterface: "eth0"

apiEndpoint:
  host: "api.example.com"
  alternativeNames:
    - "192.168.1.100"

controlPlane:
  hosts:
    - address: "192.168.1.10"
      sshUsername: "ubuntu"
      sshPrivateKeyFile: "/home/ops/.ssh/id_rsa"
    - address: "192.168.1.11"
      sshUsername: "ubuntu"
      sshPrivateKeyFile: "/home/ops/.ssh/id_rsa"
    - address: "192.168.1.12"
      sshUsername: "ubuntu"
      sshPrivateKeyFile: "/home/ops/.ssh/id_rsa"

staticWorkers:
  hosts:
    - address: "192.168.1.20"
      sshUsername: "ubuntu"
      sshPrivateKeyFile: "/home/ops/.ssh/id_rsa"
    - address: "192.168.1.21"
      sshUsername: "ubuntu"
      sshPrivateKeyFile: "/home/ops/.ssh/id_rsa"

loadBalancer:
  metallb:
    ipRange: "192.168.1.100-192.168.1.150"

storage:
  longhorn: {}

kubevirt:
  developerConfiguration:
    featureGates:
      - "LiveMigration"
      - "Snapshot"
    useEmulation: false

idp:
  dex:
    issuer: "https://dex.example.com"
    enablePasswordDB: false
    connectors:
      - type: oidc
        id: google
        name: Google
        config:
          issuer: https://accounts.google.com
          clientID: "your-google-client-id"
          clientSecret: "your-google-client-secret"
          redirectURI: "https://dex.example.com/callback"
      - type: ldap
        id: ldap
        name: Corporate Directory
        config:
          host: "ldap.corp.example.com:389"
          startTLS: true
          bindDN: "cn=kubev-svc,ou=serviceaccounts,dc=corp,dc=example,dc=com"
          bindPW: "service-account-password"
          userSearch:
            baseDN: "ou=people,dc=corp,dc=example,dc=com"
            filter: "(objectClass=person)"
            username: uid
            idAttr: uid
            emailAttr: mail
            nameAttr: displayName
    staticClients:
      - id: kubev-dashboard
        name: KubeV Dashboard
        secret: "a-strong-client-secret"
        redirectURIs:
          - "https://dashboard.example.com/auth/callback"

dashboard:
  enabled: true
  dashboardURL: "https://dashboard.example.com"
  auth:
    oidc:
      issuerURL: "https://dex.example.com"
      clientID: "kubev-dashboard"
      clientSecret: "a-strong-client-secret"
      redirectURL: "https://dashboard.example.com/auth/callback"

migration:
  enabled: true
  vddk:
    image: "registry.example.com/vddk:8.0.3"

imagePullSecret: |
  {"auths":{"quay.io":{"auth":"<base64 of username:password>"}}}
```
