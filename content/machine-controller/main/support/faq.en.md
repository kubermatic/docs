+++
title = "FAQ"
date = 2024-05-31T07:00:00+02:00
weight = 1
+++

Frequently asked questions about machine-controller.

## General Questions

### What is machine-controller?

Machine-controller is a Kubernetes controller that manages the lifecycle of worker nodes across multiple cloud providers. It implements the Cluster API specification, allowing you to create, update, and delete machines using Kubernetes resources.

### How does machine-controller differ from Cluster API?

Machine-controller is an implementation of the Cluster API specification, specifically focused on managing worker nodes. While Cluster API provides a complete solution including control plane management, machine-controller focuses solely on worker node lifecycle management and is commonly used with [KubeOne]({{< ref "/kubeone/" >}}) for control plane management.

### Which cloud providers are supported?

Machine-controller supports:
- AWS (Amazon Web Services)
- Azure (Microsoft Azure)
- DigitalOcean
- Google Cloud Platform (GCP)
- Hetzner Cloud
- KubeVirt
- Nutanix
- OpenStack
- Equinix Metal
- VMware Cloud Director
- VMware vSphere
- Alibaba Cloud
- Anexia

See [Cloud Providers]({{< ref "../references/cloud-providers/" >}}) for detailed configuration.

### What operating systems are supported?

Machine-controller supports:
- Ubuntu (20.04, 22.04, 24.04 LTS)
- Flatcar Container Linux
- RHEL 8.x
- Rocky Linux 8.5+
- Amazon Linux 2

Support varies by cloud provider. See the [OS support matrix]({{< ref "../references/operating-systems/" >}}) for details.

## Installation and Configuration

### How do I install machine-controller?

The recommended way is through [KubeOne]({{< ref "/kubeone/" >}}), which automatically installs and configures machine-controller. For manual installation, see the [Installation Guide]({{< ref "../installation/" >}}).

### Where should machine-controller run?

Machine-controller runs as a Deployment in the `kube-system` namespace, typically on control plane nodes or dedicated infrastructure nodes.

### How do I configure cloud provider credentials?

Credentials can be provided via:
1. Kubernetes Secrets (recommended for production)
2. Environment variables on the machine-controller deployment
3. Instance metadata/IAM roles (for cloud instances)

Example using secrets:
```bash
kubectl create secret generic cloud-credentials \
  -n kube-system \
  --from-literal=token=<your-token>
```

### Can I use multiple cloud providers in the same cluster?

Yes! You can create MachineDeployments for different cloud providers in the same cluster. Each MachineDeployment specifies its own provider configuration.

## Usage and Operations

### How do I create worker nodes?

Create a MachineDeployment resource:

```bash
kubectl apply -f machinedeployment.yaml
```

See the [Usage Guide]({{< ref "../tutorials/creating-machines/" >}}) for detailed examples.

### How do I scale worker nodes?

Use kubectl to scale:
```bash
kubectl scale machinedeployment <name> --replicas=5 -n kube-system
```

### Can I scale to zero?

Yes! Scaling to zero is supported and useful for temporarily removing workers while preserving configuration:
```bash
kubectl scale machinedeployment <name> --replicas=0 -n kube-system
```

### How do I update Kubernetes version on worker nodes?

Update the kubelet version in the MachineDeployment spec:
```bash
kubectl patch machinedeployment <name> -n kube-system --type merge -p '
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

This triggers a rolling update.

### How do I change instance type or size?

Edit the MachineDeployment and update the cloud provider spec:
```bash
kubectl edit machinedeployment <name> -n kube-system
```

Change the instance type field (e.g., `instanceType`, `machineType`, `serverType`) and save. A rolling update will occur.

### How long does it take to provision a new machine?

Provisioning time varies by cloud provider and OS:
- **Fast** (2-5 min): Hetzner, DigitalOcean, AWS with optimized AMIs
- **Medium** (5-10 min): Azure, GCP, AWS with base images
- **Slow** (10-15 min): OpenStack, vSphere (depends on configuration)

Factors affecting speed:
- Image/template availability
- Network performance
- Package download speeds
- Cloud provider API responsiveness

## Cluster Autoscaler Integration

### Does machine-controller work with cluster-autoscaler?

Yes! Machine-controller is fully compatible with Kubernetes cluster-autoscaler. Annotate your MachineDeployments with min/max sizes:

```yaml
metadata:
  annotations:
    cluster.k8s.io/cluster-api-autoscaler-node-group-min-size: "1"
    cluster.k8s.io/cluster-api-autoscaler-node-group-max-size: "10"
