+++
title = "Nested Cluster"
date = 2026-10-12T00:00:00+00:00
weight = 3
+++

{{% notice warning %}}
**Experimental. Don't use it in production.** The nested mode is meant for trying KDP out, for
example in a lab. For a platform people depend on, use
[Same Layer]({{< ref "../same-layer" >}}) or [Bring Your Own KDP]({{< ref "../external-kdp" >}}).
{{% /notice %}}

In the **nested** mode, the installer creates three KubeVirt VMs on the KubeV cluster, installs a
separate Kubernetes cluster in them, and runs Dex, kcp and KDP there. It then registers the KubeV
service in that KDP, and deploys the api-syncagent on the KubeV cluster.

```mermaid
flowchart TB
  installer(["Installer machine"])
  users(["Users"])
  vms["Nested KDP<br/>3 VMs in namespace kubev-kdp,<br/>running Kubernetes with<br/>Dex, kcp and the KDP dashboard"]
  agent["api-syncagent"]
  tenants["Project namespaces<br/>org--project--namespace"]

  installer -->|"SSH through the first<br/>control plane host"| vms
  users -->|"dashboard :30880<br/>Dex :30556"| vms
  agent -->|"kcp :30843"| vms
  agent --> tenants

  classDef kdp fill:#e8f1fb,stroke:#1f5fa8,color:#0d3c73
  classDef kv fill:#e3f4e8,stroke:#2e7d32,color:#1b5e20
  classDef ext fill:#fff4e0,stroke:#b26a00,color:#6d4100
  class vms kdp
  class agent,tenants kv
  class installer,users ext
```

## Limits

Before you start, know what this mode doesn't do:

- **No KubeV dashboard.** The installer refuses `dashboard.enabled: true` in this mode, so KDP shows
  no **Open KubeV Virtualization** button. Users work with KubeV resources in KDP's own pages or with
  `kubectl`.
- **One login.** The nested Dex has a single built-in user, `admin`, and no login methods of its
  own, so `adminGroup` can't work.
- **One address.** KDP is configured for the first VM's address, `kdp-cp-0`. If that VM is down,
  KDP is down.
