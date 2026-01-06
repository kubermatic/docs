+++
title = "GCP (Google Cloud Platform)"
date = 2024-05-31T07:00:00+02:00
+++

This guide covers machine-controller configuration for Google Cloud Platform.

## Prerequisites

- GCP project with Compute Engine API enabled
- Service Account with appropriate permissions
- VPC network and subnet configured
- Kubernetes cluster with machine-controller installed

## Required GCP Permissions

The Service Account needs the following roles:

- **Compute Instance Admin (v1)** - `roles/compute.instanceAdmin.v1`
- **Service Account User** - `roles/iam.serviceAccountUser`

Or a custom role with these permissions:
- `compute.instances.*`
- `compute.disks.*`
- `compute.networks.use`
- `compute.subnetworks.use`
- `compute.zones.list`
- `iam.serviceAccounts.actAs`

## Create Service Account

```bash
# Create service account
gcloud iam service-accounts create machine-controller-sa \
  --display-name="Machine Controller Service Account"

# Grant permissions
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member="serviceAccount:machine-controller-sa@PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/compute.instanceAdmin.v1"

gcloud projects add-iam-policy-binding PROJECT_ID \
  --member="serviceAccount:machine-controller-sa@PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/iam.serviceAccountUser"

# Create and download key
gcloud iam service-accounts keys create key.json \
  --iam-account=machine-controller-sa@PROJECT_ID.iam.gserviceaccount.com

# Base64 encode the key
cat key.json | base64 -w0  # Linux
cat key.json | base64      # macOS
```

## Provider Configuration

### Basic Configuration

```yaml
cloudProviderSpec:
  # Service account (base64-encoded JSON key)
  serviceAccount: "<< BASE64_ENCODED_SERVICE_ACCOUNT_JSON >>"
  
  # Zone
  zone: "us-central1-a"
  
  # Machine configuration
  machineType: "n1-standard-2"
  diskSize: 50
  diskType: "pd-standard"
  
  # Network
  network: "default"
  subnetwork: "default"
  
  # Public IP
  assignPublicIPAddress: true
  
  # Labels
  labels:
    kubernetesCluster: "my-cluster"
```

### Using Secrets

Create a secret:

```bash
# Encode service account
SA_BASE64=$(cat key.json | base64 -w0)

# Create secret
kubectl create secret generic gcp-credentials \
  -n kube-system \
  --from-literal=serviceAccount=$SA_BASE64
```

Reference in MachineDeployment:

```yaml
cloudProviderSpec:
  serviceAccount:
    secretKeyRef:
      name: gcp-credentials
      key: serviceAccount
```

### All Configuration Options

```yaml
cloudProviderSpec:
  # Service account (base64-encoded JSON)
  serviceAccount: "<< BASE64_ENCODED_SA >>"
  # Can also be set via GOOGLE_SERVICE_ACCOUNT env var
  
  # Zone (required)
  zone: "us-central1-a"
  
  # Machine type
  machineType: "n1-standard-2"
  
  # Preemptible instances (spot VMs)
  preemptible: false
  
  # Disk configuration
  diskSize: 50  # GB
  diskType: "pd-standard"  # pd-standard, pd-ssd, or pd-balanced
  
  # Custom image (optional)
  customImage: ""
  # e.g., "projects/PROJECT_ID/global/images/IMAGE_NAME"
  # or "projects/ubuntu-os-cloud/global/images/family/ubuntu-2204-lts"
  
  # Network configuration
  network: "default"
  subnetwork: "default"
  # Can use name or full path:
  # network: "projects/PROJECT_ID/global/networks/NETWORK"
  # subnetwork: "projects/PROJECT_ID/regions/REGION/subnetworks/SUBNET"
  
  # Public IP
  assignPublicIPAddress: true
  
  # Service account for the instance (optional)
  # If true, no service account is assigned to the instance
  disableMachineServiceAccount: false
  # Or specify a custom service account email
  # email: "instance-sa@PROJECT_ID.iam.gserviceaccount.com"
  
  # Regional persistent disk (optional)
  regionalPersistentDisk: false
  
  # Labels (for resource organization)
  labels:
    kubernetesCluster: "my-cluster"
    environment: "production"
  
  # Tags (for firewall rules)
  tags:
    - "worker-node"
    - "kubernetes"
```

## Complete MachineDeployment Examples

### Basic Ubuntu Workers

