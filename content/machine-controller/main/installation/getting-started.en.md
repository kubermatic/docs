+++
title = "Getting Started"
date = 2024-05-31T07:00:00+02:00
weight = 1
+++

This guide will help you get started with machine-controller to manage worker nodes in your Kubernetes cluster.

## What You'll Learn

By the end of this guide, you'll know how to:
- Install machine-controller
- Create your first MachineDeployment
- Scale worker nodes
- Update node configurations

## Prerequisites

Before you begin, ensure you have:

- A running Kubernetes cluster (v1.20 or higher)
- `kubectl` configured to access your cluster
- Cloud provider account and credentials
- Cluster admin permissions

## Quick Start

### Step 1: Install machine-controller

The easiest way to install machine-controller is through [KubeOne]({{< ref "/kubeone/" >}}):

```bash
# Install with KubeOne (recommended)
kubeone apply --manifest kubeone.yaml --tfjson tf.json
```

For manual installation, see the [Installation Guide]({{< ref "./quickstart/" >}}).

### Step 2: Configure Cloud Provider Credentials

Create a Kubernetes secret with your cloud provider credentials:

**For Hetzner Cloud:**
```bash
kubectl create secret generic hcloud-credentials \
  -n kube-system \
  --from-literal=token=<YOUR_HCLOUD_TOKEN>
```

**For AWS:**
```bash
kubectl create secret generic aws-credentials \
  -n kube-system \
  --from-literal=accessKeyId=<YOUR_ACCESS_KEY> \
  --from-literal=secretAccessKey=<YOUR_SECRET_KEY>
```

**For other providers**, see [Cloud Providers]({{< ref "../references/cloud-providers/" >}}).

### Step 3: Create Your First MachineDeployment

Create a file named `machinedeployment.yaml`:

```yaml
apiVersion: cluster.k8s.io/v1alpha1
kind: MachineDeployment
metadata:
  name: my-first-workers
  namespace: kube-system
spec:
  replicas: 2
  selector:
    matchLabels:
      name: my-first-workers
  template:
    metadata:
      labels:
        name: my-first-workers
    spec:
      providerSpec:
        value:
          cloudProvider: "hetzner"
          cloudProviderSpec:
            serverType: "cx21"
            location: "fsn1"
            labels:
              kubernetesCluster: "my-cluster"
            token:
              secretKeyRef:
                name: hcloud-credentials
                key: token
          operatingSystem: "ubuntu"
          operatingSystemSpec:
            distUpgradeOnBoot: false
      versions:
        kubelet: "1.28.0"
```

Apply the MachineDeployment:

```bash
kubectl apply -f machinedeployment.yaml
```

### Step 4: Watch Machines Being Created

Monitor the progress:

```bash
# Watch MachineDeployment
kubectl get machinedeployments -n kube-system -w

# Watch Machines
kubectl get machines -n kube-system -w

# Watch nodes joining
kubectl get nodes -w
```

After a few minutes, you should see new nodes joining your cluster!

### Step 5: Verify the Setup

Check that everything is working:

```bash
# List all nodes
kubectl get nodes

# Describe a machine
kubectl describe machine <machine-name> -n kube-system

# Check machine-controller logs
kubectl logs -n kube-system deployment/machine-controller
```

## Common Operations

### Scale Your Workers

Scale up:
```bash
kubectl scale machinedeployment my-first-workers --replicas=5 -n kube-system
```

Scale down:
```bash
kubectl scale machinedeployment my-first-workers --replicas=2 -n kube-system
```

### Update Node Configuration

Edit the MachineDeployment to change instance types, zones, or other settings:

```bash
kubectl edit machinedeployment my-first-workers -n kube-system
```

This triggers a rolling update.

### Upgrade Kubernetes Version

Update the kubelet version:

```bash
kubectl patch machinedeployment my-first-workers -n kube-system --type merge -p '
{
  "spec": {
    "template": {
      "spec": {
        "versions": {
          "kubelet": "1.29.0"
        }
      }
    }
  }
}'
```

### Delete Worker Nodes

Delete the MachineDeployment:

```bash
kubectl delete machinedeployment my-first-workers -n kube-system
```

This will:
1. Drain the nodes
2. Delete the Machines
3. Terminate the cloud instances

## Example Configurations

### AWS Example

```yaml
apiVersion: cluster.k8s.io/v1alpha1
kind: MachineDeployment
metadata:
  name: aws-workers
  namespace: kube-system
spec:
  replicas: 3
  selector:
    matchLabels:
      name: aws-workers
  template:
    metadata:
      labels:
        name: aws-workers
    spec:
      providerSpec:
        value:
          cloudProvider: "aws"
          cloudProviderSpec:
            region: "us-east-1"
            availabilityZone: "us-east-1a"
            vpcId: "vpc-xxxxx"
            subnetId: "subnet-xxxxx"
            instanceType: "t3.medium"
            diskSize: 50
            tags:
              KubernetesCluster: "my-cluster"
            accessKeyId:
              secretKeyRef:
                name: aws-credentials
                key: accessKeyId
            secretAccessKey:
              secretKeyRef:
                name: aws-credentials
                key: secretAccessKey
          operatingSystem: "ubuntu"
          operatingSystemSpec:
            distUpgradeOnBoot: false
      versions:
        kubelet: "1.28.0"
```

