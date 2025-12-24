+++
title = "Declarative Installation"
date = 2025-12-24T12:00:00+02:00
weight = 16
+++

This guide provides comprehensive instructions for deploying and managing Kubermatic Virtualization using the declarative `apply` command with YAML configuration files.

## Overview

The Kubermatic Virtualization `apply` command enables declarative cluster management through infrastructure-as-code practices. This approach provides:

- **Version-controlled configurations** stored in Git or other VCS
- **Idempotent operations** that are safe to run repeatedly
- **Automated lifecycle management** including installation, upgrades, and repairs
- **GitOps workflows** for continuous delivery and reconciliation
- **Audit trails** through configuration file history

### Prerequisites

Before beginning, ensure you have:

- A valid Kubermatic Virtualization license (contact [sales@kubermatic.com](mailto:sales@kubermatic.com))
- Administrative access to target infrastructure
- SSH connectivity to all designated cluster nodes
- A text editor for creating YAML configuration files
- Network planning documentation including CIDR blocks and IP ranges

## Configuration File Structure

The declarative installation uses a YAML configuration file following the Kubermatic Virtualization API schema. This file serves as the single source of truth for your cluster's desired state.

### Minimal Configuration Example

```yaml
apiVersion: virtualization.k8c.io/v1alpha1
kind: KubeVCluster

networkConfiguration:
  dnsServerIP: "8.8.8.8"
  networkCIDR: "10.244.0.0/16"
  serviceCIDR: "10.96.0.0/12"
  gatewayIP: "10.244.0.1"

controlPlane:
  hosts:
    - address: "192.168.1.10"
      sshUsername: "ubuntu"
      sshPrivateKeyFile: "/home/user/.ssh/id_rsa"

loadBalancer:
  none: {}

storage:
  none: {}
```

### Complete Configuration Example

```yaml
apiVersion: virtualization.k8c.io/v1alpha1
kind: KubeVCluster

# Network configuration defines the fundamental connectivity layer
networkConfiguration:
  # DNS server for name resolution
  dnsServerIP: "8.8.8.8"
  
  # Pod network CIDR (default: 10.244.0.0/16)
  networkCIDR: "10.244.0.0/16"
  
  # Service network CIDR (default: 10.96.0.0/12)
  serviceCIDR: "10.96.0.0/12"
  
  # Gateway IP for pod network (default: 10.244.0.1)
  gatewayIP: "10.244.0.1"

# Control plane configuration
controlPlane:
  hosts:
    - address: "192.168.1.10"
      sshUsername: "ubuntu"
      sshPrivateKeyFile: "/home/user/.ssh/cluster-key"

# Worker nodes configuration
staticWorkers:
  hosts:
    - address: "192.168.1.11"
      sshUsername: "ubuntu"
      sshPrivateKeyFile: "/home/user/.ssh/cluster-key"
    - address: "192.168.1.12"
      sshUsername: "ubuntu"
      sshPrivateKeyFile: "/home/user/.ssh/cluster-key"

# Load balancer configuration (exactly one option required)
loadBalancer:
  # Option 1: Enable MetalLB
  metallb:
    ipRange: "192.168.1.100-192.168.1.150"
  
  # Option 2: Disable load balancer (uncomment to use)
  # none: {}

# Storage configuration (exactly one option required)
storage:
  # Option 1: Enable Longhorn distributed storage
  longhorn: {}
  
  # Option 2: Disable managed storage (uncomment to use)
  # none: {}
```

---

## Installation Procedure

### Step 1: Create Configuration File

Create a YAML configuration file (e.g., `cluster.yaml`) with your cluster specifications:

```bash
# Create configuration file
cat > cluster.yaml <<EOF
apiVersion: virtualization.k8c.io/v1alpha1
kind: KubeVCluster

networkConfiguration:
  dnsServerIP: "8.8.8.8"
  networkCIDR: "10.244.0.0/16"
  serviceCIDR: "10.96.0.0/12"
  gatewayIP: "10.244.0.1"

controlPlane:
  hosts:
    - address: "192.168.1.10"
      sshUsername: "ubuntu"
      sshPrivateKeyFile: "/home/user/.ssh/id_rsa"

staticWorkers:
  hosts:
    - address: "192.168.1.11"
      sshUsername: "ubuntu"
      sshPrivateKeyFile: "/home/user/.ssh/id_rsa"

loadBalancer:
  metallb:
    ipRange: "192.168.1.100-192.168.1.150"

storage:
  longhorn: {}
EOF
```

### Step 2: Review Installation Plan

Run the apply command to see what will be installed:

```bash
kubermatic-virtualization apply -f cluster.yaml
```

The command will display:

```bash
INFO[12:01:02 CET] ╔══════════════════════════════════════════════════════════════╗ 
INFO[12:01:02 CET] ║                                                              ║ 
INFO[12:01:02 CET] ║          KubeV - Kubermatic Virtualization Platform          ║ 
INFO[12:01:02 CET] ║                                                              ║ 
INFO[12:01:02 CET] ╚══════════════════════════════════════════════════════════════╝ 
INFO[12:01:02 CET]                                              
INFO[12:01:02 CET] Starting cluster apply process                configFile=cluster.yaml
INFO[12:01:02 CET] Loading configuration file                    file=cluster.yaml
INFO[12:01:02 CET] Configuration loaded and validated successfully  loadBalancer=metallb masterNodes=1 storage=longhorn workerNodes=2
Do you want to proceed (yes/no): 
```

