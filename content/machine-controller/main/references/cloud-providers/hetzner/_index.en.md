+++
title = "Hetzner Cloud"
date = 2024-05-31T07:00:00+02:00
+++

This guide covers machine-controller configuration for Hetzner Cloud.

## Prerequisites

- Hetzner Cloud account
- API token with read/write permissions
- Kubernetes cluster with machine-controller installed

## Create API Token

1. Log in to [Hetzner Cloud Console](https://console.hetzner.cloud/)
2. Select your project
3. Go to **Security** → **API Tokens**
4. Click **Generate API Token**
5. Give it a name and select **Read & Write** permissions
6. Save the token securely

## Provider Configuration

### Basic Configuration

```yaml
cloudProviderSpec:
  # API token
  token: "<< HETZNER_API_TOKEN >>"
  
  # Server type
  serverType: "cx21"
  
  # Location
  location: "fsn1"
  
  # Labels
  labels:
    kubernetesCluster: "my-cluster"
```

### Using Secrets

Create a secret:

```bash
kubectl create secret generic hcloud-credentials \
  -n kube-system \
  --from-literal=token=<YOUR_HETZNER_API_TOKEN>
```

Reference in MachineDeployment:

```yaml
cloudProviderSpec:
  token:
    secretKeyRef:
      name: hcloud-credentials
      key: token
```

### All Configuration Options

```yaml
cloudProviderSpec:
  # API token (required)
  token: "<< HETZNER_API_TOKEN >>"
  # Can also be set via HCLOUD_TOKEN env var
  
  # Server type (required)
  serverType: "cx21"
  
  # Location (optional, use location OR datacenter)
  location: "fsn1"  # fsn1, nbg1, hel1, ash, hil
  
  # Datacenter (optional, use location OR datacenter)
  # datacenter: "fsn1-dc14"
  
  # Image (optional, auto-selected based on OS)
  # image: "ubuntu-22.04"
  
  # Networks (optional)
  networks:
    - "my-private-network"
    # Can use network name or ID
  
  # Firewalls (optional)
  firewalls:
    - "worker-firewall"
  
  # Placement group (optional, for spreading)
  placementGroup: "workers-pg"
  
  # Labels (for organization)
  labels:
    kubernetesCluster: "my-cluster"
    environment: "production"
```

## Complete MachineDeployment Examples

### Basic Ubuntu Workers

```yaml
apiVersion: cluster.k8s.io/v1alpha1
kind: MachineDeployment
metadata:
  name: hcloud-ubuntu-workers
  namespace: kube-system
spec:
  replicas: 3
  selector:
    matchLabels:
      name: hcloud-ubuntu-workers
  template:
    metadata:
      labels:
        name: hcloud-ubuntu-workers
    spec:
      providerSpec:
        value:
          cloudProvider: "hetzner"
          cloudProviderSpec:
            serverType: "cx21"
            location: "fsn1"
            token:
              secretKeyRef:
                name: hcloud-credentials
                key: token
            labels:
              kubernetesCluster: "my-cluster"
          operatingSystem: "ubuntu"
          operatingSystemSpec:
            distUpgradeOnBoot: false
      versions:
        kubelet: "1.28.0"
```

### Workers with Private Network

```yaml
apiVersion: cluster.k8s.io/v1alpha1
kind: MachineDeployment
metadata:
  name: hcloud-private-workers
  namespace: kube-system
spec:
  replicas: 3
  selector:
    matchLabels:
      name: hcloud-private-workers
  template:
    metadata:
      labels:
        name: hcloud-private-workers
    spec:
      providerSpec:
        value:
          cloudProvider: "hetzner"
          cloudProviderSpec:
            serverType: "cx21"
            location: "fsn1"
            networks:
              - "k8s-private-network"
            token:
              secretKeyRef:
                name: hcloud-credentials
                key: token
            labels:
              kubernetesCluster: "my-cluster"
          operatingSystem: "ubuntu"
      versions:
        kubelet: "1.28.0"
```

### High-Performance Workers

```yaml
apiVersion: cluster.k8s.io/v1alpha1
kind: MachineDeployment
metadata:
  name: hcloud-performance-workers
  namespace: kube-system
spec:
  replicas: 2
  selector:
    matchLabels:
      name: hcloud-performance-workers
  template:
    metadata:
      labels:
        name: hcloud-performance-workers
    spec:
      providerSpec:
        value:
          cloudProvider: "hetzner"
          cloudProviderSpec:
            serverType: "cpx51"  # 16 vCPU, 32 GB RAM
            location: "fsn1"
            token:
              secretKeyRef:
                name: hcloud-credentials
                key: token
            labels:
              kubernetesCluster: "my-cluster"
              workload: "compute-intensive"
          operatingSystem: "ubuntu"
      versions:
        kubelet: "1.28.0"
```

### Rocky Linux Workers

```yaml
apiVersion: cluster.k8s.io/v1alpha1
kind: MachineDeployment
metadata:
  name: hcloud-rocky-workers
  namespace: kube-system
spec:
  replicas: 3
  selector:
    matchLabels:
      name: hcloud-rocky-workers
  template:
    metadata:
      labels:
        name: hcloud-rocky-workers
    spec:
      providerSpec:
        value:
          cloudProvider: "hetzner"
          cloudProviderSpec:
            serverType: "cx21"
            location: "nbg1"
            token:
              secretKeyRef:
                name: hcloud-credentials
                key: token
            labels:
              kubernetesCluster: "my-cluster"
          operatingSystem: "rockylinux"
      versions:
        kubelet: "1.28.0"
```

## Server Types

### Standard (Shared vCPU)

| Type | vCPUs | RAM | Disk | Network | Price/mo* |
|------|-------|-----|------|---------|-----------|
| cx11 | 1 | 2 GB | 20 GB | 20 TB | ~€4 |
| cx21 | 2 | 4 GB | 40 GB | 20 TB | ~€6 |
| cx31 | 2 | 8 GB | 80 GB | 20 TB | ~€11 |
| cx41 | 4 | 16 GB | 160 GB | 20 TB | ~€18 |
| cx51 | 8 | 32 GB | 240 GB | 20 TB | ~€33 |

### Dedicated vCPU

| Type | vCPUs | RAM | Disk | Network | Price/mo* |
|------|-------|-----|------|---------|-----------|
| cpx11 | 2 | 2 GB | 40 GB | 20 TB | ~€5 |
| cpx21 | 3 | 4 GB | 80 GB | 20 TB | ~€9 |
| cpx31 | 4 | 8 GB | 160 GB | 20 TB | ~€16 |
| cpx41 | 8 | 16 GB | 240 GB | 20 TB | ~€29 |
| cpx51 | 16 | 32 GB | 360 GB | 20 TB | ~€53 |

*Prices are approximate and subject to change.

List available server types:

```bash
# Using hcloud CLI
hcloud server-type list
```

## Locations

Available locations:
- **fsn1** - Falkenstein, Germany (Nuremberg region)
- **nbg1** - Nuremberg, Germany
- **hel1** - Helsinki, Finland
- **ash** - Ashburn, VA, USA
- **hil** - Hillsboro, OR, USA

List locations:

```bash
hcloud location list
```

## Private Networks

### Create Private Network

```bash
# Create network
hcloud network create \
  --name k8s-private-network \
  --ip-range 10.0.0.0/16

# Create subnet
hcloud network add-subnet k8s-private-network \
  --type cloud \
  --network-zone eu-central \
  --ip-range 10.0.1.0/24
```

### Use in MachineDeployment

```yaml
cloudProviderSpec:
  networks:
    - "k8s-private-network"
```

{{% notice info %}}
Servers with private networks still get a public IPv4/IPv6 address for outbound connectivity.
{{% /notice %}}

## Firewalls

### Create Firewall

```bash
# Create firewall
hcloud firewall create --name worker-firewall

# Add rules
hcloud firewall add-rule worker-firewall \
  --direction in \
  --protocol tcp \
  --port 22 \
  --source-ips 0.0.0.0/0 \
  --source-ips ::/0

hcloud firewall add-rule worker-firewall \
  --direction in \
  --protocol tcp \
  --port 10250 \
  --source-ips CONTROL_PLANE_IP/32
```

### Use in MachineDeployment

```yaml
cloudProviderSpec:
  firewalls:
    - "worker-firewall"
```

## Placement Groups

Placement groups spread servers across different hosts for high availability:

```bash
# Create placement group
hcloud placement-group create \
  --name workers-pg \
  --type spread
```

Use in MachineDeployment:

```yaml
cloudProviderSpec:
  placementGroup: "workers-pg"
```

## Multi-Location Deployment

Deploy across multiple locations for geo-distribution:

```yaml
---
apiVersion: cluster.k8s.io/v1alpha1
kind: MachineDeployment
metadata:
  name: workers-fsn1
  namespace: kube-system
spec:
  replicas: 2
  template:
    spec:
      providerSpec:
        value:
          cloudProviderSpec:
            location: "fsn1"
---
apiVersion: cluster.k8s.io/v1alpha1
kind: MachineDeployment
metadata:
  name: workers-nbg1
  namespace: kube-system
spec:
  replicas: 2
  template:
    spec:
      providerSpec:
        value:
          cloudProviderSpec:
            location: "nbg1"
```

## Troubleshooting

### Server Creation Fails

```bash
# Check machine events
kubectl describe machine <machine-name> -n kube-system

# Common issues:
# - Invalid API token
# - Server type not available in location
# - Rate limit exceeded
# - Quota/limit reached
```

### Check Hetzner Cloud Status

```bash
# Using hcloud CLI
hcloud server list

# Check specific server
hcloud server describe <server-id>
```

### Rate Limiting

Hetzner Cloud has API rate limits (3600 requests/hour). If hitting limits:

1. Reduce machine-controller worker count
2. Implement retry logic with backoff
3. Check for unnecessary API calls

## Best Practices

1. **Use Private Networks**: For secure inter-node communication
2. **Use Dedicated vCPU**: For production workloads (cpx series)
3. **Enable Firewalls**: Restrict access to necessary ports
4. **Use Placement Groups**: For high availability
5. **Multi-Location**: Deploy across locations for resilience
6. **Label Resources**: Use labels for organization
7. **Monitor Costs**: Hetzner is cost-effective but monitor usage
8. **Backup Important Data**: Use Hetzner Volumes for persistent data

## Hetzner Cloud CLI

Install the CLI for management:

```bash
# Install
brew install hcloud  # macOS
# or download from https://github.com/hetznercloud/cli/releases

# Configure
hcloud context create my-project

# List resources
hcloud server list
hcloud network list
hcloud firewall list
```

## Cost Optimization

1. **Right-Size Servers**: Start with cx21, scale as needed
2. **Use Shared vCPU**: For non-production (cx series)
3. **Delete Unused Servers**: Clean up test/dev resources
4. **Use Volumes Wisely**: Detach and reuse volumes
5. **Monitor Traffic**: Watch for unexpected network usage

## Resources

- [Hetzner Cloud Docs](https://docs.hetzner.cloud/)
- [Server Types](https://www.hetzner.com/cloud#pricing)
- [Hetzner Cloud CLI](https://github.com/hetznercloud/cli)
- [Private Networks](https://docs.hetzner.cloud/cloud/networks/overview)
- [Firewalls](https://docs.hetzner.cloud/cloud/firewalls/overview)
- [Placement Groups](https://docs.hetzner.cloud/cloud/placement-groups/overview)
- [API Documentation](https://docs.hetzner.cloud/)

