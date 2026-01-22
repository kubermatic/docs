+++
title = "Azure (Microsoft Azure)"
date = 2024-05-31T07:00:00+02:00
+++

This guide covers machine-controller configuration for Microsoft Azure.

## Prerequisites

- Azure subscription
- Service Principal or Managed Identity with appropriate permissions
- Resource Group, VNet, and subnet configured
- Kubernetes cluster with machine-controller installed

## Required Azure Permissions

The Service Principal needs the following role assignments:

- **Contributor** role on the Resource Group (or specific resources)
- Or custom role with these permissions:
  - `Microsoft.Compute/virtualMachines/*`
  - `Microsoft.Compute/disks/*`
  - `Microsoft.Network/networkInterfaces/*`
  - `Microsoft.Network/publicIPAddresses/*`
  - `Microsoft.Network/networkSecurityGroups/*`

## Create Service Principal

```bash
# Create service principal
az ad sp create-for-rbac --name "machine-controller-sp" --role Contributor \
  --scopes /subscriptions/SUB_ID/resourceGroups/RESOURCE_GROUP

# Output includes:
# - appId (clientID)
# - password (clientSecret)
# - tenant (tenantID)
```

## Provider Configuration

### Basic Configuration

```yaml
cloudProviderSpec:
  # Credentials
  tenantID: "<< AZURE_TENANT_ID >>"
  clientID: "<< AZURE_CLIENT_ID >>"
  clientSecret: "<< AZURE_CLIENT_SECRET >>"
  subscriptionID: "<< AZURE_SUBSCRIPTION_ID >>"
  
  # Location and resources
  location: "westeurope"
  resourceGroup: "my-k8s-cluster-rg"
  
  # Networking
  vnetName: "k8s-vnet"
  subnetName: "worker-subnet"
  
  # VM configuration
  vmSize: "Standard_D2s_v3"
  assignPublicIP: false
  
  # Tags
  tags:
    kubernetesCluster: "my-cluster"
```

### Using Secrets

Create a secret:

```bash
kubectl create secret generic azure-credentials \
  -n kube-system \
  --from-literal=tenantID=<TENANT_ID> \
  --from-literal=clientID=<CLIENT_ID> \
  --from-literal=clientSecret=<CLIENT_SECRET> \
  --from-literal=subscriptionID=<SUB_ID>
```

Reference in MachineDeployment:

```yaml
cloudProviderSpec:
  tenantID:
    secretKeyRef:
      name: azure-credentials
      key: tenantID
  clientID:
    secretKeyRef:
      name: azure-credentials
      key: clientID
  clientSecret:
    secretKeyRef:
      name: azure-credentials
      key: clientSecret
  subscriptionID:
    secretKeyRef:
      name: azure-credentials
      key: subscriptionID
```

### All Configuration Options

```yaml
cloudProviderSpec:
  # Credentials (can also use environment variables)
  tenantID: "<< AZURE_TENANT_ID >>"
  clientID: "<< AZURE_CLIENT_ID >>"
  clientSecret: "<< AZURE_CLIENT_SECRET >>"
  subscriptionID: "<< AZURE_SUBSCRIPTION_ID >>"
  
  # Location (Azure region)
  location: "westeurope"  # e.g., eastus, westus2, northeurope
  
  # Resource groups
  resourceGroup: "my-k8s-cluster-rg"
  vnetResourceGroup: "network-rg"  # Optional, if VNet is in different RG
  
  # Availability set (optional)
  availabilitySet: "worker-availability-set"
  
  # Availability zones (optional, alternative to availability set)
  zones:
    - "1"
    - "2"
  
  # VM configuration
  vmSize: "Standard_D2s_v3"
  
  # Disk configuration
  osDiskSize: 100  # GB, optional
  dataDiskSize: 50  # GB, optional
  
  # Image configuration
  # Option 1: Use marketplace image (recommended)
  imageReference:
    publisher: "Canonical"
    offer: "0001-com-ubuntu-server-jammy"
    sku: "22_04-lts-gen2"
    version: "latest"
  
  # Option 2: Use custom image
  # imageID: "/subscriptions/SUB_ID/resourceGroups/RG/providers/Microsoft.Compute/images/IMAGE_NAME"
  
  # Networking
  vnetName: "k8s-vnet"
  subnetName: "worker-subnet"
  routeTableName: "k8s-routes"  # Optional
  assignPublicIP: false
  
  # Network Security Group
  securityGroupName: "worker-nsg"  # Optional
  
  # Load balancer backend pool (optional)
  loadBalancerSku: "Standard"  # Basic or Standard
  
  # Tags
  tags:
    kubernetesCluster: "my-cluster"
    environment: "production"
```

