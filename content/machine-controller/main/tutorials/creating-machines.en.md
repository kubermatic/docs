+++
title = "Creating Machines"
date = 2024-05-31T07:00:00+02:00
weight = 1
+++

This guide demonstrates how to use machine-controller to manage worker nodes in your Kubernetes cluster.

## Understanding Machine Resources

Machine-controller uses three main Kubernetes custom resources:

### MachineDeployment

Similar to Kubernetes Deployments, MachineDeployments manage a set of identical machines. They handle:
- Creating and scaling MachineSet resources
- Rolling updates when machine templates change
- Revision history and rollback capabilities

### MachineSet

MachineSet ensures that a specified number of Machine replicas are running. It's typically managed by MachineDeployment but can be used independently.

### Machine

Machine represents a single worker node. It contains the specification for creating a cloud instance and provisioning it to join the cluster.

## Creating a MachineDeployment

### Basic Example

Here's a minimal MachineDeployment example:

```yaml
apiVersion: cluster.k8s.io/v1alpha1
kind: MachineDeployment
metadata:
  name: my-workers
  namespace: kube-system
spec:
  replicas: 3
  selector:
    matchLabels:
      name: my-workers
  template:
    metadata:
      labels:
        name: my-workers
    spec:
      providerSpec:
        value:
          cloudProvider: "hetzner"
          cloudProviderSpec:
            token: "<HCLOUD_TOKEN>"
            serverType: "cx21"
            location: "fsn1"
            labels:
              kubernetesCluster: "my-cluster"
          operatingSystem: "ubuntu"
          operatingSystemSpec:
            distUpgradeOnBoot: false
      versions:
        kubelet: "1.28.0"
```

### Apply the MachineDeployment

```bash
kubectl apply -f machinedeployment.yaml
```

### Verify Creation

```bash
# Check MachineDeployment
kubectl get machinedeployments -n kube-system

# Check MachineSets
kubectl get machinesets -n kube-system

# Check Machines
kubectl get machines -n kube-system

# Check nodes
kubectl get nodes
```

## Scaling MachineDeployments

### Scale Up

```bash
kubectl scale machinedeployment my-workers --replicas=5 -n kube-system
```

### Scale Down

```bash
kubectl scale machinedeployment my-workers --replicas=2 -n kube-system
```

### Scale to Zero

Scaling to zero is useful for temporarily removing workers while preserving configuration:

```bash
kubectl scale machinedeployment my-workers --replicas=0 -n kube-system
```

## Updating MachineDeployments

### Update Machine Specifications

Edit the MachineDeployment to change instance type, operating system version, or other properties:

```bash
kubectl edit machinedeployment my-workers -n kube-system
```

Changes trigger a rolling update, creating new machines and deleting old ones according to the update strategy.

### Update Kubernetes Version

To upgrade the kubelet version:

```bash
kubectl patch machinedeployment my-workers -n kube-system --type merge -p '
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

### Monitor Rolling Update

```bash
kubectl rollout status machinedeployment my-workers -n kube-system
```

## Managing Multiple MachineDeployments

You can create multiple MachineDeployments for different workload types:

```yaml
---
apiVersion: cluster.k8s.io/v1alpha1
kind: MachineDeployment
metadata:
  name: general-workers
  namespace: kube-system
spec:
  replicas: 3
  selector:
    matchLabels:
      pool: general
  template:
    metadata:
      labels:
        pool: general
    spec:
      providerSpec:
        value:
          cloudProvider: "aws"
          cloudProviderSpec:
            instanceType: "t3.medium"
            # ... other AWS config
---
apiVersion: cluster.k8s.io/v1alpha1
kind: MachineDeployment
metadata:
  name: memory-intensive-workers
  namespace: kube-system
spec:
  replicas: 2
  selector:
    matchLabels:
      pool: memory
  template:
    metadata:
      labels:
        pool: memory
    spec:
      providerSpec:
        value:
          cloudProvider: "aws"
          cloudProviderSpec:
            instanceType: "r5.xlarge"
            # ... other AWS config
```

## Using Taints and Labels

### Add Node Labels

Specify custom labels in the Machine spec:

```yaml
spec:
  template:
    metadata:
      labels:
        name: my-workers
        environment: production
        workload-type: compute
```

### Add Node Taints

Add taints to control pod scheduling:

```yaml
spec:
  template:
    spec:
      taints:
      - key: "workload"
        value: "gpu"
        effect: "NoSchedule"
```

## Deleting Machines

### Delete a MachineDeployment

```bash
kubectl delete machinedeployment my-workers -n kube-system
```

This cascades deletion to MachineSets and Machines, and terminates the corresponding cloud instances.

### Delete Individual Machines

```bash
kubectl delete machine <machine-name> -n kube-system
```

The owning MachineSet will create a replacement machine to maintain the desired replica count.

## Inspecting Machine Status

### Get Detailed Machine Information

```bash
kubectl get machines -n kube-system -o wide
```

### Describe a Machine

```bash
kubectl describe machine <machine-name> -n kube-system
```

This shows:
- Cloud instance details
- Provisioning status
- Events and errors
- Node reference

### Check Machine Conditions

```bash
kubectl get machine <machine-name> -n kube-system -o jsonpath='{.status.conditions}'
```

## Working with Cloud Provider Credentials

### Using Secrets

Store credentials in Kubernetes secrets:

```bash
kubectl create secret generic cloud-credentials \
  -n kube-system \
  --from-literal=token=<your-token>
```

Reference in MachineDeployment:

```yaml
spec:
  template:
    spec:
      providerSpec:
        value:
          cloudProviderSpec:
            token:
              secretKeyRef:
                name: cloud-credentials
                key: token
```

### Using Environment Variables

Alternatively, configure credentials via environment variables on the machine-controller deployment.

## Best Practices

1. **Use MachineDeployments over individual Machines** for better management and self-healing
2. **Set appropriate resource limits** based on workload requirements
3. **Use meaningful labels** to organize and select machines
4. **Test changes in non-production** environments first
5. **Monitor machine creation** and ensure they join the cluster successfully
6. **Keep credentials secure** using Kubernetes secrets
7. **Document custom configurations** for team collaboration
8. **Regular updates** to keep kubelet versions current

## Troubleshooting Common Issues

### Machine Creation Fails

Check machine events:
```bash
kubectl describe machine <machine-name> -n kube-system
```

Common causes:
- Invalid cloud provider credentials
- Insufficient quota/limits
- Network configuration issues
- Invalid instance type or region

### Machine Not Joining Cluster

Check machine-controller logs:
```bash
kubectl logs -n kube-system deployment/machine-controller
```

Verify:
- Network connectivity between nodes
- Correct cluster join token
- Firewall rules allow required ports

### Slow Provisioning

Review:
- Cloud provider API rate limits
- Image availability in the region
- Network performance
- Machine-controller worker count

## Next Steps

- [Explore cloud provider configurations]({{< ref "../references/cloud-providers/" >}})
- [Learn about operating system options]({{< ref "../references/operating-systems/" >}})
- [Set up cluster autoscaler](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler)