```

### How do I set up autoscaling?

1. Deploy cluster-autoscaler with Cluster API support
2. Annotate MachineDeployments with min/max size
3. Configure autoscaler to watch MachineDeployments

See the [cluster-autoscaler documentation](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler/cloudprovider/clusterapi) for details.

## Troubleshooting

### My machine is stuck in "Provisioning" state. What should I do?

1. Check machine events: `kubectl describe machine <name> -n kube-system`
2. Check machine-controller logs: `kubectl logs -n kube-system deployment/machine-controller`
3. Verify cloud provider credentials
4. Check for quota/limit issues
5. Verify network connectivity

See the [Troubleshooting Guide]({{< ref "./troubleshooting/" >}}) for detailed steps.

### Why isn't my machine joining the cluster?

Common causes:
- Network connectivity issues between node and API server
- Invalid bootstrap token
- Firewall blocking required ports
- Kubelet failing to start

Check kubelet logs on the instance:
```bash
ssh into-instance
journalctl -u kubelet -f
```

### How do I debug machine creation failures?

1. Enable debug logging: Edit machine-controller deployment and set `-v=6`
2. Check cloud provider console for instance status
3. Access instance via SSH/console and check cloud-init logs:
   ```bash
   sudo journalctl -u cloud-init-output
   cat /var/log/cloud-init.log
   ```

### Can I manually delete a stuck machine?

Yes, but be careful:
```bash
# Remove finalizers to force delete
kubectl patch machine <name> -n kube-system -p '{"metadata":{"finalizers":[]}}' --type=merge

# Delete the machine
kubectl delete machine <name> -n kube-system
```

Manually clean up cloud resources if they still exist.

## Advanced Topics

### Can I use custom images?

Yes! Specify a custom AMI/image ID in your provider configuration:

```yaml
cloudProviderSpec:
  # AWS example
  ami: "ami-xxxxx"
  
  # Azure example  
  imageReference:
    publisher: "my-publisher"
    offer: "my-offer"
    sku: "my-sku"
    version: "latest"
```

Ensure the image is compatible with the selected OS.

### How do I add custom user data or scripts?

Use the `network` field in the Machine spec to add custom cloud-init:

```yaml
spec:
  providerSpec:
    value:
      cloudProvider: "aws"
      # ... other config
      network:
        cidr: ""
        gateway: ""
        dns:
          servers: []
      # Custom cloud-init
      cloudInit: |
        #cloud-config
        runcmd:
          - echo "Custom initialization"
```

### Can I use spot/preemptible instances?

Yes, for supported providers:

**AWS:**
```yaml
cloudProviderSpec:
  isSpotInstance: true
```

**GCP:**
```yaml
cloudProviderSpec:
  preemptible: true
```

Note: Spot instances can be terminated at any time, ensure your workloads are tolerant of this.

### How do I use private networks?

Configure private networking in your provider spec:

**AWS:**
```yaml
cloudProviderSpec:
  assignPublicIP: false
  subnetId: "subnet-private"
```

**Hetzner:**
```yaml
cloudProviderSpec:
  networks:
    - "my-private-network"
```

Ensure nodes can reach the API server and download packages.

### Can I pin machines to specific availability zones?

Yes, specify the zone/availability zone in the provider config:

```yaml
cloudProviderSpec:
  # AWS
  availabilityZone: "us-east-1a"
  
  # GCP
  zone: "us-central1-a"
  
  # Azure
  zone: "1"
```

### How do I add labels and taints to nodes?

Specify them in the Machine spec:

```yaml
spec:
  template:
    metadata:
      labels:
        environment: production
        workload: compute
    spec:
      taints:
      - key: "dedicated"
        value: "gpu"
        effect: "NoSchedule"
```

### Can I drain nodes before deletion?

Yes, machine-controller automatically drains nodes before deletion. Configure drain behavior:

```yaml
spec:
  template:
    spec:
      metadata:
        annotations:
          "machine.k8s.io/exclude-node-draining": "false"  # Enable draining (default)
