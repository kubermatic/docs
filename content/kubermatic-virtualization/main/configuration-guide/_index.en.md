+++
title = "Configuration Guide"
date = 2026-04-23T00:00:00+00:00
weight = 6
+++

This document provides a deep-dive reference for the KubeV cluster configuration file. The configuration file drives `kubev apply` and controls every aspect of your Kubermatic Virtualization Platform deployment.

## File Format

The configuration file is a YAML document conforming to the KubeV API schema:

```yaml
apiVersion: virtualization.k8c.io/v1alpha1
kind: KubeVCluster
```

Both fields are required and must match exactly. Use `kubev config print` to generate a starter file, or `kubev config print --verbose` for an annotated version with inline guidance.

---

## Table of Contents

1. [Nodes: Control Plane & Workers](#nodes-control-plane--workers)
2. [Network Configuration](#network-configuration)
3. [API Endpoint](#api-endpoint)
4. [Load Balancer](#load-balancer)
5. [Storage](#storage)
6. [KubeVirt Configuration](#kubevirt-configuration)
7. [Offline / Air-Gapped Configuration](#offline--air-gapped-configuration)
8. [Identity Provider (IDP)](#identity-provider-idp)
9. [Dashboard](#dashboard)
10. [Complete Example](#complete-example)

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
| `address` | Yes | — | Internal RFC-1918 IP address of the node. Must be reachable from the machine running `kubev apply`. |
| `sshUsername` | No | `root` | SSH login username. |
| `sshPrivateKeyFile` | No | `""` | Path to a plaintext (unencrypted) private key file. |
| `labels` | No | `{}` | Kubernetes node labels to apply or remove. |
| `annotations` | No | `{}` | Kubernetes node annotations to apply or remove. |
| `tunnelInterface` | No | — | Per-node override for the Kube-OVN overlay NIC. See [Tunnel Interface](#tunnel-interface). |

**SSH key requirements:**
- The key file must exist on the machine running `kubev apply` and be readable by the invoking user.
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
| `dnsServerIP` | No | — | IP address of the DNS resolver used cluster-wide. In offline deployments this is the only DNS server the nodes and pods will use. |
| `networkCIDR` | No | `10.244.0.0/16` | Pod network CIDR. All pod and VM IPs are allocated from this range by Kube-OVN's IPAM. |
| `serviceCIDR` | No | `10.96.0.0/12` | Service network CIDR. Virtual IPs for `ClusterIP` services are drawn from here. Must not overlap with `networkCIDR`. |
| `gatewayIP` | No | — | Default gateway for pod traffic leaving the cluster. Must be a valid IP within `networkCIDR`. |
| `tunnelInterface` | No | — | Physical NIC used for Kube-OVN inter-node overlay traffic. See below. |

> **Immutable field:** `dnsServerIP` cannot be changed after cluster creation.

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
- The global `tunnelInterface` may be a single name, comma-separated list, or a regex pattern. The regex is tested against `containsRegexMetachars` — if any metacharacter (`^`, `$`, `*`, `.`, `+`, `?`, `(`, `)`, `[`, `]`, `{`, `}`, `|`, `\`) is present, the value is treated as a regex and is not name-validated.
- `networkCIDR` and `serviceCIDR` must not overlap.
- `gatewayIP` must be within `networkCIDR`.
- `dnsServerIP` must be a valid IP address.

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

Exactly one option must be set. If the section is omitted, `none` is applied as the default.

### Longhorn

[Longhorn](https://longhorn.io/) provides distributed block storage backed by node-local disks. It is the default storage backend for VM persistent disks in KubeV.

```yaml
storage:
  longhorn: {}
```

No additional fields are required. Longhorn discovers and uses available block devices on each node automatically. Each `PersistentVolumeClaim` is backed by replicated block volumes, with the replica count configurable via Longhorn's own settings after deployment.

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
```

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
| `Snapshot` | Create point-in-time snapshots of a `VirtualMachine` and its associated disk volumes. Snapshots can be used to restore the VM to a previous state or clone it. Requires a CSI driver that supports volume snapshots (e.g., Longhorn). |
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

### Preparing an Air-Gapped Environment

Before running `kubev apply` in offline mode, the following must be in place:

1. **Mirror container images** — use `kubev mirror-images` to copy all required images to your internal registry. This includes images for Kube-OVN, CertManager, KubeVirt, CDI, Longhorn, MetalLB, Kyverno, Multus, and others.
2. **Prepare the package repository** — sync the OS package repository used by your node OS so that kubeadm, kubelet, and kubectl packages are available.
3. **Test connectivity** — verify that all nodes can reach every internal mirror URL before applying.

> **Note on dashboard images:** The `containerRegistry` field covers infrastructure component images. The API server and dashboard images require separate credentials provided via `dashboard.imagePullSecret` or `KUBEV_USERNAME`/`KUBEV_PASSWORD` environment variables — see [Registry Credentials](#registry-credentials).

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
  imagePullSecret: |
    {"auths":{"quay.io":{"auth":"<base64 of username:password>"}}}
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
| `dashboardURL` | No | — | Public URL where the dashboard is reachable. Used as the redirect target after a successful OIDC login. |
| `imagePullSecret` | Conditional | — | Raw Docker config JSON for authenticating to the image registry. See [Registry Credentials](#registry-credentials). |
| `auth` | No | `none` | Authentication mode. Exactly one of `none`, `basic`, or `oidc` must be set. Defaults to `none` when omitted. |

### Registry Credentials

The KubeV API server and dashboard images are hosted on a private registry. When `dashboard.enabled: true`, credentials must be provided through one of two methods:

**Option 1 — `imagePullSecret` in the config file (preferred for automation):**

```yaml
dashboard:
  imagePullSecret: |
    {"auths":{"quay.io":{"auth":"<base64 of username:password>"}}}
```

Generate the base64-encoded auth value:

```bash
echo -n "myuser:mypassword" | base64
```

**Option 2 — Environment variables before running `kubev apply`:**

```bash
export KUBEV_USERNAME=myuser
export KUBEV_PASSWORD=mypassword
kubev apply -f cluster.yaml
```

If `imagePullSecret` is set in the config file, environment variables are ignored. If neither is provided when the dashboard is enabled, `kubev apply` fails the pre-flight check with a descriptive error before any cluster changes are made.

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
cat <path printed by kubev apply>
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
| `secretName` | No | `kubev-basic-auth` | Name of the Kubernetes `Secret` holding the `username` and `password` keys. If the Secret already exists (e.g., from a previous install), its credentials are preserved. |
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

## Complete Example

A production-grade configuration with 3-node HA control plane, 2 worker nodes, MetalLB, Longhorn, in-cluster Dex federated to Google and LDAP, and the dashboard in OIDC mode:

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
  imagePullSecret: |
    {"auths":{"quay.io":{"auth":"<base64 of username:password>"}}}
  auth:
    oidc:
      issuerURL: "https://dex.example.com"
      clientID: "kubev-dashboard"
      clientSecret: "a-strong-client-secret"
      redirectURL: "https://dashboard.example.com/auth/callback"
```