### Step 3: Confirm and Install

Confirm the installation by typing `y` and pressing Enter. The installation will proceed through multiple phases:

```
[KubeV] Identifying the operating system...
[KubeV] Setting up required software components...
[KubeV] Creating configuration files...
[KubeV] Performing initial system checks...
...
[KubeV] Configuring virtualization support...

[KubeV] ✓ Cluster installation completed successfully
```

---

## Cluster Lifecycle Management

The `apply` command is not just for initial installation—it manages your cluster's entire lifecycle.

### Adding Worker Nodes

Add new nodes to `staticWorkers` section and apply:

```yaml
staticWorkers:
  hosts:
    - address: "192.168.1.11"
      sshUsername: "ubuntu"
      sshPrivateKeyFile: "/home/user/.ssh/id_rsa"
    - address: "192.168.1.12"
      sshUsername: "ubuntu"
      sshPrivateKeyFile: "/home/user/.ssh/id_rsa"
    # New node
    - address: "192.168.1.13"
      sshUsername: "ubuntu"
      sshPrivateKeyFile: "/home/user/.ssh/id_rsa"
```

```bash
kubermatic-virtualization apply -f cluster.yaml
```

### Repairing Unhealthy Clusters

If a node becomes unhealthy or is removed from the cluster, simply run apply again:

```bash
kubermatic-virtualization apply -f cluster.yaml
```

The command will:
1. Detect unhealthy or missing nodes
2. Determine if repair is safe (no etcd quorum risk)
3. Rejoin nodes automatically
4. Restore cluster to healthy state

### Checking Cluster Status

To check current cluster state without making changes:

```bash
kubermatic-virtualization apply -f cluster.yaml --verbose
```

This shows detailed information about:
- Current node health
- Component versions
- Service status
- Any detected issues

---

## Troubleshooting

### Configuration Validation Errors

**Error:** `configuration validation failed: invalid IP address`

**Solution:** Verify all IP addresses are valid IPv4 addresses:
```yaml
controlPlane:
  hosts:
    - address: "192.168.1.10"  # ✓ Valid
    # - address: "192.168.1"    # ✗ Invalid
```

**Error:** `SSH key file does not exist`

**Solution:** Ensure SSH key paths are absolute and files exist:
```bash
# Check key file exists
ls -la /home/user/.ssh/id_rsa

# Fix permissions if needed
chmod 600 /home/user/.ssh/id_rsa
```

**Error:** `exactly one load balancer option must be specified`

**Solution:** Set either `metallb` or `none`, not both:
```yaml
# Choose one:
loadBalancer:
  metallb:
    ipRange: "192.168.1.100-192.168.1.150"
  # OR
  # none: {}
```

### Connection Issues

**Error:** `failed to connect to host: connection refused`

**Solutions:**
1. Verify SSH connectivity:
   ```bash
   ssh -i /home/user/.ssh/id_rsa ubuntu@192.168.1.10
   ```

2. Check firewall rules allow SSH (port 22)

3. Verify SSH service is running on target nodes:
   ```bash
   systemctl status sshd
   ```

### Upgrade Issues

**Error:** `repair and upgrade are not supported simultaneously`

**Solution:** This occurs when trying to upgrade while nodes are unhealthy. First repair the cluster:
```bash
# Step 1: Repair cluster with current version
kubermatic-virtualization apply -f cluster.yaml

# Step 2: After repair completes, upgrade
# (update version in cluster.yaml)
kubermatic-virtualization apply -f cluster.yaml
```

### Log Analysis

Detailed logs are available at `/tmp/kubermatic-virtualization.log`:

```bash
# View recent logs
tail -f /tmp/kubermatic-virtualization.log

# Search for errors
grep -i error /tmp/kubermatic-virtualization.log
```

---

## Post-Installation

After successful installation, verify cluster health and begin workload deployment.

### Verify Installation

```bash
# Set KUBECONFIG
export KUBECONFIG=kubev-cluster-kubeconfig

# Check nodes
kubectl get nodes

# Expected output:
# NAME    STATUS   ROLES           AGE   VERSION
# node1   Ready    control-plane   5m    v1.33.0
# node2   Ready    <none>          4m    v1.33.0

# Check system pods
kubectl get pods --all-namespaces

# Check storage (if Longhorn enabled)
kubectl get pods -n longhorn-system

# Check load balancer (if MetalLB enabled)
kubectl get pods -n metallb-system
```

## Support and Resources

- **Documentation:** [https://docs.kubermatic.com/kubermatic-virtualization/](https://docs.kubermatic.com/kubermatic-virtualization/)
- **Technical Support:** [sales@kubermatic.com](mailto:sales@kubermatic.com)
- **Community:** Join our community channels
- **Enterprise Support:** Contact sales for enterprise support options

For production deployments, enterprise support, or licensing inquiries, contact Kubermatic at [sales@kubermatic.com](mailto:sales@kubermatic.com).