## Complete MachineDeployment Examples

### Basic Ubuntu Workers

```yaml
apiVersion: cluster.k8s.io/v1alpha1
kind: MachineDeployment
metadata:
  name: azure-ubuntu-workers
  namespace: kube-system
spec:
  replicas: 3
  selector:
    matchLabels:
      name: azure-ubuntu-workers
  template:
    metadata:
      labels:
        name: azure-ubuntu-workers
    spec:
      providerSpec:
        value:
          cloudProvider: "azure"
          cloudProviderSpec:
            location: "westeurope"
            resourceGroup: "my-k8s-cluster-rg"
            vnetName: "k8s-vnet"
            subnetName: "worker-subnet"
            vmSize: "Standard_D2s_v3"
            osDiskSize: 100
            assignPublicIP: false
            imageReference:
              publisher: "Canonical"
              offer: "0001-com-ubuntu-server-jammy"
              sku: "22_04-lts-gen2"
              version: "latest"
            tenantID:
              secretKeyRef:
                name: azure-credentials
                key: tenantID
            clientID:
              secretKeyRef:
                name: azure-credentials
                key: clientID
            clientSecret:
              secretKeyRef:
                name: azure-credentials
                key: clientSecret
            subscriptionID:
              secretKeyRef:
                name: azure-credentials
                key: subscriptionID
            tags:
              kubernetesCluster: "my-cluster"
          operatingSystem: "ubuntu"
          operatingSystemSpec:
            distUpgradeOnBoot: false
      versions:
        kubelet: "1.28.0"
```

### Multi-Zone Deployment

```yaml
apiVersion: cluster.k8s.io/v1alpha1
kind: MachineDeployment
metadata:
  name: azure-multi-az-workers
  namespace: kube-system
spec:
  replicas: 3
  selector:
    matchLabels:
      name: azure-multi-az-workers
  template:
    metadata:
      labels:
        name: azure-multi-az-workers
    spec:
      providerSpec:
        value:
          cloudProvider: "azure"
          cloudProviderSpec:
            location: "westeurope"
            resourceGroup: "my-k8s-cluster-rg"
            zones:
              - "1"
              - "2"
              - "3"
            vnetName: "k8s-vnet"
            subnetName: "worker-subnet"
            vmSize: "Standard_D2s_v3"
            assignPublicIP: false
            tags:
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
  name: azure-performance-workers
  namespace: kube-system
spec:
  replicas: 2
  selector:
    matchLabels:
      name: azure-performance-workers
  template:
    metadata:
      labels:
        name: azure-performance-workers
    spec:
      providerSpec:
        value:
          cloudProvider: "azure"
          cloudProviderSpec:
            location: "westeurope"
            resourceGroup: "my-k8s-cluster-rg"
            vnetName: "k8s-vnet"
            subnetName: "worker-subnet"
            vmSize: "Standard_F16s_v2"  # Compute-optimized
            osDiskSize: 200
            dataDiskSize: 500
            assignPublicIP: false
            tags:
              kubernetesCluster: "my-cluster"
              workloadType: "compute-intensive"
          operatingSystem: "ubuntu"
      versions:
        kubelet: "1.28.0"
```

### Rocky Linux Workers

```yaml
apiVersion: cluster.k8s.io/v1alpha1
kind: MachineDeployment
metadata:
  name: azure-rocky-workers
  namespace: kube-system
spec:
  replicas: 3
  selector:
    matchLabels:
      name: azure-rocky-workers
  template:
    metadata:
      labels:
        name: azure-rocky-workers
    spec:
      providerSpec:
        value:
          cloudProvider: "azure"
          cloudProviderSpec:
            location: "westeurope"
            resourceGroup: "my-k8s-cluster-rg"
            vnetName: "k8s-vnet"
            subnetName: "worker-subnet"
            vmSize: "Standard_D2s_v3"
            imageReference:
              publisher: "erockyenterprisesoftwarefoundationinc1653071250513"
              offer: "rockylinux"
              sku: "rocky-linux-8"
              version: "latest"
            assignPublicIP: false
            tags:
              kubernetesCluster: "my-cluster"
          operatingSystem: "rockylinux"
      versions:
        kubelet: "1.28.0"
```