```yaml
apiVersion: cluster.k8s.io/v1alpha1
kind: MachineDeployment
metadata:
  name: gcp-ubuntu-workers
  namespace: kube-system
spec:
  replicas: 3
  selector:
    matchLabels:
      name: gcp-ubuntu-workers
  template:
    metadata:
      labels:
        name: gcp-ubuntu-workers
    spec:
      providerSpec:
        value:
          cloudProvider: "gce"
          cloudProviderSpec:
            zone: "us-central1-a"
            machineType: "n1-standard-2"
            diskSize: 50
            diskType: "pd-balanced"
            network: "default"
            subnetwork: "default"
            assignPublicIPAddress: true
            serviceAccount:
              secretKeyRef:
                name: gcp-credentials
                key: serviceAccount
            labels:
              kubernetesCluster: "my-cluster"
            tags:
              - "worker-node"
          operatingSystem: "ubuntu"
          operatingSystemSpec:
            distUpgradeOnBoot: false
      versions:
        kubelet: "1.28.0"
```

### Preemptible (Spot) Instances

```yaml
apiVersion: cluster.k8s.io/v1alpha1
kind: MachineDeployment
metadata:
  name: gcp-preemptible-workers
  namespace: kube-system
spec:
  replicas: 5
  selector:
    matchLabels:
      name: gcp-preemptible-workers
  template:
    metadata:
      labels:
        name: gcp-preemptible-workers
    spec:
      providerSpec:
        value:
          cloudProvider: "gce"
          cloudProviderSpec:
            zone: "us-central1-a"
            machineType: "n1-standard-4"
            preemptible: true
            diskSize: 100
            diskType: "pd-standard"
            network: "default"
            subnetwork: "default"
            assignPublicIPAddress: true
            labels:
              kubernetesCluster: "my-cluster"
              workload: "batch"
          operatingSystem: "ubuntu"
      versions:
        kubelet: "1.28.0"
```

### High-Performance SSD Workers

```yaml
apiVersion: cluster.k8s.io/v1alpha1
kind: MachineDeployment
metadata:
  name: gcp-ssd-workers
  namespace: kube-system
spec:
  replicas: 2
  selector:
    matchLabels:
      name: gcp-ssd-workers
  template:
    metadata:
      labels:
        name: gcp-ssd-workers
    spec:
      providerSpec:
        value:
          cloudProvider: "gce"
          cloudProviderSpec:
            zone: "us-central1-a"
            machineType: "n1-highmem-4"
            diskSize: 200
            diskType: "pd-ssd"
            network: "default"
            subnetwork: "default"
            assignPublicIPAddress: true
            labels:
              kubernetesCluster: "my-cluster"
              workload: "database"
          operatingSystem: "ubuntu"
      versions:
        kubelet: "1.28.0"
```

### Flatcar Workers

```yaml
apiVersion: cluster.k8s.io/v1alpha1
kind: MachineDeployment
metadata:
  name: gcp-flatcar-workers
  namespace: kube-system
spec:
  replicas: 3
  selector:
    matchLabels:
      name: gcp-flatcar-workers
  template:
    metadata:
      labels:
        name: gcp-flatcar-workers
    spec:
      providerSpec:
        value:
          cloudProvider: "gce"
          cloudProviderSpec:
            zone: "us-central1-a"
            machineType: "n1-standard-2"
            customImage: "projects/kinvolk-public/global/images/family/flatcar-stable"
            diskSize: 50
            diskType: "pd-balanced"
            network: "default"
            subnetwork: "default"
            assignPublicIPAddress: true
            labels:
              kubernetesCluster: "my-cluster"
          operatingSystem: "flatcar"
      versions:
        kubelet: "1.28.0"
```

## Machine Types

### Common Machine Types

| Type | vCPUs | RAM | Use Case |
|------|-------|-----|----------|
| e2-medium | 2 | 4 GB | Cost-effective |
| n1-standard-2 | 2 | 7.5 GB | General purpose |
| n1-standard-4 | 4 | 15 GB | General purpose |
| n1-highmem-4 | 4 | 26 GB | Memory-intensive |
| n1-highcpu-4 | 4 | 3.6 GB | Compute-intensive |
| c2-standard-4 | 4 | 16 GB | Compute-optimized |

List available machine types:

```bash
gcloud compute machine-types list \
  --zones=us-central1-a \
  --filter="guestCpus<8" \
  --format="table(name,guestCpus,memoryMb)"
```

## Disk Types

- **pd-standard**: Standard persistent disk (HDD)
- **pd-balanced**: Balanced persistent disk (SSD) - recommended
- **pd-ssd**: SSD persistent disk - high performance
- **pd-extreme**: Extreme persistent disk - highest IOPS

## Networking

### VPC and Subnet

Workers should be in a subnet with:
- Access to Kubernetes API server
- Internet access (via Cloud NAT or external IP)
- Communication with other cluster nodes

### Firewall Rules

Required firewall rules:

```bash
# Allow kubelet API
gcloud compute firewall-rules create allow-kubelet \
  --network=default \
  --allow=tcp:10250 \
  --source-ranges=CONTROL_PLANE_CIDR \
  --target-tags=worker-node

# Allow NodePort services
gcloud compute firewall-rules create allow-nodeport \
  --network=default \
  --allow=tcp:30000-32767 \
  --source-ranges=0.0.0.0/0 \
  --target-tags=worker-node

# Allow internal communication
gcloud compute firewall-rules create allow-internal \
  --network=default \
  --allow=tcp,udp,icmp \
  --source-ranges=10.0.0.0/8 \
  --target-tags=worker-node
```

### Private Google Access

For private workers without public IPs:

```bash
# Enable Private Google Access on subnet
gcloud compute networks subnets update SUBNET_NAME \
  --region=REGION \
  --enable-private-ip-google-access
```

## Images

### Find Ubuntu Images

```bash
# List Ubuntu images
gcloud compute images list \
  --project=ubuntu-os-cloud \
  --filter="family:ubuntu-2204-lts" \
  --format="table(name,family,creationTimestamp)"

# Use in MachineDeployment
customImage: "projects/ubuntu-os-cloud/global/images/family/ubuntu-2204-lts"
```

### Find Flatcar Images

```bash
# List Flatcar images
gcloud compute images list \
  --project=kinvolk-public \
  --filter="family:flatcar-stable" \
  --format="table(name,family,creationTimestamp)"
```

## Preemptible Instances

### Configuration

```yaml
cloudProviderSpec:
  preemptible: true
  machineType: "n1-standard-4"
```

### Best Practices

1. **Cost Savings**: Up to 80% cheaper than regular instances
2. **24-hour Limit**: Terminated after 24 hours maximum
3. **Handle Interruptions**: Use for fault-tolerant workloads
4. **Mix with Regular**: Combine preemptible and regular instances
5. **Multiple Zones**: Spread across zones for availability

## Service Accounts

### Instance Service Account

By default, instances use the Compute Engine default service account. To disable:

```yaml
cloudProviderSpec:
  disableMachineServiceAccount: true
```

To use a custom service account:

```yaml
cloudProviderSpec:
  email: "worker-sa@PROJECT_ID.iam.gserviceaccount.com"
```

## Regional Persistent Disks

For high availability:

```yaml
cloudProviderSpec:
  regionalPersistentDisk: true
  zone: "us-central1-a"  # Primary zone
  # Disk replicated to another zone in the region
```

## Troubleshooting

### Instance Creation Fails

```bash
# Check machine events
kubectl describe machine <machine-name> -n kube-system

# Common issues:
# - Invalid service account permissions
# - Quota exceeded
# - Machine type not available in zone
# - Network/subnet not found
```

### Check GCP Operations

```bash
# List recent operations
gcloud compute operations list \
  --filter="zone:us-central1-a" \
  --limit=10

# Describe specific operation
gcloud compute operations describe OPERATION_NAME \
  --zone=us-central1-a
```

### Serial Console Output

```bash
# View instance serial console
gcloud compute instances get-serial-port-output INSTANCE_NAME \
  --zone=us-central1-a
```

## Multi-Zone Deployment

Deploy across multiple zones:

```yaml
---
apiVersion: cluster.k8s.io/v1alpha1
kind: MachineDeployment
metadata:
  name: workers-us-central1-a
  namespace: kube-system
spec:
  replicas: 2
  template:
    spec:
      providerSpec:
        value:
          cloudProviderSpec:
            zone: "us-central1-a"
---
apiVersion: cluster.k8s.io/v1alpha1
kind: MachineDeployment
metadata:
  name: workers-us-central1-b
  namespace: kube-system
spec:
  replicas: 2
  template:
    spec:
      providerSpec:
        value:
          cloudProviderSpec:
            zone: "us-central1-b"
```

## Best Practices

1. **Use Balanced Disks**: Good performance/cost ratio
2. **Enable Private Google Access**: For private instances
3. **Use Service Accounts**: Prefer instance service accounts over keys
4. **Tag Instances**: Use network tags for firewall rules
5. **Label Resources**: Use labels for organization and cost tracking
6. **Multi-Zone Deployment**: Spread workers across zones
7. **Monitor Quotas**: Check and increase quotas as needed
8. **Use Preemptible for Batch**: Leverage preemptible for cost savings

## Resources

- [GCP Machine Types](https://cloud.google.com/compute/docs/machine-types)
- [Persistent Disks](https://cloud.google.com/compute/docs/disks)
- [Preemptible VMs](https://cloud.google.com/compute/docs/instances/preemptible)
- [VPC Networking](https://cloud.google.com/vpc/docs)
- [GCP Pricing Calculator](https://cloud.google.com/products/calculator)
- [Service Accounts](https://cloud.google.com/iam/docs/service-accounts)