- **Install once.** Each run of the installer writes a new SSH key for the VMs, but VMs that already
  exist keep the key of their first boot, so a second run can't reach them. Change the nested KDP's
  settings by recreating it; see [Removing it](#removing-it).
- **No uninstall.** Remove the nested KDP by hand; see [Removing it](#removing-it).

## Requirements

| What | Why |
| --- | --- |
| **The StorageClass `longhorn`** on the KubeV cluster | The VMs' disks are created on it, whatever `storage` says. Without it, the VMs never start. |
| **Room for three VMs** | 4 vCPUs, 8 GiB of memory and a 20 GiB disk each, unless you set `cluster.vms`. |
| **SSH to the first control plane host** | The installer reaches the VMs through `controlPlane.hosts[0]`, with that host's `sshUsername` and `sshPrivateKeyFile`. It must be a key file: an SSH agent isn't used. |
| **A route from the installer machine to the VMs** | The installer connects to kcp in the VMs at the first VM's pod-network address, without a tunnel. Run it from a machine that reaches the cluster's pod network, such as one of its nodes. |
| **Internet access** | From the installer machine, for the Dex, kcp, cert-manager, local-path-provisioner and KDP charts. From the KubeV cluster, for the VMs' Ubuntu cloud image. From the VMs, for operating system packages and container images. |
| **Registry credentials** | `KUBEV_USERNAME` and `KUBEV_PASSWORD` for the KDP charts, on every run. |

## Step 1: Write the configuration

```yaml
dashboard:
  enabled: false                       # not supported beside a nested KDP

kdp:
  enabled: true
  admin: "admin"                       # the nested Dex's built-in user
  domains:
    base: kdp.example.com              # dex., kcp. and dashboard.kdp.example.com
  cluster:
    vms:
      cpu: 4
      memory: 8Gi
      diskSize: 20Gi
    network:                           # must not overlap the KubeV cluster's networks
      networkCIDR: 10.18.0.0/16
      serviceCIDR: 10.112.0.0/12
```

- **Always set `cluster.network`.** Without it, the nested cluster falls back to Kubernetes' default
  pod and Service networks, which the KubeV cluster may be using too.
- **`domains`** holds host names only: each service gets its port, `https://dex.<base>:30556`,
  `https://kcp.<base>:30843` and `http://dashboard.<base>:30880`. Without `domains`, the KDP
  dashboard and kcp fall back to `localhost`, and Dex to a name inside the cluster, so nobody can
  sign in from a browser.
- **`kdp.ca`** takes a CA of your own, as `certificate` and `privateKey` in PEM, to sign the nested
  KDP's certificates. Without it, the installer creates a self-signed CA.
- **`cluster.sshPrivateKeyFile`** is where the installer writes the VMs' SSH key, `id_rsa` in the
  current directory by default. The installer overwrites that file.

## Step 2: Run the installer

```bash
export KUBEV_USERNAME=<your-username>
export KUBEV_PASSWORD=<your-password>
kubermatic-virtualization apply -f cluster.yaml
```

After the KubeV installation, the installer works through these phases. The waits for the VMs and
for SSH can take up to 20 minutes each, the others up to 10:

| Phase | It prints |
| --- | --- |
| Creates the VMs `kdp-cp-0` to `kdp-cp-2` in namespace `kubev-kdp` | `Creating the disks and virtual machines of the KDP cluster...` |
| Waits for them to run and accept SSH | `Waiting for the KDP virtual machines to start and accept SSH...` |
| Installs Kubernetes on them, with cert-manager and local-path storage | `Installing Kubernetes on the KDP virtual machines, with cert-manager and local-path storage...` |
| Sets up the CA and Dex's certificate, then Dex and kcp | `Deploying Dex and kcp on the KDP cluster...` |
| Installs KDP and the KDP dashboard | `Deploying the KDP developer platform and dashboard...` |
| Registers the KubeV service and deploys the api-syncagent | `✓ KubeV is registered in KDP: ...` |

It writes two files in the current directory:

- `kdp-cluster-kubeconfig`, an administrator kubeconfig for the nested cluster;
- the VMs' SSH key, `id_rsa` unless you set `cluster.sshPrivateKeyFile`.

## Step 3: Reach KDP

The three services listen on the first VM's pod-network address. Make that address reachable for your
users, for example through an SSH tunnel through one of the cluster's nodes, and point the names
`dex.<base>`, `kcp.<base>` and `dashboard.<base>` at it.

Unless you set `kdp.ca`, browsers must trust the self-signed CA. Export it with the nested cluster's
kubeconfig, and install it as trusted on your users' machines:

```bash
kubectl --kubeconfig kdp-cluster-kubeconfig -n kdp-system get secret kdp-root-ca \
  -o jsonpath='{.data.tls\.crt}' | base64 -d > kdp-ca.crt
```

## Step 4: Sign in

Sign in to the KDP dashboard, at `http://dashboard.<base>:30880`, as `admin`. The password is random,
and kept in a Secret on the nested cluster:

```bash
kubectl --kubeconfig kdp-cluster-kubeconfig -n kdp-system \
  get secret kubev-kdp-dex-admin -o jsonpath='{.data.password}' | base64 -d
```

Then create an organization and a project, and enable **KubeV Virtualization** in the project from
KDP's catalog. In this mode, KubeV isn't enabled in projects automatically. Enable it in projects
only: see [Where KubeV works]({{< ref "../../how-it-works#where-kubev-works" >}}).

## Removing it

There is no uninstall command. To remove the nested KDP, remove `kdp.cluster` from the configuration
first, so that the next run doesn't create it again. Then delete these namespaces on the KubeV
cluster:

- `kubev-kdp`, which holds the VMs and their disks. Every organization, project and object in that
  KDP is lost with it;
- `kubev-syncagent`, which holds the api-syncagent;
- the project namespaces, `<organization>--<project>--<namespace>`, which still hold the copies of
  the projects' VMs, disks and networks.

The api-syncagent also left cluster-wide objects behind: the PublishedResources and their CRD
`publishedresources.syncagent.kcp.io`, the ClusterRole and ClusterRoleBinding
`kubev-syncagent:resources`, and the admission policies and bindings `kubev-kdp-kubevirt` and
`kubev-kdp-forklift`.