## VM Sizes

### Common VM Sizes

| Size | vCPUs | RAM | Use Case |
|------|-------|-----|----------|
| Standard_B2s | 2 | 4 GB | Development/testing |
| Standard_D2s_v3 | 2 | 8 GB | General purpose |
| Standard_D4s_v3 | 4 | 16 GB | General purpose |
| Standard_F4s_v2 | 4 | 8 GB | Compute optimized |
| Standard_E4s_v3 | 4 | 32 GB | Memory optimized |

List available sizes in a location:

```bash
az vm list-sizes --location westeurope --output table
```

## Networking

### VNet and Subnet

Workers must be in a subnet that can reach:
- Kubernetes API server
- Internet (for package downloads) via NAT Gateway or public IP
- Other cluster nodes

### Network Security Groups

Create NSG with required rules:

```bash
# Create NSG
az network nsg create \
  --resource-group my-k8s-cluster-rg \
  --name worker-nsg

# Allow kubelet API
az network nsg rule create \
  --resource-group my-k8s-cluster-rg \
  --nsg-name worker-nsg \
  --name allow-kubelet \
  --priority 100 \
  --source-address-prefixes VirtualNetwork \
  --destination-port-ranges 10250 \
  --access Allow \
  --protocol Tcp

# Allow NodePort services
az network nsg rule create \
  --resource-group my-k8s-cluster-rg \
  --nsg-name worker-nsg \
  --name allow-nodeport \
  --priority 110 \
  --source-address-prefixes '*' \
  --destination-port-ranges 30000-32767 \
  --access Allow \
  --protocol Tcp
```

## Availability Sets vs Availability Zones

### Availability Sets

- Within same datacenter
- Protection against hardware failures
- 99.95% SLA

```yaml
cloudProviderSpec:
  availabilitySet: "worker-availability-set"
```

### Availability Zones

- Separate physical datacenters
- Protection against datacenter failures
- 99.99% SLA
- Not available in all regions

```yaml
cloudProviderSpec:
  zones:
    - "1"
    - "2"
    - "3"
```

{{% notice warning %}}
Cannot use both availability sets and zones in the same MachineDeployment.
{{% /notice %}}

## Managed Identities

Instead of Service Principal, use Managed Identity (for Azure-hosted controllers):

```yaml
cloudProviderSpec:
  # Use system-assigned managed identity
  useManagedIdentityExtension: true
  # No need for clientID, clientSecret if using managed identity
  subscriptionID: "<< SUBSCRIPTION_ID >>"
```

## Troubleshooting

### VM Creation Fails

```bash
# Check machine events
kubectl describe machine <machine-name> -n kube-system

# Common issues:
# - Invalid credentials
# - Quota exceeded
# - VM size not available in region/zone
# - Network configuration errors
```

### Check Azure Activity Log

```bash
# View recent operations
az monitor activity-log list \
  --resource-group my-k8s-cluster-rg \
  --max-events 20 \
  --output table
```

### Node Not Joining

```bash
# Get VM details
az vm show \
  --resource-group my-k8s-cluster-rg \
  --name worker-vm-name

# Run command on VM
az vm run-command invoke \
  --resource-group my-k8s-cluster-rg \
  --name worker-vm-name \
  --command-id RunShellScript \
  --scripts "systemctl status kubelet"
```

## Best Practices

1. **Use Managed Identities**: Prefer managed identities over service principals
2. **Use Availability Zones**: For production workloads
3. **Private IPs**: Deploy workers without public IPs, use NAT Gateway
4. **Tag Resources**: Use consistent tagging strategy
5. **Monitor Costs**: Enable Azure Cost Management
6. **Use Latest Images**: Keep marketplace images updated
7. **Right-Size VMs**: Start small, scale based on metrics
8. **Separate Resource Groups**: Consider separate RGs for networking

## Resources

- [Azure VM Sizes](https://docs.microsoft.com/en-us/azure/virtual-machines/sizes)
- [Azure Availability Zones](https://docs.microsoft.com/en-us/azure/availability-zones/az-overview)
- [Azure Managed Identities](https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/)
- [Azure Networking](https://docs.microsoft.com/en-us/azure/virtual-network/)
- [Azure Pricing Calculator](https://azure.microsoft.com/en-us/pricing/calculator/)

