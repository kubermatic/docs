+++
title = "KKP Requirements for Ubuntu"
date = 2025-08-21T20:07:15+02:00
weight = 15

+++

## KKP Package and Configurations for Ubuntu

This document provides an overview of the system packages and Kubernetes-related binaries installed, along with their respective sources.

{{% notice note %}}
This document serves as a guideline for users who want to harden their Ubuntu hosts, providing instructions for installing 
and configuring the required packages and settings. By default, OSM handles these installations and configurations through 
an Operating System Profile. However, users who prefer to manage them manually can follow the steps outlined below.
{{% /notice %}}

---

## System Packages (via `apt`)

The following packages are installed using the **APT package manager**:

| Package                     | Source |
|-----------------------------|--------|
| curl                        | apt    |
| jq                          | apt    |
| ca-certificates             | apt    |
| ceph-common                 | apt    |
| cifs-utils                  | apt    |
| conntrack                   | apt    |
| e2fsprogs                   | apt    |
| ebtables                    | apt    |
| ethtool                     | apt    |
| glusterfs-client            | apt    |
| iptables                    | apt    |
| kmod                        | apt    |
| openssh-client              | apt    |
| nfs-common                  | apt    |
| socat                       | apt    |
| util-linux                  | apt    |
| ipvsadm                     | apt    |
| apt-transport-https         | apt    |
| software-properties-common  | apt    |
| lsb-release                 | apt    |
| containerd.io               | apt    |

---

## Kubernetes Dependencies (Manual Download)

The following components are **manually downloaded** (usually from the official [Kubernetes GitHub releases](https://github.com/kubernetes/kubernetes/releases)):

| Package        | Source                   |
|----------------|--------------------------|
| CNI plugins    | Manual Download (GitHub) |
| CRI-tools      | Manual Download (GitHub) |
| kubelet        | Manual Download (GitHub) |
| kubeadm        | Manual Download (GitHub) |
| kubectl        | Manual Download (GitHub) |

---


## Notes
- **APT packages**: Installed via the system’s package manager for base functionality (networking, file systems, utilities, etc.).
- **Manual downloads**: Required for Kubernetes setup and cluster management, ensuring version consistency across nodes.
- **containerd.io**: Installed via apt as the container runtime.

## Kubernetes Node Bootstrap Configuration

This repository contains scripts and systemd unit files that configure a Linux host to function as a Kubernetes node. These scripts do not install Kubernetes packages directly but apply system, kernel, and service configurations required for proper operation.

---

## 🔧 Configurations Applied

### 1. Environment Variables
- Adds `NO_PROXY` and `no_proxy` to `/etc/environment` to bypass proxying for:
    - `.svc`
    - `.cluster.local`
    - `localhost`
    - `127.0.0.1`

- Creates an empty APT proxy configuration file: /etc/apt/apt.conf.d/proxy.conf

(Placeholder for proxy settings, not configured by default).

---

### 2. Kernel Modules
The script loads and enables essential kernel modules for networking and container orchestration:
- `ip_vs` – IP Virtual Server (transport-layer load balancing).
- `ip_vs_rr` – Round-robin scheduling algorithm.
- `ip_vs_wrr` – Weighted round-robin scheduling algorithm.
- `ip_vs_sh` – Source-hash scheduling algorithm.
- `nf_conntrack_ipv4` or `nf_conntrack` – Connection tracking support.
- `br_netfilter` – Enables netfilter for bridged network traffic (required by Kubernetes).

---

### 3. Kernel Parameters (`sysctl`)
The following runtime kernel parameters are configured:

- `net.bridge.bridge-nf-call-ip6tables = 1`
- `net.bridge.bridge-nf-call-iptables = 1`
- `kernel.panic_on_oops = 1`
- `kernel.panic = 10`
- `net.ipv4.ip_forward = 1`
- `vm.overcommit_memory = 1`
- `fs.inotify.max_user_watches = 1048576`
- `fs.inotify.max_user_instances = 8192`

---

### 4. System Services & Management
- **Firewall**: Disables and masks UFW to avoid interfering with Kubernetes networking.
- **Hostname**: Overrides hostname with `/etc/machine-name` value if available.
- **APT Repositories**: Adds the official Docker APT repository and imports GPG key.
- **Symbolic Links**: Makes `kubelet`, `kubeadm`, `kubectl`, and `crictl` binaries available in `$PATH`.

---

### 5. Node IP & Hostname Configuration
- Discovers IP via: `ip -o route get 1`
- Discovers hostname via: `hostname -f`

### 6. Swap Disabling
Kubernetes requires swap to be disabled:

- Removes swap entries from /etc/fstab: `sed -i.orig '/.*swap.*/d' /etc/fstab`
- Disables active swap immediately: `swapoff -a`