```

## Performance and Limits

### How many machines can machine-controller manage?

Machine-controller can manage thousands of machines. Performance depends on:
- Worker count configuration
- Cloud provider API rate limits
- Kubernetes API server performance

For large deployments, increase worker count:
```bash
kubectl edit deployment machine-controller -n kube-system
# Add: -worker-count=20
```

### How much resources does machine-controller need?

Typical requirements:
- **CPU**: 100-500m (depends on machine count and worker count)
- **Memory**: 256-512Mi base + ~10Mi per machine

### What are cloud provider rate limits?

Each provider has different limits:
- **AWS**: Generally high, rarely an issue
- **Azure**: ~1200 requests per hour per subscription
- **DigitalOcean**: 5000 requests per hour
- **Hetzner**: 3600 requests per hour

Reduce worker count if hitting rate limits.

## Security

### How are credentials stored?

Credentials should be stored in Kubernetes Secrets with appropriate RBAC permissions. Machine-controller only needs `get` and `list` permissions on specific secrets.

### Can I use IAM roles instead of static credentials?

Yes, for cloud platforms that support instance metadata:
- **AWS**: Use IAM instance profiles
- **GCP**: Use service account impersonation
- **Azure**: Use managed identities

### What permissions does machine-controller need?

Machine-controller needs permissions to:
- Create, read, update, delete compute instances
- Manage security groups, networks (depending on configuration)
- Read/write Kubernetes resources (machines, machinesets, machinedeployments, nodes)

See cloud provider documentation for exact IAM policies/roles needed.

## Upgrading and Migration

### How do I upgrade machine-controller?

Update the image version:
```bash
kubectl set image deployment/machine-controller \
  machine-controller=quay.io/kubermatic/machine-controller:v1.59.0 \
  -n kube-system
```

Check release notes for breaking changes.

### Can I migrate from manually managed nodes?

Yes, but it requires:
1. Creating MachineDeployments for new nodes
2. Cordoning old nodes
3. Draining workloads to new nodes
4. Decommissioning old nodes

There's no automated migration path.

### How do I migrate between cloud providers?

Create MachineDeployments in the new cloud provider, then:
1. Scale up new MachineDeployment
2. Wait for nodes to join and become ready
3. Cordon old nodes
4. Drain workloads
5. Scale down old MachineDeployment

## Community and Support

### Where can I get help?

- [GitHub Issues](https://github.com/kubermatic/machine-controller/issues)
- [Kubermatic Slack](https://kubermatic.slack.com)
- [GitHub Discussions](https://github.com/kubermatic/machine-controller/discussions)

### How do I report bugs?

Open an issue on GitHub with:
- Machine-controller version
- Kubernetes version
- Cloud provider
- Detailed description and reproduction steps
- Relevant logs (sanitized)

### Can I contribute?

Yes! Contributions are welcome. See the [Development Guide]({{< ref "../developing/" >}}) for details.

### Is there commercial support?

Yes, [Kubermatic](https://www.kubermatic.com/) offers commercial support for machine-controller as part of their products.

## Migration from Other Tools

### How does this compare to kops?

- **machine-controller**: Manages worker nodes only, uses Cluster API
- **kops**: Complete cluster lifecycle management (control plane + workers)

Use machine-controller with KubeOne for a similar experience.

### How does this compare to kubeadm?

- **machine-controller**: Automated cloud instance provisioning and management
- **kubeadm**: Manual cluster bootstrapping tool

Machine-controller uses kubeadm internally for node provisioning.

### Can I use this with managed Kubernetes?

Machine-controller is designed for self-managed clusters. For managed Kubernetes (EKS, GKE, AKS), use the provider's native node group/pool management.

## Best Practices

### What are the recommended settings?

- Use MachineDeployments over individual Machines
- Set appropriate resource requests/limits
- Use Secrets for credentials
- Enable monitoring and alerting
- Test changes in non-production first
- Keep machine-controller updated
- Document custom configurations
- Use meaningful labels for organization

### Should I run multiple MachineDeployments?

Yes, for:
- Different instance types (general vs. compute vs. memory)
- Different availability zones
- Different workload types (GPU vs. CPU)
- Different scaling policies

### How should I organize machines?

Use labels to categorize:
```yaml
metadata:
  labels:
    environment: production
    pool: general
    region: us-east
    cost-center: engineering
```

Use node selectors and affinity rules to schedule workloads appropriately.