### Azure Example

```yaml
apiVersion: cluster.k8s.io/v1alpha1
kind: MachineDeployment
metadata:
  name: azure-workers
  namespace: kube-system
spec:
  replicas: 3
  selector:
    matchLabels:
      name: azure-workers
  template:
    metadata:
      labels:
        name: azure-workers
    spec:
      providerSpec:
        value:
          cloudProvider: "azure"
          cloudProviderSpec:
            location: "westeurope"
            resourceGroup: "my-resource-group"
            vnetName: "my-vnet"
            subnetName: "my-subnet"
            vmSize: "Standard_B2s"
            assignPublicIP: true
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
          operatingSystem: "ubuntu"
          operatingSystemSpec:
            distUpgradeOnBoot: false
      versions:
        kubelet: "1.28.0"
```

### GCP Example

```yaml
apiVersion: cluster.k8s.io/v1alpha1
kind: MachineDeployment
metadata:
  name: gcp-workers
  namespace: kube-system
spec:
  replicas: 3
  selector:
    matchLabels:
      name: gcp-workers
  template:
    metadata:
      labels:
        name: gcp-workers
    spec:
      providerSpec:
        value:
          cloudProvider: "gce"
          cloudProviderSpec:
            zone: "us-central1-a"
            machineType: "n1-standard-2"
            diskSize: 50
            diskType: "pd-standard"
            network: "default"
            subnetwork: "default"
            assignPublicIPAddress: true
            serviceAccount:
              secretKeyRef:
                name: gcp-credentials
                key: serviceAccount
          operatingSystem: "ubuntu"
          operatingSystemSpec:
            distUpgradeOnBoot: false
      versions:
        kubelet: "1.28.0"
```

## Multiple Machine Pools

You can create different pools for different workload types:

```yaml
---
# General purpose workers
apiVersion: cluster.k8s.io/v1alpha1
kind: MachineDeployment
metadata:
  name: general-workers
  namespace: kube-system
spec:
  replicas: 3
  template:
    metadata:
      labels:
        pool: general
    # ... spec for t3.medium instances

---
# Memory-intensive workers
apiVersion: cluster.k8s.io/v1alpha1
kind: MachineDeployment
metadata:
  name: memory-workers
  namespace: kube-system
spec:
  replicas: 2
  template:
    metadata:
      labels:
        pool: memory
    # ... spec for r5.xlarge instances

---
# Compute-intensive workers
apiVersion: cluster.k8s.io/v1alpha1
kind: MachineDeployment
metadata:
  name: compute-workers
  namespace: kube-system
spec:
  replicas: 2
  template:
    metadata:
      labels:
        pool: compute
    # ... spec for c5.2xlarge instances
```

## Troubleshooting

### Machine Not Joining Cluster

If machines are created but not joining the cluster:

1. **Check machine status:**
   ```bash
   kubectl describe machine <machine-name> -n kube-system
   ```

2. **Check machine-controller logs:**
   ```bash
   kubectl logs -n kube-system deployment/machine-controller
   ```

3. **Verify credentials are correct**

4. **Check network connectivity** between nodes and API server

See the [Troubleshooting Guide]({{< ref "../support/troubleshooting/" >}}) for more help.

### Slow Provisioning

If machines take too long to provision:

- Check cloud provider status pages for outages
- Verify image/AMI is available in your region
- Check if you've hit quota limits
- Review network performance

## Best Practices

1. **Use Secrets for Credentials**: Never hardcode credentials in manifests
2. **Label Your Machines**: Use meaningful labels for organization
3. **Start Small**: Begin with 1-2 replicas, then scale up
4. **Test in Non-Production**: Validate configurations before production use
5. **Monitor Provisioning**: Set up alerts for failed machine creation
6. **Keep Updated**: Regularly update machine-controller and node versions
7. **Document Custom Settings**: Maintain documentation for team collaboration
8. **Use Multiple Pools**: Separate workload types for better resource management

## Next Steps

Now that you have machine-controller running, explore:

- **[Cloud Provider Configurations]({{< ref "../references/cloud-providers/" >}})**: Detailed provider settings
- **[Operating Systems]({{< ref "../references/operating-systems/" >}})**: OS configuration options
- **[Usage Guide]({{< ref "../tutorials/creating-machines/" >}})**: Advanced usage patterns
- **[Architecture]({{< ref "../architecture/" >}})**: How machine-controller works
- **[FAQ]({{< ref "../support/faq/" >}})**: Common questions and answers

## Getting Help

Need assistance?

- Check the [FAQ]({{< ref "../support/faq/" >}})
- Review the [Troubleshooting Guide]({{< ref "../support/troubleshooting/" >}})
- Search [GitHub Issues](https://github.com/kubermatic/machine-controller/issues)
- Join [Kubermatic Slack](https://kubermatic.slack.com)
- Open a [new issue](https://github.com/kubermatic/machine-controller/issues/new)

## Resources

- [GitHub Repository](https://github.com/kubermatic/machine-controller)
- [Example Manifests](https://github.com/kubermatic/machine-controller/tree/main/examples)
- [KubeOne Documentation]({{< ref "/kubeone/" >}})
- [Cluster API Documentation](https://cluster-api.sigs.k8s.io/)

