+++
title = "DigitalOcean"
date = 2024-05-31T07:00:00+02:00
+++

This guide covers machine-controller configuration for DigitalOcean.

## Prerequisites

- DigitalOcean account
- Personal Access Token with read/write scopes
- Kubernetes cluster with machine-controller installed

## Create API Token

1. Log in to [DigitalOcean Control Panel](https://cloud.digitalocean.com/)
2. Go to **API** in the left sidebar
3. Click **Generate New Token**
4. Give it a name and select both **Read** and **Write** scopes
5. Click **Generate Token**
6. Copy and save the token securely (shown only once)

## Provider Configuration

### Basic Configuration

```yaml
cloudProviderSpec:
  # API token
  token: "<< YOUR_DO_TOKEN >>"
  
  # Region
  region: "fra1"
  
  # Droplet size
  size: "s-2vcpu-4gb"
  
  # Backups
  backups: false
  
  # IPv6
  ipv6: false
  
  # Private networking
  private_networking: true
  
  # Monitoring
  monitoring: true
  
  # Tags
  tags:
    - "kubernetes"
    - "worker"
```

### Using Secrets

Create a secret:

```bash
kubectl create secret generic do-credentials \
  -n kube-system \
  --from-literal=token=<YOUR_DO_TOKEN>
```

Reference in MachineDeployment:

```yaml
cloudProviderSpec:
  token:
    secretKeyRef:
      name: do-credentials
      key: token
```

### All Configuration Options

```yaml
cloudProviderSpec:
  # API token (required)
  token: "<< YOUR_DO_TOKEN >>"
  # Can also be set via DO_TOKEN env var
  
  # Region (required)
  region: "fra1"
  # Available: nyc1, nyc3, sfo3, sgp1, lon1, fra1, tor1, blr1, etc.
  
  # Droplet size (required)
  size: "s-2vcpu-4gb"
  
  # Enable backups (default: false)
  backups: false
  
  # Enable IPv6 (default: false)
  ipv6: false
  
  # Enable private networking (default: true)
  private_networking: true
  
  # Enable monitoring agent (default: true)
  monitoring: true
  
  # VPC UUID (optional)
  vpc_uuid: ""
  
  # Tags (for organization)
  tags:
    - "kubernetes"
    - "worker"
    - "production"
  
  # User data (optional, for additional customization)
  # user_data: ""
```

## Complete MachineDeployment Examples

### Basic Ubuntu Workers

```yaml
apiVersion: cluster.k8s.io/v1alpha1
kind: MachineDeployment
metadata:
  name: do-ubuntu-workers
  namespace: kube-system
spec:
  replicas: 3
  selector:
    matchLabels:
      name: do-ubuntu-workers
  template:
    metadata:
      labels:
        name: do-ubuntu-workers
    spec:
      providerSpec:
        value:
          cloudProvider: "digitalocean"
          cloudProviderSpec:
            region: "fra1"
            size: "s-2vcpu-4gb"
            backups: false
            ipv6: false
            private_networking: true
            monitoring: true
            token:
              secretKeyRef:
                name: do-credentials
                key: token
            tags:
              - "kubernetes"
              - "worker"
          operatingSystem: "ubuntu"
          operatingSystemSpec:
            distUpgradeOnBoot: false
      versions:
        kubelet: "1.28.0"
```

### High-Memory Workers

```yaml
apiVersion: cluster.k8s.io/v1alpha1
kind: MachineDeployment
metadata:
  name: do-highmem-workers
  namespace: kube-system
spec:
  replicas: 2
  selector:
    matchLabels:
      name: do-highmem-workers
  template:
    metadata:
      labels:
        name: do-highmem-workers
    spec:
      providerSpec:
        value:
          cloudProvider: "digitalocean"
          cloudProviderSpec:
            region: "fra1"
            size: "s-4vcpu-8gb"
            backups: false
            private_networking: true
            monitoring: true
            token:
              secretKeyRef:
                name: do-credentials
                key: token
            tags:
              - "kubernetes"
              - "worker"
              - "high-memory"
          operatingSystem: "ubuntu"
      versions:
        kubelet: "1.28.0"
```

### Workers with Backups Enabled

```yaml
apiVersion: cluster.k8s.io/v1alpha1
kind: MachineDeployment
metadata:
  name: do-backup-workers
  namespace: kube-system
spec:
  replicas: 3
  selector:
    matchLabels:
      name: do-backup-workers
  template:
    metadata:
      labels:
        name: do-backup-workers
    spec:
      providerSpec:
        value:
          cloudProvider: "digitalocean"
          cloudProviderSpec:
            region: "fra1"
            size: "s-2vcpu-4gb"
            backups: true  # Weekly backups
            private_networking: true
            monitoring: true
            token:
              secretKeyRef:
                name: do-credentials
                key: token
            tags:
              - "kubernetes"
              - "worker"
          operatingSystem: "ubuntu"
      versions:
        kubelet: "1.28.0"
```

### Rocky Linux Workers

```yaml
apiVersion: cluster.k8s.io/v1alpha1
kind: MachineDeployment
metadata:
  name: do-rocky-workers
  namespace: kube-system
spec:
  replicas: 3
  selector:
    matchLabels:
      name: do-rocky-workers
  template:
    metadata:
      labels:
        name: do-rocky-workers
    spec:
      providerSpec:
        value:
          cloudProvider: "digitalocean"
          cloudProviderSpec:
            region: "fra1"
            size: "s-2vcpu-4gb"
            private_networking: true
            monitoring: true
            token:
              secretKeyRef:
                name: do-credentials
                key: token
            tags:
              - "kubernetes"
              - "worker"
          operatingSystem: "rockylinux"
      versions:
        kubelet: "1.28.0"
```

## Droplet Sizes

### Standard Droplets

| Size | vCPUs | RAM | Disk | Transfer | Price/mo* |
|------|-------|-----|------|----------|-----------|
| s-1vcpu-1gb | 1 | 1 GB | 25 GB | 1 TB | $6 |
| s-1vcpu-2gb | 1 | 2 GB | 50 GB | 2 TB | $12 |
| s-2vcpu-2gb | 2 | 2 GB | 60 GB | 3 TB | $18 |
| s-2vcpu-4gb | 2 | 4 GB | 80 GB | 4 TB | $24 |
| s-4vcpu-8gb | 4 | 8 GB | 160 GB | 5 TB | $48 |
| s-8vcpu-16gb | 8 | 16 GB | 320 GB | 6 TB | $96 |

### CPU-Optimized Droplets

| Size | vCPUs | RAM | Disk | Transfer | Price/mo* |
|------|-------|-----|------|----------|-----------|
| c-2 | 2 | 4 GB | 25 GB | 4 TB | $42 |
| c-4 | 4 | 8 GB | 50 GB | 5 TB | $84 |
| c-8 | 8 | 16 GB | 100 GB | 6 TB | $168 |

### Memory-Optimized Droplets

| Size | vCPUs | RAM | Disk | Transfer | Price/mo* |
|------|-------|-----|------|----------|-----------|
| m-2vcpu-16gb | 2 | 16 GB | 40 GB | 4 TB | $90 |
| m-4vcpu-32gb | 4 | 32 GB | 80 GB | 5 TB | $180 |
| m-8vcpu-64gb | 8 | 64 GB | 160 GB | 6 TB | $360 |

*Prices are approximate and subject to change.

List available sizes:

```bash
# Using doctl CLI
doctl compute size list
```

## Regions

Available regions:
- **North America**: nyc1, nyc2, nyc3, sfo1, sfo2, sfo3, tor1
- **Europe**: ams2, ams3, fra1, lon1
- **Asia**: sgp1, blr1
- **Australia**: syd1

List regions:

```bash
doctl compute region list
```

## VPC (Virtual Private Cloud)

### Create VPC

```bash
# Create VPC
doctl vpcs create \
  --name k8s-vpc \
  --region fra1 \
  --ip-range 10.10.0.0/16
```

### Use in MachineDeployment

```yaml
cloudProviderSpec:
  vpc_uuid: "uuid-from-vpc-creation"
  private_networking: true
```

## Monitoring and Backups

### Enable Monitoring

```yaml
cloudProviderSpec:
  monitoring: true
```

This installs the DigitalOcean monitoring agent for:
- CPU usage
- Memory usage
- Disk I/O
- Network traffic

### Enable Backups

```yaml
cloudProviderSpec:
  backups: true
```

Weekly automatic backups:
- Taken once per week
- 4 backups retained
- Costs 20% of droplet price

## Firewall

### Create Firewall

```bash
# Create firewall
doctl compute firewall create \
  --name worker-firewall \
  --inbound-rules "protocol:tcp,ports:22,sources:addresses:0.0.0.0/0" \
  --inbound-rules "protocol:tcp,ports:10250,sources:addresses:CONTROL_PLANE_IP" \
  --outbound-rules "protocol:tcp,ports:all,destinations:addresses:0.0.0.0/0"
```

Apply to droplets using tags:

```yaml
cloudProviderSpec:
  tags:
    - "worker"  # Firewall rule targets this tag
```

## Load Balancer Integration

For LoadBalancer services, add annotation:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service
  annotations:
    service.beta.kubernetes.io/do-loadbalancer-name: "my-lb"
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 8080
  selector:
    app: my-app
```

## Multi-Region Deployment

Deploy across multiple regions:

```yaml
---
apiVersion: cluster.k8s.io/v1alpha1
kind: MachineDeployment
metadata:
  name: workers-fra1
  namespace: kube-system
spec:
  replicas: 2
  template:
    spec:
      providerSpec:
        value:
          cloudProviderSpec:
            region: "fra1"
---
apiVersion: cluster.k8s.io/v1alpha1
kind: MachineDeployment
metadata:
  name: workers-ams3
  namespace: kube-system
spec:
  replicas: 2
  template:
    spec:
      providerSpec:
        value:
          cloudProviderSpec:
            region: "ams3"
```

## Troubleshooting

### Droplet Creation Fails

```bash
# Check machine events
kubectl describe machine <machine-name> -n kube-system

# Common issues:
# - Invalid API token
# - Droplet limit reached
# - Size not available in region
# - Rate limit exceeded
```

### Check DigitalOcean Resources

```bash
# Using doctl CLI
doctl compute droplet list

# Check specific droplet
doctl compute droplet get <droplet-id>

# View actions/events
doctl compute droplet-action list <droplet-id>
```

### Rate Limiting

DigitalOcean has API rate limits (5000 requests/hour). If hitting limits:

1. Reduce machine-controller worker count
2. Check for unnecessary API calls
3. Implement exponential backoff

## DigitalOcean CLI (doctl)

Install and configure:

```bash
# Install
brew install doctl  # macOS
# or download from https://github.com/digitalocean/doctl/releases

# Authenticate
doctl auth init

# List resources
doctl compute droplet list
doctl compute size list
doctl compute region list
doctl compute image list --public
```

## Best Practices

1. **Use Private Networking**: Enable for secure inter-node communication
2. **Enable Monitoring**: Track resource usage
3. **Use Tags**: Organize and manage droplets
4. **VPC for Isolation**: Use VPCs for network isolation
5. **Backups for Critical**: Enable backups for stateful workloads
6. **Right-Size Droplets**: Start small, scale based on metrics
7. **Use Firewall**: Restrict access using cloud firewalls
8. **Monitor Costs**: Use billing alerts and cost tracking

## Cost Optimization

1. **Right-Size Droplets**: Don't over-provision
2. **Delete Unused Resources**: Clean up test droplets
3. **Use Block Storage**: For persistent data instead of large droplets
4. **Disable Backups**: For ephemeral workers
5. **Monitor Transfer**: Watch for excessive bandwidth usage
6. **Use Reserved IPs Wisely**: Floating IPs cost $6/mo when not attached

## Resources

- [DigitalOcean Documentation](https://docs.digitalocean.com/)
- [Droplet Sizes](https://www.digitalocean.com/pricing)
- [doctl CLI](https://github.com/digitalocean/doctl)
- [VPC Documentation](https://docs.digitalocean.com/products/networking/vpc/)
- [Cloud Firewalls](https://docs.digitalocean.com/products/networking/firewalls/)
- [Monitoring](https://docs.digitalocean.com/products/monitoring/)
- [API Documentation](https://docs.digitalocean.com/reference/api/)

